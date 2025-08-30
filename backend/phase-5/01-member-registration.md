# Point 1: Member Registration System

## 📋 Overview

Implementasi sistem registrasi member dengan member registration workflow, member profile management, dan member validation rules.

## 🎯 Objectives

- Member registration workflow
- Member profile management
- Member validation rules
- Member status management
- Member conversion from guest
- Member analytics

## 📁 Files Structure

```
phase-5/
├── 01-member-registration.md
├── app/Http/Controllers/MemberController.php
├── app/Models/Member.php
├── app/Services/MemberService.php
├── app/Jobs/ProcessMemberRegistrationJob.php
└── app/Http/Requests/MemberRequest.php
```

## 🔧 Implementation Steps

### Step 1: Create Member Model

```php
<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Carbon\Carbon;

class Member extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id',
        'membership_number',
        'membership_type',
        'status',
        'joined_date',
        'membership_start',
        'membership_end',
        'quota_used',
        'quota_remaining',
        'daily_usage_count',
        'last_usage_date',
        'total_bookings',
        'total_amount_spent',
        'is_premium',
        'notes',
        'created_by',
        'updated_by',
    ];

    protected $casts = [
        'joined_date' => 'date',
        'membership_start' => 'date',
        'membership_end' => 'date',
        'last_usage_date' => 'date',
        'total_amount_spent' => 'decimal:2',
        'is_premium' => 'boolean',
    ];

    public function user()
    {
        return $this->belongsTo(User::class);
    }

    public function createdBy()
    {
        return $this->belongsTo(User::class, 'created_by');
    }

    public function updatedBy()
    {
        return $this->belongsTo(User::class, 'updated_by');
    }

    public function bookings()
    {
        return $this->hasMany(Booking::class, 'user_id', 'user_id');
    }

    public function quotaHistory()
    {
        return $this->hasMany(MemberQuotaHistory::class);
    }

    public function dailyUsage()
    {
        return $this->hasMany(MemberDailyUsageTracking::class);
    }

    public function expiryTracking()
    {
        return $this->hasOne(MembershipExpiryTracking::class);
    }

    public function queueEntry()
    {
        return $this->hasOne(MemberQueue::class, 'user_id', 'user_id');
    }

    public function getStatusDisplayAttribute()
    {
        return match($this->status) {
            'active' => 'Active',
            'inactive' => 'Inactive',
            'suspended' => 'Suspended',
            'expired' => 'Expired',
            default => 'Unknown'
        };
    }

    public function getMembershipTypeDisplayAttribute()
    {
        return match($this->membership_type) {
            'regular' => 'Regular Member',
            'premium' => 'Premium Member',
            'vip' => 'VIP Member',
            default => 'Unknown'
        };
    }

    public function getIsActiveAttribute()
    {
        return $this->status === 'active';
    }

    public function getIsInactiveAttribute()
    {
        return $this->status === 'inactive';
    }

    public function getIsSuspendedAttribute()
    {
        return $this->status === 'suspended';
    }

    public function getIsExpiredAttribute()
    {
        return $this->status === 'expired';
    }

    public function getIsExpiringSoonAttribute()
    {
        return $this->membership_end->diffInDays(now()) <= 7;
    }

    public function getDaysUntilExpiryAttribute()
    {
        return $this->membership_end->diffInDays(now());
    }

    public function getMembershipDurationAttribute()
    {
        return $this->membership_start->diffInDays($this->membership_end);
    }

    public function getQuotaUtilizationPercentageAttribute()
    {
        $totalQuota = $this->quota_used + $this->quota_remaining;
        return $totalQuota > 0 ? round(($this->quota_used / $totalQuota) * 100, 2) : 0;
    }

    public function getCanBookAttribute()
    {
        return $this->is_active &&
               $this->quota_remaining > 0 &&
               !$this->is_expired &&
               $this->daily_usage_count < $this->getDailyLimit();
    }

    public function getDailyLimitAttribute()
    {
        $quotaConfig = MemberQuotaConfig::where('membership_type', $this->membership_type)
            ->where('is_active', true)
            ->first();

        return $quotaConfig ? $quotaConfig->daily_limit : 1;
    }

    public function getAdditionalSessionCostAttribute()
    {
        $quotaConfig = MemberQuotaConfig::where('membership_type', $this->membership_type)
            ->where('is_active', true)
            ->first();

        return $quotaConfig ? $quotaConfig->additional_session_cost : 0;
    }

    public function getMaxQuotaAttribute()
    {
        $quotaConfig = MemberQuotaConfig::where('membership_type', $this->membership_type)
            ->where('is_active', true)
            ->first();

        return $quotaConfig ? $quotaConfig->max_quota : 0;
    }

    public function generateMembershipNumber()
    {
        $prefix = match($this->membership_type) {
            'regular' => 'REG',
            'premium' => 'PRM',
            'vip' => 'VIP',
            default => 'MEM'
        };

        $year = now()->format('Y');
        $month = now()->format('m');
        $random = str_pad(rand(1, 9999), 4, '0', STR_PAD_LEFT);

        return $prefix . $year . $month . $random;
    }

    public function useQuota($amount = 1)
    {
        if ($this->quota_remaining < $amount) {
            throw new \Exception('Insufficient quota remaining');
        }

        $this->quota_used += $amount;
        $this->quota_remaining -= $amount;
        $this->save();

        // Record quota usage in history
        $this->quotaHistory()->create([
            'quota_used' => $amount,
            'quota_remaining' => $this->quota_remaining,
            'reason' => 'booking_created',
            'booking_id' => null, // Will be updated when booking is created
        ]);
    }

    public function restoreQuota($amount = 1)
    {
        $this->quota_used = max(0, $this->quota_used - $amount);
        $this->quota_remaining += $amount;
        $this->save();

        // Record quota restoration in history
        $this->quotaHistory()->create([
            'quota_used' => -$amount,
            'quota_remaining' => $this->quota_remaining,
            'reason' => 'booking_cancelled',
            'booking_id' => null,
        ]);
    }

    public function updateDailyUsage($count = 1)
    {
        $today = now()->toDateString();

        if ($this->last_usage_date !== $today) {
            $this->daily_usage_count = 0;
        }

        $this->daily_usage_count += $count;
        $this->last_usage_date = $today;
        $this->save();
    }

    public function resetDailyUsage()
    {
        $this->daily_usage_count = 0;
        $this->save();
    }

    public function hasActiveBookings()
    {
        return $this->bookings()
            ->whereIn('status', ['pending', 'confirmed'])
            ->exists();
    }

    public function canRenewMembership()
    {
        return $this->is_active && !$this->hasActiveBookings();
    }

    public function renewMembership($newEndDate)
    {
        if (!$this->canRenewMembership()) {
            throw new \Exception('Membership cannot be renewed');
        }

        $this->membership_end = $newEndDate;
        $this->status = 'active';
        $this->save();

        // Update expiry tracking
        if ($this->expiryTracking) {
            $this->expiryTracking->update([
                'expiry_date' => $newEndDate,
                'status' => 'active',
                'renewal_date' => now()->toDateString(),
            ]);
        }

        return $this;
    }

    public function suspend($reason = null)
    {
        $this->status = 'suspended';
        $this->notes = $reason;
        $this->save();

        return $this;
    }

    public function activate()
    {
        $this->status = 'active';
        $this->save();

        return $this;
    }

    public function expire()
    {
        $this->status = 'expired';
        $this->save();

        // Update expiry tracking
        if ($this->expiryTracking) {
            $this->expiryTracking->update([
                'status' => 'expired',
            ]);
        }

        return $this;
    }

    public function scopeActive($query)
    {
        return $query->where('status', 'active');
    }

    public function scopeInactive($query)
    {
        return $query->where('status', 'inactive');
    }

    public function scopeSuspended($query)
    {
        return $query->where('status', 'suspended');
    }

    public function scopeExpired($query)
    {
        return $query->where('status', 'expired');
    }

    public function scopeByMembershipType($query, $type)
    {
        return $query->where('membership_type', $type);
    }

    public function scopeExpiringSoon($query, $days = 7)
    {
        return $query->where('membership_end', '<=', now()->addDays($days))
            ->where('membership_end', '>', now());
    }

    public function scopeExpired($query)
    {
        return $query->where('membership_end', '<', now());
    }

    public function scopeByDateRange($query, $startDate, $endDate)
    {
        return $query->whereBetween('joined_date', [$startDate, $endDate]);
    }

    public function scopeWithQuota($query)
    {
        return $query->where('quota_remaining', '>', 0);
    }

    public function scopeWithoutQuota($query)
    {
        return $query->where('quota_remaining', '<=', 0);
    }

    public function scopePremium($query)
    {
        return $query->where('is_premium', true);
    }

    public function scopeRegular($query)
    {
        return $query->where('is_premium', false);
    }
}
```

### Step 2: Create Member Service

```php
<?php

namespace App\Services;

use App\Models\Member;
use App\Models\User;
use App\Models\MemberQuotaConfig;
use App\Models\MembershipExpiryTracking;
use App\Jobs\ProcessMemberRegistrationJob;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;
use Carbon\Carbon;

class MemberService
{
    public function registerMember($data)
    {
        return DB::transaction(function () use ($data) {
            $user = User::findOrFail($data['user_id']);

            // Check if user is already a member
            if ($user->member) {
                throw new \Exception('User is already a member');
            }

            // Validate membership type
            $this->validateMembershipType($data['membership_type']);

            // Get quota configuration
            $quotaConfig = $this->getQuotaConfig($data['membership_type']);

            // Create member
            $member = Member::create([
                'user_id' => $user->id,
                'membership_number' => $this->generateUniqueMembershipNumber($data['membership_type']),
                'membership_type' => $data['membership_type'],
                'status' => 'active',
                'joined_date' => now()->toDateString(),
                'membership_start' => $data['membership_start'] ?? now()->toDateString(),
                'membership_end' => $data['membership_end'] ?? now()->addYear()->toDateString(),
                'quota_used' => 0,
                'quota_remaining' => $quotaConfig->max_quota,
                'daily_usage_count' => 0,
                'total_bookings' => 0,
                'total_amount_spent' => 0,
                'is_premium' => $data['membership_type'] !== 'regular',
                'notes' => $data['notes'] ?? null,
                'created_by' => auth()->id(),
            ]);

            // Create expiry tracking
            MembershipExpiryTracking::create([
                'member_id' => $member->id,
                'expiry_date' => $member->membership_end,
                'status' => 'active',
            ]);

            // Dispatch registration job
            ProcessMemberRegistrationJob::dispatch($member);

            // Log registration
            Log::info('Member registered', [
                'member_id' => $member->id,
                'user_id' => $user->id,
                'membership_type' => $data['membership_type'],
                'membership_number' => $member->membership_number,
            ]);

            return $member;
        });
    }

    public function updateMember($memberId, $data)
    {
        return DB::transaction(function () use ($memberId, $data) {
            $member = Member::findOrFail($memberId);

            // Validate membership type if changed
            if (isset($data['membership_type']) && $data['membership_type'] !== $member->membership_type) {
                $this->validateMembershipType($data['membership_type']);

                // Update quota if membership type changed
                $quotaConfig = $this->getQuotaConfig($data['membership_type']);
                $data['quota_remaining'] = $quotaConfig->max_quota - $member->quota_used;
                $data['is_premium'] = $data['membership_type'] !== 'regular';
            }

            $data['updated_by'] = auth()->id();
            $member->update($data);

            // Update expiry tracking if membership end date changed
            if (isset($data['membership_end']) && $member->expiryTracking) {
                $member->expiryTracking->update([
                    'expiry_date' => $data['membership_end'],
                ]);
            }

            Log::info('Member updated', [
                'member_id' => $member->id,
                'updated_by' => auth()->id(),
            ]);

            return $member;
        });
    }

    public function suspendMember($memberId, $reason = null)
    {
        $member = Member::findOrFail($memberId);

        if ($member->hasActiveBookings()) {
            throw new \Exception('Cannot suspend member with active bookings');
        }

        $member->suspend($reason);

        Log::info('Member suspended', [
            'member_id' => $member->id,
            'reason' => $reason,
            'suspended_by' => auth()->id(),
        ]);

        return $member;
    }

    public function activateMember($memberId)
    {
        $member = Member::findOrFail($memberId);
        $member->activate();

        Log::info('Member activated', [
            'member_id' => $member->id,
            'activated_by' => auth()->id(),
        ]);

        return $member;
    }

    public function expireMember($memberId)
    {
        $member = Member::findOrFail($memberId);
        $member->expire();

        Log::info('Member expired', [
            'member_id' => $member->id,
            'expired_by' => auth()->id(),
        ]);

        return $member;
    }

    public function renewMembership($memberId, $newEndDate)
    {
        $member = Member::findOrFail($memberId);
        $member->renewMembership($newEndDate);

        Log::info('Membership renewed', [
            'member_id' => $member->id,
            'new_end_date' => $newEndDate,
            'renewed_by' => auth()->id(),
        ]);

        return $member;
    }

    public function convertGuestToMember($userId, $membershipData)
    {
        return DB::transaction(function () use ($userId, $membershipData) {
            $user = User::findOrFail($userId);

            if ($user->member) {
                throw new \Exception('User is already a member');
            }

            // Get guest user data
            $guestUser = $user->guestUser;
            if (!$guestUser) {
                throw new \Exception('User is not a guest user');
            }

            // Register as member
            $memberData = array_merge($membershipData, ['user_id' => $userId]);
            $member = $this->registerMember($memberData);

            // Update user role
            $user->update(['role' => 'member']);

            // Archive guest user data
            $guestUser->update(['status' => 'converted']);

            Log::info('Guest converted to member', [
                'user_id' => $userId,
                'member_id' => $member->id,
                'converted_by' => auth()->id(),
            ]);

            return $member;
        });
    }

    public function getMemberStats($filters = [])
    {
        $query = Member::query();

        // Apply filters
        if (isset($filters['start_date']) && isset($filters['end_date'])) {
            $query->whereBetween('joined_date', [$filters['start_date'], $filters['end_date']]);
        }

        if (isset($filters['membership_type'])) {
            $query->where('membership_type', $filters['membership_type']);
        }

        if (isset($filters['status'])) {
            $query->where('status', $filters['status']);
        }

        $stats = [
            'total_members' => $query->count(),
            'active_members' => $query->clone()->where('status', 'active')->count(),
            'inactive_members' => $query->clone()->where('status', 'inactive')->count(),
            'suspended_members' => $query->clone()->where('status', 'suspended')->count(),
            'expired_members' => $query->clone()->where('status', 'expired')->count(),
            'expiring_soon' => $query->clone()->expiringSoon()->count(),
            'total_revenue' => $query->clone()->sum('total_amount_spent'),
            'average_revenue_per_member' => $query->clone()->avg('total_amount_spent'),
            'membership_types' => $query->clone()->selectRaw('membership_type, COUNT(*) as count')
                ->groupBy('membership_type')
                ->get(),
        ];

        return $stats;
    }

    public function getMemberAnalytics($filters = [])
    {
        $query = Member::query();

        // Apply filters
        if (isset($filters['start_date']) && isset($filters['end_date'])) {
            $query->whereBetween('joined_date', [$filters['start_date'], $filters['end_date']]);
        }

        $analytics = [
            'member_growth' => $this->getMemberGrowthTrends($query->clone()),
            'membership_type_distribution' => $this->getMembershipTypeDistribution($query->clone()),
            'quota_utilization' => $this->getQuotaUtilizationStats($query->clone()),
            'revenue_analytics' => $this->getRevenueAnalytics($query->clone()),
            'retention_analytics' => $this->getRetentionAnalytics($query->clone()),
        ];

        return $analytics;
    }

    public function processExpiredMemberships()
    {
        $expiredMembers = Member::where('status', 'active')
            ->where('membership_end', '<', now())
            ->get();

        $processedCount = 0;

        foreach ($expiredMembers as $member) {
            try {
                $member->expire();
                $processedCount++;
            } catch (\Exception $e) {
                Log::error('Failed to expire member', [
                    'member_id' => $member->id,
                    'error' => $e->getMessage(),
                ]);
            }
        }

        return $processedCount;
    }

    protected function validateMembershipType($membershipType)
    {
        $validTypes = ['regular', 'premium', 'vip'];
        if (!in_array($membershipType, $validTypes)) {
            throw new \Exception('Invalid membership type');
        }
    }

    protected function getQuotaConfig($membershipType)
    {
        $quotaConfig = MemberQuotaConfig::where('membership_type', $membershipType)
            ->where('is_active', true)
            ->first();

        if (!$quotaConfig) {
            throw new \Exception('No quota configuration found for membership type: ' . $membershipType);
        }

        return $quotaConfig;
    }

    protected function generateUniqueMembershipNumber($membershipType)
    {
        do {
            $member = new Member();
            $member->membership_type = $membershipType;
            $membershipNumber = $member->generateMembershipNumber();
        } while (Member::where('membership_number', $membershipNumber)->exists());

        return $membershipNumber;
    }

    protected function getMemberGrowthTrends($query)
    {
        $startDate = now()->subDays(30);
        $endDate = now();

        $trends = [];
        $currentDate = $startDate->copy();

        while ($currentDate->lte($endDate)) {
            $date = $currentDate->format('Y-m-d');

            $dayStats = [
                'date' => $date,
                'new_members' => $query->clone()->whereDate('joined_date', $date)->count(),
                'total_members' => $query->clone()->where('joined_date', '<=', $date)->count(),
            ];

            $trends[] = $dayStats;
            $currentDate->addDay();
        }

        return $trends;
    }

    protected function getMembershipTypeDistribution($query)
    {
        return $query->selectRaw('membership_type, COUNT(*) as count, SUM(total_amount_spent) as total_revenue')
            ->groupBy('membership_type')
            ->get();
    }

    protected function getQuotaUtilizationStats($query)
    {
        $members = $query->get();

        return [
            'average_utilization' => $members->avg('quota_utilization_percentage'),
            'high_utilization' => $members->where('quota_utilization_percentage', '>', 80)->count(),
            'low_utilization' => $members->where('quota_utilization_percentage', '<', 20)->count(),
            'no_quota_remaining' => $members->where('quota_remaining', 0)->count(),
        ];
    }

    protected function getRevenueAnalytics($query)
    {
        $members = $query->get();

        return [
            'total_revenue' => $members->sum('total_amount_spent'),
            'average_revenue' => $members->avg('total_amount_spent'),
            'top_spenders' => $members->sortByDesc('total_amount_spent')->take(10),
            'revenue_by_type' => $members->groupBy('membership_type')->map(function ($group) {
                return [
                    'count' => $group->count(),
                    'total_revenue' => $group->sum('total_amount_spent'),
                    'average_revenue' => $group->avg('total_amount_spent'),
                ];
            }),
        ];
    }

    protected function getRetentionAnalytics($query)
    {
        $members = $query->get();
        $activeMembers = $members->where('status', 'active');
        $expiredMembers = $members->where('status', 'expired');

        return [
            'retention_rate' => $members->count() > 0 ? round(($activeMembers->count() / $members->count()) * 100, 2) : 0,
            'churn_rate' => $members->count() > 0 ? round(($expiredMembers->count() / $members->count()) * 100, 2) : 0,
            'average_membership_duration' => $members->avg('membership_duration'),
        ];
    }
}
```

### Step 3: Create Member Controller

```php
<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Api\BaseController;
use App\Http\Requests\MemberRequest;
use App\Services\MemberService;
use App\Models\Member;
use Illuminate\Http\Request;

class MemberController extends BaseController
{
    protected $memberService;

    public function __construct(MemberService $memberService)
    {
        $this->memberService = $memberService;
    }

    public function index(Request $request)
    {
        $query = Member::with(['user', 'expiryTracking']);

        // Filter by status
        if ($request->status) {
            $query->where('status', $request->status);
        }

        // Filter by membership type
        if ($request->membership_type) {
            $query->where('membership_type', $request->membership_type);
        }

        // Filter by date range
        if ($request->start_date && $request->end_date) {
            $query->whereBetween('joined_date', [$request->start_date, $request->end_date]);
        }

        // Filter by expiring soon
        if ($request->expiring_soon) {
            $query->expiringSoon($request->expiring_soon);
        }

        $members = $query->orderBy('joined_date', 'desc')->paginate($request->per_page ?? 15);

        return $this->successResponse($members, 'Members retrieved successfully');
    }

    public function store(MemberRequest $request)
    {
        try {
            $data = $request->validated();
            $member = $this->memberService->registerMember($data);

            return $this->successResponse($member->load(['user', 'expiryTracking']), 'Member registered successfully', 201);
        } catch (\Exception $e) {
            return $this->errorResponse($e->getMessage(), 400);
        }
    }

    public function show($id)
    {
        try {
            $member = Member::with(['user', 'expiryTracking', 'quotaHistory', 'dailyUsage'])
                ->findOrFail($id);

            return $this->successResponse($member, 'Member retrieved successfully');
        } catch (\Exception $e) {
            return $this->errorResponse($e->getMessage(), 404);
        }
    }

    public function update(MemberRequest $request, $id)
    {
        try {
            $data = $request->validated();
            $member = $this->memberService->updateMember($id, $data);

            return $this->successResponse($member->load(['user', 'expiryTracking']), 'Member updated successfully');
        } catch (\Exception $e) {
            return $this->errorResponse($e->getMessage(), 400);
        }
    }

    public function destroy($id)
    {
        try {
            $member = Member::findOrFail($id);

            if ($member->hasActiveBookings()) {
                return $this->errorResponse('Cannot delete member with active bookings', 422);
            }

            $member->delete();

            return $this->successResponse(null, 'Member deleted successfully');
        } catch (\Exception $e) {
            return $this->errorResponse($e->getMessage(), 400);
        }
    }

    public function suspend(Request $request, $id)
    {
        $request->validate([
            'reason' => 'nullable|string|max:500',
        ]);

        try {
            $member = $this->memberService->suspendMember($id, $request->reason);

            return $this->successResponse($member, 'Member suspended successfully');
        } catch (\Exception $e) {
            return $this->errorResponse($e->getMessage(), 400);
        }
    }

    public function activate($id)
    {
        try {
            $member = $this->memberService->activateMember($id);

            return $this->successResponse($member, 'Member activated successfully');
        } catch (\Exception $e) {
            return $this->errorResponse($e->getMessage(), 400);
        }
    }

    public function expire($id)
    {
        try {
            $member = $this->memberService->expireMember($id);

            return $this->successResponse($member, 'Member expired successfully');
        } catch (\Exception $e) {
            return $this->errorResponse($e->getMessage(), 400);
        }
    }

    public function renew(Request $request, $id)
    {
        $request->validate([
            'new_end_date' => 'required|date|after:today',
        ]);

        try {
            $member = $this->memberService->renewMembership($id, $request->new_end_date);

            return $this->successResponse($member, 'Membership renewed successfully');
        } catch (\Exception $e) {
            return $this->errorResponse($e->getMessage(), 400);
        }
    }

    public function convertGuest(Request $request, $userId)
    {
        $request->validate([
            'membership_type' => 'required|in:regular,premium,vip',
            'membership_start' => 'nullable|date',
            'membership_end' => 'required|date|after:membership_start',
            'notes' => 'nullable|string|max:500',
        ]);

        try {
            $data = $request->validated();
            $member = $this->memberService->convertGuestToMember($userId, $data);

            return $this->successResponse($member->load(['user', 'expiryTracking']), 'Guest converted to member successfully', 201);
        } catch (\Exception $e) {
            return $this->errorResponse($e->getMessage(), 400);
        }
    }

    public function getStats(Request $request)
    {
        try {
            $filters = $request->only(['start_date', 'end_date', 'membership_type', 'status']);
            $stats = $this->memberService->getMemberStats($filters);

            return $this->successResponse($stats, 'Member statistics retrieved successfully');
        } catch (\Exception $e) {
            return $this->errorResponse($e->getMessage(), 400);
        }
    }

    public function getAnalytics(Request $request)
    {
        try {
            $filters = $request->only(['start_date', 'end_date']);
            $analytics = $this->memberService->getMemberAnalytics($filters);

            return $this->successResponse($analytics, 'Member analytics retrieved successfully');
        } catch (\Exception $e) {
            return $this->errorResponse($e->getMessage(), 400);
        }
    }

    public function processExpiredMemberships()
    {
        try {
            $processedCount = $this->memberService->processExpiredMemberships();

            return $this->successResponse([
                'processed_count' => $processedCount,
            ], 'Expired memberships processed successfully');
        } catch (\Exception $e) {
            return $this->errorResponse($e->getMessage(), 400);
        }
    }

    public function getMyProfile()
    {
        try {
            $member = Member::with(['user', 'expiryTracking', 'quotaHistory'])
                ->where('user_id', auth()->id())
                ->firstOrFail();

            return $this->successResponse($member, 'Member profile retrieved successfully');
        } catch (\Exception $e) {
            return $this->errorResponse($e->getMessage(), 404);
        }
    }

    public function updateMyProfile(MemberRequest $request)
    {
        try {
            $member = Member::where('user_id', auth()->id())->firstOrFail();
            $data = $request->validated();

            // Remove fields that members cannot update themselves
            unset($data['membership_type'], $data['status'], $data['quota_used'], $data['quota_remaining']);

            $member = $this->memberService->updateMember($member->id, $data);

            return $this->successResponse($member, 'Member profile updated successfully');
        } catch (\Exception $e) {
            return $this->errorResponse($e->getMessage(), 400);
        }
    }
}
```

### Step 4: Create Request Classes

#### MemberRequest

```php
<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class MemberRequest extends FormRequest
{
    public function authorize()
    {
        return true;
    }

    public function rules()
    {
        return [
            'user_id' => ['required', 'exists:users,id'],
            'membership_type' => ['required', 'in:regular,premium,vip'],
            'membership_start' => ['nullable', 'date'],
            'membership_end' => ['required', 'date', 'after:membership_start'],
            'notes' => ['nullable', 'string', 'max:500'],
        ];
    }

    public function messages()
    {
        return [
            'user_id.required' => 'User is required',
            'user_id.exists' => 'Selected user does not exist',
            'membership_type.required' => 'Membership type is required',
            'membership_type.in' => 'Invalid membership type',
            'membership_start.date' => 'Membership start date must be a valid date',
            'membership_end.required' => 'Membership end date is required',
            'membership_end.date' => 'Membership end date must be a valid date',
            'membership_end.after' => 'Membership end date must be after start date',
            'notes.max' => 'Notes cannot exceed 500 characters',
        ];
    }

    public function withValidator($validator)
    {
        $validator->after(function ($validator) {
            // Validate user is not already a member
            if ($this->user_id) {
                $user = \App\Models\User::find($this->user_id);
                if ($user && $user->member) {
                    $validator->errors()->add('user_id', 'User is already a member');
                }
            }
        });
    }
}
```

### Step 5: Create Member Registration Job

```php
<?php

namespace App\Jobs;

use App\Models\Member;
use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Bus\Dispatchable;
use Illuminate\Queue\InteractsWithQueue;
use Illuminate\Queue\SerializesModels;
use Illuminate\Support\Facades\Log;

class ProcessMemberRegistrationJob implements ShouldQueue
{
    use Dispatchable, InteractsWithQueue, Queueable, SerializesModels;

    protected $member;

    public function __construct(Member $member)
    {
        $this->member = $member;
    }

    public function handle()
    {
        try {
            // Send welcome notification
            $this->sendWelcomeNotification($this->member);

            // Create initial quota history record
            $this->member->quotaHistory()->create([
                'quota_used' => 0,
                'quota_remaining' => $this->member->quota_remaining,
                'reason' => 'membership_created',
                'booking_id' => null,
            ]);

            // Update user role
            $this->member->user->update(['role' => 'member']);

            Log::info('Member registration processed', [
                'member_id' => $this->member->id,
                'user_id' => $this->member->user_id,
                'membership_number' => $this->member->membership_number,
            ]);

        } catch (\Exception $e) {
            Log::error('Failed to process member registration', [
                'member_id' => $this->member->id,
                'error' => $e->getMessage(),
            ]);

            throw $e;
        }
    }

    protected function sendWelcomeNotification($member)
    {
        $user = $member->user;

        $message = "Welcome to our membership program!\n";
        $message .= "Membership Number: {$member->membership_number}\n";
        $message .= "Membership Type: {$member->membership_type_display}\n";
        $message .= "Valid Until: {$member->membership_end->format('Y-m-d')}\n";
        $message .= "Quota: {$member->quota_remaining} sessions remaining";

        Log::info('Welcome notification sent', [
            'member_id' => $member->id,
            'user_id' => $user->id,
            'message' => $message,
        ]);
    }
}
```

## 📚 API Endpoints

### Member Registration Endpoints

```
GET    /api/v1/members
POST   /api/v1/members
GET    /api/v1/members/{id}
PUT    /api/v1/members/{id}
DELETE /api/v1/members/{id}
POST   /api/v1/members/{id}/suspend
POST   /api/v1/members/{id}/activate
POST   /api/v1/members/{id}/expire
POST   /api/v1/members/{id}/renew
POST   /api/v1/members/convert-guest/{userId}
GET    /api/v1/members/stats
GET    /api/v1/members/analytics
POST   /api/v1/members/process-expired
GET    /api/v1/members/my-profile
PUT    /api/v1/members/my-profile
```

## 🧪 Testing

### MemberTest.php

```php
<?php

use App\Models\Member;
use App\Models\User;
use App\Models\MemberQuotaConfig;
use App\Services\MemberService;

describe('Member Registration System', function () {

    beforeEach(function () {
        $this->memberService = app(MemberService::class);
    });

    it('can register member', function () {
        $user = User::factory()->create();
        actingAsAdmin();

        $memberData = [
            'user_id' => $user->id,
            'membership_type' => 'regular',
            'membership_start' => now()->toDateString(),
            'membership_end' => now()->addYear()->toDateString(),
        ];

        $response = apiPost('/api/v1/members', $memberData);

        assertApiSuccess($response, 'Member registered successfully');
        $this->assertDatabaseHas('members', [
            'user_id' => $user->id,
            'membership_type' => 'regular',
        ]);
    });

    it('can update member', function () {
        $member = Member::factory()->create();
        actingAsAdmin();

        $updateData = [
            'membership_type' => 'premium',
            'notes' => 'Upgraded to premium',
        ];

        $response = apiPut("/api/v1/members/{$member->id}", $updateData);

        assertApiSuccess($response, 'Member updated successfully');
        $this->assertDatabaseHas('members', [
            'id' => $member->id,
            'membership_type' => 'premium',
        ]);
    });

    it('can suspend member', function () {
        $member = Member::factory()->create();
        actingAsAdmin();

        $response = apiPost("/api/v1/members/{$member->id}/suspend", [
            'reason' => 'Policy violation'
        ]);

        assertApiSuccess($response, 'Member suspended successfully');
        $this->assertDatabaseHas('members', [
            'id' => $member->id,
            'status' => 'suspended',
        ]);
    });

    it('can renew membership', function () {
        $member = Member::factory()->create();
        actingAsAdmin();

        $newEndDate = now()->addYear()->toDateString();

        $response = apiPost("/api/v1/members/{$member->id}/renew", [
            'new_end_date' => $newEndDate
        ]);

        assertApiSuccess($response, 'Membership renewed successfully');
        $this->assertDatabaseHas('members', [
            'id' => $member->id,
            'membership_end' => $newEndDate,
        ]);
    });

    it('can convert guest to member', function () {
        $user = User::factory()->create(['role' => 'guest']);
        actingAsAdmin();

        $conversionData = [
            'membership_type' => 'regular',
            'membership_end' => now()->addYear()->toDateString(),
        ];

        $response = apiPost("/api/v1/members/convert-guest/{$user->id}", $conversionData);

        assertApiSuccess($response, 'Guest converted to member successfully');
        $this->assertDatabaseHas('members', [
            'user_id' => $user->id,
            'membership_type' => 'regular',
        ]);
    });

    it('cannot register duplicate member', function () {
        $user = User::factory()->create();
        Member::factory()->create(['user_id' => $user->id]);
        actingAsAdmin();

        $memberData = [
            'user_id' => $user->id,
            'membership_type' => 'regular',
            'membership_end' => now()->addYear()->toDateString(),
        ];

        $response = apiPost('/api/v1/members', $memberData);

        assertApiError($response, 'User is already a member');
    });
});
```

## ✅ Success Criteria

- [ ] Member registration workflow berfungsi
- [ ] Member profile management berjalan
- [ ] Member validation rules berfungsi
- [ ] Member status management berjalan
- [ ] Member conversion from guest berfungsi
- [ ] Member analytics berjalan
- [ ] Testing coverage > 90%

## 📚 Documentation

- [Laravel Eloquent Models](https://laravel.com/docs/11.x/eloquent)
- [Laravel Database Transactions](https://laravel.com/docs/11.x/database#database-transactions)
- [Laravel Jobs](https://laravel.com/docs/11.x/queues)
