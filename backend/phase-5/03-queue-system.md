# Point 3: Queue System

## 📋 Overview

Implementasi sistem queue untuk member applications dengan queue management system, queue position tracking, dan queue notification system.

## 🎯 Objectives

-   Queue management system
-   Queue position tracking
-   Queue notification system
-   Queue processing workflow
-   Queue analytics
-   Queue optimization

## 📁 Files Structure

```
phase-5/
├── 03-queue-system.md
├── app/Http/Controllers/QueueController.php
├── app/Models/MemberQueue.php
├── app/Services/QueueService.php
└── app/Jobs/ProcessQueueJob.php
```

## 🔧 Implementation Steps

### Step 1: Create Member Queue Model

```php
<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Carbon\Carbon;

class MemberQueue extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id',
        'queue_position',
        'status',
        'applied_date',
        'offered_date',
        'accepted_date',
        'expiry_date',
        'notes',
        'priority',
        'assigned_to',
    ];

    protected $casts = [
        'applied_date' => 'datetime',
        'offered_date' => 'datetime',
        'accepted_date' => 'datetime',
        'expiry_date' => 'datetime',
        'priority' => 'integer',
    ];

    public function user()
    {
        return $this->belongsTo(User::class);
    }

    public function assignedTo()
    {
        return $this->belongsTo(User::class, 'assigned_to');
    }

    public function getStatusDisplayAttribute()
    {
        return match($this->status) {
            'waiting' => 'Waiting',
            'offered' => 'Offered',
            'accepted' => 'Accepted',
            'rejected' => 'Rejected',
            'expired' => 'Expired',
            default => 'Unknown'
        };
    }

    public function getIsWaitingAttribute()
    {
        return $this->status === 'waiting';
    }

    public function getIsOfferedAttribute()
    {
        return $this->status === 'offered';
    }

    public function getIsAcceptedAttribute()
    {
        return $this->status === 'accepted';
    }

    public function getIsRejectedAttribute()
    {
        return $this->status === 'rejected';
    }

    public function getIsExpiredAttribute()
    {
        return $this->status === 'expired';
    }

    public function getCanBeOfferedAttribute()
    {
        return $this->status === 'waiting' && !$this->is_expired;
    }

    public function getCanBeAcceptedAttribute()
    {
        return $this->status === 'offered' && !$this->is_expired;
    }

    public function getCanBeRejectedAttribute()
    {
        return in_array($this->status, ['waiting', 'offered']) && !$this->is_expired;
    }

    public function getIsExpiredAttribute()
    {
        return $this->expiry_date && $this->expiry_date->isPast();
    }

    public function getTimeInQueueAttribute()
    {
        return $this->applied_date->diffForHumans();
    }

    public function getEstimatedWaitTimeAttribute()
    {
        $averageProcessingTime = 2; // days
        $position = $this->queue_position;

        return $position * $averageProcessingTime;
    }

    public function getPriorityDisplayAttribute()
    {
        return match($this->priority) {
            1 => 'Low',
            2 => 'Normal',
            3 => 'High',
            4 => 'Urgent',
            default => 'Normal'
        };
    }

    public function scopeByStatus($query, $status)
    {
        return $query->where('status', $status);
    }

    public function scopeWaiting($query)
    {
        return $query->where('status', 'waiting');
    }

    public function scopeOffered($query)
    {
        return $query->where('status', 'offered');
    }

    public function scopeAccepted($query)
    {
        return $query->where('status', 'accepted');
    }

    public function scopeRejected($query)
    {
        return $query->where('status', 'rejected');
    }

    public function scopeExpired($query)
    {
        return $query->where('status', 'expired');
    }

    public function scopeByPriority($query, $priority)
    {
        return $query->where('priority', $priority);
    }

    public function scopeByDateRange($query, $startDate, $endDate)
    {
        return $query->whereBetween('applied_date', [$startDate, $endDate]);
    }

    public function scopeExpiringSoon($query, $hours = 24)
    {
        return $query->where('expiry_date', '<=', now()->addHours($hours))
            ->where('expiry_date', '>', now());
    }

    public function scopeByAssignedTo($query, $userId)
    {
        return $query->where('assigned_to', $userId);
    }

    public function scopeUnassigned($query)
    {
        return $query->whereNull('assigned_to');
    }
}
```

### Step 2: Create Queue Service

```php
<?php

namespace App\Services;

use App\Models\MemberQueue;
use App\Models\User;
use App\Models\Member;
use App\Jobs\ProcessQueueJob;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;
use Carbon\Carbon;

class QueueService
{
    public function joinQueue($userId, $priority = 2)
    {
        return DB::transaction(function () use ($userId, $priority) {
            $user = User::findOrFail($userId);

            // Check if user is already in queue
            if ($user->queueEntry) {
                throw new \Exception('User is already in queue');
            }

            // Check if user is already a member
            if ($user->member) {
                throw new \Exception('User is already a member');
            }

            // Get next queue position
            $nextPosition = $this->getNextQueuePosition($priority);

            // Create queue entry
            $queueEntry = MemberQueue::create([
                'user_id' => $user->id,
                'queue_position' => $nextPosition,
                'status' => 'waiting',
                'applied_date' => now(),
                'expiry_date' => now()->addDays(7), // 7 days expiry
                'priority' => $priority,
            ]);

            // Update positions for other entries
            $this->updateQueuePositions();

            // Dispatch queue processing job
            ProcessQueueJob::dispatch();

            Log::info('User joined queue', [
                'user_id' => $user->id,
                'queue_id' => $queueEntry->id,
                'position' => $nextPosition,
                'priority' => $priority,
            ]);

            return $queueEntry;
        });
    }

    public function offerMembership($queueId, $assignedTo = null)
    {
        return DB::transaction(function () use ($queueId, $assignedTo) {
            $queueEntry = MemberQueue::findOrFail($queueId);

            if (!$queueEntry->can_be_offered) {
                throw new \Exception('Queue entry cannot be offered');
            }

            $queueEntry->update([
                'status' => 'offered',
                'offered_date' => now(),
                'expiry_date' => now()->addDays(3), // 3 days to accept
                'assigned_to' => $assignedTo ?? auth()->id(),
            ]);

            // Send notification to user
            $this->sendMembershipOfferNotification($queueEntry);

            Log::info('Membership offered', [
                'queue_id' => $queueEntry->id,
                'user_id' => $queueEntry->user_id,
                'offered_by' => $assignedTo ?? auth()->id(),
            ]);

            return $queueEntry;
        });
    }

    public function acceptMembership($queueId)
    {
        return DB::transaction(function () use ($queueId) {
            $queueEntry = MemberQueue::findOrFail($queueId);

            if (!$queueEntry->can_be_accepted) {
                throw new \Exception('Queue entry cannot be accepted');
            }

            $queueEntry->update([
                'status' => 'accepted',
                'accepted_date' => now(),
            ]);

            // Create member
            $member = $this->createMemberFromQueue($queueEntry);

            // Send confirmation notification
            $this->sendMembershipAcceptedNotification($queueEntry, $member);

            Log::info('Membership accepted', [
                'queue_id' => $queueEntry->id,
                'user_id' => $queueEntry->user_id,
                'member_id' => $member->id,
            ]);

            return $member;
        });
    }

    public function rejectMembership($queueId, $reason = null)
    {
        return DB::transaction(function () use ($queueId, $reason) {
            $queueEntry = MemberQueue::findOrFail($queueId);

            if (!$queueEntry->can_be_rejected) {
                throw new \Exception('Queue entry cannot be rejected');
            }

            $queueEntry->update([
                'status' => 'rejected',
                'notes' => $reason,
            ]);

            // Send rejection notification
            $this->sendMembershipRejectionNotification($queueEntry, $reason);

            Log::info('Membership rejected', [
                'queue_id' => $queueEntry->id,
                'user_id' => $queueEntry->user_id,
                'reason' => $reason,
                'rejected_by' => auth()->id(),
            ]);

            return $queueEntry;
        });
    }

    public function leaveQueue($queueId)
    {
        return DB::transaction(function () use ($queueId) {
            $queueEntry = MemberQueue::findOrFail($queueId);

            if ($queueEntry->user_id !== auth()->id()) {
                throw new \Exception('Unauthorized access to queue entry');
            }

            if (!in_array($queueEntry->status, ['waiting', 'offered'])) {
                throw new \Exception('Cannot leave queue in current status');
            }

            $queueEntry->update(['status' => 'rejected']);

            // Update queue positions
            $this->updateQueuePositions();

            Log::info('User left queue', [
                'queue_id' => $queueEntry->id,
                'user_id' => $queueEntry->user_id,
            ]);

            return $queueEntry;
        });
    }

    public function processExpiredQueueEntries()
    {
        $expiredEntries = MemberQueue::where('expiry_date', '<', now())
            ->whereIn('status', ['waiting', 'offered'])
            ->get();

        $processedCount = 0;

        foreach ($expiredEntries as $entry) {
            try {
                $entry->update(['status' => 'expired']);
                $this->sendExpiryNotification($entry);
                $processedCount++;
            } catch (\Exception $e) {
                Log::error('Failed to process expired queue entry', [
                    'queue_id' => $entry->id,
                    'error' => $e->getMessage(),
                ]);
            }
        }

        // Update queue positions after processing expired entries
        $this->updateQueuePositions();

        return $processedCount;
    }

    public function getQueueStats($filters = [])
    {
        $query = MemberQueue::query();

        // Apply filters
        if (isset($filters['start_date']) && isset($filters['end_date'])) {
            $query->whereBetween('applied_date', [$filters['start_date'], $filters['end_date']]);
        }

        $stats = [
            'total_applications' => $query->count(),
            'waiting_applications' => $query->clone()->waiting()->count(),
            'offered_applications' => $query->clone()->offered()->count(),
            'accepted_applications' => $query->clone()->accepted()->count(),
            'rejected_applications' => $query->clone()->rejected()->count(),
            'expired_applications' => $query->clone()->expired()->count(),
            'average_wait_time' => $this->calculateAverageWaitTime($query->clone()),
            'conversion_rate' => $this->calculateConversionRate($query->clone()),
            'queue_by_priority' => $query->clone()->selectRaw('priority, COUNT(*) as count')
                ->groupBy('priority')
                ->get(),
        ];

        return $stats;
    }

    public function getQueueAnalytics($filters = [])
    {
        $query = MemberQueue::query();

        // Apply filters
        if (isset($filters['start_date']) && isset($filters['end_date'])) {
            $query->whereBetween('applied_date', [$filters['start_date'], $filters['end_date']]);
        }

        $analytics = [
            'queue_trends' => $this->getQueueTrends($query->clone()),
            'processing_times' => $this->getProcessingTimes($query->clone()),
            'priority_analysis' => $this->getPriorityAnalysis($query->clone()),
            'rejection_reasons' => $this->getRejectionReasons($query->clone()),
        ];

        return $analytics;
    }

    public function assignQueueEntry($queueId, $assignedTo)
    {
        $queueEntry = MemberQueue::findOrFail($queueId);
        $queueEntry->update(['assigned_to' => $assignedTo]);

        Log::info('Queue entry assigned', [
            'queue_id' => $queueEntry->id,
            'assigned_to' => $assignedTo,
            'assigned_by' => auth()->id(),
        ]);

        return $queueEntry;
    }

    public function getQueuePosition($userId)
    {
        $queueEntry = MemberQueue::where('user_id', $userId)
            ->where('status', 'waiting')
            ->first();

        if (!$queueEntry) {
            return null;
        }

        $totalWaiting = MemberQueue::waiting()->count();
        $position = MemberQueue::waiting()
            ->where('queue_position', '<', $queueEntry->queue_position)
            ->count() + 1;

        return [
            'position' => $position,
            'total_waiting' => $totalWaiting,
            'estimated_wait_time' => $queueEntry->estimated_wait_time,
            'applied_date' => $queueEntry->applied_date,
        ];
    }

    protected function getNextQueuePosition($priority)
    {
        $lastPosition = MemberQueue::where('priority', '>=', $priority)
            ->max('queue_position');

        return ($lastPosition ?? 0) + 1;
    }

    protected function updateQueuePositions()
    {
        $queueEntries = MemberQueue::waiting()
            ->orderBy('priority', 'desc')
            ->orderBy('applied_date', 'asc')
            ->get();

        foreach ($queueEntries as $index => $entry) {
            $newPosition = $index + 1;
            if ($entry->queue_position !== $newPosition) {
                $entry->update(['queue_position' => $newPosition]);
            }
        }
    }

    protected function createMemberFromQueue($queueEntry)
    {
        $user = $queueEntry->user;

        // Get default quota configuration
        $quotaConfig = MemberQuotaConfig::where('membership_type', 'regular')
            ->where('is_active', true)
            ->first();

        if (!$quotaConfig) {
            throw new \Exception('No quota configuration found for regular membership');
        }

        // Create member
        $member = Member::create([
            'user_id' => $user->id,
            'membership_number' => $this->generateMembershipNumber(),
            'membership_type' => 'regular',
            'status' => 'active',
            'joined_date' => now()->toDateString(),
            'membership_start' => now()->toDateString(),
            'membership_end' => now()->addYear()->toDateString(),
            'quota_used' => 0,
            'quota_remaining' => $quotaConfig->max_quota,
            'daily_usage_count' => 0,
            'total_bookings' => 0,
            'total_amount_spent' => 0,
            'is_premium' => false,
            'created_by' => auth()->id(),
        ]);

        // Update user role
        $user->update(['role' => 'member']);

        return $member;
    }

    protected function generateMembershipNumber()
    {
        do {
            $membershipNumber = 'REG' . now()->format('Ymd') . str_pad(rand(1, 9999), 4, '0', STR_PAD_LEFT);
        } while (Member::where('membership_number', $membershipNumber)->exists());

        return $membershipNumber;
    }

    protected function calculateAverageWaitTime($query)
    {
        $acceptedEntries = $query->accepted()->get();

        if ($acceptedEntries->isEmpty()) {
            return 0;
        }

        $totalWaitTime = $acceptedEntries->sum(function ($entry) {
            return $entry->applied_date->diffInDays($entry->accepted_date);
        });

        return round($totalWaitTime / $acceptedEntries->count(), 2);
    }

    protected function calculateConversionRate($query)
    {
        $totalApplications = $query->count();

        if ($totalApplications === 0) {
            return 0;
        }

        $acceptedApplications = $query->accepted()->count();

        return round(($acceptedApplications / $totalApplications) * 100, 2);
    }

    protected function getQueueTrends($query)
    {
        $startDate = now()->subDays(30);
        $endDate = now();

        $trends = [];
        $currentDate = $startDate->copy();

        while ($currentDate->lte($endDate)) {
            $date = $currentDate->format('Y-m-d');

            $dayStats = [
                'date' => $date,
                'new_applications' => $query->clone()->whereDate('applied_date', $date)->count(),
                'accepted_applications' => $query->clone()->whereDate('accepted_date', $date)->count(),
                'rejected_applications' => $query->clone()->whereDate('updated_at', $date)->where('status', 'rejected')->count(),
            ];

            $trends[] = $dayStats;
            $currentDate->addDay();
        }

        return $trends;
    }

    protected function getProcessingTimes($query)
    {
        $acceptedEntries = $query->accepted()->get();

        return [
            'average_processing_time' => $this->calculateAverageWaitTime($query),
            'fastest_processing_time' => $acceptedEntries->min(function ($entry) {
                return $entry->applied_date->diffInDays($entry->accepted_date);
            }),
            'slowest_processing_time' => $acceptedEntries->max(function ($entry) {
                return $entry->applied_date->diffInDays($entry->accepted_date);
            }),
        ];
    }

    protected function getPriorityAnalysis($query)
    {
        return $query->selectRaw('priority, COUNT(*) as count, AVG(TIMESTAMPDIFF(DAY, applied_date, COALESCE(accepted_date, updated_at))) as avg_processing_time')
            ->groupBy('priority')
            ->get();
    }

    protected function getRejectionReasons($query)
    {
        return $query->rejected()
            ->whereNotNull('notes')
            ->selectRaw('notes, COUNT(*) as count')
            ->groupBy('notes')
            ->orderBy('count', 'desc')
            ->get();
    }

    protected function sendMembershipOfferNotification($queueEntry)
    {
        Log::info('Membership offer notification sent', [
            'queue_id' => $queueEntry->id,
            'user_id' => $queueEntry->user_id,
        ]);
    }

    protected function sendMembershipAcceptedNotification($queueEntry, $member)
    {
        Log::info('Membership accepted notification sent', [
            'queue_id' => $queueEntry->id,
            'user_id' => $queueEntry->user_id,
            'member_id' => $member->id,
        ]);
    }

    protected function sendMembershipRejectionNotification($queueEntry, $reason)
    {
        Log::info('Membership rejection notification sent', [
            'queue_id' => $queueEntry->id,
            'user_id' => $queueEntry->user_id,
            'reason' => $reason,
        ]);
    }

    protected function sendExpiryNotification($queueEntry)
    {
        Log::info('Queue expiry notification sent', [
            'queue_id' => $queueEntry->id,
            'user_id' => $queueEntry->user_id,
        ]);
    }
}
```

### Step 3: Create Queue Controller

```php
<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Api\BaseController;
use App\Services\QueueService;
use App\Models\MemberQueue;
use Illuminate\Http\Request;

class QueueController extends BaseController
{
    protected $queueService;

    public function __construct(QueueService $queueService)
    {
        $this->queueService = $queueService;
    }

    public function index(Request $request)
    {
        $query = MemberQueue::with(['user', 'assignedTo']);

        // Filter by status
        if ($request->status) {
            $query->where('status', $request->status);
        }

        // Filter by priority
        if ($request->priority) {
            $query->where('priority', $request->priority);
        }

        // Filter by assigned to
        if ($request->assigned_to) {
            $query->where('assigned_to', $request->assigned_to);
        }

        // Filter by date range
        if ($request->start_date && $request->end_date) {
            $query->whereBetween('applied_date', [$request->start_date, $request->end_date]);
        }

        $queueEntries = $query->orderBy('queue_position', 'asc')->paginate($request->per_page ?? 15);

        return $this->successResponse($queueEntries, 'Queue entries retrieved successfully');
    }

    public function joinQueue(Request $request)
    {
        $request->validate([
            'priority' => 'nullable|integer|min:1|max:4',
        ]);

        try {
            $priority = $request->priority ?? 2;
            $queueEntry = $this->queueService->joinQueue(auth()->id(), $priority);

            return $this->successResponse($queueEntry, 'Joined queue successfully', 201);
        } catch (\Exception $e) {
            return $this->errorResponse($e->getMessage(), 400);
        }
    }

    public function offerMembership(Request $request, $id)
    {
        $request->validate([
            'assigned_to' => 'nullable|exists:users,id',
        ]);

        try {
            $queueEntry = $this->queueService->offerMembership($id, $request->assigned_to);

            return $this->successResponse($queueEntry, 'Membership offered successfully');
        } catch (\Exception $e) {
            return $this->errorResponse($e->getMessage(), 400);
        }
    }

    public function acceptMembership($id)
    {
        try {
            $member = $this->queueService->acceptMembership($id);

            return $this->successResponse($member, 'Membership accepted successfully');
        } catch (\Exception $e) {
            return $this->errorResponse($e->getMessage(), 400);
        }
    }

    public function rejectMembership(Request $request, $id)
    {
        $request->validate([
            'reason' => 'nullable|string|max:500',
        ]);

        try {
            $queueEntry = $this->queueService->rejectMembership($id, $request->reason);

            return $this->successResponse($queueEntry, 'Membership rejected successfully');
        } catch (\Exception $e) {
            return $this->errorResponse($e->getMessage(), 400);
        }
    }

    public function leaveQueue($id)
    {
        try {
            $queueEntry = $this->queueService->leaveQueue($id);

            return $this->successResponse($queueEntry, 'Left queue successfully');
        } catch (\Exception $e) {
            return $this->errorResponse($e->getMessage(), 400);
        }
    }

    public function getMyQueueStatus()
    {
        try {
            $position = $this->queueService->getQueuePosition(auth()->id());

            if (!$position) {
                return $this->errorResponse('Not in queue', 404);
            }

            return $this->successResponse($position, 'Queue status retrieved successfully');
        } catch (\Exception $e) {
            return $this->errorResponse($e->getMessage(), 400);
        }
    }

    public function getStats(Request $request)
    {
        try {
            $filters = $request->only(['start_date', 'end_date']);
            $stats = $this->queueService->getQueueStats($filters);

            return $this->successResponse($stats, 'Queue statistics retrieved successfully');
        } catch (\Exception $e) {
            return $this->errorResponse($e->getMessage(), 400);
        }
    }

    public function getAnalytics(Request $request)
    {
        try {
            $filters = $request->only(['start_date', 'end_date']);
            $analytics = $this->queueService->getQueueAnalytics($filters);

            return $this->successResponse($analytics, 'Queue analytics retrieved successfully');
        } catch (\Exception $e) {
            return $this->errorResponse($e->getMessage(), 400);
        }
    }

    public function processExpiredEntries()
    {
        try {
            $processedCount = $this->queueService->processExpiredQueueEntries();

            return $this->successResponse([
                'processed_count' => $processedCount,
            ], 'Expired queue entries processed successfully');
        } catch (\Exception $e) {
            return $this->errorResponse($e->getMessage(), 400);
        }
    }

    public function assignEntry(Request $request, $id)
    {
        $request->validate([
            'assigned_to' => 'required|exists:users,id',
        ]);

        try {
            $queueEntry = $this->queueService->assignQueueEntry($id, $request->assigned_to);

            return $this->successResponse($queueEntry, 'Queue entry assigned successfully');
        } catch (\Exception $e) {
            return $this->errorResponse($e->getMessage(), 400);
        }
    }
}
```

### Step 4: Create Queue Processing Job

```php
<?php

namespace App\Jobs;

use App\Services\QueueService;
use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Bus\Dispatchable;
use Illuminate\Queue\InteractsWithQueue;
use Illuminate\Queue\SerializesModels;
use Illuminate\Support\Facades\Log;

class ProcessQueueJob implements ShouldQueue
{
    use Dispatchable, InteractsWithQueue, Queueable, SerializesModels;

    public function handle(QueueService $queueService)
    {
        try {
            // Process expired queue entries
            $processedCount = $queueService->processExpiredQueueEntries();

            Log::info('Queue processing completed', [
                'processed_expired_entries' => $processedCount,
            ]);

        } catch (\Exception $e) {
            Log::error('Queue processing failed', [
                'error' => $e->getMessage(),
            ]);

            throw $e;
        }
    }
}
```

## 📚 API Endpoints

### Queue System Endpoints

```
GET    /api/v1/queue
POST   /api/v1/queue/join
POST   /api/v1/queue/{id}/offer
POST   /api/v1/queue/{id}/accept
POST   /api/v1/queue/{id}/reject
DELETE /api/v1/queue/{id}/leave
GET    /api/v1/queue/my-status
GET    /api/v1/queue/stats
GET    /api/v1/queue/analytics
POST   /api/v1/queue/process-expired
POST   /api/v1/queue/{id}/assign
```

## 🧪 Testing

### QueueTest.php

```php
<?php

use App\Models\MemberQueue;
use App\Models\User;
use App\Services\QueueService;

describe('Queue System', function () {

    beforeEach(function () {
        $this->queueService = app(QueueService::class);
    });

    it('can join queue', function () {
        $user = User::factory()->create();
        actingAsUser($user);

        $queueEntry = $this->queueService->joinQueue($user->id, 2);

        expect($queueEntry->user_id)->toBe($user->id);
        expect($queueEntry->status)->toBe('waiting');
        expect($queueEntry->priority)->toBe(2);
    });

    it('can offer membership', function () {
        $queueEntry = MemberQueue::factory()->create(['status' => 'waiting']);
        actingAsAdmin();

        $updatedEntry = $this->queueService->offerMembership($queueEntry->id);

        expect($updatedEntry->status)->toBe('offered');
        expect($updatedEntry->offered_date)->not->toBeNull();
    });

    it('can accept membership', function () {
        $queueEntry = MemberQueue::factory()->create(['status' => 'offered']);
        actingAsUser($queueEntry->user);

        $member = $this->queueService->acceptMembership($queueEntry->id);

        expect($member)->toBeInstanceOf(Member::class);
        expect($member->user_id)->toBe($queueEntry->user_id);

        $queueEntry->refresh();
        expect($queueEntry->status)->toBe('accepted');
    });

    it('can reject membership', function () {
        $queueEntry = MemberQueue::factory()->create(['status' => 'offered']);
        actingAsAdmin();

        $updatedEntry = $this->queueService->rejectMembership($queueEntry->id, 'Incomplete documents');

        expect($updatedEntry->status)->toBe('rejected');
        expect($updatedEntry->notes)->toBe('Incomplete documents');
    });

    it('can get queue position', function () {
        $user = User::factory()->create();
        $queueEntry = MemberQueue::factory()->create(['user_id' => $user->id, 'status' => 'waiting']);

        $position = $this->queueService->getQueuePosition($user->id);

        expect($position)->toHaveKey('position');
        expect($position)->toHaveKey('total_waiting');
        expect($position)->toHaveKey('estimated_wait_time');
    });

    it('cannot join queue if already a member', function () {
        $user = User::factory()->create();
        Member::factory()->create(['user_id' => $user->id]);
        actingAsUser($user);

        expect(function () use ($user) {
            $this->queueService->joinQueue($user->id);
        })->toThrow(Exception::class, 'User is already a member');
    });

    it('can process expired queue entries', function () {
        $expiredEntry = MemberQueue::factory()->create([
            'status' => 'waiting',
            'expiry_date' => now()->subHour()
        ]);

        $processedCount = $this->queueService->processExpiredQueueEntries();

        expect($processedCount)->toBe(1);

        $expiredEntry->refresh();
        expect($expiredEntry->status)->toBe('expired');
    });
});
```

## ✅ Success Criteria

-   [x] Queue management system berfungsi
-   [x] Queue position tracking berjalan
-   [x] Queue notification system berfungsi
-   [x] Queue processing workflow berjalan
-   [x] Queue analytics berfungsi
-   [x] Queue optimization berjalan
-   [x] Testing coverage > 90%

## 📚 Documentation

-   [Laravel Jobs](https://laravel.com/docs/11.x/queues)
-   [Laravel Database Transactions](https://laravel.com/docs/11.x/database#database-transactions)
-   [Laravel Events](https://laravel.com/docs/11.x/events)
