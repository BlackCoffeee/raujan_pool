# Payment Tracking API Documentation

## 📋 Overview

Payment Tracking System adalah sistem yang memungkinkan tracking lengkap terhadap semua event pembayaran, termasuk timeline pembayaran, reminder otomatis, dan reporting yang komprehensif.

## 🏗️ Architecture

```
PaymentTracking Model
├── Payment (belongs to)
├── User (triggered by)
└── Event tracking data

TrackingService
├── Event tracking
├── Timeline generation
├── Reminder management
├── Expiry handling
└── Reporting

PaymentTrackingController
├── Timeline endpoints
├── Reminder endpoints
├── Statistics endpoints
└── Report endpoints

SendPaymentReminderJob
├── Reminder processing
├── Event logging
└── Notification handling
```

## 🔌 API Endpoints

### 1. Payment Timeline

#### Get Payment Timeline

```http
GET /api/v1/payments/{id}/tracking/timeline
```

**Description:** Mendapatkan timeline lengkap dari sebuah pembayaran

**Response:**

```json
{
    "success": true,
    "message": "Payment timeline retrieved successfully",
    "data": [
        {
            "event": "Payment Created",
            "timestamp": "2025-09-02T07:14:39.818017Z",
            "description": "Payment request created",
            "status": "created",
            "triggered_by": null
        },
        {
            "event": "Proof Uploaded",
            "timestamp": "2025-09-02T08:30:00.000000Z",
            "description": "Payment proof uploaded",
            "status": "pending",
            "triggered_by": "John Doe",
            "event_data": {
                "proof_path": "proof.jpg"
            }
        }
    ]
}
```

### 2. Payment Reminders

#### Send Payment Reminder

```http
POST /api/v1/payments/{id}/tracking/reminder
```

**Request Body:**

```json
{
    "reminder_type": "urgent"
}
```

**Reminder Types:**

-   `standard` - Reminder standar
-   `urgent` - Reminder mendesak
-   `final` - Reminder terakhir

**Response:**

```json
{
    "success": true,
    "message": "Payment reminder sent successfully"
}
```

#### Send Expiry Warning

```http
POST /api/v1/payments/{id}/tracking/expiry-warning
```

**Description:** Mengirim peringatan kedaluwarsa pembayaran

**Response:**

```json
{
    "success": true,
    "message": "Expiry warning sent successfully"
}
```

### 3. Payment Statistics

#### Get Payment Statistics

```http
GET /api/v1/admin/payments/tracking/stats
```

**Query Parameters:**

-   `start_date` (optional): Start date filter (Y-m-d)
-   `end_date` (optional): End date filter (Y-m-d)
-   `user_id` (optional): Filter by specific user

**Response:**

```json
{
    "success": true,
    "message": "Payment statistics retrieved successfully",
    "data": {
        "total_payments": 150,
        "pending_payments": 25,
        "verified_payments": 100,
        "rejected_payments": 15,
        "expired_payments": 10,
        "total_amount": 15000000,
        "average_payment_time": 45.5,
        "payment_success_rate": 66.67
    }
}
```

#### Get Payment Trends

```http
GET /api/v1/admin/payments/tracking/trends?days=7
```

**Query Parameters:**

-   `days` (optional): Number of days to analyze (default: 30, max: 365)

**Response:**

```json
{
    "success": true,
    "message": "Payment trends retrieved successfully",
    "data": [
        {
            "date": "2025-09-01",
            "total_payments": 15,
            "pending_payments": 5,
            "verified_payments": 8,
            "rejected_payments": 2,
            "total_amount": 1500000
        }
    ]
}
```

### 4. Payment Reports

#### Generate Payment Report

```http
GET /api/v1/admin/payments/tracking/report
```

**Query Parameters:**

-   `start_date` (optional): Start date filter (Y-m-d)
-   `end_date` (optional): End date filter (Y-m-d)
-   `status` (optional): Filter by payment status
-   `payment_method` (optional): Filter by payment method
-   `user_id` (optional): Filter by specific user

**Response:**

```json
{
    "success": true,
    "message": "Payment report generated successfully",
    "data": {
        "generated_at": "2025-09-02T07:14:39.818017Z",
        "filters": {
            "start_date": "2025-09-01",
            "end_date": "2025-09-02"
        },
        "summary": {
            "total_payments": 25,
            "total_amount": 2500000,
            "average_amount": 100000,
            "status_breakdown": {
                "pending": {
                    "count": 5,
                    "percentage": 20.0,
                    "total_amount": 500000
                },
                "verified": {
                    "count": 18,
                    "percentage": 72.0,
                    "total_amount": 1800000
                }
            }
        },
        "payments": [
            {
                "id": 1,
                "reference_number": "PAY-001",
                "user_name": "John Doe",
                "booking_reference": "BK-001",
                "amount": 100000,
                "status": "verified",
                "payment_method": "manual_transfer",
                "bank_account": "BCA",
                "created_at": "2025-09-01T10:00:00.000000Z",
                "verified_at": "2025-09-01T14:30:00.000000Z"
            }
        ]
    }
}
```

### 5. Custom Event Tracking

#### Track Custom Event

```http
POST /api/v1/payments/{id}/tracking/event
```

**Request Body:**

```json
{
    "event_type": "custom_event",
    "event_data": {
        "note": "Custom note",
        "action": "manual_verification"
    },
    "notes": "Custom event occurred"
}
```

**Response:**

```json
{
    "success": true,
    "message": "Payment event tracked successfully",
    "data": {
        "id": 15,
        "payment_id": 1,
        "event_type": "custom_event",
        "event_data": {
            "note": "Custom note",
            "action": "manual_verification"
        },
        "notes": "Custom event occurred",
        "triggered_at": "2025-09-02T07:14:39.818017Z"
    }
}
```

### 6. Expired Payment Management

#### Process Expired Payments

```http
POST /api/v1/admin/payments/process-expired
```

**Description:** Memproses semua pembayaran yang telah kedaluwarsa

**Response:**

```json
{
    "success": true,
    "message": "Expired payments processed successfully",
    "data": {
        "processed_count": 5
    }
}
```

## 📊 Event Types

Sistem mendukung berbagai jenis event tracking:

| Event Type       | Description                   | Auto Generated |
| ---------------- | ----------------------------- | -------------- |
| `created`        | Payment request created       | ✅ Yes         |
| `proof_uploaded` | Payment proof uploaded        | ✅ Yes         |
| `reminder_sent`  | Payment reminder sent         | ✅ Yes         |
| `expiry_warning` | Payment expiry warning sent   | ✅ Yes         |
| `expired`        | Payment expired               | ✅ Yes         |
| `verified`       | Payment verified and approved | ✅ Yes         |
| `rejected`       | Payment rejected              | ✅ Yes         |
| `cancelled`      | Payment cancelled             | ✅ Yes         |
| `custom_event`   | Custom event (manual)         | ❌ No          |

## 🔧 Service Methods

### TrackingService

#### trackPaymentEvent()

```php
public function trackPaymentEvent($paymentId, $eventType, $eventData = [], $triggeredBy = null)
```

**Parameters:**

-   `$paymentId`: ID pembayaran
-   `$eventType`: Jenis event
-   `$eventData`: Data tambahan event (optional)
-   `$triggeredBy`: ID user yang memicu event (optional)

**Returns:** PaymentTracking model instance

#### getPaymentTimeline()

```php
public function getPaymentTimeline($paymentId)
```

**Parameters:**

-   `$paymentId`: ID pembayaran

**Returns:** Array timeline events

#### sendPaymentReminder()

```php
public function sendPaymentReminder($paymentId, $reminderType = 'standard')
```

**Parameters:**

-   `$paymentId`: ID pembayaran
-   `$reminderType`: Jenis reminder

**Returns:** Boolean success status

#### processExpiredPayments()

```php
public function processExpiredPayments()
```

**Returns:** Number of processed payments

#### getPaymentStats()

```php
public function getPaymentStats($filters = [])
```

**Parameters:**

-   `$filters`: Array filter parameters

**Returns:** Array statistics data

## 📝 Database Schema

### payment_trackings Table

```sql
CREATE TABLE payment_trackings (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    payment_id BIGINT UNSIGNED NOT NULL,
    status VARCHAR(255) NOT NULL,
    event_type VARCHAR(255) NOT NULL,
    event_data JSON NULL,
    triggered_by BIGINT UNSIGNED NULL,
    triggered_at TIMESTAMP NOT NULL,
    notes TEXT NULL,
    created_at TIMESTAMP NULL,
    updated_at TIMESTAMP NULL,

    FOREIGN KEY (payment_id) REFERENCES payments(id) ON DELETE CASCADE,
    FOREIGN KEY (triggered_by) REFERENCES users(id) ON DELETE SET NULL,

    INDEX idx_payment_id (payment_id),
    INDEX idx_event_type (event_type),
    INDEX idx_status (status),
    INDEX idx_triggered_at (triggered_at)
);
```

## 🧪 Testing

### Running Tests

```bash
# Run all payment tracking tests
php artisan test tests/Feature/PaymentTrackingTest.php

# Run specific test
php artisan test --filter "Payment Tracking System"
```

### Test Coverage

-   ✅ Model creation and relationships
-   ✅ Service methods functionality
-   ✅ API endpoints validation
-   ✅ Job processing
-   ✅ Event tracking
-   ✅ Timeline generation
-   ✅ Statistics calculation
-   ✅ Report generation

## 🚀 Usage Examples

### 1. Track Payment Event

```php
use App\Services\TrackingService;

$trackingService = app(TrackingService::class);

// Track proof upload
$tracking = $trackingService->trackPaymentEvent(
    $paymentId,
    'proof_uploaded',
    ['proof_path' => 'uploads/proof.jpg'],
    auth()->id()
);
```

### 2. Get Payment Timeline

```php
$timeline = $trackingService->getPaymentTimeline($paymentId);

foreach ($timeline as $event) {
    echo "Event: {$event['event']}\n";
    echo "Time: {$event['timestamp']}\n";
    echo "Description: {$event['description']}\n";
}
```

### 3. Send Payment Reminder

```php
$result = $trackingService->sendPaymentReminder($paymentId, 'urgent');

if ($result) {
    echo "Reminder sent successfully";
}
```

### 4. Process Expired Payments

```php
$processedCount = $trackingService->processExpiredPayments();
echo "Processed {$processedCount} expired payments";
```

## 🔒 Security & Permissions

### Required Permissions

-   **View Timeline**: User can view their own payment timeline
-   **Send Reminder**: Admin/Staff only
-   **View Statistics**: Admin only
-   **Generate Reports**: Admin only
-   **Track Custom Events**: Admin/Staff only

### Middleware

```php
// Admin only routes
Route::middleware(['auth:sanctum', 'role:admin'])->group(function () {
    Route::get('/tracking/stats', [PaymentTrackingController::class, 'getStats']);
    Route::get('/tracking/report', [PaymentTrackingController::class, 'generateReport']);
});

// Staff/Admin routes
Route::middleware(['auth:sanctum', 'role:admin|staff'])->group(function () {
    Route::post('/{id}/tracking/reminder', [PaymentTrackingController::class, 'sendReminder']);
    Route::post('/{id}/tracking/event', [PaymentTrackingController::class, 'trackEvent']);
});
```

## 📈 Monitoring & Logging

### Log Events

Sistem mencatat semua event tracking ke dalam log:

```php
Log::info('Payment event tracked', [
    'payment_id' => $payment->id,
    'event_type' => $eventType,
    'tracking_id' => $tracking->id,
]);
```

### Performance Metrics

-   Event tracking response time
-   Timeline generation performance
-   Statistics calculation speed
-   Report generation efficiency

## 🔄 Integration Points

### 1. Payment Model

```php
// Payment model automatically tracks creation
class Payment extends Model
{
    protected static function booted()
    {
        static::created(function ($payment) {
            app(TrackingService::class)->trackPaymentEvent(
                $payment->id,
                'created'
            );
        });
    }
}
```

### 2. Payment Verification

```php
// When payment is verified
$payment->update(['status' => 'verified', 'verified_at' => now()]);

$trackingService->trackPaymentEvent(
    $payment->id,
    'verified',
    ['verified_by' => auth()->id()]
);
```

### 3. Payment Rejection

```php
// When payment is rejected
$payment->update(['status' => 'rejected']);

$trackingService->trackPaymentEvent(
    $payment->id,
    'rejected',
    ['rejected_by' => auth()->id(), 'reason' => $request->reason]
);
```

## 🐛 Troubleshooting

### Common Issues

#### 1. Event Not Tracked

**Problem:** Event tidak tercatat dalam database

**Solution:**

```php
// Check if TrackingService is properly injected
$trackingService = app(TrackingService::class);

// Verify payment exists
$payment = Payment::findOrFail($paymentId);

// Check database connection
DB::connection()->getPdo();
```

#### 2. Timeline Empty

**Problem:** Timeline tidak menampilkan data

**Solution:**

```php
// Check if payment has tracking records
$trackingCount = PaymentTracking::where('payment_id', $paymentId)->count();

// Verify payment creation event
$payment = Payment::find($paymentId);
echo "Payment created at: " . $payment->created_at;
```

#### 3. Reminder Not Sent

**Problem:** Reminder tidak terkirim

**Solution:**

```php
// Check queue configuration
php artisan queue:work

// Verify job dispatch
Queue::fake();
$trackingService->sendPaymentReminder($paymentId, 'urgent');
Queue::assertPushed(SendPaymentReminderJob::class);
```

## 📚 Additional Resources

-   [Laravel Jobs Documentation](https://laravel.com/docs/11.x/queues)
-   [Laravel Database Transactions](https://laravel.com/docs/11.x/database#database-transactions)
-   [Laravel Events & Listeners](https://laravel.com/docs/11.x/events)
-   [Payment Processing Best Practices](https://stripe.com/docs/payments)
-   [API Design Guidelines](https://github.com/microsoft/api-guidelines)

## 🤝 Contributing

Untuk berkontribusi pada Payment Tracking System:

1. Fork repository
2. Create feature branch
3. Implement changes
4. Add tests
5. Submit pull request

## 📄 License

Payment Tracking System is part of Raujan Pool Backend and is licensed under the MIT License.
