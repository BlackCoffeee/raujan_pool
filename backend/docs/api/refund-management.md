# Refund Management API

## Overview

Refund Management system memungkinkan pengelolaan refund untuk pembayaran yang sudah diverifikasi. Sistem ini mendukung workflow approval, berbagai metode refund, dan tracking status refund.

## Features

-   ✅ **Refund Request**: User dapat membuat permintaan refund
-   ✅ **Refund Calculation**: Perhitungan otomatis berdasarkan waktu pembatalan
-   ✅ **Refund History**: User dapat melihat history refund mereka
-   ✅ **Refund Tracking**: Real-time status tracking
-   ⚠️ **Admin Approval**: Admin dapat approve/reject refund (Role system issue)
-   ⚠️ **Admin Analytics**: Dashboard analytics untuk admin (Role system issue)

## Authentication

Semua endpoint memerlukan authentication menggunakan Sanctum token:

```
Authorization: Bearer {your-token}
```

## User Endpoints

### 1. Create Refund Request

**POST** `/api/v1/bookings/refunds`

Membuat permintaan refund untuk payment yang sudah diverifikasi.

**Request Body:**

```json
{
    "payment_id": 1,
    "reason": "Change of plans",
    "refund_method": "bank_transfer",
    "notes": "Need to cancel due to emergency"
}
```

**Response:**

```json
{
    "success": true,
    "message": "Refund request created successfully",
    "data": {
        "id": 1,
        "payment_id": 1,
        "booking_id": 1,
        "amount": "100000.00",
        "reason": "Change of plans",
        "status": "pending",
        "refund_method": "bank_transfer",
        "refund_reference": "REF20250903001",
        "requested_by": 1,
        "created_at": "2025-09-03T01:00:00.000000Z"
    }
}
```

**Validation Rules:**

-   `payment_id`: required, exists in payments table
-   `reason`: required, string, max 500 characters
-   `refund_method`: optional, in:bank_transfer,cash,credit
-   `notes`: optional, string, max 500 characters

**Business Rules:**

-   Payment harus memiliki status 'verified'
-   Booking tidak boleh sudah completed
-   Tidak boleh ada refund request yang sudah pending/approved untuk payment yang sama
-   Request harus dibuat dalam 24 jam setelah booking dibuat

### 2. Get Refund History

**GET** `/api/v1/bookings/refunds`

Mengambil history refund untuk user yang sedang login.

**Query Parameters:**

```
?status=pending&refund_method=bank_transfer&per_page=10&page=1
```

**Response:**

```json
{
    "success": true,
    "message": "Refunds retrieved successfully",
    "data": {
        "data": [
            {
                "id": 1,
                "payment_id": 1,
                "booking_id": 1,
                "amount": "100000.00",
                "reason": "Change of plans",
                "status": "pending",
                "refund_method": "bank_transfer",
                "refund_reference": "REF20250903001",
                "created_at": "2025-09-03T01:00:00.000000Z",
                "payment": {
                    "id": 1,
                    "reference": "PAY20250903001",
                    "amount": "100000.00"
                },
                "booking": {
                    "id": 1,
                    "booking_reference": "BOOK20250903001",
                    "booking_date": "2025-09-04"
                }
            }
        ],
        "current_page": 1,
        "per_page": 10,
        "total": 1
    }
}
```

### 3. Get Refund Detail

**GET** `/api/v1/bookings/refunds/{id}`

Mengambil detail refund berdasarkan ID.

**Response:**

```json
{
    "success": true,
    "message": "Refund retrieved successfully",
    "data": {
        "id": 1,
        "payment_id": 1,
        "booking_id": 1,
        "amount": "100000.00",
        "reason": "Change of plans",
        "status": "pending",
        "refund_method": "bank_transfer",
        "refund_reference": "REF20250903001",
        "notes": "Need to cancel due to emergency",
        "requested_by": 1,
        "created_at": "2025-09-03T01:00:00.000000Z",
        "updated_at": "2025-09-03T01:00:00.000000Z",
        "payment": {
            "id": 1,
            "reference": "PAY20250903001",
            "amount": "100000.00",
            "status": "refunded"
        },
        "booking": {
            "id": 1,
            "booking_reference": "BOOK20250903001",
            "booking_date": "2025-09-04",
            "session": {
                "id": 1,
                "name": "Morning Session",
                "start_time": "08:00:00",
                "end_time": "10:00:00"
            }
        },
        "requested_by_user": {
            "id": 1,
            "name": "John Doe",
            "email": "john@example.com"
        }
    }
}
```

### 4. Update Refund Request

**PUT** `/api/v1/bookings/refunds/{id}`

Mengupdate refund request yang masih pending.

**Request Body:**

```json
{
    "payment_id": 1,
    "reason": "Updated reason for refund",
    "notes": "Additional notes"
}
```

**Response:**

```json
{
    "success": true,
    "message": "Refund updated successfully",
    "data": {
        "id": 1,
        "reason": "Updated reason for refund",
        "notes": "Additional notes",
        "updated_at": "2025-09-03T01:30:00.000000Z"
    }
}
```

**Business Rules:**

-   Hanya refund dengan status 'pending' yang bisa diupdate
-   User hanya bisa update refund milik mereka sendiri

### 5. Cancel Refund Request

**DELETE** `/api/v1/bookings/refunds/{id}`

Membatalkan refund request yang masih pending.

**Response:**

```json
{
    "success": true,
    "message": "Refund cancelled successfully"
}
```

**Business Rules:**

-   Hanya refund dengan status 'pending' yang bisa dibatalkan
-   User hanya bisa cancel refund milik mereka sendiri
-   Payment dan booking status akan dikembalikan ke status sebelumnya

## Admin Endpoints (⚠️ Role System Issue)

> **Note**: Admin endpoints saat ini mengalami masalah dengan role system. Semua request mendapat response 403 Forbidden.

### 1. Get All Refunds

**GET** `/api/v1/admin/refunds`

Mengambil semua refund untuk admin dashboard.

### 2. Approve Refund

**POST** `/api/v1/admin/refunds/{id}/approve`

Menyetujui refund request.

### 3. Reject Refund

**POST** `/api/v1/admin/refunds/{id}/reject`

Menolak refund request.

### 4. Process Refund

**POST** `/api/v1/admin/refunds/{id}/process`

Memproses refund yang sudah diapprove.

### 5. Get Refund Statistics

**GET** `/api/v1/admin/refunds/stats`

Mengambil statistik refund untuk dashboard admin.

### 6. Bulk Process Refunds

**POST** `/api/v1/admin/refunds/bulk-process`

Memproses multiple refund sekaligus.

## Refund Calculation Logic

Sistem menggunakan logic berikut untuk menghitung jumlah refund:

```php
// Berdasarkan waktu pembatalan
$hoursUntilBooking = now()->diffInHours($bookingDate, false);

if ($hoursUntilBooking > 24) {
    return 100; // Full refund (100%)
} elseif ($hoursUntilBooking > 12) {
    return 75;  // 75% refund
} elseif ($hoursUntilBooking > 6) {
    return 50;  // 50% refund
} else {
    return 0;   // No refund
}
```

## Refund Status Flow

```
pending → approved → processed
        ↘ rejected
```

**Status Descriptions:**

-   `pending`: Refund request baru dibuat, menunggu review admin
-   `approved`: Admin sudah menyetujui refund
-   `rejected`: Admin menolak refund request
-   `processed`: Refund sudah diproses dan dana dikembalikan

## Error Responses

### 400 Bad Request

```json
{
    "success": false,
    "message": "Only verified payments can be refunded",
    "data": null,
    "errors": null
}
```

### 403 Forbidden

```json
{
    "success": false,
    "message": "Unauthorized access to refund",
    "data": null,
    "errors": null
}
```

### 404 Not Found

```json
{
    "success": false,
    "message": "Refund not found",
    "data": null,
    "errors": null
}
```

### 422 Validation Error

```json
{
    "success": false,
    "message": "Payment is required",
    "data": null,
    "errors": {
        "payment_id": ["Payment is required"]
    }
}
```

## Testing

Sistem refund telah ditest dengan 18 test cases:

**✅ Passing Tests (10/18):**

-   User can create refund request
-   User cannot create refund for unverified payment
-   User cannot create refund for completed booking
-   User cannot create duplicate refund request
-   User can view their refund history
-   User can filter refunds by status
-   User can update pending refund
-   User can cancel pending refund
-   Refund validation works correctly
-   Refund reference is auto generated

**❌ Failing Tests (8/18):**

-   Admin endpoints (Role system issue)
-   Refund calculation edge cases

## Known Issues

1. **Role System Issue**: Admin endpoints mendapat 403 Forbidden karena masalah dengan role system
2. **Refund Calculation**: Beberapa edge cases dalam perhitungan refund perlu diperbaiki
3. **Duplicate Detection**: Logic untuk mendeteksi duplicate refund perlu disempurnakan

## Development Notes

-   Refund system terintegrasi dengan Payment dan Booking system
-   Menggunakan database transactions untuk data consistency
-   Audit logging untuk semua refund operations
-   Real-time notifications untuk status updates
