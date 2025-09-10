# Point 2: Dynamic Quota Management

## 📋 Overview

Implementasi sistem manajemen quota dinamis dengan dynamic quota configuration, quota calculation logic, dan quota allocation system.

## 🎯 Objectives

-   Dynamic quota configuration
-   Quota calculation logic
-   Quota allocation system
-   Quota override mechanisms
-   Quota history tracking
-   Quota analytics

## 📁 Files Structure

```
phase-5/
├── 02-quota-management.md
├── app/Http/Controllers/QuotaController.php
├── app/Models/MemberQuota.php
├── app/Services/QuotaService.php
└── app/Repositories/QuotaRepository.php
```

## 🔧 Implementation Steps

### Step 1: Create Member Quota Models

#### MemberQuotaConfig Model

```php
<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class MemberQuotaConfig extends Model
{
    use HasFactory;

    protected $fillable = [
        'membership_type',
        'max_quota',
        'daily_limit',
        'additional_session_cost',
        'is_active',
        'created_by',
        'notes',
    ];

    protected $casts = [
        'max_quota' => 'integer',
        'daily_limit' => 'integer',
        'additional_session_cost' => 'decimal:2',
        'is_active' => 'boolean',
    ];

    public function createdBy()
    {
        return $this->belongsTo(User::class, 'created_by');
    }

    public function members()
    {
        return $this->hasMany(Member::class, 'membership_type', 'membership_type');
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

    public function scopeActive($query)
    {
        return $query->where('is_active', true);
    }

    public function scopeByMembershipType($query, $type)
    {
        return $query->where('membership_type', $type);
    }
}
```

#### MemberQuotaHistory Model

```php
<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class MemberQuotaHistory extends Model
{
    use HasFactory;

    protected $fillable = [
        'member_id',
        'quota_used',
        'quota_remaining',
        'reason',
        'booking_id',
        'notes',
        'created_by',
    ];

    protected $casts = [
        'quota_used' => 'integer',
        'quota_remaining' => 'integer',
    ];

    public function member()
    {
        return $this->belongsTo(Member::class);
    }

    public function booking()
    {
        return $this->belongsTo(Booking::class);
    }

    public function createdBy()
    {
        return $this->belongsTo(User::class, 'created_by');
    }

    public function getReasonDisplayAttribute()
    {
        return match($this->reason) {
            'membership_created' => 'Membership Created',
            'booking_created' => 'Booking Created',
            'booking_cancelled' => 'Booking Cancelled',
            'quota_adjusted' => 'Quota Adjusted',
            'membership_renewed' => 'Membership Renewed',
            'admin_override' => 'Admin Override',
            default => 'Unknown'
        };
    }

    public function scopeByMember($query, $memberId)
    {
        return $query->where('member_id', $memberId);
    }

    public function scopeByReason($query, $reason)
    {
        return $query->where('reason', $reason);
    }

    public function scopeByDateRange($query, $startDate, $endDate)
    {
        return $query->whereBetween('created_at', [$startDate, $endDate]);
    }
}
```

### Step 2: Create Quota Service

```php
<?php

namespace App\Services;

use App\Models\Member;
use App\Models\MemberQuotaConfig;
use App\Models\MemberQuotaHistory;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;
use Carbon\Carbon;

class QuotaService
{
    public function createQuotaConfig($data)
    {
        return DB::transaction(function () use ($data) {
            // Deactivate existing config for this membership type
            MemberQuotaConfig::where('membership_type', $data['membership_type'])
                ->update(['is_active' => false]);

            // Create new config
            $quotaConfig = MemberQuotaConfig::create([
                'membership_type' => $data['membership_type'],
                'max_quota' => $data['max_quota'],
                'daily_limit' => $data['daily_limit'] ?? 1,
                'additional_session_cost' => $data['additional_session_cost'] ?? 0,
                'is_active' => true,
                'created_by' => auth()->id(),
                'notes' => $data['notes'] ?? null,
            ]);

            // Update existing members of this type
            $this->updateExistingMembersQuota($data['membership_type'], $data['max_quota']);

            Log::info('Quota configuration created', [
                'config_id' => $quotaConfig->id,
                'membership_type' => $data['membership_type'],
                'max_quota' => $data['max_quota'],
                'created_by' => auth()->id(),
            ]);

            return $quotaConfig;
        });
    }

    public function updateQuotaConfig($configId, $data)
    {
        return DB::transaction(function () use ($configId, $data) {
            $quotaConfig = MemberQuotaConfig::findOrFail($configId);
            $oldQuota = $quotaConfig->max_quota;

            $quotaConfig->update($data);

            // If quota changed, update existing members
            if (isset($data['max_quota']) && $oldQuota != $data['max_quota']) {
                $this->updateExistingMembersQuota($quotaConfig->membership_type, $data['max_quota']);
            }

            Log::info('Quota configuration updated', [
                'config_id' => $quotaConfig->id,
                'old_quota' => $oldQuota,
                'new_quota' => $data['max_quota'] ?? $oldQuota,
                'updated_by' => auth()->id(),
            ]);

            return $quotaConfig;
        });
    }

    public function adjustMemberQuota($memberId, $newQuota, $reason = 'admin_override')
    {
        return DB::transaction(function () use ($memberId, $newQuota, $reason) {
            $member = Member::findOrFail($memberId);
            $oldQuota = $member->quota_remaining;

            // Calculate quota difference
            $quotaDifference = $newQuota - $oldQuota;

            // Update member quota
            $member->quota_remaining = $newQuota;
            $member->save();

            // Record quota adjustment in history
            $member->quotaHistory()->create([
                'quota_used' => 0,
                'quota_remaining' => $newQuota,
                'reason' => $reason,
                'notes' => "Quota adjusted from {$oldQuota} to {$newQuota}",
                'created_by' => auth()->id(),
            ]);

            Log::info('Member quota adjusted', [
                'member_id' => $member->id,
                'old_quota' => $oldQuota,
                'new_quota' => $newQuota,
                'difference' => $quotaDifference,
                'reason' => $reason,
                'adjusted_by' => auth()->id(),
            ]);

            return $member;
        });
    }

    public function useMemberQuota($memberId, $amount = 1, $bookingId = null)
    {
        return DB::transaction(function () use ($memberId, $amount, $bookingId) {
            $member = Member::findOrFail($memberId);

            if ($member->quota_remaining < $amount) {
                throw new \Exception('Insufficient quota remaining');
            }

            $member->useQuota($amount);

            // Update quota history with booking ID
            if ($bookingId) {
                $member->quotaHistory()
                    ->where('reason', 'booking_created')
                    ->whereNull('booking_id')
                    ->latest()
                    ->first()
                    ?->update(['booking_id' => $bookingId]);
            }

            return $member;
        });
    }

    public function restoreMemberQuota($memberId, $amount = 1, $bookingId = null)
    {
        return DB::transaction(function () use ($memberId, $amount, $bookingId) {
            $member = Member::findOrFail($memberId);
            $member->restoreQuota($amount);

            // Update quota history with booking ID
            if ($bookingId) {
                $member->quotaHistory()
                    ->where('reason', 'booking_cancelled')
                    ->whereNull('booking_id')
                    ->latest()
                    ->first()
                    ?->update(['booking_id' => $bookingId]);
            }

            return $member;
        });
    }

    public function getQuotaStats($filters = [])
    {
        $query = Member::query();

        // Apply filters
        if (isset($filters['membership_type'])) {
            $query->where('membership_type', $filters['membership_type']);
        }

        if (isset($filters['start_date']) && isset($filters['end_date'])) {
            $query->whereBetween('joined_date', [$filters['start_date'], $filters['end_date']]);
        }

        $members = $query->get();

        return [
            'total_members' => $members->count(),
            'total_quota_allocated' => $members->sum(function ($member) {
                return $member->quota_used + $member->quota_remaining;
            }),
            'total_quota_used' => $members->sum('quota_used'),
            'total_quota_remaining' => $members->sum('quota_remaining'),
            'average_quota_utilization' => $members->avg('quota_utilization_percentage'),
            'members_with_quota' => $members->where('quota_remaining', '>', 0)->count(),
            'members_without_quota' => $members->where('quota_remaining', '<=', 0)->count(),
            'quota_by_membership_type' => $members->groupBy('membership_type')->map(function ($group) {
                return [
                    'count' => $group->count(),
                    'total_quota' => $group->sum(function ($member) {
                        return $member->quota_used + $member->quota_remaining;
                    }),
                    'used_quota' => $group->sum('quota_used'),
                    'remaining_quota' => $group->sum('quota_remaining'),
                    'utilization_percentage' => $group->avg('quota_utilization_percentage'),
                ];
            }),
        ];
    }

    public function getQuotaAnalytics($filters = [])
    {
        $query = MemberQuotaHistory::query();

        // Apply filters
        if (isset($filters['start_date']) && isset($filters['end_date'])) {
            $query->whereBetween('created_at', [$filters['start_date'], $filters['end_date']]);
        }

        if (isset($filters['member_id'])) {
            $query->where('member_id', $filters['member_id']);
        }

        $history = $query->with(['member'])->get();

        return [
            'quota_usage_trends' => $this->getQuotaUsageTrends($history),
            'quota_reasons' => $this->getQuotaReasons($history),
            'top_quota_users' => $this->getTopQuotaUsers($history),
            'quota_efficiency' => $this->getQuotaEfficiency($history),
        ];
    }

    public function bulkAdjustQuota($memberIds, $newQuota, $reason = 'bulk_adjustment')
    {
        $results = [];

        foreach ($memberIds as $memberId) {
            try {
                $member = $this->adjustMemberQuota($memberId, $newQuota, $reason);
                $results[] = [
                    'member_id' => $memberId,
                    'success' => true,
                    'new_quota' => $member->quota_remaining,
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

    protected function updateExistingMembersQuota($membershipType, $newMaxQuota)
    {
        $members = Member::where('membership_type', $membershipType)->get();

        foreach ($members as $member) {
            $oldQuota = $member->quota_remaining;
            $newQuota = $newMaxQuota - $member->quota_used;

            $member->quota_remaining = max(0, $newQuota);
            $member->save();

            // Record quota adjustment
            $member->quotaHistory()->create([
                'quota_used' => 0,
                'quota_remaining' => $member->quota_remaining,
                'reason' => 'quota_config_updated',
                'notes' => "Quota updated from {$oldQuota} to {$member->quota_remaining} due to config change",
                'created_by' => auth()->id(),
            ]);
        }
    }

    protected function getQuotaUsageTrends($history)
    {
        $trends = [];
        $currentDate = now()->subDays(30);
        $endDate = now();

        while ($currentDate->lte($endDate)) {
            $date = $currentDate->format('Y-m-d');

            $dayStats = [
                'date' => $date,
                'quota_used' => $history->where('reason', 'booking_created')
                    ->whereDate('created_at', $date)
                    ->sum('quota_used'),
                'quota_restored' => $history->where('reason', 'booking_cancelled')
                    ->whereDate('created_at', $date)
                    ->sum('quota_used'),
            ];

            $trends[] = $dayStats;
            $currentDate->addDay();
        }

        return $trends;
    }

    protected function getQuotaReasons($history)
    {
        return $history->groupBy('reason')->map(function ($group) {
            return [
                'reason' => $group->first()->reason,
                'count' => $group->count(),
                'total_quota_affected' => $group->sum('quota_used'),
            ];
        });
    }

    protected function getTopQuotaUsers($history)
    {
        return $history->groupBy('member_id')->map(function ($group) {
            $member = $group->first()->member;
            return [
                'member_id' => $member->id,
                'member_name' => $member->user->name,
                'membership_type' => $member->membership_type,
                'total_quota_used' => $group->where('quota_used', '>', 0)->sum('quota_used'),
                'total_quota_restored' => $group->where('quota_used', '<', 0)->sum('quota_used'),
            ];
        })->sortByDesc('total_quota_used')->take(10);
    }

    protected function getQuotaEfficiency($history)
    {
        $totalQuotaUsed = $history->where('quota_used', '>', 0)->sum('quota_used');
        $totalQuotaRestored = abs($history->where('quota_used', '<', 0)->sum('quota_used'));

        return [
            'total_quota_used' => $totalQuotaUsed,
            'total_quota_restored' => $totalQuotaRestored,
            'net_quota_usage' => $totalQuotaUsed - $totalQuotaRestored,
            'efficiency_rate' => $totalQuotaUsed > 0 ? round((($totalQuotaUsed - $totalQuotaRestored) / $totalQuotaUsed) * 100, 2) : 0,
        ];
    }
}
```

### Step 3: Create Quota Controller

```php
<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Api\BaseController;
use App\Services\QuotaService;
use App\Models\MemberQuotaConfig;
use App\Models\MemberQuotaHistory;
use Illuminate\Http\Request;

class QuotaController extends BaseController
{
    protected $quotaService;

    public function __construct(QuotaService $quotaService)
    {
        $this->quotaService = $quotaService;
    }

    public function getQuotaConfigs()
    {
        try {
            $configs = MemberQuotaConfig::with(['createdBy'])
                ->orderBy('membership_type')
                ->get();

            return $this->successResponse($configs, 'Quota configurations retrieved successfully');
        } catch (\Exception $e) {
            return $this->errorResponse($e->getMessage(), 400);
        }
    }

    public function createQuotaConfig(Request $request)
    {
        $request->validate([
            'membership_type' => 'required|in:regular,premium,vip',
            'max_quota' => 'required|integer|min:1',
            'daily_limit' => 'nullable|integer|min:1',
            'additional_session_cost' => 'nullable|numeric|min:0',
            'notes' => 'nullable|string|max:500',
        ]);

        try {
            $data = $request->validated();
            $config = $this->quotaService->createQuotaConfig($data);

            return $this->successResponse($config, 'Quota configuration created successfully', 201);
        } catch (\Exception $e) {
            return $this->errorResponse($e->getMessage(), 400);
        }
    }

    public function updateQuotaConfig(Request $request, $id)
    {
        $request->validate([
            'max_quota' => 'nullable|integer|min:1',
            'daily_limit' => 'nullable|integer|min:1',
            'additional_session_cost' => 'nullable|numeric|min:0',
            'is_active' => 'nullable|boolean',
            'notes' => 'nullable|string|max:500',
        ]);

        try {
            $data = $request->validated();
            $config = $this->quotaService->updateQuotaConfig($id, $data);

            return $this->successResponse($config, 'Quota configuration updated successfully');
        } catch (\Exception $e) {
            return $this->errorResponse($e->getMessage(), 400);
        }
    }

    public function adjustMemberQuota(Request $request, $memberId)
    {
        $request->validate([
            'new_quota' => 'required|integer|min:0',
            'reason' => 'nullable|string|max:255',
        ]);

        try {
            $member = $this->quotaService->adjustMemberQuota(
                $memberId,
                $request->new_quota,
                $request->reason ?? 'admin_override'
            );

            return $this->successResponse($member, 'Member quota adjusted successfully');
        } catch (\Exception $e) {
            return $this->errorResponse($e->getMessage(), 400);
        }
    }

    public function getQuotaStats(Request $request)
    {
        try {
            $filters = $request->only(['membership_type', 'start_date', 'end_date']);
            $stats = $this->quotaService->getQuotaStats($filters);

            return $this->successResponse($stats, 'Quota statistics retrieved successfully');
        } catch (\Exception $e) {
            return $this->errorResponse($e->getMessage(), 400);
        }
    }

    public function getQuotaAnalytics(Request $request)
    {
        try {
            $filters = $request->only(['start_date', 'end_date', 'member_id']);
            $analytics = $this->quotaService->getQuotaAnalytics($filters);

            return $this->successResponse($analytics, 'Quota analytics retrieved successfully');
        } catch (\Exception $e) {
            return $this->errorResponse($e->getMessage(), 400);
        }
    }

    public function getMemberQuotaHistory(Request $request, $memberId)
    {
        try {
            $history = MemberQuotaHistory::with(['booking', 'createdBy'])
                ->where('member_id', $memberId)
                ->orderBy('created_at', 'desc')
                ->paginate($request->per_page ?? 15);

            return $this->successResponse($history, 'Member quota history retrieved successfully');
        } catch (\Exception $e) {
            return $this->errorResponse($e->getMessage(), 400);
        }
    }

    public function bulkAdjustQuota(Request $request)
    {
        $request->validate([
            'member_ids' => 'required|array|min:1',
            'member_ids.*' => 'exists:members,id',
            'new_quota' => 'required|integer|min:0',
            'reason' => 'nullable|string|max:255',
        ]);

        try {
            $results = $this->quotaService->bulkAdjustQuota(
                $request->member_ids,
                $request->new_quota,
                $request->reason ?? 'bulk_adjustment'
            );

            return $this->successResponse($results, 'Bulk quota adjustment completed');
        } catch (\Exception $e) {
            return $this->errorResponse($e->getMessage(), 400);
        }
    }

    public function getMyQuota()
    {
        try {
            $member = Member::where('user_id', auth()->id())->firstOrFail();

            $quotaInfo = [
                'member_id' => $member->id,
                'membership_type' => $member->membership_type,
                'quota_used' => $member->quota_used,
                'quota_remaining' => $member->quota_remaining,
                'max_quota' => $member->max_quota,
                'utilization_percentage' => $member->quota_utilization_percentage,
                'daily_limit' => $member->daily_limit,
                'additional_session_cost' => $member->additional_session_cost,
                'can_book' => $member->can_book,
            ];

            return $this->successResponse($quotaInfo, 'Quota information retrieved successfully');
        } catch (\Exception $e) {
            return $this->errorResponse($e->getMessage(), 404);
        }
    }
}
```

## 📚 API Endpoints

### Quota Management Endpoints

```
GET    /api/v1/admin/quota/configs
POST   /api/v1/admin/quota/configs
PUT    /api/v1/admin/quota/configs/{id}
POST   /api/v1/admin/quota/members/{id}/adjust
GET    /api/v1/admin/quota/stats
GET    /api/v1/admin/quota/analytics
GET    /api/v1/admin/quota/members/{id}/history
POST   /api/v1/admin/quota/bulk-adjust
GET    /api/v1/members/my-quota
```

## 🧪 Testing

### QuotaTest.php

```php
<?php

use App\Models\Member;
use App\Models\MemberQuotaConfig;
use App\Services\QuotaService;

describe('Dynamic Quota Management', function () {

    beforeEach(function () {
        $this->quotaService = app(QuotaService::class);
    });

    it('can create quota configuration', function () {
        actingAsAdmin();

        $configData = [
            'membership_type' => 'regular',
            'max_quota' => 100,
            'daily_limit' => 1,
            'additional_session_cost' => 50000,
        ];

        $response = apiPost('/api/v1/admin/quota/configs', $configData);

        assertApiSuccess($response, 'Quota configuration created successfully');
        $this->assertDatabaseHas('member_quota_configs', [
            'membership_type' => 'regular',
            'max_quota' => 100,
        ]);
    });

    it('can adjust member quota', function () {
        $member = Member::factory()->create(['quota_remaining' => 50]);
        actingAsAdmin();

        $response = apiPost("/api/v1/admin/quota/members/{$member->id}/adjust", [
            'new_quota' => 75,
            'reason' => 'Special promotion'
        ]);

        assertApiSuccess($response, 'Member quota adjusted successfully');
        $this->assertDatabaseHas('members', [
            'id' => $member->id,
            'quota_remaining' => 75,
        ]);
    });

    it('can use member quota', function () {
        $member = Member::factory()->create(['quota_remaining' => 10]);

        $this->quotaService->useMemberQuota($member->id, 2);

        $member->refresh();
        expect($member->quota_remaining)->toBe(8);
        expect($member->quota_used)->toBe(2);
    });

    it('can restore member quota', function () {
        $member = Member::factory()->create(['quota_used' => 5, 'quota_remaining' => 5]);

        $this->quotaService->restoreMemberQuota($member->id, 2);

        $member->refresh();
        expect($member->quota_remaining)->toBe(7);
        expect($member->quota_used)->toBe(3);
    });

    it('cannot use more quota than available', function () {
        $member = Member::factory()->create(['quota_remaining' => 1]);

        expect(function () use ($member) {
            $this->quotaService->useMemberQuota($member->id, 2);
        })->toThrow(Exception::class, 'Insufficient quota remaining');
    });

    it('can get quota statistics', function () {
        Member::factory()->count(5)->create();
        actingAsAdmin();

        $response = apiGet('/api/v1/admin/quota/stats');

        assertApiSuccess($response, 'Quota statistics retrieved successfully');
        expect($response->json('data.total_members'))->toBe(5);
    });
});
```

## ✅ Success Criteria

-   [x] Dynamic quota configuration berfungsi
-   [x] Quota calculation logic berjalan
-   [x] Quota allocation system berfungsi
-   [x] Quota override mechanisms berjalan
-   [x] Quota history tracking berfungsi
-   [x] Quota analytics berjalan
-   [x] Testing coverage > 90%

## 📚 Documentation

-   [Laravel Eloquent Models](https://laravel.com/docs/11.x/eloquent)
-   [Laravel Database Transactions](https://laravel.com/docs/11.x/database#database-transactions)
-   [Laravel Collections](https://laravel.com/docs/11.x/collections)
