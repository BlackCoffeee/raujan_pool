# Order Processing API Documentation

## Overview

Order Processing API memungkinkan pengguna untuk membuat, mengelola, dan melacak pesanan makanan dan minuman di sistem pool management. API ini mendukung baik member yang terdaftar maupun guest user.

## Authentication

Semua endpoint memerlukan authentication menggunakan Sanctum token, kecuali untuk guest user yang dapat membuat pesanan tanpa login.

## Base URL

```
/api/v1/members/orders
/api/v1/admin/orders
```

## Order Status Flow

```
pending → confirmed → preparing → ready → delivered
    ↓         ↓           ↓         ↓
cancelled  cancelled  cancelled  (final)
```

## Member Endpoints

### 1. Create Order

**POST** `/api/v1/members/orders`

Membuat pesanan baru.

#### Request Body

```json
{
    "user_id": 1, // Optional, jika tidak ada akan menjadi guest order
    "guest_name": "John Doe", // Required jika user_id tidak ada
    "guest_phone": "081234567890", // Required jika user_id tidak ada
    "items": [
        {
            "menu_item_id": 1,
            "quantity": 2,
            "special_instructions": "Extra spicy"
        }
    ],
    "delivery_location": "Pool Area",
    "special_instructions": "Please deliver to table 5",
    "payment_method": "manual_transfer", // manual_transfer, cash, online
    "discount_amount": 5000
}
```

#### Response

```json
{
    "success": true,
    "message": "Order created successfully",
    "data": {
        "id": 1,
        "order_number": "ORD202509040001",
        "user_id": 1,
        "guest_name": null,
        "guest_phone": null,
        "total_amount": "50000.00",
        "tax_amount": "5000.00",
        "discount_amount": "5000.00",
        "final_amount": "50000.00",
        "status": "pending",
        "payment_status": "unpaid",
        "payment_method": "manual_transfer",
        "estimated_ready_time": "2025-09-04T15:30:00.000000Z",
        "delivery_location": "Pool Area",
        "special_instructions": "Please deliver to table 5",
        "created_at": "2025-09-04T15:00:00.000000Z",
        "updated_at": "2025-09-04T15:00:00.000000Z",
        "order_items": [
            {
                "id": 1,
                "menu_item_id": 1,
                "quantity": 2,
                "unit_price": "25000.00",
                "total_price": "50000.00",
                "special_instructions": "Extra spicy",
                "status": "pending",
                "menu_item": {
                    "id": 1,
                    "name": "Nasi Goreng Spesial",
                    "price": "25000.00",
                    "preparation_time": 15
                }
            }
        ]
    }
}
```

### 2. Get Orders

**GET** `/api/v1/members/orders`

Mendapatkan daftar pesanan pengguna.

#### Query Parameters

-   `status` - Filter berdasarkan status (pending, confirmed, preparing, ready, delivered, cancelled)
-   `payment_status` - Filter berdasarkan status pembayaran (unpaid, paid, refunded)
-   `start_date` - Tanggal mulai (YYYY-MM-DD)
-   `end_date` - Tanggal akhir (YYYY-MM-DD)
-   `per_page` - Jumlah data per halaman (default: 15)

#### Response

```json
{
  "success": true,
  "message": "Orders retrieved successfully",
  "data": {
    "current_page": 1,
    "data": [
      {
        "id": 1,
        "order_number": "ORD202509040001",
        "status": "pending",
        "payment_status": "unpaid",
        "final_amount": "50000.00",
        "created_at": "2025-09-04T15:00:00.000000Z"
      }
    ],
    "first_page_url": "http://localhost/api/v1/members/orders?page=1",
    "from": 1,
    "last_page": 1,
    "last_page_url": "http://localhost/api/v1/members/orders?page=1",
    "links": [...],
    "next_page_url": null,
    "path": "http://localhost/api/v1/members/orders",
    "per_page": 15,
    "prev_page_url": null,
    "to": 1,
    "total": 1
  }
}
```

### 3. Get Order Details

**GET** `/api/v1/members/orders/{id}`

Mendapatkan detail pesanan tertentu.

#### Response

```json
{
    "success": true,
    "message": "Order details retrieved successfully",
    "data": {
        "id": 1,
        "order_number": "ORD202509040001",
        "user_id": 1,
        "total_amount": "50000.00",
        "tax_amount": "5000.00",
        "discount_amount": "5000.00",
        "final_amount": "50000.00",
        "status": "pending",
        "payment_status": "unpaid",
        "payment_method": "manual_transfer",
        "estimated_ready_time": "2025-09-04T15:30:00.000000Z",
        "actual_ready_time": null,
        "delivery_location": "Pool Area",
        "special_instructions": "Please deliver to table 5",
        "created_at": "2025-09-04T15:00:00.000000Z",
        "updated_at": "2025-09-04T15:00:00.000000Z",
        "order_items": [
            {
                "id": 1,
                "menu_item_id": 1,
                "quantity": 2,
                "unit_price": "25000.00",
                "total_price": "50000.00",
                "special_instructions": "Extra spicy",
                "status": "pending",
                "menu_item": {
                    "id": 1,
                    "name": "Nasi Goreng Spesial",
                    "price": "25000.00",
                    "preparation_time": 15,
                    "category": {
                        "id": 1,
                        "name": "Main Course"
                    }
                }
            }
        ],
        "order_tracking": [
            {
                "id": 1,
                "status": "pending",
                "notes": "Order created",
                "updated_by": 1,
                "created_at": "2025-09-04T15:00:00.000000Z"
            }
        ],
        "user": {
            "id": 1,
            "name": "John Doe",
            "email": "john@example.com",
            "phone": "081234567890"
        }
    }
}
```

### 4. Update Order

**PUT** `/api/v1/members/orders/{id}`

Mengupdate pesanan (hanya untuk field yang dapat diubah).

#### Request Body

```json
{
    "delivery_location": "Lobby",
    "special_instructions": "Updated instructions",
    "discount_amount": 10000
}
```

#### Response

```json
{
    "success": true,
    "message": "Order updated successfully",
    "data": {
        "id": 1,
        "order_number": "ORD202509040001",
        "delivery_location": "Lobby",
        "special_instructions": "Updated instructions",
        "discount_amount": "10000.00",
        "updated_at": "2025-09-04T15:05:00.000000Z"
    }
}
```

### 5. Cancel Order

**POST** `/api/v1/members/orders/{id}/cancel`

Membatalkan pesanan.

#### Request Body

```json
{
    "reason": "Customer request"
}
```

#### Response

```json
{
    "success": true,
    "message": "Order cancelled successfully",
    "data": {
        "id": 1,
        "order_number": "ORD202509040001",
        "status": "cancelled",
        "updated_at": "2025-09-04T15:05:00.000000Z"
    }
}
```

### 6. Confirm Order

**POST** `/api/v1/members/orders/{id}/confirm`

Mengkonfirmasi pesanan (hanya untuk pesanan yang sudah dibayar).

#### Response

```json
{
    "success": true,
    "message": "Order confirmed successfully",
    "data": {
        "id": 1,
        "order_number": "ORD202509040001",
        "status": "confirmed",
        "updated_at": "2025-09-04T15:05:00.000000Z"
    }
}
```

### 7. Upload Payment Proof

**POST** `/api/v1/members/orders/{id}/upload-proof`

Upload bukti pembayaran.

#### Request Body (multipart/form-data)

```
payment_proof: [file]
```

#### Response

```json
{
    "success": true,
    "message": "Payment proof uploaded successfully",
    "data": {
        "id": 1,
        "order_number": "ORD202509040001",
        "payment_proof_path": "payment-proofs/ORD202509040001_proof.jpg",
        "updated_at": "2025-09-04T15:05:00.000000Z"
    }
}
```

### 8. Get Order Receipt

**GET** `/api/v1/members/orders/{id}/receipt`

Mendapatkan struk pesanan.

#### Response

```json
{
    "success": true,
    "message": "Order receipt retrieved successfully",
    "data": {
        "order": {
            "id": 1,
            "order_number": "ORD202509040001",
            "status": "confirmed",
            "payment_status": "paid",
            "created_at": "2025-09-04T15:00:00.000000Z"
        },
        "receipt_data": {
            "order_number": "ORD202509040001",
            "customer_name": "John Doe",
            "customer_phone": "081234567890",
            "items": [
                {
                    "name": "Nasi Goreng Spesial",
                    "quantity": 2,
                    "unit_price": "25000.00",
                    "total_price": "50000.00"
                }
            ],
            "subtotal": "50000.00",
            "tax": "5000.00",
            "discount": "5000.00",
            "total": "50000.00",
            "payment_method": "Manual Transfer",
            "estimated_ready_time": "2025-09-04T15:30:00"
        }
    }
}
```

## Admin Endpoints

### 1. Get All Orders (Admin)

**GET** `/api/v1/admin/orders`

Mendapatkan semua pesanan dengan filter admin.

#### Query Parameters

-   `status` - Filter berdasarkan status
-   `payment_status` - Filter berdasarkan status pembayaran
-   `user_id` - Filter berdasarkan user ID
-   `start_date` - Tanggal mulai
-   `end_date` - Tanggal akhir
-   `order_number` - Filter berdasarkan nomor pesanan
-   `per_page` - Jumlah data per halaman

#### Response

```json
{
  "success": true,
  "message": "Orders retrieved successfully",
  "data": {
    "current_page": 1,
    "data": [
      {
        "id": 1,
        "order_number": "ORD202509040001",
        "user_id": 1,
        "guest_name": null,
        "total_amount": "50000.00",
        "final_amount": "50000.00",
        "status": "pending",
        "payment_status": "unpaid",
        "created_at": "2025-09-04T15:00:00.000000Z",
        "user": {
          "id": 1,
          "name": "John Doe",
          "email": "john@example.com"
        },
        "order_items": [
          {
            "id": 1,
            "menu_item_id": 1,
            "quantity": 2,
            "unit_price": "25000.00",
            "total_price": "50000.00",
            "status": "pending",
            "menu_item": {
              "id": 1,
              "name": "Nasi Goreng Spesial"
            }
          }
        ]
      }
    ],
    "pagination": {...}
  }
}
```

### 2. Update Order Status (Admin)

**PUT** `/api/v1/admin/orders/{id}/status`

Mengupdate status pesanan.

#### Request Body

```json
{
    "status": "confirmed",
    "notes": "Order confirmed by admin"
}
```

#### Response

```json
{
    "success": true,
    "message": "Order status updated successfully",
    "data": {
        "id": 1,
        "order_number": "ORD202509040001",
        "status": "confirmed",
        "updated_at": "2025-09-04T15:05:00.000000Z"
    }
}
```

### 3. Update Payment Status (Admin)

**PUT** `/api/v1/admin/orders/{id}/payment-status`

Mengupdate status pembayaran.

#### Request Body

```json
{
    "payment_status": "paid",
    "payment_proof_path": "payment-proofs/ORD202509040001_proof.jpg"
}
```

#### Response

```json
{
    "success": true,
    "message": "Payment status updated successfully",
    "data": {
        "id": 1,
        "order_number": "ORD202509040001",
        "payment_status": "paid",
        "payment_proof_path": "payment-proofs/ORD202509040001_proof.jpg",
        "updated_at": "2025-09-04T15:05:00.000000Z"
    }
}
```

### 4. Get Order Statistics (Admin)

**GET** `/api/v1/admin/orders/stats`

Mendapatkan statistik pesanan.

#### Query Parameters

-   `start_date` - Tanggal mulai
-   `end_date` - Tanggal akhir

#### Response

```json
{
    "success": true,
    "message": "Order statistics retrieved successfully",
    "data": {
        "total_orders": 150,
        "pending_orders": 25,
        "confirmed_orders": 30,
        "preparing_orders": 20,
        "ready_orders": 15,
        "delivered_orders": 50,
        "cancelled_orders": 10,
        "paid_orders": 140,
        "unpaid_orders": 10,
        "total_revenue": "7500000.00",
        "average_order_value": "50000.00"
    }
}
```

### 5. Get Order Analytics (Admin)

**GET** `/api/v1/admin/orders/analytics`

Mendapatkan analitik pesanan.

#### Query Parameters

-   `start_date` - Tanggal mulai
-   `end_date` - Tanggal akhir

#### Response

```json
{
    "success": true,
    "message": "Order analytics retrieved successfully",
    "data": {
        "order_trends": [
            {
                "date": "2025-09-01",
                "total_orders": 25,
                "total_revenue": "1250000.00"
            },
            {
                "date": "2025-09-02",
                "total_orders": 30,
                "total_revenue": "1500000.00"
            }
        ],
        "status_distribution": [
            {
                "status": "delivered",
                "count": 50,
                "percentage": 33.33
            },
            {
                "status": "pending",
                "count": 25,
                "percentage": 16.67
            }
        ],
        "payment_methods": [
            {
                "method": "manual_transfer",
                "count": 80,
                "percentage": 53.33
            },
            {
                "method": "cash",
                "count": 50,
                "percentage": 33.33
            },
            {
                "method": "online",
                "count": 20,
                "percentage": 13.33
            }
        ],
        "top_menu_items": [
            {
                "menu_item_id": 1,
                "menu_item_name": "Nasi Goreng Spesial",
                "total_quantity": 150,
                "total_revenue": "3750000.00"
            }
        ],
        "average_preparation_time": 18
    }
}
```

## Error Responses

### Validation Error (422)

```json
{
    "success": false,
    "message": "Validation failed",
    "errors": {
        "items": ["Order items are required"],
        "items.0.menu_item_id": ["Selected menu item does not exist"]
    }
}
```

### Not Found Error (404)

```json
{
    "success": false,
    "message": "Order not found",
    "error": "Order with ID 999 not found"
}
```

### Business Logic Error (400)

```json
{
    "success": false,
    "message": "Order cannot be cancelled",
    "error": "Order status does not allow cancellation"
}
```

### Server Error (500)

```json
{
    "success": false,
    "message": "Internal server error",
    "error": "An unexpected error occurred"
}
```

## Status Codes

-   `200` - Success
-   `201` - Created
-   `400` - Bad Request (Business logic error)
-   `401` - Unauthorized
-   `403` - Forbidden
-   `404` - Not Found
-   `422` - Validation Error
-   `500` - Internal Server Error

## Rate Limiting

-   Member endpoints: 60 requests per minute
-   Admin endpoints: 100 requests per minute

## Notes

1. **Order Number**: Otomatis generated dengan format `ORD{YYYYMMDD}{XXXX}`
2. **Tax Calculation**: Pajak 10% dari total amount
3. **Inventory**: Otomatis dikurangi saat order dibuat dan dikembalikan saat order dibatalkan
4. **Status Transition**: Hanya transisi status yang valid yang diperbolehkan
5. **Payment Auto-confirm**: Order otomatis dikonfirmasi jika payment status diubah menjadi 'paid'
6. **Guest Orders**: Dapat dibuat tanpa user_id, tetapi memerlukan guest_name dan guest_phone
