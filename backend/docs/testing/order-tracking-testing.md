# Order Tracking Testing Documentation

## Overview

Dokumentasi ini menjelaskan cara melakukan testing untuk Order Tracking System yang telah diimplementasikan.

## Prerequisites

Pastikan environment testing sudah siap:

-   Database testing sudah dikonfigurasi
-   Factory classes sudah dibuat
-   Migration sudah dijalankan

## Running Tests

### 1. Run All Order Tracking Tests

```bash
php artisan test --filter="OrderTracking"
```

### 2. Run Specific Test Files

```bash
# Feature tests
php artisan test tests/Feature/OrderTrackingTest.php

# Unit tests
php artisan test tests/Unit/OrderTrackingServiceTest.php

# Simple tests
php artisan test tests/Feature/OrderTrackingSimpleTest.php
```

### 3. Run Tests with Coverage

```bash
php artisan test --coverage --filter="OrderTracking"
```

## Test Structure

### Feature Tests (`tests/Feature/OrderTrackingTest.php`)

-   **Order Status Tracking**: Test untuk tracking status pesanan
-   **Order Timeline**: Test untuk timeline pesanan
-   **Order Feedback**: Test untuk feedback pesanan
-   **Order Analytics**: Test untuk analytics pesanan

### Unit Tests (`tests/Unit/OrderTrackingServiceTest.php`)

-   **Service Methods**: Test untuk semua method di OrderTrackingService
-   **Business Logic**: Test untuk business logic tracking
-   **Data Validation**: Test untuk validasi data

### Simple Tests (`tests/Feature/OrderTrackingSimpleTest.php`)

-   **Basic Functionality**: Test untuk fungsi dasar
-   **Model Relationships**: Test untuk relasi model
-   **Database Operations**: Test untuk operasi database

## Test Data

### Factory Usage

```php
// Create order with tracking
$order = Order::factory()->create(['status' => 'pending']);
$tracking = OrderTracking::factory()->create(['order_id' => $order->id]);

// Create feedback
$feedback = OrderFeedback::factory()->create(['order_id' => $order->id]);
```

### Test Scenarios

1. **Order Creation**: Test pembuatan pesanan baru
2. **Status Updates**: Test update status pesanan
3. **Timeline Generation**: Test pembuatan timeline
4. **Feedback Submission**: Test submit feedback
5. **Analytics Generation**: Test pembuatan analytics

## Expected Results

### Successful Tests

-   ✅ Order tracking records created
-   ✅ Timeline generated correctly
-   ✅ Feedback submitted successfully
-   ✅ Analytics calculated properly
-   ✅ Notifications sent

### Error Handling

-   ❌ Invalid order ID
-   ❌ Duplicate feedback
-   ❌ Invalid status transitions
-   ❌ Missing required fields

## Troubleshooting

### Common Issues

1. **Foreign Key Constraints**

    - Pastikan user dan order sudah dibuat sebelum tracking
    - Gunakan factory yang benar

2. **Database Connection**

    - Pastikan database testing sudah dikonfigurasi
    - Jalankan migration testing

3. **Factory Dependencies**
    - Pastikan semua factory dependencies sudah ada
    - Update factory jika diperlukan

### Debug Commands

```bash
# Check database status
php artisan migrate:status

# Reset database
php artisan migrate:fresh --seed

# Check test database
php artisan tinker
>>> DB::connection()->getDatabaseName()
```

## Performance Testing

### Load Testing

```bash
# Test dengan banyak data
php artisan test --filter="OrderTracking" --repeat=10
```

### Memory Usage

```bash
# Monitor memory usage
php artisan test --filter="OrderTracking" --memory
```

## Continuous Integration

### GitHub Actions

```yaml
name: Order Tracking Tests
on: [push, pull_request]
jobs:
    test:
        runs-on: ubuntu-latest
        steps:
            - uses: actions/checkout@v2
            - name: Setup PHP
              uses: shivammathur/setup-php@v2
              with:
                  php-version: "8.2"
            - name: Install dependencies
              run: composer install
            - name: Run tests
              run: php artisan test --filter="OrderTracking"
```

## Test Reports

### Coverage Report

```bash
php artisan test --coverage --filter="OrderTracking" --coverage-html=coverage
```

### JUnit Report

```bash
php artisan test --filter="OrderTracking" --junit=test-results.xml
```

## Best Practices

1. **Test Isolation**: Setiap test harus independen
2. **Data Cleanup**: Bersihkan data setelah test
3. **Assertions**: Gunakan assertions yang tepat
4. **Mocking**: Mock external dependencies
5. **Coverage**: Target coverage > 90%

## Maintenance

### Regular Updates

-   Update tests ketika ada perubahan business logic
-   Review test coverage secara berkala
-   Update factory data sesuai kebutuhan

### Test Data Management

-   Gunakan factory untuk data konsisten
-   Clean up test data setelah test
-   Monitor test performance
