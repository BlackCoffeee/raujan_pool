# Payment Analytics Testing Guide

## Overview

Dokumen ini menjelaskan cara melakukan testing untuk Payment Analytics API, termasuk unit tests, feature tests, dan manual testing.

## Test Structure

### 1. Unit Tests

Unit tests untuk Payment Analytics berada di `tests/Feature/PaymentAnalyticsTest.php` dan mencakup:

- **AnalyticsService Tests**: Testing business logic service
- **PaymentRepository Tests**: Testing data access layer
- **Controller Tests**: Testing API endpoints
- **Filter Tests**: Testing berbagai filter dan parameter

### 2. Test Coverage

Test coverage mencakup:

- ✅ Payment Analytics endpoints
- ✅ Revenue Analytics
- ✅ Payment Method Analytics
- ✅ Performance Metrics
- ✅ Payment Trends
- ✅ Report Generation
- ✅ Data Export (CSV/JSON)
- ✅ Dashboard Data
- ✅ Filtering capabilities
- ✅ Error handling

## Running Tests

### Run All Payment Analytics Tests

```bash
php artisan test tests/Feature/PaymentAnalyticsTest.php
```

### Run Specific Test Group

```bash
# Test analytics service
php artisan test tests/Feature/PaymentAnalyticsTest.php --filter="Payment Analytics"

# Test specific method
php artisan test tests/Feature/PaymentAnalyticsTest.php --filter="it can get payment analytics"
```

### Run with Coverage Report

```bash
php artisan test tests/Feature/PaymentAnalyticsTest.php --coverage
```

## Test Data Setup

### Database Seeding

Sebelum menjalankan tests, pastikan database sudah di-seed:

```bash
php artisan migrate:fresh --seed
```

### Factory Data

Tests menggunakan Laravel factories untuk membuat data test:

```php
// Create test payments
Payment::factory()->count(5)->create([
    'status' => 'verified',
    'amount' => 100000,
    'payment_method' => 'manual_transfer'
]);

// Create test user
$user = User::factory()->create();
$user->assignRole('admin');
```

## Test Scenarios

### 1. Basic Analytics Tests

```php
it('can get payment analytics', function () {
    $analytics = $this->analyticsService->getPaymentAnalytics();
    
    expect($analytics)->toHaveKey('payment_stats');
    expect($analytics)->toHaveKey('revenue_stats');
    expect($analytics)->toHaveKey('payment_method_stats');
});
```

### 2. Filter Tests

```php
it('can filter analytics by date range', function () {
    $filters = [
        'start_date' => '2024-01-01',
        'end_date' => '2024-12-31'
    ];
    
    $analytics = $this->analyticsService->getPaymentAnalytics($filters);
    
    expect($analytics['payment_stats']['total_payments'])->toBeGreaterThan(0);
});
```

### 3. Export Tests

```php
it('can export payment data as CSV', function () {
    $csvData = $this->analyticsService->exportPaymentData([], 'csv');
    
    expect($csvData)->toContain('id,reference_number,user_name');
    expect($csvData)->toContain('1,');
});
```

## Manual Testing

### 1. Using Postman

Import collection berikut ke Postman:

```json
{
    "info": {
        "name": "Payment Analytics API",
        "schema": "https://schema.getpostman.com/json/collection/v2.1.0/collection.json"
    },
    "item": [
        {
            "name": "Get Payment Analytics",
            "request": {
                "method": "GET",
                "header": [
                    {
                        "key": "Authorization",
                        "value": "Bearer {{admin_token}}",
                        "type": "text"
                    }
                ],
                "url": {
                    "raw": "{{base_url}}/api/v1/admin/payment-analytics/payments",
                    "host": ["{{base_url}}"],
                    "path": ["api", "v1", "admin", "payment-analytics", "payments"]
                }
            }
        }
    ]
}
```

### 2. Using cURL

```bash
# Get payment analytics
curl -X GET "http://localhost:8000/api/v1/admin/payment-analytics/payments" \
  -H "Authorization: Bearer {token}" \
  -H "Accept: application/json"

# Get revenue analytics with filters
curl -X GET "http://localhost:8000/api/v1/admin/payment-analytics/revenue?start_date=2024-01-01&end_date=2024-12-31" \
  -H "Authorization: Bearer {token}" \
  -H "Accept: application/json"

# Export as CSV
curl -X GET "http://localhost:8000/api/v1/admin/payment-analytics/export?format=csv" \
  -H "Authorization: Bearer {token}" \
  -H "Accept: text/csv" \
  -o payment_data.csv
```

### 3. Using Testing Script

Gunakan script testing yang sudah disediakan:

```bash
# Make script executable
chmod +x scripts/test-payment-analytics.sh

# Run tests
./scripts/test-payment-analytics.sh
```

## Test Environment Setup

### 1. Environment Variables

Pastikan file `.env.testing` sudah dikonfigurasi:

```env
DB_CONNECTION=sqlite
DB_DATABASE=:memory:
CACHE_DRIVER=array
QUEUE_CONNECTION=sync
```

### 2. Test Database

Tests menggunakan SQLite in-memory database untuk performa:

```php
// phpunit.xml
<php>
    <env name="DB_CONNECTION" value="sqlite"/>
    <env name="DB_DATABASE" value=":memory:"/>
</php>
```

## Common Test Issues

### 1. SQLite Limitations

SQLite tidak mendukung beberapa fungsi MySQL:

```php
// ❌ Not supported in SQLite
->selectRaw('YEAR(created_at) as year')

// ✅ Use Carbon instead
$payments->groupBy(function ($payment) {
    return $payment->created_at->format('Y');
})
```

### 2. Authentication Issues

Pastikan user test memiliki role yang tepat:

```php
beforeEach(function () {
    $this->user = User::factory()->create();
    $this->adminRole = Role::where('name', 'admin')->first();
    $this->user->assignRole($this->adminRole);
});
```

### 3. Data Consistency

Pastikan data test konsisten:

```php
// Create related data
$user = User::factory()->create();
$booking = Booking::factory()->create(['user_id' => $user->id]);
$payment = Payment::factory()->create([
    'user_id' => $user->id,
    'booking_id' => $booking->id
]);
```

## Performance Testing

### 1. Load Testing

Test dengan data besar:

```php
it('can handle large datasets', function () {
    // Create 1000 payments
    Payment::factory()->count(1000)->create();
    
    $startTime = microtime(true);
    $analytics = $this->analyticsService->getPaymentAnalytics();
    $endTime = microtime(true);
    
    $executionTime = $endTime - $startTime;
    expect($executionTime)->toBeLessThan(2.0); // Should complete in < 2 seconds
});
```

### 2. Memory Testing

Monitor memory usage:

```php
it('does not exceed memory limit', function () {
    $initialMemory = memory_get_usage();
    
    Payment::factory()->count(5000)->create();
    $analytics = $this->analyticsService->getPaymentAnalytics();
    
    $finalMemory = memory_get_usage();
    $memoryIncrease = $finalMemory - $initialMemory;
    
    expect($memoryIncrease)->toBeLessThan(50 * 1024 * 1024); // < 50MB
});
```

## Integration Testing

### 1. API Integration

Test dengan real HTTP requests:

```php
it('returns correct HTTP status codes', function () {
    $response = $this->actingAs($this->user)
        ->getJson('/api/v1/admin/payment-analytics/payments');
    
    $response->assertStatus(200);
    $response->assertJsonStructure([
        'success',
        'message',
        'data' => [
            'payment_stats',
            'revenue_stats'
        ]
    ]);
});
```

### 2. Database Integration

Test database transactions:

```php
it('maintains data integrity', function () {
    DB::beginTransaction();
    
    try {
        $payment = Payment::factory()->create(['amount' => 100000]);
        $analytics = $this->analyticsService->getPaymentAnalytics();
        
        expect($analytics['payment_stats']['total_amount'])->toBe(100000);
        
        DB::rollBack();
    } catch (Exception $e) {
        DB::rollBack();
        throw $e;
    }
});
```

## Test Maintenance

### 1. Regular Updates

Update tests ketika ada perubahan:

- API endpoint changes
- Business logic modifications
- Database schema updates

### 2. Test Data Cleanup

Pastikan test data dibersihkan:

```php
afterEach(function () {
    // Clean up test data
    Payment::query()->delete();
    User::query()->delete();
    Booking::query()->delete();
});
```

### 3. Test Documentation

Update dokumentasi ketika ada perubahan:

- New test scenarios
- Updated test data requirements
- Changed test environment setup

## Troubleshooting

### Common Errors

1. **"Call to undefined function actingAs()"**
   - Solution: Use `actingAs()` only in feature tests, not unit tests

2. **"SQLSTATE[HY000]: General error: 1 no such function: YEAR"**
   - Solution: Replace MySQL functions with Carbon date formatting

3. **"Failed asserting that 0 is greater than 0"**
   - Solution: Check test data setup and relationships

### Debug Tips

1. **Enable SQL Logging**
   ```php
   DB::enableQueryLog();
   // ... test code ...
   dd(DB::getQueryLog());
   ```

2. **Check Test Data**
   ```php
   dd(Payment::count(), User::count());
   ```

3. **Verify Relationships**
   ```php
   dd($user->payments()->count());
   ```

## Best Practices

1. **Test Isolation**: Setiap test harus independen
2. **Meaningful Names**: Gunakan nama test yang deskriptif
3. **Data Factory**: Gunakan factories untuk test data
4. **Assertions**: Test satu aspek per test
5. **Cleanup**: Bersihkan data setelah setiap test
6. **Performance**: Test harus berjalan cepat (< 1 detik per test)

## Resources

- [Laravel Testing Documentation](https://laravel.com/docs/11.x/testing)
- [Pest Testing Framework](https://pestphp.com/)
- [Laravel Database Testing](https://laravel.com/docs/11.x/testing#database-testing)
- [API Testing Best Practices](https://laravel.com/docs/11.x/testing#testing-apis)
