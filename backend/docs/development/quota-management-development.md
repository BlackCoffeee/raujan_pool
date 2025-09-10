# Quota Management Development Guide

## Overview

Dokumentasi ini menjelaskan cara mengembangkan dan memelihara sistem Quota Management di aplikasi Laravel. Sistem ini memungkinkan admin untuk mengelola konfigurasi quota member secara dinamis dan member untuk melihat informasi quota mereka.

## Architecture Overview

### System Components

```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   API Layer     │    │  Service Layer   │    │  Data Layer     │
│                 │    │                  │    │                 │
│ QuotaController │◄──►│  QuotaService    │◄──►│ MemberQuotaConfig│
│                 │    │                  │    │ MemberQuotaHistory│
│ Member Endpoints│    │                  │    │ Member          │
└─────────────────┘    └──────────────────┘    └─────────────────┘
```

### Data Flow

1. **Request** → Controller
2. **Validation** → Request validation rules
3. **Business Logic** → Service layer
4. **Data Access** → Eloquent models
5. **Response** → JSON API response

## Development Setup

### 1. Prerequisites

-   Laravel 12.x
-   PHP 8.2+
-   MySQL/PostgreSQL/SQLite
-   Composer

### 2. Environment Configuration

```bash
# .env
DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=raujan_pool
DB_USERNAME=root
DB_PASSWORD=

# Testing
DB_CONNECTION=sqlite
DB_DATABASE=:memory:
```

### 3. Dependencies

```bash
# Install dependencies
composer install

# Generate application key
php artisan key:generate

# Run migrations
php artisan migrate

# Seed database (if needed)
php artisan db:seed
```

## Code Structure

### Models

#### MemberQuotaConfig

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

    // Relationships
    public function createdBy()
    {
        return $this->belongsTo(User::class, 'created_by');
    }

    public function members()
    {
        return $this->hasMany(Member::class, 'membership_type', 'membership_type');
    }

    // Scopes
    public function scopeActive($query)
    {
        return $query->where('is_active', true);
    }

    public function scopeByMembershipType($query, $type)
    {
        return $query->where('membership_type', $type);
    }

    // Accessors
    public function getMembershipTypeDisplayAttribute()
    {
        return match($this->membership_type) {
            'regular' => 'Regular Member',
            'premium' => 'Premium Member',
            'vip' => 'VIP Member',
            default => 'Unknown'
        };
    }
}
```

#### MemberQuotaHistory

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
        'quota_restored',
        'reason',
        'booking_id',
        'notes',
        'created_by',
    ];

    protected $casts = [
        'quota_used' => 'integer',
        'quota_restored' => 'integer',
    ];

    // Relationships
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

    // Scopes
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

    // Accessors
    public function getReasonDisplayAttribute()
    {
        return match($this->reason) {
            'membership_created' => 'Membership Created',
            'booking_created' => 'Booking Created',
            'booking_cancelled' => 'Booking Cancelled',
            'quota_adjusted' => 'Quota Adjusted',
            'membership_renewed' => 'Membership Renewed',
            'admin_override' => 'Admin Override',
            'quota_config_updated' => 'Quota Config Updated',
            default => 'Unknown'
        };
    }
}
```

### Service Layer

#### QuotaService

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
    /**
     * Create new quota configuration
     */
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
                'created_by' => auth()->id() ?? 1,
                'notes' => $data['notes'] ?? null,
            ]);

            // Update existing members of this type
            $this->updateExistingMembersQuota($data['membership_type'], $data['max_quota']);

            Log::info('Quota configuration created', [
                'config_id' => $quotaConfig->id,
                'membership_type' => $data['membership_type'],
                'max_quota' => $data['max_quota'],
                'created_by' => auth()->id() ?? 1,
            ]);

            return $quotaConfig;
        });
    }

    /**
     * Update existing quota configuration
     */
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
                'updated_by' => auth()->id() ?? 1,
            ]);

            return $quotaConfig;
        });
    }

    /**
     * Adjust member quota manually
     */
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
                'quota_restored' => $quotaDifference > 0 ? $quotaDifference : 0,
                'reason' => $reason,
                'notes' => "Quota adjusted from {$oldQuota} to {$newQuota}",
                'created_by' => auth()->id() ?? 1,
            ]);

            Log::info('Member quota adjusted', [
                'member_id' => $member->id,
                'old_quota' => $oldQuota,
                'new_quota' => $newQuota,
                'difference' => $quotaDifference,
                'reason' => $reason,
                'adjusted_by' => auth()->id() ?? 1,
            ]);

            return $member;
        });
    }

    /**
     * Use member quota
     */
    public function useMemberQuota($memberId, $amount = 1, $bookingId = null)
    {
        return DB::transaction(function () use ($memberId, $amount, $bookingId) {
            $member = Member::findOrFail($memberId);

            if ($member->quota_remaining < $amount) {
                throw new \Exception('Insufficient quota remaining');
            }

            $member->quota_remaining -= $amount;
            $member->quota_used += $amount;
            $member->save();

            // Record quota usage in history
            $member->quotaHistory()->create([
                'quota_used' => $amount,
                'quota_restored' => 0,
                'reason' => 'booking_session',
                'booking_id' => $bookingId,
                'notes' => "Used {$amount} quota for booking",
                'created_by' => auth()->id() ?? 1,
            ]);

            return $member;
        });
    }

    /**
     * Restore member quota
     */
    public function restoreMemberQuota($memberId, $amount = 1, $bookingId = null)
    {
        return DB::transaction(function () use ($memberId, $amount, $bookingId) {
            $member = Member::findOrFail($memberId);

            $member->quota_remaining += $amount;
            $member->quota_used = max(0, $member->quota_used - $amount);
            $member->save();

            // Record quota restoration in history
            $member->quotaHistory()->create([
                'quota_used' => 0,
                'quota_restored' => $amount,
                'reason' => 'quota_restored',
                'booking_id' => $bookingId,
                'notes' => "Restored {$amount} quota",
                'created_by' => auth()->id() ?? 1,
            ]);

            return $member;
        });
    }

    /**
     * Get quota statistics
     */
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
            'average_utilization' => $members->avg('quota_utilization_percentage'),
            'membership_breakdown' => $members->groupBy('membership_type')->map(function ($group) {
                return [
                    'count' => $group->count(),
                    'total_quota' => $group->sum(function ($member) {
                        return $member->quota_used + $member->quota_remaining;
                    }),
                    'used_quota' => $group->sum('quota_used'),
                    'remaining_quota' => $group->sum('quota_remaining'),
                ];
            }),
        ];
    }

    /**
     * Get quota analytics
     */
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

        $history = $query->with(['member.user'])->get();

        return [
            'usage_trends' => $this->getQuotaUsageTrends($history),
            'top_quota_users' => $this->getTopQuotaUsers($history),
            'quota_efficiency' => $this->getQuotaEfficiency($history),
        ];
    }

    /**
     * Bulk adjust quota for multiple members
     */
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
                    'message' => 'Quota adjusted successfully',
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

    /**
     * Update existing members when quota config changes
     */
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
                'quota_restored' => $member->quota_remaining - $oldQuota,
                'reason' => 'quota_config_updated',
                'notes' => "Quota updated from {$oldQuota} to {$member->quota_remaining} due to config change",
                'created_by' => auth()->id() ?? 1,
            ]);
        }
    }

    /**
     * Get quota usage trends
     */
    protected function getQuotaUsageTrends($history)
    {
        $trends = [];
        $currentDate = now()->subDays(30);
        $endDate = now();

        while ($currentDate->lte($endDate)) {
            $date = $currentDate->format('Y-m-d');

            $dayStats = [
                'date' => $date,
                'quota_used' => $history->filter(function ($item) use ($date) {
                    return $item->created_at->format('Y-m-d') === $date;
                })->sum('quota_used'),
                'quota_restored' => $history->filter(function ($item) use ($date) {
                    return $item->created_at->format('Y-m-d') === $date;
                })->sum('quota_restored'),
            ];

            $trends[] = $dayStats;
            $currentDate->addDay();
        }

        return $trends;
    }

    /**
     * Get top quota users
     */
    protected function getTopQuotaUsers($history)
    {
        return $history->groupBy('member_id')->map(function ($group) {
            $member = $group->first()->member;
            return [
                'member_id' => $member->id,
                'user_name' => $member->user->name,
                'quota_used' => $group->sum('quota_used'),
                'quota_remaining' => $member->quota_remaining,
            ];
        })->sortByDesc('quota_used')->take(10);
    }

    /**
     * Get quota efficiency metrics
     */
    protected function getQuotaEfficiency($history)
    {
        $totalQuotaUsed = $history->sum('quota_used');
        $totalQuotaRestored = $history->sum('quota_restored');

        return [
            'average_daily_usage' => $history->avg('quota_used'),
            'peak_usage_day' => $history->sortByDesc('quota_used')->first()?->created_at?->format('Y-m-d'),
            'peak_usage_amount' => $history->max('quota_used'),
        ];
    }
}
```

### Controller Layer

#### QuotaController

```php
<?php

namespace App\Http\Controllers\Api\V1\Admin;

use App\Http\Controllers\Api\BaseController;
use App\Services\QuotaService;
use App\Models\MemberQuotaConfig;
use App\Models\MemberQuotaHistory;
use App\Models\Member;
use Illuminate\Http\Request;

class QuotaController extends BaseController
{
    protected $quotaService;

    public function __construct(QuotaService $quotaService)
    {
        $this->quotaService = $quotaService;
    }

    /**
     * Get all quota configurations
     */
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

    /**
     * Create new quota configuration
     */
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
            $data = $request->only(['membership_type', 'max_quota', 'daily_limit', 'additional_session_cost', 'notes']);
            $config = $this->quotaService->createQuotaConfig($data);

            return $this->successResponse($config, 'Quota configuration created successfully', 201);
        } catch (\Exception $e) {
            return $this->errorResponse($e->getMessage(), 400);
        }
    }

    /**
     * Update existing quota configuration
     */
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
            $data = $request->only(['max_quota', 'daily_limit', 'additional_session_cost', 'is_active', 'notes']);
            $config = $this->quotaService->updateQuotaConfig($id, $data);

            return $this->successResponse($config, 'Quota configuration updated successfully');
        } catch (\Exception $e) {
            return $this->errorResponse($e->getMessage(), 400);
        }
    }

    /**
     * Delete quota configuration
     */
    public function deleteQuotaConfig($id)
    {
        try {
            $config = MemberQuotaConfig::findOrFail($id);

            // Check if there are active members using this config
            $activeMembers = Member::where('membership_type', $config->membership_type)->count();

            if ($activeMembers > 0) {
                return $this->errorResponse('Cannot delete quota config with active members', 400);
            }

            $config->delete();

            return $this->successResponse(null, 'Quota configuration deleted successfully');
        } catch (\Exception $e) {
            return $this->errorResponse($e->getMessage(), 400);
        }
    }

    /**
     * Adjust member quota
     */
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

    /**
     * Get quota statistics
     */
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

    /**
     * Get quota analytics
     */
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

    /**
     * Get member quota history
     */
    public function getMemberQuotaHistory(Request $request, $memberId)
    {
        try {
            $history = MemberQuotaHistory::with(['booking', 'member.user'])
                ->where('member_id', $memberId)
                ->orderBy('created_at', 'desc')
                ->paginate($request->per_page ?? 15);

            return $this->successResponse($history, 'Member quota history retrieved successfully');
        } catch (\Exception $e) {
            return $this->errorResponse($e->getMessage(), 400);
        }
    }

    /**
     * Bulk adjust quota
     */
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

    /**
     * Get members by quota status
     */
    public function getMembersByQuotaStatus(Request $request)
    {
        try {
            $status = $request->get('status', 'with_quota'); // with_quota, without_quota, all

            $query = Member::with(['user', 'quotaHistory' => function ($q) {
                $q->latest()->limit(5);
            }]);

            switch ($status) {
                case 'with_quota':
                    $query->where('quota_remaining', '>', 0);
                    break;
                case 'without_quota':
                    $query->where('quota_remaining', '<=', 0);
                    break;
                case 'all':
                default:
                    // No additional filter
                    break;
            }

            $members = $query->paginate($request->per_page ?? 15);

            return $this->successResponse($members, 'Members retrieved successfully');
        } catch (\Exception $e) {
            return $this->errorResponse($e->getMessage(), 400);
        }
    }

    /**
     * Get quota configuration by ID
     */
    public function getQuotaConfigById($id)
    {
        try {
            $config = MemberQuotaConfig::with(['createdBy'])->findOrFail($id);
            return $this->successResponse($config, 'Quota configuration retrieved successfully');
        } catch (\Exception $e) {
            return $this->errorResponse($e->getMessage(), 404);
        }
    }

    /**
     * Get my quota (for members)
     */
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

## Database Migrations

### Create Member Quota Config Table

```php
<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up()
    {
        Schema::create('member_quota_config', function (Blueprint $table) {
            $table->id();
            $table->enum('membership_type', ['regular', 'premium', 'vip']);
            $table->integer('max_quota');
            $table->integer('daily_limit')->default(1);
            $table->decimal('additional_session_cost', 10, 2)->default(0);
            $table->boolean('is_active')->default(true);
            $table->text('notes')->nullable();
            $table->foreignId('created_by')->constrained('users');
            $table->timestamps();

            // Unique constraint: only one active config per membership type
            $table->unique(['membership_type', 'is_active']);
        });
    }

    public function down()
    {
        Schema::dropIfExists('member_quota_config');
    }
};
```

### Create Member Quota History Table

```php
<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up()
    {
        Schema::create('member_quota_history', function (Blueprint $table) {
            $table->id();
            $table->foreignId('member_id')->constrained('members')->onDelete('cascade');
            $table->integer('quota_used')->default(0);
            $table->integer('quota_restored')->default(0);
            $table->enum('reason', [
                'membership_created',
                'booking_created',
                'booking_cancelled',
                'quota_adjusted',
                'membership_renewed',
                'admin_override',
                'quota_config_updated',
                'quota_restored'
            ]);
            $table->foreignId('booking_id')->nullable()->constrained('bookings')->onDelete('set null');
            $table->text('notes')->nullable();
            $table->foreignId('created_by')->constrained('users');
            $table->timestamps();

            $table->index(['member_id', 'created_at']);
            $table->index(['reason', 'created_at']);
        });
    }

    public function down()
    {
        Schema::dropIfExists('member_quota_history');
    }
};
```

## API Routes

### Admin Routes

```php
Route::prefix('quota')->group(function () {
    Route::get('/configs', [QuotaController::class, 'getQuotaConfigs']);
    Route::post('/configs', [QuotaController::class, 'createQuotaConfig']);
    Route::get('/configs/{id}', [QuotaController::class, 'getQuotaConfigById']);
    Route::put('/configs/{id}', [QuotaController::class, 'updateQuotaConfig']);
    Route::delete('/configs/{id}', [QuotaController::class, 'deleteQuotaConfig']);

    Route::post('/members/{id}/adjust', [QuotaController::class, 'adjustMemberQuota']);
    Route::get('/stats', [QuotaController::class, 'getQuotaStats']);
    Route::get('/analytics', [QuotaController::class, 'getQuotaAnalytics']);
    Route::get('/members/{id}/history', [QuotaController::class, 'getMemberQuotaHistory']);
    Route::post('/bulk-adjust', [QuotaController::class, 'bulkAdjustQuota']);
    Route::get('/members', [QuotaController::class, 'getMembersByQuotaStatus']);
});
```

### Member Routes

```php
Route::get('/quota', [QuotaController::class, 'getMyQuota']);
```

## Testing

### Running Tests

```bash
# Run all quota management tests
php artisan test --filter=QuotaManagementTest

# Run specific test category
php artisan test --filter="QuotaService"
php artisan test --filter="QuotaController"

# Run specific test
php artisan test --filter="it can create quota configuration"
```

### Test Structure

```
tests/Feature/QuotaManagementTest.php
├── QuotaService Tests (11 tests)
├── QuotaController Tests (12 tests)
├── Member Quota Access Tests (2 tests)
└── Validation Tests (7 tests)
```

## Development Workflow

### 1. Feature Development

1. **Create/Update Models**: Add new fields, relationships, or methods
2. **Update Service Layer**: Implement business logic
3. **Update Controller**: Add new endpoints or modify existing ones
4. **Update Routes**: Add new API endpoints
5. **Write Tests**: Create comprehensive test coverage
6. **Update Documentation**: Keep API docs and development guides current

### 2. Code Review Checklist

-   [ ] Models have proper relationships and scopes
-   [ ] Service methods use database transactions where appropriate
-   [ ] Controllers handle errors gracefully
-   [ ] API responses follow consistent format
-   [ ] Tests cover all scenarios (success, failure, edge cases)
-   [ ] Validation rules are comprehensive
-   [ ] Logging is implemented for important operations
-   [ ] Database queries are optimized

### 3. Performance Considerations

-   **Database Indexing**: Ensure proper indexes on frequently queried fields
-   **Eager Loading**: Use `with()` to avoid N+1 queries
-   **Pagination**: Implement pagination for large datasets
-   **Caching**: Consider caching for frequently accessed data
-   **Batch Operations**: Use bulk operations for multiple records

## Troubleshooting

### Common Issues

1. **Unique Constraint Violation**

    - Ensure only one active config per membership type
    - Check factory states in tests

2. **Authentication Issues**

    - Verify middleware configuration
    - Check user roles and permissions

3. **Database State Issues**

    - Use `refresh()` on models after changes
    - Clear database between tests if needed

4. **Validation Errors**
    - Check request validation rules
    - Verify data types and constraints

### Debug Commands

```bash
# Check database state
php artisan tinker
>>> App\Models\MemberQuotaConfig::all()

# Check routes
php artisan route:list --name=quota

# Check migrations
php artisan migrate:status
```

## Best Practices

1. **Error Handling**: Always use try-catch blocks in controllers
2. **Logging**: Log important operations for debugging
3. **Validation**: Validate all input data
4. **Transactions**: Use database transactions for complex operations
5. **Testing**: Maintain high test coverage
6. **Documentation**: Keep code and documentation in sync
7. **Security**: Validate user permissions and input data
8. **Performance**: Optimize database queries and use caching where appropriate

## Support

Untuk pertanyaan atau masalah development:

1. Periksa error logs di `storage/logs/laravel.log`
2. Gunakan `dd()` atau `Log::info()` untuk debugging
3. Review test cases untuk contoh penggunaan
4. Periksa API documentation untuk endpoint details
5. Hubungi tim development jika diperlukan
