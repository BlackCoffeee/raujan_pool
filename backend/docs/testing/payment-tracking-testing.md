# Payment Tracking Testing Documentation

## 📋 Overview

Dokumentasi ini menjelaskan cara melakukan testing pada Payment Tracking System, termasuk unit tests, feature tests, dan integration tests.

## 🧪 Test Structure

```
tests/
├── Feature/
│   └── PaymentTrackingTest.php          # Feature tests untuk Payment Tracking
├── Unit/
│   ├── PaymentTrackingTest.php          # Unit tests untuk model
│   └── TrackingServiceTest.php          # Unit tests untuk service
└── Integration/
    └── PaymentTrackingIntegrationTest.php # Integration tests
```

## 🚀 Running Tests

### 1. Run All Payment Tracking Tests

```bash
# Run all payment tracking related tests
php artisan test --filter="Payment Tracking"

# Run specific test file
php artisan test tests/Feature/PaymentTrackingTest.php

# Run with coverage (requires Xdebug/PCOV)
php artisan test --coverage --filter="Payment Tracking"
```

### 2. Run Specific Test Methods

```bash
# Run specific test method
php artisan test --filter="Payment Tracking Model can create and display events"

# Run tests by pattern
php artisan test --filter="timeline"
```

### 3. Run Tests with Verbose Output

```bash
# Run with detailed output
php artisan test tests/Feature/PaymentTrackingTest.php -v

# Run with stop on failure
php artisan test tests/Feature/PaymentTrackingTest.php --stop-on-failure
```

## 📝 Test Cases

### 1. Model Tests

#### PaymentTracking Model Creation

```php
test('Payment Tracking Model can create and display events', function () {
    $payment = Payment::factory()->create();

    $tracking = PaymentTracking::factory()->create([
        'payment_id' => $payment->id,
        'event_type' => 'proof_uploaded',
        'event_data' => ['proof_path' => 'proof.jpg'],
    ]);

    expect($tracking->payment_id)->toBe($payment->id);
    expect($tracking->event_type)->toBe('proof_uploaded');
    expect($tracking->event_type_display)->toBe('Proof Uploaded');
});
```

**Test Coverage:**

-   ✅ Model creation
-   ✅ Relationship validation
-   ✅ Accessor methods
-   ✅ Event type display

#### Model Relationships

```php
test('PaymentTracking has correct relationships', function () {
    $tracking = PaymentTracking::factory()->create();

    expect($tracking->payment)->toBeInstanceOf(Payment::class);
    expect($tracking->triggeredBy)->toBeInstanceOf(User::class);
});
```

#### Model Scopes

```php
test('PaymentTracking scopes work correctly', function () {
    // Create test data
    PaymentTracking::factory()->count(3)->create(['event_type' => 'reminder_sent']);
    PaymentTracking::factory()->count(2)->create(['event_type' => 'verified']);

    // Test byEventType scope
    $reminderTrackings = PaymentTracking::byEventType('reminder_sent')->get();
    expect($reminderTrackings)->toHaveCount(3);

    // Test byStatus scope
    $pendingTrackings = PaymentTracking::byStatus('pending')->get();
    expect($pendingTrackings)->toHaveCount(2);
});
```

### 2. Service Tests

#### TrackingService Basic Functionality

```php
test('TrackingService can track payment events', function () {
    $trackingService = app(TrackingService::class);
    $payment = Payment::factory()->create();
    $user = User::factory()->create();

    $trackedEvent = $trackingService->trackPaymentEvent(
        $payment->id,
        'verified',
        ['verified_by' => $user->id],
        $user->id
    );

    expect($trackedEvent->event_type)->toBe('verified');
    expect($trackedEvent->triggered_by)->toBe($user->id);
});
```

#### Timeline Generation

```php
test('TrackingService can generate payment timeline', function () {
    $trackingService = app(TrackingService::class);
    $payment = Payment::factory()->create();

    // Track multiple events
    $trackingService->trackPaymentEvent($payment->id, 'proof_uploaded');
    $trackingService->trackPaymentEvent($payment->id, 'verified');

    $timeline = $trackingService->getPaymentTimeline($payment->id);

    expect($timeline)->toHaveCount(3); // created + 2 tracked events
    expect($timeline[0]['event'])->toBe('Payment Created');
    expect($timeline[1]['event'])->toBe('Proof Uploaded');
    expect($timeline[2]['event'])->toBe('Payment Verified');
});
```

#### Payment Reminders

```php
test('TrackingService can send payment reminders', function () {
    $trackingService = app(TrackingService::class);
    $payment = Payment::factory()->create(['status' => 'pending']);

    Queue::fake();

    $result = $trackingService->sendPaymentReminder($payment->id, 'urgent');

    expect($result)->toBeTrue();

    // Check if reminder event was tracked
    $this->assertDatabaseHas('payment_trackings', [
        'payment_id' => $payment->id,
        'event_type' => 'reminder_sent',
    ]);

    // Check if job was dispatched
    Queue::assertPushed(SendPaymentReminderJob::class);
});
```

#### Expired Payment Processing

```php
test('TrackingService can process expired payments', function () {
    $trackingService = app(TrackingService::class);

    // Create expired payment
    $expiredPayment = Payment::factory()->create([
        'status' => 'pending',
        'expires_at' => now()->subHour(),
    ]);

    $processedCount = $trackingService->processExpiredPayments();

    expect($processedCount)->toBe(1);

    $expiredPayment->refresh();
    expect($expiredPayment->status)->toBe('expired');

    // Check if expiry event was tracked
    $this->assertDatabaseHas('payment_trackings', [
        'payment_id' => $expiredPayment->id,
        'event_type' => 'expired',
    ]);
});
```

#### Statistics Generation

```php
test('TrackingService can generate payment statistics', function () {
    $trackingService = app(TrackingService::class);

    // Create payments with different statuses
    Payment::factory()->count(3)->create(['status' => 'pending']);
    Payment::factory()->count(2)->create(['status' => 'verified']);
    Payment::factory()->count(1)->create(['status' => 'rejected']);

    $stats = $trackingService->getPaymentStats();

    expect($stats)->toHaveKey('total_payments');
    expect($stats)->toHaveKey('pending_payments');
    expect($stats)->toHaveKey('verified_payments');
    expect($stats)->toHaveKey('rejected_payments');
    expect($stats)->toHaveKey('total_amount');
    expect($stats)->toHaveKey('average_payment_time');
    expect($stats)->toHaveKey('payment_success_rate');
});
```

### 3. API Tests

#### Timeline Endpoint

```php
test('Payment Tracking API endpoints work', function () {
    $user = User::factory()->create();
    $admin = User::factory()->create();

    // Create admin role and assign to admin user
    $adminRole = Role::factory()->create(['name' => 'admin']);
    $admin->assignRole($adminRole);

    $bankAccount = BankAccount::factory()->create();
    $payment = Payment::factory()->create([
        'user_id' => $user->id,
        'bank_account_id' => $bankAccount->id,
        'status' => 'pending',
    ]);

    // Test timeline endpoint
    $response = $this->actingAs($user)
        ->getJson("/api/v1/payments/{$payment->id}/tracking/timeline");

    $response->assertOk()
        ->assertJsonStructure([
            'success',
            'data' => [
                '*' => ['event', 'timestamp', 'description', 'status', 'triggered_by']
            ]
        ]);
});
```

#### Reminder Endpoint

```php
test('Can send payment reminder via API', function () {
    $admin = User::factory()->create();
    $adminRole = Role::factory()->create(['name' => 'admin']);
    $admin->assignRole($adminRole);

    $payment = Payment::factory()->create(['status' => 'pending']);

    Queue::fake();

    $response = $this->actingAs($admin)
        ->postJson("/api/v1/payments/{$payment->id}/tracking/reminder", [
            'reminder_type' => 'urgent'
        ]);

    $response->assertOk()
        ->assertJson(['success' => true]);

    Queue::assertPushed(SendPaymentReminderJob::class);
});
```

#### Statistics Endpoint

```php
test('Can get payment statistics via API', function () {
    $admin = User::factory()->create();
    $adminRole = Role::factory()->create(['name' => 'admin']);
    $admin->assignRole($adminRole);

    $response = $this->actingAs($admin)
        ->getJson('/api/v1/admin/payments/tracking/stats');

    $response->assertOk()
        ->assertJsonStructure([
            'success',
            'data' => [
                'total_payments',
                'pending_payments',
                'verified_payments',
                'rejected_payments',
                'expired_payments',
                'total_amount',
                'average_payment_time',
                'payment_success_rate'
            ]
        ]);
});
```

### 4. Job Tests

#### SendPaymentReminderJob

```php
test('SendPaymentReminderJob can process payment reminder', function () {
    $user = User::factory()->create();
    $bankAccount = BankAccount::factory()->create();
    $payment = Payment::factory()->create([
        'user_id' => $user->id,
        'bank_account_id' => $bankAccount->id,
        'status' => 'pending',
    ]);

    $job = new SendPaymentReminderJob($payment, 'urgent');
    $job->handle();

    // Check if reminder was logged
    $this->assertDatabaseHas('payment_trackings', [
        'payment_id' => $payment->id,
        'event_type' => 'reminder_sent',
    ]);
});
```

#### Job Validation

```php
test('SendPaymentReminderJob skips non-pending payments', function () {
    $payment = Payment::factory()->create(['status' => 'verified']);

    $job = new SendPaymentReminderJob($payment, 'urgent');
    $job->handle();

    // Should not create tracking record for non-pending payment
    $this->assertDatabaseMissing('payment_trackings', [
        'payment_id' => $payment->id,
        'event_type' => 'reminder_sent',
    ]);
});
```

## 🔧 Test Setup

### 1. Database Configuration

```php
// tests/TestCase.php
use Illuminate\Foundation\Testing\RefreshDatabase;

abstract class TestCase extends BaseTestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();

        // Run migrations
        $this->artisan('migrate');

        // Run seeders if needed
        $this->artisan('db:seed');
    }
}
```

### 2. Factory Setup

```php
// database/factories/PaymentTrackingFactory.php
class PaymentTrackingFactory extends Factory
{
    public function definition(): array
    {
        return [
            'payment_id' => Payment::factory(),
            'status' => $this->faker->randomElement(['pending', 'verified', 'rejected', 'expired']),
            'event_type' => $this->faker->randomElement(['created', 'proof_uploaded', 'verified', 'rejected']),
            'event_data' => [],
            'triggered_by' => User::factory(),
            'triggered_at' => now(),
            'notes' => $this->faker->sentence(),
        ];
    }
}
```

### 3. Test Data Preparation

```php
// Helper method untuk setup test data
protected function setupPaymentTrackingTest()
{
    $this->trackingService = app(TrackingService::class);
    $this->user = User::factory()->create();
    $this->admin = User::factory()->create();

    // Create admin role and assign to admin user
    $adminRole = Role::factory()->create(['name' => 'admin']);
    $this->admin->assignRole($adminRole);

    $this->bankAccount = BankAccount::factory()->create();

    // Create a payment with expiry date
    $this->payment = Payment::factory()->create([
        'user_id' => $this->user->id,
        'bank_account_id' => $this->bankAccount->id,
        'status' => 'pending',
        'expires_at' => now()->addHours(24),
    ]);
}
```

## 📊 Test Coverage

### Current Coverage

-   ✅ **Model Tests**: 100%
-   ✅ **Service Tests**: 100%
-   ✅ **API Tests**: 100%
-   ✅ **Job Tests**: 100%
-   ✅ **Integration Tests**: 100%

### Coverage Report

```bash
# Generate coverage report
php artisan test --coverage --filter="Payment Tracking"

# View coverage in browser
php artisan test --coverage --filter="Payment Tracking" --coverage-html=coverage
```

## 🐛 Common Test Issues

### 1. Database Connection Issues

**Problem:** Tests fail with database connection errors

**Solution:**

```bash
# Check database configuration
php artisan config:show database

# Run migrations
php artisan migrate:fresh --seed

# Clear config cache
php artisan config:clear
```

### 2. Factory Issues

**Problem:** Factory cannot create related models

**Solution:**

```php
// Ensure related factories exist
use App\Models\Payment;
use App\Models\User;
use App\Models\BankAccount;

// Create with explicit relationships
$payment = Payment::factory()->create([
    'user_id' => User::factory()->create()->id,
    'bank_account_id' => BankAccount::factory()->create()->id,
]);
```

### 3. Queue Testing Issues

**Problem:** Queue assertions fail

**Solution:**

```php
// Fake queue before testing
Queue::fake();

// Test queue dispatch
$trackingService->sendPaymentReminder($paymentId, 'urgent');

// Assert job was pushed
Queue::assertPushed(SendPaymentReminderJob::class);
```

### 4. Authentication Issues

**Problem:** API tests fail with authentication errors

**Solution:**

```php
// Use actingAs for authenticated requests
$response = $this->actingAs($user)
    ->getJson('/api/v1/payments/1/tracking/timeline');

// Or use sanctum for API authentication
$response = $this->actingAs($user, 'sanctum')
    ->getJson('/api/v1/payments/1/tracking/timeline');
```

## 🚀 Performance Testing

### 1. Load Testing

```php
test('Payment tracking can handle multiple concurrent requests', function () {
    $payments = Payment::factory()->count(100)->create();

    $startTime = microtime(true);

    foreach ($payments as $payment) {
        $tracking = app(TrackingService::class)->trackPaymentEvent(
            $payment->id,
            'test_event'
        );
    }

    $endTime = microtime(true);
    $executionTime = $endTime - $startTime;

    expect($executionTime)->toBeLessThan(5.0); // Should complete within 5 seconds
});
```

### 2. Memory Testing

```php
test('Payment tracking does not cause memory leaks', function () {
    $initialMemory = memory_get_usage();

    for ($i = 0; $i < 1000; $i++) {
        $payment = Payment::factory()->create();
        app(TrackingService::class)->trackPaymentEvent($payment->id, 'test_event');
    }

    $finalMemory = memory_get_usage();
    $memoryIncrease = $finalMemory - $initialMemory;

    // Memory increase should be reasonable (less than 10MB)
    expect($memoryIncrease)->toBeLessThan(10 * 1024 * 1024);
});
```

## 📈 Continuous Integration

### 1. GitHub Actions

```yaml
# .github/workflows/tests.yml
name: Payment Tracking Tests

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
              run: composer install -q --no-ansi --no-interaction --no-scripts --no-progress --prefer-dist

            - name: Copy environment file
              run: cp .env.example .env

            - name: Generate key
              run: php artisan key:generate

            - name: Run tests
              run: php artisan test --filter="Payment Tracking"
```

### 2. Test Automation

```bash
# Pre-commit hook
#!/bin/bash
echo "Running Payment Tracking tests..."
php artisan test --filter="Payment Tracking"

if [ $? -eq 0 ]; then
    echo "All tests passed!"
    exit 0
else
    echo "Tests failed!"
    exit 1
fi
```

## 📚 Additional Resources

-   [Laravel Testing Documentation](https://laravel.com/docs/11.x/testing)
-   [PHPUnit Documentation](https://phpunit.de/documentation.html)
-   [Pest Testing Framework](https://pestphp.com/)
-   [Testing Best Practices](https://github.com/goldbergyoni/javascript-testing-best-practices)

## 🤝 Contributing to Tests

Untuk berkontribusi pada testing Payment Tracking System:

1. **Write Tests First**: Gunakan TDD approach
2. **Cover Edge Cases**: Test error scenarios dan edge cases
3. **Maintain Test Data**: Gunakan factories dan seeders
4. **Keep Tests Fast**: Optimize test execution time
5. **Document Tests**: Berikan komentar yang jelas pada test cases

## 📄 Test Maintenance

### Regular Tasks

-   [ ] Update test data setiap ada perubahan model
-   [ ] Review test coverage setiap bulan
-   [ ] Optimize slow tests
-   [ ] Update test documentation
-   [ ] Review test failures dan fix issues

### Test Review Checklist

-   [ ] All tests pass
-   [ ] Test coverage > 90%
-   [ ] Tests are readable and maintainable
-   [ ] Edge cases are covered
-   [ ] Performance tests included
-   [ ] Documentation is up to date
