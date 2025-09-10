# Member Notifications API Documentation

## Overview

Sistem notifikasi member memungkinkan pengiriman notifikasi kepada member melalui berbagai channel seperti email, SMS, push notification, in-app, dan WhatsApp. Sistem ini mendukung notifikasi langsung, terjadwal, dan bulk notifications.

## Base URL

```
/api/v1/admin/notifications
/api/v1/members/my-notifications
```

## Authentication

Semua endpoint memerlukan authentication menggunakan Sanctum token.

## Admin Endpoints

### 1. Get All Notifications

**GET** `/api/v1/admin/notifications`

Mengambil daftar semua notifikasi dengan filter dan pagination.

**Query Parameters:**
- `type` (string, optional): Filter berdasarkan tipe notifikasi
- `status` (string, optional): Filter berdasarkan status
- `priority` (string, optional): Filter berdasarkan prioritas
- `member_id` (integer, optional): Filter berdasarkan member ID
- `start_date` (date, optional): Filter berdasarkan tanggal mulai
- `end_date` (date, optional): Filter berdasarkan tanggal akhir
- `per_page` (integer, optional): Jumlah item per halaman (default: 15)

**Response:**
```json
{
    "success": true,
    "message": "Notifications retrieved successfully",
    "data": {
        "data": [
            {
                "id": 1,
                "member_id": 1,
                "type": "booking_confirmation",
                "title": "Booking Confirmed",
                "message": "Your booking has been confirmed.",
                "data": {
                    "booking_id": 123
                },
                "delivery_channels": ["email", "in_app"],
                "scheduled_at": null,
                "sent_at": "2024-01-15T10:30:00Z",
                "status": "sent",
                "priority": "normal",
                "read_at": null,
                "clicked_at": null,
                "delivery_attempts": 1,
                "last_delivery_attempt": "2024-01-15T10:30:00Z",
                "error_message": null,
                "created_at": "2024-01-15T10:30:00Z",
                "updated_at": "2024-01-15T10:30:00Z",
                "member": {
                    "id": 1,
                    "user": {
                        "id": 1,
                        "name": "John Doe",
                        "email": "john@example.com"
                    }
                }
            }
        ],
        "current_page": 1,
        "last_page": 1,
        "per_page": 15,
        "total": 1
    }
}
```

### 2. Create Notification

**POST** `/api/v1/admin/notifications`

Membuat notifikasi baru untuk member.

**Request Body:**
```json
{
    "member_id": 1,
    "type": "booking_confirmation",
    "title": "Booking Confirmed",
    "message": "Your booking has been confirmed.",
    "data": {
        "booking_id": 123
    },
    "delivery_channels": ["email", "in_app"],
    "scheduled_at": "2024-01-15T15:00:00Z",
    "priority": "normal"
}
```

**Response:**
```json
{
    "success": true,
    "message": "Notification created successfully",
    "data": {
        "id": 1,
        "member_id": 1,
        "type": "booking_confirmation",
        "title": "Booking Confirmed",
        "message": "Your booking has been confirmed.",
        "status": "pending",
        "priority": "normal",
        "created_at": "2024-01-15T10:30:00Z"
    }
}
```

### 3. Send Bulk Notifications

**POST** `/api/v1/admin/notifications/bulk`

Mengirim notifikasi ke multiple member sekaligus.

**Request Body:**
```json
{
    "member_ids": [1, 2, 3],
    "type": "general",
    "title": "General Announcement",
    "message": "This is a general announcement.",
    "priority": "normal"
}
```

**Response:**
```json
{
    "success": true,
    "message": "Bulk notifications created successfully",
    "data": [
        {
            "id": 1,
            "member_id": 1,
            "type": "general",
            "title": "General Announcement",
            "status": "pending"
        },
        {
            "id": 2,
            "member_id": 2,
            "type": "general",
            "title": "General Announcement",
            "status": "pending"
        }
    ]
}
```

### 4. Send Notification

**POST** `/api/v1/admin/notifications/{id}/send`

Mengirim notifikasi yang sudah dibuat.

**Response:**
```json
{
    "success": true,
    "message": "Notification sent successfully",
    "data": {
        "id": 1,
        "status": "sent",
        "sent_at": "2024-01-15T10:30:00Z",
        "delivery_attempts": 1
    }
}
```

### 5. Mark as Read

**POST** `/api/v1/admin/notifications/{id}/read`

Menandai notifikasi sebagai sudah dibaca.

**Response:**
```json
{
    "success": true,
    "message": "Notification marked as read",
    "data": {
        "id": 1,
        "status": "read",
        "read_at": "2024-01-15T10:35:00Z"
    }
}
```

### 6. Mark as Clicked

**POST** `/api/v1/admin/notifications/{id}/clicked`

Menandai notifikasi sebagai sudah diklik.

**Response:**
```json
{
    "success": true,
    "message": "Notification marked as clicked",
    "data": {
        "id": 1,
        "status": "clicked",
        "clicked_at": "2024-01-15T10:35:00Z"
    }
}
```

### 7. Process Scheduled Notifications

**POST** `/api/v1/admin/notifications/process-scheduled`

Memproses notifikasi yang sudah terjadwal.

**Response:**
```json
{
    "success": true,
    "message": "Scheduled notifications processed successfully",
    "data": {
        "processed_count": 5
    }
}
```

### 8. Retry Failed Notifications

**POST** `/api/v1/admin/notifications/retry-failed`

Mencoba mengirim ulang notifikasi yang gagal.

**Response:**
```json
{
    "success": true,
    "message": "Failed notifications retried successfully",
    "data": {
        "retried_count": 3
    }
}
```

### 9. Get Notification Statistics

**GET** `/api/v1/admin/notifications/stats`

Mengambil statistik notifikasi.

**Query Parameters:**
- `start_date` (date, optional): Tanggal mulai filter
- `end_date` (date, optional): Tanggal akhir filter
- `type` (string, optional): Filter berdasarkan tipe
- `member_id` (integer, optional): Filter berdasarkan member ID

**Response:**
```json
{
    "success": true,
    "message": "Notification statistics retrieved successfully",
    "data": {
        "total_notifications": 100,
        "pending_notifications": 5,
        "scheduled_notifications": 10,
        "sent_notifications": 80,
        "delivered_notifications": 75,
        "read_notifications": 60,
        "failed_notifications": 5,
        "unread_notifications": 20
    }
}
```

### 10. Get Notification Analytics

**GET** `/api/v1/admin/notifications/analytics`

Mengambil analitik notifikasi yang detail.

**Response:**
```json
{
    "success": true,
    "message": "Notification analytics retrieved successfully",
    "data": {
        "delivery_rates": {
            "total": 100,
            "delivered": 75,
            "delivery_rate": 75.0
        },
        "read_rates": {
            "delivered": 75,
            "read": 60,
            "read_rate": 80.0
        },
        "click_rates": {
            "delivered": 75,
            "clicked": 45,
            "click_rate": 60.0
        },
        "notification_types": [
            {
                "type": "booking_confirmation",
                "count": 30,
                "percentage": 30.0
            }
        ],
        "delivery_channels": [
            {
                "channel": "email",
                "count": 80,
                "percentage": 80.0
            }
        ],
        "time_analytics": {
            "average_delivery_time": 120,
            "average_read_time": 300,
            "peak_sending_hours": {
                "09": 15,
                "10": 20
            },
            "peak_reading_hours": {
                "10": 12,
                "11": 18
            }
        }
    }
}
```

### 11. Update Notification Preferences

**PUT** `/api/v1/admin/notifications/{memberId}/preferences`

Mengupdate preferensi notifikasi untuk member.

**Request Body:**
```json
{
    "preferences": {
        "booking_confirmation": ["email", "in_app"],
        "payment_reminder": ["sms", "email"],
        "membership_expiry": ["email", "sms", "push"]
    }
}
```

**Response:**
```json
{
    "success": true,
    "message": "Notification preferences updated successfully",
    "data": {
        "id": 1,
        "notification_preferences": {
            "booking_confirmation": ["email", "in_app"],
            "payment_reminder": ["sms", "email"],
            "membership_expiry": ["email", "sms", "push"]
        }
    }
}
```

### 12. Delete Notification

**DELETE** `/api/v1/admin/notifications/{id}`

Menghapus notifikasi (hanya untuk notifikasi pending atau failed).

**Response:**
```json
{
    "success": true,
    "message": "Notification deleted successfully",
    "data": null
}
```

## Member Endpoints

### 1. Get My Notifications

**GET** `/api/v1/members/my-notifications`

Mengambil notifikasi milik member yang sedang login.

**Query Parameters:**
- `type` (string, optional): Filter berdasarkan tipe
- `status` (string, optional): Filter berdasarkan status
- `unread_only` (boolean, optional): Hanya notifikasi yang belum dibaca
- `per_page` (integer, optional): Jumlah item per halaman

**Response:**
```json
{
    "success": true,
    "message": "My notifications retrieved successfully",
    "data": {
        "data": [
            {
                "id": 1,
                "type": "booking_confirmation",
                "title": "Booking Confirmed",
                "message": "Your booking has been confirmed.",
                "status": "sent",
                "priority": "normal",
                "read_at": null,
                "created_at": "2024-01-15T10:30:00Z"
            }
        ],
        "current_page": 1,
        "last_page": 1,
        "per_page": 15,
        "total": 1
    }
}
```

### 2. Mark My Notification as Read

**POST** `/api/v1/members/my-notifications/{id}/read`

Menandai notifikasi milik member sebagai sudah dibaca.

**Response:**
```json
{
    "success": true,
    "message": "Notification marked as read",
    "data": {
        "id": 1,
        "status": "read",
        "read_at": "2024-01-15T10:35:00Z"
    }
}
```

### 3. Mark My Notification as Clicked

**POST** `/api/v1/members/my-notifications/{id}/clicked`

Menandai notifikasi milik member sebagai sudah diklik.

**Response:**
```json
{
    "success": true,
    "message": "Notification marked as clicked",
    "data": {
        "id": 1,
        "status": "clicked",
        "clicked_at": "2024-01-15T10:35:00Z"
    }
}
```

## Notification Types

Sistem mendukung berbagai tipe notifikasi:

- `booking_confirmation`: Konfirmasi booking
- `booking_reminder`: Pengingat booking
- `booking_cancellation`: Pembatalan booking
- `payment_confirmation`: Konfirmasi pembayaran
- `payment_reminder`: Pengingat pembayaran
- `membership_expiry`: Pemberitahuan masa berlaku membership
- `membership_renewal`: Pemberitahuan perpanjangan membership
- `quota_update`: Update kuota
- `queue_position`: Update posisi antrian
- `general`: Pengumuman umum
- `promotional`: Promosi
- `system`: Notifikasi sistem

## Notification Status

- `pending`: Menunggu untuk dikirim
- `scheduled`: Terjadwal untuk dikirim
- `sent`: Sudah dikirim
- `delivered`: Sudah diterima
- `read`: Sudah dibaca
- `clicked`: Sudah diklik
- `failed`: Gagal dikirim
- `cancelled`: Dibatalkan

## Priority Levels

- `low`: Prioritas rendah
- `normal`: Prioritas normal
- `high`: Prioritas tinggi
- `urgent`: Prioritas mendesak

## Delivery Channels

- `email`: Email
- `sms`: SMS
- `push`: Push notification
- `in_app`: Notifikasi dalam aplikasi
- `whatsapp`: WhatsApp

## Error Responses

### 400 Bad Request
```json
{
    "success": false,
    "message": "Error message",
    "data": null,
    "errors": null
}
```

### 422 Validation Error
```json
{
    "success": false,
    "message": "Validation failed",
    "data": null,
    "errors": {
        "member_id": ["The member id field is required."],
        "type": ["The type field is required."]
    }
}
```

### 404 Not Found
```json
{
    "success": false,
    "message": "Notification not found",
    "data": null,
    "errors": null
}
```

## Usage Examples

### Mengirim Notifikasi Booking Confirmation

```bash
curl -X POST "https://api.raujanpool.com/api/v1/admin/notifications" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "member_id": 1,
    "type": "booking_confirmation",
    "title": "Booking Confirmed",
    "message": "Your booking for tomorrow at 10:00 AM has been confirmed.",
    "data": {
      "booking_id": 123,
      "session_date": "2024-01-16",
      "session_time": "10:00"
    },
    "priority": "normal"
  }'
```

### Mengirim Bulk Notification

```bash
curl -X POST "https://api.raujanpool.com/api/v1/admin/notifications/bulk" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "member_ids": [1, 2, 3, 4, 5],
    "type": "general",
    "title": "Pool Maintenance Notice",
    "message": "The pool will be closed for maintenance on January 20th from 8:00 AM to 2:00 PM.",
    "priority": "high"
  }'
```

### Mengambil Notifikasi Member

```bash
curl -X GET "https://api.raujanpool.com/api/v1/members/my-notifications?unread_only=true" \
  -H "Authorization: Bearer YOUR_TOKEN"
```

## Rate Limiting

API ini memiliki rate limiting:
- Admin endpoints: 100 requests per minute
- Member endpoints: 60 requests per minute

## Webhooks

Sistem notifikasi mendukung webhooks untuk event:
- `notification.sent`: Ketika notifikasi berhasil dikirim
- `notification.delivered`: Ketika notifikasi berhasil diterima
- `notification.read`: Ketika notifikasi dibaca
- `notification.clicked`: Ketika notifikasi diklik
- `notification.failed`: Ketika notifikasi gagal dikirim
