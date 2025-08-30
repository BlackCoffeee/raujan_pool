# Point 1: Manual Payment System

## 📋 Overview

Implementasi sistem pembayaran manual dengan payment record creation, payment proof upload, dan payment status management.

## 🎯 Objectives

- Payment record creation
- Payment proof upload
- Payment status management
- Payment validation
- Payment notifications
- Payment history

## 📁 Files Structure

```
phase-4/
├── 01-manual-payment-system.md
├── app/Http/Controllers/PaymentController.php
├── app/Models/Payment.php
├── app/Services/PaymentService.php
├── app/Jobs/ProcessPaymentJob.php
└── app/Http/Requests/PaymentRequest.php
```

## 🔧 Implementation Steps

### Step 1: Create Payment Model

```php
<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Carbon\Carbon;

class Payment extends Model
{
    use HasFactory;

    protected $fillable = [
        'booking_id',
        'user_id',
        'amount',
        'payment_method',
        'status',
        'payment_proof_path',
        'bank_account_id',
        'reference_number',
        'transfer_date',
        'verified_at',
        'verified_by',
        'verification_note',
        'expires_at',
        'notes',
    ];

    protected $casts = [
        'amount' => 'decimal:2',
        'transfer_date' => 'datetime',
        'verified_at' => 'datetime',
        'expires_at' => 'datetime',
    ];

    public function booking()
    {
        return $this->belongsTo(Booking::class);
    }

    public function user()
    {
        return $this->belongsTo(User::class);
    }

    public function bankAccount()
    {
        return $this->belongsTo(BankAccount::class);
    }

    public function verifiedBy()
    {
        return $this->belongsTo(User::class, 'verified_by');
    }

    public function paymentVerifications()
    {
        return $this->hasMany(PaymentVerification::class);
    }

    public function refunds()
    {
        return $this->hasMany(Refund::class);
    }

    public function getStatusDisplayAttribute()
    {
        return match($this->status) {
            'pending' => 'Pending Verification',
            'verified' => 'Verified',
            'rejected' => 'Rejected',
            'expired' => 'Expired',
            'refunded' => 'Refunded',
            default => 'Unknown'
        };
    }

    public function getPaymentMethodDisplayAttribute()
    {
        return match($this->payment_method) {
            'manual_transfer' => 'Manual Transfer',
            'cash' => 'Cash Payment',
            'refund' => 'Refund',
            default => 'Unknown'
        };
    }

    public function getIsPendingAttribute()
    {
        return $this->status === 'pending';
    }

    public function getIsVerifiedAttribute()
    {
        return $this->status === 'verified';
    }

    public function getIsRejectedAttribute()
    {
        return $this->status === 'rejected';
    }

    public function getIsExpiredAttribute()
    {
        return $this->status === 'expired';
    }

    public function getIsRefundedAttribute()
    {
        return $this->status === 'refunded';
    }

    public function getIsExpiredAttribute()
    {
        return $this->expires_at && $this->expires_at->isPast();
    }

    public function getCanBeUpdatedAttribute()
    {
        return $this->status === 'pending' && !$this->is_expired;
    }

    public function getCanBeCancelledAttribute()
    {
        return $this->status === 'pending' && !$this->is_expired;
    }

    public function getCanBeVerifiedAttribute()
    {
        return $this->status === 'pending' && !$this->is_expired;
    }

    public function getCanBeRejectedAttribute()
    {
        return $this->status === 'pending' && !$this->is_expired;
    }

    public function getTimeUntilExpiryAttribute()
    {
        if (!$this->expires_at) {
            return null;
        }

        return $this->expires_at->diffForHumans();
    }

    public function getVerificationTimeAttribute()
    {
        if (!$this->verified_at) {
            return null;
        }

        return $this->verified_at->diffForHumans($this->created_at);
    }

    public function generateReferenceNumber()
    {
        $prefix = 'PAY';
        $date = now()->format('Ymd');
        $random = str_pad(rand(1, 9999), 4, '0', STR_PAD_LEFT);

        return $prefix . $date . $random;
    }

    public function getPaymentProofUrl()
    {
        if (!$this->payment_proof_path) {
            return null;
        }

        return asset('storage/' . $this->payment_proof_path);
    }

    public function scopeByUser($query, $userId)
    {
        return $query->where('user_id', $userId);
    }

    public function scopeByStatus($query, $status)
    {
        return $query->where('status', $status);
    }

    public function scopeByPaymentMethod($query, $paymentMethod)
    {
        return $query->where('payment_method', $paymentMethod);
    }

    public function scopeByDateRange($query, $startDate, $endDate)
    {
        return $query->whereBetween('created_at', [$startDate, $endDate]);
    }

    public function scopePending($query)
    {
        return $query->where('status', 'pending');
    }

    public function scopeVerified($query)
    {
        return $query->where('status', 'verified');
    }

    public function scopeRejected($query)
    {
        return $query->where('status', 'rejected');
    }

    public function scopeExpired($query)
    {
        return $query->where('status', 'expired');
    }

    public function scopeExpiringSoon($query, $hours = 2)
    {
        return $query->where('status', 'pending')
            ->where('expires_at', '<=', now()->addHours($hours))
            ->where('expires_at', '>', now());
    }

    public function scopeByAmountRange($query, $minAmount, $maxAmount)
    {
        return $query->whereBetween('amount', [$minAmount, $maxAmount]);
    }

    public function scopeWithProof($query)
    {
        return $query->whereNotNull('payment_proof_path');
    }

    public function scopeWithoutProof($query)
    {
        return $query->whereNull('payment_proof_path');
    }
}
```

### Step 2: Create Payment Service

```php
<?php

namespace App\Services;

use App\Models\Payment;
use App\Models\Booking;
use App\Models\BankAccount;
use App\Jobs\ProcessPaymentJob;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Facades\Log;
use Carbon\Carbon;

class PaymentService
{
    public function createPayment($data)
    {
        return DB::transaction(function () use ($data) {
            // Validate booking
            $booking = Booking::findOrFail($data['booking_id']);

            if ($booking->user_id !== auth()->id()) {
                throw new \Exception('Unauthorized access to booking');
            }

            if ($booking->payment_status === 'paid') {
                throw new \Exception('Booking is already paid');
            }

            // Check if payment already exists
            $existingPayment = Payment::where('booking_id', $booking->id)
                ->where('status', 'pending')
                ->first();

            if ($existingPayment) {
                throw new \Exception('Payment already exists for this booking');
            }

            // Create payment
            $payment = Payment::create([
                'booking_id' => $booking->id,
                'user_id' => auth()->id(),
                'amount' => $data['amount'],
                'payment_method' => $data['payment_method'] ?? 'manual_transfer',
                'status' => 'pending',
                'bank_account_id' => $data['bank_account_id'] ?? $this->getDefaultBankAccount(),
                'reference_number' => $this->generateUniqueReferenceNumber(),
                'expires_at' => now()->addHours(24), // 24 hours expiry
                'notes' => $data['notes'] ?? null,
            ]);

            // Update booking payment status
            $booking->update(['payment_status' => 'pending']);

            // Dispatch job to process payment
            ProcessPaymentJob::dispatch($payment);

            // Log payment creation
            Log::info('Payment created', [
                'payment_id' => $payment->id,
                'booking_id' => $booking->id,
                'user_id' => auth()->id(),
                'amount' => $payment->amount,
                'reference_number' => $payment->reference_number,
            ]);

            return $payment;
        });
    }

    public function updatePayment($paymentId, $data)
    {
        return DB::transaction(function () use ($paymentId, $data) {
            $payment = Payment::findOrFail($paymentId);

            if (!$payment->can_be_updated) {
                throw new \Exception('Payment cannot be updated');
            }

            if ($payment->user_id !== auth()->id()) {
                throw new \Exception('Unauthorized access to payment');
            }

            $payment->update($data);

            Log::info('Payment updated', [
                'payment_id' => $payment->id,
                'updated_by' => auth()->id(),
            ]);

            return $payment;
        });
    }

    public function uploadPaymentProof($paymentId, $file)
    {
        return DB::transaction(function () use ($paymentId, $file) {
            $payment = Payment::findOrFail($paymentId);

            if (!$payment->can_be_updated) {
                throw new \Exception('Payment cannot be updated');
            }

            if ($payment->user_id !== auth()->id()) {
                throw new \Exception('Unauthorized access to payment');
            }

            // Validate file
            $this->validatePaymentProof($file);

            // Delete old proof if exists
            if ($payment->payment_proof_path) {
                Storage::disk('public')->delete($payment->payment_proof_path);
            }

            // Store new proof
            $path = $file->store('payment-proofs', 'public');

            $payment->update([
                'payment_proof_path' => $path,
            ]);

            Log::info('Payment proof uploaded', [
                'payment_id' => $payment->id,
                'proof_path' => $path,
                'uploaded_by' => auth()->id(),
            ]);

            return $payment;
        });
    }

    public function verifyPayment($paymentId, $status, $note = null, $verifiedBy = null)
    {
        return DB::transaction(function () use ($paymentId, $status, $note, $verifiedBy) {
            $payment = Payment::findOrFail($paymentId);

            if (!$payment->can_be_verified) {
                throw new \Exception('Payment cannot be verified');
            }

            $verifiedBy = $verifiedBy ?? auth()->id();

            // Update payment status
            $payment->update([
                'status' => $status,
                'verified_at' => now(),
                'verified_by' => $verifiedBy,
                'verification_note' => $note,
            ]);

            // Update booking payment status
            $booking = $payment->booking;
            $booking->update([
                'payment_status' => $status === 'verified' ? 'paid' : 'unpaid',
            ]);

            // Create verification record
            $payment->paymentVerifications()->create([
                'verified_by' => $verifiedBy,
                'status' => $status,
                'note' => $note,
            ]);

            // Send notifications
            $this->sendVerificationNotification($payment, $status);

            Log::info('Payment verified', [
                'payment_id' => $payment->id,
                'status' => $status,
                'verified_by' => $verifiedBy,
            ]);

            return $payment;
        });
    }

    public function rejectPayment($paymentId, $reason, $rejectedBy = null)
    {
        return $this->verifyPayment($paymentId, 'rejected', $reason, $rejectedBy);
    }

    public function cancelPayment($paymentId)
    {
        return DB::transaction(function () use ($paymentId) {
            $payment = Payment::findOrFail($paymentId);

            if (!$payment->can_be_cancelled) {
                throw new \Exception('Payment cannot be cancelled');
            }

            if ($payment->user_id !== auth()->id()) {
                throw new \Exception('Unauthorized access to payment');
            }

            // Delete payment proof if exists
            if ($payment->payment_proof_path) {
                Storage::disk('public')->delete($payment->payment_proof_path);
            }

            // Update booking payment status
            $booking = $payment->booking;
            $booking->update(['payment_status' => 'unpaid']);

            // Delete payment
            $payment->delete();

            Log::info('Payment cancelled', [
                'payment_id' => $paymentId,
                'cancelled_by' => auth()->id(),
            ]);

            return true;
        });
    }

    public function expirePayment($paymentId)
    {
        return DB::transaction(function () use ($paymentId) {
            $payment = Payment::findOrFail($paymentId);

            if ($payment->status !== 'pending') {
                throw new \Exception('Only pending payments can be expired');
            }

            $payment->update([
                'status' => 'expired',
            ]);

            // Update booking payment status
            $booking = $payment->booking;
            $booking->update(['payment_status' => 'unpaid']);

            // Send expiry notification
            $this->sendExpiryNotification($payment);

            Log::info('Payment expired', [
                'payment_id' => $payment->id,
            ]);

            return $payment;
        });
    }

    public function getPaymentHistory($userId, $filters = [])
    {
        $query = Payment::with(['booking', 'bankAccount', 'verifiedBy'])
            ->where('user_id', $userId);

        // Apply filters
        if (isset($filters['status'])) {
            $query->where('status', $filters['status']);
        }

        if (isset($filters['payment_method'])) {
            $query->where('payment_method', $filters['payment_method']);
        }

        if (isset($filters['start_date']) && isset($filters['end_date'])) {
            $query->whereBetween('created_at', [$filters['start_date'], $filters['end_date']]);
        }

        if (isset($filters['min_amount']) && isset($filters['max_amount'])) {
            $query->whereBetween('amount', [$filters['min_amount'], $filters['max_amount']]);
        }

        return $query->orderBy('created_at', 'desc')->paginate($filters['per_page'] ?? 15);
    }

    public function getPaymentStats($filters = [])
    {
        $query = Payment::query();

        // Apply filters
        if (isset($filters['start_date']) && isset($filters['end_date'])) {
            $query->whereBetween('created_at', [$filters['start_date'], $filters['end_date']]);
        }

        if (isset($filters['user_id'])) {
            $query->where('user_id', $filters['user_id']);
        }

        $stats = [
            'total_payments' => $query->count(),
            'total_amount' => $query->sum('amount'),
            'pending_payments' => $query->clone()->where('status', 'pending')->count(),
            'verified_payments' => $query->clone()->where('status', 'verified')->count(),
            'rejected_payments' => $query->clone()->where('status', 'rejected')->count(),
            'expired_payments' => $query->clone()->where('status', 'expired')->count(),
            'average_payment_amount' => $query->clone()->avg('amount'),
            'payment_methods' => $query->clone()->selectRaw('payment_method, COUNT(*) as count, SUM(amount) as total')
                ->groupBy('payment_method')
                ->get(),
        ];

        return $stats;
    }

    public function getExpiringPayments($hours = 2)
    {
        return Payment::with(['user', 'booking'])
            ->expiringSoon($hours)
            ->get();
    }

    public function processExpiredPayments()
    {
        $expiredPayments = Payment::where('status', 'pending')
            ->where('expires_at', '<', now())
            ->get();

        foreach ($expiredPayments as $payment) {
            $this->expirePayment($payment->id);
        }

        return $expiredPayments->count();
    }

    protected function generateUniqueReferenceNumber()
    {
        do {
            $reference = 'PAY' . now()->format('Ymd') . str_pad(rand(1, 9999), 4, '0', STR_PAD_LEFT);
        } while (Payment::where('reference_number', $reference)->exists());

        return $reference;
    }

    protected function getDefaultBankAccount()
    {
        $defaultAccount = BankAccount::where('is_active', true)->first();
        return $defaultAccount ? $defaultAccount->id : null;
    }

    protected function validatePaymentProof($file)
    {
        // Validate file type
        $allowedTypes = ['image/jpeg', 'image/png', 'image/gif', 'application/pdf'];
        if (!in_array($file->getMimeType(), $allowedTypes)) {
            throw new \Exception('Invalid file type. Only JPEG, PNG, GIF, and PDF files are allowed.');
        }

        // Validate file size (max 5MB)
        if ($file->getSize() > 5 * 1024 * 1024) {
            throw new \Exception('File size too large. Maximum size is 5MB.');
        }
    }

    protected function sendVerificationNotification($payment, $status)
    {
        // Send notification to user
        $user = $payment->user;
        $message = $status === 'verified'
            ? "Your payment of Rp " . number_format($payment->amount) . " has been verified."
            : "Your payment of Rp " . number_format($payment->amount) . " has been rejected.";

        // Implementation would depend on notification system
        // For now, we'll just log it
        Log::info('Payment verification notification', [
            'user_id' => $user->id,
            'payment_id' => $payment->id,
            'status' => $status,
            'message' => $message,
        ]);
    }

    protected function sendExpiryNotification($payment)
    {
        $user = $payment->user;
        $message = "Your payment of Rp " . number_format($payment->amount) . " has expired. Please make a new payment.";

        Log::info('Payment expiry notification', [
            'user_id' => $user->id,
            'payment_id' => $payment->id,
            'message' => $message,
        ]);
    }
}
```

### Step 3: Create Payment Controller

```php
<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Api\BaseController;
use App\Http\Requests\PaymentRequest;
use App\Services\PaymentService;
use App\Models\Payment;
use Illuminate\Http\Request;

class PaymentController extends BaseController
{
    protected $paymentService;

    public function __construct(PaymentService $paymentService)
    {
        $this->paymentService = $paymentService;
    }

    public function index(Request $request)
    {
        try {
            $filters = $request->only(['status', 'payment_method', 'start_date', 'end_date', 'min_amount', 'max_amount', 'per_page']);
            $payments = $this->paymentService->getPaymentHistory(auth()->id(), $filters);

            return $this->successResponse($payments, 'Payments retrieved successfully');
        } catch (\Exception $e) {
            return $this->errorResponse($e->getMessage(), 400);
        }
    }

    public function store(PaymentRequest $request)
    {
        try {
            $data = $request->validated();
            $payment = $this->paymentService->createPayment($data);

            return $this->successResponse($payment->load(['booking', 'bankAccount']), 'Payment created successfully', 201);
        } catch (\Exception $e) {
            return $this->errorResponse($e->getMessage(), 400);
        }
    }

    public function show($id)
    {
        try {
            $payment = Payment::with(['booking', 'bankAccount', 'verifiedBy', 'paymentVerifications'])
                ->where('user_id', auth()->id())
                ->findOrFail($id);

            return $this->successResponse($payment, 'Payment retrieved successfully');
        } catch (\Exception $e) {
            return $this->errorResponse($e->getMessage(), 404);
        }
    }

    public function update(PaymentRequest $request, $id)
    {
        try {
            $data = $request->validated();
            $payment = $this->paymentService->updatePayment($id, $data);

            return $this->successResponse($payment->load(['booking', 'bankAccount']), 'Payment updated successfully');
        } catch (\Exception $e) {
            return $this->errorResponse($e->getMessage(), 400);
        }
    }

    public function destroy($id)
    {
        try {
            $this->paymentService->cancelPayment($id);

            return $this->successResponse(null, 'Payment cancelled successfully');
        } catch (\Exception $e) {
            return $this->errorResponse($e->getMessage(), 400);
        }
    }

    public function uploadProof(Request $request, $id)
    {
        $request->validate([
            'payment_proof' => 'required|file|mimes:jpeg,png,gif,pdf|max:5120', // 5MB max
        ]);

        try {
            $payment = $this->paymentService->uploadPaymentProof($id, $request->file('payment_proof'));

            return $this->successResponse($payment, 'Payment proof uploaded successfully');
        } catch (\Exception $e) {
            return $this->errorResponse($e->getMessage(), 400);
        }
    }

    public function getStatus($id)
    {
        try {
            $payment = Payment::where('user_id', auth()->id())->findOrFail($id);

            return $this->successResponse([
                'status' => $payment->status,
                'status_display' => $payment->status_display,
                'can_be_updated' => $payment->can_be_updated,
                'can_be_cancelled' => $payment->can_be_cancelled,
                'time_until_expiry' => $payment->time_until_expiry,
                'verification_time' => $payment->verification_time,
            ], 'Payment status retrieved successfully');
        } catch (\Exception $e) {
            return $this->errorResponse($e->getMessage(), 404);
        }
    }

    public function getTimeline($id)
    {
        try {
            $payment = Payment::with(['paymentVerifications.verifiedBy'])
                ->where('user_id', auth()->id())
                ->findOrFail($id);

            $timeline = [
                [
                    'event' => 'Payment Created',
                    'timestamp' => $payment->created_at,
                    'description' => 'Payment request created',
                ],
            ];

            if ($payment->payment_proof_path) {
                $timeline[] = [
                    'event' => 'Proof Uploaded',
                    'timestamp' => $payment->updated_at,
                    'description' => 'Payment proof uploaded',
                ];
            }

            if ($payment->verified_at) {
                $timeline[] = [
                    'event' => 'Payment Verified',
                    'timestamp' => $payment->verified_at,
                    'description' => $payment->status === 'verified' ? 'Payment approved' : 'Payment rejected',
                    'verified_by' => $payment->verifiedBy->name ?? 'Admin',
                    'note' => $payment->verification_note,
                ];
            }

            return $this->successResponse($timeline, 'Payment timeline retrieved successfully');
        } catch (\Exception $e) {
            return $this->errorResponse($e->getMessage(), 404);
        }
    }

    public function generateReceipt($id)
    {
        try {
            $payment = Payment::with(['booking', 'user', 'bankAccount'])
                ->where('user_id', auth()->id())
                ->findOrFail($id);

            if ($payment->status !== 'verified') {
                return $this->errorResponse('Receipt can only be generated for verified payments', 400);
            }

            $receipt = [
                'receipt_number' => $payment->reference_number,
                'payment_date' => $payment->verified_at->format('Y-m-d H:i:s'),
                'amount' => $payment->amount,
                'payment_method' => $payment->payment_method_display,
                'booking_reference' => $payment->booking->booking_reference,
                'user_name' => $payment->user->name,
                'bank_account' => $payment->bankAccount ? $payment->bankAccount->bank_name : 'N/A',
            ];

            return $this->successResponse($receipt, 'Receipt generated successfully');
        } catch (\Exception $e) {
            return $this->errorResponse($e->getMessage(), 404);
        }
    }

    public function getStats(Request $request)
    {
        try {
            $filters = $request->only(['start_date', 'end_date']);
            $stats = $this->paymentService->getPaymentStats($filters);

            return $this->successResponse($stats, 'Payment statistics retrieved successfully');
        } catch (\Exception $e) {
            return $this->errorResponse($e->getMessage(), 400);
        }
    }
}
```

### Step 4: Create Request Classes

#### PaymentRequest

```php
<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class PaymentRequest extends FormRequest
{
    public function authorize()
    {
        return true;
    }

    public function rules()
    {
        return [
            'booking_id' => ['required', 'exists:bookings,id'],
            'amount' => ['required', 'numeric', 'min:0'],
            'payment_method' => ['nullable', 'in:manual_transfer,cash'],
            'bank_account_id' => ['nullable', 'exists:bank_accounts,id'],
            'notes' => ['nullable', 'string', 'max:500'],
        ];
    }

    public function messages()
    {
        return [
            'booking_id.required' => 'Booking is required',
            'booking_id.exists' => 'Selected booking does not exist',
            'amount.required' => 'Amount is required',
            'amount.numeric' => 'Amount must be a number',
            'amount.min' => 'Amount must be at least 0',
            'payment_method.in' => 'Invalid payment method',
            'bank_account_id.exists' => 'Selected bank account does not exist',
        ];
    }

    public function withValidator($validator)
    {
        $validator->after(function ($validator) {
            // Validate booking belongs to user
            if ($this->booking_id) {
                $booking = \App\Models\Booking::find($this->booking_id);
                if ($booking && $booking->user_id !== auth()->id()) {
                    $validator->errors()->add('booking_id', 'You can only create payments for your own bookings');
                }
            }

            // Validate amount matches booking total
            if ($this->booking_id && $this->amount) {
                $booking = \App\Models\Booking::find($this->booking_id);
                if ($booking && $booking->total_amount != $this->amount) {
                    $validator->errors()->add('amount', 'Amount must match booking total');
                }
            }
        });
    }
}
```

### Step 5: Create Payment Processing Job

```php
<?php

namespace App\Jobs;

use App\Models\Payment;
use App\Services\PaymentService;
use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Bus\Dispatchable;
use Illuminate\Queue\InteractsWithQueue;
use Illuminate\Queue\SerializesModels;
use Illuminate\Support\Facades\Log;

class ProcessPaymentJob implements ShouldQueue
{
    use Dispatchable, InteractsWithQueue, Queueable, SerializesModels;

    protected $payment;

    public function __construct(Payment $payment)
    {
        $this->payment = $payment;
    }

    public function handle(PaymentService $paymentService)
    {
        try {
            // Check if payment is still pending
            $this->payment->refresh();

            if ($this->payment->status !== 'pending') {
                Log::info('Payment no longer pending, skipping processing', [
                    'payment_id' => $this->payment->id,
                    'status' => $this->payment->status,
                ]);
                return;
            }

            // Send payment instructions to user
            $this->sendPaymentInstructions($this->payment);

            // Schedule expiry check
            $this->scheduleExpiryCheck($this->payment);

            Log::info('Payment processing completed', [
                'payment_id' => $this->payment->id,
                'reference_number' => $this->payment->reference_number,
            ]);

        } catch (\Exception $e) {
            Log::error('Payment processing failed', [
                'payment_id' => $this->payment->id,
                'error' => $e->getMessage(),
            ]);

            throw $e;
        }
    }

    protected function sendPaymentInstructions($payment)
    {
        // Send payment instructions to user
        $user = $payment->user;
        $bankAccount = $payment->bankAccount;

        $message = "Payment Instructions:\n";
        $message .= "Reference: {$payment->reference_number}\n";
        $message .= "Amount: Rp " . number_format($payment->amount) . "\n";
        $message .= "Bank: {$bankAccount->bank_name}\n";
        $message .= "Account: {$bankAccount->account_number}\n";
        $message .= "Expires: {$payment->expires_at->format('Y-m-d H:i:s')}";

        Log::info('Payment instructions sent', [
            'payment_id' => $payment->id,
            'user_id' => $user->id,
            'message' => $message,
        ]);
    }

    protected function scheduleExpiryCheck($payment)
    {
        // Schedule a job to check for expiry
        CheckPaymentExpiryJob::dispatch($payment->id)
            ->delay($payment->expires_at);
    }
}
```

## 📚 API Endpoints

### Manual Payment System Endpoints

```
GET    /api/v1/payments
POST   /api/v1/payments
GET    /api/v1/payments/{id}
PUT    /api/v1/payments/{id}
DELETE /api/v1/payments/{id}
POST   /api/v1/payments/{id}/upload-proof
GET    /api/v1/payments/{id}/status
GET    /api/v1/payments/{id}/timeline
GET    /api/v1/payments/{id}/receipt
GET    /api/v1/payments/stats
```

## 🧪 Testing

### PaymentTest.php

```php
<?php

use App\Models\Payment;
use App\Models\Booking;
use App\Models\User;
use App\Services\PaymentService;

describe('Manual Payment System', function () {

    beforeEach(function () {
        $this->paymentService = app(PaymentService::class);
    });

    it('can create payment', function () {
        $user = User::factory()->create();
        $booking = Booking::factory()->create(['user_id' => $user->id]);
        actingAsUser($user);

        $paymentData = [
            'booking_id' => $booking->id,
            'amount' => $booking->total_amount,
            'payment_method' => 'manual_transfer',
        ];

        $response = apiPost('/api/v1/payments', $paymentData);

        assertApiSuccess($response, 'Payment created successfully');
        $this->assertDatabaseHas('payments', [
            'booking_id' => $booking->id,
            'user_id' => $user->id,
            'amount' => $booking->total_amount,
        ]);
    });

    it('can upload payment proof', function () {
        $user = User::factory()->create();
        $payment = Payment::factory()->create(['user_id' => $user->id]);
        actingAsUser($user);

        $file = UploadedFile::fake()->image('payment-proof.jpg');

        $response = apiPost("/api/v1/payments/{$payment->id}/upload-proof", [
            'payment_proof' => $file
        ]);

        assertApiSuccess($response, 'Payment proof uploaded successfully');
        $this->assertDatabaseHas('payments', [
            'id' => $payment->id,
            'payment_proof_path' => 'payment-proofs/' . $file->hashName(),
        ]);
    });

    it('can verify payment', function () {
        $payment = Payment::factory()->create(['status' => 'pending']);
        actingAsAdmin();

        $response = apiPut("/api/v1/admin/payments/{$payment->id}/verify", [
            'status' => 'verified',
            'note' => 'Payment verified'
        ]);

        assertApiSuccess($response, 'Payment verified successfully');
        $this->assertDatabaseHas('payments', [
            'id' => $payment->id,
            'status' => 'verified',
        ]);
    });

    it('cannot create payment for other user booking', function () {
        $user = User::factory()->create();
        $otherUser = User::factory()->create();
        $booking = Booking::factory()->create(['user_id' => $otherUser->id]);
        actingAsUser($user);

        $paymentData = [
            'booking_id' => $booking->id,
            'amount' => $booking->total_amount,
        ];

        $response = apiPost('/api/v1/payments', $paymentData);

        assertApiValidationError($response, 'booking_id');
    });
});
```

## ✅ Success Criteria

- [ ] Payment record creation berfungsi
- [ ] Payment proof upload berjalan
- [ ] Payment status management berfungsi
- [ ] Payment validation berjalan
- [ ] Payment notifications berfungsi
- [ ] Payment history berjalan
- [ ] Testing coverage > 90%

## 📚 Documentation

- [Laravel File Storage](https://laravel.com/docs/11.x/filesystem)
- [Laravel Jobs](https://laravel.com/docs/11.x/queues)
- [Laravel Validation](https://laravel.com/docs/11.x/validation)
