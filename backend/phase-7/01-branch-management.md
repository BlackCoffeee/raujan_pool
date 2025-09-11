# Branch Management - Phase 7.1

## 📋 Overview

Implementasi sistem manajemen cabang untuk Raujan Pool Syariah. Fitur ini memungkinkan admin untuk mengelola multiple cabang kolam renang dengan kontrol terpusat.

## 🎯 Objectives

- **Branch CRUD Operations**: Create, Read, Update, Delete cabang
- **Branch Configuration**: Konfigurasi cabang (jam operasi, kapasitas, dll)
- **Branch Activation/Deactivation**: Aktivasi dan deaktivasi cabang
- **Branch Validation**: Validasi data cabang
- **Branch Search & Filter**: Pencarian dan filter cabang

## 🏗️ Database Schema

### 1.1 Branches Table

```sql
CREATE TABLE branches (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    code VARCHAR(10) NOT NULL UNIQUE,
    name VARCHAR(255) NOT NULL,
    address TEXT NOT NULL,
    phone VARCHAR(20) NOT NULL,
    email VARCHAR(255) NOT NULL,
    latitude DECIMAL(10, 8) NOT NULL,
    longitude DECIMAL(11, 8) NOT NULL,
    operating_hours JSON NOT NULL,
    max_capacity INT NOT NULL DEFAULT 100,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP NULL DEFAULT NULL,
    updated_at TIMESTAMP NULL DEFAULT NULL,

    INDEX idx_branches_code (code),
    INDEX idx_branches_active (is_active),
    INDEX idx_branches_location (latitude, longitude)
);
```

### 1.2 Operating Hours JSON Structure

```json
{
  "monday": {
    "open": "06:00",
    "close": "22:00",
    "is_open": true
  },
  "tuesday": {
    "open": "06:00",
    "close": "22:00",
    "is_open": true
  },
  "wednesday": {
    "open": "06:00",
    "close": "22:00",
    "is_open": true
  },
  "thursday": {
    "open": "06:00",
    "close": "22:00",
    "is_open": true
  },
  "friday": {
    "open": "06:00",
    "close": "22:00",
    "is_open": true
  },
  "saturday": {
    "open": "08:00",
    "close": "20:00",
    "is_open": true
  },
  "sunday": {
    "open": "08:00",
    "close": "20:00",
    "is_open": true
  }
}
```

## 🔧 Implementation

### 1.1 Migration

```php
<?php
// database/migrations/2024_09_04_000001_create_branches_table.php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('branches', function (Blueprint $table) {
            $table->id();
            $table->string('code', 10)->unique();
            $table->string('name');
            $table->text('address');
            $table->string('phone', 20);
            $table->string('email');
            $table->decimal('latitude', 10, 8);
            $table->decimal('longitude', 11, 8);
            $table->json('operating_hours');
            $table->integer('max_capacity')->default(100);
            $table->boolean('is_active')->default(true);
            $table->timestamps();

            $table->index('code');
            $table->index('is_active');
            $table->index(['latitude', 'longitude']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('branches');
    }
};
```

### 1.2 Model

```php
<?php
// app/Models/Branch.php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Branch extends Model
{
    use HasFactory;

    protected $fillable = [
        'code',
        'name',
        'address',
        'phone',
        'email',
        'latitude',
        'longitude',
        'operating_hours',
        'max_capacity',
        'is_active'
    ];

    protected $casts = [
        'operating_hours' => 'array',
        'is_active' => 'boolean',
        'latitude' => 'decimal:8',
        'longitude' => 'decimal:8',
        'max_capacity' => 'integer'
    ];

    // Relationships
    public function users(): HasMany
    {
        return $this->hasMany(User::class);
    }

    public function pools(): HasMany
    {
        return $this->hasMany(Pool::class);
    }

    public function menuItems(): HasMany
    {
        return $this->hasMany(MenuItem::class);
    }

    public function bookings(): HasMany
    {
        return $this->hasMany(Booking::class);
    }

    public function orders(): HasMany
    {
        return $this->hasMany(Order::class);
    }

    // Scopes
    public function scopeActive($query)
    {
        return $query->where('is_active', true);
    }

    public function scopeInactive($query)
    {
        return $query->where('is_active', false);
    }

    // Accessors & Mutators
    public function getOperatingHoursAttribute($value)
    {
        return json_decode($value, true);
    }

    public function setOperatingHoursAttribute($value)
    {
        $this->attributes['operating_hours'] = json_encode($value);
    }

    // Helper Methods
    public function isOpenOn($day): bool
    {
        $hours = $this->operating_hours;
        return isset($hours[$day]) && $hours[$day]['is_open'] ?? false;
    }

    public function getOperatingHoursForDay($day): ?array
    {
        $hours = $this->operating_hours;
        return $hours[$day] ?? null;
    }

    public function isCurrentlyOpen(): bool
    {
        $now = now();
        $day = strtolower($now->format('l'));
        $time = $now->format('H:i');

        $dayHours = $this->getOperatingHoursForDay($day);

        if (!$dayHours || !$dayHours['is_open']) {
            return false;
        }

        return $time >= $dayHours['open'] && $time <= $dayHours['close'];
    }
}
```

### 1.3 Factory

```php
<?php
// database/factories/BranchFactory.php

namespace Database\Factories;

use App\Models\Branch;
use Illuminate\Database\Eloquent\Factories\Factory;

class BranchFactory extends Factory
{
    protected $model = Branch::class;

    public function definition(): array
    {
        return [
            'code' => 'BR' . $this->faker->unique()->numberBetween(1000, 9999),
            'name' => $this->faker->company . ' Pool',
            'address' => $this->faker->address,
            'phone' => $this->faker->phoneNumber,
            'email' => $this->faker->unique()->safeEmail,
            'latitude' => $this->faker->latitude(-6.5, -5.5),
            'longitude' => $this->faker->longitude(106.5, 107.5),
            'operating_hours' => [
                'monday' => ['open' => '06:00', 'close' => '22:00', 'is_open' => true],
                'tuesday' => ['open' => '06:00', 'close' => '22:00', 'is_open' => true],
                'wednesday' => ['open' => '06:00', 'close' => '22:00', 'is_open' => true],
                'thursday' => ['open' => '06:00', 'close' => '22:00', 'is_open' => true],
                'friday' => ['open' => '06:00', 'close' => '22:00', 'is_open' => true],
                'saturday' => ['open' => '08:00', 'close' => '20:00', 'is_open' => true],
                'sunday' => ['open' => '08:00', 'close' => '20:00', 'is_open' => true],
            ],
            'max_capacity' => $this->faker->numberBetween(50, 200),
            'is_active' => $this->faker->boolean(80),
        ];
    }

    public function active(): static
    {
        return $this->state(fn (array $attributes) => [
            'is_active' => true,
        ]);
    }

    public function inactive(): static
    {
        return $this->state(fn (array $attributes) => [
            'is_active' => false,
        ]);
    }
}
```

### 1.4 Form Requests

```php
<?php
// app/Http/Requests/StoreBranchRequest.php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class StoreBranchRequest extends FormRequest
{
    public function authorize(): bool
    {
        return $this->user()->hasRole('admin');
    }

    public function rules(): array
    {
        return [
            'code' => [
                'required',
                'string',
                'max:10',
                'unique:branches,code',
                'regex:/^BR\d{4}$/'
            ],
            'name' => 'required|string|max:255',
            'address' => 'required|string|max:1000',
            'phone' => 'required|string|max:20|regex:/^[\d\s\-\+\(\)]+$/',
            'email' => 'required|email|max:255|unique:branches,email',
            'latitude' => 'required|numeric|between:-90,90',
            'longitude' => 'required|numeric|between:-180,180',
            'operating_hours' => 'required|array',
            'operating_hours.monday' => 'required|array',
            'operating_hours.monday.open' => 'required|date_format:H:i',
            'operating_hours.monday.close' => 'required|date_format:H:i|after:operating_hours.monday.open',
            'operating_hours.monday.is_open' => 'required|boolean',
            'operating_hours.tuesday' => 'required|array',
            'operating_hours.tuesday.open' => 'required|date_format:H:i',
            'operating_hours.tuesday.close' => 'required|date_format:H:i|after:operating_hours.tuesday.open',
            'operating_hours.tuesday.is_open' => 'required|boolean',
            'operating_hours.wednesday' => 'required|array',
            'operating_hours.wednesday.open' => 'required|date_format:H:i',
            'operating_hours.wednesday.close' => 'required|date_format:H:i|after:operating_hours.wednesday.open',
            'operating_hours.wednesday.is_open' => 'required|boolean',
            'operating_hours.thursday' => 'required|array',
            'operating_hours.thursday.open' => 'required|date_format:H:i',
            'operating_hours.thursday.close' => 'required|date_format:H:i|after:operating_hours.thursday.open',
            'operating_hours.thursday.is_open' => 'required|boolean',
            'operating_hours.friday' => 'required|array',
            'operating_hours.friday.open' => 'required|date_format:H:i',
            'operating_hours.friday.close' => 'required|date_format:H:i|after:operating_hours.friday.open',
            'operating_hours.friday.is_open' => 'required|boolean',
            'operating_hours.saturday' => 'required|array',
            'operating_hours.saturday.open' => 'required|date_format:H:i',
            'operating_hours.saturday.close' => 'required|date_format:H:i|after:operating_hours.saturday.open',
            'operating_hours.saturday.is_open' => 'required|boolean',
            'operating_hours.sunday' => 'required|array',
            'operating_hours.sunday.open' => 'required|date_format:H:i',
            'operating_hours.sunday.close' => 'required|date_format:H:i|after:operating_hours.sunday.open',
            'operating_hours.sunday.is_open' => 'required|boolean',
            'max_capacity' => 'required|integer|min:1|max:1000',
            'is_active' => 'boolean'
        ];
    }

    public function messages(): array
    {
        return [
            'code.regex' => 'Branch code must be in format BR followed by 4 digits (e.g., BR0001)',
            'operating_hours.*.close.after' => 'Close time must be after open time',
            'latitude.between' => 'Latitude must be between -90 and 90',
            'longitude.between' => 'Longitude must be between -180 and 180',
        ];
    }
}
```

```php
<?php
// app/Http/Requests/UpdateBranchRequest.php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class UpdateBranchRequest extends FormRequest
{
    public function authorize(): bool
    {
        return $this->user()->hasRole('admin');
    }

    public function rules(): array
    {
        $branchId = $this->route('branch')->id;

        return [
            'code' => [
                'sometimes',
                'string',
                'max:10',
                Rule::unique('branches', 'code')->ignore($branchId),
                'regex:/^BR\d{4}$/'
            ],
            'name' => 'sometimes|string|max:255',
            'address' => 'sometimes|string|max:1000',
            'phone' => 'sometimes|string|max:20|regex:/^[\d\s\-\+\(\)]+$/',
            'email' => [
                'sometimes',
                'email',
                'max:255',
                Rule::unique('branches', 'email')->ignore($branchId)
            ],
            'latitude' => 'sometimes|numeric|between:-90,90',
            'longitude' => 'sometimes|numeric|between:-180,180',
            'operating_hours' => 'sometimes|array',
            'operating_hours.monday' => 'sometimes|array',
            'operating_hours.monday.open' => 'required_with:operating_hours.monday|date_format:H:i',
            'operating_hours.monday.close' => 'required_with:operating_hours.monday|date_format:H:i|after:operating_hours.monday.open',
            'operating_hours.monday.is_open' => 'required_with:operating_hours.monday|boolean',
            'operating_hours.tuesday' => 'sometimes|array',
            'operating_hours.tuesday.open' => 'required_with:operating_hours.tuesday|date_format:H:i',
            'operating_hours.tuesday.close' => 'required_with:operating_hours.tuesday|date_format:H:i|after:operating_hours.tuesday.open',
            'operating_hours.tuesday.is_open' => 'required_with:operating_hours.tuesday|boolean',
            'operating_hours.wednesday' => 'sometimes|array',
            'operating_hours.wednesday.open' => 'required_with:operating_hours.wednesday|date_format:H:i',
            'operating_hours.wednesday.close' => 'required_with:operating_hours.wednesday|date_format:H:i|after:operating_hours.wednesday.open',
            'operating_hours.wednesday.is_open' => 'required_with:operating_hours.wednesday|boolean',
            'operating_hours.thursday' => 'sometimes|array',
            'operating_hours.thursday.open' => 'required_with:operating_hours.thursday|date_format:H:i',
            'operating_hours.thursday.close' => 'required_with:operating_hours.thursday|date_format:H:i|after:operating_hours.thursday.open',
            'operating_hours.thursday.is_open' => 'required_with:operating_hours.thursday|boolean',
            'operating_hours.friday' => 'sometimes|array',
            'operating_hours.friday.open' => 'required_with:operating_hours.friday|date_format:H:i',
            'operating_hours.friday.close' => 'required_with:operating_hours.friday|date_format:H:i|after:operating_hours.friday.open',
            'operating_hours.friday.is_open' => 'required_with:operating_hours.friday|boolean',
            'operating_hours.saturday' => 'sometimes|array',
            'operating_hours.saturday.open' => 'required_with:operating_hours.saturday|date_format:H:i',
            'operating_hours.saturday.close' => 'required_with:operating_hours.saturday|date_format:H:i|after:operating_hours.saturday.open',
            'operating_hours.saturday.is_open' => 'required_with:operating_hours.saturday|boolean',
            'operating_hours.sunday' => 'sometimes|array',
            'operating_hours.sunday.open' => 'required_with:operating_hours.sunday|date_format:H:i',
            'operating_hours.sunday.close' => 'required_with:operating_hours.sunday|date_format:H:i|after:operating_hours.sunday.open',
            'operating_hours.sunday.is_open' => 'required_with:operating_hours.sunday|boolean',
            'max_capacity' => 'sometimes|integer|min:1|max:1000',
            'is_active' => 'sometimes|boolean'
        ];
    }
}
```

### 1.5 Service

```php
<?php
// app/Services/BranchService.php

namespace App\Services;

use App\Models\Branch;
use App\Repositories\BranchRepository;
use Illuminate\Database\Eloquent\Collection;
use Illuminate\Pagination\LengthAwarePaginator;

class BranchService
{
    public function __construct(
        private BranchRepository $branchRepository
    ) {}

    public function getAllBranches(array $filters = []): LengthAwarePaginator
    {
        return $this->branchRepository->getAll($filters);
    }

    public function getActiveBranches(): Collection
    {
        return $this->branchRepository->getActive();
    }

    public function getBranchById(int $id): ?Branch
    {
        return $this->branchRepository->findById($id);
    }

    public function getBranchByCode(string $code): ?Branch
    {
        return $this->branchRepository->findByCode($code);
    }

    public function createBranch(array $data): Branch
    {
        // Validate operating hours
        $this->validateOperatingHours($data['operating_hours']);

        // Generate code if not provided
        if (!isset($data['code'])) {
            $data['code'] = $this->generateBranchCode();
        }

        return $this->branchRepository->create($data);
    }

    public function updateBranch(Branch $branch, array $data): Branch
    {
        // Validate operating hours if provided
        if (isset($data['operating_hours'])) {
            $this->validateOperatingHours($data['operating_hours']);
        }

        return $this->branchRepository->update($branch, $data);
    }

    public function deleteBranch(Branch $branch): bool
    {
        // Check if branch has any related data
        if ($this->hasRelatedData($branch)) {
            throw new \Exception('Cannot delete branch with existing data');
        }

        return $this->branchRepository->delete($branch);
    }

    public function activateBranch(Branch $branch): Branch
    {
        return $this->branchRepository->update($branch, ['is_active' => true]);
    }

    public function deactivateBranch(Branch $branch): Branch
    {
        return $this->branchRepository->update($branch, ['is_active' => false]);
    }

    public function searchBranches(string $query, array $filters = []): Collection
    {
        return $this->branchRepository->search($query, $filters);
    }

    public function getBranchesNearLocation(float $latitude, float $longitude, float $radius = 10): Collection
    {
        return $this->branchRepository->getNearLocation($latitude, $longitude, $radius);
    }

    private function validateOperatingHours(array $operatingHours): void
    {
        $days = ['monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday'];

        foreach ($days as $day) {
            if (!isset($operatingHours[$day])) {
                throw new \InvalidArgumentException("Operating hours for {$day} is required");
            }

            $dayHours = $operatingHours[$day];

            if (!isset($dayHours['open']) || !isset($dayHours['close']) || !isset($dayHours['is_open'])) {
                throw new \InvalidArgumentException("Invalid operating hours format for {$day}");
            }

            if ($dayHours['is_open'] && $dayHours['open'] >= $dayHours['close']) {
                throw new \InvalidArgumentException("Open time must be before close time for {$day}");
            }
        }
    }

    private function generateBranchCode(): string
    {
        $lastBranch = Branch::orderBy('id', 'desc')->first();
        $lastNumber = $lastBranch ? (int) substr($lastBranch->code, 2) : 0;
        $newNumber = $lastNumber + 1;

        return 'BR' . str_pad($newNumber, 4, '0', STR_PAD_LEFT);
    }

    private function hasRelatedData(Branch $branch): bool
    {
        return $branch->users()->exists() ||
               $branch->pools()->exists() ||
               $branch->menuItems()->exists() ||
               $branch->bookings()->exists() ||
               $branch->orders()->exists();
    }
}
```

### 1.6 Repository

```php
<?php
// app/Repositories/BranchRepository.php

namespace App\Repositories;

use App\Models\Branch;
use Illuminate\Database\Eloquent\Collection;
use Illuminate\Pagination\LengthAwarePaginator;

class BranchRepository
{
    public function getAll(array $filters = []): LengthAwarePaginator
    {
        $query = Branch::query();

        // Apply filters
        if (isset($filters['search'])) {
            $query->where(function ($q) use ($filters) {
                $q->where('name', 'like', '%' . $filters['search'] . '%')
                  ->orWhere('code', 'like', '%' . $filters['search'] . '%')
                  ->orWhere('address', 'like', '%' . $filters['search'] . '%');
            });
        }

        if (isset($filters['is_active'])) {
            $query->where('is_active', $filters['is_active']);
        }

        if (isset($filters['sort_by'])) {
            $sortDirection = $filters['sort_direction'] ?? 'asc';
            $query->orderBy($filters['sort_by'], $sortDirection);
        } else {
            $query->orderBy('name');
        }

        return $query->paginate($filters['per_page'] ?? 15);
    }

    public function getActive(): Collection
    {
        return Branch::active()->orderBy('name')->get();
    }

    public function findById(int $id): ?Branch
    {
        return Branch::find($id);
    }

    public function findByCode(string $code): ?Branch
    {
        return Branch::where('code', $code)->first();
    }

    public function create(array $data): Branch
    {
        return Branch::create($data);
    }

    public function update(Branch $branch, array $data): Branch
    {
        $branch->update($data);
        return $branch->fresh();
    }

    public function delete(Branch $branch): bool
    {
        return $branch->delete();
    }

    public function search(string $query, array $filters = []): Collection
    {
        $searchQuery = Branch::query();

        $searchQuery->where(function ($q) use ($query) {
            $q->where('name', 'like', '%' . $query . '%')
              ->orWhere('code', 'like', '%' . $query . '%')
              ->orWhere('address', 'like', '%' . $query . '%')
              ->orWhere('phone', 'like', '%' . $query . '%')
              ->orWhere('email', 'like', '%' . $query . '%');
        });

        if (isset($filters['is_active'])) {
            $searchQuery->where('is_active', $filters['is_active']);
        }

        return $searchQuery->orderBy('name')->get();
    }

    public function getNearLocation(float $latitude, float $longitude, float $radius = 10): Collection
    {
        return Branch::selectRaw("
            *,
            (6371 * acos(cos(radians(?)) * cos(radians(latitude)) * cos(radians(longitude) - radians(?)) + sin(radians(?)) * sin(radians(latitude)))) AS distance
        ", [$latitude, $longitude, $latitude])
        ->having('distance', '<', $radius)
        ->orderBy('distance')
        ->get();
    }
}
```

### 1.7 Controller

```php
<?php
// app/Http/Controllers/Api/V1/BranchController.php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Http\Requests\StoreBranchRequest;
use App\Http\Requests\UpdateBranchRequest;
use App\Http\Resources\BranchResource;
use App\Models\Branch;
use App\Services\BranchService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class BranchController extends Controller
{
    public function __construct(
        private BranchService $branchService
    ) {}

    public function index(Request $request): JsonResponse
    {
        $filters = $request->only(['search', 'is_active', 'sort_by', 'sort_direction', 'per_page']);
        $branches = $this->branchService->getAllBranches($filters);

        return response()->json([
            'success' => true,
            'message' => 'Branches retrieved successfully',
            'data' => BranchResource::collection($branches),
            'meta' => [
                'current_page' => $branches->currentPage(),
                'last_page' => $branches->lastPage(),
                'per_page' => $branches->perPage(),
                'total' => $branches->total()
            ]
        ]);
    }

    public function store(StoreBranchRequest $request): JsonResponse
    {
        $branch = $this->branchService->createBranch($request->validated());

        return response()->json([
            'success' => true,
            'message' => 'Branch created successfully',
            'data' => new BranchResource($branch)
        ], 201);
    }

    public function show(Branch $branch): JsonResponse
    {
        return response()->json([
            'success' => true,
            'message' => 'Branch retrieved successfully',
            'data' => new BranchResource($branch)
        ]);
    }

    public function update(UpdateBranchRequest $request, Branch $branch): JsonResponse
    {
        $branch = $this->branchService->updateBranch($branch, $request->validated());

        return response()->json([
            'success' => true,
            'message' => 'Branch updated successfully',
            'data' => new BranchResource($branch)
        ]);
    }

    public function destroy(Branch $branch): JsonResponse
    {
        $this->branchService->deleteBranch($branch);

        return response()->json([
            'success' => true,
            'message' => 'Branch deleted successfully'
        ]);
    }

    public function activate(Branch $branch): JsonResponse
    {
        $branch = $this->branchService->activateBranch($branch);

        return response()->json([
            'success' => true,
            'message' => 'Branch activated successfully',
            'data' => new BranchResource($branch)
        ]);
    }

    public function deactivate(Branch $branch): JsonResponse
    {
        $branch = $this->branchService->deactivateBranch($branch);

        return response()->json([
            'success' => true,
            'message' => 'Branch deactivated successfully',
            'data' => new BranchResource($branch)
        ]);
    }

    public function search(Request $request): JsonResponse
    {
        $query = $request->get('q');
        $filters = $request->only(['is_active']);

        if (!$query) {
            return response()->json([
                'success' => false,
                'message' => 'Search query is required'
            ], 400);
        }

        $branches = $this->branchService->searchBranches($query, $filters);

        return response()->json([
            'success' => true,
            'message' => 'Search results retrieved successfully',
            'data' => BranchResource::collection($branches)
        ]);
    }

    public function nearLocation(Request $request): JsonResponse
    {
        $request->validate([
            'latitude' => 'required|numeric|between:-90,90',
            'longitude' => 'required|numeric|between:-180,180',
            'radius' => 'numeric|min:0.1|max:100'
        ]);

        $branches = $this->branchService->getBranchesNearLocation(
            $request->latitude,
            $request->longitude,
            $request->get('radius', 10)
        );

        return response()->json([
            'success' => true,
            'message' => 'Nearby branches retrieved successfully',
            'data' => BranchResource::collection($branches)
        ]);
    }
}
```

### 1.8 API Resource

```php
<?php
// app/Http/Resources/BranchResource.php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class BranchResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'code' => $this->code,
            'name' => $this->name,
            'address' => $this->address,
            'phone' => $this->phone,
            'email' => $this->email,
            'latitude' => $this->latitude,
            'longitude' => $this->longitude,
            'operating_hours' => $this->operating_hours,
            'max_capacity' => $this->max_capacity,
            'is_active' => $this->is_active,
            'is_currently_open' => $this->isCurrentlyOpen(),
            'created_at' => $this->created_at,
            'updated_at' => $this->updated_at,
        ];
    }
}
```

## 🧪 Testing

### 1.1 Unit Tests

```php
<?php
// tests/Unit/Services/BranchServiceTest.php

namespace Tests\Unit\Services;

use App\Models\Branch;
use App\Repositories\BranchRepository;
use App\Services\BranchService;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class BranchServiceTest extends TestCase
{
    use RefreshDatabase;

    private BranchService $branchService;
    private BranchRepository $branchRepository;

    protected function setUp(): void
    {
        parent::setUp();
        $this->branchRepository = new BranchRepository();
        $this->branchService = new BranchService($this->branchRepository);
    }

    public function test_can_create_branch(): void
    {
        $branchData = [
            'code' => 'BR0001',
            'name' => 'Test Branch',
            'address' => 'Test Address',
            'phone' => '081234567890',
            'email' => 'test@example.com',
            'latitude' => -6.2,
            'longitude' => 106.816666,
            'operating_hours' => [
                'monday' => ['open' => '06:00', 'close' => '22:00', 'is_open' => true],
                'tuesday' => ['open' => '06:00', 'close' => '22:00', 'is_open' => true],
                'wednesday' => ['open' => '06:00', 'close' => '22:00', 'is_open' => true],
                'thursday' => ['open' => '06:00', 'close' => '22:00', 'is_open' => true],
                'friday' => ['open' => '06:00', 'close' => '22:00', 'is_open' => true],
                'saturday' => ['open' => '08:00', 'close' => '20:00', 'is_open' => true],
                'sunday' => ['open' => '08:00', 'close' => '20:00', 'is_open' => true],
            ],
            'max_capacity' => 100,
            'is_active' => true
        ];

        $branch = $this->branchService->createBranch($branchData);

        $this->assertInstanceOf(Branch::class, $branch);
        $this->assertEquals('BR0001', $branch->code);
        $this->assertEquals('Test Branch', $branch->name);
        $this->assertTrue($branch->is_active);
    }

    public function test_can_activate_branch(): void
    {
        $branch = Branch::factory()->inactive()->create();

        $this->assertFalse($branch->is_active);

        $activatedBranch = $this->branchService->activateBranch($branch);

        $this->assertTrue($activatedBranch->is_active);
    }

    public function test_can_deactivate_branch(): void
    {
        $branch = Branch::factory()->active()->create();

        $this->assertTrue($branch->is_active);

        $deactivatedBranch = $this->branchService->deactivateBranch($branch);

        $this->assertFalse($deactivatedBranch->is_active);
    }

    public function test_throws_exception_when_deleting_branch_with_related_data(): void
    {
        $branch = Branch::factory()->create();

        // Create related data
        $branch->users()->create([
            'name' => 'Test User',
            'email' => 'user@example.com',
            'password' => bcrypt('password'),
            'phone' => '081234567890'
        ]);

        $this->expectException(\Exception::class);
        $this->expectExceptionMessage('Cannot delete branch with existing data');

        $this->branchService->deleteBranch($branch);
    }
}
```

### 1.2 Feature Tests

```php
<?php
// tests/Feature/Api/V1/BranchApiTest.php

namespace Tests\Feature\Api\V1;

use App\Models\Branch;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class BranchApiTest extends TestCase
{
    use RefreshDatabase;

    public function test_can_list_branches(): void
    {
        Branch::factory()->count(3)->create();

        $response = $this->getJson('/api/v1/branches');

        $response->assertStatus(200)
            ->assertJsonStructure([
                'success',
                'message',
                'data' => [
                    '*' => [
                        'id',
                        'code',
                        'name',
                        'address',
                        'phone',
                        'email',
                        'latitude',
                        'longitude',
                        'operating_hours',
                        'max_capacity',
                        'is_active',
                        'is_currently_open',
                        'created_at',
                        'updated_at'
                    ]
                ],
                'meta'
            ]);
    }

    public function test_can_create_branch_as_admin(): void
    {
        $admin = User::factory()->admin()->create();

        $branchData = [
            'code' => 'BR0001',
            'name' => 'Test Branch',
            'address' => 'Test Address',
            'phone' => '081234567890',
            'email' => 'test@example.com',
            'latitude' => -6.2,
            'longitude' => 106.816666,
            'operating_hours' => [
                'monday' => ['open' => '06:00', 'close' => '22:00', 'is_open' => true],
                'tuesday' => ['open' => '06:00', 'close' => '22:00', 'is_open' => true],
                'wednesday' => ['open' => '06:00', 'close' => '22:00', 'is_open' => true],
                'thursday' => ['open' => '06:00', 'close' => '22:00', 'is_open' => true],
                'friday' => ['open' => '06:00', 'close' => '22:00', 'is_open' => true],
                'saturday' => ['open' => '08:00', 'close' => '20:00', 'is_open' => true],
                'sunday' => ['open' => '08:00', 'close' => '20:00', 'is_open' => true],
            ],
            'max_capacity' => 100,
            'is_active' => true
        ];

        $response = $this->actingAs($admin)
            ->postJson('/api/v1/branches', $branchData);

        $response->assertStatus(201)
            ->assertJsonStructure([
                'success',
                'message',
                'data' => [
                    'id',
                    'code',
                    'name',
                    'address',
                    'phone',
                    'email',
                    'latitude',
                    'longitude',
                    'operating_hours',
                    'max_capacity',
                    'is_active',
                    'is_currently_open',
                    'created_at',
                    'updated_at'
                ]
            ]);
    }

    public function test_cannot_create_branch_as_regular_user(): void
    {
        $user = User::factory()->create();

        $branchData = [
            'code' => 'BR0001',
            'name' => 'Test Branch',
            'address' => 'Test Address',
            'phone' => '081234567890',
            'email' => 'test@example.com',
            'latitude' => -6.2,
            'longitude' => 106.816666,
            'operating_hours' => [
                'monday' => ['open' => '06:00', 'close' => '22:00', 'is_open' => true],
            ],
            'max_capacity' => 100
        ];

        $response = $this->actingAs($user)
            ->postJson('/api/v1/branches', $branchData);

        $response->assertStatus(403);
    }

    public function test_can_search_branches(): void
    {
        Branch::factory()->create(['name' => 'Jakarta Branch']);
        Branch::factory()->create(['name' => 'Bandung Branch']);

        $response = $this->getJson('/api/v1/branches/search?q=Jakarta');

        $response->assertStatus(200)
            ->assertJsonCount(1, 'data')
            ->assertJsonPath('data.0.name', 'Jakarta Branch');
    }

    public function test_can_find_branches_near_location(): void
    {
        Branch::factory()->create([
            'name' => 'Nearby Branch',
            'latitude' => -6.2,
            'longitude' => 106.816666
        ]);

        Branch::factory()->create([
            'name' => 'Far Branch',
            'latitude' => -7.0,
            'longitude' => 110.0
        ]);

        $response = $this->getJson('/api/v1/branches/near-location?latitude=-6.2&longitude=106.816666&radius=1');

        $response->assertStatus(200)
            ->assertJsonCount(1, 'data')
            ->assertJsonPath('data.0.name', 'Nearby Branch');
    }
}
```

## 📊 API Endpoints

### 1.1 Public Endpoints

```http
GET /api/v1/branches
GET /api/v1/branches/{id}
GET /api/v1/branches/search?q={query}
GET /api/v1/branches/near-location?latitude={lat}&longitude={lng}&radius={radius}
```

### 1.2 Admin Endpoints

```http
POST /api/v1/branches
PUT /api/v1/branches/{id}
DELETE /api/v1/branches/{id}
POST /api/v1/branches/{id}/activate
POST /api/v1/branches/{id}/deactivate
```

## 🎯 Success Criteria

- [ ] Branch CRUD operations working
- [ ] Branch validation working
- [ ] Branch search functionality working
- [ ] Branch location-based search working
- [ ] Branch activation/deactivation working
- [ ] All tests passing
- [ ] API documentation complete
- [ ] Performance optimized
- [ ] Security implemented
- [ ] Error handling complete

## 📚 Documentation

- API endpoints documented
- Database schema documented
- Business logic documented
- Testing procedures documented
- Success criteria defined
- Migration scripts provided
- Configuration examples provided

---

**Versi**: 1.0  
**Tanggal**: 4 September 2025  
**Status**: Planning  
**Dependencies**: Phase 1-6 Complete  
**Key Features**:

- 🏢 **Branch CRUD Operations** dengan validasi lengkap
- 🔍 **Branch Search & Filter** dengan berbagai kriteria
- 📍 **Location-based Search** untuk mencari cabang terdekat
- ⚡ **Branch Activation/Deactivation** untuk kontrol status
- 🧪 **Comprehensive Testing** dengan unit dan feature tests
- 📊 **API Documentation** lengkap dengan examples
- 🔒 **Security & Validation** untuk semua operasi
