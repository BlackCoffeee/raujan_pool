# Testing Guide

Panduan lengkap untuk testing API backend.

## Base URL

```
Testing: http://localhost:8000/api/v1
```

## Test Environment Setup

### 1. Environment Configuration

```env
# .env.testing
APP_ENV=testing
APP_DEBUG=true
APP_KEY=base64:your_test_key_here

DB_CONNECTION=sqlite
DB_DATABASE=database/testing.sqlite

BROADCAST_DRIVER=log
CACHE_DRIVER=array
QUEUE_CONNECTION=sync
SESSION_DRIVER=array
```

### 2. Database Setup

```bash
# Create testing database
touch database/testing.sqlite

# Run migrations
php artisan migrate --env=testing

# Run seeders
php artisan db:seed --env=testing
```

## Running Tests

### 1. Run All Tests

```bash
php artisan test
```

### 2. Run Specific Test File

```bash
php artisan test tests/Feature/AuthTest.php
```

### 3. Run Tests with Coverage

```bash
php artisan test --coverage
```

### 4. Run Tests in Parallel

```bash
php artisan test --parallel
```

## Test Categories

### 1. Authentication Tests

**File:** `tests/Feature/AuthTest.php`

```php
<?php

use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;

uses(RefreshDatabase::class);

test('user can register', function () {
    $response = $this->postJson('/api/v1/auth/register', [
        'name' => 'John Doe',
        'email' => 'john@example.com',
        'password' => 'password123',
        'password_confirmation' => 'password123',
    ]);

    $response->assertStatus(201)
        ->assertJsonStructure([
            'success',
            'message',
            'data' => [
                'user' => [
                    'id',
                    'name',
                    'email',
                ],
                'token',
            ],
        ]);
});

test('user can login', function () {
    $user = User::factory()->create();

    $response = $this->postJson('/api/v1/auth/login', [
        'email' => $user->email,
        'password' => 'password',
    ]);

    $response->assertStatus(200)
        ->assertJsonStructure([
            'success',
            'message',
            'data' => [
                'user',
                'token',
            ],
        ]);
});
```

### 2. Booking Tests

**File:** `tests/Feature/BookingTest.php`

```php
<?php

use App\Models\User;
use App\Models\Session;
use Illuminate\Foundation\Testing\RefreshDatabase;

uses(RefreshDatabase::class);

test('user can create booking', function () {
    $user = User::factory()->create();
    $session = Session::factory()->create();

    $response = $this->actingAs($user)
        ->postJson('/api/v1/bookings', [
            'session_id' => $session->id,
            'booking_date' => '2024-01-15',
            'notes' => 'Test booking',
        ]);

    $response->assertStatus(201)
        ->assertJsonStructure([
            'success',
            'message',
            'data' => [
                'booking' => [
                    'id',
                    'booking_code',
                    'status',
                ],
            ],
        ]);
});

test('user can view their bookings', function () {
    $user = User::factory()->create();
    $booking = Booking::factory()->create(['user_id' => $user->id]);

    $response = $this->actingAs($user)
        ->getJson('/api/v1/bookings');

    $response->assertStatus(200)
        ->assertJsonStructure([
            'success',
            'data' => [
                'bookings' => [
                    '*' => [
                        'id',
                        'booking_code',
                        'status',
                    ],
                ],
            ],
        ]);
});
```

### 3. Payment Tests

**File:** `tests/Feature/PaymentTest.php`

```php
<?php

use App\Models\User;
use App\Models\Booking;
use Illuminate\Foundation\Testing\RefreshDatabase;

uses(RefreshDatabase::class);

test('user can submit payment proof', function () {
    $user = User::factory()->create();
    $booking = Booking::factory()->create(['user_id' => $user->id]);

    $response = $this->actingAs($user)
        ->postJson("/api/v1/bookings/{$booking->id}/payment", [
            'payment_method' => 'bank_transfer',
            'payment_proof' => 'https://example.com/proof.jpg',
        ]);

    $response->assertStatus(200)
        ->assertJsonStructure([
            'success',
            'message',
            'data' => [
                'payment' => [
                    'id',
                    'status',
                    'payment_method',
                ],
            ],
        ]);
});

test('staff can verify payment', function () {
    $staff = User::factory()->create(['role' => 'staff']);
    $payment = Payment::factory()->create(['status' => 'pending']);

    $response = $this->actingAs($staff)
        ->postJson("/api/v1/staff/payments/{$payment->id}/verify", [
            'notes' => 'Payment verified',
        ]);

    $response->assertStatus(200)
        ->assertJsonStructure([
            'success',
            'message',
            'data' => [
                'payment' => [
                    'id',
                    'status',
                    'verified_at',
                ],
            ],
        ]);
});
```

### 4. Admin Tests

**File:** `tests/Feature/AdminTest.php`

```php
<?php

use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;

uses(RefreshDatabase::class);

test('admin can view analytics', function () {
    $admin = User::factory()->create(['role' => 'admin']);

    $response = $this->actingAs($admin)
        ->getJson('/api/v1/admin/analytics/dashboard');

    $response->assertStatus(200)
        ->assertJsonStructure([
            'success',
            'data' => [
                'total_revenue',
                'total_bookings',
                'total_members',
            ],
        ]);
});

test('admin can manage users', function () {
    $admin = User::factory()->create(['role' => 'admin']);
    $user = User::factory()->create();

    $response = $this->actingAs($admin)
        ->getJson('/api/v1/admin/users');

    $response->assertStatus(200)
        ->assertJsonStructure([
            'success',
            'data' => [
                'users' => [
                    '*' => [
                        'id',
                        'name',
                        'email',
                        'role',
                    ],
                ],
            ],
        ]);
});
```

## Test Data Factories

### 1. User Factory

```php
<?php

namespace Database\Factories;

use Illuminate\Database\Eloquent\Factories\Factory;
use Illuminate\Support\Facades\Hash;

class UserFactory extends Factory
{
    public function definition(): array
    {
        return [
            'name' => $this->faker->name(),
            'email' => $this->faker->unique()->safeEmail(),
            'phone' => $this->faker->phoneNumber(),
            'password' => Hash::make('password'),
            'role' => $this->faker->randomElement(['admin', 'staff', 'member', 'regular']),
            'status' => 'active',
        ];
    }

    public function admin(): static
    {
        return $this->state(fn (array $attributes) => [
            'role' => 'admin',
        ]);
    }

    public function member(): static
    {
        return $this->state(fn (array $attributes) => [
            'role' => 'member',
            'membership_type' => $this->faker->randomElement(['monthly', 'quarterly', 'yearly']),
            'membership_expires_at' => $this->faker->dateTimeBetween('now', '+1 year'),
        ]);
    }
}
```

### 2. Booking Factory

```php
<?php

namespace Database\Factories;

use App\Models\User;
use App\Models\Session;
use Illuminate\Database\Eloquent\Factories\Factory;

class BookingFactory extends Factory
{
    public function definition(): array
    {
        return [
            'user_id' => User::factory(),
            'session_id' => Session::factory(),
            'booking_code' => 'BK' . $this->faker->unique()->numberBetween(1000, 9999),
            'booking_date' => $this->faker->dateTimeBetween('now', '+1 month'),
            'status' => $this->faker->randomElement(['pending', 'confirmed', 'cancelled']),
            'payment_status' => $this->faker->randomElement(['pending', 'paid', 'failed']),
            'total_amount' => $this->faker->numberBetween(50000, 200000),
        ];
    }

    public function confirmed(): static
    {
        return $this->state(fn (array $attributes) => [
            'status' => 'confirmed',
            'payment_status' => 'paid',
        ]);
    }
}
```

## API Testing with Postman

### 1. Environment Variables

```json
{
    "base_url": "http://localhost:8000/api/v1",
    "token": "{{auth_token}}",
    "user_id": "{{user_id}}"
}
```

### 2. Pre-request Scripts

```javascript
// Get token from previous request
if (pm.response.code === 200) {
    const response = pm.response.json();
    if (response.data && response.data.token) {
        pm.environment.set("auth_token", response.data.token);
    }
}
```

### 3. Test Scripts

```javascript
// Test response structure
pm.test("Response has success field", function () {
    pm.expect(pm.response.json()).to.have.property("success");
});

pm.test("Response is successful", function () {
    pm.expect(pm.response.json().success).to.be.true;
});

pm.test("Response time is less than 2000ms", function () {
    pm.expect(pm.response.responseTime).to.be.below(2000);
});
```

## Performance Testing

### 1. Load Testing with Artillery

```yaml
# artillery-config.yml
config:
    target: "http://localhost:8000"
    phases:
        - duration: 60
          arrivalRate: 10
    defaults:
        headers:
            Authorization: "Bearer {{token}}"

scenarios:
    - name: "API Load Test"
      flow:
          - get:
                url: "/api/v1/bookings"
          - post:
                url: "/api/v1/bookings"
                json:
                    session_id: 1
                    booking_date: "2024-01-15"
```

### 2. Run Load Test

```bash
artillery run artillery-config.yml
```

## Test Coverage

### 1. Generate Coverage Report

```bash
php artisan test --coverage --coverage-html=coverage
```

### 2. Coverage Configuration

```xml
<!-- phpunit.xml -->
<coverage>
    <include>
        <directory suffix=".php">./app</directory>
    </include>
    <exclude>
        <directory>./app/Console</directory>
        <directory>./app/Exceptions</directory>
    </exclude>
</coverage>
```

## Continuous Integration

### 1. GitHub Actions

```yaml
# .github/workflows/tests.yml
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
                  php-version: "8.2"
                  extensions: mbstring, dom, fileinfo, mysql

            - name: Install dependencies
              run: composer install -q --no-ansi --no-interaction --no-scripts --no-progress --prefer-dist

            - name: Copy environment
              run: cp .env.example .env

            - name: Generate key
              run: php artisan key:generate

            - name: Create database
              run: touch database/testing.sqlite

            - name: Run migrations
              run: php artisan migrate --env=testing

            - name: Run tests
              run: php artisan test
```

## Notes

-   Semua test menggunakan SQLite untuk performa yang lebih baik
-   Test data di-reset setiap test menggunakan RefreshDatabase
-   Factory digunakan untuk membuat test data yang konsisten
-   Coverage report dapat di-generate untuk melihat test coverage
-   CI/CD pipeline otomatis menjalankan test pada setiap commit
