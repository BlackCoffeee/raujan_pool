# Admin User Management API

API untuk manajemen user oleh admin.

## Base URL

```
GET /api/v1/admin/users
```

## Authentication

-   **Required**: Bearer Token (Admin role)
-   **Header**: `Authorization: Bearer {token}`

## Endpoints

### 1. List All Users

```http
GET /api/v1/admin/users
```

**Query Parameters:**

-   `page` (optional): Halaman (default: 1)
-   `per_page` (optional): Jumlah data per halaman (default: 15)
-   `search` (optional): Pencarian berdasarkan nama atau email
-   `role` (optional): Filter berdasarkan role (`admin`, `staff`, `member`, `regular`)
-   `status` (optional): Filter berdasarkan status (`active`, `suspended`)

**Response:**

```json
{
    "success": true,
    "data": {
        "users": [
            {
                "id": 1,
                "name": "John Doe",
                "email": "john@example.com",
                "phone": "081234567890",
                "role": "member",
                "status": "active",
                "membership_type": "monthly",
                "membership_expires_at": "2024-02-15T23:59:59Z",
                "created_at": "2024-01-01T00:00:00Z",
                "last_login_at": "2024-01-15T08:00:00Z"
            }
        ],
        "pagination": {
            "current_page": 1,
            "per_page": 15,
            "total": 120,
            "last_page": 8
        }
    }
}
```

### 2. Get User Details

```http
GET /api/v1/admin/users/{user_id}
```

**Response:**

```json
{
    "success": true,
    "data": {
        "id": 1,
        "name": "John Doe",
        "email": "john@example.com",
        "phone": "081234567890",
        "role": "member",
        "status": "active",
        "membership_type": "monthly",
        "membership_expires_at": "2024-02-15T23:59:59Z",
        "created_at": "2024-01-01T00:00:00Z",
        "last_login_at": "2024-01-15T08:00:00Z",
        "bookings_count": 25,
        "total_spent": 1250000,
        "profile": {
            "avatar": "https://example.com/avatar.jpg",
            "address": "Jl. Example No. 123",
            "date_of_birth": "1990-01-01"
        }
    }
}
```

### 3. Create New User

```http
POST /api/v1/admin/users
```

**Request Body:**

```json
{
    "name": "Jane Doe",
    "email": "jane@example.com",
    "phone": "081234567891",
    "password": "password123",
    "role": "member",
    "membership_type": "monthly",
    "membership_expires_at": "2024-02-15"
}
```

**Response:**

```json
{
    "success": true,
    "message": "User created successfully",
    "data": {
        "id": 2,
        "name": "Jane Doe",
        "email": "jane@example.com",
        "phone": "081234567891",
        "role": "member",
        "status": "active",
        "membership_type": "monthly",
        "membership_expires_at": "2024-02-15T23:59:59Z",
        "created_at": "2024-01-15T08:00:00Z"
    }
}
```

### 4. Update User

```http
PUT /api/v1/admin/users/{user_id}
```

**Request Body:**

```json
{
    "name": "Jane Smith",
    "phone": "081234567892",
    "role": "member",
    "membership_type": "quarterly",
    "membership_expires_at": "2024-04-15"
}
```

**Response:**

```json
{
    "success": true,
    "message": "User updated successfully",
    "data": {
        "id": 2,
        "name": "Jane Smith",
        "email": "jane@example.com",
        "phone": "081234567892",
        "role": "member",
        "status": "active",
        "membership_type": "quarterly",
        "membership_expires_at": "2024-04-15T23:59:59Z",
        "updated_at": "2024-01-15T08:30:00Z"
    }
}
```

### 5. Suspend User

```http
POST /api/v1/admin/users/{user_id}/suspend
```

**Request Body:**

```json
{
    "reason": "Violation of terms of service",
    "suspended_until": "2024-02-15"
}
```

**Response:**

```json
{
    "success": true,
    "message": "User suspended successfully",
    "data": {
        "id": 2,
        "status": "suspended",
        "suspended_at": "2024-01-15T08:30:00Z",
        "suspended_until": "2024-02-15T23:59:59Z",
        "suspension_reason": "Violation of terms of service"
    }
}
```

### 6. Activate User

```http
POST /api/v1/admin/users/{user_id}/activate
```

**Request Body:**

```json
{
    "notes": "User has been reactivated"
}
```

**Response:**

```json
{
    "success": true,
    "message": "User activated successfully",
    "data": {
        "id": 2,
        "status": "active",
        "activated_at": "2024-01-15T08:30:00Z",
        "notes": "User has been reactivated"
    }
}
```

### 7. Delete User

```http
DELETE /api/v1/admin/users/{user_id}
```

**Response:**

```json
{
    "success": true,
    "message": "User deleted successfully"
}
```

### 8. User Statistics

```http
GET /api/v1/admin/users/statistics
```

**Response:**

```json
{
    "success": true,
    "data": {
        "total_users": 120,
        "active_users": 110,
        "suspended_users": 10,
        "users_by_role": {
            "admin": 2,
            "staff": 5,
            "member": 45,
            "regular": 68
        },
        "users_by_membership": {
            "monthly": 25,
            "quarterly": 15,
            "yearly": 5
        },
        "new_users_this_month": 15,
        "users_expiring_soon": 8
    }
}
```

## Error Responses

### 401 Unauthorized

```json
{
    "success": false,
    "message": "Unauthorized"
}
```

### 403 Forbidden

```json
{
    "success": false,
    "message": "Access denied. Admin role required."
}
```

### 404 Not Found

```json
{
    "success": false,
    "message": "User not found"
}
```

### 422 Validation Error

```json
{
    "success": false,
    "message": "Validation failed",
    "errors": {
        "email": ["The email field is required."],
        "name": ["The name field is required."]
    }
}
```

## Frontend Integration Examples

### JavaScript/Axios

```javascript
// Get all users with filters
const getUsers = async (page = 1, search = "", role = "", status = "") => {
    try {
        const params = { page };
        if (search) params.search = search;
        if (role) params.role = role;
        if (status) params.status = status;

        const response = await axios.get("/api/v1/admin/users", {
            params,
            headers: {
                Authorization: `Bearer ${token}`,
                Accept: "application/json",
            },
        });
        return response.data;
    } catch (error) {
        console.error("Error fetching users:", error);
    }
};

// Create new user
const createUser = async (userData) => {
    try {
        const response = await axios.post("/api/v1/admin/users", userData, {
            headers: {
                Authorization: `Bearer ${token}`,
                Accept: "application/json",
                "Content-Type": "application/json",
            },
        });
        return response.data;
    } catch (error) {
        console.error("Error creating user:", error);
    }
};

// Suspend user
const suspendUser = async (userId, reason, suspendedUntil) => {
    try {
        const response = await axios.post(
            `/api/v1/admin/users/${userId}/suspend`,
            {
                reason,
                suspended_until: suspendedUntil,
            },
            {
                headers: {
                    Authorization: `Bearer ${token}`,
                    Accept: "application/json",
                    "Content-Type": "application/json",
                },
            }
        );
        return response.data;
    } catch (error) {
        console.error("Error suspending user:", error);
    }
};
```

### React Component

```jsx
import React, { useState, useEffect } from "react";
import axios from "axios";

const UserManagement = () => {
    const [users, setUsers] = useState([]);
    const [loading, setLoading] = useState(true);
    const [search, setSearch] = useState("");
    const [roleFilter, setRoleFilter] = useState("");

    useEffect(() => {
        const fetchUsers = async () => {
            try {
                const response = await axios.get("/api/v1/admin/users", {
                    params: { search, role: roleFilter },
                    headers: {
                        Authorization: `Bearer ${localStorage.getItem(
                            "token"
                        )}`,
                        Accept: "application/json",
                    },
                });
                setUsers(response.data.data.users);
            } catch (error) {
                console.error("Error fetching users:", error);
            } finally {
                setLoading(false);
            }
        };

        fetchUsers();
    }, [search, roleFilter]);

    const handleSuspendUser = async (userId) => {
        if (window.confirm("Are you sure you want to suspend this user?")) {
            try {
                await axios.post(
                    `/api/v1/admin/users/${userId}/suspend`,
                    {
                        reason: "Admin suspension",
                        suspended_until: new Date(
                            Date.now() + 30 * 24 * 60 * 60 * 1000
                        )
                            .toISOString()
                            .split("T")[0],
                    },
                    {
                        headers: {
                            Authorization: `Bearer ${localStorage.getItem(
                                "token"
                            )}`,
                            Accept: "application/json",
                            "Content-Type": "application/json",
                        },
                    }
                );
                // Refresh users list
                window.location.reload();
            } catch (error) {
                console.error("Error suspending user:", error);
            }
        }
    };

    if (loading) return <div>Loading...</div>;

    return (
        <div>
            <h2>User Management</h2>
            <div className="filters">
                <input
                    type="text"
                    placeholder="Search users..."
                    value={search}
                    onChange={(e) => setSearch(e.target.value)}
                />
                <select
                    value={roleFilter}
                    onChange={(e) => setRoleFilter(e.target.value)}
                >
                    <option value="">All Roles</option>
                    <option value="admin">Admin</option>
                    <option value="staff">Staff</option>
                    <option value="member">Member</option>
                    <option value="regular">Regular</option>
                </select>
            </div>

            <div className="users-list">
                {users.map((user) => (
                    <div key={user.id} className="user-item">
                        <div>
                            <h3>{user.name}</h3>
                            <p>{user.email}</p>
                            <p>Role: {user.role}</p>
                            <p>Status: {user.status}</p>
                        </div>
                        <div className="actions">
                            <button onClick={() => handleSuspendUser(user.id)}>
                                Suspend
                            </button>
                        </div>
                    </div>
                ))}
            </div>
        </div>
    );
};

export default UserManagement;
```

### Vue.js Component

```vue
<template>
    <div>
        <h2>User Management</h2>
        <div v-if="loading">Loading...</div>
        <div v-else>
            <div class="filters">
                <input
                    v-model="search"
                    type="text"
                    placeholder="Search users..."
                />
                <select v-model="roleFilter">
                    <option value="">All Roles</option>
                    <option value="admin">Admin</option>
                    <option value="staff">Staff</option>
                    <option value="member">Member</option>
                    <option value="regular">Regular</option>
                </select>
            </div>

            <div class="users-list">
                <div v-for="user in users" :key="user.id" class="user-item">
                    <div>
                        <h3>{{ user.name }}</h3>
                        <p>{{ user.email }}</p>
                        <p>Role: {{ user.role }}</p>
                        <p>Status: {{ user.status }}</p>
                    </div>
                    <div class="actions">
                        <button @click="suspendUser(user.id)">Suspend</button>
                    </div>
                </div>
            </div>
        </div>
    </div>
</template>

<script setup>
import { ref, onMounted, watch } from "vue";
import axios from "axios";

const users = ref([]);
const loading = ref(true);
const search = ref("");
const roleFilter = ref("");

const fetchUsers = async () => {
    try {
        const response = await axios.get("/api/v1/admin/users", {
            params: { search: search.value, role: roleFilter.value },
            headers: {
                Authorization: `Bearer ${localStorage.getItem("token")}`,
                Accept: "application/json",
            },
        });
        users.value = response.data.data.users;
    } catch (error) {
        console.error("Error fetching users:", error);
    } finally {
        loading.value = false;
    }
};

const suspendUser = async (userId) => {
    if (confirm("Are you sure you want to suspend this user?")) {
        try {
            await axios.post(
                `/api/v1/admin/users/${userId}/suspend`,
                {
                    reason: "Admin suspension",
                    suspended_until: new Date(
                        Date.now() + 30 * 24 * 60 * 60 * 1000
                    )
                        .toISOString()
                        .split("T")[0],
                },
                {
                    headers: {
                        Authorization: `Bearer ${localStorage.getItem(
                            "token"
                        )}`,
                        Accept: "application/json",
                        "Content-Type": "application/json",
                    },
                }
            );
            await fetchUsers();
        } catch (error) {
            console.error("Error suspending user:", error);
        }
    }
};

// Watch for changes in search and roleFilter
watch([search, roleFilter], () => {
    fetchUsers();
});

onMounted(() => {
    fetchUsers();
});
</script>
```

## Notes

-   Semua endpoint memerlukan autentikasi admin
-   User dapat difilter berdasarkan role, status, dan pencarian
-   Suspension dapat dilakukan dengan durasi tertentu
-   User statistics memberikan overview pengguna sistem
-   Pagination tersedia untuk list users
