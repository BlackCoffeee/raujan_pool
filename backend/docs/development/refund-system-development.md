# Refund System Development Guide

## Overview

Refund Management System adalah bagian dari Phase 4 development yang memungkinkan pengelolaan refund untuk pembayaran yang sudah diverifikasi. Sistem ini terintegrasi dengan Payment dan Booking system.

## Architecture

### Database Schema

```sql
-- Refunds Table
CREATE TABLE refunds (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    payment_id BIGINT UNSIGNED NOT NULL,
    booking_id BIGINT UNSIGNED NOT NULL,
    amount DECIMAL(10,2) NOT NULL,
    reason TEXT NOT NULL,
    status ENUM('pending', 'approved', 'rejected', 'processed') DEFAULT 'pending',
    requested_by BIGINT UNSIGNED NOT NULL,
    approved_by BIGINT UNSIGNED NULL,
    processed_at TIMESTAMP NULL,
    refund_method ENUM('bank_transfer', 'cash', 'credit') DEFAULT 'bank_transfer',
    refund_reference VARCHAR(255) UNIQUE NOT NULL,
    notes TEXT NULL,
    admin_notes TEXT NULL,
    created_at TIMESTAMP NULL DEFAULT NULL,
    updated_at TIMESTAMP NULL DEFAULT NULL,

    FOREIGN KEY (payment_id) REFERENCES payments(id) ON DELETE CASCADE,
    FOREIGN KEY (booking_id) REFERENCES bookings(id) ON DELETE CASCADE,
    FOREIGN KEY (requested_by) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (approved_by) REFERENCES users(id) ON DELETE SET NULL
);

-- Updates to Payments Table
ALTER TABLE payments ADD COLUMN refund_id BIGINT UNSIGNED NULL;
ALTER TABLE payments ADD COLUMN refunded_amount DECIMAL(10,2) NULL DEFAULT 0;
ALTER TABLE payments ADD COLUMN refunded_at TIMESTAMP NULL;
ALTER TABLE payments ADD COLUMN refunded_by BIGINT UNSIGNED NULL;
```

### Model Relationships

```php
// Refund Model
class Refund extends Model
{
    public function payment(): BelongsTo
    public function booking(): BelongsTo
    public function requestedBy(): BelongsTo
    public function approvedBy(): BelongsTo
}

// Payment Model (Updated)
class Payment extends Model
{
    public function refund(): BelongsTo
    public function refundedBy(): BelongsTo
}

// Booking Model (Updated)
class Booking extends Model
{
    public function refunds(): HasMany
}
```

## Service Layer

### RefundService

Core business logic untuk refund management:

```php
class RefundService
{
    // Main methods
    public function createRefundRequest($data)
    public function approveRefund($refundId, $approvedBy = null, $adminNotes = null)
    public function rejectRefund($refundId, $rejectedBy = null, $adminNotes = null)
    public function processRefund($refundId)

    // Helper methods
    protected function validateRefundEligibility($payment, $booking)
    protected function calculateRefundAmount($payment, $booking, $data)
    protected function getRefundPercentage($booking, $data)
}
```

### Business Rules

1. **Refund Eligibility**:

    - Payment harus status 'verified'
    - Booking tidak boleh status 'completed'
    - Tidak ada refund pending/approved untuk payment yang sama
    - Request dalam 24 jam setelah booking dibuat

2. **Refund Calculation**:

    ```php
    if ($hoursUntilBooking > 24) return 100; // Full refund
    elseif ($hoursUntilBooking > 12) return 75; // 75% refund
    elseif ($hoursUntilBooking > 6) return 50; // 50% refund
    else return 0; // No refund
    ```

3. **Status Flow**:
    ```
    pending → approved → processed
            ↘ rejected
    ```

## Controllers

### User Controller (RefundController)

Endpoints untuk user management:

```php
class RefundController extends BaseController
{
    public function index(Request $request) // GET /api/v1/bookings/refunds
    public function store(RefundRequest $request) // POST /api/v1/bookings/refunds
    public function show($id) // GET /api/v1/bookings/refunds/{id}
    public function update(RefundRequest $request, $id) // PUT /api/v1/bookings/refunds/{id}
    public function destroy($id) // DELETE /api/v1/bookings/refunds/{id}
}
```

### Admin Controller (Admin\RefundController)

Endpoints untuk admin management:

```php
class Admin\RefundController extends BaseController
{
    public function index(Request $request) // GET /api/v1/admin/refunds
    public function show($id) // GET /api/v1/admin/refunds/{id}
    public function approve(Request $request, $id) // POST /api/v1/admin/refunds/{id}/approve
    public function reject(Request $request, $id) // POST /api/v1/admin/refunds/{id}/reject
    public function process($id) // POST /api/v1/admin/refunds/{id}/process
    public function getStats() // GET /api/v1/admin/refunds/stats
    public function bulkProcess(Request $request) // POST /api/v1/admin/refunds/bulk-process
}
```

## Routes

### User Routes

```php
Route::middleware(['auth:sanctum'])->group(function () {
    Route::prefix('bookings/refunds')->group(function () {
        Route::get('/', [RefundController::class, 'index']);
        Route::post('/', [RefundController::class, 'store']);
        Route::get('/{id}', [RefundController::class, 'show']);
        Route::put('/{id}', [RefundController::class, 'update']);
        Route::delete('/{id}', [RefundController::class, 'destroy']);
    });
});
```

### Admin Routes

```php
Route::middleware(['auth:sanctum', 'role:admin'])->prefix('admin')->group(function () {
    Route::prefix('refunds')->group(function () {
        Route::get('/', [Admin\RefundController::class, 'index']);
        Route::get('/stats', [Admin\RefundController::class, 'getStats']);
        Route::post('/bulk-process', [Admin\RefundController::class, 'bulkProcess']);
        Route::get('/{id}', [Admin\RefundController::class, 'show']);
        Route::post('/{id}/approve', [Admin\RefundController::class, 'approve']);
        Route::post('/{id}/reject', [Admin\RefundController::class, 'reject']);
        Route::post('/{id}/process', [Admin\RefundController::class, 'process']);
    });
});
```

## Validation

### RefundRequest

```php
class RefundRequest extends FormRequest
{
    public function rules(): array
    {
        return [
            'payment_id' => ['required', 'exists:payments,id'],
            'reason' => ['required', 'string', 'max:500'],
            'refund_method' => ['nullable', 'in:bank_transfer,cash,credit'],
            'notes' => ['nullable', 'string', 'max:500'],
        ];
    }
}
```

## Testing

### Test Structure

```
tests/Feature/RefundTest.php
├── User Tests (10/18 passing)
│   ├── ✅ test_user_can_create_refund_request
│   ├── ✅ test_user_cannot_create_refund_for_unverified_payment
│   ├── ✅ test_user_cannot_create_refund_for_completed_booking
│   ├── ✅ test_user_cannot_create_duplicate_refund_request
│   ├── ✅ test_user_can_view_their_refund_history
│   ├── ✅ test_user_can_filter_refunds_by_status
│   ├── ✅ test_user_can_update_pending_refund
│   ├── ✅ test_user_can_cancel_pending_refund
│   ├── ✅ test_refund_validation_works_correctly
│   └── ✅ test_refund_reference_is_auto_generated
├── Admin Tests (8/18 failing - role system issue)
│   ├── ❌ test_admin_can_approve_refund_request
│   ├── ❌ test_admin_can_reject_refund_request
│   ├── ❌ test_admin_can_process_approved_refund
│   ├── ❌ test_admin_can_view_all_refunds
│   ├── ❌ test_admin_can_get_refund_statistics
│   ├── ❌ test_admin_can_bulk_process_refunds
│   ├── ❌ test_user_cannot_update_approved_refund
│   └── ❌ test_refund_calculation_based_on_cancellation_time
```

### Running Tests

```bash
# Run all refund tests
php artisan test tests/Feature/RefundTest.php

# Run specific test
php artisan test --filter="test_user_can_create_refund_request"

# Run with coverage
php artisan test tests/Feature/RefundTest.php --coverage

# Use custom test script
./scripts/test-refund-system.sh
```

## Factory & Seeding

### RefundFactory

```php
class RefundFactory extends Factory
{
    public function definition(): array
    {
        return [
            'payment_id' => Payment::factory(),
            'booking_id' => Booking::factory(),
            'amount' => $this->faker->randomFloat(2, 25000, 500000),
            'reason' => $this->faker->randomElement([
                'Change of plans',
                'Emergency situation',
                'Medical reasons',
                'Weather conditions',
                'Double booking',
            ]),
            'status' => 'pending',
            'requested_by' => User::factory(),
            'refund_method' => $this->faker->randomElement(['bank_transfer', 'cash', 'credit']),
            'refund_reference' => 'REF' . now()->format('Ymd') . str_pad(rand(1, 9999), 4, '0', STR_PAD_LEFT),
        ];
    }

    // States
    public function pending(): static
    public function approved(): static
    public function rejected(): static
    public function processed(): static
}
```

## Integration Points

### Payment System Integration

```php
// In RefundService::createRefundRequest()
$payment->update(['status' => 'refunded']);
$booking->update(['payment_status' => 'refunded']);
```

### Booking System Integration

```php
// In BookingService::processRefund()
$refundService = app(RefundService::class);
$refundService->createRefundRequest($refundData);
```

## Known Issues & Solutions

### 1. Role System Issue (Admin Endpoints)

**Problem**: Admin endpoints mendapat 403 Forbidden

```
Expected response status code [200] but received 403
```

**Analysis**:

-   Admin user tidak memiliki role yang benar
-   Role system mungkin tidak ter-setup dengan benar
-   Middleware `role:admin` tidak berfungsi

**Solutions**:

1. Fix role system setup
2. Ensure admin roles are seeded properly
3. Check middleware configuration
4. Verify user-role relationships

### 2. Refund Calculation Edge Cases

**Problem**: Refund calculation tidak akurat

```
Failed asserting that '100000.00' matches expected 75000
```

**Analysis**:

-   Edge cases dalam perhitungan waktu
-   Time zone issues
-   Business logic edge cases

**Solutions**:

1. Review calculation logic
2. Add more test cases
3. Handle time zone properly
4. Add logging for debugging

### 3. Duplicate Detection Logic

**Problem**: Duplicate refund detection tidak bekerja optimal

**Solutions**:

1. Improve validation logic
2. Add database constraints
3. Better error handling

## Development Workflow

### Adding New Features

1. **Update Models**: Add relationships and attributes
2. **Update Migrations**: Add database changes
3. **Update Service**: Add business logic
4. **Update Controllers**: Add API endpoints
5. **Update Routes**: Register new routes
6. **Add Validation**: Create/update request classes
7. **Write Tests**: Add comprehensive tests
8. **Update Documentation**: Update API docs

### Code Standards

-   Follow PSR-12 coding standards
-   Use type hints and return types
-   Write comprehensive tests
-   Add proper error handling
-   Include logging for debugging
-   Use database transactions for data consistency

## Performance Considerations

1. **Database Queries**: Use eager loading for relationships
2. **Caching**: Cache refund statistics and analytics
3. **Pagination**: Always paginate list endpoints
4. **Indexing**: Add proper database indexes
5. **Background Jobs**: Use queues for heavy operations

## Security Considerations

1. **Authorization**: Proper role-based access control
2. **Validation**: Strict input validation
3. **Rate Limiting**: Prevent abuse
4. **Audit Logging**: Track all refund operations
5. **Data Sanitization**: Clean user inputs

## Deployment Checklist

-   [ ] Database migrations applied
-   [ ] Roles and permissions seeded
-   [ ] Environment variables configured
-   [ ] Tests passing (minimum 90%)
-   [ ] Documentation updated
-   [ ] Performance tested
-   [ ] Security reviewed
-   [ ] Monitoring configured

## Monitoring & Logging

### Key Metrics

-   Refund request volume
-   Processing time
-   Success/failure rates
-   User satisfaction

### Log Events

-   Refund request created
-   Refund approved/rejected
-   Refund processed
-   Errors and exceptions

## Future Enhancements

1. **Automated Refunds**: Auto-approve based on criteria
2. **Partial Refunds**: Support for partial refund amounts
3. **Refund Notifications**: Email/SMS notifications
4. **Analytics Dashboard**: Advanced reporting
5. **Integration**: Payment gateway integration
6. **Workflow**: Advanced approval workflows
