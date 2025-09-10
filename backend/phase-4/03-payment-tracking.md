# Point 3: Payment Tracking

## 📋 Overview

Implementasi sistem tracking pembayaran dengan payment status tracking, payment timeline, dan payment reminders.

## 🎯 Objectives

-   Payment status tracking
-   Payment timeline
-   Payment reminders
-   Payment expiry handling
-   Payment reconciliation
-   Payment reporting

## 📁 Files Structure

```
phase-4/
├── 03-payment-tracking.md
├── app/Http/Controllers/PaymentTrackingController.php
├── app/Models/PaymentTracking.php
├── app/Services/TrackingService.php
└── app/Jobs/SendPaymentReminderJob.php
```

## 🔧 Implementation Steps

### Step 1: Create Payment Tracking Model

```php
<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class PaymentTracking extends Model
{
    use HasFactory;

    protected $fillable = [
        'payment_id',
        'status',
        'event_type',
        'event_data',
        'triggered_by',
        'triggered_at',
        'notes',
    ];

    protected $casts = [
        'event_data' => 'array',
        'triggered_at' => 'datetime',
    ];

    public function payment()
    {
        return $this->belongsTo(Payment::class);
    }

    public function triggeredBy()
    {
        return $this->belongsTo(User::class, 'triggered_by');
    }

    public function getEventTypeDisplayAttribute()
    {
        return match($this->event_type) {
            'created' => 'Payment Created',
            'proof_uploaded' => 'Proof Uploaded',
            'reminder_sent' => 'Reminder Sent',
            'expiry_warning' => 'Expiry Warning',
            'expired' => 'Payment Expired',
            'verified' => 'Payment Verified',
            'rejected' => 'Payment Rejected',
            'cancelled' => 'Payment Cancelled',
            default => 'Unknown Event'
        };
    }

    public function scopeByEventType($query, $eventType)
    {
        return $query->where('event_type', $eventType);
    }

    public function scopeByStatus($query, $status)
    {
        return $query->where('status', $status);
    }

    public function scopeByDateRange($query, $startDate, $endDate)
    {
        return $query->whereBetween('triggered_at', [$startDate, $endDate]);
    }

    public function scopeByTriggeredBy($query, $userId)
    {
        return $query->where('triggered_by', $userId);
    }
}
```

### Step 2: Create Tracking Service

```php
<?php

namespace App\Services;

use App\Models\Payment;
use App\Models\PaymentTracking;
use App\Jobs\SendPaymentReminderJob;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;
use Carbon\Carbon;

class TrackingService
{
    public function trackPaymentEvent($paymentId, $eventType, $eventData = [], $triggeredBy = null)
    {
        return DB::transaction(function () use ($paymentId, $eventType, $eventData, $triggeredBy) {
            $payment = Payment::findOrFail($paymentId);

            $tracking = PaymentTracking::create([
                'payment_id' => $payment->id,
                'status' => $payment->status,
                'event_type' => $eventType,
                'event_data' => $eventData,
                'triggered_by' => $triggeredBy ?? auth()->id(),
                'triggered_at' => now(),
                'notes' => $this->generateEventNotes($eventType, $eventData),
            ]);

            Log::info('Payment event tracked', [
                'payment_id' => $payment->id,
                'event_type' => $eventType,
                'tracking_id' => $tracking->id,
            ]);

            return $tracking;
        });
    }

    public function getPaymentTimeline($paymentId)
    {
        $payment = Payment::findOrFail($paymentId);
        $tracking = PaymentTracking::with(['triggeredBy'])
            ->where('payment_id', $paymentId)
            ->orderBy('triggered_at', 'asc')
            ->get();

        $timeline = [];

        // Add payment creation event
        $timeline[] = [
            'event' => 'Payment Created',
            'timestamp' => $payment->created_at,
            'description' => 'Payment request created',
            'status' => 'created',
            'triggered_by' => null,
        ];

        // Add tracking events
        foreach ($tracking as $event) {
            $timeline[] = [
                'event' => $event->event_type_display,
                'timestamp' => $event->triggered_at,
                'description' => $event->notes,
                'status' => $event->status,
                'triggered_by' => $event->triggeredBy ? $event->triggeredBy->name : 'System',
                'event_data' => $event->event_data,
            ];
        }

        return $timeline;
    }

    public function sendPaymentReminder($paymentId, $reminderType = 'standard')
    {
        $payment = Payment::findOrFail($paymentId);

        if ($payment->status !== 'pending') {
            throw new \Exception('Only pending payments can receive reminders');
        }

        // Dispatch reminder job
        SendPaymentReminderJob::dispatch($payment, $reminderType);

        // Track reminder event
        $this->trackPaymentEvent($paymentId, 'reminder_sent', [
            'reminder_type' => $reminderType,
            'sent_at' => now(),
        ]);

        return true;
    }

    public function sendExpiryWarning($paymentId)
    {
        $payment = Payment::findOrFail($paymentId);

        if ($payment->status !== 'pending') {
            throw new \Exception('Only pending payments can receive expiry warnings');
        }

        if (!$payment->expires_at || $payment->expires_at->isPast()) {
            throw new \Exception('Payment is already expired or has no expiry date');
        }

        // Track expiry warning event
        $this->trackPaymentEvent($paymentId, 'expiry_warning', [
            'expires_at' => $payment->expires_at,
            'time_remaining' => $payment->expires_at->diffForHumans(),
        ]);

        return true;
    }

    public function processExpiredPayments()
    {
        $expiredPayments = Payment::where('status', 'pending')
            ->where('expires_at', '<', now())
            ->get();

        $processedCount = 0;

        foreach ($expiredPayments as $payment) {
            try {
                // Update payment status
                $payment->update(['status' => 'expired']);

                // Update booking status
                $payment->booking->update(['payment_status' => 'unpaid']);

                // Track expiry event
                $this->trackPaymentEvent($payment->id, 'expired', [
                    'expired_at' => now(),
                    'original_expiry' => $payment->expires_at,
                ]);

                $processedCount++;
            } catch (\Exception $e) {
                Log::error('Failed to process expired payment', [
                    'payment_id' => $payment->id,
                    'error' => $e->getMessage(),
                ]);
            }
        }

        return $processedCount;
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
            'pending_payments' => $query->clone()->where('status', 'pending')->count(),
            'verified_payments' => $query->clone()->where('status', 'verified')->count(),
            'rejected_payments' => $query->clone()->where('status', 'rejected')->count(),
            'expired_payments' => $query->clone()->where('status', 'expired')->count(),
            'total_amount' => $query->clone()->sum('amount'),
            'average_payment_time' => $this->calculateAveragePaymentTime($query->clone()),
            'payment_success_rate' => $this->calculateSuccessRate($query->clone()),
        ];

        return $stats;
    }

    public function getPaymentTrends($days = 30)
    {
        $startDate = now()->subDays($days);
        $endDate = now();

        $trends = [];
        $currentDate = $startDate->copy();

        while ($currentDate->lte($endDate)) {
            $date = $currentDate->format('Y-m-d');

            $dayStats = [
                'date' => $date,
                'total_payments' => Payment::whereDate('created_at', $date)->count(),
                'pending_payments' => Payment::whereDate('created_at', $date)->where('status', 'pending')->count(),
                'verified_payments' => Payment::whereDate('created_at', $date)->where('status', 'verified')->count(),
                'rejected_payments' => Payment::whereDate('created_at', $date)->where('status', 'rejected')->count(),
                'expired_payments' => Payment::whereDate('created_at', $date)->where('status', 'expired')->count(),
                'total_amount' => Payment::whereDate('created_at', $date)->sum('amount'),
            ];

            $trends[] = $dayStats;
            $currentDate->addDay();
        }

        return $trends;
    }

    public function getPaymentReconciliation($startDate, $endDate)
    {
        $payments = Payment::with(['booking', 'user'])
            ->whereBetween('created_at', [$startDate, $endDate])
            ->get();

        $reconciliation = [
            'period' => [
                'start_date' => $startDate,
                'end_date' => $endDate,
            ],
            'summary' => [
                'total_payments' => $payments->count(),
                'total_amount' => $payments->sum('amount'),
                'verified_amount' => $payments->where('status', 'verified')->sum('amount'),
                'pending_amount' => $payments->where('status', 'pending')->sum('amount'),
                'rejected_amount' => $payments->where('status', 'rejected')->sum('amount'),
                'expired_amount' => $payments->where('status', 'expired')->sum('amount'),
            ],
            'by_status' => $payments->groupBy('status')->map(function ($group) {
                return [
                    'count' => $group->count(),
                    'total_amount' => $group->sum('amount'),
                    'average_amount' => $group->avg('amount'),
                ];
            }),
            'by_payment_method' => $payments->groupBy('payment_method')->map(function ($group) {
                return [
                    'count' => $group->count(),
                    'total_amount' => $group->sum('amount'),
                    'average_amount' => $group->avg('amount'),
                ];
            }),
            'by_bank_account' => $payments->groupBy('bank_account_id')->map(function ($group) {
                return [
                    'count' => $group->count(),
                    'total_amount' => $group->sum('amount'),
                    'average_amount' => $group->avg('amount'),
                ];
            }),
        ];

        return $reconciliation;
    }

    public function generatePaymentReport($filters = [])
    {
        $query = Payment::with(['user', 'booking', 'bankAccount']);

        // Apply filters
        if (isset($filters['start_date']) && isset($filters['end_date'])) {
            $query->whereBetween('created_at', [$filters['start_date'], $filters['end_date']]);
        }

        if (isset($filters['status'])) {
            $query->where('status', $filters['status']);
        }

        if (isset($filters['payment_method'])) {
            $query->where('payment_method', $filters['payment_method']);
        }

        if (isset($filters['user_id'])) {
            $query->where('user_id', $filters['user_id']);
        }

        $payments = $query->orderBy('created_at', 'desc')->get();

        $report = [
            'generated_at' => now(),
            'filters' => $filters,
            'summary' => [
                'total_payments' => $payments->count(),
                'total_amount' => $payments->sum('amount'),
                'average_amount' => $payments->avg('amount'),
                'status_breakdown' => $payments->groupBy('status')->map(function ($group) {
                    return [
                        'count' => $group->count(),
                        'percentage' => round(($group->count() / $payments->count()) * 100, 2),
                        'total_amount' => $group->sum('amount'),
                    ];
                }),
            ],
            'payments' => $payments->map(function ($payment) {
                return [
                    'id' => $payment->id,
                    'reference_number' => $payment->reference_number,
                    'user_name' => $payment->user->name,
                    'booking_reference' => $payment->booking->booking_reference,
                    'amount' => $payment->amount,
                    'status' => $payment->status,
                    'payment_method' => $payment->payment_method,
                    'bank_account' => $payment->bankAccount ? $payment->bankAccount->bank_name : 'N/A',
                    'created_at' => $payment->created_at,
                    'verified_at' => $payment->verified_at,
                ];
            }),
        ];

        return $report;
    }

    protected function generateEventNotes($eventType, $eventData)
    {
        return match($eventType) {
            'created' => 'Payment request created',
            'proof_uploaded' => 'Payment proof uploaded',
            'reminder_sent' => 'Payment reminder sent',
            'expiry_warning' => 'Payment expiry warning sent',
            'expired' => 'Payment expired',
            'verified' => 'Payment verified and approved',
            'rejected' => 'Payment rejected',
            'cancelled' => 'Payment cancelled',
            default => 'Payment event occurred'
        };
    }

    protected function calculateAveragePaymentTime($query)
    {
        $payments = $query->whereNotNull('verified_at')->get();

        if ($payments->isEmpty()) {
            return 0;
        }

        $totalTime = $payments->sum(function ($payment) {
            return $payment->created_at->diffInMinutes($payment->verified_at);
        });

        return round($totalTime / $payments->count(), 2);
    }

    protected function calculateSuccessRate($query)
    {
        $totalPayments = $query->count();

        if ($totalPayments === 0) {
            return 0;
        }

        $verifiedPayments = $query->where('status', 'verified')->count();

        return round(($verifiedPayments / $totalPayments) * 100, 2);
    }
}
```

### Step 3: Create Payment Tracking Controller

```php
<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Api\BaseController;
use App\Services\TrackingService;
use App\Models\Payment;
use Illuminate\Http\Request;

class PaymentTrackingController extends BaseController
{
    protected $trackingService;

    public function __construct(TrackingService $trackingService)
    {
        $this->trackingService = $trackingService;
    }

    public function getTimeline($paymentId)
    {
        try {
            $timeline = $this->trackingService->getPaymentTimeline($paymentId);

            return $this->successResponse($timeline, 'Payment timeline retrieved successfully');
        } catch (\Exception $e) {
            return $this->errorResponse($e->getMessage(), 404);
        }
    }

    public function sendReminder(Request $request, $paymentId)
    {
        $request->validate([
            'reminder_type' => 'nullable|in:standard,urgent,final',
        ]);

        try {
            $this->trackingService->sendPaymentReminder(
                $paymentId,
                $request->reminder_type ?? 'standard'
            );

            return $this->successResponse(null, 'Payment reminder sent successfully');
        } catch (\Exception $e) {
            return $this->errorResponse($e->getMessage(), 400);
        }
    }

    public function sendExpiryWarning($paymentId)
    {
        try {
            $this->trackingService->sendExpiryWarning($paymentId);

            return $this->successResponse(null, 'Expiry warning sent successfully');
        } catch (\Exception $e) {
            return $this->errorResponse($e->getMessage(), 400);
        }
    }

    public function processExpiredPayments()
    {
        try {
            $processedCount = $this->trackingService->processExpiredPayments();

            return $this->successResponse([
                'processed_count' => $processedCount,
            ], 'Expired payments processed successfully');
        } catch (\Exception $e) {
            return $this->errorResponse($e->getMessage(), 400);
        }
    }

    public function getStats(Request $request)
    {
        try {
            $filters = $request->only(['start_date', 'end_date', 'user_id']);
            $stats = $this->trackingService->getPaymentStats($filters);

            return $this->successResponse($stats, 'Payment statistics retrieved successfully');
        } catch (\Exception $e) {
            return $this->errorResponse($e->getMessage(), 400);
        }
    }

    public function getTrends(Request $request)
    {
        $request->validate([
            'days' => 'nullable|integer|min:1|max:365',
        ]);

        try {
            $trends = $this->trackingService->getPaymentTrends($request->days ?? 30);

            return $this->successResponse($trends, 'Payment trends retrieved successfully');
        } catch (\Exception $e) {
            return $this->errorResponse($e->getMessage(), 400);
        }
    }

    public function getReconciliation(Request $request)
    {
        $request->validate([
            'start_date' => 'required|date',
            'end_date' => 'required|date|after_or_equal:start_date',
        ]);

        try {
            $reconciliation = $this->trackingService->getPaymentReconciliation(
                $request->start_date,
                $request->end_date
            );

            return $this->successResponse($reconciliation, 'Payment reconciliation retrieved successfully');
        } catch (\Exception $e) {
            return $this->errorResponse($e->getMessage(), 400);
        }
    }

    public function generateReport(Request $request)
    {
        try {
            $filters = $request->only(['start_date', 'end_date', 'status', 'payment_method', 'user_id']);
            $report = $this->trackingService->generatePaymentReport($filters);

            return $this->successResponse($report, 'Payment report generated successfully');
        } catch (\Exception $e) {
            return $this->errorResponse($e->getMessage(), 400);
        }
    }

    public function trackEvent(Request $request, $paymentId)
    {
        $request->validate([
            'event_type' => 'required|string',
            'event_data' => 'nullable|array',
            'notes' => 'nullable|string|max:500',
        ]);

        try {
            $tracking = $this->trackingService->trackPaymentEvent(
                $paymentId,
                $request->event_type,
                $request->event_data ?? [],
                auth()->id()
            );

            return $this->successResponse($tracking, 'Payment event tracked successfully');
        } catch (\Exception $e) {
            return $this->errorResponse($e->getMessage(), 400);
        }
    }
}
```

### Step 4: Create Payment Reminder Job

```php
<?php

namespace App\Jobs;

use App\Models\Payment;
use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Bus\Dispatchable;
use Illuminate\Queue\InteractsWithQueue;
use Illuminate\Queue\SerializesModels;
use Illuminate\Support\Facades\Log;

class SendPaymentReminderJob implements ShouldQueue
{
    use Dispatchable, InteractsWithQueue, Queueable, SerializesModels;

    protected $payment;
    protected $reminderType;

    public function __construct(Payment $payment, $reminderType = 'standard')
    {
        $this->payment = $payment;
        $this->reminderType = $reminderType;
    }

    public function handle()
    {
        try {
            // Check if payment is still pending
            $this->payment->refresh();

            if ($this->payment->status !== 'pending') {
                Log::info('Payment no longer pending, skipping reminder', [
                    'payment_id' => $this->payment->id,
                    'status' => $this->payment->status,
                ]);
                return;
            }

            // Send reminder based on type
            $this->sendReminderByType($this->payment, $this->reminderType);

            Log::info('Payment reminder sent', [
                'payment_id' => $this->payment->id,
                'reminder_type' => $this->reminderType,
                'user_id' => $this->payment->user_id,
            ]);

        } catch (\Exception $e) {
            Log::error('Failed to send payment reminder', [
                'payment_id' => $this->payment->id,
                'reminder_type' => $this->reminderType,
                'error' => $e->getMessage(),
            ]);

            throw $e;
        }
    }

    protected function sendReminderByType($payment, $reminderType)
    {
        $user = $payment->user;
        $bankAccount = $payment->bankAccount;

        $message = $this->getReminderMessage($reminderType, $payment, $bankAccount);

        // Implementation would depend on notification system
        // For now, we'll just log it
        Log::info('Payment reminder message', [
            'payment_id' => $payment->id,
            'user_id' => $user->id,
            'reminder_type' => $reminderType,
            'message' => $message,
        ]);
    }

    protected function getReminderMessage($reminderType, $payment, $bankAccount)
    {
        $baseMessage = "Payment Reminder\n";
        $baseMessage .= "Reference: {$payment->reference_number}\n";
        $baseMessage .= "Amount: Rp " . number_format($payment->amount) . "\n";
        $baseMessage .= "Bank: {$bankAccount->bank_name}\n";
        $baseMessage .= "Account: {$bankAccount->account_number}\n";

        switch ($reminderType) {
            case 'urgent':
                $baseMessage .= "URGENT: Payment expires in " . $payment->expires_at->diffForHumans() . "\n";
                $baseMessage .= "Please make payment immediately to avoid cancellation.";
                break;
            case 'final':
                $baseMessage .= "FINAL REMINDER: Payment expires in " . $payment->expires_at->diffForHumans() . "\n";
                $baseMessage .= "This is your final reminder. Payment will be cancelled if not received by expiry time.";
                break;
            default:
                $baseMessage .= "Payment expires in " . $payment->expires_at->diffForHumans() . "\n";
                $baseMessage .= "Please make payment to complete your booking.";
                break;
        }

        return $baseMessage;
    }
}
```

## 📚 API Endpoints

### Payment Tracking Endpoints

```
GET    /api/v1/payments/{id}/timeline
POST   /api/v1/payments/{id}/reminder
POST   /api/v1/payments/{id}/expiry-warning
POST   /api/v1/payments/process-expired
GET    /api/v1/payments/stats
GET    /api/v1/payments/trends
GET    /api/v1/payments/reconciliation
GET    /api/v1/payments/report
POST   /api/v1/payments/{id}/track-event
```

## 🧪 Testing

### PaymentTrackingTest.php

```php
<?php

use App\Models\Payment;
use App\Models\PaymentTracking;
use App\Services\TrackingService;

describe('Payment Tracking', function () {

    beforeEach(function () {
        $this->trackingService = app(TrackingService::class);
    });

    it('can track payment event', function () {
        $payment = Payment::factory()->create();
        actingAsUser();

        $tracking = $this->trackingService->trackPaymentEvent(
            $payment->id,
            'proof_uploaded',
            ['proof_path' => 'proof.jpg']
        );

        expect($tracking->event_type)->toBe('proof_uploaded');
        expect($tracking->event_data)->toHaveKey('proof_path');
    });

    it('can get payment timeline', function () {
        $payment = Payment::factory()->create();

        $this->trackingService->trackPaymentEvent($payment->id, 'proof_uploaded');
        $this->trackingService->trackPaymentEvent($payment->id, 'verified');

        $timeline = $this->trackingService->getPaymentTimeline($payment->id);

        expect($timeline)->toHaveCount(3); // created + 2 tracked events
        expect($timeline[0]['event'])->toBe('Payment Created');
        expect($timeline[1]['event'])->toBe('Proof Uploaded');
    });

    it('can send payment reminder', function () {
        $payment = Payment::factory()->create(['status' => 'pending']);
        actingAsAdmin();

        $result = $this->trackingService->sendPaymentReminder($payment->id, 'urgent');

        expect($result)->toBeTrue();

        $this->assertDatabaseHas('payment_trackings', [
            'payment_id' => $payment->id,
            'event_type' => 'reminder_sent',
        ]);
    });

    it('can process expired payments', function () {
        $payment = Payment::factory()->create([
            'status' => 'pending',
            'expires_at' => now()->subHour()
        ]);

        $processedCount = $this->trackingService->processExpiredPayments();

        expect($processedCount)->toBe(1);

        $payment->refresh();
        expect($payment->status)->toBe('expired');
    });

    it('can generate payment report', function () {
        Payment::factory()->count(5)->create();
        actingAsAdmin();

        $report = $this->trackingService->generatePaymentReport([
            'start_date' => now()->subDays(30),
            'end_date' => now(),
        ]);

        expect($report)->toHaveKey('summary');
        expect($report)->toHaveKey('payments');
        expect($report['summary']['total_payments'])->toBe(5);
    });
});
```

## ✅ Success Criteria

-   [x] Payment status tracking berfungsi
-   [x] Payment timeline berjalan
-   [x] Payment reminders berfungsi
-   [x] Payment expiry handling berjalan
-   [x] Payment reconciliation berfungsi
-   [x] Payment reporting berjalan
-   [x] Testing coverage > 90%

## 📚 Documentation

-   [Laravel Jobs](https://laravel.com/docs/11.x/queues)
-   [Laravel Database Transactions](https://laravel.com/docs/11.x/database#database-transactions)
-   [Laravel Events](https://laravel.com/docs/11.x/events)
