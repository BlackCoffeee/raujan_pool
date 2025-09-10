# Point 3: Role-Based Access Control (RBAC)

## 📋 Overview

Implementasi sistem role-based access control dengan permissions dan middleware untuk mengatur akses user.

## 🎯 Objectives

-   Define user roles (Admin, Staff, Member, Guest)
-   Implementasi permissions system
-   Role assignment mechanism
-   Permission checking middleware
-   Role-based route protection
-   Admin role management

## 📁 Files Structure

```
phase-2/
├── 03-role-based-access-control.md
├── app/Models/Role.php
├── app/Models/Permission.php
├── app/Http/Middleware/CheckRole.php
├── app/Http/Middleware/CheckPermission.php
└── database/migrations/
```

## 🔧 Implementation Steps

### Step 1: Create Role Model

```php
<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Role extends Model
{
    use HasFactory;

    protected $fillable = [
        'name',
        'display_name',
        'description',
        'is_active',
    ];

    protected $casts = [
        'is_active' => 'boolean',
    ];

    public function users()
    {
        return $this->belongsToMany(User::class);
    }

    public function permissions()
    {
        return $this->belongsToMany(Permission::class);
    }

    public function hasPermission($permission)
    {
        return $this->permissions()->where('name', $permission)->exists();
    }

    public function givePermission($permission)
    {
        if (is_string($permission)) {
            $permission = Permission::where('name', $permission)->first();
        }

        if ($permission && !$this->hasPermission($permission->name)) {
            $this->permissions()->attach($permission);
        }
    }

    public function revokePermission($permission)
    {
        if (is_string($permission)) {
            $permission = Permission::where('name', $permission)->first();
        }

        if ($permission) {
            $this->permissions()->detach($permission);
        }
    }

    public function syncPermissions($permissions)
    {
        $permissionIds = collect($permissions)->map(function ($permission) {
            if (is_string($permission)) {
                return Permission::where('name', $permission)->first()?->id;
            }
            return $permission->id ?? $permission;
        })->filter()->toArray();

        $this->permissions()->sync($permissionIds);
    }

    public function scopeActive($query)
    {
        return $query->where('is_active', true);
    }
}
```

### Step 2: Create Permission Model

```php
<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Permission extends Model
{
    use HasFactory;

    protected $fillable = [
        'name',
        'display_name',
        'description',
        'group',
        'is_active',
    ];

    protected $casts = [
        'is_active' => 'boolean',
    ];

    public function roles()
    {
        return $this->belongsToMany(Role::class);
    }

    public function scopeActive($query)
    {
        return $query->where('is_active', true);
    }

    public function scopeByGroup($query, $group)
    {
        return $query->where('group', $group);
    }
}
```

### Step 3: Update User Model

```php
<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Laravel\Sanctum\HasApiTokens;

class User extends Authenticatable
{
    use HasApiTokens, HasFactory, Notifiable;

    // ... existing code ...

    public function roles()
    {
        return $this->belongsToMany(Role::class);
    }

    public function hasRole($role)
    {
        if (is_string($role)) {
            return $this->roles()->where('name', $role)->exists();
        }

        return $this->roles()->where('id', $role->id)->exists();
    }

    public function hasAnyRole($roles)
    {
        if (is_string($roles)) {
            $roles = [$roles];
        }

        return $this->roles()->whereIn('name', $roles)->exists();
    }

    public function hasAllRoles($roles)
    {
        if (is_string($roles)) {
            $roles = [$roles];
        }

        $userRoles = $this->roles()->pluck('name')->toArray();

        return count(array_intersect($roles, $userRoles)) === count($roles);
    }

    public function hasPermission($permission)
    {
        return $this->roles()->whereHas('permissions', function ($query) use ($permission) {
            $query->where('name', $permission);
        })->exists();
    }

    public function hasAnyPermission($permissions)
    {
        if (is_string($permissions)) {
            $permissions = [$permissions];
        }

        return $this->roles()->whereHas('permissions', function ($query) use ($permissions) {
            $query->whereIn('name', $permissions);
        })->exists();
    }

    public function assignRole($role)
    {
        if (is_string($role)) {
            $role = Role::where('name', $role)->first();
        }

        if ($role && !$this->hasRole($role)) {
            $this->roles()->attach($role);
        }
    }

    public function removeRole($role)
    {
        if (is_string($role)) {
            $role = Role::where('name', $role)->first();
        }

        if ($role) {
            $this->roles()->detach($role);
        }
    }

    public function syncRoles($roles)
    {
        $roleIds = collect($roles)->map(function ($role) {
            if (is_string($role)) {
                return Role::where('name', $role)->first()?->id;
            }
            return $role->id ?? $role;
        })->filter()->toArray();

        $this->roles()->sync($roleIds);
    }

    public function getRoleNames()
    {
        return $this->roles()->pluck('name')->toArray();
    }

    public function getPermissionNames()
    {
        return $this->roles()->with('permissions')->get()
            ->pluck('permissions')
            ->flatten()
            ->pluck('name')
            ->unique()
            ->toArray();
    }
}
```

### Step 4: Create Role Management Controller

```php
<?php

namespace App\Http\Controllers\Api\V1\Admin;

use App\Http\Controllers\Api\BaseController;
use App\Http\Requests\RoleRequest;
use App\Models\Role;
use App\Models\Permission;
use Illuminate\Http\Request;

class RoleController extends BaseController
{
    public function index(Request $request)
    {
        $roles = Role::with('permissions')
            ->when($request->search, function ($query, $search) {
                return $query->where('name', 'like', "%{$search}%")
                    ->orWhere('display_name', 'like', "%{$search}%");
            })
            ->when($request->active !== null, function ($query) use ($request) {
                return $query->where('is_active', $request->active);
            })
            ->orderBy('name')
            ->paginate($request->per_page ?? 15);

        return $this->successResponse($roles, 'Roles retrieved successfully');
    }

    public function store(RoleRequest $request)
    {
        $role = Role::create($request->validated());

        if ($request->has('permissions')) {
            $role->syncPermissions($request->permissions);
        }

        return $this->successResponse($role->load('permissions'), 'Role created successfully', 201);
    }

    public function show(Role $role)
    {
        return $this->successResponse($role->load('permissions'), 'Role retrieved successfully');
    }

    public function update(RoleRequest $request, Role $role)
    {
        $role->update($request->validated());

        if ($request->has('permissions')) {
            $role->syncPermissions($request->permissions);
        }

        return $this->successResponse($role->load('permissions'), 'Role updated successfully');
    }

    public function destroy(Role $role)
    {
        // Check if role is assigned to any users
        if ($role->users()->count() > 0) {
            return $this->errorResponse('Cannot delete role that is assigned to users', 422);
        }

        $role->delete();

        return $this->successResponse(null, 'Role deleted successfully');
    }

    public function assignPermissions(Request $request, Role $role)
    {
        $request->validate([
            'permissions' => 'required|array',
            'permissions.*' => 'exists:permissions,id'
        ]);

        $role->syncPermissions($request->permissions);

        return $this->successResponse($role->load('permissions'), 'Permissions assigned successfully');
    }

    public function revokePermission(Request $request, Role $role)
    {
        $request->validate([
            'permission' => 'required|exists:permissions,id'
        ]);

        $role->revokePermission($request->permission);

        return $this->successResponse($role->load('permissions'), 'Permission revoked successfully');
    }
}
```

### Step 5: Create Permission Management Controller

```php
<?php

namespace App\Http\Controllers\Api\V1\Admin;

use App\Http\Controllers\Api\BaseController;
use App\Http\Requests\PermissionRequest;
use App\Models\Permission;
use Illuminate\Http\Request;

class PermissionController extends BaseController
{
    public function index(Request $request)
    {
        $permissions = Permission::when($request->search, function ($query, $search) {
                return $query->where('name', 'like', "%{$search}%")
                    ->orWhere('display_name', 'like', "%{$search}%");
            })
            ->when($request->group, function ($query, $group) {
                return $query->where('group', $group);
            })
            ->when($request->active !== null, function ($query) use ($request) {
                return $query->where('is_active', $request->active);
            })
            ->orderBy('group')
            ->orderBy('name')
            ->paginate($request->per_page ?? 15);

        return $this->successResponse($permissions, 'Permissions retrieved successfully');
    }

    public function store(PermissionRequest $request)
    {
        $permission = Permission::create($request->validated());

        return $this->successResponse($permission, 'Permission created successfully', 201);
    }

    public function show(Permission $permission)
    {
        return $this->successResponse($permission, 'Permission retrieved successfully');
    }

    public function update(PermissionRequest $request, Permission $permission)
    {
        $permission->update($request->validated());

        return $this->successResponse($permission, 'Permission updated successfully');
    }

    public function destroy(Permission $permission)
    {
        // Check if permission is assigned to any roles
        if ($permission->roles()->count() > 0) {
            return $this->errorResponse('Cannot delete permission that is assigned to roles', 422);
        }

        $permission->delete();

        return $this->successResponse(null, 'Permission deleted successfully');
    }

    public function groups()
    {
        $groups = Permission::select('group')
            ->distinct()
            ->whereNotNull('group')
            ->orderBy('group')
            ->pluck('group');

        return $this->successResponse($groups, 'Permission groups retrieved successfully');
    }
}
```

### Step 6: Create Request Classes

#### RoleRequest

```php
<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class RoleRequest extends FormRequest
{
    public function authorize()
    {
        return true;
    }

    public function rules()
    {
        $roleId = $this->route('role')?->id;

        return [
            'name' => [
                'required',
                'string',
                'max:50',
                'unique:roles,name,' . $roleId,
                'regex:/^[a-z_]+$/'
            ],
            'display_name' => ['required', 'string', 'max:100'],
            'description' => ['nullable', 'string', 'max:500'],
            'is_active' => ['boolean'],
            'permissions' => ['array'],
            'permissions.*' => ['exists:permissions,id']
        ];
    }

    public function messages()
    {
        return [
            'name.required' => 'Role name is required',
            'name.unique' => 'Role name already exists',
            'name.regex' => 'Role name can only contain lowercase letters and underscores',
            'display_name.required' => 'Display name is required',
            'permissions.*.exists' => 'One or more permissions do not exist'
        ];
    }
}
```

#### PermissionRequest

```php
<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class PermissionRequest extends FormRequest
{
    public function authorize()
    {
        return true;
    }

    public function rules()
    {
        $permissionId = $this->route('permission')?->id;

        return [
            'name' => [
                'required',
                'string',
                'max:100',
                'unique:permissions,name,' . $permissionId,
                'regex:/^[a-z_\.]+$/'
            ],
            'display_name' => ['required', 'string', 'max:100'],
            'description' => ['nullable', 'string', 'max:500'],
            'group' => ['nullable', 'string', 'max:50'],
            'is_active' => ['boolean']
        ];
    }

    public function messages()
    {
        return [
            'name.required' => 'Permission name is required',
            'name.unique' => 'Permission name already exists',
            'name.regex' => 'Permission name can only contain lowercase letters, underscores, and dots',
            'display_name.required' => 'Display name is required'
        ];
    }
}
```

### Step 7: Create Middleware

#### CheckRole Middleware

```php
<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class CheckRole
{
    public function handle(Request $request, Closure $next, ...$roles): Response
    {
        if (!$request->user()) {
            return response()->json([
                'success' => false,
                'message' => 'Unauthenticated',
                'data' => null
            ], 401);
        }

        if (!$request->user()->hasAnyRole($roles)) {
            return response()->json([
                'success' => false,
                'message' => 'Access denied. Insufficient role permissions.',
                'data' => null
            ], 403);
        }

        return $next($request);
    }
}
```

#### CheckPermission Middleware

```php
<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class CheckPermission
{
    public function handle(Request $request, Closure $next, $permission): Response
    {
        if (!$request->user()) {
            return response()->json([
                'success' => false,
                'message' => 'Unauthenticated',
                'data' => null
            ], 401);
        }

        if (!$request->user()->hasPermission($permission)) {
            return response()->json([
                'success' => false,
                'message' => 'Access denied. Insufficient permissions.',
                'data' => null
            ], 403);
        }

        return $next($request);
    }
}
```

### Step 8: Update API Routes

```php
// In routes/api.php
Route::middleware(['auth:sanctum', 'role:admin'])->prefix('admin')->group(function () {

    // Role Management
    Route::prefix('roles')->group(function () {
        Route::get('/', [RoleController::class, 'index']);
        Route::post('/', [RoleController::class, 'store']);
        Route::get('/{role}', [RoleController::class, 'show']);
        Route::put('/{role}', [RoleController::class, 'update']);
        Route::delete('/{role}', [RoleController::class, 'destroy']);
        Route::post('/{role}/permissions', [RoleController::class, 'assignPermissions']);
        Route::delete('/{role}/permissions/{permission}', [RoleController::class, 'revokePermission']);
    });

    // Permission Management
    Route::prefix('permissions')->group(function () {
        Route::get('/', [PermissionController::class, 'index']);
        Route::post('/', [PermissionController::class, 'store']);
        Route::get('/{permission}', [PermissionController::class, 'show']);
        Route::put('/{permission}', [PermissionController::class, 'update']);
        Route::delete('/{permission}', [PermissionController::class, 'destroy']);
        Route::get('/groups/list', [PermissionController::class, 'groups']);
    });
});

// Role-based route protection examples
Route::middleware(['auth:sanctum', 'role:admin,staff'])->group(function () {
    // Routes accessible by admin and staff
});

Route::middleware(['auth:sanctum', 'permission:users.create'])->group(function () {
    // Routes requiring specific permission
});
```

## 📊 Database Schema

### Roles Table

```sql
CREATE TABLE roles (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE,
    display_name VARCHAR(100) NOT NULL,
    description TEXT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);
```

### Permissions Table

```sql
CREATE TABLE permissions (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    display_name VARCHAR(100) NOT NULL,
    description TEXT NULL,
    group VARCHAR(50) NULL,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);
```

### Role User Pivot Table

```sql
CREATE TABLE role_user (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    role_id BIGINT UNSIGNED NOT NULL,
    user_id BIGINT UNSIGNED NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    FOREIGN KEY (role_id) REFERENCES roles(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    UNIQUE KEY unique_role_user (role_id, user_id)
);
```

### Permission Role Pivot Table

```sql
CREATE TABLE permission_role (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    permission_id BIGINT UNSIGNED NOT NULL,
    role_id BIGINT UNSIGNED NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    FOREIGN KEY (permission_id) REFERENCES permissions(id) ON DELETE CASCADE,
    FOREIGN KEY (role_id) REFERENCES roles(id) ON DELETE CASCADE,
    UNIQUE KEY unique_permission_role (permission_id, role_id)
);
```

## 🧪 Testing

### RoleTest.php

```php
<?php

use App\Models\User;
use App\Models\Role;
use App\Models\Permission;

describe('Role Management', function () {

    beforeEach(function () {
        $this->seed();
    });

    it('can list roles as admin', function () {
        actingAsAdmin();

        $response = apiGet('/api/v1/admin/roles');

        assertApiSuccess($response, 'Roles retrieved successfully');
        $response->assertJsonStructure([
            'data' => [
                '*' => [
                    'id',
                    'name',
                    'display_name',
                    'permissions'
                ]
            ]
        ]);
    });

    it('can create role as admin', function () {
        actingAsAdmin();

        $roleData = [
            'name' => 'test_role',
            'display_name' => 'Test Role',
            'description' => 'Test role description',
            'permissions' => [1, 2, 3]
        ];

        $response = apiPost('/api/v1/admin/roles', $roleData);

        assertApiSuccess($response, 'Role created successfully');
        $this->assertDatabaseHas('roles', [
            'name' => 'test_role'
        ]);
    });

    it('can assign permissions to role', function () {
        $role = Role::factory()->create();
        $permissions = Permission::factory()->count(3)->create();
        actingAsAdmin();

        $response = apiPost("/api/v1/admin/roles/{$role->id}/permissions", [
            'permissions' => $permissions->pluck('id')->toArray()
        ]);

        assertApiSuccess($response, 'Permissions assigned successfully');
        expect($role->fresh()->permissions)->toHaveCount(3);
    });

    it('cannot access role management as non-admin', function () {
        actingAsMember();

        $response = apiGet('/api/v1/admin/roles');

        assertApiError($response, 403, 'Access denied. Insufficient role permissions.');
    });
});
```

## ✅ Success Criteria

-   [x] User roles terdefinisi dengan baik
-   [x] Permissions system terimplementasi
-   [x] Role assignment mechanism berfungsi
-   [x] Permission checking middleware berjalan
-   [x] Role-based route protection berfungsi
-   [x] Admin role management berjalan
-   [x] Database schema optimal
-   [x] Testing coverage > 90%

## 📚 Documentation

-   [Laravel Authorization Documentation](https://laravel.com/docs/11.x/authorization)
-   [RBAC Best Practices](https://en.wikipedia.org/wiki/Role-based_access_control)
-   [Laravel Gates and Policies](https://laravel.com/docs/11.x/authorization#gates)
