# Quota Management API Documentation

## Overview

Sistem Quota Management memungkinkan admin untuk mengelola konfigurasi quota member dan member untuk melihat informasi quota mereka sendiri.

## Base URL

```
/api/v1
```

## Authentication

Semua endpoint memerlukan authentication. Admin endpoints memerlukan role admin, sedangkan member endpoints memerlukan user yang terdaftar sebagai member.

## Admin Endpoints

### 1. Get Quota Configurations

**GET** `/admin/quota/configs`

Mengambil semua konfigurasi quota yang tersedia.

**Response:**

```json
{
    "success": true,
    "message": "Quota configurations retrieved successfully",
    "data": [
        {
            "id": 1,
            "membership_type": "regular",
            "max_quota": 50,
            "daily_limit": 1,
            "additional_session_cost": 50000,
            "is_active": true,
            "notes": "Regular membership quota",
            "created_by": {
                "id": 1,
                "name": "Admin User"
            },
            "created_at": "2024-01-01T00:00:00.000000Z",
            "updated_at": "2024-01-01T00:00:00.000000Z"
        }
    ]
}
```

### 2. Create Quota Configuration

**POST** `/admin/quota/configs`

Membuat konfigurasi quota baru.

**Request Body:**

```json
{
    "membership_type": "regular",
    "max_quota": 50,
    "daily_limit": 1,
    "additional_session_cost": 50000,
    "notes": "Regular membership quota"
}
```

**Validation Rules:**

-   `membership_type`: required, in:regular,premium,vip
-   `max_quota`: required, integer, min:1
-   `daily_limit`: nullable, integer, min:1
-   `additional_session_cost`: nullable, numeric, min:0
-   `notes`: nullable, string

**Response:**

```json
{
    "success": true,
    "message": "Quota configuration created successfully",
    "data": {
        "id": 1,
        "membership_type": "regular",
        "max_quota": 50,
        "daily_limit": 1,
        "additional_session_cost": 50000,
        "is_active": true,
        "notes": "Regular membership quota",
        "created_at": "2024-01-01T00:00:00.000000Z",
        "updated_at": "2024-01-01T00:00:00.000000Z"
    }
}
```

### 3. Update Quota Configuration

**PUT** `/admin/quota/configs/{id}`

Mengupdate konfigurasi quota yang ada.

**Request Body:**

```json
{
    "max_quota": 75,
    "daily_limit": 2,
    "additional_session_cost": 45000,
    "is_active": true,
    "notes": "Updated regular membership quota"
}
```

**Validation Rules:**

-   `max_quota`: nullable, integer, min:1
-   `daily_limit`: nullable, integer, min:1
-   `additional_session_cost`: nullable, numeric, min:0
-   `is_active`: nullable, boolean
-   `notes`: nullable, string

**Response:**

```json
{
    "success": true,
    "message": "Quota configuration updated successfully",
    "data": {
        "id": 1,
        "membership_type": "regular",
        "max_quota": 75,
        "daily_limit": 2,
        "additional_session_cost": 45000,
        "is_active": true,
        "notes": "Updated regular membership quota",
        "updated_at": "2024-01-01T00:00:00.000000Z"
    }
}
```

### 4. Delete Quota Configuration

**DELETE** `/admin/quota/configs/{id}`

Menghapus konfigurasi quota. Hanya bisa dihapus jika tidak ada member aktif yang menggunakan membership type tersebut.

**Response:**

```json
{
    "success": true,
    "message": "Quota configuration deleted successfully",
    "data": null
}
```

**Error Response (400):**

```json
{
    "success": false,
    "message": "Cannot delete quota config with active members"
}
```

### 5. Get Quota Configuration by ID

**GET** `/admin/quota/configs/{id}`

Mengambil detail konfigurasi quota berdasarkan ID.

**Response:**

```json
{
    "success": true,
    "message": "Quota configuration retrieved successfully",
    "data": {
        "id": 1,
        "membership_type": "regular",
        "max_quota": 50,
        "daily_limit": 1,
        "additional_session_cost": 50000,
        "is_active": true,
        "notes": "Regular membership quota",
        "created_by": {
            "id": 1,
            "name": "Admin User"
        },
        "created_at": "2024-01-01T00:00:00.000000Z",
        "updated_at": "2024-01-01T00:00:00.000000Z"
    }
}
```

### 6. Adjust Member Quota

**POST** `/admin/quota/members/{id}/adjust`

Mengatur ulang quota member secara manual.

**Request Body:**

```json
{
    "new_quota": 75,
    "reason": "Special promotion"
}
```

**Validation Rules:**

-   `new_quota`: required, integer, min:0
-   `reason`: nullable, string, max:255

**Response:**

```json
{
    "success": true,
    "message": "Member quota adjusted successfully",
    "data": {
        "id": 1,
        "user_id": 1,
        "membership_type": "regular",
        "quota_used": 15,
        "quota_remaining": 75,
        "max_quota": 50,
        "daily_limit": 1,
        "additional_session_cost": 50000,
        "updated_at": "2024-01-01T00:00:00.000000Z"
    }
}
```

### 7. Bulk Adjust Quota

**POST** `/admin/quota/bulk-adjust`

Mengatur ulang quota untuk multiple member sekaligus.

**Request Body:**

```json
{
    "member_ids": [1, 2, 3],
    "new_quota": 100,
    "reason": "Bulk promotion"
}
```

**Validation Rules:**

-   `member_ids`: required, array, min:1
-   `member_ids.*`: exists:members,id
-   `new_quota`: required, integer, min:0
-   `reason`: nullable, string, max:255

**Response:**

```json
{
    "success": true,
    "message": "Bulk quota adjustment completed",
    "data": [
        {
            "member_id": 1,
            "success": true,
            "new_quota": 100,
            "message": "Quota adjusted successfully"
        },
        {
            "member_id": 2,
            "success": true,
            "new_quota": 100,
            "message": "Quota adjusted successfully"
        },
        {
            "member_id": 3,
            "success": true,
            "new_quota": 100,
            "message": "Quota adjusted successfully"
        }
    ]
}
```

### 8. Get Quota Statistics

**GET** `/admin/quota/stats`

Mengambil statistik quota secara keseluruhan.

**Query Parameters:**

-   `membership_type`: optional, filter by membership type
-   `start_date`: optional, start date for filtering (YYYY-MM-DD)
-   `end_date`: optional, end date for filtering (YYYY-MM-DD)

**Response:**

```json
{
    "success": true,
    "message": "Quota statistics retrieved successfully",
    "data": {
        "total_members": 150,
        "total_quota_allocated": 7500,
        "total_quota_used": 3200,
        "total_quota_remaining": 4300,
        "average_utilization": 42.67,
        "membership_breakdown": {
            "regular": {
                "count": 100,
                "total_quota": 5000,
                "used_quota": 2000,
                "remaining_quota": 3000
            },
            "premium": {
                "count": 35,
                "total_quota": 1750,
                "used_quota": 800,
                "remaining_quota": 950
            },
            "vip": {
                "count": 15,
                "total_quota": 750,
                "used_quota": 400,
                "remaining_quota": 350
            }
        }
    }
}
```

### 9. Get Quota Analytics

**GET** `/admin/quota/analytics`

Mengambil data analitik quota untuk periode tertentu.

**Query Parameters:**

-   `start_date`: optional, start date (YYYY-MM-DD)
-   `end_date`: optional, end date (YYYY-MM-DD)
-   `member_id`: optional, filter by specific member

**Response:**

```json
{
    "success": true,
    "message": "Quota analytics retrieved successfully",
    "data": {
        "period": {
            "start_date": "2024-01-01",
            "end_date": "2024-01-31"
        },
        "usage_trends": [
            {
                "date": "2024-01-01",
                "quota_used": 150,
                "quota_restored": 25,
                "active_members": 120
            }
        ],
        "top_quota_users": [
            {
                "member_id": 1,
                "user_name": "John Doe",
                "quota_used": 45,
                "quota_remaining": 5
            }
        ],
        "quota_efficiency": {
            "average_daily_usage": 12.5,
            "peak_usage_day": "2024-01-15",
            "peak_usage_amount": 200
        }
    }
}
```

### 10. Get Member Quota History

**GET** `/admin/quota/members/{id}/history`

Mengambil riwayat penggunaan quota untuk member tertentu.

**Query Parameters:**

-   `per_page`: optional, number of items per page (default: 15)

**Response:**

```json
{
    "success": true,
    "message": "Member quota history retrieved successfully",
    "data": {
        "current_page": 1,
        "data": [
            {
                "id": 1,
                "member_id": 1,
                "quota_used": 2,
                "quota_restored": 0,
                "reason": "booking_session",
                "booking": {
                    "id": 1,
                    "session_date": "2024-01-01",
                    "session_time": "10:00:00"
                },
                "created_at": "2024-01-01T10:00:00.000000Z"
            }
        ],
        "total": 25,
        "per_page": 15
    }
}
```

### 11. Get Members by Quota Status

**GET** `/admin/quota/members`

Mengambil daftar member berdasarkan status quota mereka.

**Query Parameters:**

-   `status`: optional, with_quota|without_quota|all (default: with_quota)
-   `per_page`: optional, number of items per page (default: 15)

**Response:**

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
                "membership_type": "regular",
                "quota_remaining": 25,
                "quota_used": 25,
                "user": {
                    "id": 1,
                    "name": "John Doe",
                    "email": "john@example.com"
                },
                "quota_history": [
                    {
                        "id": 1,
                        "quota_used": 2,
                        "reason": "booking_session",
                        "created_at": "2024-01-01T10:00:00.000000Z"
                    }
                ]
            }
        ],
        "total": 120,
        "per_page": 15
    }
}
```

## Member Endpoints

### 1. Get My Quota

**GET** `/members/quota`

Member dapat melihat informasi quota mereka sendiri.

**Response:**

```json
{
    "success": true,
    "message": "Quota information retrieved successfully",
    "data": {
        "member_id": 1,
        "membership_type": "regular",
        "quota_used": 25,
        "quota_remaining": 25,
        "max_quota": 50,
        "utilization_percentage": 50.0,
        "daily_limit": 1,
        "additional_session_cost": 50000,
        "can_book": true
    }
}
```

## Error Responses

### Validation Error (422)

```json
{
    "success": false,
    "message": "The given data was invalid.",
    "errors": {
        "membership_type": ["The membership type field is required."],
        "max_quota": ["The max quota must be at least 1."]
    }
}
```

### Not Found Error (404)

```json
{
    "success": false,
    "message": "No query results for model [App\\Models\\MemberQuotaConfig] 1"
}
```

### Business Logic Error (400)

```json
{
    "success": false,
    "message": "Cannot delete quota config with active members"
}
```

## Data Models

### MemberQuotaConfig

-   `id`: Primary key
-   `membership_type`: Enum (regular, premium, vip)
-   `max_quota`: Maximum quota allocation
-   `daily_limit`: Daily booking limit
-   `additional_session_cost`: Cost for additional sessions
-   `is_active`: Whether config is active
-   `notes`: Additional notes
-   `created_by`: User who created the config
-   `created_at`: Creation timestamp
-   `updated_at`: Last update timestamp

### MemberQuotaHistory

-   `id`: Primary key
-   `member_id`: Reference to member
-   `quota_used`: Quota used in this transaction
-   `quota_restored`: Quota restored in this transaction
-   `reason`: Reason for quota change
-   `booking_id`: Reference to booking (if applicable)
-   `created_at`: Transaction timestamp

## Business Rules

1. **Unique Active Configs**: Hanya satu konfigurasi aktif yang diperbolehkan per membership type
2. **Quota Validation**: Member tidak bisa menggunakan quota melebihi yang tersedia
3. **Deletion Protection**: Konfigurasi quota tidak bisa dihapus jika masih ada member aktif
4. **History Tracking**: Semua perubahan quota dicatat dengan alasan
5. **Auto-update**: Perubahan konfigurasi otomatis mengupdate member yang terkait

## Rate Limiting

-   Admin endpoints: 100 requests per minute
-   Member endpoints: 60 requests per minute

## Testing

Semua endpoint telah diuji dengan coverage > 90% menggunakan Pest PHP testing framework.

## Support

Untuk pertanyaan atau bantuan teknis, silakan hubungi tim development.
