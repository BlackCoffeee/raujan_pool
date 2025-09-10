# Point 2: Payment Verification

## 📋 Overview

Implementasi sistem verifikasi pembayaran dengan admin verification interface, payment proof validation, dan verification workflow.

## 🎯 Objectives

-   Admin verification interface
-   Payment proof validation
-   Verification workflow
-   Rejection handling
-   Verification notifications
-   Verification history

## 📁 Files Structure

```
phase-4/
├── 02-payment-verification.md
├── app/Http/Controllers/PaymentVerificationController.php
├── app/Models/PaymentVerification.php
├── app/Services/VerificationService.php
└── app/Http/Requests/VerificationRequest.php
```

## 🔧 Implementation Steps

### Step 1: Create Payment Verification Model

```php
<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class PaymentVerification extends Model
{
    use HasFactory;

    protected $fillable = [
        'payment_id',
        'verified_by',
        'status',
        'note',
        'verification_data',
        'proof_validation_score',
        'auto_verified',
        'verification_duration',
    ];

    protected $casts = [
        'verification_data' => 'array',
        'proof_validation_score' => 'decimal:2',
        'auto_verified' => 'boolean',
        'verification_duration' => 'integer',
    ];

    public function payment()
    {
        return $this->belongsTo(Payment::class);
    }

    public function verifiedBy()
    {
        return $this->belongsTo(User::class, 'verified_by');
    }

    public function getStatusDisplayAttribute()
    {
        return match($this->status) {
            'approved' => 'Approved',
            'rejected' => 'Rejected',
            'pending' => 'Pending Review',
            default => 'Unknown'
        };
    }

    public function getIsApprovedAttribute()
    {
        return $this->status === 'approved';
    }

    public function getIsRejectedAttribute()
    {
        return $this->status === 'rejected';
    }

    public function getIsPendingAttribute()
    {
        return $this->status === 'pending';
    }

    public function getVerificationDurationDisplayAttribute()
    {
        if (!$this->verification_duration) {
            return null;
        }

        $minutes = floor($this->verification_duration / 60);
        $seconds = $this->verification_duration % 60;

        return "{$minutes}m {$seconds}s";
    }

    public function scopeApproved($query)
    {
        return $query->where('status', 'approved');
    }

    public function scopeRejected($query)
    {
        return $query->where('status', 'rejected');
    }

    public function scopePending($query)
    {
        return $query->where('status', 'pending');
    }

    public function scopeByVerifier($query, $verifierId)
    {
        return $query->where('verified_by', $verifierId);
    }

    public function scopeAutoVerified($query)
    {
        return $query->where('auto_verified', true);
    }

    public function scopeManualVerified($query)
    {
        return $query->where('auto_verified', false);
    }

    public function scopeByDateRange($query, $startDate, $endDate)
    {
        return $query->whereBetween('created_at', [$startDate, $endDate]);
    }
}
```

### Step 2: Create Verification Service

```php
<?php

namespace App\Services;

use App\Models\Payment;
use App\Models\PaymentVerification;
use App\Models\User;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;
use Carbon\Carbon;

class VerificationService
{
    public function createVerification($paymentId, $status, $note = null, $verifiedBy = null)
    {
        return DB::transaction(function () use ($paymentId, $status, $note, $verifiedBy) {
            $payment = Payment::findOrFail($paymentId);
            $verifiedBy = $verifiedBy ?? auth()->id();

            // Validate payment can be verified
            if (!$payment->can_be_verified) {
                throw new \Exception('Payment cannot be verified');
            }

            // Start timing verification
            $startTime = now();

            // Create verification record
            $verification = PaymentVerification::create([
                'payment_id' => $payment->id,
                'verified_by' => $verifiedBy,
                'status' => $status,
                'note' => $note,
                'verification_data' => $this->collectVerificationData($payment),
                'proof_validation_score' => $this->calculateProofValidationScore($payment),
                'auto_verified' => false,
                'verification_duration' => 0, // Will be updated at the end
            ]);

            // Update payment status
            $payment->update([
                'status' => $status === 'approved' ? 'verified' : 'rejected',
                'verified_at' => now(),
                'verified_by' => $verifiedBy,
                'verification_note' => $note,
            ]);

            // Update booking payment status
            $booking = $payment->booking;
            $booking->update([
                'payment_status' => $status === 'approved' ? 'paid' : 'unpaid',
            ]);

            // Calculate verification duration
            $verificationDuration = now()->diffInSeconds($startTime);
            $verification->update(['verification_duration' => $verificationDuration]);

            // Send notifications
            $this->sendVerificationNotifications($payment, $verification);

            // Log verification
            Log::info('Payment verification completed', [
                'payment_id' => $payment->id,
                'verification_id' => $verification->id,
                'status' => $status,
                'verified_by' => $verifiedBy,
                'duration' => $verificationDuration,
            ]);

            return $verification;
        });
    }

    public function autoVerifyPayment($paymentId)
    {
        return DB::transaction(function () use ($paymentId) {
            $payment = Payment::findOrFail($paymentId);

            if (!$payment->can_be_verified) {
                throw new \Exception('Payment cannot be auto-verified');
            }

            // Check if payment meets auto-verification criteria
            $autoVerificationResult = $this->checkAutoVerificationCriteria($payment);

            if (!$autoVerificationResult['can_auto_verify']) {
                throw new \Exception('Payment does not meet auto-verification criteria');
            }

            $startTime = now();

            // Create auto-verification record
            $verification = PaymentVerification::create([
                'payment_id' => $payment->id,
                'verified_by' => null, // System verification
                'status' => 'approved',
                'note' => 'Auto-verified by system',
                'verification_data' => $autoVerificationResult['data'],
                'proof_validation_score' => $autoVerificationResult['score'],
                'auto_verified' => true,
                'verification_duration' => 0,
            ]);

            // Update payment status
            $payment->update([
                'status' => 'verified',
                'verified_at' => now(),
                'verified_by' => null,
                'verification_note' => 'Auto-verified by system',
            ]);

            // Update booking payment status
            $booking = $payment->booking;
            $booking->update([
                'payment_status' => 'paid',
            ]);

            // Calculate verification duration
            $verificationDuration = now()->diffInSeconds($startTime);
            $verification->update(['verification_duration' => $verificationDuration]);

            // Send notifications
            $this->sendAutoVerificationNotifications($payment, $verification);

            Log::info('Payment auto-verified', [
                'payment_id' => $payment->id,
                'verification_id' => $verification->id,
                'score' => $autoVerificationResult['score'],
                'duration' => $verificationDuration,
            ]);

            return $verification;
        });
    }

    public function getPendingVerifications($filters = [])
    {
        $query = Payment::with(['user', 'booking', 'bankAccount'])
            ->where('status', 'pending')
            ->whereNotNull('payment_proof_path');

        // Apply filters
        if (isset($filters['min_amount'])) {
            $query->where('amount', '>=', $filters['min_amount']);
        }

        if (isset($filters['max_amount'])) {
            $query->where('amount', '<=', $filters['max_amount']);
        }

        if (isset($filters['payment_method'])) {
            $query->where('payment_method', $filters['payment_method']);
        }

        if (isset($filters['bank_account_id'])) {
            $query->where('bank_account_id', $filters['bank_account_id']);
        }

        if (isset($filters['created_after'])) {
            $query->where('created_at', '>=', $filters['created_after']);
        }

        return $query->orderBy('created_at', 'asc')->paginate($filters['per_page'] ?? 20);
    }

    public function getVerificationStats($filters = [])
    {
        $query = PaymentVerification::query();

        // Apply filters
        if (isset($filters['start_date']) && isset($filters['end_date'])) {
            $query->whereBetween('created_at', [$filters['start_date'], $filters['end_date']]);
        }

        if (isset($filters['verified_by'])) {
            $query->where('verified_by', $filters['verified_by']);
        }

        $stats = [
            'total_verifications' => $query->count(),
            'approved_verifications' => $query->clone()->approved()->count(),
            'rejected_verifications' => $query->clone()->rejected()->count(),
            'auto_verifications' => $query->clone()->autoVerified()->count(),
            'manual_verifications' => $query->clone()->manualVerified()->count(),
            'average_verification_time' => $query->clone()->avg('verification_duration'),
            'average_proof_score' => $query->clone()->avg('proof_validation_score'),
            'verification_by_verifier' => $query->clone()
                ->selectRaw('verified_by, COUNT(*) as count, AVG(verification_duration) as avg_duration')
                ->groupBy('verified_by')
                ->with('verifiedBy')
                ->get(),
        ];

        return $stats;
    }

    public function getVerificationHistory($paymentId)
    {
        return PaymentVerification::with(['verifiedBy'])
            ->where('payment_id', $paymentId)
            ->orderBy('created_at', 'desc')
            ->get();
    }

    public function bulkVerifyPayments($paymentIds, $status, $note = null, $verifiedBy = null)
    {
        $results = [];
        $verifiedBy = $verifiedBy ?? auth()->id();

        foreach ($paymentIds as $paymentId) {
            try {
                $verification = $this->createVerification($paymentId, $status, $note, $verifiedBy);
                $results[] = [
                    'payment_id' => $paymentId,
                    'success' => true,
                    'verification_id' => $verification->id,
                ];
            } catch (\Exception $e) {
                $results[] = [
                    'payment_id' => $paymentId,
                    'success' => false,
                    'error' => $e->getMessage(),
                ];
            }
        }

        return $results;
    }

    public function getVerificationQueue($verifierId = null)
    {
        $query = Payment::with(['user', 'booking', 'bankAccount'])
            ->where('status', 'pending')
            ->whereNotNull('payment_proof_path')
            ->orderBy('created_at', 'asc');

        // If verifier is specified, prioritize their queue
        if ($verifierId) {
            $query->where(function ($q) use ($verifierId) {
                $q->whereNull('assigned_to')
                  ->orWhere('assigned_to', $verifierId);
            });
        }

        return $query->limit(50)->get();
    }

    public function assignVerification($paymentId, $verifierId)
    {
        $payment = Payment::findOrFail($paymentId);

        if ($payment->status !== 'pending') {
            throw new \Exception('Only pending payments can be assigned');
        }

        $payment->update(['assigned_to' => $verifierId]);

        Log::info('Payment verification assigned', [
            'payment_id' => $paymentId,
            'assigned_to' => $verifierId,
            'assigned_by' => auth()->id(),
        ]);

        return $payment;
    }

    public function unassignVerification($paymentId)
    {
        $payment = Payment::findOrFail($paymentId);
        $payment->update(['assigned_to' => null]);

        Log::info('Payment verification unassigned', [
            'payment_id' => $paymentId,
            'unassigned_by' => auth()->id(),
        ]);

        return $payment;
    }

    protected function collectVerificationData($payment)
    {
        return [
            'payment_amount' => $payment->amount,
            'booking_amount' => $payment->booking->total_amount,
            'amount_match' => $payment->amount === $payment->booking->total_amount,
            'has_proof' => !empty($payment->payment_proof_path),
            'proof_type' => $this->getProofType($payment->payment_proof_path),
            'bank_account' => $payment->bankAccount ? $payment->bankAccount->bank_name : null,
            'payment_method' => $payment->payment_method,
            'created_at' => $payment->created_at,
            'expires_at' => $payment->expires_at,
        ];
    }

    protected function calculateProofValidationScore($payment)
    {
        $score = 0;

        // Check if proof exists
        if ($payment->payment_proof_path) {
            $score += 30;
        }

        // Check amount match
        if ($payment->amount === $payment->booking->total_amount) {
            $score += 25;
        }

        // Check bank account match
        if ($payment->bankAccount) {
            $score += 20;
        }

        // Check payment method
        if ($payment->payment_method === 'manual_transfer') {
            $score += 15;
        }

        // Check if payment is not expired
        if (!$payment->is_expired) {
            $score += 10;
        }

        return $score;
    }

    protected function checkAutoVerificationCriteria($payment)
    {
        $score = $this->calculateProofValidationScore($payment);
        $canAutoVerify = $score >= 80; // Auto-verify if score is 80 or higher

        return [
            'can_auto_verify' => $canAutoVerify,
            'score' => $score,
            'data' => $this->collectVerificationData($payment),
            'criteria_met' => [
                'has_proof' => !empty($payment->payment_proof_path),
                'amount_match' => $payment->amount === $payment->booking->total_amount,
                'valid_bank_account' => $payment->bankAccount !== null,
                'not_expired' => !$payment->is_expired,
            ],
        ];
    }

    protected function sendVerificationNotifications($payment, $verification)
    {
        $user = $payment->user;
        $status = $verification->status;

        $message = $status === 'approved'
            ? "Your payment of Rp " . number_format($payment->amount) . " has been verified and approved."
            : "Your payment of Rp " . number_format($payment->amount) . " has been rejected. Please check the verification note.";

        Log::info('Verification notification sent', [
            'user_id' => $user->id,
            'payment_id' => $payment->id,
            'status' => $status,
            'message' => $message,
        ]);
    }

    protected function sendAutoVerificationNotifications($payment, $verification)
    {
        $user = $payment->user;
        $message = "Your payment of Rp " . number_format($payment->amount) . " has been automatically verified and approved.";

        Log::info('Auto-verification notification sent', [
            'user_id' => $user->id,
            'payment_id' => $payment->id,
            'score' => $verification->proof_validation_score,
            'message' => $message,
        ]);
    }

    protected function getProofType($proofPath)
    {
        if (!$proofPath) {
            return null;
        }

        $extension = pathinfo($proofPath, PATHINFO_EXTENSION);

        return match(strtolower($extension)) {
            'jpg', 'jpeg' => 'image',
            'png' => 'image',
            'gif' => 'image',
            'pdf' => 'document',
            default => 'unknown'
        };
    }
}
```

### Step 3: Create Payment Verification Controller

```php
<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Api\BaseController;
use App\Http\Requests\VerificationRequest;
use App\Services\VerificationService;
use App\Models\Payment;
use App\Models\PaymentVerification;
use Illuminate\Http\Request;

class PaymentVerificationController extends BaseController
{
    protected $verificationService;

    public function __construct(VerificationService $verificationService)
    {
        $this->verificationService = $verificationService;
    }

    public function index(Request $request)
    {
        try {
            $filters = $request->only(['min_amount', 'max_amount', 'payment_method', 'bank_account_id', 'created_after', 'per_page']);
            $payments = $this->verificationService->getPendingVerifications($filters);

            return $this->successResponse($payments, 'Pending verifications retrieved successfully');
        } catch (\Exception $e) {
            return $this->errorResponse($e->getMessage(), 400);
        }
    }

    public function store(VerificationRequest $request)
    {
        try {
            $data = $request->validated();
            $verification = $this->verificationService->createVerification(
                $data['payment_id'],
                $data['status'],
                $data['note'] ?? null,
                auth()->id()
            );

            return $this->successResponse($verification->load(['payment', 'verifiedBy']), 'Verification created successfully', 201);
        } catch (\Exception $e) {
            return $this->errorResponse($e->getMessage(), 400);
        }
    }

    public function show($id)
    {
        try {
            $verification = PaymentVerification::with(['payment.user', 'payment.booking', 'payment.bankAccount', 'verifiedBy'])
                ->findOrFail($id);

            return $this->successResponse($verification, 'Verification retrieved successfully');
        } catch (\Exception $e) {
            return $this->errorResponse($e->getMessage(), 404);
        }
    }

    public function verifyPayment(Request $request, $paymentId)
    {
        $request->validate([
            'status' => 'required|in:approved,rejected',
            'note' => 'nullable|string|max:500',
        ]);

        try {
            $verification = $this->verificationService->createVerification(
                $paymentId,
                $request->status,
                $request->note,
                auth()->id()
            );

            return $this->successResponse($verification, 'Payment verified successfully');
        } catch (\Exception $e) {
            return $this->errorResponse($e->getMessage(), 400);
        }
    }

    public function autoVerify($paymentId)
    {
        try {
            $verification = $this->verificationService->autoVerifyPayment($paymentId);

            return $this->successResponse($verification, 'Payment auto-verified successfully');
        } catch (\Exception $e) {
            return $this->errorResponse($e->getMessage(), 400);
        }
    }

    public function bulkVerify(Request $request)
    {
        $request->validate([
            'payment_ids' => 'required|array|min:1',
            'payment_ids.*' => 'exists:payments,id',
            'status' => 'required|in:approved,rejected',
            'note' => 'nullable|string|max:500',
        ]);

        try {
            $results = $this->verificationService->bulkVerifyPayments(
                $request->payment_ids,
                $request->status,
                $request->note,
                auth()->id()
            );

            return $this->successResponse($results, 'Bulk verification completed');
        } catch (\Exception $e) {
            return $this->errorResponse($e->getMessage(), 400);
        }
    }

    public function getStats(Request $request)
    {
        try {
            $filters = $request->only(['start_date', 'end_date', 'verified_by']);
            $stats = $this->verificationService->getVerificationStats($filters);

            return $this->successResponse($stats, 'Verification statistics retrieved successfully');
        } catch (\Exception $e) {
            return $this->errorResponse($e->getMessage(), 400);
        }
    }

    public function getHistory($paymentId)
    {
        try {
            $history = $this->verificationService->getVerificationHistory($paymentId);

            return $this->successResponse($history, 'Verification history retrieved successfully');
        } catch (\Exception $e) {
            return $this->errorResponse($e->getMessage(), 404);
        }
    }

    public function getQueue(Request $request)
    {
        try {
            $verifierId = $request->get('verifier_id');
            $queue = $this->verificationService->getVerificationQueue($verifierId);

            return $this->successResponse($queue, 'Verification queue retrieved successfully');
        } catch (\Exception $e) {
            return $this->errorResponse($e->getMessage(), 400);
        }
    }

    public function assignVerification(Request $request, $paymentId)
    {
        $request->validate([
            'verifier_id' => 'required|exists:users,id',
        ]);

        try {
            $payment = $this->verificationService->assignVerification($paymentId, $request->verifier_id);

            return $this->successResponse($payment, 'Verification assigned successfully');
        } catch (\Exception $e) {
            return $this->errorResponse($e->getMessage(), 400);
        }
    }

    public function unassignVerification($paymentId)
    {
        try {
            $payment = $this->verificationService->unassignVerification($paymentId);

            return $this->successResponse($payment, 'Verification unassigned successfully');
        } catch (\Exception $e) {
            return $this->errorResponse($e->getMessage(), 400);
        }
    }

    public function getVerificationDetails($paymentId)
    {
        try {
            $payment = Payment::with(['user', 'booking', 'bankAccount', 'paymentVerifications.verifiedBy'])
                ->findOrFail($paymentId);

            $verificationData = [
                'payment' => $payment,
                'verification_score' => $this->verificationService->calculateProofValidationScore($payment),
                'auto_verification_criteria' => $this->verificationService->checkAutoVerificationCriteria($payment),
                'verification_history' => $payment->paymentVerifications,
            ];

            return $this->successResponse($verificationData, 'Verification details retrieved successfully');
        } catch (\Exception $e) {
            return $this->errorResponse($e->getMessage(), 404);
        }
    }
}
```

### Step 4: Create Request Classes

#### VerificationRequest

```php
<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class VerificationRequest extends FormRequest
{
    public function authorize()
    {
        return true;
    }

    public function rules()
    {
        return [
            'payment_id' => ['required', 'exists:payments,id'],
            'status' => ['required', 'in:approved,rejected'],
            'note' => ['nullable', 'string', 'max:500'],
        ];
    }

    public function messages()
    {
        return [
            'payment_id.required' => 'Payment is required',
            'payment_id.exists' => 'Selected payment does not exist',
            'status.required' => 'Verification status is required',
            'status.in' => 'Invalid verification status',
            'note.max' => 'Note cannot exceed 500 characters',
        ];
    }

    public function withValidator($validator)
    {
        $validator->after(function ($validator) {
            // Validate payment can be verified
            if ($this->payment_id) {
                $payment = \App\Models\Payment::find($this->payment_id);
                if ($payment && !$payment->can_be_verified) {
                    $validator->errors()->add('payment_id', 'Payment cannot be verified');
                }
            }
        });
    }
}
```

## 📚 API Endpoints

### Payment Verification Endpoints

```
GET    /api/v1/admin/verifications
POST   /api/v1/admin/verifications
GET    /api/v1/admin/verifications/{id}
POST   /api/v1/admin/verifications/{paymentId}/verify
POST   /api/v1/admin/verifications/{paymentId}/auto-verify
POST   /api/v1/admin/verifications/bulk-verify
GET    /api/v1/admin/verifications/stats
GET    /api/v1/admin/verifications/{paymentId}/history
GET    /api/v1/admin/verifications/queue
POST   /api/v1/admin/verifications/{paymentId}/assign
DELETE /api/v1/admin/verifications/{paymentId}/assign
GET    /api/v1/admin/verifications/{paymentId}/details
```

## 🧪 Testing

### PaymentVerificationTest.php

```php
<?php

use App\Models\Payment;
use App\Models\PaymentVerification;
use App\Models\User;
use App\Services\VerificationService;

describe('Payment Verification', function () {

    beforeEach(function () {
        $this->verificationService = app(VerificationService::class);
    });

    it('can verify payment', function () {
        $payment = Payment::factory()->create(['status' => 'pending']);
        actingAsAdmin();

        $verification = $this->verificationService->createVerification(
            $payment->id,
            'approved',
            'Payment verified',
            auth()->id()
        );

        expect($verification->status)->toBe('approved');
        expect($verification->auto_verified)->toBeFalse();

        $payment->refresh();
        expect($payment->status)->toBe('verified');
    });

    it('can auto-verify payment with high score', function () {
        $payment = Payment::factory()->create([
            'status' => 'pending',
            'payment_proof_path' => 'proof.jpg',
            'amount' => 100000
        ]);

        $booking = $payment->booking;
        $booking->update(['total_amount' => 100000]);

        $verification = $this->verificationService->autoVerifyPayment($payment->id);

        expect($verification->status)->toBe('approved');
        expect($verification->auto_verified)->toBeTrue();
    });

    it('can get pending verifications', function () {
        Payment::factory()->count(5)->create(['status' => 'pending']);
        actingAsAdmin();

        $pendingVerifications = $this->verificationService->getPendingVerifications();

        expect($pendingVerifications->count())->toBe(5);
    });

    it('can bulk verify payments', function () {
        $payments = Payment::factory()->count(3)->create(['status' => 'pending']);
        $paymentIds = $payments->pluck('id')->toArray();
        actingAsAdmin();

        $results = $this->verificationService->bulkVerifyPayments(
            $paymentIds,
            'approved',
            'Bulk verification'
        );

        expect($results)->toHaveCount(3);
        expect($results[0]['success'])->toBeTrue();
    });

    it('cannot verify already verified payment', function () {
        $payment = Payment::factory()->create(['status' => 'verified']);
        actingAsAdmin();

        expect(function () use ($payment) {
            $this->verificationService->createVerification($payment->id, 'approved');
        })->toThrow(Exception::class, 'Payment cannot be verified');
    });
});
```

## ✅ Success Criteria

-   [x] Admin verification interface berfungsi
-   [x] Payment proof validation berjalan
-   [x] Verification workflow berfungsi
-   [x] Rejection handling berjalan
-   [x] Verification notifications berfungsi
-   [x] Verification history berjalan
-   [x] Testing coverage > 90%

## 📚 Documentation

-   [Laravel Database Transactions](https://laravel.com/docs/11.x/database#database-transactions)
-   [Laravel Events](https://laravel.com/docs/11.x/events)
-   [Laravel Validation](https://laravel.com/docs/11.x/validation)
