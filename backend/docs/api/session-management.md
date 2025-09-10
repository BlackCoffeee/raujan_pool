# Session Management API Documentation

## Overview

Session Management API menyediakan endpoint untuk mengelola session renang dengan fitur CRUD operations, capacity management, time slot management, session scheduling, status management, dan pricing management.

## Base URL

```
/api/v1/sessions
```

## Authentication

Semua endpoint memerlukan authentication menggunakan Sanctum token.

```bash
Authorization: Bearer {token}
```

## Endpoints

### 1. Get All Sessions

**GET** `/api/v1/sessions`

Mengambil daftar semua session dengan filtering dan pagination.

#### Query Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `is_active` | boolean | No | Filter berdasarkan status aktif |
| `is_peak_hour` | boolean | No | Filter berdasarkan peak hour |
| `min_capacity` | integer | No | Filter kapasitas minimum |
| `max_capacity` | integer | No | Filter kapasitas maksimum |
| `start_time` | string | No | Filter waktu mulai (HH:MM) |
| `end_time` | string | No | Filter waktu selesai (HH:MM) |
| `per_page` | integer | No | Jumlah item per halaman (default: 15) |

#### Response

```json
{
    "success": true,
    "message": "Sessions retrieved successfully",
    "data": {
        "current_page": 1,
        "data": [
            {
                "id": 1,
                "name": "Morning Session",
                "description": "Morning swimming session",
                "start_time": "06:00",
                "end_time": "10:00",
                "max_capacity": 50,
                "current_capacity": 0,
                "is_active": true,
                "is_peak_hour": false,
                "peak_hour_multiplier": "1.00",
                "advance_booking_days": 7,
                "cancellation_hours": 24,
                "check_in_start_minutes": 30,
                "check_in_end_minutes": 15,
                "auto_cancel_minutes": 30,
                "notes": null,
                "created_by": 1,
                "updated_by": null,
                "created_at": "2025-09-01T10:00:00.000000Z",
                "updated_at": "2025-09-01T10:00:00.000000Z",
                "created_by_user": {
                    "id": 1,
                    "name": "Admin User"
                }
            }
        ],
        "first_page_url": "http://localhost/api/v1/sessions?page=1",
        "from": 1,
        "last_page": 1,
        "last_page_url": "http://localhost/api/v1/sessions?page=1",
        "links": [...],
        "next_page_url": null,
        "path": "http://localhost/api/v1/sessions",
        "per_page": 15,
        "prev_page_url": null,
        "to": 1,
        "total": 1
    }
}
```

### 2. Create Session

**POST** `/api/v1/sessions`

Membuat session baru.

#### Request Body

```json
{
    "name": "Morning Session",
    "description": "Morning swimming session",
    "start_time": "06:00",
    "end_time": "10:00",
    "max_capacity": 50,
    "is_active": true,
    "is_peak_hour": false,
    "peak_hour_multiplier": 1.00,
    "advance_booking_days": 7,
    "cancellation_hours": 24,
    "check_in_start_minutes": 30,
    "check_in_end_minutes": 15,
    "auto_cancel_minutes": 30,
    "notes": "Additional notes"
}
```

#### Validation Rules

| Field | Rules |
|-------|-------|
| `name` | required, string, max:255 |
| `description` | nullable, string, max:1000 |
| `start_time` | required, date_format:H:i |
| `end_time` | required, date_format:H:i, after:start_time |
| `max_capacity` | required, integer, min:1, max:1000 |
| `is_active` | nullable, boolean |
| `is_peak_hour` | nullable, boolean |
| `peak_hour_multiplier` | nullable, numeric, min:1, max:5 |
| `advance_booking_days` | nullable, integer, min:0, max:365 |
| `cancellation_hours` | nullable, integer, min:0, max:168 |
| `check_in_start_minutes` | nullable, integer, min:0, max:120 |
| `check_in_end_minutes` | nullable, integer, min:0, max:120 |
| `auto_cancel_minutes` | nullable, integer, min:0, max:120 |
| `notes` | nullable, string, max:1000 |

#### Response

```json
{
    "success": true,
    "message": "Session created successfully",
    "data": {
        "id": 1,
        "name": "Morning Session",
        "description": "Morning swimming session",
        "start_time": "06:00",
        "end_time": "10:00",
        "max_capacity": 50,
        "current_capacity": 0,
        "is_active": true,
        "is_peak_hour": false,
        "peak_hour_multiplier": "1.00",
        "advance_booking_days": 7,
        "cancellation_hours": 24,
        "check_in_start_minutes": 30,
        "check_in_end_minutes": 15,
        "auto_cancel_minutes": 30,
        "notes": "Additional notes",
        "created_by": 1,
        "updated_by": null,
        "created_at": "2025-09-01T10:00:00.000000Z",
        "updated_at": "2025-09-01T10:00:00.000000Z",
        "created_by_user": {
            "id": 1,
            "name": "Admin User"
        }
    }
}
```

### 3. Get Session by ID

**GET** `/api/v1/sessions/{id}`

Mengambil detail session berdasarkan ID.

#### Response

```json
{
    "success": true,
    "message": "Session retrieved successfully",
    "data": {
        "id": 1,
        "name": "Morning Session",
        "description": "Morning swimming session",
        "start_time": "06:00",
        "end_time": "10:00",
        "max_capacity": 50,
        "current_capacity": 0,
        "is_active": true,
        "is_peak_hour": false,
        "peak_hour_multiplier": "1.00",
        "advance_booking_days": 7,
        "cancellation_hours": 24,
        "check_in_start_minutes": 30,
        "check_in_end_minutes": 15,
        "auto_cancel_minutes": 30,
        "notes": "Additional notes",
        "created_by": 1,
        "updated_by": null,
        "created_at": "2025-09-01T10:00:00.000000Z",
        "updated_at": "2025-09-01T10:00:00.000000Z",
        "created_by_user": {
            "id": 1,
            "name": "Admin User"
        },
        "updated_by_user": null,
        "session_pricings": [
            {
                "id": 1,
                "session_id": 1,
                "booking_type": "regular",
                "adult_price": "50000.00",
                "child_price": "25000.00",
                "peak_hour_adult_price": null,
                "peak_hour_child_price": null,
                "is_active": true,
                "valid_from": "2025-09-01",
                "valid_until": null,
                "created_by": 1,
                "updated_by": null,
                "created_at": "2025-09-01T10:00:00.000000Z",
                "updated_at": "2025-09-01T10:00:00.000000Z"
            }
        ]
    }
}
```

### 4. Update Session

**PUT** `/api/v1/sessions/{id}`

Mengupdate session berdasarkan ID.

#### Request Body

```json
{
    "name": "Updated Morning Session",
    "max_capacity": 75,
    "is_peak_hour": true,
    "peak_hour_multiplier": 1.5
}
```

#### Response

```json
{
    "success": true,
    "message": "Session updated successfully",
    "data": {
        "id": 1,
        "name": "Updated Morning Session",
        "description": "Morning swimming session",
        "start_time": "06:00",
        "end_time": "10:00",
        "max_capacity": 75,
        "current_capacity": 0,
        "is_active": true,
        "is_peak_hour": true,
        "peak_hour_multiplier": "1.50",
        "advance_booking_days": 7,
        "cancellation_hours": 24,
        "check_in_start_minutes": 30,
        "check_in_end_minutes": 15,
        "auto_cancel_minutes": 30,
        "notes": "Additional notes",
        "created_by": 1,
        "updated_by": 1,
        "created_at": "2025-09-01T10:00:00.000000Z",
        "updated_at": "2025-09-01T10:30:00.000000Z",
        "updated_by_user": {
            "id": 1,
            "name": "Admin User"
        }
    }
}
```

### 5. Delete Session

**DELETE** `/api/v1/sessions/{id}`

Menghapus session berdasarkan ID.

#### Response

```json
{
    "success": true,
    "message": "Session deleted successfully",
    "data": null
}
```

#### Error Response

```json
{
    "success": false,
    "message": "Cannot delete session with active bookings",
    "data": null
}
```

### 6. Activate Session

**POST** `/api/v1/sessions/{id}/activate`

Mengaktifkan session.

#### Response

```json
{
    "success": true,
    "message": "Session activated successfully",
    "data": {
        "id": 1,
        "name": "Morning Session",
        "is_active": true,
        "updated_by": 1,
        "updated_at": "2025-09-01T10:30:00.000000Z"
    }
}
```

### 7. Deactivate Session

**POST** `/api/v1/sessions/{id}/deactivate`

Menonaktifkan session.

#### Response

```json
{
    "success": true,
    "message": "Session deactivated successfully",
    "data": {
        "id": 1,
        "name": "Morning Session",
        "is_active": false,
        "updated_by": 1,
        "updated_at": "2025-09-01T10:30:00.000000Z"
    }
}
```

### 8. Update Session Capacity

**PUT** `/api/v1/sessions/{id}/capacity`

Mengupdate kapasitas session.

#### Request Body

```json
{
    "max_capacity": 100
}
```

#### Response

```json
{
    "success": true,
    "message": "Session capacity updated successfully",
    "data": {
        "id": 1,
        "name": "Morning Session",
        "max_capacity": 100,
        "updated_by": 1,
        "updated_at": "2025-09-01T10:30:00.000000Z"
    }
}
```

### 9. Get Session Statistics

**GET** `/api/v1/sessions/{id}/stats`

Mengambil statistik session.

#### Query Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `start_date` | date | No | Tanggal mulai (default: 30 hari lalu) |
| `end_date` | date | No | Tanggal selesai (default: hari ini) |

#### Response

```json
{
    "success": true,
    "message": "Session statistics retrieved successfully",
    "data": {
        "session_id": 1,
        "session_name": "Morning Session",
        "period": {
            "start_date": "2025-08-01",
            "end_date": "2025-09-01"
        },
        "total_bookings": 45,
        "confirmed_bookings": 40,
        "cancelled_bookings": 3,
        "completed_bookings": 35,
        "no_show_bookings": 2,
        "total_revenue": 2250000,
        "average_booking_value": 50000,
        "utilization_rate": 78.5,
        "peak_hours": {
            "08": 12,
            "09": 15,
            "10": 8,
            "07": 6,
            "11": 4
        },
        "booking_types": {
            "regular": {
                "count": 30,
                "revenue": 1500000,
                "average_value": 50000
            },
            "private_silver": {
                "count": 10,
                "revenue": 750000,
                "average_value": 75000
            },
            "private_gold": {
                "count": 5,
                "revenue": 500000,
                "average_value": 100000
            }
        }
    }
}
```

### 10. Get Session Availability

**GET** `/api/v1/sessions/{id}/availability`

Mengambil ketersediaan session untuk tanggal tertentu.

#### Query Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `date` | date | Yes | Tanggal yang ingin dicek |

#### Response

```json
{
    "success": true,
    "message": "Session availability retrieved successfully",
    "data": {
        "is_available": true,
        "max_capacity": 50,
        "booked_slots": 15,
        "available_slots": 35,
        "utilization_percentage": 30.0
    }
}
```

#### Error Response

```json
{
    "success": true,
    "message": "Session availability retrieved successfully",
    "data": {
        "is_available": false,
        "reason": "Session not available for booking"
    }
}
```

### 11. Get Session Pricing

**GET** `/api/v1/sessions/{id}/pricing`

Mengambil pricing session untuk booking type tertentu.

#### Query Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `booking_type` | string | Yes | regular, private_silver, private_gold |
| `date` | date | No | Tanggal untuk pricing (default: hari ini) |

#### Response

```json
{
    "success": true,
    "message": "Session pricing retrieved successfully",
    "data": {
        "adult_price": 50000,
        "child_price": 25000
    }
}
```

### 12. Create Session Pricing

**POST** `/api/v1/sessions/{id}/pricing`

Membuat pricing baru untuk session.

#### Request Body

```json
{
    "booking_type": "regular",
    "adult_price": 50000,
    "child_price": 25000,
    "peak_hour_adult_price": 75000,
    "peak_hour_child_price": 37500,
    "valid_from": "2025-09-01",
    "valid_until": "2025-12-31"
}
```

#### Validation Rules

| Field | Rules |
|-------|-------|
| `booking_type` | required, in:regular,private_silver,private_gold |
| `adult_price` | required, numeric, min:0 |
| `child_price` | required, numeric, min:0 |
| `peak_hour_adult_price` | nullable, numeric, min:0 |
| `peak_hour_child_price` | nullable, numeric, min:0 |
| `valid_from` | required, date |
| `valid_until` | nullable, date, after:valid_from |

#### Response

```json
{
    "success": true,
    "message": "Session pricing created successfully",
    "data": {
        "id": 1,
        "session_id": 1,
        "booking_type": "regular",
        "adult_price": "50000.00",
        "child_price": "25000.00",
        "peak_hour_adult_price": "75000.00",
        "peak_hour_child_price": "37500.00",
        "is_active": true,
        "valid_from": "2025-09-01",
        "valid_until": "2025-12-31",
        "created_by": 1,
        "updated_by": null,
        "created_at": "2025-09-01T10:00:00.000000Z",
        "updated_at": "2025-09-01T10:00:00.000000Z"
    }
}
```

### 13. Update Session Pricing

**PUT** `/api/v1/sessions/pricing/{pricingId}`

Mengupdate pricing session.

#### Request Body

```json
{
    "adult_price": 60000,
    "child_price": 30000,
    "is_active": true
}
```

#### Response

```json
{
    "success": true,
    "message": "Session pricing updated successfully",
    "data": {
        "id": 1,
        "session_id": 1,
        "booking_type": "regular",
        "adult_price": "60000.00",
        "child_price": "30000.00",
        "peak_hour_adult_price": "75000.00",
        "peak_hour_child_price": "37500.00",
        "is_active": true,
        "valid_from": "2025-09-01",
        "valid_until": "2025-12-31",
        "created_by": 1,
        "updated_by": 1,
        "created_at": "2025-09-01T10:00:00.000000Z",
        "updated_at": "2025-09-01T10:30:00.000000Z"
    }
}
```

### 14. Delete Session Pricing

**DELETE** `/api/v1/sessions/pricing/{pricingId}`

Menghapus pricing session.

#### Response

```json
{
    "success": true,
    "message": "Session pricing deleted successfully",
    "data": null
}
```

### 15. Get Active Sessions

**GET** `/api/v1/sessions/active`

Mengambil daftar session yang aktif.

#### Response

```json
{
    "success": true,
    "message": "Active sessions retrieved successfully",
    "data": [
        {
            "id": 1,
            "name": "Morning Session",
            "start_time": "06:00",
            "end_time": "10:00",
            "max_capacity": 50,
            "current_capacity": 0,
            "is_active": true
        }
    ]
}
```

### 16. Get Available Sessions

**GET** `/api/v1/sessions/available`

Mengambil daftar session yang tersedia untuk booking pada tanggal tertentu.

#### Query Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `date` | date | Yes | Tanggal yang ingin dicek |

#### Response

```json
{
    "success": true,
    "message": "Available sessions retrieved successfully",
    "data": [
        {
            "id": 1,
            "name": "Morning Session",
            "start_time": "06:00",
            "end_time": "10:00",
            "max_capacity": 50,
            "current_capacity": 0,
            "is_active": true,
            "available_capacity": 50,
            "is_available": true
        }
    ]
}
```

## Error Responses

### Validation Error (422)

```json
{
    "success": false,
    "message": "The given data was invalid.",
    "errors": {
        "name": ["Session name is required"],
        "start_time": ["Start time is required"],
        "end_time": ["End time must be after start time"]
    }
}
```

### Not Found Error (404)

```json
{
    "success": false,
    "message": "Session not found",
    "data": null
}
```

### Business Logic Error (400)

```json
{
    "success": false,
    "message": "Cannot delete session with active bookings",
    "data": null
}
```

## Business Rules

1. **Session Creation**: Saat membuat session baru, sistem akan otomatis membuat default pricing untuk semua booking type (regular, private_silver, private_gold).

2. **Session Deletion**: Session tidak dapat dihapus jika memiliki booking yang aktif (status pending atau confirmed).

3. **Capacity Update**: Kapasitas baru tidak boleh kurang dari kapasitas saat ini.

4. **Pricing Validation**: Pricing harus memiliki valid_from dan valid_until yang valid.

5. **Availability Check**: Session hanya dapat di-booking jika:
   - Session aktif
   - Tanggal booking tidak melebihi advance_booking_days
   - Tanggal booking tidak di masa lalu
   - Masih ada slot tersedia

## Rate Limiting

API ini menggunakan rate limiting standar Laravel:
- 60 requests per minute untuk authenticated users
- 10 requests per minute untuk unauthenticated requests

## Testing

Untuk testing API ini, gunakan script berikut:

```bash
# Test session creation
curl -X POST http://localhost/api/v1/sessions \
  -H "Authorization: Bearer {token}" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Test Session",
    "start_time": "08:00",
    "end_time": "12:00",
    "max_capacity": 30
  }'

# Test session listing
curl -X GET http://localhost/api/v1/sessions \
  -H "Authorization: Bearer {token}"

# Test session availability
curl -X GET "http://localhost/api/v1/sessions/1/availability?date=2025-09-15" \
  -H "Authorization: Bearer {token}"
```

## Support

Untuk pertanyaan atau bantuan terkait API ini, silakan hubungi tim development.
