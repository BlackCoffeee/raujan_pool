# Queue System API Documentation

## 📋 Overview

Queue System API memungkinkan user untuk mendaftar dalam antrian membership, admin untuk mengelola antrian, dan sistem untuk memproses antrian secara otomatis.

## 🔐 Authentication

Semua endpoint memerlukan authentication menggunakan Sanctum token.

## 📍 Base URL

```
/api/v1/queue
```

## 🚀 API Endpoints

### 1. Get Queue Entries

**GET** `/api/v1/queue`

Mendapatkan daftar semua antrian dengan filtering dan pagination.

**Query Parameters:**

-   `status` (optional): Filter by status (`waiting`, `offered`, `accepted`, `rejected`, `expired`)
-   `priority` (optional): Filter by priority (1-4)
-   `assigned_to` (optional): Filter by assigned admin
-   `start_date` (optional): Start date for date range filter
-   `end_date` (optional): End date for date range filter
-   `per_page` (optional): Number of items per page (default: 15)

**Response:**

```json
{
    "success": true,
    "message": "Queue entries retrieved successfully",
    "data": {
        "current_page": 1,
        "data": [
            {
                "id": 1,
                "user_id": 1,
                "queue_position": 1,
                "status": "waiting",
                "applied_date": "2025-09-03T07:00:00.000000Z",
                "offered_date": null,
                "accepted_date": null,
                "expiry_date": "2025-09-10T07:00:00.000000Z",
                "notes": null,
                "priority": 2,
                "assigned_to": null,
                "user": {
                    "id": 1,
                    "name": "John Doe",
                    "email": "john@example.com"
                },
                "assigned_to_user": null
            }
        ],
        "total": 1,
        "per_page": 15
    }
}
```

### 2. Join Queue

**POST** `/api/v1/queue/join`

User mendaftar dalam antrian membership.

**Request Body:**

```json
{
    "priority": 2
}
```

**Priority Levels:**

-   `1`: Low
-   `2`: Normal (default)
-   `3`: High
-   `4`: Urgent

**Response:**

```json
{
    "success": true,
    "message": "Joined queue successfully",
    "data": {
        "id": 1,
        "user_id": 1,
        "queue_position": 1,
        "status": "waiting",
        "priority": 2,
        "applied_date": "2025-09-03T07:00:00.000000Z",
        "expiry_date": "2025-09-10T07:00:00.000000Z"
    }
}
```

**Error Cases:**

-   User sudah dalam antrian
-   User sudah menjadi member
-   Invalid priority level

### 3. Get My Queue Status

**GET** `/api/v1/queue/my-status`

User mendapatkan status posisi antrian mereka.

**Response:**

```json
{
    "success": true,
    "message": "Queue status retrieved successfully",
    "data": {
        "position": 1,
        "total_waiting": 5,
        "estimated_wait_time": 2,
        "applied_date": "2025-09-03T07:00:00.000000Z"
    }
}
```

**Error Cases:**

-   User tidak dalam antrian (404)

### 4. Leave Queue

**DELETE** `/api/v1/queue/{id}/leave`

User keluar dari antrian.

**Response:**

```json
{
    "success": true,
    "message": "Left queue successfully",
    "data": {
        "id": 1,
        "status": "rejected"
    }
}
```

**Error Cases:**

-   Unauthorized access
-   Invalid queue status

### 5. Get Queue Statistics

**GET** `/api/v1/queue/stats`

Mendapatkan statistik antrian.

**Query Parameters:**

-   `start_date` (optional): Start date for filtering
-   `end_date` (optional): End date for filtering

**Response:**

```json
{
    "success": true,
    "message": "Queue statistics retrieved successfully",
    "data": {
        "total_applications": 10,
        "waiting_applications": 5,
        "offered_applications": 3,
        "accepted_applications": 2,
        "rejected_applications": 0,
        "expired_applications": 0,
        "average_wait_time": 3.5,
        "conversion_rate": 20.0,
        "queue_by_priority": [
            {
                "priority": 1,
                "count": 2
            },
            {
                "priority": 2,
                "count": 5
            }
        ]
    }
}
```

### 6. Get Queue Analytics

**GET** `/api/v1/queue/analytics`

Mendapatkan analisis detail antrian.

**Query Parameters:**

-   `start_date` (optional): Start date for filtering
-   `end_date` (optional): End date for filtering

**Response:**

```json
{
    "success": true,
    "message": "Queue analytics retrieved successfully",
    "data": {
        "queue_trends": [
            {
                "date": "2025-09-01",
                "new_applications": 2,
                "accepted_applications": 1,
                "rejected_applications": 0
            }
        ],
        "processing_times": {
            "average_processing_time": 3.5,
            "fastest_processing_time": 1,
            "slowest_processing_time": 7
        },
        "priority_analysis": [
            {
                "priority": 2,
                "count": 5,
                "avg_processing_time": 3.2
            }
        ],
        "rejection_reasons": [
            {
                "notes": "Incomplete documents",
                "count": 2
            }
        ]
    }
}
```

### 7. Process Expired Entries

**POST** `/api/v1/queue/process-expired`

Memproses antrian yang sudah expired.

**Response:**

```json
{
    "success": true,
    "message": "Expired queue entries processed successfully",
    "data": {
        "processed_count": 3
    }
}
```

## 🔧 Admin Endpoints

### 1. Offer Membership

**POST** `/api/v1/admin/queue/{id}/offer`

Admin menawarkan membership kepada user dalam antrian.

**Request Body:**

```json
{
    "assigned_to": 2
}
```

**Response:**

```json
{
    "success": true,
    "message": "Membership offered successfully",
    "data": {
        "id": 1,
        "status": "offered",
        "offered_date": "2025-09-03T07:00:00.000000Z",
        "expiry_date": "2025-09-06T07:00:00.000000Z",
        "assigned_to": 2
    }
}
```

### 2. Accept Membership

**POST** `/api/v1/admin/queue/{id}/accept`

Admin menerima membership user.

**Response:**

```json
{
    "success": true,
    "message": "Membership accepted successfully",
    "data": {
        "id": 1,
        "user_id": 1,
        "membership_number": "REG202509030001",
        "membership_type": "regular",
        "status": "active"
    }
}
```

### 3. Reject Membership

**POST** `/api/v1/admin/queue/{id}/reject`

Admin menolak membership user.

**Request Body:**

```json
{
    "reason": "Incomplete documents"
}
```

**Response:**

```json
{
    "success": true,
    "message": "Membership rejected successfully",
    "data": {
        "id": 1,
        "status": "rejected",
        "notes": "Incomplete documents"
    }
}
```

### 4. Assign Queue Entry

**POST** `/api/v1/admin/queue/{id}/assign`

Admin menugaskan antrian kepada staff tertentu.

**Request Body:**

```json
{
    "assigned_to": 2
}
```

**Response:**

```json
{
    "success": true,
    "message": "Queue entry assigned successfully",
    "data": {
        "id": 1,
        "assigned_to": 2
    }
}
```

## 📊 Queue Status Flow

```
User Joins Queue
       ↓
    WAITING
       ↓
   [Admin Review]
       ↓
   OFFERED (3 days expiry)
       ↓
   [User Response]
       ↓
  ACCEPTED → Create Member
       ↓
  REJECTED → End Process
```

## ⏰ Expiry Rules

-   **Application Expiry**: 7 days setelah join queue
-   **Offer Expiry**: 3 days setelah ditawarkan membership
-   **Auto Processing**: Expired entries otomatis diubah status menjadi 'expired'

## 🔒 Authorization

-   **User Endpoints**: Semua user yang terautentikasi
-   **Admin Endpoints**: Hanya user dengan role 'admin'
-   **Queue Management**: User hanya bisa mengakses antrian mereka sendiri

## 📝 Error Handling

Semua error mengembalikan response dengan format:

```json
{
    "success": false,
    "message": "Error description",
    "errors": {
        "field": ["Validation error message"]
    }
}
```

**Common HTTP Status Codes:**

-   `200`: Success
-   `201`: Created
-   `400`: Bad Request (Validation errors)
-   `401`: Unauthorized
-   `403`: Forbidden
-   `404`: Not Found
-   `500`: Internal Server Error

## 🧪 Testing

Untuk testing Queue System, gunakan script:

```bash
# Test semua endpoint
./scripts/test-queue-system.sh

# Test specific endpoint
php artisan test tests/Feature/QueueSystemTest.php
```

## 📚 Related Documentation

-   [Member Management API](../member-management.md)
-   [Quota Management API](../quota-management.md)
-   [Authentication API](../authentication.md)
