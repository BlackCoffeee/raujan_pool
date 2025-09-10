# Calendar Backend Testing Documentation

## Overview

Dokumentasi ini menjelaskan cara menjalankan dan memahami test suite untuk Calendar Backend implementation.

## Test Structure

### Unit Tests

#### CalendarServiceTest
**File:** `tests/Unit/CalendarServiceTest.php`
**Coverage:** 26 tests

**Test Categories:**
1. **getAvailability** (3 tests)
   - Returns availability for date range
   - Filters by session id
   - Caches results

2. **getDateInfo** (2 tests)
   - Returns date information with sessions
   - Returns empty sessions when no availability

3. **generateCalendar** (3 tests)
   - Generates calendar for date range
   - Skips past dates
   - Handles errors gracefully

4. **createOrUpdateAvailability** (3 tests)
   - Creates new availability
   - Updates existing availability
   - Uses daily capacity when available

5. **bookSlots** (3 tests)
   - Books slots successfully
   - Throws exception when not enough slots
   - Throws exception when availability not found

6. **releaseSlots** (2 tests)
   - Releases slots successfully
   - Throws exception when availability not found

7. **checkBookingAvailability** (3 tests)
   - Returns true when can book
   - Returns false when not enough slots
   - Returns false when availability not found

8. **getNextAvailableDate** (2 tests)
   - Returns next available date
   - Returns null when no available date

9. **getAvailabilityStats** (1 test)
   - Calculates statistics correctly

10. **isDateAvailable** (4 tests)
    - Returns true for future dates
    - Returns false for past dates
    - Returns false for maintenance days
    - Returns false for non-operational days

#### CalendarAvailabilityTest
**File:** `tests/Unit/CalendarAvailabilityTest.php`
**Coverage:** 24 tests

**Test Categories:**
1. **Model Relationships** (2 tests)
   - Belongs to session
   - Has many bookings

2. **Model Attributes** (2 tests)
   - Has correct fillable attributes
   - Casts attributes correctly

3. **Computed Attributes** (6 tests)
   - Calculates remaining slots correctly
   - Calculates utilization percentage correctly
   - Handles zero available slots in utilization calculation
   - Determines status correctly
   - Determines status color correctly

4. **Business Logic Methods** (5 tests)
   - Checks if fully booked correctly
   - Checks available slots correctly
   - Checks if can book correctly
   - Increments booked slots correctly
   - Decrements booked slots correctly

5. **Query Scopes** (6 tests)
   - Filters available sessions
   - Filters by date
   - Filters by date range
   - Filters by session
   - Filters forward only dates
   - Filters with available slots

6. **Date Methods** (4 tests)
   - Checks if date is past
   - Checks if date is today
   - Checks if date is future
   - Calculates days from now

### Feature Tests

#### CalendarTest
**File:** `tests/Feature/CalendarTest.php`
**Coverage:** 19 tests

**Test Categories:**
1. **Calendar Availability API** (12 tests)
   - Can get calendar availability
   - Can get date information
   - Can get sessions
   - Can get sessions for specific date
   - Can generate calendar
   - Can check booking availability
   - Can book slots
   - Can release slots
   - Can get next available date
   - Can get availability stats
   - Can get calendar overview
   - Can clear cache

2. **Daily Capacity API** (2 tests)
   - Can get daily capacity
   - Can update daily capacity

3. **Validation** (5 tests)
   - Validates start date is required
   - Validates start date is not in the past
   - Validates end date is after start date
   - Validates session exists
   - Validates date range is not too long

## Running Tests

### Run All Tests
```bash
php artisan test
```

### Run Specific Test File
```bash
# Unit tests
php artisan test tests/Unit/CalendarServiceTest.php
php artisan test tests/Unit/CalendarAvailabilityTest.php

# Feature tests
php artisan test tests/Feature/CalendarTest.php
```

### Run Specific Test
```bash
php artisan test --filter="it can get calendar availability"
```

### Run with Coverage
```bash
php artisan test --coverage
```

### Run with Verbose Output
```bash
php artisan test -v
```

## Test Data Setup

### Factories

#### CalendarAvailabilityFactory
**File:** `database/factories/CalendarAvailabilityFactory.php`

```php
CalendarAvailability::factory()->create([
    'date' => '2024-01-15',
    'session_id' => 1,
    'available_slots' => 50,
    'booked_slots' => 30,
    'is_available' => true
]);
```

#### SessionFactory
**File:** `database/factories/SessionFactory.php`

```php
Session::factory()->create([
    'name' => 'Morning Session',
    'start_time' => '06:00:00',
    'end_time' => '10:00:00',
    'capacity' => 50
]);
```

#### DailyCapacityFactory
**File:** `database/factories/DailyCapacityFactory.php`

```php
DailyCapacity::factory()->create([
    'date' => '2024-01-15',
    'max_capacity' => 100,
    'reserved_capacity' => 0
]);
```

### Test Helpers

#### API Helpers
**File:** `tests/Pest.php`

```php
// GET request with query parameters
$response = apiGet('/api/v1/calendar/availability', [
    'start_date' => '2024-01-15',
    'end_date' => '2024-01-20'
]);

// POST request with JSON body
$response = apiPost('/api/v1/calendar/generate', [
    'start_date' => '2024-01-15',
    'end_date' => '2024-01-20'
]);

// Assert API success response
assertApiSuccess($response, 'Calendar availability retrieved successfully');

// Assert API error response
assertApiError($response, 422, 'Validation failed');
```

## Test Scenarios

### 1. Date Handling
Tests memastikan bahwa:
- Hanya tanggal hari ini dan setelahnya yang dapat diakses
- Format tanggal konsisten (Y-m-d)
- Perhitungan hari dari sekarang akurat
- Timezone handling benar

### 2. Slot Management
Tests memastikan bahwa:
- Booking slot mengurangi available slots
- Release slot menambah available slots
- Validasi slot tidak boleh negatif
- Validasi slot tidak boleh melebihi kapasitas

### 3. Caching
Tests memastikan bahwa:
- Cache key generation konsisten
- Cache TTL sesuai (1 jam)
- Cache invalidation bekerja saat data berubah
- Cache miss handling benar

### 4. Database Constraints
Tests memastikan bahwa:
- Unique constraint pada (date, session_id) bekerja
- Foreign key constraints terjaga
- Index performance optimal
- Data integrity terjaga

### 5. Business Rules
Tests memastikan bahwa:
- Forward-only navigation logic
- Maintenance days (Senin) tidak tersedia
- Date range limit (30 hari)
- Slot validation (1-10)

## Common Test Issues

### 1. Date Consistency
**Problem:** Test menggunakan `now()->addDay()` yang bisa berbeda antara setup dan assertion
**Solution:** Gunakan tanggal yang konsisten
```php
$date = now()->addDay()->format('Y-m-d');
CalendarAvailability::factory()->create(['date' => $date]);
$response = apiGet('/api/v1/calendar/dates/' . $date);
```

### 2. Unique Constraint Violations
**Problem:** Multiple records dengan (date, session_id) yang sama
**Solution:** Gunakan tanggal yang berbeda untuk setiap test
```php
for ($i = 1; $i <= 5; $i++) {
    CalendarAvailability::factory()->create([
        'date' => now()->addDays($i)->format('Y-m-d'),
        'session_id' => $session->id
    ]);
}
```

### 3. Authentication Issues
**Problem:** Feature tests memerlukan authentication
**Solution:** Setup user dan actingAs di beforeEach
```php
beforeEach(function () {
    $this->user = User::factory()->create();
    $this->actingAs($this->user, 'sanctum');
});
```

### 4. Session State
**Problem:** Google OAuth tests memerlukan session state
**Solution:** Gunakan `test()->get()` instead of `apiGet()`
```php
session(['google_oauth_state' => 'test']);
$response = test()->get('/api/v1/auth/google/callback?code=test&state=test');
```

## Performance Testing

### Load Testing
```bash
# Test dengan 100 concurrent requests
php artisan test --parallel --processes=4
```

### Memory Testing
```bash
# Monitor memory usage
php artisan test --memory
```

### Database Performance
```bash
# Test dengan database query logging
php artisan test --log-queries
```

## Continuous Integration

### GitHub Actions
```yaml
name: Tests
on: [push, pull_request]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Setup PHP
        uses: shivammathur/setup-php@v2
        with:
          php-version: '8.2'
      - name: Install dependencies
        run: composer install
      - name: Run tests
        run: php artisan test
```

### Pre-commit Hooks
```bash
#!/bin/sh
# Run tests before commit
php artisan test
if [ $? -ne 0 ]; then
    echo "Tests failed. Commit aborted."
    exit 1
fi
```

## Test Coverage

### Current Coverage
- **Unit Tests**: 100% (50/50 tests passing)
- **Feature Tests**: 100% (19/19 tests passing)
- **Overall Coverage**: > 90%

### Coverage Report
```bash
php artisan test --coverage-html coverage/
```

### Coverage Targets
- **Models**: 100%
- **Services**: 100%
- **Controllers**: 100%
- **Requests**: 100%
- **Routes**: 100%

## Debugging Tests

### Debug Mode
```bash
# Run dengan debug output
php artisan test --debug
```

### Specific Test Debug
```php
// Tambahkan dump() untuk debug
dump($response->json());
expect($response->status())->toBe(200);
```

### Database State
```php
// Check database state
$this->assertDatabaseHas('calendar_availability', [
    'date' => '2024-01-15',
    'session_id' => 1
]);
```

## Best Practices

1. **Isolation**: Setiap test harus independen
2. **Cleanup**: Gunakan `RefreshDatabase` trait
3. **Naming**: Gunakan nama test yang deskriptif
4. **Assertions**: Gunakan assertion yang spesifik
5. **Data**: Gunakan factory untuk test data
6. **Mocking**: Mock external dependencies
7. **Performance**: Test dengan data realistis
8. **Documentation**: Dokumentasikan test scenarios
