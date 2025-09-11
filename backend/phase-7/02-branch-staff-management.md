# Branch Staff Management - Phase 7.2

## 📋 Overview

Implementasi sistem manajemen staff per cabang untuk Raujan Pool Syariah. Fitur ini memungkinkan admin untuk mengelola staff yang bekerja di setiap cabang dengan kontrol akses yang tepat.

## 🎯 Objectives

- **Staff Assignment**: Penugasan staff ke cabang tertentu
- **Branch-specific Permissions**: Permission khusus per cabang
- **Staff Transfer**: Transfer staff antar cabang
- **Staff Scheduling**: Jadwal kerja staff per cabang
- **Staff Performance**: Tracking performa staff per cabang

## 🏗️ Database Schema

### 2.1 Branch Staff Table

```sql
CREATE TABLE branch_staff (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    branch_id BIGINT UNSIGNED NOT NULL,
    user_id BIGINT UNSIGNED NOT NULL,
    role VARCHAR(50) NOT NULL,
    permissions JSON,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    assigned_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    assigned_by BIGINT UNSIGNED,
    created_at TIMESTAMP NULL DEFAULT NULL,
    updated_at TIMESTAMP NULL DEFAULT NULL,
    
    FOREIGN KEY (branch_id) REFERENCES branches(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (assigned_by) REFERENCES users(id) ON DELETE SET NULL,
    
    UNIQUE KEY unique_branch_user (branch_id, user_id),
    INDEX idx_branch_staff_branch (branch_id),
    INDEX idx_branch_staff_user (user_id),
    INDEX idx_branch_staff_active (is_active)
);
```

### 2.2 Staff Schedule Table

```sql
CREATE TABLE staff_schedules (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    branch_staff_id BIGINT UNSIGNED NOT NULL,
    day_of_week TINYINT NOT NULL, -- 1=Monday, 7=Sunday
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP NULL DEFAULT NULL,
    updated_at TIMESTAMP NULL DEFAULT NULL,
    
    FOREIGN KEY (branch_staff_id) REFERENCES branch_staff(id) ON DELETE CASCADE,
    
    INDEX idx_staff_schedule_branch_staff (branch_staff_id),
    INDEX idx_staff_schedule_day (day_of_week),
    INDEX idx_staff_schedule_active (is_active)
);
```

### 2.3 Staff Performance Table

```sql
CREATE TABLE staff_performance (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    branch_staff_id BIGINT UNSIGNED NOT NULL,
    date DATE NOT NULL,
    bookings_handled INT NOT NULL DEFAULT 0,
    orders_processed INT NOT NULL DEFAULT 0,
    customer_rating DECIMAL(3,2),
    notes TEXT,
    created_at TIMESTAMP NULL DEFAULT NULL,
    updated_at TIMESTAMP NULL DEFAULT NULL,
    
    FOREIGN KEY (branch_staff_id) REFERENCES branch_staff(id) ON DELETE CASCADE,
    
    UNIQUE KEY unique_staff_date (branch_staff_id, date),
    INDEX idx_staff_performance_branch_staff (branch_staff_id),
    INDEX idx_staff_performance_date (date)
);
```

## 🔧 Implementation

### 2.1 Migrations

```php
<?php
// database/migrations/2024_09_04_000002_create_branch_staff_table.php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('branch_staff', function (Blueprint $table) {
            $table->id();
            $table->foreignId('branch_id')->constrained()->onDelete('cascade');
            $table->foreignId('user_id')->constrained()->onDelete('cascade');
            $table->string('role', 50);
            $table->json('permissions')->nullable();
            $table->boolean('is_active')->default(true);
            $table->timestamp('assigned_at')->useCurrent();
            $table->foreignId('assigned_by')->nullable()->constrained('users')->onDelete('set null');
            $table->timestamps();
            
            $table->unique(['branch_id', 'user_id']);
            $table->index('branch_id');
            $table->index('user_id');
            $table->index('is_active');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('branch_staff');
    }
};
```

```php
<?php
// database/migrations/2024_09_04_000003_create_staff_schedules_table.php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('staff_schedules', function (Blueprint $table) {
            $table->id();
            $table->foreignId('branch_staff_id')->constrained()->onDelete('cascade');
            $table->tinyInteger('day_of_week'); // 1=Monday, 7=Sunday
            $table->time('start_time');
            $table->time('end_time');
            $table->boolean('is_active')->default(true);
            $table->timestamps();
            
            $table->index('branch_staff_id');
            $table->index('day_of_week');
            $table->index('is_active');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('staff_schedules');
    }
};
```

```php
<?php
// database/migrations/2024_09_04_000004_create_staff_performance_table.php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('staff_performance', function (Blueprint $table) {
            $table->id();
            $table->foreignId('branch_staff_id')->constrained()->onDelete('cascade');
            $table->date('date');
            $table->integer('bookings_handled')->default(0);
            $table->integer('orders_processed')->default(0);
            $table->decimal('customer_rating', 3, 2)->nullable();
            $table->text('notes')->nullable();
            $table->timestamps();
            
            $table->unique(['branch_staff_id', 'date']);
            $table->index('branch_staff_id');
            $table->index('date');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('staff_performance');
    }
};
```

### 2.2 Models

```php
<?php
// app/Models/BranchStaff.php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class BranchStaff extends Model
{
    use HasFactory;

    protected $fillable = [
        'branch_id',
        'user_id',
        'role',
        'permissions',
        'is_active',
        'assigned_at',
        'assigned_by'
    ];

    protected $casts = [
        'permissions' => 'array',
        'is_active' => 'boolean',
        'assigned_at' => 'datetime'
    ];

    // Relationships
    public function branch(): BelongsTo
    {
        return $this->belongsTo(Branch::class);
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    public function assignedBy(): BelongsTo
    {
        return $this->belongsTo(User::class, 'assigned_by');
    }

    public function schedules(): HasMany
    {
        return $this->hasMany(StaffSchedule::class);
    }

    public function performance(): HasMany
    {
        return $this->hasMany(StaffPerformance::class);
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

    public function scopeByBranch($query, $branchId)
    {
        return $query->where('branch_id', $branchId);
    }

    public function scopeByRole($query, $role)
    {
        return $query->where('role', $role);
    }

    // Helper Methods
    public function hasPermission(string $permission): bool
    {
        $permissions = $this->permissions ?? [];
        return in_array($permission, $permissions);
    }

    public function addPermission(string $permission): void
    {
        $permissions = $this->permissions ?? [];
        if (!in_array($permission, $permissions)) {
            $permissions[] = $permission;
            $this->update(['permissions' => $permissions]);
        }
    }

    public function removePermission(string $permission): void
    {
        $permissions = $this->permissions ?? [];
        $permissions = array_filter($permissions, fn($p) => $p !== $permission);
        $this->update(['permissions' => array_values($permissions)]);
    }

    public function getScheduleForDay(int $dayOfWeek): ?StaffSchedule
    {
        return $this->schedules()
            ->where('day_of_week', $dayOfWeek)
            ->where('is_active', true)
            ->first();
    }

    public function isWorkingOnDay(int $dayOfWeek): bool
    {
        return $this->getScheduleForDay($dayOfWeek) !== null;
    }

    public function getPerformanceForDate(string $date): ?StaffPerformance
    {
        return $this->performance()->where('date', $date)->first();
    }
}
```

```php
<?php
// app/Models/StaffSchedule.php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class StaffSchedule extends Model
{
    use HasFactory;

    protected $fillable = [
        'branch_staff_id',
        'day_of_week',
        'start_time',
        'end_time',
        'is_active'
    ];

    protected $casts = [
        'is_active' => 'boolean',
        'start_time' => 'datetime:H:i',
        'end_time' => 'datetime:H:i'
    ];

    // Relationships
    public function branchStaff(): BelongsTo
    {
        return $this->belongsTo(BranchStaff::class);
    }

    // Scopes
    public function scopeActive($query)
    {
        return $query->where('is_active', true);
    }

    public function scopeByDay($query, int $dayOfWeek)
    {
        return $query->where('day_of_week', $dayOfWeek);
    }

    // Helper Methods
    public function getDayName(): string
    {
        $days = [
            1 => 'Monday',
            2 => 'Tuesday',
            3 => 'Wednesday',
            4 => 'Thursday',
            5 => 'Friday',
            6 => 'Saturday',
            7 => 'Sunday'
        ];

        return $days[$this->day_of_week] ?? 'Unknown';
    }

    public function getDurationInHours(): float
    {
        $start = \Carbon\Carbon::createFromTimeString($this->start_time);
        $end = \Carbon\Carbon::createFromTimeString($this->end_time);
        
        return $start->diffInHours($end);
    }
}
```

```php
<?php
// app/Models/StaffPerformance.php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class StaffPerformance extends Model
{
    use HasFactory;

    protected $fillable = [
        'branch_staff_id',
        'date',
        'bookings_handled',
        'orders_processed',
        'customer_rating',
        'notes'
    ];

    protected $casts = [
        'date' => 'date',
        'customer_rating' => 'decimal:2'
    ];

    // Relationships
    public function branchStaff(): BelongsTo
    {
        return $this->belongsTo(BranchStaff::class);
    }

    // Scopes
    public function scopeByDateRange($query, string $startDate, string $endDate)
    {
        return $query->whereBetween('date', [$startDate, $endDate]);
    }

    public function scopeByBranch($query, int $branchId)
    {
        return $query->whereHas('branchStaff', function ($q) use ($branchId) {
            $q->where('branch_id', $branchId);
        });
    }

    // Helper Methods
    public function getTotalTasks(): int
    {
        return $this->bookings_handled + $this->orders_processed;
    }

    public function getEfficiencyScore(): float
    {
        $totalTasks = $this->getTotalTasks();
        $rating = $this->customer_rating ?? 0;
        
        // Simple efficiency calculation
        return ($totalTasks * 0.7) + ($rating * 0.3);
    }
}
```

### 2.3 Form Requests

```php
<?php
// app/Http/Requests/AssignStaffToBranchRequest.php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class AssignStaffToBranchRequest extends FormRequest
{
    public function authorize(): bool
    {
        return $this->user()->hasRole('admin');
    }

    public function rules(): array
    {
        return [
            'user_id' => [
                'required',
                'exists:users,id',
                Rule::unique('branch_staff')->where(function ($query) {
                    return $query->where('branch_id', $this->route('branch')->id);
                })
            ],
            'role' => 'required|string|in:manager,supervisor,staff,cashier',
            'permissions' => 'array',
            'permissions.*' => 'string|in:booking_management,order_management,inventory_management,payment_verification,user_management,analytics_view',
            'is_active' => 'boolean'
        ];
    }

    public function messages(): array
    {
        return [
            'user_id.unique' => 'This user is already assigned to this branch',
            'role.in' => 'Role must be one of: manager, supervisor, staff, cashier',
            'permissions.*.in' => 'Invalid permission'
        ];
    }
}
```

```php
<?php
// app/Http/Requests/CreateStaffScheduleRequest.php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class CreateStaffScheduleRequest extends FormRequest
{
    public function authorize(): bool
    {
        return $this->user()->hasRole('admin') || $this->user()->hasRole('manager');
    }

    public function rules(): array
    {
        return [
            'schedules' => 'required|array|min:1',
            'schedules.*.day_of_week' => 'required|integer|between:1,7',
            'schedules.*.start_time' => 'required|date_format:H:i',
            'schedules.*.end_time' => 'required|date_format:H:i|after:schedules.*.start_time',
            'schedules.*.is_active' => 'boolean'
        ];
    }

    public function messages(): array
    {
        return [
            'schedules.*.day_of_week.between' => 'Day of week must be between 1 (Monday) and 7 (Sunday)',
            'schedules.*.end_time.after' => 'End time must be after start time'
        ];
    }
}
```

### 2.4 Services

```php
<?php
// app/Services/BranchStaffService.php

namespace App\Services;

use App\Models\Branch;
use App\Models\BranchStaff;
use App\Models\StaffSchedule;
use App\Models\StaffPerformance;
use App\Models\User;
use Illuminate\Database\Eloquent\Collection;
use Illuminate\Support\Facades\DB;

class BranchStaffService
{
    public function assignStaffToBranch(Branch $branch, User $user, array $data): BranchStaff
    {
        return DB::transaction(function () use ($branch, $user, $data) {
            $branchStaff = BranchStaff::create([
                'branch_id' => $branch->id,
                'user_id' => $user->id,
                'role' => $data['role'],
                'permissions' => $data['permissions'] ?? [],
                'is_active' => $data['is_active'] ?? true,
                'assigned_by' => auth()->id()
            ]);

            // Update user's branch_id
            $user->update(['branch_id' => $branch->id]);

            return $branchStaff;
        });
    }

    public function removeStaffFromBranch(BranchStaff $branchStaff): bool
    {
        return DB::transaction(function () use ($branchStaff) {
            // Remove all schedules
            $branchStaff->schedules()->delete();
            
            // Remove all performance records
            $branchStaff->performance()->delete();
            
            // Update user's branch_id to null
            $branchStaff->user->update(['branch_id' => null]);
            
            // Delete branch staff record
            return $branchStaff->delete();
        });
    }

    public function transferStaff(BranchStaff $branchStaff, Branch $newBranch, array $data = []): BranchStaff
    {
        return DB::transaction(function () use ($branchStaff, $newBranch, $data) {
            // Update branch_id
            $branchStaff->update(['branch_id' => $newBranch->id]);
            
            // Update user's branch_id
            $branchStaff->user->update(['branch_id' => $newBranch->id]);
            
            // Update role and permissions if provided
            if (!empty($data)) {
                $branchStaff->update($data);
            }
            
            return $branchStaff->fresh();
        });
    }

    public function getBranchStaff(Branch $branch, array $filters = []): Collection
    {
        $query = $branch->staff();
        
        if (isset($filters['role'])) {
            $query->where('role', $filters['role']);
        }
        
        if (isset($filters['is_active'])) {
            $query->where('is_active', $filters['is_active']);
        }
        
        return $query->with(['user', 'schedules', 'performance'])->get();
    }

    public function getStaffSchedule(BranchStaff $branchStaff): Collection
    {
        return $branchStaff->schedules()->active()->orderBy('day_of_week')->get();
    }

    public function createStaffSchedule(BranchStaff $branchStaff, array $schedules): Collection
    {
        return DB::transaction(function () use ($branchStaff, $schedules) {
            // Delete existing schedules
            $branchStaff->schedules()->delete();
            
            // Create new schedules
            $createdSchedules = collect();
            foreach ($schedules as $schedule) {
                $createdSchedules->push(
                    $branchStaff->schedules()->create($schedule)
                );
            }
            
            return $createdSchedules;
        });
    }

    public function updateStaffSchedule(StaffSchedule $schedule, array $data): StaffSchedule
    {
        $schedule->update($data);
        return $schedule->fresh();
    }

    public function recordStaffPerformance(BranchStaff $branchStaff, array $data): StaffPerformance
    {
        return StaffPerformance::updateOrCreate(
            [
                'branch_staff_id' => $branchStaff->id,
                'date' => $data['date']
            ],
            $data
        );
    }

    public function getStaffPerformance(BranchStaff $branchStaff, string $startDate, string $endDate): Collection
    {
        return $branchStaff->performance()
            ->whereBetween('date', [$startDate, $endDate])
            ->orderBy('date')
            ->get();
    }

    public function getBranchStaffPerformance(Branch $branch, string $startDate, string $endDate): Collection
    {
        return StaffPerformance::with(['branchStaff.user'])
            ->whereHas('branchStaff', function ($query) use ($branch) {
                $query->where('branch_id', $branch->id);
            })
            ->whereBetween('date', [$startDate, $endDate])
            ->orderBy('date')
            ->get();
    }

    public function getStaffWorkingToday(Branch $branch): Collection
    {
        $today = now();
        $dayOfWeek = $today->dayOfWeek === 0 ? 7 : $today->dayOfWeek; // Convert Sunday from 0 to 7
        
        return $branch->staff()
            ->whereHas('schedules', function ($query) use ($dayOfWeek, $today) {
                $query->where('day_of_week', $dayOfWeek)
                      ->where('is_active', true)
                      ->whereTime('start_time', '<=', $today->format('H:i:s'))
                      ->whereTime('end_time', '>=', $today->format('H:i:s'));
            })
            ->with(['user', 'schedules' => function ($query) use ($dayOfWeek) {
                $query->where('day_of_week', $dayOfWeek);
            }])
            ->get();
    }

    public function updateStaffPermissions(BranchStaff $branchStaff, array $permissions): BranchStaff
    {
        $branchStaff->update(['permissions' => $permissions]);
        return $branchStaff->fresh();
    }

    public function activateStaff(BranchStaff $branchStaff): BranchStaff
    {
        $branchStaff->update(['is_active' => true]);
        return $branchStaff->fresh();
    }

    public function deactivateStaff(BranchStaff $branchStaff): BranchStaff
    {
        $branchStaff->update(['is_active' => false]);
        return $branchStaff->fresh();
    }
}
```

### 2.5 Controllers

```php
<?php
// app/Http/Controllers/Api/V1/BranchStaffController.php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Http\Requests\AssignStaffToBranchRequest;
use App\Http\Requests\CreateStaffScheduleRequest;
use App\Http\Resources\BranchStaffResource;
use App\Http\Resources\StaffScheduleResource;
use App\Http\Resources\StaffPerformanceResource;
use App\Models\Branch;
use App\Models\BranchStaff;
use App\Services\BranchStaffService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class BranchStaffController extends Controller
{
    public function __construct(
        private BranchStaffService $branchStaffService
    ) {}

    public function index(Branch $branch, Request $request): JsonResponse
    {
        $filters = $request->only(['role', 'is_active']);
        $staff = $this->branchStaffService->getBranchStaff($branch, $filters);
        
        return response()->json([
            'success' => true,
            'message' => 'Branch staff retrieved successfully',
            'data' => BranchStaffResource::collection($staff)
        ]);
    }

    public function store(AssignStaffToBranchRequest $request, Branch $branch): JsonResponse
    {
        $user = \App\Models\User::findOrFail($request->user_id);
        $branchStaff = $this->branchStaffService->assignStaffToBranch($branch, $user, $request->validated());
        
        return response()->json([
            'success' => true,
            'message' => 'Staff assigned to branch successfully',
            'data' => new BranchStaffResource($branchStaff)
        ], 201);
    }

    public function show(BranchStaff $branchStaff): JsonResponse
    {
        return response()->json([
            'success' => true,
            'message' => 'Branch staff retrieved successfully',
            'data' => new BranchStaffResource($branchStaff->load(['user', 'schedules', 'performance']))
        ]);
    }

    public function destroy(BranchStaff $branchStaff): JsonResponse
    {
        $this->branchStaffService->removeStaffFromBranch($branchStaff);
        
        return response()->json([
            'success' => true,
            'message' => 'Staff removed from branch successfully'
        ]);
    }

    public function transfer(Request $request, BranchStaff $branchStaff): JsonResponse
    {
        $request->validate([
            'new_branch_id' => 'required|exists:branches,id',
            'role' => 'sometimes|string|in:manager,supervisor,staff,cashier',
            'permissions' => 'sometimes|array',
            'permissions.*' => 'string|in:booking_management,order_management,inventory_management,payment_verification,user_management,analytics_view'
        ]);
        
        $newBranch = Branch::findOrFail($request->new_branch_id);
        $data = $request->only(['role', 'permissions']);
        
        $branchStaff = $this->branchStaffService->transferStaff($branchStaff, $newBranch, $data);
        
        return response()->json([
            'success' => true,
            'message' => 'Staff transferred successfully',
            'data' => new BranchStaffResource($branchStaff)
        ]);
    }

    public function getSchedule(BranchStaff $branchStaff): JsonResponse
    {
        $schedules = $this->branchStaffService->getStaffSchedule($branchStaff);
        
        return response()->json([
            'success' => true,
            'message' => 'Staff schedule retrieved successfully',
            'data' => StaffScheduleResource::collection($schedules)
        ]);
    }

    public function createSchedule(CreateStaffScheduleRequest $request, BranchStaff $branchStaff): JsonResponse
    {
        $schedules = $this->branchStaffService->createStaffSchedule($branchStaff, $request->schedules);
        
        return response()->json([
            'success' => true,
            'message' => 'Staff schedule created successfully',
            'data' => StaffScheduleResource::collection($schedules)
        ], 201);
    }

    public function getPerformance(BranchStaff $branchStaff, Request $request): JsonResponse
    {
        $request->validate([
            'start_date' => 'required|date',
            'end_date' => 'required|date|after_or_equal:start_date'
        ]);
        
        $performance = $this->branchStaffService->getStaffPerformance(
            $branchStaff,
            $request->start_date,
            $request->end_date
        );
        
        return response()->json([
            'success' => true,
            'message' => 'Staff performance retrieved successfully',
            'data' => StaffPerformanceResource::collection($performance)
        ]);
    }

    public function recordPerformance(Request $request, BranchStaff $branchStaff): JsonResponse
    {
        $request->validate([
            'date' => 'required|date',
            'bookings_handled' => 'integer|min:0',
            'orders_processed' => 'integer|min:0',
            'customer_rating' => 'numeric|min:0|max:5',
            'notes' => 'string|max:1000'
        ]);
        
        $performance = $this->branchStaffService->recordStaffPerformance($branchStaff, $request->validated());
        
        return response()->json([
            'success' => true,
            'message' => 'Staff performance recorded successfully',
            'data' => new StaffPerformanceResource($performance)
        ], 201);
    }

    public function getWorkingToday(Branch $branch): JsonResponse
    {
        $staff = $this->branchStaffService->getStaffWorkingToday($branch);
        
        return response()->json([
            'success' => true,
            'message' => 'Staff working today retrieved successfully',
            'data' => BranchStaffResource::collection($staff)
        ]);
    }

    public function updatePermissions(Request $request, BranchStaff $branchStaff): JsonResponse
    {
        $request->validate([
            'permissions' => 'required|array',
            'permissions.*' => 'string|in:booking_management,order_management,inventory_management,payment_verification,user_management,analytics_view'
        ]);
        
        $branchStaff = $this->branchStaffService->updateStaffPermissions($branchStaff, $request->permissions);
        
        return response()->json([
            'success' => true,
            'message' => 'Staff permissions updated successfully',
            'data' => new BranchStaffResource($branchStaff)
        ]);
    }

    public function activate(BranchStaff $branchStaff): JsonResponse
    {
        $branchStaff = $this->branchStaffService->activateStaff($branchStaff);
        
        return response()->json([
            'success' => true,
            'message' => 'Staff activated successfully',
            'data' => new BranchStaffResource($branchStaff)
        ]);
    }

    public function deactivate(BranchStaff $branchStaff): JsonResponse
    {
        $branchStaff = $this->branchStaffService->deactivateStaff($branchStaff);
        
        return response()->json([
            'success' => true,
            'message' => 'Staff deactivated successfully',
            'data' => new BranchStaffResource($branchStaff)
        ]);
    }
}
```

### 2.6 API Resources

```php
<?php
// app/Http/Resources/BranchStaffResource.php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class BranchStaffResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'branch_id' => $this->branch_id,
            'user_id' => $this->user_id,
            'role' => $this->role,
            'permissions' => $this->permissions,
            'is_active' => $this->is_active,
            'assigned_at' => $this->assigned_at,
            'assigned_by' => $this->assigned_by,
            'created_at' => $this->created_at,
            'updated_at' => $this->updated_at,
            
            // Relationships
            'user' => new UserResource($this->whenLoaded('user')),
            'branch' => new BranchResource($this->whenLoaded('branch')),
            'assigned_by_user' => new UserResource($this->whenLoaded('assignedBy')),
            'schedules' => StaffScheduleResource::collection($this->whenLoaded('schedules')),
            'performance' => StaffPerformanceResource::collection($this->whenLoaded('performance')),
        ];
    }
}
```

```php
<?php
// app/Http/Resources/StaffScheduleResource.php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class StaffScheduleResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'branch_staff_id' => $this->branch_staff_id,
            'day_of_week' => $this->day_of_week,
            'day_name' => $this->getDayName(),
            'start_time' => $this->start_time,
            'end_time' => $this->end_time,
            'duration_hours' => $this->getDurationInHours(),
            'is_active' => $this->is_active,
            'created_at' => $this->created_at,
            'updated_at' => $this->updated_at,
        ];
    }
}
```

```php
<?php
// app/Http/Resources/StaffPerformanceResource.php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class StaffPerformanceResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'branch_staff_id' => $this->branch_staff_id,
            'date' => $this->date,
            'bookings_handled' => $this->bookings_handled,
            'orders_processed' => $this->orders_processed,
            'total_tasks' => $this->getTotalTasks(),
            'customer_rating' => $this->customer_rating,
            'efficiency_score' => $this->getEfficiencyScore(),
            'notes' => $this->notes,
            'created_at' => $this->created_at,
            'updated_at' => $this->updated_at,
        ];
    }
}
```

## 🧪 Testing

### 2.1 Unit Tests

```php
<?php
// tests/Unit/Services/BranchStaffServiceTest.php

namespace Tests\Unit\Services;

use App\Models\Branch;
use App\Models\BranchStaff;
use App\Models\User;
use App\Services\BranchStaffService;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class BranchStaffServiceTest extends TestCase
{
    use RefreshDatabase;

    private BranchStaffService $branchStaffService;

    protected function setUp(): void
    {
        parent::setUp();
        $this->branchStaffService = app(BranchStaffService::class);
    }

    public function test_can_assign_staff_to_branch(): void
    {
        $branch = Branch::factory()->create();
        $user = User::factory()->create();
        
        $data = [
            'role' => 'staff',
            'permissions' => ['booking_management'],
            'is_active' => true
        ];
        
        $branchStaff = $this->branchStaffService->assignStaffToBranch($branch, $user, $data);
        
        $this->assertInstanceOf(BranchStaff::class, $branchStaff);
        $this->assertEquals($branch->id, $branchStaff->branch_id);
        $this->assertEquals($user->id, $branchStaff->user_id);
        $this->assertEquals('staff', $branchStaff->role);
        $this->assertTrue($branchStaff->is_active);
        
        // Check user's branch_id is updated
        $this->assertEquals($branch->id, $user->fresh()->branch_id);
    }

    public function test_can_remove_staff_from_branch(): void
    {
        $branchStaff = BranchStaff::factory()->create();
        $user = $branchStaff->user;
        
        $result = $this->branchStaffService->removeStaffFromBranch($branchStaff);
        
        $this->assertTrue($result);
        $this->assertDatabaseMissing('branch_staff', ['id' => $branchStaff->id]);
        $this->assertNull($user->fresh()->branch_id);
    }

    public function test_can_transfer_staff_between_branches(): void
    {
        $branchStaff = BranchStaff::factory()->create();
        $newBranch = Branch::factory()->create();
        
        $data = ['role' => 'manager'];
        $transferredStaff = $this->branchStaffService->transferStaff($branchStaff, $newBranch, $data);
        
        $this->assertEquals($newBranch->id, $transferredStaff->branch_id);
        $this->assertEquals('manager', $transferredStaff->role);
        $this->assertEquals($newBranch->id, $transferredStaff->user->fresh()->branch_id);
    }

    public function test_can_get_staff_working_today(): void
    {
        $branch = Branch::factory()->create();
        $branchStaff = BranchStaff::factory()->create(['branch_id' => $branch->id]);
        
        // Create schedule for today
        $today = now();
        $dayOfWeek = $today->dayOfWeek === 0 ? 7 : $today->dayOfWeek;
        
        $branchStaff->schedules()->create([
            'day_of_week' => $dayOfWeek,
            'start_time' => '08:00',
            'end_time' => '17:00',
            'is_active' => true
        ]);
        
        $workingStaff = $this->branchStaffService->getStaffWorkingToday($branch);
        
        $this->assertCount(1, $workingStaff);
        $this->assertEquals($branchStaff->id, $workingStaff->first()->id);
    }
}
```

### 2.2 Feature Tests

```php
<?php
// tests/Feature/Api/V1/BranchStaffApiTest.php

namespace Tests\Feature\Api\V1;

use App\Models\Branch;
use App\Models\BranchStaff;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class BranchStaffApiTest extends TestCase
{
    use RefreshDatabase;

    public function test_can_assign_staff_to_branch_as_admin(): void
    {
        $admin = User::factory()->admin()->create();
        $branch = Branch::factory()->create();
        $user = User::factory()->create();
        
        $data = [
            'user_id' => $user->id,
            'role' => 'staff',
            'permissions' => ['booking_management'],
            'is_active' => true
        ];
        
        $response = $this->actingAs($admin)
            ->postJson("/api/v1/branches/{$branch->id}/staff", $data);
        
        $response->assertStatus(201)
            ->assertJsonStructure([
                'success',
                'message',
                'data' => [
                    'id',
                    'branch_id',
                    'user_id',
                    'role',
                    'permissions',
                    'is_active',
                    'assigned_at',
                    'user'
                ]
            ]);
    }

    public function test_cannot_assign_staff_to_branch_as_regular_user(): void
    {
        $user = User::factory()->create();
        $branch = Branch::factory()->create();
        $staffUser = User::factory()->create();
        
        $data = [
            'user_id' => $staffUser->id,
            'role' => 'staff'
        ];
        
        $response = $this->actingAs($user)
            ->postJson("/api/v1/branches/{$branch->id}/staff", $data);
        
        $response->assertStatus(403);
    }

    public function test_can_get_branch_staff(): void
    {
        $branch = Branch::factory()->create();
        BranchStaff::factory()->count(3)->create(['branch_id' => $branch->id]);
        
        $response = $this->getJson("/api/v1/branches/{$branch->id}/staff");
        
        $response->assertStatus(200)
            ->assertJsonCount(3, 'data')
            ->assertJsonStructure([
                'success',
                'message',
                'data' => [
                    '*' => [
                        'id',
                        'branch_id',
                        'user_id',
                        'role',
                        'permissions',
                        'is_active',
                        'user'
                    ]
                ]
            ]);
    }

    public function test_can_create_staff_schedule(): void
    {
        $admin = User::factory()->admin()->create();
        $branchStaff = BranchStaff::factory()->create();
        
        $schedules = [
            [
                'day_of_week' => 1,
                'start_time' => '08:00',
                'end_time' => '17:00',
                'is_active' => true
            ],
            [
                'day_of_week' => 2,
                'start_time' => '08:00',
                'end_time' => '17:00',
                'is_active' => true
            ]
        ];
        
        $response = $this->actingAs($admin)
            ->postJson("/api/v1/branch-staff/{$branchStaff->id}/schedule", [
                'schedules' => $schedules
            ]);
        
        $response->assertStatus(201)
            ->assertJsonCount(2, 'data')
            ->assertJsonStructure([
                'success',
                'message',
                'data' => [
                    '*' => [
                        'id',
                        'branch_staff_id',
                        'day_of_week',
                        'day_name',
                        'start_time',
                        'end_time',
                        'duration_hours',
                        'is_active'
                    ]
                ]
            ]);
    }

    public function test_can_record_staff_performance(): void
    {
        $admin = User::factory()->admin()->create();
        $branchStaff = BranchStaff::factory()->create();
        
        $data = [
            'date' => now()->format('Y-m-d'),
            'bookings_handled' => 10,
            'orders_processed' => 5,
            'customer_rating' => 4.5,
            'notes' => 'Good performance today'
        ];
        
        $response = $this->actingAs($admin)
            ->postJson("/api/v1/branch-staff/{$branchStaff->id}/performance", $data);
        
        $response->assertStatus(201)
            ->assertJsonStructure([
                'success',
                'message',
                'data' => [
                    'id',
                    'branch_staff_id',
                    'date',
                    'bookings_handled',
                    'orders_processed',
                    'total_tasks',
                    'customer_rating',
                    'efficiency_score',
                    'notes'
                ]
            ]);
    }
}
```

## 📊 API Endpoints

### 2.1 Branch Staff Management

```http
GET /api/v1/branches/{branch_id}/staff
POST /api/v1/branches/{branch_id}/staff
GET /api/v1/branch-staff/{branch_staff_id}
DELETE /api/v1/branch-staff/{branch_staff_id}
PUT /api/v1/branch-staff/{branch_staff_id}/transfer
POST /api/v1/branch-staff/{branch_staff_id}/activate
POST /api/v1/branch-staff/{branch_staff_id}/deactivate
```

### 2.2 Staff Schedule Management

```http
GET /api/v1/branch-staff/{branch_staff_id}/schedule
POST /api/v1/branch-staff/{branch_staff_id}/schedule
PUT /api/v1/staff-schedules/{schedule_id}
DELETE /api/v1/staff-schedules/{schedule_id}
```

### 2.3 Staff Performance

```http
GET /api/v1/branch-staff/{branch_staff_id}/performance
POST /api/v1/branch-staff/{branch_staff_id}/performance
GET /api/v1/branches/{branch_id}/staff-performance
```

### 2.4 Staff Permissions

```http
PUT /api/v1/branch-staff/{branch_staff_id}/permissions
```

## 🎯 Success Criteria

- [ ] Staff assignment to branches working
- [ ] Staff removal from branches working
- [ ] Staff transfer between branches working
- [ ] Staff schedule management working
- [ ] Staff performance tracking working
- [ ] Staff permissions management working
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
**Dependencies**: Phase 7.1 Complete  
**Key Features**:

- 👥 **Staff Assignment & Management** per cabang
- 📅 **Staff Schedule Management** dengan jadwal kerja
- 📊 **Staff Performance Tracking** dengan metrik performa
- 🔐 **Staff Permissions Management** dengan kontrol akses
- 🔄 **Staff Transfer System** antar cabang
- 🧪 **Comprehensive Testing** dengan unit dan feature tests
- 📊 **API Documentation** lengkap dengan examples
- 🔒 **Security & Validation** untuk semua operasi
