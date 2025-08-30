# Point 2: Booking Management System

## 📋 Overview

Implementasi sistem manajemen booking dengan CRUD operations, validasi, status management, dan business rules.

## 🎯 Objectives

- Booking CRUD operations
- Booking validation rules
- Booking status management
- Booking confirmation system
- Booking cancellation logic
- Booking history tracking

## 📁 Files Structure

```
phase-3/
├── 02-booking-management.md
├── app/Http/Controllers/BookingController.php
├── app/Models/Booking.php
├── app/Http/Requests/BookingRequest.php
└── app/Services/BookingService.php
```

## 🔧 Implementation Steps

### Step 1: Create Booking Model

```php
<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Carbon\Carbon;

class Booking extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id',
        'guest_user_id',
        'session_id',
        'booking_date',
        'booking_type',
        'adult_count',
        'child_count',
        'total_amount',
        'status',
        'payment_status',
        'booking_reference',
        'qr_code',
        'check_in_time',
        'check_out_time',
        'notes',
        'cancellation_reason',
        'cancelled_at',
        'cancelled_by',
    ];

    protected $casts = [
        'booking_date' => 'date',
        'check_in_time' => 'datetime',
        'check_out_time' => 'datetime',
        'cancelled_at' => 'datetime',
        'total_amount' => 'decimal:2',
    ];

    public function user()
    {
        return $this->belongsTo(User::class);
    }

    public function guestUser()
    {
        return $this->belongsTo(GuestUser::class);
    }

    public function session()
    {
        return $this->belongsTo(Session::class);
    }

    public function payment()
    {
        return $this->hasOne(Payment::class);
    }

    public function cancelledBy()
    {
        return $this->belongsTo(User::class, 'cancelled_by');
    }

    public function getTotalGuestsAttribute()
    {
        return $this->adult_count + $this->child_count;
    }

    public function getBookingTypeDisplayAttribute()
    {
        return match($this->booking_type) {
            'regular' => 'Regular Session',
            'private_silver' => 'Private Session (Silver)',
            'private_gold' => 'Private Session (Gold)',
            default => 'Unknown'
        };
    }

    public function getStatusDisplayAttribute()
    {
        return match($this->status) {
            'pending' => 'Pending',
            'confirmed' => 'Confirmed',
            'cancelled' => 'Cancelled',
            'completed' => 'Completed',
            'no_show' => 'No Show',
            default => 'Unknown'
        };
    }

    public function getPaymentStatusDisplayAttribute()
    {
        return match($this->payment_status) {
            'unpaid' => 'Unpaid',
            'paid' => 'Paid',
            'refunded' => 'Refunded',
            'partial_refund' => 'Partial Refund',
            default => 'Unknown'
        };
    }

    public function isPending()
    {
        return $this->status === 'pending';
    }

    public function isConfirmed()
    {
        return $this->status === 'confirmed';
    }

    public function isCancelled()
    {
        return $this->status === 'cancelled';
    }

    public function isCompleted()
    {
        return $this->status === 'completed';
    }

    public function isPaid()
    {
        return $this->payment_status === 'paid';
    }

    public function isUnpaid()
    {
        return $this->payment_status === 'unpaid';
    }

    public function canBeCancelled()
    {
        if ($this->isCancelled()) {
            return false;
        }

        if ($this->isCompleted()) {
            return false;
        }

        // Can cancel up to 1 hour before session start
        $sessionStart = Carbon::parse($this->booking_date . ' ' . $this->session->start_time);
        $cancellationDeadline = $sessionStart->subHour();

        return now()->lt($cancellationDeadline);
    }

    public function canBeConfirmed()
    {
        return $this->isPending() && $this->isPaid();
    }

    public function canCheckIn()
    {
        if (!$this->isConfirmed()) {
            return false;
        }

        if ($this->check_in_time) {
            return false; // Already checked in
        }

        // Can check in 30 minutes before session start
        $sessionStart = Carbon::parse($this->booking_date . ' ' . $this->session->start_time);
        $checkInStart = $sessionStart->subMinutes(30);

        return now()->gte($checkInStart);
    }

    public function canCheckOut()
    {
        return $this->check_in_time && !$this->check_out_time;
    }

    public function calculateTotalAmount()
    {
        $adultPrice = $this->getAdultPrice();
        $childPrice = $this->getChildPrice();

        return ($this->adult_count * $adultPrice) + ($this->child_count * $childPrice);
    }

    public function getAdultPrice()
    {
        return match($this->booking_type) {
            'regular' => 50000,
            'private_silver' => 75000,
            'private_gold' => 100000,
            default => 50000
        };
    }

    public function getChildPrice()
    {
        return match($this->booking_type) {
            'regular' => 25000,
            'private_silver' => 37500,
            'private_gold' => 50000,
            default => 25000
        };
    }

    public function generateBookingReference()
    {
        $prefix = 'BK';
        $date = now()->format('Ymd');
        $random = str_pad(rand(1, 9999), 4, '0', STR_PAD_LEFT);

        return $prefix . $date . $random;
    }

    public function generateQRCode()
    {
        $data = [
            'booking_id' => $this->id,
            'booking_reference' => $this->booking_reference,
            'user_id' => $this->user_id,
            'session_id' => $this->session_id,
            'booking_date' => $this->booking_date->format('Y-m-d'),
        ];

        return base64_encode(json_encode($data));
    }

    public function scopeByUser($query, $userId)
    {
        return $query->where('user_id', $userId);
    }

    public function scopeByGuest($query, $guestUserId)
    {
        return $query->where('guest_user_id', $guestUserId);
    }

    public function scopeByDate($query, $date)
    {
        return $query->where('booking_date', $date);
    }

    public function scopeByDateRange($query, $startDate, $endDate)
    {
        return $query->whereBetween('booking_date', [$startDate, $endDate]);
    }

    public function scopeBySession($query, $sessionId)
    {
        return $query->where('session_id', $sessionId);
    }

    public function scopeByStatus($query, $status)
    {
        return $query->where('status', $status);
    }

    public function scopeByPaymentStatus($query, $paymentStatus)
    {
        return $query->where('payment_status', $paymentStatus);
    }

    public function scopeActive($query)
    {
        return $query->whereIn('status', ['pending', 'confirmed']);
    }

    public function scopeUpcoming($query)
    {
        return $query->where('booking_date', '>=', now()->toDateString())
            ->whereIn('status', ['pending', 'confirmed']);
    }

    public function scopePast($query)
    {
        return $query->where('booking_date', '<', now()->toDateString());
    }
}
```

### Step 2: Create Booking Service

```php
<?php

namespace App\Services;

use App\Models\Booking;
use App\Models\CalendarAvailability;
use App\Models\Session;
use App\Models\User;
use App\Models\GuestUser;
use Carbon\Carbon;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;

class BookingService
{
    public function createBooking($data)
    {
        return DB::transaction(function () use ($data) {
            // Validate booking data
            $this->validateBookingData($data);

            // Check availability
            $this->checkAvailability($data['booking_date'], $data['session_id'], $data['adult_count'] + $data['child_count']);

            // Calculate total amount
            $totalAmount = $this->calculateTotalAmount($data);

            // Create booking
            $booking = Booking::create([
                'user_id' => $data['user_id'] ?? null,
                'guest_user_id' => $data['guest_user_id'] ?? null,
                'session_id' => $data['session_id'],
                'booking_date' => $data['booking_date'],
                'booking_type' => $data['booking_type'],
                'adult_count' => $data['adult_count'],
                'child_count' => $data['child_count'],
                'total_amount' => $totalAmount,
                'status' => 'pending',
                'payment_status' => 'unpaid',
                'booking_reference' => $this->generateUniqueBookingReference(),
                'qr_code' => null, // Will be generated after creation
                'notes' => $data['notes'] ?? null,
            ]);

            // Generate QR code
            $booking->qr_code = $booking->generateQRCode();
            $booking->save();

            // Update availability
            $this->updateAvailability($data['booking_date'], $data['session_id'], $data['adult_count'] + $data['child_count']);

            // Log booking creation
            Log::info('Booking created', [
                'booking_id' => $booking->id,
                'booking_reference' => $booking->booking_reference,
                'user_id' => $booking->user_id,
                'guest_user_id' => $booking->guest_user_id,
            ]);

            return $booking;
        });
    }

    public function confirmBooking($bookingId, $confirmedBy = null)
    {
        $booking = Booking::findOrFail($bookingId);

        if (!$booking->canBeConfirmed()) {
            throw new \Exception('Booking cannot be confirmed');
        }

        $booking->update([
            'status' => 'confirmed',
            'confirmed_at' => now(),
            'confirmed_by' => $confirmedBy,
        ]);

        // Log confirmation
        Log::info('Booking confirmed', [
            'booking_id' => $booking->id,
            'booking_reference' => $booking->booking_reference,
            'confirmed_by' => $confirmedBy,
        ]);

        return $booking;
    }

    public function cancelBooking($bookingId, $reason = null, $cancelledBy = null)
    {
        $booking = Booking::findOrFail($bookingId);

        if (!$booking->canBeCancelled()) {
            throw new \Exception('Booking cannot be cancelled');
        }

        return DB::transaction(function () use ($booking, $reason, $cancelledBy) {
            // Update booking status
            $booking->update([
                'status' => 'cancelled',
                'cancellation_reason' => $reason,
                'cancelled_at' => now(),
                'cancelled_by' => $cancelledBy,
            ]);

            // Release availability slots
            $this->releaseAvailability($booking->booking_date, $booking->session_id, $booking->total_guests);

            // Handle refund if paid
            if ($booking->isPaid()) {
                $this->processRefund($booking);
            }

            // Log cancellation
            Log::info('Booking cancelled', [
                'booking_id' => $booking->id,
                'booking_reference' => $booking->booking_reference,
                'reason' => $reason,
                'cancelled_by' => $cancelledBy,
            ]);

            return $booking;
        });
    }

    public function checkIn($bookingId, $checkedInBy = null)
    {
        $booking = Booking::findOrFail($bookingId);

        if (!$booking->canCheckIn()) {
            throw new \Exception('Booking cannot be checked in');
        }

        $booking->update([
            'check_in_time' => now(),
            'checked_in_by' => $checkedInBy,
        ]);

        // Log check-in
        Log::info('Booking checked in', [
            'booking_id' => $booking->id,
            'booking_reference' => $booking->booking_reference,
            'checked_in_by' => $checkedInBy,
        ]);

        return $booking;
    }

    public function checkOut($bookingId, $checkedOutBy = null)
    {
        $booking = Booking::findOrFail($bookingId);

        if (!$booking->canCheckOut()) {
            throw new \Exception('Booking cannot be checked out');
        }

        $booking->update([
            'check_out_time' => now(),
            'status' => 'completed',
            'checked_out_by' => $checkedOutBy,
        ]);

        // Log check-out
        Log::info('Booking checked out', [
            'booking_id' => $booking->id,
            'booking_reference' => $booking->booking_reference,
            'checked_out_by' => $checkedOutBy,
        ]);

        return $booking;
    }

    public function markAsNoShow($bookingId, $markedBy = null)
    {
        $booking = Booking::findOrFail($bookingId);

        if (!$booking->isConfirmed()) {
            throw new \Exception('Only confirmed bookings can be marked as no show');
        }

        $booking->update([
            'status' => 'no_show',
            'marked_no_show_by' => $markedBy,
            'marked_no_show_at' => now(),
        ]);

        // Log no show
        Log::info('Booking marked as no show', [
            'booking_id' => $booking->id,
            'booking_reference' => $booking->booking_reference,
            'marked_by' => $markedBy,
        ]);

        return $booking;
    }

    public function updateBooking($bookingId, $data)
    {
        $booking = Booking::findOrFail($bookingId);

        if ($booking->isCancelled() || $booking->isCompleted()) {
            throw new \Exception('Cannot update cancelled or completed booking');
        }

        return DB::transaction(function () use ($booking, $data) {
            $oldData = $booking->toArray();

            // If changing date or session, check availability
            if (isset($data['booking_date']) || isset($data['session_id'])) {
                $newDate = $data['booking_date'] ?? $booking->booking_date;
                $newSessionId = $data['session_id'] ?? $booking->session_id;
                $newGuestCount = ($data['adult_count'] ?? $booking->adult_count) + ($data['child_count'] ?? $booking->child_count);

                $this->checkAvailability($newDate, $newSessionId, $newGuestCount, $booking->id);
            }

            // Update booking
            $booking->update($data);

            // Recalculate total amount if guest count changed
            if (isset($data['adult_count']) || isset($data['child_count'])) {
                $booking->total_amount = $booking->calculateTotalAmount();
                $booking->save();
            }

            // Update availability if needed
            if (isset($data['booking_date']) || isset($data['session_id']) || isset($data['adult_count']) || isset($data['child_count'])) {
                $this->updateAvailabilityAfterBookingChange($booking, $oldData);
            }

            return $booking;
        });
    }

    protected function validateBookingData($data)
    {
        // Check if user or guest user is provided
        if (empty($data['user_id']) && empty($data['guest_user_id'])) {
            throw new \Exception('Either user_id or guest_user_id must be provided');
        }

        // Validate booking date is not in the past
        if (Carbon::parse($data['booking_date'])->isPast()) {
            throw new \Exception('Cannot book for past dates');
        }

        // Validate guest count
        if (($data['adult_count'] + $data['child_count']) <= 0) {
            throw new \Exception('At least one guest must be specified');
        }

        // Validate session exists and is active
        $session = Session::find($data['session_id']);
        if (!$session || !$session->is_active) {
            throw new \Exception('Invalid or inactive session');
        }

        // Check if user already has a booking for this date
        if (!empty($data['user_id'])) {
            $existingBooking = Booking::where('user_id', $data['user_id'])
                ->where('booking_date', $data['booking_date'])
                ->whereIn('status', ['pending', 'confirmed'])
                ->first();

            if ($existingBooking) {
                throw new \Exception('User already has a booking for this date');
            }
        }
    }

    protected function checkAvailability($date, $sessionId, $requiredSlots, $excludeBookingId = null)
    {
        $availability = CalendarAvailability::where('date', $date)
            ->where('session_id', $sessionId)
            ->first();

        if (!$availability || !$availability->is_available) {
            throw new \Exception('No availability for the selected date and session');
        }

        // Calculate current booked slots excluding the booking being updated
        $currentBookedSlots = Booking::where('booking_date', $date)
            ->where('session_id', $sessionId)
            ->whereIn('status', ['pending', 'confirmed'])
            ->when($excludeBookingId, function ($query) use ($excludeBookingId) {
                return $query->where('id', '!=', $excludeBookingId);
            })
            ->sum(DB::raw('adult_count + child_count'));

        $availableSlots = $availability->available_slots - $currentBookedSlots;

        if ($availableSlots < $requiredSlots) {
            throw new \Exception('Not enough available slots');
        }
    }

    protected function calculateTotalAmount($data)
    {
        $adultPrice = $this->getPriceByType($data['booking_type'], 'adult');
        $childPrice = $this->getPriceByType($data['booking_type'], 'child');

        return ($data['adult_count'] * $adultPrice) + ($data['child_count'] * $childPrice);
    }

    protected function getPriceByType($bookingType, $guestType)
    {
        $prices = [
            'regular' => ['adult' => 50000, 'child' => 25000],
            'private_silver' => ['adult' => 75000, 'child' => 37500],
            'private_gold' => ['adult' => 100000, 'child' => 50000],
        ];

        return $prices[$bookingType][$guestType] ?? $prices['regular'][$guestType];
    }

    protected function generateUniqueBookingReference()
    {
        do {
            $reference = 'BK' . now()->format('Ymd') . str_pad(rand(1, 9999), 4, '0', STR_PAD_LEFT);
        } while (Booking::where('booking_reference', $reference)->exists());

        return $reference;
    }

    protected function updateAvailability($date, $sessionId, $slots)
    {
        // This is handled by the CalendarService
        // The availability is updated when booking is created
    }

    protected function releaseAvailability($date, $sessionId, $slots)
    {
        // This is handled by the CalendarService
        // The availability is released when booking is cancelled
    }

    protected function processRefund($booking)
    {
        // Implement refund logic
        // This would typically create a refund record and update payment status
        $booking->update(['payment_status' => 'refunded']);
    }

    protected function updateAvailabilityAfterBookingChange($booking, $oldData)
    {
        // Handle availability updates when booking is modified
        // This is a complex operation that needs to:
        // 1. Release slots from old date/session
        // 2. Reserve slots for new date/session
    }
}
```

### Step 3: Create Booking Controller

```php
<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Api\BaseController;
use App\Http\Requests\BookingRequest;
use App\Services\BookingService;
use App\Models\Booking;
use Illuminate\Http\Request;

class BookingController extends BaseController
{
    protected $bookingService;

    public function __construct(BookingService $bookingService)
    {
        $this->bookingService = $bookingService;
    }

    public function index(Request $request)
    {
        $query = Booking::with(['user', 'session', 'payment']);

        // Filter by user
        if ($request->user_id) {
            $query->byUser($request->user_id);
        }

        // Filter by guest user
        if ($request->guest_user_id) {
            $query->byGuest($request->guest_user_id);
        }

        // Filter by date range
        if ($request->start_date && $request->end_date) {
            $query->byDateRange($request->start_date, $request->end_date);
        }

        // Filter by status
        if ($request->status) {
            $query->byStatus($request->status);
        }

        // Filter by payment status
        if ($request->payment_status) {
            $query->byPaymentStatus($request->payment_status);
        }

        $bookings = $query->orderBy('booking_date', 'desc')
            ->orderBy('created_at', 'desc')
            ->paginate($request->per_page ?? 15);

        return $this->successResponse($bookings, 'Bookings retrieved successfully');
    }

    public function store(BookingRequest $request)
    {
        try {
            $data = $request->validated();
            $data['user_id'] = auth()->id();

            $booking = $this->bookingService->createBooking($data);

            return $this->successResponse($booking->load(['user', 'session']), 'Booking created successfully', 201);
        } catch (\Exception $e) {
            return $this->errorResponse($e->getMessage(), 400);
        }
    }

    public function show($id)
    {
        $booking = Booking::with(['user', 'session', 'payment', 'cancelledBy'])
            ->findOrFail($id);

        // Check authorization
        if ($booking->user_id !== auth()->id() && !auth()->user()->hasRole(['admin', 'staff'])) {
            return $this->errorResponse('Access denied', 403);
        }

        return $this->successResponse($booking, 'Booking retrieved successfully');
    }

    public function update(BookingRequest $request, $id)
    {
        try {
            $booking = Booking::findOrFail($id);

            // Check authorization
            if ($booking->user_id !== auth()->id() && !auth()->user()->hasRole(['admin', 'staff'])) {
                return $this->errorResponse('Access denied', 403);
            }

            $data = $request->validated();
            $booking = $this->bookingService->updateBooking($id, $data);

            return $this->successResponse($booking->load(['user', 'session']), 'Booking updated successfully');
        } catch (\Exception $e) {
            return $this->errorResponse($e->getMessage(), 400);
        }
    }

    public function destroy($id)
    {
        try {
            $booking = Booking::findOrFail($id);

            // Check authorization
            if ($booking->user_id !== auth()->id() && !auth()->user()->hasRole(['admin', 'staff'])) {
                return $this->errorResponse('Access denied', 403);
            }

            $this->bookingService->cancelBooking($id, 'Deleted by user', auth()->id());

            return $this->successResponse(null, 'Booking cancelled successfully');
        } catch (\Exception $e) {
            return $this->errorResponse($e->getMessage(), 400);
        }
    }

    public function confirm($id)
    {
        try {
            $booking = $this->bookingService->confirmBooking($id, auth()->id());

            return $this->successResponse($booking, 'Booking confirmed successfully');
        } catch (\Exception $e) {
            return $this->errorResponse($e->getMessage(), 400);
        }
    }

    public function cancel(Request $request, $id)
    {
        $request->validate([
            'reason' => 'nullable|string|max:500',
        ]);

        try {
            $booking = $this->bookingService->cancelBooking($id, $request->reason, auth()->id());

            return $this->successResponse($booking, 'Booking cancelled successfully');
        } catch (\Exception $e) {
            return $this->errorResponse($e->getMessage(), 400);
        }
    }

    public function checkIn($id)
    {
        try {
            $booking = $this->bookingService->checkIn($id, auth()->id());

            return $this->successResponse($booking, 'Booking checked in successfully');
        } catch (\Exception $e) {
            return $this->errorResponse($e->getMessage(), 400);
        }
    }

    public function checkOut($id)
    {
        try {
            $booking = $this->bookingService->checkOut($id, auth()->id());

            return $this->successResponse($booking, 'Booking checked out successfully');
        } catch (\Exception $e) {
            return $this->errorResponse($e->getMessage(), 400);
        }
    }

    public function markNoShow($id)
    {
        try {
            $booking = $this->bookingService->markAsNoShow($id, auth()->id());

            return $this->successResponse($booking, 'Booking marked as no show successfully');
        } catch (\Exception $e) {
            return $this->errorResponse($e->getMessage(), 400);
        }
    }

    public function getMyBookings(Request $request)
    {
        $query = Booking::with(['session', 'payment'])
            ->byUser(auth()->id());

        // Filter by status
        if ($request->status) {
            $query->byStatus($request->status);
        }

        // Filter by date range
        if ($request->start_date && $request->end_date) {
            $query->byDateRange($request->start_date, $request->end_date);
        }

        $bookings = $query->orderBy('booking_date', 'desc')
            ->paginate($request->per_page ?? 15);

        return $this->successResponse($bookings, 'My bookings retrieved successfully');
    }

    public function getBookingByReference($reference)
    {
        $booking = Booking::with(['user', 'session', 'payment'])
            ->where('booking_reference', $reference)
            ->firstOrFail();

        return $this->successResponse($booking, 'Booking retrieved successfully');
    }

    public function getBookingStats(Request $request)
    {
        $query = Booking::query();

        // Filter by date range
        if ($request->start_date && $request->end_date) {
            $query->byDateRange($request->start_date, $request->end_date);
        }

        $stats = [
            'total_bookings' => $query->count(),
            'pending_bookings' => $query->clone()->byStatus('pending')->count(),
            'confirmed_bookings' => $query->clone()->byStatus('confirmed')->count(),
            'cancelled_bookings' => $query->clone()->byStatus('cancelled')->count(),
            'completed_bookings' => $query->clone()->byStatus('completed')->count(),
            'no_show_bookings' => $query->clone()->byStatus('no_show')->count(),
            'total_revenue' => $query->clone()->where('payment_status', 'paid')->sum('total_amount'),
            'average_booking_value' => $query->clone()->avg('total_amount'),
        ];

        return $this->successResponse($stats, 'Booking statistics retrieved successfully');
    }
}
```

### Step 4: Create Request Classes

#### BookingRequest

```php
<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class BookingRequest extends FormRequest
{
    public function authorize()
    {
        return true;
    }

    public function rules()
    {
        return [
            'session_id' => ['required', 'exists:sessions,id'],
            'booking_date' => ['required', 'date', 'after_or_equal:today'],
            'booking_type' => ['required', 'in:regular,private_silver,private_gold'],
            'adult_count' => ['required', 'integer', 'min:0', 'max:10'],
            'child_count' => ['required', 'integer', 'min:0', 'max:10'],
            'notes' => ['nullable', 'string', 'max:500'],
        ];
    }

    public function messages()
    {
        return [
            'session_id.required' => 'Session is required',
            'session_id.exists' => 'Selected session does not exist',
            'booking_date.required' => 'Booking date is required',
            'booking_date.after_or_equal' => 'Booking date must be today or later',
            'booking_type.required' => 'Booking type is required',
            'booking_type.in' => 'Invalid booking type',
            'adult_count.required' => 'Adult count is required',
            'adult_count.min' => 'Adult count must be at least 0',
            'adult_count.max' => 'Adult count cannot exceed 10',
            'child_count.required' => 'Child count is required',
            'child_count.min' => 'Child count must be at least 0',
            'child_count.max' => 'Child count cannot exceed 10',
        ];
    }

    public function withValidator($validator)
    {
        $validator->after(function ($validator) {
            if (($this->adult_count + $this->child_count) <= 0) {
                $validator->errors()->add('guest_count', 'At least one guest must be specified');
            }
        });
    }
}
```

## 📚 API Endpoints

### Booking Management Endpoints

```
GET    /api/v1/bookings
POST   /api/v1/bookings
GET    /api/v1/bookings/{id}
PUT    /api/v1/bookings/{id}
DELETE /api/v1/bookings/{id}
POST   /api/v1/bookings/{id}/confirm
POST   /api/v1/bookings/{id}/cancel
POST   /api/v1/bookings/{id}/check-in
POST   /api/v1/bookings/{id}/check-out
POST   /api/v1/bookings/{id}/no-show
GET    /api/v1/bookings/my
GET    /api/v1/bookings/reference/{reference}
GET    /api/v1/bookings/stats
```

### Request/Response Examples

#### Create Booking

```json
POST /api/v1/bookings
{
    "session_id": 1,
    "booking_date": "2024-01-15",
    "booking_type": "regular",
    "adult_count": 2,
    "child_count": 1,
    "notes": "Family booking"
}

Response:
{
    "success": true,
    "message": "Booking created successfully",
    "data": {
        "id": 1,
        "user_id": 1,
        "session_id": 1,
        "booking_date": "2024-01-15",
        "booking_type": "regular",
        "adult_count": 2,
        "child_count": 1,
        "total_amount": 125000,
        "status": "pending",
        "payment_status": "unpaid",
        "booking_reference": "BK202401150001",
        "qr_code": "eyJib29raW5nX2lkIjoxLCJib29raW5nX3JlZmVyZW5jZSI6IkJLMjAyNDAxMTUwMDAxIn0=",
        "session": {
            "id": 1,
            "name": "Morning Session",
            "start_time": "06:00:00",
            "end_time": "10:00:00"
        }
    }
}
```

## 🧪 Testing

### BookingTest.php

```php
<?php

use App\Models\Booking;
use App\Models\Session;
use App\Models\User;
use App\Services\BookingService;

describe('Booking Management', function () {

    beforeEach(function () {
        $this->bookingService = app(BookingService::class);
    });

    it('can create booking', function () {
        $user = User::factory()->create();
        $session = Session::factory()->create();
        actingAsUser($user);

        $bookingData = [
            'session_id' => $session->id,
            'booking_date' => now()->addDay()->format('Y-m-d'),
            'booking_type' => 'regular',
            'adult_count' => 2,
            'child_count' => 1
        ];

        $response = apiPost('/api/v1/bookings', $bookingData);

        assertApiSuccess($response, 'Booking created successfully');
        $this->assertDatabaseHas('bookings', [
            'user_id' => $user->id,
            'session_id' => $session->id,
            'booking_type' => 'regular'
        ]);
    });

    it('can confirm booking', function () {
        $booking = Booking::factory()->create([
            'status' => 'pending',
            'payment_status' => 'paid'
        ]);
        actingAsAdmin();

        $response = apiPost("/api/v1/bookings/{$booking->id}/confirm");

        assertApiSuccess($response, 'Booking confirmed successfully');
        $this->assertDatabaseHas('bookings', [
            'id' => $booking->id,
            'status' => 'confirmed'
        ]);
    });

    it('can cancel booking', function () {
        $booking = Booking::factory()->create([
            'status' => 'pending',
            'booking_date' => now()->addDay()
        ]);
        actingAsUser($booking->user);

        $response = apiPost("/api/v1/bookings/{$booking->id}/cancel", [
            'reason' => 'Change of plans'
        ]);

        assertApiSuccess($response, 'Booking cancelled successfully');
        $this->assertDatabaseHas('bookings', [
            'id' => $booking->id,
            'status' => 'cancelled'
        ]);
    });

    it('cannot book for past date', function () {
        $user = User::factory()->create();
        $session = Session::factory()->create();
        actingAsUser($user);

        $bookingData = [
            'session_id' => $session->id,
            'booking_date' => now()->subDay()->format('Y-m-d'),
            'booking_type' => 'regular',
            'adult_count' => 2,
            'child_count' => 0
        ];

        $response = apiPost('/api/v1/bookings', $bookingData);

        assertApiValidationError($response, 'booking_date');
    });
});
```

## ✅ Success Criteria

- [ ] Booking CRUD operations berfungsi
- [ ] Booking validation rules terimplementasi
- [ ] Booking status management berjalan
- [ ] Booking confirmation system berfungsi
- [ ] Booking cancellation logic berjalan
- [ ] Booking history tracking berfungsi
- [ ] Business rules terimplementasi
- [ ] Testing coverage > 90%

## 📚 Documentation

- [Laravel Eloquent Models](https://laravel.com/docs/11.x/eloquent)
- [Laravel Database Transactions](https://laravel.com/docs/11.x/database#database-transactions)
- [Laravel Validation](https://laravel.com/docs/11.x/validation)
