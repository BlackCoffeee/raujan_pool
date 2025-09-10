# Role-Based Access Control (RBAC) API

## Overview

Sistem RBAC memungkinkan pengelolaan role dan permission untuk mengontrol akses user ke berbagai fitur dalam aplikasi.

## Authentication

Semua endpoint RBAC memerlukan authentication dengan Sanctum token dan role admin.

```bash
Authorization: Bearer {token}
```

## Role Management

### List Roles

**GET** `/api/v1/admin/roles`

Mengambil daftar semua role dengan pagination.

**Query Parameters:**
- `search` (string, optional): Pencarian berdasarkan name atau display_name
- `active` (boolean, optional): Filter berdasarkan status aktif
- `per_page` (integer, optional): Jumlah item per halaman (default: 15)

**Response:**
```json
{
  "success": true,
  "message": "Roles retrieved successfully",
  "data": {
    "data": [
      {
        "id": 1,
        "name": "admin",
        "display_name": "Administrator",
        "description": "Full system access",
        "is_active": true,
        "permissions": [
          {
            "id": 1,
            "name": "users.create",
            "display_name": "Create Users"
          }
        ]
      }
    ],
    "current_page": 1,
    "total": 10
  }
}
```

### Create Role

**POST** `/api/v1/admin/roles`

Membuat role baru.

**Request Body:**
```json
{
  "name": "test_role",
  "display_name": "Test Role",
  "description": "Test role description",
  "is_active": true,
  "permissions": [1, 2, 3]
}
```

**Response:**
```json
{
  "success": true,
  "message": "Role created successfully",
  "data": {
    "id": 4,
    "name": "test_role",
    "display_name": "Test Role",
    "description": "Test role description",
    "is_active": true,
    "permissions": []
  }
}
```

### Get Role

**GET** `/api/v1/admin/roles/{role}`

Mengambil detail role berdasarkan ID.

**Response:**
```json
{
  "success": true,
  "message": "Role retrieved successfully",
  "data": {
    "id": 1,
    "name": "admin",
    "display_name": "Administrator",
    "description": "Full system access",
    "is_active": true,
    "permissions": []
  }
}
```

### Update Role

**PUT** `/api/v1/admin/roles/{role}`

Mengupdate role.

**Request Body:**
```json
{
  "name": "updated_role",
  "display_name": "Updated Role",
  "description": "Updated description",
  "is_active": false,
  "permissions": [1, 2]
}
```

**Response:**
```json
{
  "success": true,
  "message": "Role updated successfully",
  "data": {
    "id": 1,
    "name": "updated_role",
    "display_name": "Updated Role",
    "description": "Updated description",
    "is_active": false,
    "permissions": []
  }
}
```

### Delete Role

**DELETE** `/api/v1/admin/roles/{role}`

Menghapus role. Role tidak dapat dihapus jika masih digunakan oleh user.

**Response:**
```json
{
  "success": true,
  "message": "Role deleted successfully",
  "data": null
}
```

### Assign Permissions to Role

**POST** `/api/v1/admin/roles/{role}/permissions`

Menetapkan permissions ke role.

**Request Body:**
```json
{
  "permissions": [1, 2, 3, 4]
}
```

**Response:**
```json
{
  "success": true,
  "message": "Permissions assigned successfully",
  "data": {
    "id": 1,
    "name": "admin",
    "permissions": [
      {
        "id": 1,
        "name": "users.create"
      }
    ]
  }
}
```

### Revoke Permission from Role

**DELETE** `/api/v1/admin/roles/{role}/permissions/{permission}`

Mencabut permission dari role.

**Response:**
```json
{
  "success": true,
  "message": "Permission revoked successfully",
  "data": {
    "id": 1,
    "name": "admin",
    "permissions": []
  }
}
```

## Permission Management

### List Permissions

**GET** `/api/v1/admin/permissions`

Mengambil daftar semua permission dengan pagination.

**Query Parameters:**
- `search` (string, optional): Pencarian berdasarkan name atau display_name
- `group` (string, optional): Filter berdasarkan group
- `active` (boolean, optional): Filter berdasarkan status aktif
- `per_page` (integer, optional): Jumlah item per halaman (default: 15)

**Response:**
```json
{
  "success": true,
  "message": "Permissions retrieved successfully",
  "data": {
    "data": [
      {
        "id": 1,
        "name": "users.create",
        "display_name": "Create Users",
        "description": "Permission to create new users",
        "group": "users",
        "is_active": true
      }
    ],
    "current_page": 1,
    "total": 25
  }
}
```

### Create Permission

**POST** `/api/v1/admin/permissions`

Membuat permission baru.

**Request Body:**
```json
{
  "name": "test.permission",
  "display_name": "Test Permission",
  "description": "Test permission description",
  "group": "test",
  "is_active": true
}
```

**Response:**
```json
{
  "success": true,
  "message": "Permission created successfully",
  "data": {
    "id": 26,
    "name": "test.permission",
    "display_name": "Test Permission",
    "description": "Test permission description",
    "group": "test",
    "is_active": true
  }
}
```

### Get Permission

**GET** `/api/v1/admin/permissions/{permission}`

Mengambil detail permission berdasarkan ID.

**Response:**
```json
{
  "success": true,
  "message": "Permission retrieved successfully",
  "data": {
    "id": 1,
    "name": "users.create",
    "display_name": "Create Users",
    "description": "Permission to create new users",
    "group": "users",
    "is_active": true
  }
}
```

### Update Permission

**PUT** `/api/v1/admin/permissions/{permission}`

Mengupdate permission.

**Request Body:**
```json
{
  "name": "updated.permission",
  "display_name": "Updated Permission",
  "description": "Updated description",
  "group": "updated",
  "is_active": false
}
```

**Response:**
```json
{
  "success": true,
  "message": "Permission updated successfully",
  "data": {
    "id": 1,
    "name": "updated.permission",
    "display_name": "Updated Permission",
    "description": "Updated description",
    "group": "updated",
    "is_active": false
  }
}
```

### Delete Permission

**DELETE** `/api/v1/admin/permissions/{permission}`

Menghapus permission. Permission tidak dapat dihapus jika masih digunakan oleh role.

**Response:**
```json
{
  "success": true,
  "message": "Permission deleted successfully",
  "data": null
}
```

### Get Permission Groups

**GET** `/api/v1/admin/permissions/groups/list`

Mengambil daftar semua group permission.

**Response:**
```json
{
  "success": true,
  "message": "Permission groups retrieved successfully",
  "data": [
    "users",
    "bookings",
    "payments",
    "members",
    "cafe"
  ]
}
```

## Error Responses

### 401 Unauthorized
```json
{
  "success": false,
  "message": "Unauthenticated",
  "data": null
}
```

### 403 Forbidden
```json
{
  "success": false,
  "message": "Insufficient permissions",
  "data": null
}
```

### 422 Validation Error
```json
{
  "success": false,
  "message": "Validation failed",
  "data": null,
  "errors": {
    "name": ["The name field is required."],
    "display_name": ["The display name field is required."]
  }
}
```

### 422 Business Logic Error
```json
{
  "success": false,
  "message": "Cannot delete role that is assigned to users",
  "data": null
}
```

## Validation Rules

### Role Validation
- `name`: Required, string, max 50 characters, unique, lowercase letters and underscores only
- `display_name`: Required, string, max 100 characters
- `description`: Optional, string, max 500 characters
- `is_active`: Optional, boolean
- `permissions`: Optional, array of permission IDs

### Permission Validation
- `name`: Required, string, max 100 characters, unique, lowercase letters, underscores, and dots only
- `display_name`: Required, string, max 100 characters
- `description`: Optional, string, max 500 characters
- `group`: Optional, string, max 50 characters
- `is_active`: Optional, boolean

## Usage Examples

### Assign Role to User
```php
$user = User::find(1);
$user->assignRole('admin');
```

### Check User Role
```php
if ($user->hasRole('admin')) {
    // User is admin
}
```

### Check User Permission
```php
if ($user->hasPermission('users.create')) {
    // User can create users
}
```

### Middleware Usage
```php
// In routes
Route::middleware(['auth:sanctum', 'role:admin'])->group(function () {
    // Admin only routes
});

Route::middleware(['auth:sanctum', 'permission:users.create'])->group(function () {
    // Routes requiring specific permission
});
```
