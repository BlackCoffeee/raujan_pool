# Real-time Availability API Documentation

## 📋 Overview

API untuk sistem real-time availability dengan WebSocket integration, Redis caching, dan live notifications.

## 🔗 Base URL

```
/api/v1/websocket
```

## 🔐 Authentication

Semua endpoint memerlukan authentication menggunakan Bearer token:

```bash
Authorization: Bearer {token}
```

## 📡 Endpoints

### 1. Get Availability

Mendapatkan informasi availability untuk tanggal dan session tertentu.

```http
GET /api/v1/websocket/availability
```

**Parameters:**

-   `date` (required): Tanggal dalam format Y-m-d
-   `session_id` (optional): ID session

**Example Request:**

```bash
curl -X GET "https://api.example.com/api/v1/websocket/availability?date=2024-01-15&session_id=1" \
  -H "Authorization: Bearer {token}"
```

**Response:**

```json
{
    "success": true,
    "message": "Availability retrieved successfully",
    "data": {
        "session_id": 1,
        "date": "2024-01-15",
        "max_slots": 50,
        "booked_slots": 10,
        "available_slots": 40,
        "is_available": true,
        "last_updated": "2024-01-15T10:30:00.000000Z"
    }
}
```

### 2. Get Availability for Date Range

Mendapatkan informasi availability untuk rentang tanggal.

```http
GET /api/v1/websocket/availability/date-range
```

**Parameters:**

-   `start_date` (required): Tanggal mulai dalam format Y-m-d
-   `end_date` (required): Tanggal akhir dalam format Y-m-d
-   `session_id` (optional): ID session

**Example Request:**

```bash
curl -X GET "https://api.example.com/api/v1/websocket/availability/date-range?start_date=2024-01-15&end_date=2024-01-20&session_id=1" \
  -H "Authorization: Bearer {token}"
```

**Response:**

```json
{
    "success": true,
    "message": "Availability for date range retrieved successfully",
    "data": {
        "2024-01-15": {
            "session_id": 1,
            "date": "2024-01-15",
            "max_slots": 50,
            "booked_slots": 10,
            "available_slots": 40,
            "is_available": true,
            "last_updated": "2024-01-15T10:30:00.000000Z"
        },
        "2024-01-16": {
            "session_id": 1,
            "date": "2024-01-16",
            "max_slots": 50,
            "booked_slots": 15,
            "available_slots": 35,
            "is_available": true,
            "last_updated": "2024-01-16T10:30:00.000000Z"
        }
    }
}
```

### 3. Get Availability for Session

Mendapatkan informasi availability untuk session tertentu dalam rentang tanggal.

```http
GET /api/v1/websocket/availability/session
```

**Parameters:**

-   `session_id` (required): ID session
-   `start_date` (optional): Tanggal mulai dalam format Y-m-d (default: hari ini)
-   `end_date` (optional): Tanggal akhir dalam format Y-m-d (default: 30 hari ke depan)

**Example Request:**

```bash
curl -X GET "https://api.example.com/api/v1/websocket/availability/session?session_id=1&start_date=2024-01-15&end_date=2024-01-30" \
  -H "Authorization: Bearer {token}"
```

### 4. Get Availability Statistics

Mendapatkan statistik availability untuk tanggal dan session tertentu.

```http
GET /api/v1/websocket/availability/stats
```

**Parameters:**

-   `date` (required): Tanggal dalam format Y-m-d
-   `session_id` (optional): ID session

**Example Request:**

```bash
curl -X GET "https://api.example.com/api/v1/websocket/availability/stats?date=2024-01-15&session_id=1" \
  -H "Authorization: Bearer {token}"
```

**Response:**

```json
{
    "success": true,
    "message": "Availability statistics retrieved successfully",
    "data": {
        "date": "2024-01-15",
        "session_id": 1,
        "total_slots": 50,
        "booked_slots": 10,
        "available_slots": 40,
        "utilization_percentage": 20.0,
        "is_available": true,
        "last_updated": "2024-01-15T10:30:00.000000Z"
    }
}
```

### 5. Get Availability Trends

Mendapatkan tren availability untuk session tertentu.

```http
GET /api/v1/websocket/availability/trends
```

**Parameters:**

-   `session_id` (required): ID session
-   `days` (optional): Jumlah hari (1-90, default: 30)

**Example Request:**

```bash
curl -X GET "https://api.example.com/api/v1/websocket/availability/trends?session_id=1&days=7" \
  -H "Authorization: Bearer {token}"
```

**Response:**

```json
{
    "success": true,
    "message": "Availability trends retrieved successfully",
    "data": [
        {
            "date": "2024-01-08",
            "booked_slots": 15,
            "available_slots": 35,
            "utilization_percentage": 30.0
        },
        {
            "date": "2024-01-09",
            "booked_slots": 20,
            "available_slots": 30,
            "utilization_percentage": 40.0
        }
    ]
}
```

### 6. Get Peak Hours

Mendapatkan jam-jam puncak untuk session tertentu.

```http
GET /api/v1/websocket/availability/peak-hours
```

**Parameters:**

-   `session_id` (required): ID session
-   `days` (optional): Jumlah hari (1-90, default: 30)

**Example Request:**

```bash
curl -X GET "https://api.example.com/api/v1/websocket/availability/peak-hours?session_id=1&days=30" \
  -H "Authorization: Bearer {token}"
```

**Response:**

```json
{
    "success": true,
    "message": "Peak hours retrieved successfully",
    "data": [
        {
            "hour": 10,
            "booking_count": 25
        },
        {
            "hour": 14,
            "booking_count": 20
        },
        {
            "hour": 16,
            "booking_count": 18
        }
    ]
}
```

### 7. Get Availability Alerts

Mendapatkan alert availability untuk session tertentu.

```http
GET /api/v1/websocket/availability/alerts
```

**Parameters:**

-   `session_id` (optional): ID session

**Example Request:**

```bash
curl -X GET "https://api.example.com/api/v1/websocket/availability/alerts?session_id=1" \
  -H "Authorization: Bearer {token}"
```

**Response:**

```json
{
    "success": true,
    "message": "Availability alerts retrieved successfully",
    "data": [
        {
            "type": "low_availability",
            "session_id": 1,
            "session_name": "Morning Session",
            "date": "2024-01-15",
            "available_slots": 3,
            "message": "Low availability for Morning Session today"
        },
        {
            "type": "high_demand",
            "session_id": 1,
            "session_name": "Morning Session",
            "date": "2024-01-16",
            "booked_slots": 45,
            "message": "High demand for Morning Session tomorrow"
        }
    ]
}
```

### 8. Refresh Availability

Memperbarui cache availability dan broadcast update.

```http
POST /api/v1/websocket/availability/refresh
```

**Parameters:**

-   `date` (required): Tanggal dalam format Y-m-d
-   `session_id` (optional): ID session

**Example Request:**

```bash
curl -X POST "https://api.example.com/api/v1/websocket/availability/refresh" \
  -H "Authorization: Bearer {token}" \
  -H "Content-Type: application/json" \
  -d '{
    "date": "2024-01-15",
    "session_id": 1
  }'
```

**Response:**

```json
{
    "success": true,
    "message": "Availability refreshed successfully",
    "data": null
}
```

### 9. Subscribe to Availability Channels

Subscribe ke channel availability untuk real-time updates.

```http
POST /api/v1/websocket/availability/subscribe
```

**Parameters:**

-   `channels` (required): Array channel yang akan di-subscribe
    -   `availability`: Global availability updates
    -   `availability.date`: Availability untuk tanggal tertentu
    -   `availability.session`: Availability untuk session tertentu

**Example Request:**

```bash
curl -X POST "https://api.example.com/api/v1/websocket/availability/subscribe" \
  -H "Authorization: Bearer {token}" \
  -H "Content-Type: application/json" \
  -d '{
    "channels": ["availability", "availability.date", "availability.session"]
  }'
```

**Response:**

```json
{
    "success": true,
    "message": "Successfully subscribed to availability channels",
    "data": {
        "channels": [
            "availability",
            "availability.2024-01-15",
            "availability.session.1"
        ],
        "message": "Subscribed to availability channels"
    }
}
```

## 🔌 WebSocket Channels

### Available Channels

1. **`availability`** - Global availability updates
2. **`availability.{date}`** - Availability untuk tanggal tertentu
3. **`availability.session.{id}`** - Availability untuk session tertentu
4. **`availability.user.{id}`** - Private channel untuk user tertentu

### WebSocket Events

#### availability.updated

Event yang dikirim ketika availability berubah.

```json
{
    "type": "availability.updated",
    "date": "2024-01-15",
    "session_id": 1,
    "availability": {
        "id": 123,
        "date": "2024-01-15",
        "session_id": 1,
        "available_slots": 40,
        "is_available": true
    },
    "booked_slots": 10,
    "available_slots": 40,
    "timestamp": "2024-01-15T10:30:00.000000Z"
}
```

## ⚠️ Error Responses

### Validation Error (422)

```json
{
    "success": false,
    "message": "Validation failed",
    "errors": {
        "date": ["The date field is required."],
        "session_id": ["The selected session id is invalid."]
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

### Server Error (500)

```json
{
    "success": false,
    "message": "Internal server error",
    "data": null
}
```

## 📊 Rate Limiting

-   **Standard endpoints**: 60 requests per minute
-   **Refresh endpoint**: 10 requests per minute
-   **Subscribe endpoint**: 5 requests per minute

## 🔄 Caching

-   Availability data di-cache selama 1 jam
-   Cache otomatis di-clear ketika ada update
-   Manual refresh tersedia melalui endpoint refresh

## 📝 Notes

1. Semua tanggal menggunakan format `Y-m-d`
2. Timezone menggunakan UTC
3. Cache TTL: 3600 detik (1 jam)
4. WebSocket menggunakan Laravel Reverb
5. Broadcasting menggunakan Redis sebagai driver
