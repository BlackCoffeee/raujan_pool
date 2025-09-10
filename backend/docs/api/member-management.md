# Member Management API

## Overview
API untuk mengelola member registration, profile management, dan member analytics dalam sistem kolam renang.

## Authentication
Semua endpoint memerlukan authentication menggunakan Bearer token, kecuali yang disebutkan sebaliknya.

## Admin vs Member Access
- **Admin routes**: `/api/v1/admin/members/*` - Hanya admin yang bisa akses
- **Member routes**: `/api/v1/members/*` - Member bisa akses untuk profile sendiri

## Endpoints

### 1. Member Registration

#### POST `/api/v1/members/register`
Mendaftarkan user sebagai member baru.

**Request:**
```json
{
    "user_id": 1,
    "membership_type": "regular",
    "membership_start": "2025-09-03",
    "membership_end": "2026-09-03",
    "notes": "New member registration"
}
```

**Response (201):**
```json
{
    "success": true,
    "message": "Member registered successfully",
    "data": {
        "id": 1,
        "user_id": 1,
        "membership_number": "REG2025090001",
        "membership_type": "regular",
        "status": "active",
        "joined_date": "2025-09-03",
        "membership_start": "2025-09-03",
        "membership_end": "2026-09-03",
        "quota_used": 0,
        "quota_remaining": 50,
        "daily_usage_count": 0,
        "total_bookings": 0,
        "total_amount_spent": 0,
        "is_premium": false,
        "notes": "New member registration",
        "created_at": "2025-09-03T00:00:00.000000Z",
        "updated_at": "2025-09-03T00:00:00.000000Z",
        "user": {
            "id": 1,
            "name": "John Doe",
            "email": "john@example.com"
        }
    }
}
```

### 2. Admin Member Management

#### GET `/api/v1/admin/members`
Mendapatkan daftar semua member (Admin only).

**Query Parameters:**
- `status` - Filter by status (active, inactive, suspended, expired)
- `membership_type` - Filter by membership type (regular, premium, vip)
- `start_date` - Filter by joined date range
- `end_date` - Filter by joined date range
- `expiring_soon` - Filter members expiring soon (number of days)
- `per_page` - Number of items per page (default: 15)

**Response (200):**
```json
{
    "success": true,
    "message": "Members retrieved successfully",
    "data": {
        "current_page": 1,
        "data": [
            {
                "id": 1,
                "user_id": 1,
                "membership_number": "REG2025090001",
                "membership_type": "regular",
                "status": "active",
                "quota_remaining": 50,
                "membership_end": "2026-09-03",
                "user": {
                    "id": 1,
                    "name": "John Doe",
                    "email": "john@example.com"
                }
            }
        ],
        "total": 1,
        "per_page": 15
    }
}
```

#### GET `/api/v1/admin/members/{id}`
Mendapatkan detail member (Admin only).

**Response (200):**
```json
{
    "success": true,
    "message": "Member retrieved successfully",
    "data": {
        "id": 1,
        "user_id": 1,
        "membership_number": "REG2025090001",
        "membership_type": "regular",
        "status": "active",
        "joined_date": "2025-09-03",
        "membership_start": "2025-09-03",
        "membership_end": "2026-09-03",
        "quota_used": 0,
        "quota_remaining": 50,
        "daily_usage_count": 0,
        "total_bookings": 0,
        "total_amount_spent": 0,
        "is_premium": false,
        "user": {
            "id": 1,
            "name": "John Doe",
            "email": "john@example.com"
        },
        "quota_history": [],
        "daily_usage": []
    }
}
```

#### PUT `/api/v1/admin/members/{id}`
Update data member (Admin only).

**Request:**
```json
{
    "user_id": 1,
    "membership_type": "premium",
    "membership_end": "2026-09-03",
    "notes": "Upgraded to premium"
}
```

**Response (200):**
```json
{
    "success": true,
    "message": "Member updated successfully",
    "data": {
        "id": 1,
        "membership_type": "premium",
        "is_premium": true,
        "quota_remaining": 100,
        "updated_at": "2025-09-03T00:00:00.000000Z"
    }
}
```

#### DELETE `/api/v1/admin/members/{id}`
Hapus member (Admin only).

**Response (200):**
```json
{
    "success": true,
    "message": "Member deleted successfully",
    "data": null
}
```

### 3. Member Status Management

#### POST `/api/v1/admin/members/{id}/suspend`
Suspend member (Admin only).

**Request:**
```json
{
    "reason": "Policy violation"
}
```

**Response (200):**
```json
{
    "success": true,
    "message": "Member suspended successfully",
    "data": {
        "id": 1,
        "status": "suspended",
        "notes": "Policy violation"
    }
}
```

#### POST `/api/v1/admin/members/{id}/activate`
Activate member (Admin only).

**Response (200):**
```json
{
    "success": true,
    "message": "Member activated successfully",
    "data": {
        "id": 1,
        "status": "active"
    }
}
```

#### POST `/api/v1/admin/members/{id}/expire`
Expire member (Admin only).

**Response (200):**
```json
{
    "success": true,
    "message": "Member expired successfully",
    "data": {
        "id": 1,
        "status": "expired"
    }
}
```

#### POST `/api/v1/admin/members/{id}/renew`
Renew membership (Admin only).

**Request:**
```json
{
    "new_end_date": "2027-09-03"
}
```

**Response (200):**
```json
{
    "success": true,
    "message": "Membership renewed successfully",
    "data": {
        "id": 1,
        "membership_end": "2027-09-03",
        "status": "active"
    }
}
```

### 4. Member Profile Management

#### GET `/api/v1/members/profile`
Mendapatkan profile member yang sedang login.

**Response (200):**
```json
{
    "success": true,
    "message": "Member profile retrieved successfully",
    "data": {
        "id": 1,
        "user_id": 1,
        "membership_number": "REG2025090001",
        "membership_type": "regular",
        "status": "active",
        "joined_date": "2025-09-03",
        "membership_start": "2025-09-03",
        "membership_end": "2026-09-03",
        "quota_used": 5,
        "quota_remaining": 45,
        "daily_usage_count": 1,
        "total_bookings": 5,
        "total_amount_spent": 250000,
        "is_premium": false,
        "user": {
            "id": 1,
            "name": "John Doe",
            "email": "john@example.com",
            "phone": "081234567890"
        },
        "quota_history": [
            {
                "id": 1,
                "quota_used": 1,
                "quota_remaining": 49,
                "reason": "booking_confirmed",
                "created_at": "2025-09-03T10:00:00.000000Z"
            }
        ]
    }
}
```

#### PUT `/api/v1/members/profile`
Update profile member yang sedang login.

**Request:**
```json
{
    "notes": "Updated notes"
}
```

**Response (200):**
```json
{
    "success": true,
    "message": "Member profile updated successfully",
    "data": {
        "id": 1,
        "notes": "Updated notes",
        "updated_at": "2025-09-03T00:00:00.000000Z"
    }
}
```

### 5. Member Analytics (Admin only)

#### GET `/api/v1/admin/members/stats`
Mendapatkan statistik member.

**Query Parameters:**
- `start_date` - Filter by date range
- `end_date` - Filter by date range
- `membership_type` - Filter by membership type
- `status` - Filter by status

**Response (200):**
```json
{
    "success": true,
    "message": "Member statistics retrieved successfully",
    "data": {
        "total_members": 100,
        "active_members": 80,
        "inactive_members": 5,
        "suspended_members": 10,
        "expired_members": 5,
        "expiring_soon": 15,
        "total_revenue": 25000000,
        "average_revenue_per_member": 250000,
        "membership_types": [
            {
                "membership_type": "regular",
                "count": 60
            },
            {
                "membership_type": "premium",
                "count": 30
            },
            {
                "membership_type": "vip",
                "count": 10
            }
        ]
    }
}
```

#### GET `/api/v1/admin/members/analytics`
Mendapatkan analytics member yang lebih detail.

**Response (200):**
```json
{
    "success": true,
    "message": "Member analytics retrieved successfully",
    "data": {
        "member_growth": [
            {
                "date": "2025-09-01",
                "new_members": 5,
                "total_members": 95
            },
            {
                "date": "2025-09-02",
                "new_members": 3,
                "total_members": 98
            }
        ],
        "membership_type_distribution": [
            {
                "membership_type": "regular",
                "count": 60,
                "total_revenue": 15000000
            }
        ],
        "quota_utilization": {
            "average_utilization": 45.5,
            "high_utilization": 20,
            "low_utilization": 15,
            "no_quota_remaining": 5
        },
        "revenue_analytics": {
            "total_revenue": 25000000,
            "average_revenue": 250000,
            "top_spenders": [],
            "revenue_by_type": {
                "regular": {
                    "count": 60,
                    "total_revenue": 15000000,
                    "average_revenue": 250000
                }
            }
        },
        "retention_analytics": {
            "retention_rate": 85.5,
            "churn_rate": 14.5,
            "average_membership_duration": 365
        }
    }
}
```

### 6. Bulk Operations

#### POST `/api/v1/admin/members/process-expired`
Proses member yang sudah expired (Admin only).

**Response (200):**
```json
{
    "success": true,
    "message": "Expired memberships processed successfully",
    "data": {
        "processed_count": 5
    }
}
```

#### POST `/api/v1/admin/members/convert-guest/{userId}`
Convert guest user menjadi member (Admin only).

**Request:**
```json
{
    "membership_type": "regular",
    "membership_start": "2025-09-03",
    "membership_end": "2026-09-03",
    "notes": "Converted from guest"
}
```

**Response (201):**
```json
{
    "success": true,
    "message": "Guest converted to member successfully",
    "data": {
        "id": 1,
        "user_id": 1,
        "membership_number": "REG2025090001",
        "membership_type": "regular",
        "status": "active"
    }
}
```

## Error Responses

### 400 Bad Request
```json
{
    "success": false,
    "message": "User is already a member",
    "data": null,
    "errors": null
}
```

### 422 Validation Error
```json
{
    "success": false,
    "message": "User is required (and 2 more errors)",
    "data": null,
    "errors": {
        "user_id": [
            "User is required"
        ],
        "membership_type": [
            "Membership type is required"
        ],
        "membership_end": [
            "Membership end date is required"
        ]
    }
}
```

### 403 Forbidden
```json
{
    "success": false,
    "message": "Unauthorized access",
    "data": null,
    "errors": null
}
```

### 404 Not Found
```json
{
    "success": false,
    "message": "Member not found",
    "data": null,
    "errors": null
}
```

## Membership Types

- **regular**: Member reguler dengan quota 50 sesi
- **premium**: Member premium dengan quota 100 sesi
- **vip**: Member VIP dengan quota unlimited

## Member Status

- **active**: Member aktif dan bisa booking
- **inactive**: Member tidak aktif
- **suspended**: Member di-suspend karena pelanggaran
- **expired**: Membership sudah expired

## Business Rules

1. User hanya bisa menjadi member satu kali
2. Member yang suspended tidak bisa melakukan booking
3. Member yang expired akan otomatis diproses oleh sistem
4. Quota member akan berkurang setiap kali booking dikonfirmasi
5. Daily limit membatasi jumlah booking per hari
6. Member premium dan VIP mendapat benefit tambahan

## Testing

Untuk testing API, gunakan command:
```bash
php artisan test tests/Feature/MemberTest.php
```

Coverage saat ini: ~59% (10/17 tests passing)
