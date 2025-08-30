# Point 3: Real-time Availability System

## 📋 Overview

Implementasi sistem real-time availability dengan WebSocket untuk update live, caching Redis, dan notifikasi real-time.

## 🎯 Objectives

- Real-time availability updates
- WebSocket integration
- Redis caching system
- Live notifications
- Availability broadcasting
- Performance optimization

## 📁 Files Structure

```
phase-3/
├── 03-real-time-availability.md
├── app/Http/Controllers/WebSocketController.php
├── app/Services/RealTimeAvailabilityService.php
├── app/Events/AvailabilityUpdated.php
├── app/Listeners/BroadcastAvailabilityUpdate.php
├── app/Channels/AvailabilityChannel.php
└── resources/js/websocket.js
```

## 🔧 Implementation Steps

### Step 1: Create Availability Event

```php
<?php

namespace App\Events;

use Illuminate\Broadcasting\Channel;
use Illuminate\Broadcasting\InteractsWithSockets;
use Illuminate\Broadcasting\PresenceChannel;
use Illuminate\Broadcasting\PrivateChannel;
use Illuminate\Contracts\Broadcasting\ShouldBroadcast;
use Illuminate\Foundation\Events\Dispatchable;
use Illuminate\Queue\SerializesModels;

class AvailabilityUpdated implements ShouldBroadcast
{
    use Dispatchable, InteractsWithSockets, SerializesModels;

    public $date;
    public $sessionId;
    public $availability;
    public $bookedSlots;
    public $availableSlots;

    public function __construct($date, $sessionId, $availability, $bookedSlots, $availableSlots)
    {
        $this->date = $date;
        $this->sessionId = $sessionId;
        $this->availability = $availability;
        $this->bookedSlots = $bookedSlots;
        $this->availableSlots = $availableSlots;
    }

    public function broadcastOn()
    {
        return [
            new Channel('availability'),
            new Channel("availability.{$this->date}"),
            new Channel("availability.session.{$this->sessionId}"),
        ];
    }

    public function broadcastAs()
    {
        return 'availability.updated';
    }

    public function broadcastWith()
    {
        return [
            'date' => $this->date,
            'session_id' => $this->sessionId,
            'availability' => $this->availability,
            'booked_slots' => $this->bookedSlots,
            'available_slots' => $this->availableSlots,
            'timestamp' => now()->toISOString(),
        ];
    }
}
```

### Step 2: Create Real-time Availability Service

```php
<?php

namespace App\Services;

use App\Events\AvailabilityUpdated;
use App\Models\CalendarAvailability;
use App\Models\Booking;
use App\Models\Session;
use Illuminate\Support\Facades\Cache;
use Illuminate\Support\Facades\Redis;
use Carbon\Carbon;

class RealTimeAvailabilityService
{
    protected $cachePrefix = 'availability:';
    protected $cacheTtl = 3600; // 1 hour

    public function getAvailability($date, $sessionId = null)
    {
        $cacheKey = $this->getCacheKey($date, $sessionId);

        return Cache::remember($cacheKey, $this->cacheTtl, function () use ($date, $sessionId) {
            return $this->calculateAvailability($date, $sessionId);
        });
    }

    public function updateAvailability($date, $sessionId, $bookedSlots)
    {
        // Update database
        $availability = CalendarAvailability::updateOrCreate(
            [
                'date' => $date,
                'session_id' => $sessionId,
            ],
            [
                'available_slots' => $this->getMaxSlots($sessionId) - $bookedSlots,
                'is_available' => ($this->getMaxSlots($sessionId) - $bookedSlots) > 0,
                'updated_at' => now(),
            ]
        );

        // Clear cache
        $this->clearCache($date, $sessionId);

        // Broadcast update
        $this->broadcastAvailabilityUpdate($date, $sessionId, $availability);

        return $availability;
    }

    public function broadcastAvailabilityUpdate($date, $sessionId, $availability = null)
    {
        if (!$availability) {
            $availability = CalendarAvailability::where('date', $date)
                ->where('session_id', $sessionId)
                ->first();
        }

        if (!$availability) {
            return;
        }

        $bookedSlots = $this->getBookedSlots($date, $sessionId);
        $availableSlots = $availability->available_slots;

        event(new AvailabilityUpdated(
            $date,
            $sessionId,
            $availability,
            $bookedSlots,
            $availableSlots
        ));
    }

    public function getAvailabilityForDateRange($startDate, $endDate, $sessionId = null)
    {
        $dates = [];
        $currentDate = Carbon::parse($startDate);
        $endDate = Carbon::parse($endDate);

        while ($currentDate->lte($endDate)) {
            $date = $currentDate->format('Y-m-d');
            $dates[$date] = $this->getAvailability($date, $sessionId);
            $currentDate->addDay();
        }

        return $dates;
    }

    public function getAvailabilityForSession($sessionId, $startDate = null, $endDate = null)
    {
        $startDate = $startDate ?? now()->format('Y-m-d');
        $endDate = $endDate ?? now()->addDays(30)->format('Y-m-d');

        return $this->getAvailabilityForDateRange($startDate, $endDate, $sessionId);
    }

    public function getAvailabilityForAllSessions($date)
    {
        $sessions = Session::where('is_active', true)->get();
        $availability = [];

        foreach ($sessions as $session) {
            $availability[$session->id] = $this->getAvailability($date, $session->id);
        }

        return $availability;
    }

    public function refreshAvailability($date, $sessionId = null)
    {
        if ($sessionId) {
            $this->clearCache($date, $sessionId);
            $this->broadcastAvailabilityUpdate($date, $sessionId);
        } else {
            $sessions = Session::where('is_active', true)->get();
            foreach ($sessions as $session) {
                $this->clearCache($date, $session->id);
                $this->broadcastAvailabilityUpdate($date, $session->id);
            }
        }
    }

    public function getAvailabilityStats($date, $sessionId = null)
    {
        $availability = $this->getAvailability($date, $sessionId);

        return [
            'date' => $date,
            'session_id' => $sessionId,
            'total_slots' => $this->getMaxSlots($sessionId),
            'booked_slots' => $availability['booked_slots'],
            'available_slots' => $availability['available_slots'],
            'utilization_percentage' => $this->calculateUtilizationPercentage($availability),
            'is_available' => $availability['is_available'],
            'last_updated' => $availability['last_updated'],
        ];
    }

    public function getAvailabilityTrends($sessionId, $days = 30)
    {
        $trends = [];
        $endDate = now();
        $startDate = $endDate->copy()->subDays($days);

        $currentDate = $startDate->copy();
        while ($currentDate->lte($endDate)) {
            $date = $currentDate->format('Y-m-d');
            $availability = $this->getAvailability($date, $sessionId);

            $trends[] = [
                'date' => $date,
                'booked_slots' => $availability['booked_slots'],
                'available_slots' => $availability['available_slots'],
                'utilization_percentage' => $this->calculateUtilizationPercentage($availability),
            ];

            $currentDate->addDay();
        }

        return $trends;
    }

    public function getPeakHours($sessionId, $days = 30)
    {
        $bookings = Booking::where('session_id', $sessionId)
            ->where('booking_date', '>=', now()->subDays($days))
            ->whereIn('status', ['confirmed', 'completed'])
            ->selectRaw('HOUR(created_at) as hour, COUNT(*) as booking_count')
            ->groupBy('hour')
            ->orderBy('booking_count', 'desc')
            ->get();

        return $bookings->map(function ($booking) {
            return [
                'hour' => $booking->hour,
                'booking_count' => $booking->booking_count,
            ];
        });
    }

    public function getAvailabilityAlerts($sessionId = null)
    {
        $alerts = [];
        $sessions = $sessionId ? Session::where('id', $sessionId)->get() : Session::where('is_active', true)->get();

        foreach ($sessions as $session) {
            $today = now()->format('Y-m-d');
            $tomorrow = now()->addDay()->format('Y-m-d');

            $todayAvailability = $this->getAvailability($today, $session->id);
            $tomorrowAvailability = $this->getAvailability($tomorrow, $session->id);

            // Low availability alert
            if ($todayAvailability['available_slots'] < 5) {
                $alerts[] = [
                    'type' => 'low_availability',
                    'session_id' => $session->id,
                    'session_name' => $session->name,
                    'date' => $today,
                    'available_slots' => $todayAvailability['available_slots'],
                    'message' => "Low availability for {$session->name} today",
                ];
            }

            // No availability alert
            if ($todayAvailability['available_slots'] == 0) {
                $alerts[] = [
                    'type' => 'no_availability',
                    'session_id' => $session->id,
                    'session_name' => $session->name,
                    'date' => $today,
                    'message' => "No availability for {$session->name} today",
                ];
            }

            // High demand alert
            if ($tomorrowAvailability['booked_slots'] > ($this->getMaxSlots($session->id) * 0.8)) {
                $alerts[] = [
                    'type' => 'high_demand',
                    'session_id' => $session->id,
                    'session_name' => $session->name,
                    'date' => $tomorrow,
                    'booked_slots' => $tomorrowAvailability['booked_slots'],
                    'message' => "High demand for {$session->name} tomorrow",
                ];
            }
        }

        return $alerts;
    }

    protected function calculateAvailability($date, $sessionId = null)
    {
        if ($sessionId) {
            return $this->calculateAvailabilityForSession($date, $sessionId);
        }

        $sessions = Session::where('is_active', true)->get();
        $availability = [];

        foreach ($sessions as $session) {
            $availability[$session->id] = $this->calculateAvailabilityForSession($date, $session->id);
        }

        return $availability;
    }

    protected function calculateAvailabilityForSession($date, $sessionId)
    {
        $maxSlots = $this->getMaxSlots($sessionId);
        $bookedSlots = $this->getBookedSlots($date, $sessionId);
        $availableSlots = $maxSlots - $bookedSlots;

        return [
            'session_id' => $sessionId,
            'date' => $date,
            'max_slots' => $maxSlots,
            'booked_slots' => $bookedSlots,
            'available_slots' => $availableSlots,
            'is_available' => $availableSlots > 0,
            'last_updated' => now()->toISOString(),
        ];
    }

    protected function getMaxSlots($sessionId)
    {
        $session = Session::find($sessionId);
        return $session ? $session->max_capacity : 0;
    }

    protected function getBookedSlots($date, $sessionId)
    {
        return Booking::where('booking_date', $date)
            ->where('session_id', $sessionId)
            ->whereIn('status', ['pending', 'confirmed'])
            ->sum(\DB::raw('adult_count + child_count'));
    }

    protected function calculateUtilizationPercentage($availability)
    {
        if ($availability['max_slots'] == 0) {
            return 0;
        }

        return round(($availability['booked_slots'] / $availability['max_slots']) * 100, 2);
    }

    protected function getCacheKey($date, $sessionId = null)
    {
        return $this->cachePrefix . $date . ($sessionId ? ":{$sessionId}" : '');
    }

    protected function clearCache($date, $sessionId = null)
    {
        $cacheKey = $this->getCacheKey($date, $sessionId);
        Cache::forget($cacheKey);

        // Also clear related cache keys
        if ($sessionId) {
            Cache::forget($this->getCacheKey($date));
        }
    }
}
```

### Step 3: Create WebSocket Controller

```php
<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Api\BaseController;
use App\Services\RealTimeAvailabilityService;
use Illuminate\Http\Request;

class WebSocketController extends BaseController
{
    protected $availabilityService;

    public function __construct(RealTimeAvailabilityService $availabilityService)
    {
        $this->availabilityService = $availabilityService;
    }

    public function getAvailability(Request $request)
    {
        $request->validate([
            'date' => 'required|date',
            'session_id' => 'nullable|exists:sessions,id',
        ]);

        $availability = $this->availabilityService->getAvailability(
            $request->date,
            $request->session_id
        );

        return $this->successResponse($availability, 'Availability retrieved successfully');
    }

    public function getAvailabilityForDateRange(Request $request)
    {
        $request->validate([
            'start_date' => 'required|date',
            'end_date' => 'required|date|after_or_equal:start_date',
            'session_id' => 'nullable|exists:sessions,id',
        ]);

        $availability = $this->availabilityService->getAvailabilityForDateRange(
            $request->start_date,
            $request->end_date,
            $request->session_id
        );

        return $this->successResponse($availability, 'Availability for date range retrieved successfully');
    }

    public function getAvailabilityForSession(Request $request)
    {
        $request->validate([
            'session_id' => 'required|exists:sessions,id',
            'start_date' => 'nullable|date',
            'end_date' => 'nullable|date|after_or_equal:start_date',
        ]);

        $availability = $this->availabilityService->getAvailabilityForSession(
            $request->session_id,
            $request->start_date,
            $request->end_date
        );

        return $this->successResponse($availability, 'Availability for session retrieved successfully');
    }

    public function getAvailabilityStats(Request $request)
    {
        $request->validate([
            'date' => 'required|date',
            'session_id' => 'nullable|exists:sessions,id',
        ]);

        $stats = $this->availabilityService->getAvailabilityStats(
            $request->date,
            $request->session_id
        );

        return $this->successResponse($stats, 'Availability statistics retrieved successfully');
    }

    public function getAvailabilityTrends(Request $request)
    {
        $request->validate([
            'session_id' => 'required|exists:sessions,id',
            'days' => 'nullable|integer|min:1|max:90',
        ]);

        $trends = $this->availabilityService->getAvailabilityTrends(
            $request->session_id,
            $request->days ?? 30
        );

        return $this->successResponse($trends, 'Availability trends retrieved successfully');
    }

    public function getPeakHours(Request $request)
    {
        $request->validate([
            'session_id' => 'required|exists:sessions,id',
            'days' => 'nullable|integer|min:1|max:90',
        ]);

        $peakHours = $this->availabilityService->getPeakHours(
            $request->session_id,
            $request->days ?? 30
        );

        return $this->successResponse($peakHours, 'Peak hours retrieved successfully');
    }

    public function getAvailabilityAlerts(Request $request)
    {
        $request->validate([
            'session_id' => 'nullable|exists:sessions,id',
        ]);

        $alerts = $this->availabilityService->getAvailabilityAlerts(
            $request->session_id
        );

        return $this->successResponse($alerts, 'Availability alerts retrieved successfully');
    }

    public function refreshAvailability(Request $request)
    {
        $request->validate([
            'date' => 'required|date',
            'session_id' => 'nullable|exists:sessions,id',
        ]);

        $this->availabilityService->refreshAvailability(
            $request->date,
            $request->session_id
        );

        return $this->successResponse(null, 'Availability refreshed successfully');
    }

    public function subscribeToAvailability(Request $request)
    {
        $request->validate([
            'channels' => 'required|array',
            'channels.*' => 'string|in:availability,availability.date,availability.session',
        ]);

        // This would typically be handled by the WebSocket server
        // For now, we'll return the channels the client should subscribe to
        $channels = $request->channels;
        $userChannels = [];

        foreach ($channels as $channel) {
            switch ($channel) {
                case 'availability':
                    $userChannels[] = 'availability';
                    break;
                case 'availability.date':
                    $userChannels[] = 'availability.' . now()->format('Y-m-d');
                    break;
                case 'availability.session':
                    $userChannels[] = 'availability.session.1'; // Default session
                    break;
            }
        }

        return $this->successResponse([
            'channels' => $userChannels,
            'message' => 'Subscribed to availability channels'
        ], 'Successfully subscribed to availability channels');
    }
}
```

### Step 4: Create WebSocket Channel

```php
<?php

namespace App\Channels;

use Illuminate\Broadcasting\Channel;
use Illuminate\Broadcasting\InteractsWithSockets;
use Illuminate\Broadcasting\PresenceChannel;
use Illuminate\Broadcasting\PrivateChannel;
use Illuminate\Contracts\Broadcasting\ShouldBroadcast;
use Illuminate\Foundation\Events\Dispatchable;
use Illuminate\Queue\SerializesModels;

class AvailabilityChannel
{
    public static function availability()
    {
        return new Channel('availability');
    }

    public static function availabilityForDate($date)
    {
        return new Channel("availability.{$date}");
    }

    public static function availabilityForSession($sessionId)
    {
        return new Channel("availability.session.{$sessionId}");
    }

    public static function availabilityForUser($userId)
    {
        return new PrivateChannel("availability.user.{$userId}");
    }
}
```

### Step 5: Create Frontend WebSocket Client

```javascript
// resources/js/websocket.js

class AvailabilityWebSocket {
  constructor() {
    this.socket = null;
    this.channels = [];
    this.callbacks = {};
    this.reconnectAttempts = 0;
    this.maxReconnectAttempts = 5;
    this.reconnectInterval = 5000;
  }

  connect() {
    try {
      this.socket = new WebSocket("ws://localhost:8080");

      this.socket.onopen = () => {
        console.log("WebSocket connected");
        this.reconnectAttempts = 0;
        this.subscribeToChannels();
      };

      this.socket.onmessage = (event) => {
        const data = JSON.parse(event.data);
        this.handleMessage(data);
      };

      this.socket.onclose = () => {
        console.log("WebSocket disconnected");
        this.handleReconnect();
      };

      this.socket.onerror = (error) => {
        console.error("WebSocket error:", error);
      };
    } catch (error) {
      console.error("Failed to connect to WebSocket:", error);
      this.handleReconnect();
    }
  }

  subscribeToChannels() {
    this.channels.forEach((channel) => {
      this.socket.send(
        JSON.stringify({
          type: "subscribe",
          channel: channel,
        })
      );
    });
  }

  subscribe(channel) {
    if (!this.channels.includes(channel)) {
      this.channels.push(channel);

      if (this.socket && this.socket.readyState === WebSocket.OPEN) {
        this.socket.send(
          JSON.stringify({
            type: "subscribe",
            channel: channel,
          })
        );
      }
    }
  }

  unsubscribe(channel) {
    const index = this.channels.indexOf(channel);
    if (index > -1) {
      this.channels.splice(index, 1);

      if (this.socket && this.socket.readyState === WebSocket.OPEN) {
        this.socket.send(
          JSON.stringify({
            type: "unsubscribe",
            channel: channel,
          })
        );
      }
    }
  }

  on(event, callback) {
    if (!this.callbacks[event]) {
      this.callbacks[event] = [];
    }
    this.callbacks[event].push(callback);
  }

  off(event, callback) {
    if (this.callbacks[event]) {
      const index = this.callbacks[event].indexOf(callback);
      if (index > -1) {
        this.callbacks[event].splice(index, 1);
      }
    }
  }

  emit(event, data) {
    if (this.callbacks[event]) {
      this.callbacks[event].forEach((callback) => callback(data));
    }
  }

  handleMessage(data) {
    switch (data.type) {
      case "availability.updated":
        this.emit("availabilityUpdated", data);
        break;
      case "booking.created":
        this.emit("bookingCreated", data);
        break;
      case "booking.cancelled":
        this.emit("bookingCancelled", data);
        break;
      default:
        console.log("Unknown message type:", data.type);
    }
  }

  handleReconnect() {
    if (this.reconnectAttempts < this.maxReconnectAttempts) {
      this.reconnectAttempts++;
      console.log(
        `Attempting to reconnect... (${this.reconnectAttempts}/${this.maxReconnectAttempts})`
      );

      setTimeout(() => {
        this.connect();
      }, this.reconnectInterval);
    } else {
      console.error("Max reconnection attempts reached");
    }
  }

  disconnect() {
    if (this.socket) {
      this.socket.close();
      this.socket = null;
    }
  }
}

// Usage example
const availabilityWS = new AvailabilityWebSocket();

// Connect to WebSocket
availabilityWS.connect();

// Subscribe to availability updates
availabilityWS.subscribe("availability");
availabilityWS.subscribe("availability.2024-01-15");
availabilityWS.subscribe("availability.session.1");

// Listen for availability updates
availabilityWS.on("availabilityUpdated", (data) => {
  console.log("Availability updated:", data);
  updateAvailabilityDisplay(data);
});

// Listen for booking events
availabilityWS.on("bookingCreated", (data) => {
  console.log("Booking created:", data);
  showNotification("New booking created");
});

availabilityWS.on("bookingCancelled", (data) => {
  console.log("Booking cancelled:", data);
  showNotification("Booking cancelled");
});

function updateAvailabilityDisplay(data) {
  // Update the availability display in the UI
  const availabilityElement = document.querySelector(
    `[data-date="${data.date}"][data-session="${data.session_id}"]`
  );
  if (availabilityElement) {
    availabilityElement.textContent = data.available_slots;
    availabilityElement.className =
      data.available_slots > 0 ? "available" : "unavailable";
  }
}

function showNotification(message) {
  // Show notification to user
  const notification = document.createElement("div");
  notification.className = "notification";
  notification.textContent = message;
  document.body.appendChild(notification);

  setTimeout(() => {
    notification.remove();
  }, 3000);
}

export default AvailabilityWebSocket;
```

## 📚 API Endpoints

### Real-time Availability Endpoints

```
GET    /api/v1/websocket/availability
GET    /api/v1/websocket/availability/date-range
GET    /api/v1/websocket/availability/session
GET    /api/v1/websocket/availability/stats
GET    /api/v1/websocket/availability/trends
GET    /api/v1/websocket/availability/peak-hours
GET    /api/v1/websocket/availability/alerts
POST   /api/v1/websocket/availability/refresh
POST   /api/v1/websocket/availability/subscribe
```

### WebSocket Channels

```
availability                    - Global availability updates
availability.{date}            - Availability for specific date
availability.session.{id}      - Availability for specific session
availability.user.{id}         - Private channel for user-specific updates
```

## 🧪 Testing

### RealTimeAvailabilityTest.php

```php
<?php

use App\Events\AvailabilityUpdated;
use App\Services\RealTimeAvailabilityService;
use App\Models\Session;
use App\Models\Booking;

describe('Real-time Availability System', function () {

    beforeEach(function () {
        $this->availabilityService = app(RealTimeAvailabilityService::class);
    });

    it('can get availability for date', function () {
        $session = Session::factory()->create(['max_capacity' => 50]);
        $date = now()->addDay()->format('Y-m-d');

        $availability = $this->availabilityService->getAvailability($date, $session->id);

        expect($availability['session_id'])->toBe($session->id);
        expect($availability['date'])->toBe($date);
        expect($availability['max_slots'])->toBe(50);
        expect($availability['available_slots'])->toBe(50);
    });

    it('can update availability', function () {
        $session = Session::factory()->create(['max_capacity' => 50]);
        $date = now()->addDay()->format('Y-m-d');

        $availability = $this->availabilityService->updateAvailability($date, $session->id, 10);

        expect($availability->available_slots)->toBe(40);
        expect($availability->is_available)->toBeTrue();
    });

    it('can broadcast availability update', function () {
        Event::fake();

        $session = Session::factory()->create(['max_capacity' => 50]);
        $date = now()->addDay()->format('Y-m-d');

        $this->availabilityService->broadcastAvailabilityUpdate($date, $session->id);

        Event::assertDispatched(AvailabilityUpdated::class);
    });

    it('can get availability alerts', function () {
        $session = Session::factory()->create(['max_capacity' => 50]);
        $date = now()->format('Y-m-d');

        // Create booking that fills most slots
        Booking::factory()->create([
            'session_id' => $session->id,
            'booking_date' => $date,
            'adult_count' => 45,
            'child_count' => 0,
            'status' => 'confirmed'
        ]);

        $alerts = $this->availabilityService->getAvailabilityAlerts($session->id);

        expect($alerts)->toHaveCount(1);
        expect($alerts[0]['type'])->toBe('low_availability');
    });
});
```

## ✅ Success Criteria

- [ ] Real-time availability updates berfungsi
- [ ] WebSocket integration berjalan
- [ ] Redis caching system berfungsi
- [ ] Live notifications berjalan
- [ ] Availability broadcasting berfungsi
- [ ] Performance optimization berjalan
- [ ] Testing coverage > 90%

## 📚 Documentation

- [Laravel Broadcasting](https://laravel.com/docs/11.x/broadcasting)
- [Laravel Events](https://laravel.com/docs/11.x/events)
- [Laravel Cache](https://laravel.com/docs/11.x/cache)
- [Laravel Reverb](https://laravel.com/docs/11.x/reverb)
