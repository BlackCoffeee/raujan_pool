# Point 4: Membership Expiry Management

## 📋 Overview

Implementasi sistem manajemen expiry membership dengan expiry date tracking, expiry notifications, dan expiry processing.

## 🎯 Objectives

-   Expiry date tracking
-   Expiry notifications
-   Expiry processing
-   Membership renewal
-   Expiry analytics
-   Expiry automation

## 📁 Files Structure

```
phase-5/
├── 04-membership-expiry.md
├── app/Http/Controllers/MembershipExpiryController.php
├── app/Models/MembershipExpiryTracking.php
├── app/Services/ExpiryService.php
└── app/Jobs/ProcessExpiryJob.php
```

## 🔧 Implementation Steps

### Step 1: Create Membership Expiry Tracking Model

```php
<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Carbon\Carbon;

class MembershipExpiryTracking extends Model
{
    use HasFactory;

    protected $fillable = [
        'member_id',
        'expiry_date',
        'notification_sent_3_days',
        'notification_sent_1_day',
        'notification_sent_expired',
        'status',
        'renewal_date',
        'renewal_amount',
        'renewal_method',
        'notes',
    ];

    protected $casts = [
        'expiry_date' => 'date',
        'renewal_date' => 'date',
        'renewal_amount' => 'decimal:2',
        'notification_sent_3_days' => 'boolean',
        'notification_sent_1_day' => 'boolean',
        'notification_sent_expired' => 'boolean',
    ];

    public function member()
    {
        return $this->belongsTo(Member::class);
    }

    public function getStatusDisplayAttribute()
    {
        return match($this->status) {
            'active' => 'Active',
            'expired' => 'Expired',
            'renewed' => 'Renewed',
            default => 'Unknown'
        };
    }

    public function getIsActiveAttribute()
    {
        return $this->status === 'active';
    }

    public function getIsExpiredAttribute()
    {
        return $this->status === 'expired';
    }

    public function getIsRenewedAttribute()
    {
        return $this->status === 'renewed';
    }

    public function getDaysUntilExpiryAttribute()
    {
        return $this->expiry_date->diffInDays(now());
    }

    public function getIsExpiringSoonAttribute()
    {
        return $this->days_until_expiry <= 7 && $this->days_until_expiry > 0;
    }

    public function getIsExpiredAttribute()
    {
        return $this->expiry_date->isPast();
    }

    public function getExpiryStatusAttribute()
    {
        if ($this->is_expired) {
            return 'expired';
        } elseif ($this->days_until_expiry <= 1) {
            return 'expires_today';
        } elseif ($this->days_until_expiry <= 3) {
            return 'expires_soon';
        } elseif ($this->days_until_expiry <= 7) {
            return 'expires_this_week';
        } else {
            return 'active';
        }
    }

    public function getCanRenewAttribute()
    {
        return $this->is_active && !$this->member->hasActiveBookings();
    }

    public function scopeActive($query)
    {
        return $query->where('status', 'active');
    }

    public function scopeExpired($query)
    {
        return $query->where('status', 'expired');
    }

    public function scopeRenewed($query)
    {
        return $query->where('status', 'renewed');
    }

    public function scopeExpiringSoon($query, $days = 7)
    {
        return $query->where('expiry_date', '<=', now()->addDays($days))
            ->where('expiry_date', '>', now())
            ->where('status', 'active');
    }

    public function scopeExpired($query)
    {
        return $query->where('expiry_date', '<', now())
            ->where('status', 'active');
    }

    public function scopeByDateRange($query, $startDate, $endDate)
    {
        return $query->whereBetween('expiry_date', [$startDate, $endDate]);
    }

    public function scopeNeedsNotification($query, $days)
    {
        return $query->where('expiry_date', '<=', now()->addDays($days))
            ->where('expiry_date', '>', now())
            ->where('status', 'active')
            ->where(function ($q) use ($days) {
                if ($days === 3) {
                    $q->where('notification_sent_3_days', false);
                } elseif ($days === 1) {
                    $q->where('notification_sent_1_day', false);
                }
            });
    }
}
```

### Step 2: Create Expiry Service

```php
<?php

namespace App\Services;

use App\Models\Member;
use App\Models\MembershipExpiryTracking;
use App\Jobs\ProcessExpiryJob;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;
use Carbon\Carbon;

class ExpiryService
{
    public function createExpiryTracking($memberId, $expiryDate)
    {
        return DB::transaction(function () use ($memberId, $expiryDate) {
            $member = Member::findOrFail($memberId);

            // Check if tracking already exists
            $existingTracking = $member->expiryTracking;
            if ($existingTracking) {
                $existingTracking->update([
                    'expiry_date' => $expiryDate,
                    'status' => 'active',
                    'notification_sent_3_days' => false,
                    'notification_sent_1_day' => false,
                    'notification_sent_expired' => false,
                ]);
                return $existingTracking;
            }

            // Create new tracking
            $tracking = MembershipExpiryTracking::create([
                'member_id' => $member->id,
                'expiry_date' => $expiryDate,
                'status' => 'active',
                'notification_sent_3_days' => false,
                'notification_sent_1_day' => false,
                'notification_sent_expired' => false,
            ]);

            Log::info('Expiry tracking created', [
                'member_id' => $member->id,
                'expiry_date' => $expiryDate,
            ]);

            return $tracking;
        });
    }

    public function renewMembership($memberId, $newExpiryDate, $renewalAmount = null, $renewalMethod = null)
    {
        return DB::transaction(function () use ($memberId, $newExpiryDate, $renewalAmount, $renewalMethod) {
            $member = Member::findOrFail($memberId);
            $tracking = $member->expiryTracking;

            if (!$tracking || !$tracking->can_renew) {
                throw new \Exception('Membership cannot be renewed');
            }

            // Update member
            $member->update([
                'membership_end' => $newExpiryDate,
                'status' => 'active',
            ]);

            // Update tracking
            $tracking->update([
                'expiry_date' => $newExpiryDate,
                'status' => 'renewed',
                'renewal_date' => now()->toDateString(),
                'renewal_amount' => $renewalAmount,
                'renewal_method' => $renewalMethod,
                'notification_sent_3_days' => false,
                'notification_sent_1_day' => false,
                'notification_sent_expired' => false,
            ]);

            // Create new tracking for the renewed period
            $this->createExpiryTracking($memberId, $newExpiryDate);

            // Send renewal confirmation
            $this->sendRenewalConfirmation($member, $tracking);

            Log::info('Membership renewed', [
                'member_id' => $member->id,
                'new_expiry_date' => $newExpiryDate,
                'renewal_amount' => $renewalAmount,
                'renewed_by' => auth()->id(),
            ]);

            return $member;
        });
    }

    public function processExpiredMemberships()
    {
        $expiredMembers = Member::where('status', 'active')
            ->where('membership_end', '<', now())
            ->get();

        $processedCount = 0;

        foreach ($expiredMembers as $member) {
            try {
                $this->expireMembership($member->id);
                $processedCount++;
            } catch (\Exception $e) {
                Log::error('Failed to expire membership', [
                    'member_id' => $member->id,
                    'error' => $e->getMessage(),
                ]);
            }
        }

        return $processedCount;
    }

    public function expireMembership($memberId)
    {
        return DB::transaction(function () use ($memberId) {
            $member = Member::findOrFail($memberId);
            $tracking = $member->expiryTracking;

            // Update member status
            $member->update(['status' => 'expired']);

            // Update tracking
            if ($tracking) {
                $tracking->update([
                    'status' => 'expired',
                    'notification_sent_expired' => true,
                ]);
            }

            // Send expiry notification
            $this->sendExpiryNotification($member);

            Log::info('Membership expired', [
                'member_id' => $member->id,
                'expired_by' => auth()->id(),
            ]);

            return $member;
        });
    }

    public function sendExpiryNotifications($days = 3)
    {
        $memberships = MembershipExpiryTracking::needsNotification($days)->get();
        $sentCount = 0;

        foreach ($memberships as $tracking) {
            try {
                $this->sendExpiryWarning($tracking, $days);

                // Mark notification as sent
                $tracking->update([
                    "notification_sent_{$days}_days" => true,
                ]);

                $sentCount++;
            } catch (\Exception $e) {
                Log::error('Failed to send expiry notification', [
                    'tracking_id' => $tracking->id,
                    'member_id' => $tracking->member_id,
                    'days' => $days,
                    'error' => $e->getMessage(),
                ]);
            }
        }

        return $sentCount;
    }

    public function getExpiryStats($filters = [])
    {
        $query = MembershipExpiryTracking::query();

        // Apply filters
        if (isset($filters['start_date']) && isset($filters['end_date'])) {
            $query->whereBetween('expiry_date', [$filters['start_date'], $filters['end_date']]);
        }

        $stats = [
            'total_trackings' => $query->count(),
            'active_trackings' => $query->clone()->active()->count(),
            'expired_trackings' => $query->clone()->expired()->count(),
            'renewed_trackings' => $query->clone()->renewed()->count(),
            'expiring_soon' => $query->clone()->expiringSoon()->count(),
            'expired_today' => $query->clone()->whereDate('expiry_date', now())->count(),
            'expiring_this_week' => $query->clone()->expiringSoon(7)->count(),
            'expiring_this_month' => $query->clone()->expiringSoon(30)->count(),
        ];

        return $stats;
    }

    public function getExpiryAnalytics($filters = [])
    {
        $query = MembershipExpiryTracking::query();

        // Apply filters
        if (isset($filters['start_date']) && isset($filters['end_date'])) {
            $query->whereBetween('expiry_date', [$filters['start_date'], $filters['end_date']]);
        }

        $analytics = [
            'expiry_trends' => $this->getExpiryTrends($query->clone()),
            'renewal_analytics' => $this->getRenewalAnalytics($query->clone()),
            'notification_effectiveness' => $this->getNotificationEffectiveness($query->clone()),
            'expiry_by_membership_type' => $this->getExpiryByMembershipType($query->clone()),
        ];

        return $analytics;
    }

    public function bulkRenewMemberships($memberIds, $newExpiryDate, $renewalAmount = null, $renewalMethod = null)
    {
        $results = [];

        foreach ($memberIds as $memberId) {
            try {
                $member = $this->renewMembership($memberId, $newExpiryDate, $renewalAmount, $renewalMethod);
                $results[] = [
                    'member_id' => $memberId,
                    'success' => true,
                    'new_expiry_date' => $newExpiryDate,
                ];
            } catch (\Exception $e) {
                $results[] = [
                    'member_id' => $memberId,
                    'success' => false,
                    'error' => $e->getMessage(),
                ];
            }
        }

        return $results;
    }

    public function getExpiringMemberships($days = 7)
    {
        return MembershipExpiryTracking::with(['member.user'])
            ->expiringSoon($days)
            ->orderBy('expiry_date', 'asc')
            ->get();
    }

    public function getExpiredMemberships()
    {
        return MembershipExpiryTracking::with(['member.user'])
            ->expired()
            ->orderBy('expiry_date', 'desc')
            ->get();
    }

    protected function sendExpiryWarning($tracking, $days)
    {
        $member = $tracking->member;
        $user = $member->user;

        $message = "Membership Expiry Warning\n";
        $message .= "Your membership will expire in {$days} day(s) on {$tracking->expiry_date->format('Y-m-d')}.\n";
        $message .= "Please renew your membership to continue enjoying our services.";

        Log::info('Expiry warning sent', [
            'member_id' => $member->id,
            'user_id' => $user->id,
            'days' => $days,
            'expiry_date' => $tracking->expiry_date,
            'message' => $message,
        ]);
    }

    protected function sendExpiryNotification($member)
    {
        $user = $member->user;

        $message = "Membership Expired\n";
        $message .= "Your membership has expired on {$member->membership_end->format('Y-m-d')}.\n";
        $message .= "Please renew your membership to continue using our services.";

        Log::info('Expiry notification sent', [
            'member_id' => $member->id,
            'user_id' => $user->id,
            'expiry_date' => $member->membership_end,
            'message' => $message,
        ]);
    }

    protected function sendRenewalConfirmation($member, $tracking)
    {
        $user = $member->user;

        $message = "Membership Renewed\n";
        $message .= "Your membership has been renewed successfully.\n";
        $message .= "New expiry date: {$member->membership_end->format('Y-m-d')}\n";
        if ($tracking->renewal_amount) {
            $message .= "Renewal amount: Rp " . number_format($tracking->renewal_amount);
        }

        Log::info('Renewal confirmation sent', [
            'member_id' => $member->id,
            'user_id' => $user->id,
            'new_expiry_date' => $member->membership_end,
            'renewal_amount' => $tracking->renewal_amount,
            'message' => $message,
        ]);
    }

    protected function getExpiryTrends($query)
    {
        $startDate = now()->subDays(30);
        $endDate = now()->addDays(30);

        $trends = [];
        $currentDate = $startDate->copy();

        while ($currentDate->lte($endDate)) {
            $date = $currentDate->format('Y-m-d');

            $dayStats = [
                'date' => $date,
                'expiring_today' => $query->clone()->whereDate('expiry_date', $date)->count(),
                'renewed_today' => $query->clone()->whereDate('renewal_date', $date)->count(),
            ];

            $trends[] = $dayStats;
            $currentDate->addDay();
        }

        return $trends;
    }

    protected function getRenewalAnalytics($query)
    {
        $renewedTrackings = $query->renewed()->get();

        return [
            'total_renewals' => $renewedTrackings->count(),
            'average_renewal_amount' => $renewedTrackings->avg('renewal_amount'),
            'total_renewal_revenue' => $renewedTrackings->sum('renewal_amount'),
            'renewal_methods' => $renewedTrackings->groupBy('renewal_method')->map(function ($group) {
                return [
                    'method' => $group->first()->renewal_method,
                    'count' => $group->count(),
                    'total_amount' => $group->sum('renewal_amount'),
                ];
            }),
        ];
    }

    protected function getNotificationEffectiveness($query)
    {
        $trackings = $query->get();

        return [
            'notifications_sent_3_days' => $trackings->where('notification_sent_3_days', true)->count(),
            'notifications_sent_1_day' => $trackings->where('notification_sent_1_day', true)->count(),
            'notifications_sent_expired' => $trackings->where('notification_sent_expired', true)->count(),
            'renewal_rate_after_3_day_notification' => $this->calculateRenewalRate($trackings, 'notification_sent_3_days'),
            'renewal_rate_after_1_day_notification' => $this->calculateRenewalRate($trackings, 'notification_sent_1_day'),
        ];
    }

    protected function getExpiryByMembershipType($query)
    {
        return $query->with(['member'])
            ->get()
            ->groupBy('member.membership_type')
            ->map(function ($group) {
                return [
                    'membership_type' => $group->first()->member->membership_type,
                    'total_expiries' => $group->count(),
                    'renewed' => $group->where('status', 'renewed')->count(),
                    'expired' => $group->where('status', 'expired')->count(),
                    'renewal_rate' => $group->count() > 0 ? round(($group->where('status', 'renewed')->count() / $group->count()) * 100, 2) : 0,
                ];
            });
    }

    protected function calculateRenewalRate($trackings, $notificationField)
    {
        $notifiedTrackings = $trackings->where($notificationField, true);
        $renewedAfterNotification = $notifiedTrackings->where('status', 'renewed');

        return $notifiedTrackings->count() > 0 ?
            round(($renewedAfterNotification->count() / $notifiedTrackings->count()) * 100, 2) : 0;
    }
}
```

### Step 3: Create Expiry Controller

```php
<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Api\BaseController;
use App\Services\ExpiryService;
use App\Models\MembershipExpiryTracking;
use Illuminate\Http\Request;

class MembershipExpiryController extends BaseController
{
    protected $expiryService;

    public function __construct(ExpiryService $expiryService)
    {
        $this->expiryService = $expiryService;
    }

    public function index(Request $request)
    {
        $query = MembershipExpiryTracking::with(['member.user']);

        // Filter by status
        if ($request->status) {
            $query->where('status', $request->status);
        }

        // Filter by expiry date range
        if ($request->start_date && $request->end_date) {
            $query->whereBetween('expiry_date', [$request->start_date, $request->end_date]);
        }

        // Filter by expiring soon
        if ($request->expiring_soon) {
            $query->expiringSoon($request->expiring_soon);
        }

        $trackings = $query->orderBy('expiry_date', 'asc')->paginate($request->per_page ?? 15);

        return $this->successResponse($trackings, 'Expiry trackings retrieved successfully');
    }

    public function renewMembership(Request $request, $memberId)
    {
        $request->validate([
            'new_expiry_date' => 'required|date|after:today',
            'renewal_amount' => 'nullable|numeric|min:0',
            'renewal_method' => 'nullable|string|max:100',
        ]);

        try {
            $member = $this->expiryService->renewMembership(
                $memberId,
                $request->new_expiry_date,
                $request->renewal_amount,
                $request->renewal_method
            );

            return $this->successResponse($member, 'Membership renewed successfully');
        } catch (\Exception $e) {
            return $this->errorResponse($e->getMessage(), 400);
        }
    }

    public function expireMembership($memberId)
    {
        try {
            $member = $this->expiryService->expireMembership($memberId);

            return $this->successResponse($member, 'Membership expired successfully');
        } catch (\Exception $e) {
            return $this->errorResponse($e->getMessage(), 400);
        }
    }

    public function sendNotifications(Request $request)
    {
        $request->validate([
            'days' => 'required|integer|in:1,3',
        ]);

        try {
            $sentCount = $this->expiryService->sendExpiryNotifications($request->days);

            return $this->successResponse([
                'sent_count' => $sentCount,
            ], 'Expiry notifications sent successfully');
        } catch (\Exception $e) {
            return $this->errorResponse($e->getMessage(), 400);
        }
    }

    public function processExpiredMemberships()
    {
        try {
            $processedCount = $this->expiryService->processExpiredMemberships();

            return $this->successResponse([
                'processed_count' => $processedCount,
            ], 'Expired memberships processed successfully');
        } catch (\Exception $e) {
            return $this->errorResponse($e->getMessage(), 400);
        }
    }

    public function getExpiringMemberships(Request $request)
    {
        try {
            $days = $request->get('days', 7);
            $memberships = $this->expiryService->getExpiringMemberships($days);

            return $this->successResponse($memberships, 'Expiring memberships retrieved successfully');
        } catch (\Exception $e) {
            return $this->errorResponse($e->getMessage(), 400);
        }
    }

    public function getExpiredMemberships()
    {
        try {
            $memberships = $this->expiryService->getExpiredMemberships();

            return $this->successResponse($memberships, 'Expired memberships retrieved successfully');
        } catch (\Exception $e) {
            return $this->errorResponse($e->getMessage(), 400);
        }
    }

    public function getStats(Request $request)
    {
        try {
            $filters = $request->only(['start_date', 'end_date']);
            $stats = $this->expiryService->getExpiryStats($filters);

            return $this->successResponse($stats, 'Expiry statistics retrieved successfully');
        } catch (\Exception $e) {
            return $this->errorResponse($e->getMessage(), 400);
        }
    }

    public function getAnalytics(Request $request)
    {
        try {
            $filters = $request->only(['start_date', 'end_date']);
            $analytics = $this->expiryService->getExpiryAnalytics($filters);

            return $this->successResponse($analytics, 'Expiry analytics retrieved successfully');
        } catch (\Exception $e) {
            return $this->errorResponse($e->getMessage(), 400);
        }
    }

    public function bulkRenew(Request $request)
    {
        $request->validate([
            'member_ids' => 'required|array|min:1',
            'member_ids.*' => 'exists:members,id',
            'new_expiry_date' => 'required|date|after:today',
            'renewal_amount' => 'nullable|numeric|min:0',
            'renewal_method' => 'nullable|string|max:100',
        ]);

        try {
            $results = $this->expiryService->bulkRenewMemberships(
                $request->member_ids,
                $request->new_expiry_date,
                $request->renewal_amount,
                $request->renewal_method
            );

            return $this->successResponse($results, 'Bulk renewal completed');
        } catch (\Exception $e) {
            return $this->errorResponse($e->getMessage(), 400);
        }
    }

    public function getMyExpiryStatus()
    {
        try {
            $member = Member::where('user_id', auth()->id())->firstOrFail();
            $tracking = $member->expiryTracking;

            if (!$tracking) {
                return $this->errorResponse('No expiry tracking found', 404);
            }

            $expiryInfo = [
                'member_id' => $member->id,
                'expiry_date' => $tracking->expiry_date,
                'status' => $tracking->status,
                'days_until_expiry' => $tracking->days_until_expiry,
                'expiry_status' => $tracking->expiry_status,
                'can_renew' => $tracking->can_renew,
                'renewal_date' => $tracking->renewal_date,
                'renewal_amount' => $tracking->renewal_amount,
            ];

            return $this->successResponse($expiryInfo, 'Expiry status retrieved successfully');
        } catch (\Exception $e) {
            return $this->errorResponse($e->getMessage(), 404);
        }
    }
}
```

### Step 4: Create Expiry Processing Job

```php
<?php

namespace App\Jobs;

use App\Services\ExpiryService;
use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Bus\Dispatchable;
use Illuminate\Queue\InteractsWithQueue;
use Illuminate\Queue\SerializesModels;
use Illuminate\Support\Facades\Log;

class ProcessExpiryJob implements ShouldQueue
{
    use Dispatchable, InteractsWithQueue, Queueable, SerializesModels;

    public function handle(ExpiryService $expiryService)
    {
        try {
            // Process expired memberships
            $expiredCount = $expiryService->processExpiredMemberships();

            // Send 3-day expiry notifications
            $notifications3Days = $expiryService->sendExpiryNotifications(3);

            // Send 1-day expiry notifications
            $notifications1Day = $expiryService->sendExpiryNotifications(1);

            Log::info('Expiry processing completed', [
                'expired_memberships' => $expiredCount,
                'notifications_3_days' => $notifications3Days,
                'notifications_1_day' => $notifications1Day,
            ]);

        } catch (\Exception $e) {
            Log::error('Expiry processing failed', [
                'error' => $e->getMessage(),
            ]);

            throw $e;
        }
    }
}
```

## 📚 API Endpoints

### Membership Expiry Endpoints

```
GET    /api/v1/admin/expiry
POST   /api/v1/admin/expiry/{memberId}/renew
POST   /api/v1/admin/expiry/{memberId}/expire
POST   /api/v1/admin/expiry/send-notifications
POST   /api/v1/admin/expiry/process-expired
GET    /api/v1/admin/expiry/expiring
GET    /api/v1/admin/expiry/expired
GET    /api/v1/admin/expiry/stats
GET    /api/v1/admin/expiry/analytics
POST   /api/v1/admin/expiry/bulk-renew
GET    /api/v1/members/my-expiry-status
```

## 🧪 Testing

### ExpiryTest.php

```php
<?php

use App\Models\Member;
use App\Models\MembershipExpiryTracking;
use App\Services\ExpiryService;

describe('Membership Expiry Management', function () {

    beforeEach(function () {
        $this->expiryService = app(ExpiryService::class);
    });

    it('can create expiry tracking', function () {
        $member = Member::factory()->create();
        $expiryDate = now()->addYear();

        $tracking = $this->expiryService->createExpiryTracking($member->id, $expiryDate);

        expect($tracking->member_id)->toBe($member->id);
        expect($tracking->expiry_date->format('Y-m-d'))->toBe($expiryDate->format('Y-m-d'));
        expect($tracking->status)->toBe('active');
    });

    it('can renew membership', function () {
        $member = Member::factory()->create();
        $tracking = MembershipExpiryTracking::factory()->create([
            'member_id' => $member->id,
            'status' => 'active'
        ]);
        $newExpiryDate = now()->addYear();

        $renewedMember = $this->expiryService->renewMembership($member->id, $newExpiryDate, 100000, 'bank_transfer');

        expect($renewedMember->membership_end->format('Y-m-d'))->toBe($newExpiryDate->format('Y-m-d'));
        expect($renewedMember->status)->toBe('active');

        $tracking->refresh();
        expect($tracking->status)->toBe('renewed');
    });

    it('can expire membership', function () {
        $member = Member::factory()->create(['status' => 'active']);
        $tracking = MembershipExpiryTracking::factory()->create([
            'member_id' => $member->id,
            'status' => 'active'
        ]);

        $expiredMember = $this->expiryService->expireMembership($member->id);

        expect($expiredMember->status)->toBe('expired');

        $tracking->refresh();
        expect($tracking->status)->toBe('expired');
    });

    it('can send expiry notifications', function () {
        $tracking = MembershipExpiryTracking::factory()->create([
            'expiry_date' => now()->addDays(3),
            'notification_sent_3_days' => false
        ]);

        $sentCount = $this->expiryService->sendExpiryNotifications(3);

        expect($sentCount)->toBe(1);

        $tracking->refresh();
        expect($tracking->notification_sent_3_days)->toBeTrue();
    });

    it('can process expired memberships', function () {
        $member = Member::factory()->create([
            'status' => 'active',
            'membership_end' => now()->subDay()
        ]);

        $processedCount = $this->expiryService->processExpiredMemberships();

        expect($processedCount)->toBe(1);

        $member->refresh();
        expect($member->status)->toBe('expired');
    });

    it('can get expiring memberships', function () {
        MembershipExpiryTracking::factory()->count(3)->create([
            'expiry_date' => now()->addDays(5)
        ]);

        $expiringMemberships = $this->expiryService->getExpiringMemberships(7);

        expect($expiringMemberships)->toHaveCount(3);
    });

    it('can get expiry statistics', function () {
        MembershipExpiryTracking::factory()->count(5)->create();
        actingAsAdmin();

        $response = apiGet('/api/v1/admin/expiry/stats');

        assertApiSuccess($response, 'Expiry statistics retrieved successfully');
        expect($response->json('data.total_trackings'))->toBe(5);
    });

    it('cannot renew membership with active bookings', function () {
        $member = Member::factory()->create();
        $member->bookings()->create([
            'session_id' => 1,
            'booking_date' => now()->addDay(),
            'status' => 'confirmed'
        ]);
        $tracking = MembershipExpiryTracking::factory()->create([
            'member_id' => $member->id,
            'status' => 'active'
        ]);

        expect(function () use ($member) {
            $this->expiryService->renewMembership($member->id, now()->addYear());
        })->toThrow(Exception::class, 'Membership cannot be renewed');
    });
});
```

## ✅ Success Criteria

-   [x] Expiry date tracking berfungsi
-   [x] Expiry notifications berjalan
-   [x] Expiry processing berfungsi
-   [x] Membership renewal berjalan
-   [x] Expiry analytics berfungsi
-   [x] Expiry automation berjalan
-   [x] Testing coverage > 90%

## 📚 Documentation

-   [Laravel Jobs](https://laravel.com/docs/11.x/queues)
-   [Laravel Database Transactions](https://laravel.com/docs/11.x/database#database-transactions)
-   [Laravel Events](https://laravel.com/docs/11.x/events)
