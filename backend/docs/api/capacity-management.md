# Capacity Management API Documentation

## Overview

Capacity Management API menyediakan endpoints untuk mengelola kapasitas kolam renang, antrian booking, dan monitoring real-time. API ini memungkinkan:

-   Pengecekan ketersediaan kapasitas
-   Manajemen antrian booking
-   Penyesuaian kapasitas dinamis
-   Monitoring dan analytics
-   Notifikasi real-time

## Base URL

```
/api/v1/capacity
```

## Authentication

Semua endpoints memerlukan authentication menggunakan Sanctum token:

```bash
Authorization: Bearer {token}
```

## Endpoints

### 1. Check Capacity Availability

**POST** `/api/v1/capacity/check`

Mengecek ketersediaan kapasitas untuk session dan tanggal tertentu.

#### Request Body

```json
{
    "session_id": 1,
    "date": "2025-09-01",
    "requested_slots": 2
}
```

#### Response

```json
{
    "success": true,
    "message": "Capacity check completed",
    "data": {
        "available": true,
        "available_slots": 8,
        "max_capacity": 10,
        "utilization_percentage": 20.0,
        "queue_length": 0
    }
}
```

### 2. Add to Queue

**POST** `/api/v1/capacity/queue`

Menambahkan request ke antrian kapasitas.

#### Request Body

```json
{
    "session_id": 1,
    "date": "2025-09-01",
    "requested_slots": 2,
    "user_id": 1,
    "guest_user_id": null,
    "booking_type": "regular"
}
```

#### Response

```json
{
    "success": true,
    "message": "Added to capacity queue",
    "data": {
        "id": 1,
        "session_id": 1,
        "date": "2025-09-01",
        "requested_slots": 2,
        "position_in_queue": 1,
        "estimated_wait_time": 5,
        "status": "pending",
        "expires_at": "2025-09-01T16:00:00Z"
    }
}
```

### 3. Get Queue Status

**GET** `/api/v1/capacity/queue/status?session_id=1&date=2025-09-01`

Mendapatkan status antrian untuk session dan tanggal tertentu.

#### Response

```json
{
    "success": true,
    "message": "Queue status retrieved",
    "data": {
        "total_in_queue": 3,
        "total_requested_slots": 7,
        "average_wait_time": 15,
        "queue_entries": [
            {
                "id": 1,
                "position": 1,
                "requested_slots": 2,
                "priority": 1,
                "estimated_wait_time": 5,
                "expires_at": "2025-09-01T16:00:00Z"
            }
        ]
    }
}
```

### 4. Remove from Queue

**DELETE** `/api/v1/capacity/queue/{queueId}`

Menghapus entry dari antrian.

#### Response

```json
{
    "success": true,
    "message": "Removed from queue",
    "data": {
        "id": 1,
        "status": "cancelled",
        "notes": "User cancelled"
    }
}
```

### 5. Adjust Session Capacity

**PUT** `/api/v1/capacity/sessions/{sessionId}/adjust`

Menyesuaikan kapasitas session.

#### Request Body

```json
{
    "new_capacity": 15,
    "reason": "demand_increase"
}
```

#### Response

```json
{
    "success": true,
    "message": "Capacity adjusted successfully",
    "data": {
        "session_id": 1,
        "old_capacity": 10,
        "new_capacity": 15,
        "reason": "demand_increase"
    }
}
```

### 6. Get Capacity Analytics

**GET** `/api/v1/capacity/sessions/{sessionId}/analytics?start_date=2025-08-01&end_date=2025-09-01`

Mendapatkan analytics kapasitas untuk periode tertentu.

#### Response

```json
{
    "success": true,
    "message": "Analytics retrieved",
    "data": {
        "session_id": 1,
        "session_name": "Morning Session",
        "period": {
            "start_date": "2025-08-01",
            "end_date": "2025-09-01"
        },
        "capacity_stats": {
            "max_capacity": 10,
            "average_utilization": 75.5,
            "peak_utilization": 100.0,
            "capacity_shortage_days": 5
        },
        "queue_stats": {
            "total_queue_entries": 25,
            "completed_queue_entries": 20,
            "cancelled_queue_entries": 3,
            "average_wait_time": 12.5,
            "average_queue_position": 2.3
        },
        "recommendations": [
            {
                "type": "increase_capacity",
                "message": "Consider increasing capacity due to high utilization",
                "priority": "high"
            }
        ]
    }
}
```

### 7. Get Capacity Alerts

**GET** `/api/v1/capacity/alerts?session_id=1`

Mendapatkan alert kapasitas.

#### Response

```json
{
    "success": true,
    "message": "Alerts retrieved",
    "data": [
        {
            "type": "high_utilization",
            "session_id": 1,
            "session_name": "Morning Session",
            "utilization_percentage": 95.0,
            "message": "High utilization (95%) for Morning Session"
        }
    ]
}
```

### 8. Process Queue

**POST** `/api/v1/capacity/queue/process`

Memproses antrian untuk session dan tanggal tertentu.

#### Request Body

```json
{
    "session_id": 1,
    "date": "2025-09-01"
}
```

#### Response

```json
{
    "success": true,
    "message": "Queue processed",
    "data": {
        "processed_count": 3,
        "created_bookings": [1, 2, 3]
    }
}
```

### 9. Get My Queue Entries

**GET** `/api/v1/capacity/queue/my`

Mendapatkan antrian milik user yang sedang login.

#### Response

```json
{
    "success": true,
    "message": "Queue entries retrieved",
    "data": [
        {
            "id": 1,
            "session_id": 1,
            "session_name": "Morning Session",
            "date": "2025-09-01",
            "requested_slots": 2,
            "position_in_queue": 1,
            "estimated_wait_time": 5,
            "status": "pending",
            "expires_at": "2025-09-01T16:00:00Z"
        }
    ]
}
```

## Error Responses

### 400 Bad Request

```json
{
    "success": false,
    "message": "Validation failed",
    "errors": {
        "session_id": ["The session id field is required."],
        "date": ["The date field is required."]
    }
}
```

### 404 Not Found

```json
{
    "success": false,
    "message": "Session not found"
}
```

### 422 Unprocessable Entity

```json
{
    "success": false,
    "message": "Not enough available slots"
}
```

## Status Codes

-   `200` - Success
-   `201` - Created
-   `400` - Bad Request
-   `401` - Unauthorized
-   `404` - Not Found
-   `422` - Unprocessable Entity
-   `500` - Internal Server Error

## Rate Limiting

API ini menggunakan rate limiting standar Laravel:

-   60 requests per minute per user
-   1000 requests per minute per IP

## Real-time Updates

Capacity Management menggunakan Laravel Broadcasting untuk real-time updates:

### Channels

-   `capacity-updates` - Global capacity updates
-   `capacity-updates.{session_id}` - Session-specific updates
-   `capacity-updates.{date}` - Date-specific updates

### Events

-   `capacity.updated` - Capacity atau queue status berubah

### Example Event Data

```json
{
    "session_id": 1,
    "date": "2025-09-01",
    "capacity": {
        "available_slots": 8,
        "max_capacity": 10,
        "utilization_percentage": 20.0
    },
    "queue": {
        "total_in_queue": 2,
        "average_wait_time": 10
    },
    "timestamp": "2025-09-01T14:30:00Z"
}
```

## Usage Examples

### JavaScript/TypeScript

```javascript
// Check capacity
const response = await fetch("/api/v1/capacity/check", {
    method: "POST",
    headers: {
        "Content-Type": "application/json",
        Authorization: `Bearer ${token}`,
    },
    body: JSON.stringify({
        session_id: 1,
        date: "2025-09-01",
        requested_slots: 2,
    }),
});

const data = await response.json();
console.log(data.data.available_slots);
```

### PHP

```php
use Illuminate\Support\Facades\Http;

$response = Http::withToken($token)
    ->post('/api/v1/capacity/check', [
        'session_id' => 1,
        'date' => '2025-09-01',
        'requested_slots' => 2
    ]);

$data = $response->json();
echo $data['data']['available_slots'];
```

### cURL

```bash
curl -X POST "https://api.example.com/api/v1/capacity/check" \
  -H "Authorization: Bearer {token}" \
  -H "Content-Type: application/json" \
  -d '{
    "session_id": 1,
    "date": "2025-09-01",
    "requested_slots": 2
  }'
```

## Best Practices

1. **Caching**: Cache capacity data untuk mengurangi database queries
2. **Rate Limiting**: Implementasikan rate limiting di client side
3. **Error Handling**: Selalu handle error responses dengan baik
4. **Real-time Updates**: Gunakan WebSocket untuk real-time updates
5. **Validation**: Validasi input di client side sebelum mengirim request
6. **Retry Logic**: Implementasikan retry logic untuk failed requests
7. **Monitoring**: Monitor API usage dan performance

## Changelog

### v1.0.0 (2025-09-01)

-   Initial release
-   Basic capacity management endpoints
-   Queue management
-   Real-time updates
-   Analytics and alerts
