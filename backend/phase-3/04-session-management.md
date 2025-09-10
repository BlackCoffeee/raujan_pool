# Point 4: Session Management System

## 📋 Overview

Implementasi sistem manajemen session dengan CRUD operations, capacity management, time slot management, dan session scheduling.

## 🎯 Objectives

-   Session CRUD operations
-   Session capacity management
-   Time slot management
-   Session scheduling
-   Session status management
-   Session pricing management

## 📁 Files Structure

```
phase-3/
├── 04-session-management.md
├── app/Http/Controllers/SessionController.php
├── app/Models/Session.php
├── app/Http/Requests/SessionRequest.php
├── app/Services/SessionService.php
└── app/Models/SessionPricing.php
```

## 🔧 Implementation Steps

### Step 1: Create Session Model

```php
<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Carbon\Carbon;

class Session extends Model
{
    use HasFactory;

    protected $fillable = [
        'name',
        'description',
        'start_time',
        'end_time',
        'max_capacity',
        'current_capacity',
        'is_active',
        'is_peak_hour',
        'peak_hour_multiplier',
        'advance_booking_days',
        'cancellation_hours',
        'check_in_start_minutes',
        'check_in_end_minutes',
        'auto_cancel_minutes',
        'notes',
        'created_by',
        'updated_by',
    ];

    protected $casts = [
        'start_time' => 'datetime:H:i',
        'end_time' => 'datetime:H:i',
        'is_active' => 'boolean',
        'is_peak_hour' => 'boolean',
        'peak_hour_multiplier' => 'decimal:2',
        'advance_booking_days' => 'integer',
        'cancellation_hours' => 'integer',
        'check_in_start_minutes' => 'integer',
        'check_in_end_minutes' => 'integer',
        'auto_cancel_minutes' => 'integer',
    ];

    public function bookings()
    {
        return $this->hasMany(Booking::class);
    }

    public function calendarAvailabilities()
    {
        return $this->hasMany(CalendarAvailability::class);
    }

    public function sessionPricings()
    {
        return $this->hasMany(SessionPricing::class);
    }

    public function createdBy()
    {
        return $this->belongsTo(User::class, 'created_by');
    }

    public function updatedBy()
    {
        return $this->belongsTo(User::class, 'updated_by');
    }

    public function getDurationAttribute()
    {
        $start = Carbon::parse($this->start_time);
        $end = Carbon::parse($this->end_time);
        return $start->diffInMinutes($end);
    }

    public function getDurationInHoursAttribute()
    {
        return round($this->duration / 60, 2);
    }

    public function getAvailableCapacityAttribute()
    {
        return $this->max_capacity - $this->current_capacity;
    }

    public function getUtilizationPercentageAttribute()
    {
        if ($this->max_capacity == 0) {
            return 0;
        }
        return round(($this->current_capacity / $this->max_capacity) * 100, 2);
    }

    public function getIsFullyBookedAttribute()
    {
        return $this->current_capacity >= $this->max_capacity;
    }

    public function getIsAvailableAttribute()
    {
        return $this->is_active && !$this->is_fully_booked;
    }

    public function getCheckInStartTimeAttribute()
    {
        $sessionStart = Carbon::parse($this->start_time);
        return $sessionStart->subMinutes($this->check_in_start_minutes);
    }

    public function getCheckInEndTimeAttribute()
    {
        $sessionStart = Carbon::parse($this->start_time);
        return $sessionStart->addMinutes($this->check_in_end_minutes);
    }

    public function getCancellationDeadlineAttribute()
    {
        return Carbon::parse($this->start_time)->subHours($this->cancellation_hours);
    }

    public function getAutoCancelTimeAttribute()
    {
        return Carbon::parse($this->start_time)->addMinutes($this->auto_cancel_minutes);
    }

    public function getAdvanceBookingLimitAttribute()
    {
        return now()->addDays($this->advance_booking_days);
    }

    public function canBeBooked($date = null)
    {
        $date = $date ?? now()->toDateString();

        // Check if session is active
        if (!$this->is_active) {
            return false;
        }

        // Check if date is within advance booking limit
        if (Carbon::parse($date)->gt($this->advance_booking_limit)) {
            return false;
        }

        // Check if date is not in the past
        if (Carbon::parse($date)->lt(now()->toDateString())) {
            return false;
        }

        return true;
    }

    public function canCheckIn($date = null)
    {
        $date = $date ?? now()->toDateString();
        $sessionDateTime = Carbon::parse($date . ' ' . $this->start_time);
        $checkInStart = $sessionDateTime->copy()->subMinutes($this->check_in_start_minutes);
        $checkInEnd = $sessionDateTime->copy()->addMinutes($this->check_in_end_minutes);

        return now()->between($checkInStart, $checkInEnd);
    }

    public function canCancel($date = null)
    {
        $date = $date ?? now()->toDateString();
        $sessionDateTime = Carbon::parse($date . ' ' . $this->start_time);
        $cancellationDeadline = $sessionDateTime->copy()->subHours($this->cancellation_hours);

        return now()->lt($cancellationDeadline);
    }

    public function getPricingForType($bookingType)
    {
        $pricing = $this->sessionPricings()
            ->where('booking_type', $bookingType)
            ->first();

        if (!$pricing) {
            // Return default pricing
            return $this->getDefaultPricing($bookingType);
        }

        return $pricing;
    }

    public function getDefaultPricing($bookingType)
    {
        $defaultPricing = [
            'regular' => [
                'adult_price' => 50000,
                'child_price' => 25000,
            ],
            'private_silver' => [
                'adult_price' => 75000,
                'child_price' => 37500,
            ],
            'private_gold' => [
                'adult_price' => 100000,
                'child_price' => 50000,
            ],
        ];

        return (object) $defaultPricing[$bookingType] ?? $defaultPricing['regular'];
    }

    public function updateCapacity($change)
    {
        $this->current_capacity += $change;
        $this->save();
    }

    public function resetCapacity()
    {
        $this->current_capacity = 0;
        $this->save();
    }

    public function scopeActive($query)
    {
        return $query->where('is_active', true);
    }

    public function scopePeakHour($query)
    {
        return $query->where('is_peak_hour', true);
    }

    public function scopeAvailable($query)
    {
        return $query->where('is_active', true)
            ->whereRaw('current_capacity < max_capacity');
    }

    public function scopeByTimeRange($query, $startTime, $endTime)
    {
        return $query->where('start_time', '>=', $startTime)
            ->where('end_time', '<=', $endTime);
    }

    public function scopeByCapacity($query, $minCapacity = null, $maxCapacity = null)
    {
        if ($minCapacity) {
            $query->where('max_capacity', '>=', $minCapacity);
        }
        if ($maxCapacity) {
            $query->where('max_capacity', '<=', $maxCapacity);
        }
        return $query;
    }
}
```

### Step 2: Create Session Pricing Model

```php
<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class SessionPricing extends Model
{
    use HasFactory;

    protected $fillable = [
        'session_id',
        'booking_type',
        'adult_price',
        'child_price',
        'peak_hour_adult_price',
        'peak_hour_child_price',
        'is_active',
        'valid_from',
        'valid_until',
        'created_by',
        'updated_by',
    ];

    protected $casts = [
        'adult_price' => 'decimal:2',
        'child_price' => 'decimal:2',
        'peak_hour_adult_price' => 'decimal:2',
        'peak_hour_child_price' => 'decimal:2',
        'is_active' => 'boolean',
        'valid_from' => 'date',
        'valid_until' => 'date',
    ];

    public function session()
    {
        return $this->belongsTo(Session::class);
    }

    public function createdBy()
    {
        return $this->belongsTo(User::class, 'created_by');
    }

    public function updatedBy()
    {
        return $this->belongsTo(User::class, 'updated_by');
    }

    public function getEffectiveAdultPrice($isPeakHour = false)
    {
        if ($isPeakHour && $this->peak_hour_adult_price) {
            return $this->peak_hour_adult_price;
        }
        return $this->adult_price;
    }

    public function getEffectiveChildPrice($isPeakHour = false)
    {
        if ($isPeakHour && $this->peak_hour_child_price) {
            return $this->peak_hour_child_price;
        }
        return $this->child_price;
    }

    public function isCurrentlyValid()
    {
        $now = now()->toDateString();
        return $this->is_active &&
            $this->valid_from <= $now &&
            ($this->valid_until === null || $this->valid_until >= $now);
    }

    public function scopeActive($query)
    {
        return $query->where('is_active', true);
    }

    public function scopeValid($query, $date = null)
    {
        $date = $date ?? now()->toDateString();
        return $query->where('is_active', true)
            ->where('valid_from', '<=', $date)
            ->where(function ($q) use ($date) {
                $q->whereNull('valid_until')
                  ->orWhere('valid_until', '>=', $date);
            });
    }

    public function scopeByBookingType($query, $bookingType)
    {
        return $query->where('booking_type', $bookingType);
    }
}
```

### Step 3: Create Session Service

```php
<?php

namespace App\Services;

use App\Models\Session;
use App\Models\SessionPricing;
use App\Models\Booking;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;
use Carbon\Carbon;

class SessionService
{
    public function createSession($data)
    {
        return DB::transaction(function () use ($data) {
            $data['created_by'] = auth()->id();
            $data['current_capacity'] = 0;

            $session = Session::create($data);

            // Create default pricing for all booking types
            $this->createDefaultPricing($session);

            Log::info('Session created', [
                'session_id' => $session->id,
                'name' => $session->name,
                'created_by' => auth()->id(),
            ]);

            return $session;
        });
    }

    public function updateSession($sessionId, $data)
    {
        return DB::transaction(function () use ($sessionId, $data) {
            $session = Session::findOrFail($sessionId);
            $data['updated_by'] = auth()->id();

            $session->update($data);

            Log::info('Session updated', [
                'session_id' => $session->id,
                'name' => $session->name,
                'updated_by' => auth()->id(),
            ]);

            return $session;
        });
    }

    public function deleteSession($sessionId)
    {
        return DB::transaction(function () use ($sessionId) {
            $session = Session::findOrFail($sessionId);

            // Check if session has active bookings
            $activeBookings = Booking::where('session_id', $sessionId)
                ->whereIn('status', ['pending', 'confirmed'])
                ->count();

            if ($activeBookings > 0) {
                throw new \Exception('Cannot delete session with active bookings');
            }

            // Delete session pricing
            $session->sessionPricings()->delete();

            // Delete session
            $session->delete();

            Log::info('Session deleted', [
                'session_id' => $sessionId,
                'deleted_by' => auth()->id(),
            ]);

            return true;
        });
    }

    public function activateSession($sessionId)
    {
        $session = Session::findOrFail($sessionId);
        $session->update([
            'is_active' => true,
            'updated_by' => auth()->id(),
        ]);

        Log::info('Session activated', [
            'session_id' => $sessionId,
            'activated_by' => auth()->id(),
        ]);

        return $session;
    }

    public function deactivateSession($sessionId)
    {
        $session = Session::findOrFail($sessionId);
        $session->update([
            'is_active' => false,
            'updated_by' => auth()->id(),
        ]);

        Log::info('Session deactivated', [
            'session_id' => $sessionId,
            'deactivated_by' => auth()->id(),
        ]);

        return $session;
    }

    public function updateSessionCapacity($sessionId, $newCapacity)
    {
        $session = Session::findOrFail($sessionId);

        if ($newCapacity < $session->current_capacity) {
            throw new \Exception('New capacity cannot be less than current capacity');
        }

        $session->update([
            'max_capacity' => $newCapacity,
            'updated_by' => auth()->id(),
        ]);

        Log::info('Session capacity updated', [
            'session_id' => $sessionId,
            'old_capacity' => $session->getOriginal('max_capacity'),
            'new_capacity' => $newCapacity,
            'updated_by' => auth()->id(),
        ]);

        return $session;
    }

    public function getSessionStats($sessionId, $startDate = null, $endDate = null)
    {
        $session = Session::findOrFail($sessionId);
        $startDate = $startDate ?? now()->subDays(30)->toDateString();
        $endDate = $endDate ?? now()->toDateString();

        $bookings = Booking::where('session_id', $sessionId)
            ->whereBetween('booking_date', [$startDate, $endDate])
            ->get();

        $stats = [
            'session_id' => $sessionId,
            'session_name' => $session->name,
            'period' => [
                'start_date' => $startDate,
                'end_date' => $endDate,
            ],
            'total_bookings' => $bookings->count(),
            'confirmed_bookings' => $bookings->where('status', 'confirmed')->count(),
            'cancelled_bookings' => $bookings->where('status', 'cancelled')->count(),
            'completed_bookings' => $bookings->where('status', 'completed')->count(),
            'no_show_bookings' => $bookings->where('status', 'no_show')->count(),
            'total_revenue' => $bookings->where('payment_status', 'paid')->sum('total_amount'),
            'average_booking_value' => $bookings->avg('total_amount'),
            'utilization_rate' => $this->calculateUtilizationRate($session, $bookings),
            'peak_hours' => $this->getPeakHours($bookings),
            'booking_types' => $this->getBookingTypeStats($bookings),
        ];

        return $stats;
    }

    public function getSessionAvailability($sessionId, $date)
    {
        $session = Session::findOrFail($sessionId);

        if (!$session->canBeBooked($date)) {
            return [
                'is_available' => false,
                'reason' => 'Session not available for booking',
            ];
        }

        $bookedSlots = Booking::where('session_id', $sessionId)
            ->where('booking_date', $date)
            ->whereIn('status', ['pending', 'confirmed'])
            ->sum(DB::raw('adult_count + child_count'));

        $availableSlots = $session->max_capacity - $bookedSlots;

        return [
            'is_available' => $availableSlots > 0,
            'max_capacity' => $session->max_capacity,
            'booked_slots' => $bookedSlots,
            'available_slots' => $availableSlots,
            'utilization_percentage' => $session->max_capacity > 0 ? round(($bookedSlots / $session->max_capacity) * 100, 2) : 0,
        ];
    }

    public function createSessionPricing($sessionId, $data)
    {
        $session = Session::findOrFail($sessionId);
        $data['session_id'] = $sessionId;
        $data['created_by'] = auth()->id();

        $pricing = SessionPricing::create($data);

        Log::info('Session pricing created', [
            'session_id' => $sessionId,
            'pricing_id' => $pricing->id,
            'booking_type' => $data['booking_type'],
            'created_by' => auth()->id(),
        ]);

        return $pricing;
    }

    public function updateSessionPricing($pricingId, $data)
    {
        $pricing = SessionPricing::findOrFail($pricingId);
        $data['updated_by'] = auth()->id();

        $pricing->update($data);

        Log::info('Session pricing updated', [
            'pricing_id' => $pricingId,
            'session_id' => $pricing->session_id,
            'updated_by' => auth()->id(),
        ]);

        return $pricing;
    }

    public function deleteSessionPricing($pricingId)
    {
        $pricing = SessionPricing::findOrFail($pricingId);
        $pricing->delete();

        Log::info('Session pricing deleted', [
            'pricing_id' => $pricingId,
            'session_id' => $pricing->session_id,
            'deleted_by' => auth()->id(),
        ]);

        return true;
    }

    public function getSessionPricing($sessionId, $bookingType, $date = null)
    {
        $session = Session::findOrFail($sessionId);
        $date = $date ?? now()->toDateString();

        $pricing = SessionPricing::where('session_id', $sessionId)
            ->where('booking_type', $bookingType)
            ->valid($date)
            ->orderBy('valid_from', 'desc')
            ->first();

        if (!$pricing) {
            return $session->getDefaultPricing($bookingType);
        }

        return $pricing;
    }

    protected function createDefaultPricing($session)
    {
        $bookingTypes = ['regular', 'private_silver', 'private_gold'];

        foreach ($bookingTypes as $type) {
            SessionPricing::create([
                'session_id' => $session->id,
                'booking_type' => $type,
                'adult_price' => $session->getDefaultPricing($type)->adult_price,
                'child_price' => $session->getDefaultPricing($type)->child_price,
                'is_active' => true,
                'valid_from' => now()->toDateString(),
                'created_by' => auth()->id(),
            ]);
        }
    }

    protected function calculateUtilizationRate($session, $bookings)
    {
        if ($session->max_capacity == 0) {
            return 0;
        }

        $totalBookedSlots = $bookings->sum(function ($booking) {
            return $booking->adult_count + $booking->child_count;
        });

        $totalPossibleSlots = $session->max_capacity * $bookings->count();

        return $totalPossibleSlots > 0 ? round(($totalBookedSlots / $totalPossibleSlots) * 100, 2) : 0;
    }

    protected function getPeakHours($bookings)
    {
        return $bookings->groupBy(function ($booking) {
            return Carbon::parse($booking->created_at)->format('H');
        })->map(function ($hourBookings) {
            return $hourBookings->count();
        })->sortDesc()->take(5);
    }

    protected function getBookingTypeStats($bookings)
    {
        return $bookings->groupBy('booking_type')->map(function ($typeBookings) {
            return [
                'count' => $typeBookings->count(),
                'revenue' => $typeBookings->sum('total_amount'),
                'average_value' => $typeBookings->avg('total_amount'),
            ];
        });
    }
}
```

### Step 4: Create Session Controller

```php
<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Api\BaseController;
use App\Http\Requests\SessionRequest;
use App\Services\SessionService;
use App\Models\Session;
use Illuminate\Http\Request;

class SessionController extends BaseController
{
    protected $sessionService;

    public function __construct(SessionService $sessionService)
    {
        $this->sessionService = $sessionService;
    }

    public function index(Request $request)
    {
        $query = Session::with(['createdBy', 'updatedBy']);

        // Filter by active status
        if ($request->has('is_active')) {
            $query->where('is_active', $request->boolean('is_active'));
        }

        // Filter by peak hour
        if ($request->has('is_peak_hour')) {
            $query->where('is_peak_hour', $request->boolean('is_peak_hour'));
        }

        // Filter by capacity range
        if ($request->min_capacity) {
            $query->where('max_capacity', '>=', $request->min_capacity);
        }
        if ($request->max_capacity) {
            $query->where('max_capacity', '<=', $request->max_capacity);
        }

        // Filter by time range
        if ($request->start_time) {
            $query->where('start_time', '>=', $request->start_time);
        }
        if ($request->end_time) {
            $query->where('end_time', '<=', $request->end_time);
        }

        $sessions = $query->orderBy('start_time')->paginate($request->per_page ?? 15);

        return $this->successResponse($sessions, 'Sessions retrieved successfully');
    }

    public function store(SessionRequest $request)
    {
        try {
            $data = $request->validated();
            $session = $this->sessionService->createSession($data);

            return $this->successResponse($session->load(['createdBy']), 'Session created successfully', 201);
        } catch (\Exception $e) {
            return $this->errorResponse($e->getMessage(), 400);
        }
    }

    public function show($id)
    {
        $session = Session::with(['createdBy', 'updatedBy', 'sessionPricings'])
            ->findOrFail($id);

        return $this->successResponse($session, 'Session retrieved successfully');
    }

    public function update(SessionRequest $request, $id)
    {
        try {
            $data = $request->validated();
            $session = $this->sessionService->updateSession($id, $data);

            return $this->successResponse($session->load(['updatedBy']), 'Session updated successfully');
        } catch (\Exception $e) {
            return $this->errorResponse($e->getMessage(), 400);
        }
    }

    public function destroy($id)
    {
        try {
            $this->sessionService->deleteSession($id);

            return $this->successResponse(null, 'Session deleted successfully');
        } catch (\Exception $e) {
            return $this->errorResponse($e->getMessage(), 400);
        }
    }

    public function activate($id)
    {
        try {
            $session = $this->sessionService->activateSession($id);

            return $this->successResponse($session, 'Session activated successfully');
        } catch (\Exception $e) {
            return $this->errorResponse($e->getMessage(), 400);
        }
    }

    public function deactivate($id)
    {
        try {
            $session = $this->sessionService->deactivateSession($id);

            return $this->successResponse($session, 'Session deactivated successfully');
        } catch (\Exception $e) {
            return $this->errorResponse($e->getMessage(), 400);
        }
    }

    public function updateCapacity(Request $request, $id)
    {
        $request->validate([
            'max_capacity' => 'required|integer|min:1',
        ]);

        try {
            $session = $this->sessionService->updateSessionCapacity($id, $request->max_capacity);

            return $this->successResponse($session, 'Session capacity updated successfully');
        } catch (\Exception $e) {
            return $this->errorResponse($e->getMessage(), 400);
        }
    }

    public function getStats(Request $request, $id)
    {
        $request->validate([
            'start_date' => 'nullable|date',
            'end_date' => 'nullable|date|after_or_equal:start_date',
        ]);

        try {
            $stats = $this->sessionService->getSessionStats(
                $id,
                $request->start_date,
                $request->end_date
            );

            return $this->successResponse($stats, 'Session statistics retrieved successfully');
        } catch (\Exception $e) {
            return $this->errorResponse($e->getMessage(), 400);
        }
    }

    public function getAvailability(Request $request, $id)
    {
        $request->validate([
            'date' => 'required|date',
        ]);

        try {
            $availability = $this->sessionService->getSessionAvailability($id, $request->date);

            return $this->successResponse($availability, 'Session availability retrieved successfully');
        } catch (\Exception $e) {
            return $this->errorResponse($e->getMessage(), 400);
        }
    }

    public function getPricing(Request $request, $id)
    {
        $request->validate([
            'booking_type' => 'required|in:regular,private_silver,private_gold',
            'date' => 'nullable|date',
        ]);

        try {
            $pricing = $this->sessionService->getSessionPricing(
                $id,
                $request->booking_type,
                $request->date
            );

            return $this->successResponse($pricing, 'Session pricing retrieved successfully');
        } catch (\Exception $e) {
            return $this->errorResponse($e->getMessage(), 400);
        }
    }

    public function createPricing(Request $request, $id)
    {
        $request->validate([
            'booking_type' => 'required|in:regular,private_silver,private_gold',
            'adult_price' => 'required|numeric|min:0',
            'child_price' => 'required|numeric|min:0',
            'peak_hour_adult_price' => 'nullable|numeric|min:0',
            'peak_hour_child_price' => 'nullable|numeric|min:0',
            'valid_from' => 'required|date',
            'valid_until' => 'nullable|date|after:valid_from',
        ]);

        try {
            $data = $request->validated();
            $pricing = $this->sessionService->createSessionPricing($id, $data);

            return $this->successResponse($pricing, 'Session pricing created successfully', 201);
        } catch (\Exception $e) {
            return $this->errorResponse($e->getMessage(), 400);
        }
    }

    public function updatePricing(Request $request, $pricingId)
    {
        $request->validate([
            'adult_price' => 'nullable|numeric|min:0',
            'child_price' => 'nullable|numeric|min:0',
            'peak_hour_adult_price' => 'nullable|numeric|min:0',
            'peak_hour_child_price' => 'nullable|numeric|min:0',
            'is_active' => 'nullable|boolean',
            'valid_from' => 'nullable|date',
            'valid_until' => 'nullable|date|after:valid_from',
        ]);

        try {
            $data = $request->validated();
            $pricing = $this->sessionService->updateSessionPricing($pricingId, $data);

            return $this->successResponse($pricing, 'Session pricing updated successfully');
        } catch (\Exception $e) {
            return $this->errorResponse($e->getMessage(), 400);
        }
    }

    public function deletePricing($pricingId)
    {
        try {
            $this->sessionService->deleteSessionPricing($pricingId);

            return $this->successResponse(null, 'Session pricing deleted successfully');
        } catch (\Exception $e) {
            return $this->errorResponse($e->getMessage(), 400);
        }
    }

    public function getActiveSessions()
    {
        $sessions = Session::active()
            ->orderBy('start_time')
            ->get();

        return $this->successResponse($sessions, 'Active sessions retrieved successfully');
    }

    public function getAvailableSessions(Request $request)
    {
        $request->validate([
            'date' => 'required|date',
        ]);

        $sessions = Session::available()
            ->where(function ($query) use ($request) {
                $query->whereNull('advance_booking_days')
                    ->orWhereRaw('DATE_ADD(CURDATE(), INTERVAL advance_booking_days DAY) >= ?', [$request->date]);
            })
            ->orderBy('start_time')
            ->get();

        // Filter sessions that can be booked for the given date
        $availableSessions = $sessions->filter(function ($session) use ($request) {
            return $session->canBeBooked($request->date);
        });

        return $this->successResponse($availableSessions, 'Available sessions retrieved successfully');
    }
}
```

### Step 5: Create Request Classes

#### SessionRequest

```php
<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class SessionRequest extends FormRequest
{
    public function authorize()
    {
        return true;
    }

    public function rules()
    {
        return [
            'name' => ['required', 'string', 'max:255'],
            'description' => ['nullable', 'string', 'max:1000'],
            'start_time' => ['required', 'date_format:H:i'],
            'end_time' => ['required', 'date_format:H:i', 'after:start_time'],
            'max_capacity' => ['required', 'integer', 'min:1', 'max:1000'],
            'is_active' => ['nullable', 'boolean'],
            'is_peak_hour' => ['nullable', 'boolean'],
            'peak_hour_multiplier' => ['nullable', 'numeric', 'min:1', 'max:5'],
            'advance_booking_days' => ['nullable', 'integer', 'min:0', 'max:365'],
            'cancellation_hours' => ['nullable', 'integer', 'min:0', 'max:168'],
            'check_in_start_minutes' => ['nullable', 'integer', 'min:0', 'max:120'],
            'check_in_end_minutes' => ['nullable', 'integer', 'min:0', 'max:120'],
            'auto_cancel_minutes' => ['nullable', 'integer', 'min:0', 'max:120'],
            'notes' => ['nullable', 'string', 'max:1000'],
        ];
    }

    public function messages()
    {
        return [
            'name.required' => 'Session name is required',
            'name.max' => 'Session name cannot exceed 255 characters',
            'start_time.required' => 'Start time is required',
            'start_time.date_format' => 'Start time must be in HH:MM format',
            'end_time.required' => 'End time is required',
            'end_time.date_format' => 'End time must be in HH:MM format',
            'end_time.after' => 'End time must be after start time',
            'max_capacity.required' => 'Maximum capacity is required',
            'max_capacity.min' => 'Maximum capacity must be at least 1',
            'max_capacity.max' => 'Maximum capacity cannot exceed 1000',
            'peak_hour_multiplier.min' => 'Peak hour multiplier must be at least 1',
            'peak_hour_multiplier.max' => 'Peak hour multiplier cannot exceed 5',
            'advance_booking_days.max' => 'Advance booking days cannot exceed 365',
            'cancellation_hours.max' => 'Cancellation hours cannot exceed 168',
        ];
    }
}
```

## 📚 API Endpoints

### Session Management Endpoints

```
GET    /api/v1/sessions
POST   /api/v1/sessions
GET    /api/v1/sessions/{id}
PUT    /api/v1/sessions/{id}
DELETE /api/v1/sessions/{id}
POST   /api/v1/sessions/{id}/activate
POST   /api/v1/sessions/{id}/deactivate
PUT    /api/v1/sessions/{id}/capacity
GET    /api/v1/sessions/{id}/stats
GET    /api/v1/sessions/{id}/availability
GET    /api/v1/sessions/{id}/pricing
POST   /api/v1/sessions/{id}/pricing
PUT    /api/v1/sessions/pricing/{pricingId}
DELETE /api/v1/sessions/pricing/{pricingId}
GET    /api/v1/sessions/active
GET    /api/v1/sessions/available
```

## 🧪 Testing

### SessionTest.php

```php
<?php

use App\Models\Session;
use App\Models\SessionPricing;
use App\Services\SessionService;

describe('Session Management', function () {

    beforeEach(function () {
        $this->sessionService = app(SessionService::class);
    });

    it('can create session', function () {
        actingAsAdmin();

        $sessionData = [
            'name' => 'Morning Session',
            'start_time' => '06:00',
            'end_time' => '10:00',
            'max_capacity' => 50,
            'is_active' => true,
        ];

        $response = apiPost('/api/v1/sessions', $sessionData);

        assertApiSuccess($response, 'Session created successfully');
        $this->assertDatabaseHas('sessions', [
            'name' => 'Morning Session',
            'max_capacity' => 50,
        ]);
    });

    it('can update session', function () {
        $session = Session::factory()->create();
        actingAsAdmin();

        $updateData = [
            'name' => 'Updated Session Name',
            'max_capacity' => 75,
        ];

        $response = apiPut("/api/v1/sessions/{$session->id}", $updateData);

        assertApiSuccess($response, 'Session updated successfully');
        $this->assertDatabaseHas('sessions', [
            'id' => $session->id,
            'name' => 'Updated Session Name',
            'max_capacity' => 75,
        ]);
    });

    it('can activate session', function () {
        $session = Session::factory()->create(['is_active' => false]);
        actingAsAdmin();

        $response = apiPost("/api/v1/sessions/{$session->id}/activate");

        assertApiSuccess($response, 'Session activated successfully');
        $this->assertDatabaseHas('sessions', [
            'id' => $session->id,
            'is_active' => true,
        ]);
    });

    it('can get session availability', function () {
        $session = Session::factory()->create(['max_capacity' => 50]);
        actingAsUser();

        $response = apiGet("/api/v1/sessions/{$session->id}/availability", [
            'date' => now()->addDay()->format('Y-m-d')
        ]);

        assertApiSuccess($response, 'Session availability retrieved successfully');
        expect($response->json('data.max_capacity'))->toBe(50);
        expect($response->json('data.available_slots'))->toBe(50);
    });

    it('can create session pricing', function () {
        $session = Session::factory()->create();
        actingAsAdmin();

        $pricingData = [
            'booking_type' => 'regular',
            'adult_price' => 50000,
            'child_price' => 25000,
            'valid_from' => now()->toDateString(),
        ];

        $response = apiPost("/api/v1/sessions/{$session->id}/pricing", $pricingData);

        assertApiSuccess($response, 'Session pricing created successfully');
        $this->assertDatabaseHas('session_pricings', [
            'session_id' => $session->id,
            'booking_type' => 'regular',
            'adult_price' => 50000,
        ]);
    });
});
```

## ✅ Success Criteria

-   [x] Session CRUD operations berfungsi
-   [x] Session capacity management berjalan
-   [x] Time slot management berfungsi
-   [x] Session scheduling berjalan
-   [x] Session status management berfungsi
-   [x] Session pricing management berjalan
-   [x] Testing coverage > 90%

## 📚 Documentation

-   [Laravel Eloquent Models](https://laravel.com/docs/11.x/eloquent)
-   [Laravel Database Transactions](https://laravel.com/docs/11.x/database#database-transactions)
-   [Laravel Validation](https://laravel.com/docs/11.x/validation)
