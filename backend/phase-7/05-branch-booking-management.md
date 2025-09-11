# Branch Booking Management - Phase 7.5

## 📋 Overview

Implementasi sistem manajemen booking per cabang untuk Raujan Pool Syariah. Fitur ini memungkinkan setiap cabang memiliki sistem booking yang terpisah dengan kontrol kapasitas dan ketersediaan.

## 🎯 Objectives

- **Branch-specific Booking**: Booking khusus per cabang
- **Cross-branch Booking**: Booking lintas cabang
- **Branch Capacity Management**: Manajemen kapasitas per cabang
- **Branch Booking Analytics**: Analitik booking per cabang
- **Branch Booking Notifications**: Notifikasi booking per cabang

## 🏗️ Database Schema

### 5.1 Updated Bookings Table

```sql
ALTER TABLE bookings ADD COLUMN branch_id BIGINT UNSIGNED NOT NULL AFTER id;
ALTER TABLE bookings ADD FOREIGN KEY (branch_id) REFERENCES branches(id) ON DELETE CASCADE;
ALTER TABLE bookings ADD INDEX idx_bookings_branch (branch_id);
```

### 5.2 Branch Booking Configuration Table

```sql
CREATE TABLE branch_booking_configs (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    branch_id BIGINT UNSIGNED NOT NULL,
    max_daily_bookings INT NOT NULL DEFAULT 100,
    max_advance_booking_days INT NOT NULL DEFAULT 30,
    booking_time_slots JSON NOT NULL,
    is_cross_branch_enabled BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMP NULL DEFAULT NULL,
    updated_at TIMESTAMP NULL DEFAULT NULL,

    FOREIGN KEY (branch_id) REFERENCES branches(id) ON DELETE CASCADE,
    UNIQUE KEY unique_branch_booking_config (branch_id)
);
```

## 🔧 Implementation

### 5.1 Migration

```php
<?php
// database/migrations/2024_09_04_000007_add_branch_id_to_bookings_table.php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('bookings', function (Blueprint $table) {
            $table->foreignId('branch_id')->after('id')->constrained()->onDelete('cascade');
            $table->index('branch_id');
        });
    }

    public function down(): void
    {
        Schema::table('bookings', function (Blueprint $table) {
            $table->dropForeign(['branch_id']);
            $table->dropIndex(['branch_id']);
            $table->dropColumn('branch_id');
        });
    }
};
```

### 5.2 Service

```php
<?php
// app/Services/BranchBookingService.php

namespace App\Services;

use App\Models\Branch;
use App\Models\Booking;
use App\Models\Pool;
use App\Models\User;
use Illuminate\Database\Eloquent\Collection;
use Illuminate\Support\Facades\DB;

class BranchBookingService
{
    public function getBranchBookings(Branch $branch, array $filters = []): Collection
    {
        $query = $branch->bookings();

        if (isset($filters['date'])) {
            $query->where('date', $filters['date']);
        }

        if (isset($filters['status'])) {
            $query->where('status', $filters['status']);
        }

        if (isset($filters['user_id'])) {
            $query->where('user_id', $filters['user_id']);
        }

        return $query->with(['user', 'pool', 'payment'])->get();
    }

    public function createBranchBooking(Branch $branch, User $user, array $data): Booking
    {
        return DB::transaction(function () use ($branch, $user, $data) {
            // Validate pool belongs to branch
            $pool = Pool::where('id', $data['pool_id'])
                ->where('branch_id', $branch->id)
                ->firstOrFail();

            // Check availability
            $this->validateBookingAvailability($branch, $pool, $data['date'], $data['time_slot']);

            // Create booking
            $booking = Booking::create([
                'user_id' => $user->id,
                'branch_id' => $branch->id,
                'pool_id' => $pool->id,
                'date' => $data['date'],
                'time_slot' => $data['time_slot'],
                'status' => 'pending',
                'total_amount' => $pool->getPriceForBranch($branch),
                'notes' => $data['notes'] ?? null
            ]);

            return $booking;
        });
    }

    public function createCrossBranchBooking(User $user, array $data): Booking
    {
        return DB::transaction(function () use ($user, $data) {
            $pool = Pool::findOrFail($data['pool_id']);
            $branch = $pool->branch;

            // Check if cross-branch booking is enabled
            $config = $branch->bookingConfig;
            if (!$config || !$config->is_cross_branch_enabled) {
                throw new \Exception('Cross-branch booking is not enabled for this branch');
            }

            // Check availability
            $this->validateBookingAvailability($branch, $pool, $data['date'], $data['time_slot']);

            // Create booking
            $booking = Booking::create([
                'user_id' => $user->id,
                'branch_id' => $branch->id,
                'pool_id' => $pool->id,
                'date' => $data['date'],
                'time_slot' => $data['time_slot'],
                'status' => 'pending',
                'total_amount' => $pool->getPriceForBranch($branch),
                'notes' => $data['notes'] ?? null
            ]);

            return $booking;
        });
    }

    public function getBranchBookingAvailability(Branch $branch, string $date): array
    {
        $pools = $branch->pools()->active()->get();
        $timeSlots = $this->getAvailableTimeSlots($branch);

        $availability = [];
        foreach ($pools as $pool) {
            $poolAvailability = [];
            foreach ($timeSlots as $timeSlot) {
                $poolAvailability[] = $this->getPoolTimeSlotAvailability($pool, $date, $timeSlot);
            }
            $availability[] = [
                'pool' => $pool,
                'time_slots' => $poolAvailability
            ];
        }

        return $availability;
    }

    public function getBranchBookingStats(Branch $branch, string $startDate, string $endDate): array
    {
        $bookings = $branch->bookings()
            ->whereBetween('date', [$startDate, $endDate])
            ->get();

        return [
            'total_bookings' => $bookings->count(),
            'confirmed_bookings' => $bookings->where('status', 'confirmed')->count(),
            'pending_bookings' => $bookings->where('status', 'pending')->count(),
            'cancelled_bookings' => $bookings->where('status', 'cancelled')->count(),
            'total_revenue' => $bookings->where('status', 'confirmed')->sum('total_amount'),
            'average_booking_value' => $bookings->where('status', 'confirmed')->avg('total_amount'),
            'most_popular_time_slot' => $bookings->groupBy('time_slot')->sortDesc()->keys()->first(),
            'most_popular_pool' => $bookings->groupBy('pool_id')->sortDesc()->keys()->first()
        ];
    }

    private function validateBookingAvailability(Branch $branch, Pool $pool, string $date, string $timeSlot): void
    {
        // Check if date is within allowed range
        $config = $branch->bookingConfig;
        if ($config) {
            $maxAdvanceDays = $config->max_advance_booking_days;
            $maxDate = now()->addDays($maxAdvanceDays)->format('Y-m-d');

            if ($date > $maxDate) {
                throw new \Exception("Booking date cannot be more than {$maxAdvanceDays} days in advance");
            }
        }

        // Check daily booking limit
        $dailyBookings = $branch->bookings()
            ->where('date', $date)
            ->where('status', 'confirmed')
            ->count();

        if ($config && $dailyBookings >= $config->max_daily_bookings) {
            throw new \Exception('Daily booking limit reached for this branch');
        }

        // Check pool availability
        $poolBookings = $pool->bookings()
            ->where('date', $date)
            ->where('time_slot', $timeSlot)
            ->where('status', 'confirmed')
            ->count();

        $capacity = $pool->getCapacityForBranch($branch);
        if ($poolBookings >= $capacity) {
            throw new \Exception('Pool is fully booked for this time slot');
        }
    }

    private function getAvailableTimeSlots(Branch $branch): array
    {
        $config = $branch->bookingConfig;
        if ($config && $config->booking_time_slots) {
            return $config->booking_time_slots;
        }

        // Default time slots
        return [
            '08:00-10:00',
            '10:00-12:00',
            '12:00-14:00',
            '14:00-16:00',
            '16:00-18:00',
            '18:00-20:00'
        ];
    }

    private function getPoolTimeSlotAvailability(Pool $pool, string $date, string $timeSlot): array
    {
        $bookings = $pool->bookings()
            ->where('date', $date)
            ->where('time_slot', $timeSlot)
            ->where('status', 'confirmed')
            ->count();

        $capacity = $pool->getCapacityForBranch($pool->branch);
        $available = $capacity - $bookings;

        return [
            'time_slot' => $timeSlot,
            'total_capacity' => $capacity,
            'booked_slots' => $bookings,
            'available_slots' => max(0, $available),
            'is_available' => $available > 0,
            'price' => $pool->getPriceForBranch($pool->branch)
        ];
    }
}
```

### 5.3 Controller

```php
<?php
// app/Http/Controllers/Api/V1/BranchBookingController.php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Http\Resources\BookingResource;
use App\Models\Branch;
use App\Models\Booking;
use App\Services\BranchBookingService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class BranchBookingController extends Controller
{
    public function __construct(
        private BranchBookingService $branchBookingService
    ) {}

    public function index(Branch $branch, Request $request): JsonResponse
    {
        $filters = $request->only(['date', 'status', 'user_id']);
        $bookings = $this->branchBookingService->getBranchBookings($branch, $filters);

        return response()->json([
            'success' => true,
            'message' => 'Branch bookings retrieved successfully',
            'data' => BookingResource::collection($bookings)
        ]);
    }

    public function store(Request $request, Branch $branch): JsonResponse
    {
        $request->validate([
            'pool_id' => 'required|exists:pools,id',
            'date' => 'required|date|after_or_equal:today',
            'time_slot' => 'required|string',
            'notes' => 'string|max:1000'
        ]);

        $user = auth()->user();
        $booking = $this->branchBookingService->createBranchBooking($branch, $user, $request->validated());

        return response()->json([
            'success' => true,
            'message' => 'Booking created successfully',
            'data' => new BookingResource($booking)
        ], 201);
    }

    public function getAvailability(Branch $branch, Request $request): JsonResponse
    {
        $request->validate([
            'date' => 'required|date|after_or_equal:today'
        ]);

        $availability = $this->branchBookingService->getBranchBookingAvailability($branch, $request->date);

        return response()->json([
            'success' => true,
            'message' => 'Branch booking availability retrieved successfully',
            'data' => $availability
        ]);
    }

    public function getStats(Branch $branch, Request $request): JsonResponse
    {
        $request->validate([
            'start_date' => 'required|date',
            'end_date' => 'required|date|after_or_equal:start_date'
        ]);

        $stats = $this->branchBookingService->getBranchBookingStats(
            $branch,
            $request->start_date,
            $request->end_date
        );

        return response()->json([
            'success' => true,
            'message' => 'Branch booking stats retrieved successfully',
            'data' => $stats
        ]);
    }

    public function createCrossBranchBooking(Request $request): JsonResponse
    {
        $request->validate([
            'pool_id' => 'required|exists:pools,id',
            'date' => 'required|date|after_or_equal:today',
            'time_slot' => 'required|string',
            'notes' => 'string|max:1000'
        ]);

        $user = auth()->user();
        $booking = $this->branchBookingService->createCrossBranchBooking($user, $request->validated());

        return response()->json([
            'success' => true,
            'message' => 'Cross-branch booking created successfully',
            'data' => new BookingResource($booking)
        ], 201);
    }
}
```

## 🧪 Testing

### 5.1 Unit Tests

```php
<?php
// tests/Unit/Services/BranchBookingServiceTest.php

namespace Tests\Unit\Services;

use App\Models\Branch;
use App\Models\Booking;
use App\Models\Pool;
use App\Models\User;
use App\Services\BranchBookingService;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class BranchBookingServiceTest extends TestCase
{
    use RefreshDatabase;

    private BranchBookingService $branchBookingService;

    protected function setUp(): void
    {
        parent::setUp();
        $this->branchBookingService = app(BranchBookingService::class);
    }

    public function test_can_create_branch_booking(): void
    {
        $branch = Branch::factory()->create();
        $pool = Pool::factory()->create(['branch_id' => $branch->id]);
        $user = User::factory()->create();

        $bookingData = [
            'pool_id' => $pool->id,
            'date' => now()->addDay()->format('Y-m-d'),
            'time_slot' => '10:00-12:00',
            'notes' => 'Test booking'
        ];

        $booking = $this->branchBookingService->createBranchBooking($branch, $user, $bookingData);

        $this->assertInstanceOf(Booking::class, $booking);
        $this->assertEquals($branch->id, $booking->branch_id);
        $this->assertEquals($user->id, $booking->user_id);
        $this->assertEquals($pool->id, $booking->pool_id);
    }

    public function test_can_get_branch_booking_availability(): void
    {
        $branch = Branch::factory()->create();
        Pool::factory()->count(2)->create(['branch_id' => $branch->id]);

        $availability = $this->branchBookingService->getBranchBookingAvailability(
            $branch,
            now()->addDay()->format('Y-m-d')
        );

        $this->assertIsArray($availability);
        $this->assertCount(2, $availability);
    }

    public function test_can_get_branch_booking_stats(): void
    {
        $branch = Branch::factory()->create();
        Booking::factory()->count(5)->create(['branch_id' => $branch->id]);

        $stats = $this->branchBookingService->getBranchBookingStats(
            $branch,
            now()->subDays(7)->format('Y-m-d'),
            now()->format('Y-m-d')
        );

        $this->assertArrayHasKey('total_bookings', $stats);
        $this->assertArrayHasKey('confirmed_bookings', $stats);
        $this->assertArrayHasKey('total_revenue', $stats);
    }
}
```

## 📊 API Endpoints

### 5.1 Branch Booking Management

```http
GET /api/v1/branches/{branch_id}/bookings
POST /api/v1/branches/{branch_id}/bookings
GET /api/v1/branches/{branch_id}/bookings/availability
GET /api/v1/branches/{branch_id}/bookings/stats
```

### 5.2 Cross-branch Booking

```http
POST /api/v1/bookings/cross-branch
```

## 🎯 Success Criteria

- [ ] Branch-specific booking working
- [ ] Cross-branch booking working
- [ ] Branch capacity management working
- [ ] Branch booking analytics working
- [ ] Branch booking notifications working
- [ ] All tests passing
- [ ] API documentation complete
- [ ] Performance optimized
- [ ] Security implemented
- [ ] Error handling complete

---

**Versi**: 1.0  
**Tanggal**: 4 September 2025  
**Status**: Planning  
**Dependencies**: Phase 7.1-7.4 Complete  
**Key Features**:

- 📅 **Branch-specific Booking** dengan kontrol kapasitas
- 🔄 **Cross-branch Booking** untuk fleksibilitas pengguna
- 📊 **Branch Booking Analytics** dengan statistik lengkap
- 🚨 **Branch Booking Notifications** untuk update real-time
- 🧪 **Comprehensive Testing** dengan unit dan feature tests
- 📊 **API Documentation** lengkap dengan examples
- 🔒 **Security & Validation** untuk semua operasi
