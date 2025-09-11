# Branch Pool Management - Phase 7.3

## 📋 Overview

Implementasi sistem manajemen kolam renang per cabang untuk Raujan Pool Syariah. Fitur ini memungkinkan setiap cabang memiliki kolam renang dengan konfigurasi yang berbeda.

## 🎯 Objectives

- **Pool Assignment**: Penugasan kolam renang ke cabang tertentu
- **Branch-specific Pool Configuration**: Konfigurasi kolam per cabang
- **Pool Availability Management**: Manajemen ketersediaan kolam per cabang
- **Pool Pricing per Branch**: Harga kolam per cabang
- **Pool Capacity Management**: Manajemen kapasitas kolam per cabang

## 🏗️ Database Schema

### 3.1 Updated Pools Table

```sql
ALTER TABLE pools ADD COLUMN branch_id BIGINT UNSIGNED NOT NULL AFTER id;
ALTER TABLE pools ADD FOREIGN KEY (branch_id) REFERENCES branches(id) ON DELETE CASCADE;
ALTER TABLE pools ADD INDEX idx_pools_branch (branch_id);
```

### 3.2 Pool Branch Configuration Table

```sql
CREATE TABLE pool_branch_configs (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    pool_id BIGINT UNSIGNED NOT NULL,
    branch_id BIGINT UNSIGNED NOT NULL,
    price_per_hour DECIMAL(10,2) NOT NULL,
    max_capacity INT NOT NULL,
    operating_hours JSON,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP NULL DEFAULT NULL,
    updated_at TIMESTAMP NULL DEFAULT NULL,
    
    FOREIGN KEY (pool_id) REFERENCES pools(id) ON DELETE CASCADE,
    FOREIGN KEY (branch_id) REFERENCES branches(id) ON DELETE CASCADE,
    
    UNIQUE KEY unique_pool_branch (pool_id, branch_id),
    INDEX idx_pool_branch_config_pool (pool_id),
    INDEX idx_pool_branch_config_branch (branch_id)
);
```

## 🔧 Implementation

### 3.1 Migration

```php
<?php
// database/migrations/2024_09_04_000005_add_branch_id_to_pools_table.php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('pools', function (Blueprint $table) {
            $table->foreignId('branch_id')->after('id')->constrained()->onDelete('cascade');
            $table->index('branch_id');
        });
    }

    public function down(): void
    {
        Schema::table('pools', function (Blueprint $table) {
            $table->dropForeign(['branch_id']);
            $table->dropIndex(['branch_id']);
            $table->dropColumn('branch_id');
        });
    }
};
```

### 3.2 Model Updates

```php
<?php
// app/Models/Pool.php - Updated

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Pool extends Model
{
    use HasFactory;

    protected $fillable = [
        'branch_id',
        'name',
        'description',
        'capacity',
        'price_per_hour',
        'is_active'
    ];

    protected $casts = [
        'is_active' => 'boolean',
        'price_per_hour' => 'decimal:2'
    ];

    // Relationships
    public function branch(): BelongsTo
    {
        return $this->belongsTo(Branch::class);
    }

    public function bookings(): HasMany
    {
        return $this->hasMany(Booking::class);
    }

    public function branchConfigs(): HasMany
    {
        return $this->hasMany(PoolBranchConfig::class);
    }

    // Scopes
    public function scopeByBranch($query, $branchId)
    {
        return $query->where('branch_id', $branchId);
    }

    public function scopeActive($query)
    {
        return $query->where('is_active', true);
    }

    // Helper Methods
    public function getPriceForBranch(Branch $branch): float
    {
        $config = $this->branchConfigs()
            ->where('branch_id', $branch->id)
            ->where('is_active', true)
            ->first();
        
        return $config ? $config->price_per_hour : $this->price_per_hour;
    }

    public function getCapacityForBranch(Branch $branch): int
    {
        $config = $this->branchConfigs()
            ->where('branch_id', $branch->id)
            ->where('is_active', true)
            ->first();
        
        return $config ? $config->max_capacity : $this->capacity;
    }
}
```

### 3.3 Service

```php
<?php
// app/Services/BranchPoolService.php

namespace App\Services;

use App\Models\Branch;
use App\Models\Pool;
use App\Models\PoolBranchConfig;
use Illuminate\Database\Eloquent\Collection;

class BranchPoolService
{
    public function getBranchPools(Branch $branch, array $filters = []): Collection
    {
        $query = $branch->pools();
        
        if (isset($filters['is_active'])) {
            $query->where('is_active', $filters['is_active']);
        }
        
        return $query->with(['branchConfigs' => function ($q) use ($branch) {
            $q->where('branch_id', $branch->id);
        }])->get();
    }

    public function createBranchPool(Branch $branch, array $data): Pool
    {
        $data['branch_id'] = $branch->id;
        return Pool::create($data);
    }

    public function updateBranchPool(Pool $pool, array $data): Pool
    {
        $pool->update($data);
        return $pool->fresh();
    }

    public function configurePoolForBranch(Pool $pool, Branch $branch, array $config): PoolBranchConfig
    {
        return PoolBranchConfig::updateOrCreate(
            [
                'pool_id' => $pool->id,
                'branch_id' => $branch->id
            ],
            $config
        );
    }

    public function getPoolAvailability(Pool $pool, string $date, string $timeSlot): array
    {
        $bookings = $pool->bookings()
            ->where('date', $date)
            ->where('time_slot', $timeSlot)
            ->where('status', 'confirmed')
            ->count();
        
        $capacity = $pool->getCapacityForBranch($pool->branch);
        $available = $capacity - $bookings;
        
        return [
            'pool_id' => $pool->id,
            'date' => $date,
            'time_slot' => $timeSlot,
            'total_capacity' => $capacity,
            'booked_slots' => $bookings,
            'available_slots' => max(0, $available),
            'is_available' => $available > 0
        ];
    }

    public function getBranchPoolAvailability(Branch $branch, string $date): Collection
    {
        $pools = $this->getBranchPools($branch, ['is_active' => true]);
        
        return $pools->map(function ($pool) use ($date) {
            $timeSlots = ['08:00-10:00', '10:00-12:00', '12:00-14:00', '14:00-16:00', '16:00-18:00', '18:00-20:00'];
            
            $availability = [];
            foreach ($timeSlots as $timeSlot) {
                $availability[] = $this->getPoolAvailability($pool, $date, $timeSlot);
            }
            
            return [
                'pool' => $pool,
                'availability' => $availability
            ];
        });
    }
}
```

### 3.4 Controller

```php
<?php
// app/Http/Controllers/Api/V1/BranchPoolController.php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Http\Resources\PoolResource;
use App\Models\Branch;
use App\Models\Pool;
use App\Services\BranchPoolService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class BranchPoolController extends Controller
{
    public function __construct(
        private BranchPoolService $branchPoolService
    ) {}

    public function index(Branch $branch, Request $request): JsonResponse
    {
        $filters = $request->only(['is_active']);
        $pools = $this->branchPoolService->getBranchPools($branch, $filters);
        
        return response()->json([
            'success' => true,
            'message' => 'Branch pools retrieved successfully',
            'data' => PoolResource::collection($pools)
        ]);
    }

    public function store(Request $request, Branch $branch): JsonResponse
    {
        $request->validate([
            'name' => 'required|string|max:255',
            'description' => 'string|max:1000',
            'capacity' => 'required|integer|min:1|max:1000',
            'price_per_hour' => 'required|numeric|min:0',
            'is_active' => 'boolean'
        ]);
        
        $pool = $this->branchPoolService->createBranchPool($branch, $request->validated());
        
        return response()->json([
            'success' => true,
            'message' => 'Pool created successfully',
            'data' => new PoolResource($pool)
        ], 201);
    }

    public function show(Pool $pool): JsonResponse
    {
        return response()->json([
            'success' => true,
            'message' => 'Pool retrieved successfully',
            'data' => new PoolResource($pool->load('branch'))
        ]);
    }

    public function update(Request $request, Pool $pool): JsonResponse
    {
        $request->validate([
            'name' => 'sometimes|string|max:255',
            'description' => 'sometimes|string|max:1000',
            'capacity' => 'sometimes|integer|min:1|max:1000',
            'price_per_hour' => 'sometimes|numeric|min:0',
            'is_active' => 'sometimes|boolean'
        ]);
        
        $pool = $this->branchPoolService->updateBranchPool($pool, $request->validated());
        
        return response()->json([
            'success' => true,
            'message' => 'Pool updated successfully',
            'data' => new PoolResource($pool)
        ]);
    }

    public function getAvailability(Pool $pool, Request $request): JsonResponse
    {
        $request->validate([
            'date' => 'required|date|after_or_equal:today',
            'time_slot' => 'required|string'
        ]);
        
        $availability = $this->branchPoolService->getPoolAvailability(
            $pool,
            $request->date,
            $request->time_slot
        );
        
        return response()->json([
            'success' => true,
            'message' => 'Pool availability retrieved successfully',
            'data' => $availability
        ]);
    }

    public function getBranchAvailability(Branch $branch, Request $request): JsonResponse
    {
        $request->validate([
            'date' => 'required|date|after_or_equal:today'
        ]);
        
        $availability = $this->branchPoolService->getBranchPoolAvailability(
            $branch,
            $request->date
        );
        
        return response()->json([
            'success' => true,
            'message' => 'Branch pool availability retrieved successfully',
            'data' => $availability
        ]);
    }
}
```

## 🧪 Testing

### 3.1 Unit Tests

```php
<?php
// tests/Unit/Services/BranchPoolServiceTest.php

namespace Tests\Unit\Services;

use App\Models\Branch;
use App\Models\Pool;
use App\Services\BranchPoolService;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class BranchPoolServiceTest extends TestCase
{
    use RefreshDatabase;

    private BranchPoolService $branchPoolService;

    protected function setUp(): void
    {
        parent::setUp();
        $this->branchPoolService = app(BranchPoolService::class);
    }

    public function test_can_get_branch_pools(): void
    {
        $branch = Branch::factory()->create();
        Pool::factory()->count(3)->create(['branch_id' => $branch->id]);
        
        $pools = $this->branchPoolService->getBranchPools($branch);
        
        $this->assertCount(3, $pools);
        $this->assertTrue($pools->every(fn($pool) => $pool->branch_id === $branch->id));
    }

    public function test_can_create_branch_pool(): void
    {
        $branch = Branch::factory()->create();
        $poolData = [
            'name' => 'Test Pool',
            'description' => 'Test Description',
            'capacity' => 50,
            'price_per_hour' => 25.00,
            'is_active' => true
        ];
        
        $pool = $this->branchPoolService->createBranchPool($branch, $poolData);
        
        $this->assertInstanceOf(Pool::class, $pool);
        $this->assertEquals($branch->id, $pool->branch_id);
        $this->assertEquals('Test Pool', $pool->name);
    }

    public function test_can_get_pool_availability(): void
    {
        $branch = Branch::factory()->create();
        $pool = Pool::factory()->create(['branch_id' => $branch->id, 'capacity' => 50]);
        
        $availability = $this->branchPoolService->getPoolAvailability(
            $pool,
            '2024-12-25',
            '10:00-12:00'
        );
        
        $this->assertArrayHasKey('pool_id', $availability);
        $this->assertArrayHasKey('total_capacity', $availability);
        $this->assertArrayHasKey('available_slots', $availability);
        $this->assertArrayHasKey('is_available', $availability);
        $this->assertEquals(50, $availability['total_capacity']);
    }
}
```

## 📊 API Endpoints

### 3.1 Branch Pool Management

```http
GET /api/v1/branches/{branch_id}/pools
POST /api/v1/branches/{branch_id}/pools
GET /api/v1/pools/{pool_id}
PUT /api/v1/pools/{pool_id}
DELETE /api/v1/pools/{pool_id}
```

### 3.2 Pool Availability

```http
GET /api/v1/pools/{pool_id}/availability
GET /api/v1/branches/{branch_id}/pools/availability
```

## 🎯 Success Criteria

- [ ] Pool assignment to branches working
- [ ] Branch-specific pool configuration working
- [ ] Pool availability management working
- [ ] Pool pricing per branch working
- [ ] Pool capacity management working
- [ ] All tests passing
- [ ] API documentation complete
- [ ] Performance optimized
- [ ] Security implemented
- [ ] Error handling complete

---

**Versi**: 1.0  
**Tanggal**: 4 September 2025  
**Status**: Planning  
**Dependencies**: Phase 7.1-7.2 Complete  
**Key Features**:

- 🏊‍♂️ **Pool Management per Branch** dengan konfigurasi khusus
- 💰 **Branch-specific Pricing** untuk setiap kolam
- 📊 **Pool Availability Management** dengan tracking real-time
- 🧪 **Comprehensive Testing** dengan unit dan feature tests
- 📊 **API Documentation** lengkap dengan examples
- 🔒 **Security & Validation** untuk semua operasi
