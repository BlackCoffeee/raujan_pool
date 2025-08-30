# Point 4: Refund Management

## 📋 Overview

Implementasi sistem manajemen refund dengan refund request processing, refund approval workflow, dan refund calculation.

## 🎯 Objectives

- Refund request processing
- Refund approval workflow
- Refund calculation
- Refund notifications
- Refund history
- Refund analytics

## 📁 Files Structure

```
phase-4/
├── 04-refund-management.md
├── app/Http/Controllers/RefundController.php
├── app/Models/Refund.php
├── app/Services/RefundService.php
└── app/Http/Requests/RefundRequest.php
```

## 🔧 Implementation Steps

### Step 1: Create Refund Model

```php
<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Refund extends Model
{
    use HasFactory;

    protected $fillable = [
        'payment_id',
        'booking_id',
        'amount',
        'reason',
        'status',
        'requested_by',
        'approved_by',
        'processed_at',
        'refund_method',
        'refund_reference',
        'notes',
        'admin_notes',
    ];

    protected $casts = [
        'amount' => 'decimal:2',
        'processed_at' => 'datetime',
    ];

    public function payment()
    {
        return $this->belongsTo(Payment::class);
    }

    public function booking()
    {
        return $this->belongsTo(Booking::class);
    }

    public function requestedBy()
    {
        return $this->belongsTo(User::class, 'requested_by');
    }

    public function approvedBy()
    {
        return $this->belongsTo(User::class, 'approved_by');
    }

    public function getStatusDisplayAttribute()
    {
        return match($this->status) {
            'pending' => 'Pending Approval',
            'approved' => 'Approved',
            'rejected' => 'Rejected',
            'processed' => 'Processed',
            default => 'Unknown'
        };
    }

    public function getRefundMethodDisplayAttribute()
    {
        return match($this->refund_method) {
            'bank_transfer' => 'Bank Transfer',
            'cash' => 'Cash Refund',
            'credit' => 'Account Credit',
            default => 'Unknown'
        };
    }

    public function getIsPendingAttribute()
    {
        return $this->status === 'pending';
    }

    public function getIsApprovedAttribute()
    {
        return $this->status === 'approved';
    }

    public function getIsRejectedAttribute()
    {
        return $this->status === 'rejected';
    }

    public function getIsProcessedAttribute()
    {
        return $this->status === 'processed';
    }

    public function getCanBeApprovedAttribute()
    {
        return $this->status === 'pending';
    }

    public function getCanBeRejectedAttribute()
    {
        return $this->status === 'pending';
    }

    public function getCanBeProcessedAttribute()
    {
        return $this->status === 'approved';
    }

    public function getProcessingTimeAttribute()
    {
        if (!$this->processed_at) {
            return null;
        }

        return $this->created_at->diffForHumans($this->processed_at);
    }

    public function getApprovalTimeAttribute()
    {
        if (!$this->approved_by) {
            return null;
        }

        return $this->created_at->diffForHumans($this->updated_at);
    }

    public function generateRefundReference()
    {
        $prefix = 'REF';
        $date = now()->format('Ymd');
        $random = str_pad(rand(1, 9999), 4, '0', STR_PAD_LEFT);

        return $prefix . $date . $random;
    }

    public function scopeByStatus($query, $status)
    {
        return $query->where('status', $status);
    }

    public function scopeByUser($query, $userId)
    {
        return $query->where('requested_by', $userId);
    }

    public function scopeByDateRange($query, $startDate, $endDate)
    {
        return $query->whereBetween('created_at', [$startDate, $endDate]);
    }

    public function scopeByAmountRange($query, $minAmount, $maxAmount)
    {
        return $query->whereBetween('amount', [$minAmount, $maxAmount]);
    }

    public function scopePending($query)
    {
        return $query->where('status', 'pending');
    }

    public function scopeApproved($query)
    {
        return $query->where('status', 'approved');
    }

    public function scopeRejected($query)
    {
        return $query->where('status', 'rejected');
    }

    public function scopeProcessed($query)
    {
        return $query->where('status', 'processed');
    }

    public function scopeByRefundMethod($query, $refundMethod)
    {
        return $query->where('refund_method', $refundMethod);
    }
}
```

### Step 2: Create Refund Service

```php
<?php

namespace App\Services;

use App\Models\Refund;
use App\Models\Payment;
use App\Models\Booking;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;
use Carbon\Carbon;

class RefundService
{
    public function createRefundRequest($data)
    {
        return DB::transaction(function () use ($data) {
            $payment = Payment::findOrFail($data['payment_id']);
            $booking = $payment->booking;

            // Validate refund eligibility
            $this->validateRefundEligibility($payment, $booking);

            // Calculate refund amount
            $refundAmount = $this->calculateRefundAmount($payment, $booking, $data);

            // Create refund request
            $refund = Refund::create([
                'payment_id' => $payment->id,
                'booking_id' => $booking->id,
                'amount' => $refundAmount,
                'reason' => $data['reason'],
                'status' => 'pending',
                'requested_by' => auth()->id(),
                'refund_method' => $data['refund_method'] ?? 'bank_transfer',
                'refund_reference' => $this->generateUniqueRefundReference(),
                'notes' => $data['notes'] ?? null,
            ]);

            // Update payment status
            $payment->update(['status' => 'refunded']);

            // Update booking status
            $booking->update(['payment_status' => 'refunded']);

            // Send notification to admin
            $this->sendRefundRequestNotification($refund);

            Log::info('Refund request created', [
                'refund_id' => $refund->id,
                'payment_id' => $payment->id,
                'booking_id' => $booking->id,
                'amount' => $refundAmount,
                'requested_by' => auth()->id(),
            ]);

            return $refund;
        });
    }

    public function approveRefund($refundId, $approvedBy = null, $adminNotes = null)
    {
        return DB::transaction(function () use ($refundId, $approvedBy, $adminNotes) {
            $refund = Refund::findOrFail($refundId);
            $approvedBy = $approvedBy ?? auth()->id();

            if (!$refund->can_be_approved) {
                throw new \Exception('Refund cannot be approved');
            }

            $refund->update([
                'status' => 'approved',
                'approved_by' => $approvedBy,
                'admin_notes' => $adminNotes,
            ]);

            // Send notification to user
            $this->sendRefundApprovalNotification($refund);

            Log::info('Refund approved', [
                'refund_id' => $refund->id,
                'approved_by' => $approvedBy,
            ]);

            return $refund;
        });
    }

    public function rejectRefund($refundId, $rejectedBy = null, $adminNotes = null)
    {
        return DB::transaction(function () use ($refundId, $rejectedBy, $adminNotes) {
            $refund = Refund::findOrFail($refundId);
            $rejectedBy = $rejectedBy ?? auth()->id();

            if (!$refund->can_be_rejected) {
                throw new \Exception('Refund cannot be rejected');
            }

            $refund->update([
                'status' => 'rejected',
                'approved_by' => $rejectedBy,
                'admin_notes' => $adminNotes,
            ]);

            // Revert payment and booking status
            $payment = $refund->payment;
            $booking = $refund->booking;

            $payment->update(['status' => 'verified']);
            $booking->update(['payment_status' => 'paid']);

            // Send notification to user
            $this->sendRefundRejectionNotification($refund);

            Log::info('Refund rejected', [
                'refund_id' => $refund->id,
                'rejected_by' => $rejectedBy,
            ]);

            return $refund;
        });
    }

    public function processRefund($refundId, $processedBy = null)
    {
        return DB::transaction(function () use ($refundId, $processedBy) {
            $refund = Refund::findOrFail($refundId);
            $processedBy = $processedBy ?? auth()->id();

            if (!$refund->can_be_processed) {
                throw new \Exception('Refund cannot be processed');
            }

            // Process refund based on method
            $this->processRefundByMethod($refund);

            $refund->update([
                'status' => 'processed',
                'processed_at' => now(),
            ]);

            // Send notification to user
            $this->sendRefundProcessedNotification($refund);

            Log::info('Refund processed', [
                'refund_id' => $refund->id,
                'processed_by' => $processedBy,
                'refund_method' => $refund->refund_method,
            ]);

            return $refund;
        });
    }

    public function getRefundHistory($userId, $filters = [])
    {
        $query = Refund::with(['payment', 'booking', 'approvedBy'])
            ->where('requested_by', $userId);

        // Apply filters
        if (isset($filters['status'])) {
            $query->where('status', $filters['status']);
        }

        if (isset($filters['refund_method'])) {
            $query->where('refund_method', $filters['refund_method']);
        }

        if (isset($filters['start_date']) && isset($filters['end_date'])) {
            $query->whereBetween('created_at', [$filters['start_date'], $filters['end_date']]);
        }

        if (isset($filters['min_amount']) && isset($filters['max_amount'])) {
            $query->whereBetween('amount', [$filters['min_amount'], $filters['max_amount']]);
        }

        return $query->orderBy('created_at', 'desc')->paginate($filters['per_page'] ?? 15);
    }

    public function getRefundStats($filters = [])
    {
        $query = Refund::query();

        // Apply filters
        if (isset($filters['start_date']) && isset($filters['end_date'])) {
            $query->whereBetween('created_at', [$filters['start_date'], $filters['end_date']]);
        }

        if (isset($filters['requested_by'])) {
            $query->where('requested_by', $filters['requested_by']);
        }

        $stats = [
            'total_refunds' => $query->count(),
            'pending_refunds' => $query->clone()->where('status', 'pending')->count(),
            'approved_refunds' => $query->clone()->where('status', 'approved')->count(),
            'rejected_refunds' => $query->clone()->where('status', 'rejected')->count(),
            'processed_refunds' => $query->clone()->where('status', 'processed')->count(),
            'total_refund_amount' => $query->clone()->sum('amount'),
            'average_refund_amount' => $query->clone()->avg('amount'),
            'refund_success_rate' => $this->calculateRefundSuccessRate($query->clone()),
            'average_processing_time' => $this->calculateAverageProcessingTime($query->clone()),
            'refund_methods' => $query->clone()->selectRaw('refund_method, COUNT(*) as count, SUM(amount) as total')
                ->groupBy('refund_method')
                ->get(),
        ];

        return $stats;
    }

    public function getRefundAnalytics($filters = [])
    {
        $query = Refund::query();

        // Apply filters
        if (isset($filters['start_date']) && isset($filters['end_date'])) {
            $query->whereBetween('created_at', [$filters['start_date'], $filters['end_date']]);
        }

        $analytics = [
            'refund_trends' => $this->getRefundTrends($query->clone()),
            'refund_reasons' => $this->getRefundReasons($query->clone()),
            'refund_by_status' => $this->getRefundByStatus($query->clone()),
            'refund_by_method' => $this->getRefundByMethod($query->clone()),
            'refund_by_user' => $this->getRefundByUser($query->clone()),
            'processing_time_analysis' => $this->getProcessingTimeAnalysis($query->clone()),
        ];

        return $analytics;
    }

    public function bulkProcessRefunds($refundIds, $processedBy = null)
    {
        $results = [];
        $processedBy = $processedBy ?? auth()->id();

        foreach ($refundIds as $refundId) {
            try {
                $refund = $this->processRefund($refundId, $processedBy);
                $results[] = [
                    'refund_id' => $refundId,
                    'success' => true,
                    'refund' => $refund,
                ];
            } catch (\Exception $e) {
                $results[] = [
                    'refund_id' => $refundId,
                    'success' => false,
                    'error' => $e->getMessage(),
                ];
            }
        }

        return $results;
    }

    protected function validateRefundEligibility($payment, $booking)
    {
        // Check if payment is verified
        if ($payment->status !== 'verified') {
            throw new \Exception('Only verified payments can be refunded');
        }

        // Check if booking is not completed
        if ($booking->status === 'completed') {
            throw new \Exception('Cannot refund completed bookings');
        }

        // Check if refund already exists
        $existingRefund = Refund::where('payment_id', $payment->id)
            ->whereIn('status', ['pending', 'approved'])
            ->first();

        if ($existingRefund) {
            throw new \Exception('Refund request already exists for this payment');
        }

        // Check refund time limit (e.g., within 24 hours of booking)
        $refundDeadline = $booking->created_at->addHours(24);
        if (now()->gt($refundDeadline)) {
            throw new \Exception('Refund request is past the deadline');
        }
    }

    protected function calculateRefundAmount($payment, $booking, $data)
    {
        $fullAmount = $payment->amount;
        $refundPercentage = $this->getRefundPercentage($booking, $data);

        return $fullAmount * ($refundPercentage / 100);
    }

    protected function getRefundPercentage($booking, $data)
    {
        // Calculate refund percentage based on cancellation time
        $bookingDate = Carbon::parse($booking->booking_date . ' ' . $booking->session->start_time);
        $hoursUntilBooking = now()->diffInHours($bookingDate, false);

        if ($hoursUntilBooking > 24) {
            return 100; // Full refund if more than 24 hours
        } elseif ($hoursUntilBooking > 12) {
            return 75; // 75% refund if 12-24 hours
        } elseif ($hoursUntilBooking > 6) {
            return 50; // 50% refund if 6-12 hours
        } else {
            return 0; // No refund if less than 6 hours
        }
    }

    protected function processRefundByMethod($refund)
    {
        switch ($refund->refund_method) {
            case 'bank_transfer':
                $this->processBankTransferRefund($refund);
                break;
            case 'cash':
                $this->processCashRefund($refund);
                break;
            case 'credit':
                $this->processCreditRefund($refund);
                break;
            default:
                throw new \Exception('Invalid refund method');
        }
    }

    protected function processBankTransferRefund($refund)
    {
        // Implementation for bank transfer refund
        // This would typically integrate with a payment gateway
        Log::info('Processing bank transfer refund', [
            'refund_id' => $refund->id,
            'amount' => $refund->amount,
        ]);
    }

    protected function processCashRefund($refund)
    {
        // Implementation for cash refund
        Log::info('Processing cash refund', [
            'refund_id' => $refund->id,
            'amount' => $refund->amount,
        ]);
    }

    protected function processCreditRefund($refund)
    {
        // Implementation for account credit refund
        Log::info('Processing credit refund', [
            'refund_id' => $refund->id,
            'amount' => $refund->amount,
        ]);
    }

    protected function generateUniqueRefundReference()
    {
        do {
            $reference = 'REF' . now()->format('Ymd') . str_pad(rand(1, 9999), 4, '0', STR_PAD_LEFT);
        } while (Refund::where('refund_reference', $reference)->exists());

        return $reference;
    }

    protected function calculateRefundSuccessRate($query)
    {
        $totalRefunds = $query->count();

        if ($totalRefunds === 0) {
            return 0;
        }

        $processedRefunds = $query->where('status', 'processed')->count();

        return round(($processedRefunds / $totalRefunds) * 100, 2);
    }

    protected function calculateAverageProcessingTime($query)
    {
        $processedRefunds = $query->where('status', 'processed')
            ->whereNotNull('processed_at')
            ->get();

        if ($processedRefunds->isEmpty()) {
            return 0;
        }

        $totalTime = $processedRefunds->sum(function ($refund) {
            return $refund->created_at->diffInHours($refund->processed_at);
        });

        return round($totalTime / $processedRefunds->count(), 2);
    }

    protected function getRefundTrends($query)
    {
        // Implementation for refund trends analysis
        return [];
    }

    protected function getRefundReasons($query)
    {
        return $query->selectRaw('reason, COUNT(*) as count')
            ->groupBy('reason')
            ->orderBy('count', 'desc')
            ->get();
    }

    protected function getRefundByStatus($query)
    {
        return $query->selectRaw('status, COUNT(*) as count, SUM(amount) as total')
            ->groupBy('status')
            ->get();
    }

    protected function getRefundByMethod($query)
    {
        return $query->selectRaw('refund_method, COUNT(*) as count, SUM(amount) as total')
            ->groupBy('refund_method')
            ->get();
    }

    protected function getRefundByUser($query)
    {
        return $query->selectRaw('requested_by, COUNT(*) as count, SUM(amount) as total')
            ->groupBy('requested_by')
            ->with('requestedBy')
            ->get();
    }

    protected function getProcessingTimeAnalysis($query)
    {
        // Implementation for processing time analysis
        return [];
    }

    protected function sendRefundRequestNotification($refund)
    {
        Log::info('Refund request notification sent', [
            'refund_id' => $refund->id,
            'amount' => $refund->amount,
        ]);
    }

    protected function sendRefundApprovalNotification($refund)
    {
        Log::info('Refund approval notification sent', [
            'refund_id' => $refund->id,
            'amount' => $refund->amount,
        ]);
    }

    protected function sendRefundRejectionNotification($refund)
    {
        Log::info('Refund rejection notification sent', [
            'refund_id' => $refund->id,
            'amount' => $refund->amount,
        ]);
    }

    protected function sendRefundProcessedNotification($refund)
    {
        Log::info('Refund processed notification sent', [
            'refund_id' => $refund->id,
            'amount' => $refund->amount,
        ]);
    }
}
```

### Step 3: Create Refund Controller

```php
<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Api\BaseController;
use App\Http\Requests\RefundRequest;
use App\Services\RefundService;
use App\Models\Refund;
use Illuminate\Http\Request;

class RefundController extends BaseController
{
    protected $refundService;

    public function __construct(RefundService $refundService)
    {
        $this->refundService = $refundService;
    }

    public function index(Request $request)
    {
        try {
            $filters = $request->only(['status', 'refund_method', 'start_date', 'end_date', 'min_amount', 'max_amount', 'per_page']);
            $refunds = $this->refundService->getRefundHistory(auth()->id(), $filters);

            return $this->successResponse($refunds, 'Refunds retrieved successfully');
        } catch (\Exception $e) {
            return $this->errorResponse($e->getMessage(), 400);
        }
    }

    public function store(RefundRequest $request)
    {
        try {
            $data = $request->validated();
            $refund = $this->refundService->createRefundRequest($data);

            return $this->successResponse($refund->load(['payment', 'booking']), 'Refund request created successfully', 201);
        } catch (\Exception $e) {
            return $this->errorResponse($e->getMessage(), 400);
        }
    }

    public function show($id)
    {
        try {
            $refund = Refund::with(['payment', 'booking', 'requestedBy', 'approvedBy'])
                ->where('requested_by', auth()->id())
                ->findOrFail($id);

            return $this->successResponse($refund, 'Refund retrieved successfully');
        } catch (\Exception $e) {
            return $this->errorResponse($e->getMessage(), 404);
        }
    }

    public function update(RefundRequest $request, $id)
    {
        try {
            $refund = Refund::where('requested_by', auth()->id())->findOrFail($id);

            if (!$refund->is_pending) {
                return $this->errorResponse('Refund cannot be updated', 400);
            }

            $data = $request->validated();
            $refund->update($data);

            return $this->successResponse($refund, 'Refund updated successfully');
        } catch (\Exception $e) {
            return $this->errorResponse($e->getMessage(), 400);
        }
    }

    public function destroy($id)
    {
        try {
            $refund = Refund::where('requested_by', auth()->id())->findOrFail($id);

            if (!$refund->is_pending) {
                return $this->errorResponse('Refund cannot be cancelled', 400);
            }

            $refund->delete();

            return $this->successResponse(null, 'Refund request cancelled successfully');
        } catch (\Exception $e) {
            return $this->errorResponse($e->getMessage(), 400);
        }
    }

    public function approve(Request $request, $id)
    {
        $request->validate([
            'admin_notes' => 'nullable|string|max:500',
        ]);

        try {
            $refund = $this->refundService->approveRefund($id, auth()->id(), $request->admin_notes);

            return $this->successResponse($refund, 'Refund approved successfully');
        } catch (\Exception $e) {
            return $this->errorResponse($e->getMessage(), 400);
        }
    }

    public function reject(Request $request, $id)
    {
        $request->validate([
            'admin_notes' => 'required|string|max:500',
        ]);

        try {
            $refund = $this->refundService->rejectRefund($id, auth()->id(), $request->admin_notes);

            return $this->successResponse($refund, 'Refund rejected successfully');
        } catch (\Exception $e) {
            return $this->errorResponse($e->getMessage(), 400);
        }
    }

    public function process($id)
    {
        try {
            $refund = $this->refundService->processRefund($id, auth()->id());

            return $this->successResponse($refund, 'Refund processed successfully');
        } catch (\Exception $e) {
            return $this->errorResponse($e->getMessage(), 400);
        }
    }

    public function getStats(Request $request)
    {
        try {
            $filters = $request->only(['start_date', 'end_date']);
            $stats = $this->refundService->getRefundStats($filters);

            return $this->successResponse($stats, 'Refund statistics retrieved successfully');
        } catch (\Exception $e) {
            return $this->errorResponse($e->getMessage(), 400);
        }
    }

    public function getAnalytics(Request $request)
    {
        try {
            $filters = $request->only(['start_date', 'end_date']);
            $analytics = $this->refundService->getRefundAnalytics($filters);

            return $this->successResponse($analytics, 'Refund analytics retrieved successfully');
        } catch (\Exception $e) {
            return $this->errorResponse($e->getMessage(), 400);
        }
    }

    public function bulkProcess(Request $request)
    {
        $request->validate([
            'refund_ids' => 'required|array|min:1',
            'refund_ids.*' => 'exists:refunds,id',
        ]);

        try {
            $results = $this->refundService->bulkProcessRefunds($request->refund_ids, auth()->id());

            return $this->successResponse($results, 'Bulk refund processing completed');
        } catch (\Exception $e) {
            return $this->errorResponse($e->getMessage(), 400);
        }
    }
}
```

### Step 4: Create Request Classes

#### RefundRequest

```php
<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class RefundRequest extends FormRequest
{
    public function authorize()
    {
        return true;
    }

    public function rules()
    {
        return [
            'payment_id' => ['required', 'exists:payments,id'],
            'reason' => ['required', 'string', 'max:500'],
            'refund_method' => ['nullable', 'in:bank_transfer,cash,credit'],
            'notes' => ['nullable', 'string', 'max:500'],
        ];
    }

    public function messages()
    {
        return [
            'payment_id.required' => 'Payment is required',
            'payment_id.exists' => 'Selected payment does not exist',
            'reason.required' => 'Refund reason is required',
            'reason.max' => 'Reason cannot exceed 500 characters',
            'refund_method.in' => 'Invalid refund method',
            'notes.max' => 'Notes cannot exceed 500 characters',
        ];
    }

    public function withValidator($validator)
    {
        $validator->after(function ($validator) {
            // Validate payment belongs to user
            if ($this->payment_id) {
                $payment = \App\Models\Payment::find($this->payment_id);
                if ($payment && $payment->user_id !== auth()->id()) {
                    $validator->errors()->add('payment_id', 'You can only request refunds for your own payments');
                }
            }
        });
    }
}
```

## 📚 API Endpoints

### Refund Management Endpoints

```
GET    /api/v1/refunds
POST   /api/v1/refunds
GET    /api/v1/refunds/{id}
PUT    /api/v1/refunds/{id}
DELETE /api/v1/refunds/{id}
POST   /api/v1/admin/refunds/{id}/approve
POST   /api/v1/admin/refunds/{id}/reject
POST   /api/v1/admin/refunds/{id}/process
GET    /api/v1/refunds/stats
GET    /api/v1/refunds/analytics
POST   /api/v1/admin/refunds/bulk-process
```

## 🧪 Testing

### RefundTest.php

```php
<?php

use App\Models\Refund;
use App\Models\Payment;
use App\Models\Booking;
use App\Services\RefundService;

describe('Refund Management', function () {

    beforeEach(function () {
        $this->refundService = app(RefundService::class);
    });

    it('can create refund request', function () {
        $user = User::factory()->create();
        $payment = Payment::factory()->create([
            'user_id' => $user->id,
            'status' => 'verified'
        ]);
        actingAsUser($user);

        $refundData = [
            'payment_id' => $payment->id,
            'reason' => 'Change of plans',
            'refund_method' => 'bank_transfer',
        ];

        $response = apiPost('/api/v1/refunds', $refundData);

        assertApiSuccess($response, 'Refund request created successfully');
        $this->assertDatabaseHas('refunds', [
            'payment_id' => $payment->id,
            'requested_by' => $user->id,
            'status' => 'pending',
        ]);
    });

    it('can approve refund', function () {
        $refund = Refund::factory()->create(['status' => 'pending']);
        actingAsAdmin();

        $response = apiPost("/api/v1/admin/refunds/{$refund->id}/approve", [
            'admin_notes' => 'Refund approved'
        ]);

        assertApiSuccess($response, 'Refund approved successfully');
        $this->assertDatabaseHas('refunds', [
            'id' => $refund->id,
            'status' => 'approved',
        ]);
    });

    it('can process refund', function () {
        $refund = Refund::factory()->create(['status' => 'approved']);
        actingAsAdmin();

        $response = apiPost("/api/v1/admin/refunds/{$refund->id}/process");

        assertApiSuccess($response, 'Refund processed successfully');
        $this->assertDatabaseHas('refunds', [
            'id' => $refund->id,
            'status' => 'processed',
        ]);
    });

    it('cannot create refund for unverified payment', function () {
        $user = User::factory()->create();
        $payment = Payment::factory()->create([
            'user_id' => $user->id,
            'status' => 'pending'
        ]);
        actingAsUser($user);

        $refundData = [
            'payment_id' => $payment->id,
            'reason' => 'Change of plans',
        ];

        $response = apiPost('/api/v1/refunds', $refundData);

        assertApiError($response, 'Only verified payments can be refunded');
    });

    it('can get refund statistics', function () {
        Refund::factory()->count(5)->create();
        actingAsAdmin();

        $response = apiGet('/api/v1/refunds/stats');

        assertApiSuccess($response, 'Refund statistics retrieved successfully');
        expect($response->json('data.total_refunds'))->toBe(5);
    });
});
```

## ✅ Success Criteria

- [ ] Refund request processing berfungsi
- [ ] Refund approval workflow berjalan
- [ ] Refund calculation berfungsi
- [ ] Refund notifications berjalan
- [ ] Refund history berfungsi
- [ ] Refund analytics berjalan
- [ ] Testing coverage > 90%

## 📚 Documentation

- [Laravel Database Transactions](https://laravel.com/docs/11.x/database#database-transactions)
- [Laravel Events](https://laravel.com/docs/11.x/events)
- [Laravel Validation](https://laravel.com/docs/11.x/validation)
