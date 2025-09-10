# Order Tracking System - Dokumentasi Lengkap

## Overview

Order Tracking System adalah sistem pelacakan pesanan yang komprehensif untuk mengelola status pesanan, timeline, feedback, dan analytics. Sistem ini terintegrasi dengan cafe order management dan menyediakan real-time tracking untuk customer dan admin.

## Fitur Utama

### 1. Order Status Tracking

-   **Status Management**: Pending, Confirmed, Preparing, Ready, Delivered, Cancelled
-   **Real-time Updates**: Status update otomatis dengan timestamp
-   **Status Validation**: Validasi transisi status yang sesuai
-   **Admin Override**: Admin dapat mengubah status secara manual

### 2. Order Timeline

-   **Complete History**: Riwayat lengkap perubahan status
-   **Timestamp Tracking**: Waktu setiap perubahan status
-   **User Attribution**: Siapa yang melakukan perubahan
-   **Notes & Comments**: Catatan untuk setiap perubahan

### 3. Order Feedback System

-   **Rating System**: Rating 1-5 untuk overall, food quality, service, delivery
-   **Comment System**: Komentar text untuk feedback detail
-   **Anonymous Feedback**: Opsi feedback anonim
-   **Feedback Analytics**: Analisis feedback untuk improvement

### 4. Analytics & Reporting

-   **Processing Times**: Waktu rata-rata setiap tahap
-   **Status Distribution**: Distribusi status pesanan
-   **Completion Rate**: Tingkat penyelesaian pesanan
-   **Staff Performance**: Performa staff berdasarkan tracking
-   **Peak Hours**: Jam-jam sibuk berdasarkan data

## Arsitektur Sistem

### Models

#### OrderTracking

```php
- order_id: Foreign key ke orders
- status: Status pesanan (pending, confirmed, preparing, ready, delivered, cancelled)
- notes: Catatan perubahan status
- updated_by: User yang melakukan update
- estimated_time: Estimasi waktu selesai
- actual_time: Waktu aktual perubahan
- created_at, updated_at: Timestamps
```

#### OrderFeedback

```php
- order_id: Foreign key ke orders
- user_id: User yang memberikan feedback
- rating: Rating keseluruhan (1-5)
- comment: Komentar feedback
- food_quality_rating: Rating kualitas makanan
- service_rating: Rating pelayanan
- delivery_rating: Rating pengiriman
- is_anonymous: Feedback anonim atau tidak
- created_at, updated_at: Timestamps
```

### Services

#### OrderTrackingService

-   `createTrackingRecord()`: Membuat record tracking baru
-   `getOrderStatus()`: Mendapatkan status pesanan
-   `getOrderTimeline()`: Mendapatkan timeline pesanan
-   `submitFeedback()`: Submit feedback pesanan
-   `getActiveOrders()`: Mendapatkan pesanan aktif
-   `getOrderHistory()`: Mendapatkan riwayat pesanan
-   `getTrackingStats()`: Mendapatkan statistik tracking
-   `getTrackingAnalytics()`: Mendapatkan analytics tracking
-   `sendOrderNotifications()`: Kirim notifikasi pesanan

### Controllers

#### OrderTrackingController

-   `GET /orders/{id}/status`: Get order status
-   `GET /orders/{id}/timeline`: Get order timeline
-   `POST /orders/{id}/feedback`: Submit feedback
-   `GET /orders/active`: Get active orders
-   `GET /orders/history`: Get order history
-   `GET /admin/orders/tracking/stats`: Get tracking statistics
-   `GET /admin/orders/tracking/analytics`: Get tracking analytics
-   `PUT /admin/orders/{id}/tracking`: Update order tracking

## Database Schema

### order_tracking Table

```sql
CREATE TABLE order_tracking (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    order_id BIGINT NOT NULL,
    status ENUM('pending', 'confirmed', 'preparing', 'ready', 'delivered', 'cancelled') NOT NULL,
    notes TEXT NULL,
    updated_by BIGINT NULL,
    estimated_time TIMESTAMP NULL,
    actual_time TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE,
    FOREIGN KEY (updated_by) REFERENCES users(id) ON DELETE SET NULL,

    INDEX idx_order_id (order_id),
    INDEX idx_status (status),
    INDEX idx_updated_by (updated_by),
    INDEX idx_created_at (created_at)
);
```

### order_feedback Table

```sql
CREATE TABLE order_feedback (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    order_id BIGINT NOT NULL,
    user_id BIGINT NOT NULL,
    rating INT NOT NULL COMMENT 'Overall rating 1-5',
    comment TEXT NULL,
    food_quality_rating INT NULL COMMENT 'Food quality rating 1-5',
    service_rating INT NULL COMMENT 'Service rating 1-5',
    delivery_rating INT NULL COMMENT 'Delivery rating 1-5',
    is_anonymous BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,

    UNIQUE KEY unique_order_feedback (order_id),
    INDEX idx_order_id (order_id),
    INDEX idx_user_id (user_id),
    INDEX idx_rating (rating),
    INDEX idx_created_at (created_at)
);
```

## API Endpoints

### Member Endpoints

#### Get Order Status

```http
GET /api/v1/orders/{id}/status
Authorization: Bearer {token}
```

Response:

```json
{
    "success": true,
    "message": "Order status retrieved successfully",
    "data": {
        "order_id": 1,
        "order_number": "ORD-20250105-0001",
        "current_status": "preparing",
        "status_display": "Preparing",
        "estimated_ready_time": "2025-01-05T10:30:00Z",
        "can_be_cancelled": true,
        "can_provide_feedback": false
    }
}
```

#### Get Order Timeline

```http
GET /api/v1/orders/{id}/timeline
Authorization: Bearer {token}
```

Response:

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
            "actual_time": "2025-01-05T09:00:00Z"
        },
        {
            "id": 2,
            "status": "confirmed",
            "status_display": "Confirmed",
            "notes": "Order confirmed by admin",
            "updated_by": "Admin User",
            "actual_time": "2025-01-05T09:05:00Z"
        }
    ]
}
```

#### Submit Feedback

```http
POST /api/v1/orders/{id}/feedback
Authorization: Bearer {token}
Content-Type: application/json

{
    "rating": 5,
    "comment": "Excellent service!",
    "food_quality_rating": 5,
    "service_rating": 4,
    "delivery_rating": 5,
    "is_anonymous": false
}
```

Response:

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
        "created_at": "2025-01-05T10:00:00Z"
    }
}
```

### Admin Endpoints

#### Update Order Tracking

```http
PUT /api/v1/admin/orders/{id}/tracking
Authorization: Bearer {admin_token}
Content-Type: application/json

{
    "status": "ready",
    "notes": "Order is ready for pickup",
    "estimated_time": "2025-01-05T10:30:00Z"
}
```

#### Get Tracking Statistics

```http
GET /api/v1/admin/orders/tracking/stats
Authorization: Bearer {admin_token}
```

Response:

```json
{
    "success": true,
    "message": "Tracking statistics retrieved successfully",
    "data": {
        "total_tracking_records": 150,
        "status_distribution": {
            "pending": 5,
            "confirmed": 10,
            "preparing": 15,
            "ready": 8,
            "delivered": 110,
            "cancelled": 2
        },
        "average_processing_time": 25.5,
        "completion_rate": 95.2,
        "cancellation_rate": 1.3
    }
}
```

## Testing

### Running Tests

```bash
# Run all order tracking tests
php artisan test --filter="OrderTracking"

# Run specific test file
php artisan test tests/Feature/OrderTrackingFinalTest.php

# Run with coverage
php artisan test --coverage --filter="OrderTracking"
```

### Test Coverage

-   ✅ Model instantiation
-   ✅ Service methods
-   ✅ API endpoints
-   ✅ Database operations
-   ✅ Error handling
-   ✅ Validation rules

## Setup & Installation

### 1. Run Migrations

```bash
php artisan migrate
```

### 2. Clear Cache

```bash
php artisan config:clear
php artisan cache:clear
php artisan route:clear
```

### 3. Run Tests

```bash
php artisan test --filter="OrderTracking"
```

### 4. Setup Script

```bash
./scripts/order-tracking-setup.sh
```

## Usage Examples

### 1. Create Tracking Record

```php
$trackingService = app(OrderTrackingService::class);

$tracking = $trackingService->createTrackingRecord(
    $orderId = 1,
    $status = 'confirmed',
    $notes = 'Order confirmed by admin',
    $estimatedTime = now()->addMinutes(30)
);
```

### 2. Get Order Status

```php
$status = $trackingService->getOrderStatus($orderId);
echo $status['current_status']; // 'preparing'
```

### 3. Submit Feedback

```php
$feedback = $trackingService->submitFeedback($orderId, [
    'rating' => 5,
    'comment' => 'Great service!',
    'food_quality_rating' => 5,
    'service_rating' => 4,
    'delivery_rating' => 5,
    'is_anonymous' => false
]);
```

### 4. Get Analytics

```php
$analytics = $trackingService->getTrackingAnalytics();
$stats = $trackingService->getTrackingStats();
```

## Monitoring & Maintenance

### 1. Performance Monitoring

-   Monitor query performance pada tabel tracking
-   Optimize index jika diperlukan
-   Monitor memory usage untuk analytics

### 2. Data Cleanup

-   Archive old tracking records (> 1 year)
-   Clean up cancelled orders
-   Optimize feedback data

### 3. Regular Maintenance

-   Update statistics daily
-   Monitor completion rates
-   Review feedback trends

## Security Considerations

### 1. Access Control

-   Member hanya bisa akses pesanan sendiri
-   Admin memiliki akses penuh
-   Validasi ownership untuk feedback

### 2. Data Validation

-   Validasi input untuk semua endpoints
-   Sanitize feedback comments
-   Rate limiting untuk feedback submission

### 3. Privacy

-   Support anonymous feedback
-   Data retention policies
-   GDPR compliance untuk feedback data

## Troubleshooting

### Common Issues

1. **Foreign Key Constraints**

    - Pastikan order dan user sudah ada sebelum tracking
    - Gunakan factory yang benar untuk testing

2. **Status Transition Errors**

    - Validasi status transition rules
    - Check business logic dalam service

3. **Performance Issues**
    - Optimize database queries
    - Add proper indexes
    - Use pagination untuk large datasets

### Debug Commands

```bash
# Check database structure
php artisan tinker
>>> Schema::getColumnListing('order_tracking')

# Test service methods
php artisan tinker
>>> app(App\Services\OrderTrackingService::class)->getTrackingStats()

# Check routes
php artisan route:list --name=order-tracking
```

## Future Enhancements

### 1. Real-time Updates

-   WebSocket integration untuk real-time status updates
-   Push notifications untuk status changes
-   Live dashboard untuk admin

### 2. Advanced Analytics

-   Machine learning untuk prediction
-   Customer behavior analysis
-   Staff performance optimization

### 3. Integration Features

-   SMS notifications
-   Email updates
-   Third-party delivery tracking
-   QR code integration

## Support & Documentation

-   **API Documentation**: `/docs/api/order-tracking-api.md`
-   **Testing Documentation**: `/docs/testing/order-tracking-testing.md`
-   **Setup Script**: `/scripts/order-tracking-setup.sh`
-   **Database Schema**: `/plan/analisis/05-desain-database.md`

---

**Version**: 1.0  
**Last Updated**: 5 September 2025  
**Status**: Production Ready  
**Maintainer**: Development Team
