# Point 1: Calendar Backend Implementation

## 📋 Overview

Implementasi backend calendar dengan data structure, availability calculation, dan forward-only navigation logic.

## 🎯 Objectives

- Calendar data structure design
- Date availability calculation
- Forward-only navigation logic
- Calendar API endpoints
- Calendar caching mechanism
- Calendar validation rules

## 📁 Files Structure

```
phase-3/
├── 01-calendar-backend.md
├── database/migrations/
│   ├── 2024_01_01_000001_create_calendar_availabilities_table.php
│   └── 2024_01_01_000002_create_booking_sessions_table.php
├── app/Models/
│   ├── CalendarAvailability.php
│   └── BookingSession.php
├── app/Services/
│   └── CalendarService.php
└── app/Http/Controllers/
    └── CalendarController.php
```

## 📋 File Hierarchy Rules

Implementasi mengikuti urutan: **Database → Model → Service → Controller**

1. **Database**: Migrations untuk calendar_availabilities dan booking_sessions
2. **Model**: CalendarAvailability dan BookingSession models
3. **Service**: CalendarService untuk calendar business logic
4. **Controller**: CalendarController untuk HTTP handling

## 🔧 Implementation Steps

### Step 1: Create Calendar Availability Model

```php
<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Carbon\Carbon;

class CalendarAvailability extends Model
{
    use HasFactory;

    protected $fillable = [
        'date',
        'session_id',
        'available_slots',
        'booked_slots',
        'is_available',
        'max_capacity',
        'reserved_slots',
        'notes',
        'is_override',
        'override_reason',
    ];

    protected $casts = [
        'date' => 'date',
        'is_available' => 'boolean',
        'is_override' => 'boolean',
    ];

    public function session()
    {
        return $this->belongsTo(Session::class);
    }

    public function bookings()
    {
        return $this->hasMany(Booking::class, 'booking_date', 'date');
    }

    public function getRemainingSlotsAttribute()
    {
        return max(0, $this->available_slots - $this->booked_slots);
    }

    public function getUtilizationPercentageAttribute()
    {
        if ($this->available_slots == 0) {
            return 0;
        }
        return round(($this->booked_slots / $this->available_slots) * 100, 2);
    }

    public function isFullyBooked()
    {
        return $this->booked_slots >= $this->available_slots;
    }

    public function hasAvailableSlots($requiredSlots = 1)
    {
        return $this->getRemainingSlotsAttribute() >= $requiredSlots;
    }

    public function canBook($requiredSlots = 1)
    {
        return $this->is_available && $this->hasAvailableSlots($requiredSlots);
    }

    public function incrementBookedSlots($slots = 1)
    {
        $this->increment('booked_slots', $slots);
    }

    public function decrementBookedSlots($slots = 1)
    {
        $this->decrement('booked_slots', $slots);
    }

    public function scopeAvailable($query)
    {
        return $query->where('is_available', true);
    }

    public function scopeByDate($query, $date)
    {
        return $query->where('date', $date);
    }

    public function scopeByDateRange($query, $startDate, $endDate)
    {
        return $query->whereBetween('date', [$startDate, $endDate]);
    }

    public function scopeBySession($query, $sessionId)
    {
        return $query->where('session_id', $sessionId);
    }

    public function scopeForwardOnly($query, $fromDate = null)
    {
        $fromDate = $fromDate ?: now()->toDateString();
        return $query->where('date', '>=', $fromDate);
    }

    public function scopeWithAvailableSlots($query, $minSlots = 1)
    {
        return $query->whereRaw('(available_slots - booked_slots) >= ?', [$minSlots]);
    }
}
```

### Step 2: Create Calendar Service

```php
<?php

namespace App\Services;

use App\Models\CalendarAvailability;
use App\Models\Session;
use App\Models\DailyCapacity;
use Carbon\Carbon;
use Illuminate\Support\Facades\Cache;
use Illuminate\Support\Facades\DB;

class CalendarService
{
    protected $cachePrefix = 'calendar_availability_';
    protected $cacheTtl = 3600; // 1 hour

    public function getAvailability($startDate, $endDate, $sessionId = null)
    {
        $cacheKey = $this->getCacheKey($startDate, $endDate, $sessionId);

        return Cache::remember($cacheKey, $this->cacheTtl, function () use ($startDate, $endDate, $sessionId) {
            $query = CalendarAvailability::with('session')
                ->available()
                ->byDateRange($startDate, $endDate)
                ->forwardOnly();

            if ($sessionId) {
                $query->bySession($sessionId);
            }

            return $query->orderBy('date')
                ->orderBy('session_id')
                ->get()
                ->groupBy('date');
        });
    }

    public function getDateInfo($date)
    {
        $cacheKey = $this->getCacheKey($date, $date);

        return Cache::remember($cacheKey, $this->cacheTtl, function () use ($date) {
            $availability = CalendarAvailability::with('session')
                ->available()
                ->byDate($date)
                ->forwardOnly()
                ->get();

            $dailyCapacity = DailyCapacity::byDate($date)->first();

            return [
                'date' => $date,
                'is_available' => $availability->isNotEmpty(),
                'daily_capacity' => $dailyCapacity,
                'sessions' => $availability->map(function ($item) {
                    return [
                        'session_id' => $item->session_id,
                        'session_name' => $item->session->name,
                        'start_time' => $item->session->start_time,
                        'end_time' => $item->session->end_time,
                        'available_slots' => $item->available_slots,
                        'booked_slots' => $item->booked_slots,
                        'remaining_slots' => $item->remaining_slots,
                        'utilization_percentage' => $item->utilization_percentage,
                        'is_fully_booked' => $item->isFullyBooked(),
                    ];
                }),
                'total_available_slots' => $availability->sum('available_slots'),
                'total_booked_slots' => $availability->sum('booked_slots'),
                'total_remaining_slots' => $availability->sum('remaining_slots'),
            ];
        });
    }

    public function generateCalendar($startDate, $endDate, $sessionId = null)
    {
        $start = Carbon::parse($startDate);
        $end = Carbon::parse($endDate);
        $sessions = $sessionId ? Session::where('id', $sessionId)->get() : Session::active()->get();

        $generated = 0;
        $errors = [];

        DB::transaction(function () use ($start, $end, $sessions, &$generated, &$errors) {
            for ($date = $start->copy(); $date->lte($end); $date->addDay()) {
                // Skip past dates
                if ($date->isPast()) {
                    continue;
                }

                // Skip if date is not available (e.g., maintenance day)
                if (!$this->isDateAvailable($date)) {
                    continue;
                }

                foreach ($sessions as $session) {
                    try {
                        $this->createOrUpdateAvailability($date, $session);
                        $generated++;
                    } catch (\Exception $e) {
                        $errors[] = "Error generating availability for {$date->format('Y-m-d')} - {$session->name}: " . $e->getMessage();
                    }
                }
            }
        });

        // Clear cache after generation
        $this->clearCache($startDate, $endDate, $sessionId);

        return [
            'generated' => $generated,
            'errors' => $errors,
            'success' => empty($errors),
        ];
    }

    public function createOrUpdateAvailability($date, $session)
    {
        $dailyCapacity = DailyCapacity::byDate($date->toDateString())->first();
        $maxCapacity = $dailyCapacity ? $dailyCapacity->max_capacity : $session->capacity;

        $availability = CalendarAvailability::updateOrCreate(
            [
                'date' => $date->toDateString(),
                'session_id' => $session->id,
            ],
            [
                'available_slots' => $maxCapacity,
                'booked_slots' => 0,
                'is_available' => true,
                'max_capacity' => $maxCapacity,
                'reserved_slots' => 0,
            ]
        );

        return $availability;
    }

    public function updateAvailability($date, $sessionId, $data)
    {
        $availability = CalendarAvailability::where('date', $date)
            ->where('session_id', $sessionId)
            ->first();

        if (!$availability) {
            throw new \Exception('Availability not found for the specified date and session');
        }

        $availability->update($data);

        // Clear cache
        $this->clearCache($date, $date, $sessionId);

        return $availability;
    }

    public function bookSlots($date, $sessionId, $slots = 1)
    {
        $availability = CalendarAvailability::where('date', $date)
            ->where('session_id', $sessionId)
            ->first();

        if (!$availability) {
            throw new \Exception('Availability not found');
        }

        if (!$availability->canBook($slots)) {
            throw new \Exception('Not enough available slots');
        }

        $availability->incrementBookedSlots($slots);

        // Clear cache
        $this->clearCache($date, $date, $sessionId);

        return $availability;
    }

    public function releaseSlots($date, $sessionId, $slots = 1)
    {
        $availability = CalendarAvailability::where('date', $date)
            ->where('session_id', $sessionId)
            ->first();

        if (!$availability) {
            throw new \Exception('Availability not found');
        }

        $availability->decrementBookedSlots($slots);

        // Clear cache
        $this->clearCache($date, $date, $sessionId);

        return $availability;
    }

    public function isDateAvailable($date)
    {
        // Check if date is in the past
        if (Carbon::parse($date)->isPast()) {
            return false;
        }

        // Check if date is a maintenance day (implement your logic)
        if ($this->isMaintenanceDay($date)) {
            return false;
        }

        // Check if date is a holiday (implement your logic)
        if ($this->isHoliday($date)) {
            return false;
        }

        return true;
    }

    public function isMaintenanceDay($date)
    {
        // Implement maintenance day logic
        // For example, every Monday
        return Carbon::parse($date)->isMonday();
    }

    public function isHoliday($date)
    {
        // Implement holiday logic
        // You can create a holidays table or use a service
        return false;
    }

    public function getNextAvailableDate($sessionId = null, $requiredSlots = 1)
    {
        $query = CalendarAvailability::available()
            ->withAvailableSlots($requiredSlots)
            ->forwardOnly();

        if ($sessionId) {
            $query->bySession($sessionId);
        }

        $nextAvailable = $query->orderBy('date')
            ->orderBy('session_id')
            ->first();

        return $nextAvailable ? $nextAvailable->date : null;
    }

    public function getAvailabilityStats($startDate, $endDate)
    {
        $availability = CalendarAvailability::available()
            ->byDateRange($startDate, $endDate)
            ->get();

        $totalSlots = $availability->sum('available_slots');
        $bookedSlots = $availability->sum('booked_slots');
        $remainingSlots = $totalSlots - $bookedSlots;

        return [
            'total_slots' => $totalSlots,
            'booked_slots' => $bookedSlots,
            'remaining_slots' => $remainingSlots,
            'utilization_percentage' => $totalSlots > 0 ? round(($bookedSlots / $totalSlots) * 100, 2) : 0,
            'total_days' => $availability->groupBy('date')->count(),
            'fully_booked_days' => $availability->groupBy('date')->filter(function ($day) {
                return $day->every(function ($session) {
                    return $session->isFullyBooked();
                });
            })->count(),
        ];
    }

    protected function getCacheKey($startDate, $endDate, $sessionId = null)
    {
        return $this->cachePrefix . md5("{$startDate}_{$endDate}_{$sessionId}");
    }

    protected function clearCache($startDate, $endDate, $sessionId = null)
    {
        $cacheKey = $this->getCacheKey($startDate, $endDate, $sessionId);
        Cache::forget($cacheKey);
    }

    public function clearAllCache()
    {
        // Clear all calendar-related cache
        $pattern = $this->cachePrefix . '*';
        // Implementation depends on your cache driver
        // For Redis: Cache::getRedis()->del(Cache::getRedis()->keys($pattern));
    }
}
```

### Step 3: Create Calendar Controller

```php
<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Api\BaseController;
use App\Http\Requests\CalendarRequest;
use App\Services\CalendarService;
use Illuminate\Http\Request;
use Carbon\Carbon;

class CalendarController extends BaseController
{
    protected $calendarService;

    public function __construct(CalendarService $calendarService)
    {
        $this->calendarService = $calendarService;
    }

    public function getAvailability(Request $request)
    {
        $request->validate([
            'start_date' => 'required|date|after_or_equal:today',
            'end_date' => 'required|date|after:start_date',
            'session_id' => 'nullable|exists:sessions,id',
        ]);

        $startDate = $request->start_date;
        $endDate = $request->end_date;
        $sessionId = $request->session_id;

        $availability = $this->calendarService->getAvailability($startDate, $endDate, $sessionId);

        return $this->successResponse([
            'availability' => $availability,
            'date_range' => [
                'start_date' => $startDate,
                'end_date' => $endDate,
            ],
            'session_id' => $sessionId,
        ], 'Calendar availability retrieved successfully');
    }

    public function getDateInfo(Request $request, $date)
    {
        $request->validate([
            'date' => 'required|date|after_or_equal:today',
        ]);

        $dateInfo = $this->calendarService->getDateInfo($date);

        return $this->successResponse($dateInfo, 'Date information retrieved successfully');
    }

    public function getSessions(Request $request)
    {
        $sessions = \App\Models\Session::active()
            ->orderBy('start_time')
            ->get(['id', 'name', 'start_time', 'end_time', 'capacity', 'session_type']);

        return $this->successResponse($sessions, 'Sessions retrieved successfully');
    }

    public function generateCalendar(CalendarRequest $request)
    {
        $startDate = $request->start_date;
        $endDate = $request->end_date;
        $sessionId = $request->session_id;

        $result = $this->calendarService->generateCalendar($startDate, $endDate, $sessionId);

        if ($result['success']) {
            return $this->successResponse([
                'generated' => $result['generated'],
                'date_range' => [
                    'start_date' => $startDate,
                    'end_date' => $endDate,
                ],
            ], 'Calendar generated successfully');
        } else {
            return $this->errorResponse('Calendar generation failed', 500, $result['errors']);
        }
    }

    public function updateAvailability(Request $request)
    {
        $request->validate([
            'date' => 'required|date',
            'session_id' => 'required|exists:sessions,id',
            'available_slots' => 'required|integer|min:0',
            'is_available' => 'boolean',
            'notes' => 'nullable|string|max:500',
            'is_override' => 'boolean',
            'override_reason' => 'nullable|string|max:255',
        ]);

        try {
            $availability = $this->calendarService->updateAvailability(
                $request->date,
                $request->session_id,
                $request->only([
                    'available_slots',
                    'is_available',
                    'notes',
                    'is_override',
                    'override_reason',
                ])
            );

            return $this->successResponse($availability, 'Availability updated successfully');
        } catch (\Exception $e) {
            return $this->errorResponse($e->getMessage(), 400);
        }
    }

    public function getNextAvailableDate(Request $request)
    {
        $request->validate([
            'session_id' => 'nullable|exists:sessions,id',
            'required_slots' => 'integer|min:1|max:10',
        ]);

        $nextDate = $this->calendarService->getNextAvailableDate(
            $request->session_id,
            $request->required_slots ?? 1
        );

        return $this->successResponse([
            'next_available_date' => $nextDate,
            'session_id' => $request->session_id,
            'required_slots' => $request->required_slots ?? 1,
        ], 'Next available date retrieved successfully');
    }

    public function getAvailabilityStats(Request $request)
    {
        $request->validate([
            'start_date' => 'required|date',
            'end_date' => 'required|date|after:start_date',
        ]);

        $stats = $this->calendarService->getAvailabilityStats(
            $request->start_date,
            $request->end_date
        );

        return $this->successResponse($stats, 'Availability statistics retrieved successfully');
    }

    public function checkBookingAvailability(Request $request)
    {
        $request->validate([
            'date' => 'required|date|after_or_equal:today',
            'session_id' => 'required|exists:sessions,id',
            'required_slots' => 'required|integer|min:1|max:10',
        ]);

        $availability = \App\Models\CalendarAvailability::where('date', $request->date)
            ->where('session_id', $request->session_id)
            ->first();

        if (!$availability) {
            return $this->errorResponse('No availability found for the specified date and session', 404);
        }

        $canBook = $availability->canBook($request->required_slots);

        return $this->successResponse([
            'can_book' => $canBook,
            'available_slots' => $availability->available_slots,
            'booked_slots' => $availability->booked_slots,
            'remaining_slots' => $availability->remaining_slots,
            'required_slots' => $request->required_slots,
            'is_available' => $availability->is_available,
        ], 'Booking availability checked successfully');
    }

    public function clearCache(Request $request)
    {
        $this->calendarService->clearAllCache();

        return $this->successResponse(null, 'Calendar cache cleared successfully');
    }
}
```

### Step 4: Create Request Classes

#### CalendarRequest

```php
<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class CalendarRequest extends FormRequest
{
    public function authorize()
    {
        return true;
    }

    public function rules()
    {
        return [
            'start_date' => ['required', 'date', 'after_or_equal:today'],
            'end_date' => ['required', 'date', 'after:start_date'],
            'session_id' => ['nullable', 'exists:sessions,id'],
        ];
    }

    public function messages()
    {
        return [
            'start_date.required' => 'Start date is required',
            'start_date.after_or_equal' => 'Start date must be today or later',
            'end_date.required' => 'End date is required',
            'end_date.after' => 'End date must be after start date',
            'session_id.exists' => 'Selected session does not exist',
        ];
    }
}
```

### Step 5: Create Migration

```bash
php artisan make:migration create_calendar_availability_table
```

```php
<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('calendar_availability', function (Blueprint $table) {
            $table->id();
            $table->date('date');
            $table->foreignId('session_id')->constrained()->onDelete('cascade');
            $table->integer('available_slots')->default(0);
            $table->integer('booked_slots')->default(0);
            $table->boolean('is_available')->default(true);
            $table->integer('max_capacity')->default(0);
            $table->integer('reserved_slots')->default(0);
            $table->text('notes')->nullable();
            $table->boolean('is_override')->default(false);
            $table->string('override_reason')->nullable();
            $table->timestamps();

            $table->unique(['date', 'session_id']);
            $table->index(['date', 'is_available']);
            $table->index(['session_id', 'date']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('calendar_availability');
    }
};
```

## 📚 API Endpoints

### Calendar Endpoints

```
GET  /api/v1/calendar/availability
GET  /api/v1/calendar/sessions
GET  /api/v1/calendar/dates/{date}
POST /api/v1/calendar/generate
PUT  /api/v1/calendar/availability
GET  /api/v1/calendar/next-available
GET  /api/v1/calendar/stats
POST /api/v1/calendar/check-booking
POST /api/v1/calendar/clear-cache
```

### Request/Response Examples

#### Get Availability

```json
GET /api/v1/calendar/availability?start_date=2024-01-15&end_date=2024-01-20&session_id=1

Response:
{
    "success": true,
    "message": "Calendar availability retrieved successfully",
    "data": {
        "availability": {
            "2024-01-15": [
                {
                    "id": 1,
                    "date": "2024-01-15",
                    "session_id": 1,
                    "available_slots": 50,
                    "booked_slots": 30,
                    "remaining_slots": 20,
                    "utilization_percentage": 60,
                    "session": {
                        "id": 1,
                        "name": "Morning Session",
                        "start_time": "06:00:00",
                        "end_time": "10:00:00"
                    }
                }
            ]
        },
        "date_range": {
            "start_date": "2024-01-15",
            "end_date": "2024-01-20"
        },
        "session_id": 1
    }
}
```

#### Get Date Info

```json
GET /api/v1/calendar/dates/2024-01-15

Response:
{
    "success": true,
    "message": "Date information retrieved successfully",
    "data": {
        "date": "2024-01-15",
        "is_available": true,
        "daily_capacity": {
            "max_capacity": 100,
            "reserved_capacity": 0
        },
        "sessions": [
            {
                "session_id": 1,
                "session_name": "Morning Session",
                "start_time": "06:00:00",
                "end_time": "10:00:00",
                "available_slots": 50,
                "booked_slots": 30,
                "remaining_slots": 20,
                "utilization_percentage": 60,
                "is_fully_booked": false
            }
        ],
        "total_available_slots": 50,
        "total_booked_slots": 30,
        "total_remaining_slots": 20
    }
}
```

## 🧪 Testing

### CalendarTest.php

```php
<?php

use App\Models\CalendarAvailability;
use App\Models\Session;
use App\Services\CalendarService;

describe('Calendar Backend', function () {

    beforeEach(function () {
        $this->calendarService = app(CalendarService::class);
    });

    it('can get calendar availability', function () {
        $session = Session::factory()->create();
        CalendarAvailability::factory()->create([
            'date' => now()->addDay(),
            'session_id' => $session->id,
            'available_slots' => 50,
            'booked_slots' => 30
        ]);

        $response = apiGet('/api/v1/calendar/availability', [
            'start_date' => now()->addDay()->format('Y-m-d'),
            'end_date' => now()->addDays(7)->format('Y-m-d')
        ]);

        assertApiSuccess($response, 'Calendar availability retrieved successfully');
        $response->assertJsonStructure([
            'data' => [
                'availability',
                'date_range'
            ]
        ]);
    });

    it('can get date information', function () {
        $session = Session::factory()->create();
        CalendarAvailability::factory()->create([
            'date' => now()->addDay(),
            'session_id' => $session->id
        ]);

        $response = apiGet('/api/v1/calendar/dates/' . now()->addDay()->format('Y-m-d'));

        assertApiSuccess($response, 'Date information retrieved successfully');
        $response->assertJsonStructure([
            'data' => [
                'date',
                'is_available',
                'sessions'
            ]
        ]);
    });

    it('can generate calendar', function () {
        $session = Session::factory()->create();

        $response = apiPost('/api/v1/calendar/generate', [
            'start_date' => now()->addDay()->format('Y-m-d'),
            'end_date' => now()->addDays(7)->format('Y-m-d'),
            'session_id' => $session->id
        ]);

        assertApiSuccess($response, 'Calendar generated successfully');
    });

    it('can check booking availability', function () {
        $session = Session::factory()->create();
        CalendarAvailability::factory()->create([
            'date' => now()->addDay(),
            'session_id' => $session->id,
            'available_slots' => 50,
            'booked_slots' => 30
        ]);

        $response = apiPost('/api/v1/calendar/check-booking', [
            'date' => now()->addDay()->format('Y-m-d'),
            'session_id' => $session->id,
            'required_slots' => 2
        ]);

        assertApiSuccess($response, 'Booking availability checked successfully');
        $response->assertJson([
            'data' => [
                'can_book' => true,
                'remaining_slots' => 20
            ]
        ]);
    });
});
```

## ✅ Success Criteria

- [ ] Calendar data structure terdesain dengan baik
- [ ] Date availability calculation berfungsi
- [ ] Forward-only navigation logic berjalan
- [ ] Calendar API endpoints berfungsi
- [ ] Calendar caching mechanism berjalan
- [ ] Calendar validation rules terimplementasi
- [ ] Database schema optimal
- [ ] Testing coverage > 90%

## 📚 Documentation

- [Laravel Eloquent Relationships](https://laravel.com/docs/11.x/eloquent-relationships)
- [Laravel Caching](https://laravel.com/docs/11.x/cache)
- [Carbon Date Library](https://carbon.nesbot.com/docs/)
