# Order Tracking API Documentation

## Overview

Order Tracking API memungkinkan pengguna untuk melacak status pesanan, melihat timeline pesanan, memberikan feedback, dan mengakses analytics pesanan. API ini mendukung operasi untuk member dan admin.

## Authentication

Semua endpoint memerlukan authentication menggunakan Bearer token:

```
Authorization: Bearer {token}
```

## Base URL

```
/api/v1/
```

## Member Endpoints

### 1. Get Order Status

Mendapatkan status detail pesanan.

**Endpoint:** `GET /api/v1/orders/{id}/status`

**Headers:**

```
Authorization: Bearer {token}
Content-Type: application/json
```

**Parameters:**

-   `id` (path, required): ID pesanan

**Response:**

```json
{
    "success": true,
    "message": "Order status retrieved successfully",
    "data": {
        "order_id": 1,
        "order_number": "ORD-20250105-0001",
        "current_status": "preparing",
        "current_status_display": "Preparing",
        "payment_status": "confirmed",
        "payment_status_display": "Confirmed",
        "estimated_ready_time": "2025-01-05T15:30:00Z",
        "actual_ready_time": null,
        "delivery_location": "Table 5",
        "special_instructions": "Extra spicy",
        "customer_name": "John Doe",
        "customer_phone": "+6281234567890",
        "total_amount": 75000,
        "final_amount": 75000,
        "total_items": 3,
        "items": [
            {
                "id": 1,
                "menu_item_name": "Nasi Goreng Spesial",
                "quantity": 2,
                "unit_price": 25000,
                "total_price": 50000,
                "status": "preparing",
                "special_instructions": "Extra spicy"
            }
        ],
        "latest_tracking": {
            "status": "preparing",
            "notes": "Order is being prepared",
            "updated_by": "Admin User",
            "updated_at": "2025-01-05T14:15:00Z"
        },
        "can_be_cancelled": true,
        "can_provide_feedback": false
    }
}
```

### 2. Get Order Timeline

Mendapatkan timeline lengkap status pesanan.

**Endpoint:** `GET /api/v1/orders/{id}/timeline`

**Headers:**

```
Authorization: Bearer {token}
Content-Type: application/json
```

**Parameters:**

-   `id` (path, required): ID pesanan

**Response:**

```json
{
    "success": true,
    "message": "Order timeline retrieved successfully",
    "data": [
        {
            "id": 1,
            "status": "pending",
            "status_display": "Pending",
            "notes": "Order created",
            "updated_by": "System",
            "estimated_time": null,
            "actual_time": "2025-01-05T14:00:00Z",
            "duration": null,
            "created_at": "2025-01-05T14:00:00Z"
        },
        {
            "id": 2,
            "status": "confirmed",
            "status_display": "Confirmed",
            "notes": "Order confirmed by admin",
            "updated_by": "Admin User",
            "estimated_time": "2025-01-05T15:00:00Z",
            "actual_time": "2025-01-05T14:05:00Z",
            "duration": 5,
            "created_at": "2025-01-05T14:05:00Z"
        }
    ]
}
```

### 3. Submit Order Feedback

Memberikan feedback untuk pesanan yang sudah selesai.

**Endpoint:** `POST /api/v1/orders/{id}/feedback`

**Headers:**

```
Authorization: Bearer {token}
Content-Type: application/json
```

**Parameters:**

-   `id` (path, required): ID pesanan

**Request Body:**

```json
{
    "rating": 5,
    "comment": "Excellent service!",
    "food_quality_rating": 5,
    "service_rating": 4,
    "delivery_rating": 5,
    "is_anonymous": false
}
```

**Validation Rules:**

-   `rating`: required, integer, min:1, max:5
-   `comment`: optional, string, max:1000
-   `food_quality_rating`: optional, integer, min:1, max:5
-   `service_rating`: optional, integer, min:1, max:5
-   `delivery_rating`: optional, integer, min:1, max:5
-   `is_anonymous`: optional, boolean

**Response:**

```json
{
    "success": true,
    "message": "Feedback submitted successfully",
    "data": {
        "id": 1,
        "order_id": 1,
        "user_id": 1,
        "rating": 5,
        "comment": "Excellent service!",
        "food_quality_rating": 5,
        "service_rating": 4,
        "delivery_rating": 5,
        "is_anonymous": false,
        "overall_rating": 4.75,
        "is_positive": true,
        "created_at": "2025-01-05T16:00:00Z"
    }
}
```

### 4. Get Active Orders

Mendapatkan daftar pesanan aktif pengguna.

**Endpoint:** `GET /api/v1/orders/active`

**Headers:**

```
Authorization: Bearer {token}
Content-Type: application/json
```

**Query Parameters:**

-   `page`: optional, integer, default: 1
-   `per_page`: optional, integer, default: 15, max: 100

**Response:**

```json
{
    "success": true,
    "message": "Active orders retrieved successfully",
    "data": [
        {
            "order_id": 1,
            "order_number": "ORD-20250105-0001",
            "status": "preparing",
            "status_display": "Preparing",
            "customer_name": "John Doe",
            "total_items": 3,
            "estimated_ready_time": "2025-01-05T15:30:00Z",
            "delivery_location": "Table 5",
            "latest_update": {
                "notes": "Order is being prepared",
                "updated_by": "Admin User",
                "updated_at": "2025-01-05T14:15:00Z"
            },
            "time_elapsed": 15
        }
    ]
}
```

### 5. Get Order History

Mendapatkan riwayat pesanan pengguna.

**Endpoint:** `GET /api/v1/orders/history`

**Headers:**

```
Authorization: Bearer {token}
Content-Type: application/json
```

**Query Parameters:**

-   `page`: optional, integer, default: 1
-   `per_page`: optional, integer, default: 15, max: 100
-   `status`: optional, string, enum: pending, confirmed, preparing, ready, delivered, cancelled
-   `start_date`: optional, date (YYYY-MM-DD)
-   `end_date`: optional, date (YYYY-MM-DD)

**Response:**

```json
{
    "success": true,
    "message": "Order history retrieved successfully",
    "data": {
        "data": [
            {
                "id": 1,
                "order_number": "ORD-20250105-0001",
                "status": "delivered",
                "status_display": "Delivered",
                "total_amount": 75000,
                "final_amount": 75000,
                "payment_status": "confirmed",
                "created_at": "2025-01-05T14:00:00Z",
                "feedback": {
                    "rating": 5,
                    "comment": "Excellent service!"
                }
            }
        ],
        "current_page": 1,
        "per_page": 15,
        "total": 25,
        "last_page": 2,
        "from": 1,
        "to": 15
    }
}
```

## Admin Endpoints

### 1. Get All Active Orders (Admin)

Mendapatkan semua pesanan aktif untuk admin.

**Endpoint:** `GET /api/v1/admin/orders/active`

**Headers:**

```
Authorization: Bearer {admin_token}
Content-Type: application/json
```

**Query Parameters:**

-   `page`: optional, integer, default: 1
-   `per_page`: optional, integer, default: 15, max: 100
-   `status`: optional, string, enum: pending, confirmed, preparing, ready

**Response:**

```json
{
    "success": true,
    "message": "Active orders retrieved successfully",
    "data": [
        {
            "order_id": 1,
            "order_number": "ORD-20250105-0001",
            "status": "preparing",
            "status_display": "Preparing",
            "customer_name": "John Doe",
            "customer_phone": "+6281234567890",
            "total_items": 3,
            "total_amount": 75000,
            "delivery_location": "Table 5",
            "time_elapsed": 15,
            "latest_update": {
                "notes": "Order is being prepared",
                "updated_by": "Admin User",
                "updated_at": "2025-01-05T14:15:00Z"
            }
        }
    ]
}
```

### 2. Update Order Tracking (Admin)

Memperbarui status tracking pesanan.

**Endpoint:** `POST /api/v1/admin/orders/{id}/tracking`

**Headers:**

```
Authorization: Bearer {admin_token}
Content-Type: application/json
```

**Parameters:**

-   `id` (path, required): ID pesanan

**Request Body:**

```json
{
    "status": "preparing",
    "notes": "Order is being prepared",
    "estimated_time": "2025-01-05T15:30:00Z"
}
```

**Validation Rules:**

-   `status`: required, string, enum: pending, confirmed, preparing, ready, delivered, cancelled
-   `notes`: optional, string, max:1000
-   `estimated_time`: optional, datetime

**Response:**

```json
{
    "success": true,
    "message": "Order tracking updated successfully",
    "data": {
        "id": 1,
        "order_id": 1,
        "status": "preparing",
        "notes": "Order is being prepared",
        "updated_by": 1,
        "estimated_time": "2025-01-05T15:30:00Z",
        "actual_time": "2025-01-05T14:15:00Z",
        "created_at": "2025-01-05T14:15:00Z"
    }
}
```

### 3. Get Tracking Statistics (Admin)

Mendapatkan statistik tracking pesanan.

**Endpoint:** `GET /api/v1/admin/orders/tracking-stats`

**Headers:**

```
Authorization: Bearer {admin_token}
Content-Type: application/json
```

**Query Parameters:**

-   `start_date`: optional, date (YYYY-MM-DD)
-   `end_date`: optional, date (YYYY-MM-DD)

**Response:**

```json
{
    "success": true,
    "message": "Tracking statistics retrieved successfully",
    "data": {
        "total_tracking_records": 150,
        "status_distribution": [
            {
                "status": "delivered",
                "count": 120,
                "percentage": 80.0
            },
            {
                "status": "cancelled",
                "count": 15,
                "percentage": 10.0
            },
            {
                "status": "preparing",
                "count": 10,
                "percentage": 6.67
            }
        ],
        "average_processing_time": 25,
        "completion_rate": 80.0,
        "cancellation_rate": 10.0
    }
}
```

### 4. Get Tracking Analytics (Admin)

Mendapatkan analytics detail tracking pesanan.

**Endpoint:** `GET /api/v1/admin/orders/tracking-analytics`

**Headers:**

```
Authorization: Bearer {admin_token}
Content-Type: application/json
```

**Query Parameters:**

-   `start_date`: optional, date (YYYY-MM-DD)
-   `end_date`: optional, date (YYYY-MM-DD)

**Response:**

```json
{
    "success": true,
    "message": "Tracking analytics retrieved successfully",
    "data": {
        "processing_times": {
            "average_time": 25,
            "min_time": 10,
            "max_time": 60
        },
        "status_transitions": {
            "pending_to_confirmed": 45,
            "confirmed_to_preparing": 40,
            "preparing_to_ready": 35,
            "ready_to_delivered": 30
        },
        "peak_processing_hours": [
            {
                "hour": 12,
                "count": 25
            },
            {
                "hour": 13,
                "count": 30
            }
        ],
        "staff_performance": [
            {
                "user_id": 1,
                "user_name": "Admin User",
                "update_count": 50
            }
        ],
        "feedback_analytics": {
            "total_feedbacks": 100,
            "average_rating": 4.2,
            "positive_feedbacks": 80,
            "negative_feedbacks": 5,
            "rating_distribution": {
                "5": 60,
                "4": 20,
                "3": 15,
                "2": 3,
                "1": 2
            }
        }
    }
}
```

## Error Responses

### 400 Bad Request

```json
{
    "success": false,
    "message": "Validation failed",
    "errors": {
        "rating": ["The rating field is required."],
        "comment": ["The comment may not be greater than 1000 characters."]
    }
}
```

### 401 Unauthorized

```json
{
    "success": false,
    "message": "Unauthenticated",
    "data": null
}
```

### 403 Forbidden

```json
{
    "success": false,
    "message": "Access denied. Admin role required.",
    "data": null
}
```

### 404 Not Found

```json
{
    "success": false,
    "message": "Order not found",
    "data": null
}
```

### 422 Unprocessable Entity

```json
{
    "success": false,
    "message": "Feedback can only be submitted for delivered orders",
    "data": null
}
```

### 500 Internal Server Error

```json
{
    "success": false,
    "message": "Internal server error",
    "data": null
}
```

## Status Codes

| Status      | Description                  |
| ----------- | ---------------------------- |
| `pending`   | Pesanan baru dibuat          |
| `confirmed` | Pesanan dikonfirmasi admin   |
| `preparing` | Pesanan sedang disiapkan     |
| `ready`     | Pesanan siap diambil/diantar |
| `delivered` | Pesanan sudah diantarkan     |
| `cancelled` | Pesanan dibatalkan           |

## Rate Limiting

API ini menggunakan rate limiting:

-   **Member endpoints**: 60 requests per minute
-   **Admin endpoints**: 120 requests per minute

## Examples

### cURL Examples

#### Get Order Status

```bash
curl -X GET "https://api.example.com/api/v1/orders/1/status" \
  -H "Authorization: Bearer {token}" \
  -H "Content-Type: application/json"
```

#### Submit Feedback

```bash
curl -X POST "https://api.example.com/api/v1/orders/1/feedback" \
  -H "Authorization: Bearer {token}" \
  -H "Content-Type: application/json" \
  -d '{
    "rating": 5,
    "comment": "Excellent service!",
    "food_quality_rating": 5,
    "service_rating": 4,
    "delivery_rating": 5
  }'
```

#### Update Order Tracking (Admin)

```bash
curl -X POST "https://api.example.com/api/v1/admin/orders/1/tracking" \
  -H "Authorization: Bearer {admin_token}" \
  -H "Content-Type: application/json" \
  -d '{
    "status": "preparing",
    "notes": "Order is being prepared",
    "estimated_time": "2025-01-05T15:30:00Z"
  }'
```

### JavaScript Examples

#### Get Order Timeline

```javascript
const response = await fetch("/api/v1/orders/1/timeline", {
    method: "GET",
    headers: {
        Authorization: `Bearer ${token}`,
        "Content-Type": "application/json",
    },
});

const data = await response.json();
console.log(data.data);
```

#### Get Active Orders

```javascript
const response = await fetch("/api/v1/orders/active?page=1&per_page=10", {
    method: "GET",
    headers: {
        Authorization: `Bearer ${token}`,
        "Content-Type": "application/json",
    },
});

const data = await response.json();
console.log(data.data);
```

## Notes

1. **Feedback**: Hanya bisa diberikan untuk pesanan dengan status `delivered`
2. **Timeline**: Urutan berdasarkan `created_at` ascending
3. **Active Orders**: Hanya menampilkan pesanan dengan status `pending`, `confirmed`, `preparing`, `ready`
4. **Admin Access**: Semua admin endpoints memerlukan role `admin`
5. **Pagination**: Default 15 items per page, maksimal 100 items per page
6. **Date Format**: Menggunakan ISO 8601 format (YYYY-MM-DDTHH:mm:ssZ)
7. **Timezone**: Semua waktu menggunakan UTC timezone
