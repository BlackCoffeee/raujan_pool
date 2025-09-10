# Quota Management API Documentation

## Overview

Sistem Dynamic Quota Management memungkinkan admin untuk mengelola konfigurasi quota member berdasarkan tipe membership, melacak penggunaan quota, dan memberikan analytics yang komprehensif.

## Base URL

```
/api/v1
```

## Authentication

Semua endpoint memerlukan authentication dengan Bearer token:

```
Authorization: Bearer {token}
```

## Admin Quota Management Endpoints

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
            "max_quota": 100,
            "daily_limit": 1,
            "additional_session_cost": "50000.00",
            "is_active": true,
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

Membuat konfigurasi quota baru untuk tipe membership tertentu.

**Request Body:**

```json
{
    "membership_type": "premium",
    "max_quota": 200,
    "daily_limit": 2,
    "additional_session_cost": 75000
}
```

**Validation Rules:**

-   `membership_type`: required, enum: regular, premium, vip
-   `max_quota`: required, integer, min: 1
-   `daily_limit`: nullable, integer, min: 1
-   `additional_session_cost`: nullable, numeric, min: 0

**Response:**

```json
{
    "success": true,
    "message": "Quota configuration created successfully",
    "data": {
        "id": 2,
        "membership_type": "premium",
        "max_quota": 200,
        "daily_limit": 2,
        "additional_session_cost": "75000.00",
        "is_active": true,
        "created_at": "2024-01-01T00:00:00.000000Z",
        "updated_at": "2024-01-01T00:00:00.000000Z"
    }
}
```

### 3. Get Quota Configuration by ID

**GET** `/admin/quota/configs/{id}`

Mengambil konfigurasi quota berdasarkan ID.

**Response:**

```json
{
    "success": true,
    "message": "Quota configuration retrieved successfully",
    "data": {
        "id": 1,
        "membership_type": "regular",
        "max_quota": 100,
        "daily_limit": 1,
        "additional_session_cost": "50000.00",
        "is_active": true,
        "created_by": {
            "id": 1,
            "name": "Admin User"
        },
        "created_at": "2024-01-01T00:00:00.000000Z",
        "updated_at": "2024-01-01T00:00:00.000000Z"
    }
}
```

### 4. Update Quota Configuration

**PUT** `/admin/quota/configs/{id}`

Mengupdate konfigurasi quota yang sudah ada.

**Request Body:**

```json
{
    "max_quota": 150,
    "daily_limit": 2,
    "additional_session_cost": 60000,
    "is_active": true
}
```

**Validation Rules:**

-   `max_quota`: nullable, integer, min: 1
-   `daily_limit`: nullable, integer, min: 1
-   `additional_session_cost`: nullable, numeric, min: 0
-   `is_active`: nullable, boolean

**Response:**

```json
{
    "success": true,
    "message": "Quota configuration updated successfully",
    "data": {
        "id": 1,
        "membership_type": "regular",
        "max_quota": 150,
        "daily_limit": 2,
        "additional_session_cost": "60000.00",
        "is_active": true,
        "updated_at": "2024-01-01T00:00:00.000000Z"
    }
}
```

### 5. Delete Quota Configuration

**DELETE** `/admin/quota/configs/{id}`

Menghapus konfigurasi quota. Hanya bisa dihapus jika tidak ada member aktif yang menggunakan tipe membership tersebut.

**Response:**

```json
{
    "success": true,
    "message": "Quota configuration deleted successfully",
    "data": null
}
```

**Error Response (jika ada member aktif):**

```json
{
    "success": false,
    "message": "Cannot delete quota config with active members",
    "data": null
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

-   `new_quota`: required, integer, min: 0
-   `reason`: nullable, string, max: 255

**Response:**

```json
{
    "success": true,
    "message": "Member quota adjusted successfully",
    "data": {
        "id": 1,
        "user_id": 1,
        "membership_type": "regular",
        "quota_remaining": 75,
        "quota_used": 25,
        "status": "active"
    }
}
```

### 7. Get Quota Statistics

**GET** `/admin/quota/stats`

Mengambil statistik quota secara keseluruhan.

**Query Parameters:**

-   `membership_type`: optional, filter berdasarkan tipe membership
-   `start_date`: optional, tanggal mulai filter
-   `end_date`: optional, tanggal akhir filter

**Response:**

```json
{
    "success": true,
    "message": "Quota statistics retrieved successfully",
    "data": {
        "total_members": 150,
        "total_quota_allocated": 15000,
        "total_quota_used": 7500,
        "total_quota_remaining": 7500,
        "average_quota_utilization": 50.0,
        "members_with_quota": 120,
        "members_without_quota": 30,
        "quota_by_membership_type": {
            "regular": {
                "count": 100,
                "total_quota": 10000,
                "used_quota": 5000,
                "remaining_quota": 5000,
                "utilization_percentage": 50.0
            },
            "premium": {
                "count": 30,
                "total_quota": 3000,
                "used_quota": 1500,
                "remaining_quota": 1500,
                "utilization_percentage": 50.0
            },
            "vip": {
                "count": 20,
                "total_quota": 2000,
                "used_quota": 1000,
                "remaining_quota": 1000,
                "utilization_percentage": 50.0
            }
        }
    }
}
```

### 8. Get Quota Analytics

**GET** `/admin/quota/analytics`

Mengambil analytics detail untuk quota management.

**Query Parameters:**

-   `start_date`: optional, tanggal mulai filter
-   `end_date`: optional, tanggal akhir filter
-   `member_id`: optional, filter berdasarkan member tertentu

**Response:**

```json
{
    "success": true,
    "message": "Quota analytics retrieved successfully",
    "data": {
        "quota_usage_trends": [
            {
                "date": "2024-01-01",
                "quota_used": 25,
                "quota_restored": 5
            }
        ],
        "quota_reasons": [
            {
                "reason": "booking_created",
                "count": 150,
                "total_quota_affected": 150
            },
            {
                "reason": "booking_cancelled",
                "count": 20,
                "total_quota_affected": 20
            }
        ],
        "top_quota_users": [
            {
                "member_id": 1,
                "member_name": "John Doe",
                "membership_type": "premium",
                "total_quota_used": 50,
                "total_quota_restored": 5
            }
        ],
        "quota_efficiency": {
            "total_quota_used": 1500,
            "total_quota_restored": 100,
            "net_quota_usage": 1400,
            "efficiency_rate": 93.33
        }
    }
}
```

### 9. Get Member Quota History

**GET** `/admin/quota/members/{id}/history`

Mengambil riwayat perubahan quota untuk member tertentu.

**Query Parameters:**

-   `per_page`: optional, jumlah item per halaman (default: 15)

**Response:**

```json
{
    "success": true,
    "message": "Member quota history retrieved successfully",
    "data": {
        "data": [
            {
                "id": 1,
                "member_id": 1,
                "quota_used": 2,
                "quota_remaining": 98,
                "reason": "booking_created",
                "booking_id": 123,
                "notes": null,
                "created_at": "2024-01-01T00:00:00.000000Z"
            }
        ],
        "current_page": 1,
        "per_page": 15,
        "total": 1
    }
}
```

### 10. Bulk Adjust Quota

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

-   `member_ids`: required, array, min: 1, setiap ID harus exists di table members
-   `new_quota`: required, integer, min: 0
-   `reason`: nullable, string, max: 255

**Response:**

```json
{
    "success": true,
    "message": "Bulk quota adjustment completed",
    "data": [
        {
            "member_id": 1,
            "success": true,
            "new_quota": 100
        },
        {
            "member_id": 2,
            "success": true,
            "new_quota": 100
        },
        {
            "member_id": 3,
            "success": false,
            "error": "Member not found"
        }
    ]
}
```

### 11. Get Members by Quota Status

**GET** `/admin/quota/members`

Mengambil daftar member berdasarkan status quota.

**Query Parameters:**

-   `status`: optional, enum: with_quota, without_quota, all (default: with_quota)
-   `per_page`: optional, jumlah item per halaman (default: 15)

**Response:**

```json
{
    "success": true,
    "message": "Members retrieved successfully",
    "data": {
        "data": [
            {
                "id": 1,
                "user_id": 1,
                "membership_type": "regular",
                "quota_remaining": 50,
                "quota_used": 50,
                "user": {
                    "id": 1,
                    "name": "John Doe",
                    "email": "john@example.com"
                },
                "quotaHistory": [
                    {
                        "id": 1,
                        "reason": "booking_created",
                        "quota_used": 2,
                        "created_at": "2024-01-01T00:00:00.000000Z"
                    }
                ]
            }
        ],
        "current_page": 1,
        "per_page": 15,
        "total": 1
    }
}
```

## Member Quota Access Endpoints

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
        "quota_remaining": 75,
        "max_quota": 100,
        "utilization_percentage": 25.0,
        "daily_limit": 1,
        "additional_session_cost": "50000.00",
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
    "message": "Quota configuration not found",
    "data": null
}
```

### Server Error (500)

```json
{
    "success": false,
    "message": "Internal server error",
    "data": null
}
```

## Business Logic

### Quota Configuration Management

-   Setiap tipe membership hanya bisa memiliki satu konfigurasi aktif
-   Ketika konfigurasi baru dibuat, konfigurasi lama otomatis dinonaktifkan
-   Perubahan konfigurasi akan mempengaruhi member yang sudah ada

### Quota Usage Tracking

-   Setiap penggunaan quota dicatat dengan reason dan booking ID
-   Quota dapat dipulihkan ketika booking dibatalkan
-   History quota disimpan untuk audit dan analytics

### Quota Analytics

-   Trend penggunaan quota per hari
-   Analisis berdasarkan reason penggunaan
-   Top users berdasarkan penggunaan quota
-   Efisiensi penggunaan quota

## Rate Limiting

Semua endpoint dibatasi maksimal 60 request per menit per user.

## Notes

-   Semua endpoint admin memerlukan role 'admin'
-   Endpoint member hanya bisa diakses oleh member yang sudah login
-   Perubahan quota akan otomatis mempengaruhi kemampuan booking member
-   Analytics data dihitung secara real-time dari database
