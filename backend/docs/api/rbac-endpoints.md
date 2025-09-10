# Role-Based Access Control (RBAC) API Endpoints

## Overview

Sistem RBAC memungkinkan pengelolaan roles dan permissions untuk mengontrol akses user ke berbagai fitur aplikasi.

## Authentication

Semua endpoint RBAC memerlukan authentication menggunakan Sanctum token.

```bash
Authorization: Bearer {token}
```

## Role Management

### List Roles

**GET** `/api/v1/admin/roles`

Mengambil daftar semua roles dengan pagination.

**Headers:**
- `Authorization: Bearer {token}` (required)
- `Content-Type: application/json`

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
        "description": "Full system access and control",
        "is_active": true,
        "permissions": [
          {
            "id": 1,
            "name": "users.index",
            "display_name": "View Users",
            "group": "User Management"
          }
        ],
        "created_at": "2025-01-01T00:00:00.000000Z",
        "updated_at": "2025-01-01T00:00:00.000000Z"
      }
    ],
    "links": {...},
    "meta": {...}
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

**Validation Rules:**
- `name`: required, string, max:50, unique, regex:/^[a-z_]+$/
- `display_name`: required, string, max:100
- `description`: nullable, string, max:500
- `is_active`: boolean
- `permissions`: array
- `permissions.*`: exists:permissions,id

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
    "permissions": [...],
    "created_at": "2025-01-01T00:00:00.000000Z",
    "updated_at": "2025-01-01T00:00:00.000000Z"
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
    "description": "Full system access and control",
    "is_active": true,
    "permissions": [...],
    "created_at": "2025-01-01T00:00:00.000000Z",
    "updated_at": "2025-01-01T00:00:00.000000Z"
  }
}
```

### Update Role

**PUT** `/api/v1/admin/roles/{role}`

Mengupdate role yang sudah ada.

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
    "permissions": [...],
    "created_at": "2025-01-01T00:00:00.000000Z",
    "updated_at": "2025-01-01T00:00:00.000000Z"
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

**Error Response (422):**
```json
{
  "success": false,
  "message": "Cannot delete role that is assigned to users",
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

**Validation Rules:**
- `permissions`: required, array
- `permissions.*`: exists:permissions,id

**Response:**
```json
{
  "success": true,
  "message": "Permissions assigned successfully",
  "data": {
    "id": 1,
    "name": "admin",
    "display_name": "Administrator",
    "permissions": [...],
    "created_at": "2025-01-01T00:00:00.000000Z",
    "updated_at": "2025-01-01T00:00:00.000000Z"
  }
}
```

### Revoke Permission from Role

**DELETE** `/api/v1/admin/roles/{role}/permissions`

Mencabut permission dari role.

**Request Body:**
```json
{
  "permission": 1
}
```

**Validation Rules:**
- `permission`: required, exists:permissions,id

**Response:**
```json
{
  "success": true,
  "message": "Permission revoked successfully",
  "data": {
    "id": 1,
    "name": "admin",
    "display_name": "Administrator",
    "permissions": [...],
    "created_at": "2025-01-01T00:00:00.000000Z",
    "updated_at": "2025-01-01T00:00:00.000000Z"
  }
}
```

## Permission Management

### List Permissions

**GET** `/api/v1/admin/permissions`

Mengambil daftar semua permissions dengan pagination.

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
        "name": "users.index",
        "display_name": "View Users",
        "description": null,
        "group": "User Management",
        "is_active": true,
        "created_at": "2025-01-01T00:00:00.000000Z",
        "updated_at": "2025-01-01T00:00:00.000000Z"
      }
    ],
    "links": {...},
    "meta": {...}
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
  "group": "Test Group",
  "is_active": true
}
```

**Validation Rules:**
- `name`: required, string, max:100, unique, regex:/^[a-z_\.]+$/
- `display_name`: required, string, max:100
- `description`: nullable, string, max:500
- `group`: nullable, string, max:50
- `is_active`: boolean

**Response:**
```json
{
  "success": true,
  "message": "Permission created successfully",
  "data": {
    "id": 20,
    "name": "test.permission",
    "display_name": "Test Permission",
    "description": "Test permission description",
    "group": "Test Group",
    "is_active": true,
    "created_at": "2025-01-01T00:00:00.000000Z",
    "updated_at": "2025-01-01T00:00:00.000000Z"
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
    "name": "users.index",
    "display_name": "View Users",
    "description": null,
    "group": "User Management",
    "is_active": true,
    "created_at": "2025-01-01T00:00:00.000000Z",
    "updated_at": "2025-01-01T00:00:00.000000Z"
  }
}
```

### Update Permission

**PUT** `/api/v1/admin/permissions/{permission}`

Mengupdate permission yang sudah ada.

**Request Body:**
```json
{
  "name": "updated.permission",
  "display_name": "Updated Permission",
  "description": "Updated description",
  "group": "Updated Group",
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
    "group": "Updated Group",
    "is_active": false,
    "created_at": "2025-01-01T00:00:00.000000Z",
    "updated_at": "2025-01-01T00:00:00.000000Z"
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

**Error Response (422):**
```json
{
  "success": false,
  "message": "Cannot delete permission that is assigned to roles",
  "data": null
}
```

### Get Permission Groups

**GET** `/api/v1/admin/permissions/groups/list`

Mengambil daftar semua permission groups.

**Response:**
```json
{
  "success": true,
  "message": "Permission groups retrieved successfully",
  "data": [
    "User Management",
    "Booking Management",
    "Payment Management",
    "Member Management",
    "Cafe Management",
    "Reports & Analytics"
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
  "message": "The given data was invalid.",
  "data": {
    "name": ["The name field is required."],
    "permissions.0": ["The selected permissions.0 is invalid."]
  }
}
```

## Middleware Usage

### Role Middleware
```php
Route::middleware(['auth:sanctum', 'role:admin'])->group(function () {
    // Routes accessible by admin only
});

Route::middleware(['auth:sanctum', 'role:admin,staff'])->group(function () {
    // Routes accessible by admin or staff
});
```

### Permission Middleware
```php
Route::middleware(['auth:sanctum', 'permission:users.create'])->group(function () {
    // Routes requiring specific permission
});
```

## Default Roles and Permissions

### Roles
- **admin**: Full system access
- **staff**: Limited administrative access
- **member**: Basic user with booking privileges
- **guest**: Limited access

### Permission Groups
- **User Management**: users.index, users.create, users.edit, users.delete
- **Booking Management**: bookings.index, bookings.create, bookings.edit, bookings.delete
- **Payment Management**: payments.index, payments.verify, payments.refund
- **Member Management**: members.index, members.create, members.edit, members.delete
- **Cafe Management**: cafe.menu, cafe.orders, cafe.inventory
- **Reports & Analytics**: reports.view, analytics.view
