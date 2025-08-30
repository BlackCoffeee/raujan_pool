# Point 5: Capacity Management System

## 📋 Overview

Implementasi sistem manajemen kapasitas dengan dynamic capacity adjustment, queue system, dan capacity monitoring.

## 🎯 Objectives

- Dynamic capacity management
- Queue system implementation
- Capacity monitoring
- Auto-scaling capacity
- Capacity alerts
- Capacity analytics

## 📁 Files Structure

```
phase-3/
├── 05-capacity-management.md
├── app/Http/Controllers/CapacityController.php
├── app/Models/CapacityQueue.php
├── app/Services/CapacityService.php
├── app/Jobs/ProcessCapacityQueue.php
└── app/Events/CapacityUpdated.php
```

## 🔧 Implementation Steps

### Step 1: Create Capacity Queue Model

```php
<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Carbon\Carbon;

class CapacityQueue extends Model
{
    use HasFactory;

    protected $fillable = [
        'session_id',
        'date',
        'requested_slots',
        'user_id',
        'guest_user_id',
        'booking_type',
        'priority',
        'status',
        'estimated_wait_time',
        'position_in_queue',
        'expires_at',
        'processed_at',
        'notes',
    ];

    protected $casts = [
        'date' => 'date',
        'expires_at' => 'datetime',
        'processed_at' => 'datetime',
        'priority' => 'integer',
        'position_in_queue' => 'integer',
        'estimated_wait_time' => 'integer',
    ];

    public function session()
    {
        return $this->belongsTo(Session::class);
    }

    public function user()
    {
        return $this->belongsTo(User::class);
    }

    public function guestUser()
    {
        return $this->belongsTo(GuestUser::class);
    }

    public function scopePending($query)
    {
        return $query->where('status', 'pending');
    }

    public function scopeProcessing($query)
    {
        return $query->where('status', 'processing');
    }

    public function scopeCompleted($query)
    {
        return $query->where('status', 'completed');
    }

    public function scopeExpired($query)
    {
        return $query->where('expires_at', '<', now());
    }

    public function scopeByPriority($query)
    {
        return $query->orderBy('priority', 'desc')->orderBy('created_at', 'asc');
    }

    public function isExpired()
    {
        return $this->expires_at && $this->expires_at->isPast();
    }

    public function canBeProcessed()
    {
        return $this->status === 'pending' && !$this->isExpired();
    }
}
```

### Step 2: Create Capacity Service

```php
<?php

namespace App\Services;

use App\Models\Session;
use App\Models\CapacityQueue;
use App\Models\Booking;
use App\Jobs\ProcessCapacityQueue;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;
use Carbon\Carbon;

class CapacityService
{
    public function checkCapacity($sessionId, $date, $requestedSlots)
    {
        $session = Session::findOrFail($sessionId);
        $availability = $this->getCurrentAvailability($sessionId, $date);

        if ($availability['available_slots'] >= $requestedSlots) {
            return [
                'status' => 'available',
                'available_slots' => $availability['available_slots'],
                'can_book' => true,
            ];
        }

        return [
            'status' => 'queue_required',
            'available_slots' => $availability['available_slots'],
            'can_book' => false,
            'queue_position' => $this->getQueuePosition($sessionId, $date),
            'estimated_wait_time' => $this->getEstimatedWaitTime($sessionId, $date),
        ];
    }

    public function addToQueue($sessionId, $date, $requestedSlots, $userId = null, $guestUserId = null, $bookingType = 'regular')
    {
        return DB::transaction(function () use ($sessionId, $date, $requestedSlots, $userId, $guestUserId, $bookingType) {
            $priority = $this->calculatePriority($userId, $guestUserId, $bookingType);
            $position = $this->getNextQueuePosition($sessionId, $date);

            $queueEntry = CapacityQueue::create([
                'session_id' => $sessionId,
                'date' => $date,
                'requested_slots' => $requestedSlots,
                'user_id' => $userId,
                'guest_user_id' => $guestUserId,
                'booking_type' => $bookingType,
                'priority' => $priority,
                'status' => 'pending',
                'position_in_queue' => $position,
                'estimated_wait_time' => $this->calculateEstimatedWaitTime($sessionId, $date, $position),
                'expires_at' => now()->addHours(2), // Queue expires in 2 hours
            ]);

            // Dispatch job to process queue
            ProcessCapacityQueue::dispatch($sessionId, $date);

            Log::info('Added to capacity queue', [
                'queue_id' => $queueEntry->id,
                'session_id' => $sessionId,
                'date' => $date,
                'position' => $position,
            ]);

            return $queueEntry;
        });
    }

    public function processQueue($sessionId, $date)
    {
        $session = Session::findOrFail($sessionId);
        $queueEntries = CapacityQueue::where('session_id', $sessionId)
            ->where('date', $date)
            ->pending()
            ->byPriority()
            ->get();

        foreach ($queueEntries as $entry) {
            if (!$entry->canBeProcessed()) {
                continue;
            }

            $availability = $this->getCurrentAvailability($sessionId, $date);

            if ($availability['available_slots'] >= $entry->requested_slots) {
                $this->processQueueEntry($entry);
            }
        }
    }

    public function processQueueEntry($queueEntry)
    {
        return DB::transaction(function () use ($queueEntry) {
            $queueEntry->update([
                'status' => 'processing',
                'processed_at' => now(),
            ]);

            // Create booking from queue entry
            $bookingData = [
                'session_id' => $queueEntry->session_id,
                'booking_date' => $queueEntry->date,
                'booking_type' => $queueEntry->booking_type,
                'adult_count' => $queueEntry->requested_slots, // Simplified for demo
                'child_count' => 0,
                'user_id' => $queueEntry->user_id,
                'guest_user_id' => $queueEntry->guest_user_id,
            ];

            $booking = app(BookingService::class)->createBooking($bookingData);

            $queueEntry->update([
                'status' => 'completed',
            ]);

            // Update queue positions
            $this->updateQueuePositions($queueEntry->session_id, $queueEntry->date);

            Log::info('Queue entry processed', [
                'queue_id' => $queueEntry->id,
                'booking_id' => $booking->id,
            ]);

            return $booking;
        });
    }

    public function removeFromQueue($queueId, $reason = 'cancelled')
    {
        $queueEntry = CapacityQueue::findOrFail($queueId);

        if ($queueEntry->status !== 'pending') {
            throw new \Exception('Cannot remove non-pending queue entry');
        }

        $queueEntry->update([
            'status' => 'cancelled',
            'notes' => $reason,
        ]);

        // Update queue positions
        $this->updateQueuePositions($queueEntry->session_id, $queueEntry->date);

        return $queueEntry;
    }

    public function getQueueStatus($sessionId, $date)
    {
        $queueEntries = CapacityQueue::where('session_id', $sessionId)
            ->where('date', $date)
            ->pending()
            ->byPriority()
            ->get();

        return [
            'total_in_queue' => $queueEntries->count(),
            'total_requested_slots' => $queueEntries->sum('requested_slots'),
            'average_wait_time' => $queueEntries->avg('estimated_wait_time'),
            'queue_entries' => $queueEntries->map(function ($entry) {
                return [
                    'id' => $entry->id,
                    'position' => $entry->position_in_queue,
                    'requested_slots' => $entry->requested_slots,
                    'priority' => $entry->priority,
                    'estimated_wait_time' => $entry->estimated_wait_time,
                    'expires_at' => $entry->expires_at,
                ];
            }),
        ];
    }

    public function adjustCapacity($sessionId, $newCapacity, $reason = 'manual_adjustment')
    {
        return DB::transaction(function () use ($sessionId, $newCapacity, $reason) {
            $session = Session::findOrFail($sessionId);
            $oldCapacity = $session->max_capacity;

            if ($newCapacity < $session->current_capacity) {
                throw new \Exception('New capacity cannot be less than current capacity');
            }

            $session->update([
                'max_capacity' => $newCapacity,
                'updated_by' => auth()->id(),
            ]);

            // Process queue if capacity increased
            if ($newCapacity > $oldCapacity) {
                $this->processQueue($sessionId, now()->toDateString());
            }

            Log::info('Capacity adjusted', [
                'session_id' => $sessionId,
                'old_capacity' => $oldCapacity,
                'new_capacity' => $newCapacity,
                'reason' => $reason,
                'adjusted_by' => auth()->id(),
            ]);

            return $session;
        });
    }

    public function getCapacityAnalytics($sessionId, $startDate = null, $endDate = null)
    {
        $startDate = $startDate ?? now()->subDays(30)->toDateString();
        $endDate = $endDate ?? now()->toDateString();

        $session = Session::findOrFail($sessionId);

        $bookings = Booking::where('session_id', $sessionId)
            ->whereBetween('booking_date', [$startDate, $endDate])
            ->get();

        $queueEntries = CapacityQueue::where('session_id', $sessionId)
            ->whereBetween('date', [$startDate, $endDate])
            ->get();

        return [
            'session_id' => $sessionId,
            'session_name' => $session->name,
            'period' => [
                'start_date' => $startDate,
                'end_date' => $endDate,
            ],
            'capacity_stats' => [
                'max_capacity' => $session->max_capacity,
                'average_utilization' => $this->calculateAverageUtilization($bookings, $session->max_capacity),
                'peak_utilization' => $this->calculatePeakUtilization($bookings, $session->max_capacity),
                'capacity_shortage_days' => $this->getCapacityShortageDays($bookings, $session->max_capacity),
            ],
            'queue_stats' => [
                'total_queue_entries' => $queueEntries->count(),
                'completed_queue_entries' => $queueEntries->where('status', 'completed')->count(),
                'cancelled_queue_entries' => $queueEntries->where('status', 'cancelled')->count(),
                'average_wait_time' => $queueEntries->avg('estimated_wait_time'),
                'average_queue_position' => $queueEntries->avg('position_in_queue'),
            ],
            'recommendations' => $this->getCapacityRecommendations($session, $bookings, $queueEntries),
        ];
    }

    public function getCapacityAlerts($sessionId = null)
    {
        $alerts = [];
        $sessions = $sessionId ? Session::where('id', $sessionId)->get() : Session::active()->get();

        foreach ($sessions as $session) {
            $today = now()->toDateString();
            $availability = $this->getCurrentAvailability($session->id, $today);
            $queueStatus = $this->getQueueStatus($session->id, $today);

            // High utilization alert
            if ($availability['utilization_percentage'] > 90) {
                $alerts[] = [
                    'type' => 'high_utilization',
                    'session_id' => $session->id,
                    'session_name' => $session->name,
                    'utilization_percentage' => $availability['utilization_percentage'],
                    'message' => "High utilization ({$availability['utilization_percentage']}%) for {$session->name}",
                ];
            }

            // Long queue alert
            if ($queueStatus['total_in_queue'] > 10) {
                $alerts[] = [
                    'type' => 'long_queue',
                    'session_id' => $session->id,
                    'session_name' => $session->name,
                    'queue_length' => $queueStatus['total_in_queue'],
                    'message' => "Long queue ({$queueStatus['total_in_queue']} entries) for {$session->name}",
                ];
            }

            // Capacity shortage alert
            if ($availability['available_slots'] == 0 && $queueStatus['total_in_queue'] > 0) {
                $alerts[] = [
                    'type' => 'capacity_shortage',
                    'session_id' => $session->id,
                    'session_name' => $session->name,
                    'queue_length' => $queueStatus['total_in_queue'],
                    'message' => "Capacity shortage for {$session->name} with {$queueStatus['total_in_queue']} in queue",
                ];
            }
        }

        return $alerts;
    }

    protected function getCurrentAvailability($sessionId, $date)
    {
        $session = Session::findOrFail($sessionId);
        $bookedSlots = Booking::where('session_id', $sessionId)
            ->where('booking_date', $date)
            ->whereIn('status', ['pending', 'confirmed'])
            ->sum(DB::raw('adult_count + child_count'));

        $availableSlots = $session->max_capacity - $bookedSlots;
        $utilizationPercentage = $session->max_capacity > 0 ?
            round(($bookedSlots / $session->max_capacity) * 100, 2) : 0;

        return [
            'max_capacity' => $session->max_capacity,
            'booked_slots' => $bookedSlots,
            'available_slots' => $availableSlots,
            'utilization_percentage' => $utilizationPercentage,
        ];
    }

    protected function getQueuePosition($sessionId, $date)
    {
        return CapacityQueue::where('session_id', $sessionId)
            ->where('date', $date)
            ->pending()
            ->count() + 1;
    }

    protected function getEstimatedWaitTime($sessionId, $date)
    {
        $queueLength = $this->getQueuePosition($sessionId, $date) - 1;
        $averageProcessingTime = 5; // minutes per booking

        return $queueLength * $averageProcessingTime;
    }

    protected function calculatePriority($userId, $guestUserId, $bookingType)
    {
        $priority = 1; // Base priority

        // Higher priority for registered users
        if ($userId) {
            $priority += 2;
        }

        // Higher priority for premium booking types
        if ($bookingType === 'private_gold') {
            $priority += 3;
        } elseif ($bookingType === 'private_silver') {
            $priority += 2;
        }

        return $priority;
    }

    protected function getNextQueuePosition($sessionId, $date)
    {
        $lastPosition = CapacityQueue::where('session_id', $sessionId)
            ->where('date', $date)
            ->max('position_in_queue');

        return ($lastPosition ?? 0) + 1;
    }

    protected function calculateEstimatedWaitTime($sessionId, $date, $position)
    {
        $averageProcessingTime = 5; // minutes per booking
        return ($position - 1) * $averageProcessingTime;
    }

    protected function updateQueuePositions($sessionId, $date)
    {
        $queueEntries = CapacityQueue::where('session_id', $sessionId)
            ->where('date', $date)
            ->pending()
            ->byPriority()
            ->get();

        foreach ($queueEntries as $index => $entry) {
            $newPosition = $index + 1;
            if ($entry->position_in_queue !== $newPosition) {
                $entry->update([
                    'position_in_queue' => $newPosition,
                    'estimated_wait_time' => $this->calculateEstimatedWaitTime($sessionId, $date, $newPosition),
                ]);
            }
        }
    }

    protected function calculateAverageUtilization($bookings, $maxCapacity)
    {
        if ($maxCapacity == 0) return 0;

        $totalBookedSlots = $bookings->sum(function ($booking) {
            return $booking->adult_count + $booking->child_count;
        });

        $totalPossibleSlots = $maxCapacity * $bookings->count();

        return $totalPossibleSlots > 0 ? round(($totalBookedSlots / $totalPossibleSlots) * 100, 2) : 0;
    }

    protected function calculatePeakUtilization($bookings, $maxCapacity)
    {
        if ($maxCapacity == 0) return 0;

        $peakBookedSlots = $bookings->max(function ($booking) {
            return $booking->adult_count + $booking->child_count;
        });

        return round(($peakBookedSlots / $maxCapacity) * 100, 2);
    }

    protected function getCapacityShortageDays($bookings, $maxCapacity)
    {
        $shortageDays = 0;
        $bookingsByDate = $bookings->groupBy('booking_date');

        foreach ($bookingsByDate as $date => $dateBookings) {
            $totalBookedSlots = $dateBookings->sum(function ($booking) {
                return $booking->adult_count + $booking->child_count;
            });

            if ($totalBookedSlots >= $maxCapacity) {
                $shortageDays++;
            }
        }

        return $shortageDays;
    }

    protected function getCapacityRecommendations($session, $bookings, $queueEntries)
    {
        $recommendations = [];

        $averageUtilization = $this->calculateAverageUtilization($bookings, $session->max_capacity);
        $queueCount = $queueEntries->count();

        if ($averageUtilization > 80) {
            $recommendations[] = [
                'type' => 'increase_capacity',
                'message' => 'Consider increasing capacity due to high utilization',
                'priority' => 'high',
            ];
        }

        if ($queueCount > 20) {
            $recommendations[] = [
                'type' => 'add_session',
                'message' => 'Consider adding additional session due to high queue demand',
                'priority' => 'medium',
            ];
        }

        if ($averageUtilization < 30) {
            $recommendations[] = [
                'type' => 'decrease_capacity',
                'message' => 'Consider decreasing capacity due to low utilization',
                'priority' => 'low',
            ];
        }

        return $recommendations;
    }
}
```

### Step 3: Create Capacity Controller

```php
<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Api\BaseController;
use App\Services\CapacityService;
use App\Models\CapacityQueue;
use Illuminate\Http\Request;

class CapacityController extends BaseController
{
    protected $capacityService;

    public function __construct(CapacityService $capacityService)
    {
        $this->capacityService = $capacityService;
    }

    public function checkCapacity(Request $request)
    {
        $request->validate([
            'session_id' => 'required|exists:sessions,id',
            'date' => 'required|date',
            'requested_slots' => 'required|integer|min:1',
        ]);

        try {
            $result = $this->capacityService->checkCapacity(
                $request->session_id,
                $request->date,
                $request->requested_slots
            );

            return $this->successResponse($result, 'Capacity check completed');
        } catch (\Exception $e) {
            return $this->errorResponse($e->getMessage(), 400);
        }
    }

    public function addToQueue(Request $request)
    {
        $request->validate([
            'session_id' => 'required|exists:sessions,id',
            'date' => 'required|date',
            'requested_slots' => 'required|integer|min:1',
            'booking_type' => 'required|in:regular,private_silver,private_gold',
        ]);

        try {
            $queueEntry = $this->capacityService->addToQueue(
                $request->session_id,
                $request->date,
                $request->requested_slots,
                auth()->id(),
                null,
                $request->booking_type
            );

            return $this->successResponse($queueEntry, 'Added to capacity queue', 201);
        } catch (\Exception $e) {
            return $this->errorResponse($e->getMessage(), 400);
        }
    }

    public function getQueueStatus(Request $request)
    {
        $request->validate([
            'session_id' => 'required|exists:sessions,id',
            'date' => 'required|date',
        ]);

        try {
            $status = $this->capacityService->getQueueStatus(
                $request->session_id,
                $request->date
            );

            return $this->successResponse($status, 'Queue status retrieved successfully');
        } catch (\Exception $e) {
            return $this->errorResponse($e->getMessage(), 400);
        }
    }

    public function removeFromQueue($queueId)
    {
        try {
            $queueEntry = $this->capacityService->removeFromQueue($queueId, 'user_cancelled');

            return $this->successResponse($queueEntry, 'Removed from queue successfully');
        } catch (\Exception $e) {
            return $this->errorResponse($e->getMessage(), 400);
        }
    }

    public function adjustCapacity(Request $request, $sessionId)
    {
        $request->validate([
            'new_capacity' => 'required|integer|min:1',
            'reason' => 'nullable|string|max:255',
        ]);

        try {
            $session = $this->capacityService->adjustCapacity(
                $sessionId,
                $request->new_capacity,
                $request->reason ?? 'manual_adjustment'
            );

            return $this->successResponse($session, 'Capacity adjusted successfully');
        } catch (\Exception $e) {
            return $this->errorResponse($e->getMessage(), 400);
        }
    }

    public function getAnalytics(Request $request, $sessionId)
    {
        $request->validate([
            'start_date' => 'nullable|date',
            'end_date' => 'nullable|date|after_or_equal:start_date',
        ]);

        try {
            $analytics = $this->capacityService->getCapacityAnalytics(
                $sessionId,
                $request->start_date,
                $request->end_date
            );

            return $this->successResponse($analytics, 'Capacity analytics retrieved successfully');
        } catch (\Exception $e) {
            return $this->errorResponse($e->getMessage(), 400);
        }
    }

    public function getAlerts(Request $request)
    {
        $request->validate([
            'session_id' => 'nullable|exists:sessions,id',
        ]);

        try {
            $alerts = $this->capacityService->getCapacityAlerts($request->session_id);

            return $this->successResponse($alerts, 'Capacity alerts retrieved successfully');
        } catch (\Exception $e) {
            return $this->errorResponse($e->getMessage(), 400);
        }
    }

    public function processQueue(Request $request)
    {
        $request->validate([
            'session_id' => 'required|exists:sessions,id',
            'date' => 'required|date',
        ]);

        try {
            $this->capacityService->processQueue($request->session_id, $request->date);

            return $this->successResponse(null, 'Queue processed successfully');
        } catch (\Exception $e) {
            return $this->errorResponse($e->getMessage(), 400);
        }
    }

    public function getMyQueueEntries(Request $request)
    {
        $queueEntries = CapacityQueue::where('user_id', auth()->id())
            ->with(['session'])
            ->orderBy('created_at', 'desc')
            ->paginate($request->per_page ?? 15);

        return $this->successResponse($queueEntries, 'My queue entries retrieved successfully');
    }
}
```

### Step 4: Create Queue Processing Job

```php
<?php

namespace App\Jobs;

use App\Services\CapacityService;
use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Bus\Dispatchable;
use Illuminate\Queue\InteractsWithQueue;
use Illuminate\Queue\SerializesModels;
use Illuminate\Support\Facades\Log;

class ProcessCapacityQueue implements ShouldQueue
{
    use Dispatchable, InteractsWithQueue, Queueable, SerializesModels;

    protected $sessionId;
    protected $date;

    public function __construct($sessionId, $date)
    {
        $this->sessionId = $sessionId;
        $this->date = $date;
    }

    public function handle(CapacityService $capacityService)
    {
        try {
            $capacityService->processQueue($this->sessionId, $this->date);

            Log::info('Capacity queue processed', [
                'session_id' => $this->sessionId,
                'date' => $this->date,
            ]);
        } catch (\Exception $e) {
            Log::error('Failed to process capacity queue', [
                'session_id' => $this->sessionId,
                'date' => $this->date,
                'error' => $e->getMessage(),
            ]);

            throw $e;
        }
    }
}
```

## 📚 API Endpoints

### Capacity Management Endpoints

```
GET    /api/v1/capacity/check
POST   /api/v1/capacity/queue
GET    /api/v1/capacity/queue/status
DELETE /api/v1/capacity/queue/{queueId}
PUT    /api/v1/capacity/sessions/{sessionId}/adjust
GET    /api/v1/capacity/sessions/{sessionId}/analytics
GET    /api/v1/capacity/alerts
POST   /api/v1/capacity/queue/process
GET    /api/v1/capacity/queue/my
```

## 🧪 Testing

### CapacityTest.php

```php
<?php

use App\Models\Session;
use App\Models\CapacityQueue;
use App\Services\CapacityService;

describe('Capacity Management', function () {

    beforeEach(function () {
        $this->capacityService = app(CapacityService::class);
    });

    it('can check capacity availability', function () {
        $session = Session::factory()->create(['max_capacity' => 50]);
        actingAsUser();

        $result = $this->capacityService->checkCapacity($session->id, now()->addDay()->format('Y-m-d'), 10);

        expect($result['status'])->toBe('available');
        expect($result['can_book'])->toBeTrue();
    });

    it('can add to capacity queue', function () {
        $session = Session::factory()->create(['max_capacity' => 5]);
        $user = User::factory()->create();
        actingAsUser($user);

        // Fill capacity first
        Booking::factory()->create([
            'session_id' => $session->id,
            'booking_date' => now()->addDay()->format('Y-m-d'),
            'adult_count' => 5,
            'child_count' => 0,
            'status' => 'confirmed'
        ]);

        $queueEntry = $this->capacityService->addToQueue(
            $session->id,
            now()->addDay()->format('Y-m-d'),
            2,
            $user->id
        );

        expect($queueEntry->status)->toBe('pending');
        expect($queueEntry->position_in_queue)->toBe(1);
    });

    it('can process capacity queue', function () {
        $session = Session::factory()->create(['max_capacity' => 10]);
        $user = User::factory()->create();

        $queueEntry = CapacityQueue::factory()->create([
            'session_id' => $session->id,
            'user_id' => $user->id,
            'status' => 'pending',
            'requested_slots' => 2
        ]);

        $this->capacityService->processQueue($session->id, $queueEntry->date);

        $queueEntry->refresh();
        expect($queueEntry->status)->toBe('completed');
    });

    it('can adjust session capacity', function () {
        $session = Session::factory()->create(['max_capacity' => 50]);
        actingAsAdmin();

        $updatedSession = $this->capacityService->adjustCapacity($session->id, 75, 'demand_increase');

        expect($updatedSession->max_capacity)->toBe(75);
    });
});
```

## ✅ Success Criteria

- [ ] Dynamic capacity management berfungsi
- [ ] Queue system implementation berjalan
- [ ] Capacity monitoring berfungsi
- [ ] Auto-scaling capacity berjalan
- [ ] Capacity alerts berfungsi
- [ ] Capacity analytics berjalan
- [ ] Testing coverage > 90%

## 📚 Documentation

- [Laravel Jobs](https://laravel.com/docs/11.x/queues)
- [Laravel Database Transactions](https://laravel.com/docs/11.x/database#database-transactions)
- [Laravel Events](https://laravel.com/docs/11.x/events)
