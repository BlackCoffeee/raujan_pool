# Capacity Management Testing Guide

## Overview

Dokumentasi ini menjelaskan cara melakukan testing untuk Capacity Management System, termasuk unit tests, feature tests, dan API testing.

## Test Structure

### Unit Tests

-   `tests/Unit/CapacityServiceTest.php` - Test business logic
-   `tests/Unit/CapacityQueueTest.php` - Test model functionality
-   `tests/Unit/ProcessCapacityQueueJobTest.php` - Test job processing

### Feature Tests

-   `tests/Feature/CapacityManagementTest.php` - Test complete workflows
-   `tests/Feature/CapacityControllerTest.php` - Test API endpoints

## Running Tests

### Run All Capacity Tests

```bash
# Run all capacity management tests
php artisan test --filter=Capacity

# Run specific test file
php artisan test tests/Feature/CapacityManagementTest.php

# Run with coverage
php artisan test --coverage --filter=Capacity
```

### Run Individual Test Groups

```bash
# Unit tests only
php artisan test tests/Unit/ --filter=Capacity

# Feature tests only
php artisan test tests/Feature/ --filter=Capacity

# Specific test
php artisan test --filter="can check capacity availability"
```

## Test Data Setup

### Database Seeding

```bash
# Seed test data
php artisan db:seed --class=CapacityTestSeeder

# Fresh migration with seeding
php artisan migrate:fresh --seed
```

### Factory Usage

```php
// Create test session
$session = Session::factory()->create([
    'max_capacity' => 10,
    'is_active' => true
]);

// Create test user
$user = User::factory()->create();

// Create test queue entry
$queueEntry = CapacityQueue::factory()->pending()->create([
    'session_id' => $session->id,
    'user_id' => $user->id,
    'priority' => 1
]);
```

## Test Scenarios

### 1. Capacity Availability Tests

```php
it('can check capacity availability', function () {
    $session = Session::factory()->create(['max_capacity' => 10]);
    $date = now()->addDay()->format('Y-m-d');

    // Create calendar availability
    CalendarAvailability::factory()->create([
        'session_id' => $session->id,
        'date' => $date,
        'available_slots' => 10,
        'is_available' => true
    ]);

    $result = $this->capacityService->checkCapacity($session->id, $date, 5);

    expect($result['available'])->toBeTrue();
    expect($result['available_slots'])->toBe(10);
});
```

### 2. Queue Management Tests

```php
it('can add to capacity queue', function () {
    $session = Session::factory()->create(['max_capacity' => 5]);
    $user = User::factory()->create();
    $date = now()->addDay()->format('Y-m-d');

    // Fill capacity first
    Booking::factory()->create([
        'session_id' => $session->id,
        'booking_date' => $date,
        'adult_count' => 3,
        'child_count' => 0,
        'status' => 'confirmed'
    ]);

    $queueEntry = $this->capacityService->addToQueue(
        $session->id,
        $date,
        2,
        $user->id,
        null,
        'regular'
    );

    expect($queueEntry)->toBeInstanceOf(CapacityQueue::class);
    expect($queueEntry->status)->toBe('pending');
});
```

### 3. Priority Calculation Tests

```php
it('calculates priority correctly', function () {
    $session = Session::factory()->create(['max_capacity' => 5, 'is_active' => true]);
    $user1 = User::factory()->create();
    $user2 = User::factory()->create();
    $date = now()->addDay()->format('Y-m-d');

    // Create calendar availability
    CalendarAvailability::factory()->create([
        'session_id' => $session->id,
        'date' => $date,
        'available_slots' => 5,
        'is_available' => true
    ]);

    // Regular booking
    $regularQueue = $this->capacityService->addToQueue(
        $session->id, $date, 1, $user1->id, null, 'regular'
    );

    // Private gold booking
    $goldQueue = $this->capacityService->addToQueue(
        $session->id, $date, 1, $user2->id, null, 'private_gold'
    );

    expect($goldQueue->priority)->toBeGreaterThan($regularQueue->priority);
});
```

### 4. Analytics Tests

```php
it('can get capacity analytics', function () {
    $session = Session::factory()->create(['max_capacity' => 10]);

    // Create test bookings
    Booking::factory()->count(5)->create([
        'session_id' => $session->id,
        'adult_count' => 2,
        'child_count' => 1
    ]);

    $analytics = $this->capacityService->getCapacityAnalytics($session->id);

    expect($analytics['session_id'])->toBe($session->id);
    expect($analytics['capacity_stats'])->toHaveKey('max_capacity');
    expect($analytics['capacity_stats'])->toHaveKey('average_utilization');
});
```

## API Testing

### Using Test Script

```bash
# Run API tests
./scripts/test-capacity-management.sh --token your_token_here

# Run with custom URL
./scripts/test-capacity-management.sh --token your_token_here --url https://api.example.com/api/v1
```

### Manual API Testing

```bash
# Check capacity
curl -X POST "http://localhost:8000/api/v1/capacity/check" \
  -H "Authorization: Bearer {token}" \
  -H "Content-Type: application/json" \
  -d '{
    "session_id": 1,
    "date": "2025-09-01",
    "requested_slots": 2
  }'

# Add to queue
curl -X POST "http://localhost:8000/api/v1/capacity/queue" \
  -H "Authorization: Bearer {token}" \
  -H "Content-Type: application/json" \
  -d '{
    "session_id": 1,
    "date": "2025-09-01",
    "requested_slots": 2,
    "user_id": 1,
    "booking_type": "regular"
  }'
```

### Postman Collection

Import file `docs/postman/capacity-management.json` ke Postman untuk testing yang lebih mudah.

## Performance Testing

### Load Testing

```php
it('handles high load queue processing', function () {
    $session = Session::factory()->create(['max_capacity' => 100]);
    $date = now()->addDay()->format('Y-m-d');

    // Create 50 queue entries
    CapacityQueue::factory()->count(50)->create([
        'session_id' => $session->id,
        'date' => $date,
        'status' => 'pending'
    ]);

    $startTime = microtime(true);
    $this->capacityService->processQueue($session->id, $date);
    $endTime = microtime(true);

    $executionTime = $endTime - $startTime;
    expect($executionTime)->toBeLessThan(5.0); // Should complete within 5 seconds
});
```

### Memory Testing

```php
it('does not leak memory during queue processing', function () {
    $session = Session::factory()->create(['max_capacity' => 50]);
    $date = now()->addDay()->format('Y-m-d');

    $initialMemory = memory_get_usage();

    // Process large queue
    for ($i = 0; $i < 100; $i++) {
        $this->capacityService->processQueue($session->id, $date);
    }

    $finalMemory = memory_get_usage();
    $memoryIncrease = $finalMemory - $initialMemory;

    expect($memoryIncrease)->toBeLessThan(10 * 1024 * 1024); // Less than 10MB increase
});
```

## Integration Testing

### Database Integration

```php
it('maintains data consistency during queue processing', function () {
    $session = Session::factory()->create(['max_capacity' => 10]);
    $date = now()->addDay()->format('Y-m-d');

    // Create queue entries
    $queueEntries = CapacityQueue::factory()->count(5)->create([
        'session_id' => $session->id,
        'date' => $date,
        'status' => 'pending'
    ]);

    // Process queue
    $this->capacityService->processQueue($session->id, $date);

    // Verify data consistency
    $completedEntries = CapacityQueue::where('session_id', $session->id)
        ->where('status', 'completed')
        ->count();

    $createdBookings = Booking::where('session_id', $session->id)
        ->where('booking_date', $date)
        ->count();

    expect($completedEntries)->toBe($createdBookings);
});
```

### Real-time Integration

```php
it('broadcasts capacity updates', function () {
    Event::fake();

    $session = Session::factory()->create(['max_capacity' => 10]);
    $date = now()->addDay()->format('Y-m-d');

    // Add to queue
    $this->capacityService->addToQueue($session->id, $date, 2, 1, null, 'regular');

    // Verify event was broadcast
    Event::assertDispatched(CapacityUpdated::class);
});
```

## Test Data Management

### Test Database

```bash
# Use separate test database
DB_CONNECTION=sqlite
DB_DATABASE=:memory:

# Or use dedicated test database
DB_CONNECTION=mysql
DB_DATABASE=raujan_pool_test
```

### Test Isolation

```php
// Each test runs in transaction
use Illuminate\Foundation\Testing\RefreshDatabase;

uses(RefreshDatabase::class);

// Or use database transactions
use Illuminate\Foundation\Testing\DatabaseTransactions;

uses(DatabaseTransactions::class);
```

## Debugging Tests

### Enable Query Logging

```php
it('can debug database queries', function () {
    DB::enableQueryLog();

    $this->capacityService->getCapacityAnalytics(1);

    $queries = DB::getQueryLog();
    dump($queries);

    expect($queries)->toHaveCount(3); // Expected number of queries
});
```

### Debug Test Data

```php
it('can debug test data', function () {
    $session = Session::factory()->create();

    // Debug created data
    dump($session->toArray());

    // Debug relationships
    dump($session->capacityQueues->toArray());
});
```

## Continuous Integration

### GitHub Actions

```yaml
# .github/workflows/capacity-tests.yml
name: Capacity Management Tests

on: [push, pull_request]

jobs:
    test:
        runs-on: ubuntu-latest

        steps:
            - uses: actions/checkout@v2

            - name: Setup PHP
              uses: shivammathur/setup-php@v2
              with:
                  php-version: "8.1"
                  extensions: mbstring, dom, fileinfo, mysql

            - name: Install dependencies
              run: composer install --no-progress --prefer-dist --optimize-autoloader

            - name: Run tests
              run: php artisan test --filter=Capacity --coverage

            - name: Upload coverage
              uses: codecov/codecov-action@v1
```

### Test Reports

```bash
# Generate test report
php artisan test --filter=Capacity --coverage-html=coverage

# Generate JUnit report
php artisan test --filter=Capacity --log-junit=junit.xml
```

## Best Practices

1. **Test Isolation**: Each test should be independent
2. **Realistic Data**: Use factories to create realistic test data
3. **Edge Cases**: Test boundary conditions and error scenarios
4. **Performance**: Monitor test execution time
5. **Coverage**: Aim for high test coverage
6. **Documentation**: Document complex test scenarios
7. **Maintenance**: Keep tests updated with code changes
8. **CI/CD**: Integrate tests into deployment pipeline
