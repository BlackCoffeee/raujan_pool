# Booking Management API

## Overview

Sistem booking management memungkinkan pengguna untuk membuat, mengelola, dan melacak reservasi kolam renang. API ini menyediakan endpoint lengkap untuk CRUD operations dan manajemen status booking.

## Base URL

```
/api/v1/bookings
```

## Authentication

Semua endpoint memerlukan authentication menggunakan Sanctum token.

## Endpoints

### 1. Get All Bookings

**GET** `/api/v1/bookings`

Mengambil daftar semua booking dengan pagination dan filtering.

#### Query Parameters

| Parameter | Type | Description | Example |
|-----------|------|-------------|---------|
| `page` | integer | Halaman untuk pagination | `1` |
| `per_page` | integer | Jumlah item per halaman | `10` |
| `status` | string | Filter berdasarkan status | `pending`, `confirmed`, `cancelled` |
| `date` | string | Filter berdasarkan tanggal | `2025-09-01` |
| `session_id` | integer | Filter berdasarkan session | `1` |

#### Response

```json
{
    "success": true,
    "message": "Bookings retrieved successfully",
    "data": {
        "current_page": 1,
        "data": [
            {
                "id": 1,
                "user_id": 1,
                "session_id": 1,
                "booking_date": "2025-09-01",
                "booking_type": "regular",
                "adult_count": 2,
                "child_count": 1,
                "total_amount": 75000,
                "status": "confirmed",
                "payment_status": "paid",
                "booking_reference": "BK-20250901-001",
                "qr_code": "QR-ABC123",
                "notes": "Family booking",
                "created_at": "2025-09-01T10:00:00.000000Z",
                "updated_at": "2025-09-01T10:00:00.000000Z",
                "user": {
                    "id": 1,
                    "name": "John Doe",
                    "email": "john@example.com"
                },
                "session": {
                    "id": 1,
                    "name": "Morning Session",
                    "start_time": "06:00",
                    "end_time": "10:00"
                }
            }
        ],
        "total": 1,
        "per_page": 10,
        "last_page": 1
    }
}
```

### 2. Create Booking

**POST** `/api/v1/bookings`

Membuat booking baru.

#### Request Body

```json
{
    "session_id": 1,
    "booking_date": "2025-09-01",
    "booking_type": "regular",
    "adult_count": 2,
    "child_count": 1,
    "notes": "Family booking"
}
```

#### Validation Rules

| Field | Rules | Description |
|-------|-------|-------------|
| `session_id` | required, exists:swimming_sessions,id | ID session yang valid |
| `booking_date` | required, date, after_or_equal:today | Tanggal booking (hari ini atau setelahnya) |
| `booking_type` | required, in:regular,private_silver,private_gold | Tipe booking |
| `adult_count` | required, integer, min:0, max:10 | Jumlah dewasa |
| `child_count` | required, integer, min:0, max:10 | Jumlah anak |
| `notes` | nullable, string, max:500 | Catatan tambahan |

#### Response

```json
{
    "success": true,
    "message": "Booking created successfully",
    "data": {
        "id": 1,
        "user_id": 1,
        "session_id": 1,
        "booking_date": "2025-09-01",
        "booking_type": "regular",
        "adult_count": 2,
        "child_count": 1,
        "total_amount": 75000,
        "status": "pending",
        "payment_status": "unpaid",
        "booking_reference": "BK-20250901-001",
        "qr_code": "QR-ABC123",
        "notes": "Family booking",
        "created_at": "2025-09-01T10:00:00.000000Z",
        "updated_at": "2025-09-01T10:00:00.000000Z"
    }
}
```

### 3. Get Booking by ID

**GET** `/api/v1/bookings/{id}`

Mengambil detail booking berdasarkan ID.

#### Response

```json
{
    "success": true,
    "message": "Booking retrieved successfully",
    "data": {
        "id": 1,
        "user_id": 1,
        "session_id": 1,
        "booking_date": "2025-09-01",
        "booking_type": "regular",
        "adult_count": 2,
        "child_count": 1,
        "total_amount": 75000,
        "status": "confirmed",
        "payment_status": "paid",
        "booking_reference": "BK-20250901-001",
        "qr_code": "QR-ABC123",
        "notes": "Family booking",
        "created_at": "2025-09-01T10:00:00.000000Z",
        "updated_at": "2025-09-01T10:00:00.000000Z",
        "user": {
            "id": 1,
            "name": "John Doe",
            "email": "john@example.com"
        },
        "session": {
            "id": 1,
            "name": "Morning Session",
            "start_time": "06:00",
            "end_time": "10:00"
        },
        "payment": {
            "id": 1,
            "payment_method": "cash",
            "amount": 75000,
            "status": "completed"
        }
    }
}
```

### 4. Update Booking

**PUT** `/api/v1/bookings/{id}`

Mengupdate booking yang sudah ada.

#### Request Body

```json
{
    "adult_count": 3,
    "child_count": 2,
    "notes": "Updated booking"
}
```

#### Response

```json
{
    "success": true,
    "message": "Booking updated successfully",
    "data": {
        "id": 1,
        "user_id": 1,
        "session_id": 1,
        "booking_date": "2025-09-01",
        "booking_type": "regular",
        "adult_count": 3,
        "child_count": 2,
        "total_amount": 100000,
        "status": "pending",
        "payment_status": "unpaid",
        "booking_reference": "BK-20250901-001",
        "qr_code": "QR-ABC123",
        "notes": "Updated booking",
        "created_at": "2025-09-01T10:00:00.000000Z",
        "updated_at": "2025-09-01T11:00:00.000000Z"
    }
}
```

### 5. Delete Booking

**DELETE** `/api/v1/bookings/{id}`

Menghapus booking (mengubah status menjadi cancelled).

#### Response

```json
{
    "success": true,
    "message": "Booking cancelled successfully",
    "data": null
}
```

### 6. Confirm Booking

**POST** `/api/v1/bookings/{id}/confirm`

Mengkonfirmasi booking yang sudah dibayar.

#### Response

```json
{
    "success": true,
    "message": "Booking confirmed successfully",
    "data": {
        "id": 1,
        "status": "confirmed",
        "confirmed_at": "2025-09-01T12:00:00.000000Z",
        "confirmed_by": 1
    }
}
```

### 7. Cancel Booking

**POST** `/api/v1/bookings/{id}/cancel`

Membatalkan booking dengan alasan.

#### Request Body

```json
{
    "reason": "Change of plans"
}
```

#### Response

```json
{
    "success": true,
    "message": "Booking cancelled successfully",
    "data": {
        "id": 1,
        "status": "cancelled",
        "cancellation_reason": "Change of plans",
        "cancelled_at": "2025-09-01T12:00:00.000000Z",
        "cancelled_by": 1
    }
}
```

### 8. Check In

**POST** `/api/v1/bookings/{id}/check-in`

Check in untuk booking yang sudah dikonfirmasi.

#### Response

```json
{
    "success": true,
    "message": "Check-in successful",
    "data": {
        "id": 1,
        "status": "completed",
        "check_in_time": "2025-09-01T06:00:00.000000Z",
        "checked_in_by": 1
    }
}
```

### 9. Check Out

**POST** `/api/v1/bookings/{id}/check-out`

Check out untuk booking yang sudah check in.

#### Response

```json
{
    "success": true,
    "message": "Check-out successful",
    "data": {
        "id": 1,
        "check_out_time": "2025-09-01T10:00:00.000000Z",
        "checked_out_by": 1
    }
}
```

### 10. Mark as No Show

**POST** `/api/v1/bookings/{id}/no-show`

Menandai booking sebagai no show.

#### Response

```json
{
    "success": true,
    "message": "Booking marked as no show",
    "data": {
        "id": 1,
        "status": "no_show",
        "marked_no_show_at": "2025-09-01T12:00:00.000000Z",
        "marked_no_show_by": 1
    }
}
```

### 11. Get My Bookings

**GET** `/api/v1/bookings/my`

Mengambil daftar booking milik user yang sedang login.

#### Query Parameters

| Parameter | Type | Description | Example |
|-----------|------|-------------|---------|
| `status` | string | Filter berdasarkan status | `pending`, `confirmed` |
| `date` | string | Filter berdasarkan tanggal | `2025-09-01` |

#### Response

```json
{
    "success": true,
    "message": "User bookings retrieved successfully",
    "data": [
        {
            "id": 1,
            "session_id": 1,
            "booking_date": "2025-09-01",
            "booking_type": "regular",
            "adult_count": 2,
            "child_count": 1,
            "total_amount": 75000,
            "status": "confirmed",
            "payment_status": "paid",
            "booking_reference": "BK-20250901-001",
            "session": {
                "id": 1,
                "name": "Morning Session",
                "start_time": "06:00",
                "end_time": "10:00"
            }
        }
    ]
}
```

### 12. Get Booking by Reference

**GET** `/api/v1/bookings/reference/{reference}`

Mengambil booking berdasarkan booking reference.

#### Response

```json
{
    "success": true,
    "message": "Booking retrieved successfully",
    "data": {
        "id": 1,
        "booking_reference": "BK-20250901-001",
        "status": "confirmed",
        "booking_date": "2025-09-01",
        "session": {
            "name": "Morning Session",
            "start_time": "06:00",
            "end_time": "10:00"
        },
        "user": {
            "name": "John Doe"
        }
    }
}
```

### 13. Get Booking Statistics

**GET** `/api/v1/bookings/stats`

Mengambil statistik booking.

#### Query Parameters

| Parameter | Type | Description | Example |
|-----------|------|-------------|---------|
| `date_from` | string | Tanggal mulai | `2025-09-01` |
| `date_to` | string | Tanggal akhir | `2025-09-30` |

#### Response

```json
{
    "success": true,
    "message": "Booking statistics retrieved successfully",
    "data": {
        "total_bookings": 150,
        "pending_bookings": 25,
        "confirmed_bookings": 100,
        "cancelled_bookings": 15,
        "completed_bookings": 80,
        "no_show_bookings": 10,
        "total_revenue": 11250000,
        "average_booking_value": 75000,
        "booking_by_type": {
            "regular": 120,
            "private_silver": 20,
            "private_gold": 10
        },
        "booking_by_status": {
            "pending": 25,
            "confirmed": 100,
            "cancelled": 15,
            "completed": 80,
            "no_show": 10
        }
    }
}
```

## Error Responses

### Validation Error (422)

```json
{
    "success": false,
    "message": "Validation failed",
    "data": null,
    "errors": {
        "session_id": ["Session is required"],
        "booking_date": ["Booking date is required"],
        "adult_count": ["Adult count must be at least 0"]
    }
}
```

### Not Found Error (404)

```json
{
    "success": false,
    "message": "Booking not found",
    "data": null,
    "errors": null
}
```

### Business Logic Error (400)

```json
{
    "success": false,
    "message": "Booking cannot be cancelled",
    "data": null,
    "errors": null
}
```

### Authorization Error (403)

```json
{
    "success": false,
    "message": "Access denied",
    "data": null,
    "errors": null
}
```

## Business Rules

### Booking Status Flow

1. **pending** → **confirmed** (setelah pembayaran)
2. **confirmed** → **completed** (setelah check-in)
3. **completed** → **checked_out** (setelah check-out)
4. **pending/confirmed** → **cancelled** (pembatalan)
5. **confirmed** → **no_show** (tidak hadir)

### Cancellation Rules

- Booking dapat dibatalkan hingga 1 jam sebelum session dimulai
- Booking yang sudah completed tidak dapat dibatalkan
- Pembatalan akan melepas slot availability

### Payment Rules

- Booking baru memiliki status `unpaid`
- Booking dapat dikonfirmasi setelah status payment menjadi `paid`
- Refund otomatis untuk booking yang dibatalkan

### Availability Rules

- Sistem akan mengecek availability sebelum membuat booking
- Slot akan diambil saat booking dibuat
- Slot akan dilepas saat booking dibatalkan

## Rate Limiting

- 60 requests per minute per user
- 1000 requests per hour per user

## Testing

Untuk testing API, gunakan script berikut:

```bash
# Test semua endpoint booking
./scripts/test-booking-api.sh

# Test endpoint spesifik
php artisan test tests/Feature/BookingManagementTest.php
```
