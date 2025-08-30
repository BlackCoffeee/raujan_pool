# Point 4: Testing Environment

## 📋 Overview

Setup environment testing dengan Laravel Pest, PHPUnit, dan testing database.

## 🎯 Objectives

- Setup Laravel Pest
- Konfigurasi PHPUnit
- Setup testing database
- Konfigurasi test factories
- Setup API testing

## 📁 Files Structure

```
phase-1/
├── 04-testing-setup.md
├── tests/
│   ├── Feature/
│   ├── Unit/
│   └── Pest.php
├── phpunit.xml
└── database/
    └── testing.sqlite
```

## 🔧 Implementation Steps

### Step 1: Install Laravel Pest

```bash
# Install Pest
composer require pestphp/pest --dev

# Install Pest Laravel plugin
composer require pestphp/pest-plugin-laravel --dev

# Initialize Pest
./vendor/bin/pest --init
```

### Step 2: Configure Testing Database

```bash
# Create testing database
touch database/testing.sqlite

# Update .env.testing
cp .env .env.testing
```

### Step 3: Setup Test Structure

```bash
# Create test directories
mkdir -p tests/Feature
mkdir -p tests/Unit
mkdir -p tests/Helpers
```

## 📊 Configuration Files

### phpunit.xml

```xml
<?xml version="1.0" encoding="UTF-8"?>
<phpunit xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:noNamespaceSchemaLocation="vendor/phpunit/phpunit/phpunit.xsd"
         bootstrap="vendor/autoload.php"
         colors="true"
>
    <testsuites>
        <testsuite name="Unit">
            <directory>tests/Unit</directory>
        </testsuite>
        <testsuite name="Feature">
            <directory>tests/Feature</directory>
        </testsuite>
    </testsuites>
    <source>
        <include>
            <directory>app</directory>
        </include>
    </source>
    <php>
        <env name="APP_ENV" value="testing"/>
        <env name="APP_KEY" value="base64:YourAppKeyHere"/>
        <env name="BCRYPT_ROUNDS" value="4"/>
        <env name="CACHE_DRIVER" value="array"/>
        <env name="DB_CONNECTION" value="sqlite"/>
        <env name="DB_DATABASE" value=":memory:"/>
        <env name="MAIL_MAILER" value="array"/>
        <env name="QUEUE_CONNECTION" value="sync"/>
        <env name="SESSION_DRIVER" value="array"/>
        <env name="TELESCOPE_ENABLED" value="false"/>
    </php>
</phpunit>
```

### tests/Pest.php

```php
<?php

use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Foundation\Testing\WithFaker;

uses(RefreshDatabase::class, WithFaker::class)->in('Feature');
uses(WithFaker::class)->in('Unit');

// Global test helpers
function actingAsUser($user = null)
{
    $user = $user ?? \App\Models\User::factory()->create();
    return test()->actingAs($user);
}

function actingAsAdmin()
{
    $admin = \App\Models\User::factory()->create();
    $adminRole = \App\Models\Role::where('name', 'admin')->first();
    $admin->roles()->attach($adminRole);
    return test()->actingAs($admin);
}

function actingAsStaff()
{
    $staff = \App\Models\User::factory()->create();
    $staffRole = \App\Models\Role::where('name', 'staff')->first();
    $staff->roles()->attach($staffRole);
    return test()->actingAs($staff);
}

function actingAsMember()
{
    $member = \App\Models\User::factory()->create();
    $memberRole = \App\Models\Role::where('name', 'member')->first();
    $member->roles()->attach($memberRole);
    return test()->actingAs($member);
}

function actingAsGuest()
{
    $guest = \App\Models\User::factory()->create();
    $guestRole = \App\Models\Role::where('name', 'guest')->first();
    $guest->roles()->attach($guestRole);
    return test()->actingAs($guest);
}

// API test helpers
function apiGet($uri, $headers = [])
{
    return test()->getJson($uri, $headers);
}

function apiPost($uri, $data = [], $headers = [])
{
    return test()->postJson($uri, $data, $headers);
}

function apiPut($uri, $data = [], $headers = [])
{
    return test()->putJson($uri, $data, $headers);
}

function apiDelete($uri, $headers = [])
{
    return test()->deleteJson($uri, $headers);
}

// Assertion helpers
function assertApiSuccess($response, $message = null)
{
    $response->assertStatus(200)
             ->assertJsonStructure([
                 'success',
                 'message',
                 'data'
             ])
             ->assertJson(['success' => true]);

    if ($message) {
        $response->assertJson(['message' => $message]);
    }
}

function assertApiError($response, $status = 400, $message = null)
{
    $response->assertStatus($status)
             ->assertJsonStructure([
                 'success',
                 'message',
                 'data'
             ])
             ->assertJson(['success' => false]);

    if ($message) {
        $response->assertJson(['message' => $message]);
    }
}

function assertApiValidationError($response, $field = null)
{
    $response->assertStatus(422)
             ->assertJsonStructure([
                 'success',
                 'message',
                 'data',
                 'errors'
             ])
             ->assertJson(['success' => false]);

    if ($field) {
        $response->assertJsonValidationErrors($field);
    }
}
```

### .env.testing

```env
APP_NAME="Raujan Pool Testing"
APP_ENV=testing
APP_KEY=base64:YourAppKeyHere
APP_DEBUG=true
APP_TIMEZONE=UTC
APP_URL=http://localhost

APP_LOCALE=en
APP_FALLBACK_LOCALE=en
APP_FAKER_LOCALE=en_US

APP_MAINTENANCE_DRIVER=file
APP_MAINTENANCE_STORE=database

BCRYPT_ROUNDS=4

LOG_CHANNEL=stack
LOG_STACK=single
LOG_DEPRECATIONS_CHANNEL=null
LOG_LEVEL=debug

DB_CONNECTION=sqlite
DB_DATABASE=:memory:

SESSION_DRIVER=array
SESSION_LIFETIME=120
SESSION_ENCRYPT=false
SESSION_PATH=/
SESSION_DOMAIN=null

BROADCAST_CONNECTION=log
FILESYSTEM_DISK=local
QUEUE_CONNECTION=sync

CACHE_STORE=array
CACHE_PREFIX=

MEMCACHED_HOST=127.0.0.1

REDIS_CLIENT=phpredis
REDIS_HOST=127.0.0.1
REDIS_PASSWORD=null
REDIS_PORT=6379

MAIL_MAILER=array
MAIL_HOST=127.0.0.1
MAIL_PORT=2525
MAIL_USERNAME=null
MAIL_PASSWORD=null
MAIL_ENCRYPTION=null
MAIL_FROM_ADDRESS="hello@example.com"
MAIL_FROM_NAME="${APP_NAME}"

AWS_ACCESS_KEY_ID=
AWS_SECRET_ACCESS_KEY=
AWS_DEFAULT_REGION=us-east-1
AWS_BUCKET=
AWS_USE_PATH_STYLE_ENDPOINT=false

VITE_APP_NAME="${APP_NAME}"

# Sanctum
SANCTUM_STATEFUL_DOMAINS=localhost,127.0.0.1,127.0.0.1:8000,::1

# Google OAuth
GOOGLE_CLIENT_ID=test-client-id
GOOGLE_CLIENT_SECRET=test-client-secret
GOOGLE_REDIRECT_URI=http://localhost:8000/auth/google/callback

# Reverb
REVERB_APP_ID=test-app-id
REVERB_APP_KEY=test-app-key
REVERB_APP_SECRET=test-app-secret
REVERB_HOST=localhost
REVERB_PORT=443
REVERB_SCHEME=https
```

## 🧪 Test Examples

### Feature Tests

#### tests/Feature/AuthTest.php

```php
<?php

use App\Models\User;
use App\Models\Role;

describe('Authentication', function () {

    beforeEach(function () {
        $this->seed();
    });

    it('can login with valid credentials', function () {
        $user = User::factory()->create([
            'email' => 'test@example.com',
            'password' => bcrypt('password123')
        ]);

        $response = apiPost('/api/v1/auth/login', [
            'email' => 'test@example.com',
            'password' => 'password123'
        ]);

        assertApiSuccess($response, 'Login successful');
        $response->assertJsonStructure([
            'data' => [
                'user',
                'token'
            ]
        ]);
    });

    it('cannot login with invalid credentials', function () {
        $response = apiPost('/api/v1/auth/login', [
            'email' => 'test@example.com',
            'password' => 'wrongpassword'
        ]);

        assertApiError($response, 401, 'Invalid credentials');
    });

    it('can register a new user', function () {
        $userData = [
            'name' => 'John Doe',
            'email' => 'john@example.com',
            'password' => 'password123',
            'password_confirmation' => 'password123',
            'phone' => '081234567890'
        ];

        $response = apiPost('/api/v1/auth/register', $userData);

        assertApiSuccess($response, 'Registration successful');
        $this->assertDatabaseHas('users', [
            'email' => 'john@example.com'
        ]);
    });

    it('cannot register with invalid data', function () {
        $response = apiPost('/api/v1/auth/register', [
            'name' => '',
            'email' => 'invalid-email',
            'password' => '123'
        ]);

        assertApiValidationError($response);
    });

    it('can logout authenticated user', function () {
        actingAsUser();

        $response = apiPost('/api/v1/auth/logout');

        assertApiSuccess($response, 'Logout successful');
    });

    it('can get authenticated user data', function () {
        $user = User::factory()->create();
        actingAsUser($user);

        $response = apiGet('/api/v1/auth/user');

        assertApiSuccess($response);
        $response->assertJson([
            'data' => [
                'id' => $user->id,
                'email' => $user->email
            ]
        ]);
    });
});
```

#### tests/Feature/UserTest.php

```php
<?php

use App\Models\User;
use App\Models\Role;

describe('User Management', function () {

    beforeEach(function () {
        $this->seed();
    });

    it('can list users as admin', function () {
        actingAsAdmin();

        $response = apiGet('/api/v1/admin/users');

        assertApiSuccess($response);
        $response->assertJsonStructure([
            'data' => [
                '*' => [
                    'id',
                    'name',
                    'email',
                    'created_at'
                ]
            ]
        ]);
    });

    it('cannot list users as non-admin', function () {
        actingAsMember();

        $response = apiGet('/api/v1/admin/users');

        assertApiError($response, 403, 'Access denied');
    });

    it('can create user as admin', function () {
        actingAsAdmin();

        $userData = [
            'name' => 'New User',
            'email' => 'newuser@example.com',
            'password' => 'password123',
            'phone' => '081234567890'
        ];

        $response = apiPost('/api/v1/admin/users', $userData);

        assertApiSuccess($response, 'User created successfully');
        $this->assertDatabaseHas('users', [
            'email' => 'newuser@example.com'
        ]);
    });

    it('can update user as admin', function () {
        $user = User::factory()->create();
        actingAsAdmin();

        $response = apiPut("/api/v1/admin/users/{$user->id}", [
            'name' => 'Updated Name',
            'phone' => '081234567891'
        ]);

        assertApiSuccess($response, 'User updated successfully');
        $this->assertDatabaseHas('users', [
            'id' => $user->id,
            'name' => 'Updated Name'
        ]);
    });

    it('can delete user as admin', function () {
        $user = User::factory()->create();
        actingAsAdmin();

        $response = apiDelete("/api/v1/admin/users/{$user->id}");

        assertApiSuccess($response, 'User deleted successfully');
        $this->assertDatabaseMissing('users', [
            'id' => $user->id
        ]);
    });
});
```

#### tests/Feature/BookingTest.php

```php
<?php

use App\Models\User;
use App\Models\Booking;
use App\Models\Session;

describe('Booking Management', function () {

    beforeEach(function () {
        $this->seed();
        $this->session = Session::factory()->create();
    });

    it('can create booking as authenticated user', function () {
        $user = User::factory()->create();
        actingAsUser($user);

        $bookingData = [
            'session_id' => $this->session->id,
            'booking_date' => now()->addDay()->format('Y-m-d'),
            'booking_type' => 'regular',
            'adult_count' => 2,
            'child_count' => 1
        ];

        $response = apiPost('/api/v1/bookings', $bookingData);

        assertApiSuccess($response, 'Booking created successfully');
        $this->assertDatabaseHas('bookings', [
            'user_id' => $user->id,
            'session_id' => $this->session->id
        ]);
    });

    it('cannot create booking for past date', function () {
        actingAsUser();

        $bookingData = [
            'session_id' => $this->session->id,
            'booking_date' => now()->subDay()->format('Y-m-d'),
            'booking_type' => 'regular',
            'adult_count' => 2
        ];

        $response = apiPost('/api/v1/bookings', $bookingData);

        assertApiValidationError($response, 'booking_date');
    });

    it('can list user bookings', function () {
        $user = User::factory()->create();
        Booking::factory()->count(3)->create(['user_id' => $user->id]);
        actingAsUser($user);

        $response = apiGet('/api/v1/bookings');

        assertApiSuccess($response);
        $response->assertJsonCount(3, 'data');
    });

    it('can cancel booking', function () {
        $user = User::factory()->create();
        $booking = Booking::factory()->create([
            'user_id' => $user->id,
            'status' => 'confirmed'
        ]);
        actingAsUser($user);

        $response = apiPost("/api/v1/bookings/{$booking->id}/cancel");

        assertApiSuccess($response, 'Booking cancelled successfully');
        $this->assertDatabaseHas('bookings', [
            'id' => $booking->id,
            'status' => 'cancelled'
        ]);
    });
});
```

### Unit Tests

#### tests/Unit/UserTest.php

```php
<?php

use App\Models\User;
use App\Models\Role;

describe('User Model', function () {

    it('can create user', function () {
        $user = User::factory()->create([
            'name' => 'John Doe',
            'email' => 'john@example.com'
        ]);

        expect($user->name)->toBe('John Doe');
        expect($user->email)->toBe('john@example.com');
        expect($user->exists)->toBeTrue();
    });

    it('can assign role to user', function () {
        $user = User::factory()->create();
        $role = Role::factory()->create(['name' => 'member']);

        $user->roles()->attach($role);

        expect($user->roles)->toHaveCount(1);
        expect($user->roles->first()->name)->toBe('member');
    });

    it('can check if user has role', function () {
        $user = User::factory()->create();
        $role = Role::factory()->create(['name' => 'admin']);
        $user->roles()->attach($role);

        expect($user->hasRole('admin'))->toBeTrue();
        expect($user->hasRole('member'))->toBeFalse();
    });

    it('can get user full name', function () {
        $user = User::factory()->create([
            'name' => 'John Doe'
        ]);

        expect($user->full_name)->toBe('John Doe');
    });

    it('can check if user is active', function () {
        $activeUser = User::factory()->create(['is_active' => true]);
        $inactiveUser = User::factory()->create(['is_active' => false]);

        expect($activeUser->isActive())->toBeTrue();
        expect($inactiveUser->isActive())->toBeFalse();
    });
});
```

#### tests/Unit/BookingTest.php

```php
<?php

use App\Models\Booking;
use App\Models\User;
use App\Models\Session;

describe('Booking Model', function () {

    it('can create booking', function () {
        $user = User::factory()->create();
        $session = Session::factory()->create();

        $booking = Booking::factory()->create([
            'user_id' => $user->id,
            'session_id' => $session->id,
            'total_amount' => 150000
        ]);

        expect($booking->user_id)->toBe($user->id);
        expect($booking->session_id)->toBe($session->id);
        expect($booking->total_amount)->toBe(150000);
    });

    it('can calculate total amount', function () {
        $booking = Booking::factory()->create([
            'adult_count' => 2,
            'child_count' => 1,
            'booking_type' => 'regular'
        ]);

        $expectedAmount = (2 * 50000) + (1 * 25000); // Adult: 50k, Child: 25k
        expect($booking->calculateTotalAmount())->toBe($expectedAmount);
    });

    it('can check if booking is confirmed', function () {
        $confirmedBooking = Booking::factory()->create(['status' => 'confirmed']);
        $pendingBooking = Booking::factory()->create(['status' => 'pending']);

        expect($confirmedBooking->isConfirmed())->toBeTrue();
        expect($pendingBooking->isConfirmed())->toBeFalse();
    });

    it('can check if booking is cancellable', function () {
        $confirmedBooking = Booking::factory()->create([
            'status' => 'confirmed',
            'booking_date' => now()->addDay()
        ]);

        $pastBooking = Booking::factory()->create([
            'status' => 'confirmed',
            'booking_date' => now()->subDay()
        ]);

        expect($confirmedBooking->isCancellable())->toBeTrue();
        expect($pastBooking->isCancellable())->toBeFalse();
    });
});
```

## 🔧 Test Commands

### Run Tests

```bash
# Run all tests
./vendor/bin/pest

# Run specific test file
./vendor/bin/pest tests/Feature/AuthTest.php

# Run tests with coverage
./vendor/bin/pest --coverage

# Run tests in parallel
./vendor/bin/pest --parallel

# Run tests with verbose output
./vendor/bin/pest --verbose

# Run specific test
./vendor/bin/pest --filter="can login with valid credentials"

# Run tests and stop on first failure
./vendor/bin/pest --stop-on-failure
```

### Test Database Commands

```bash
# Refresh test database
php artisan migrate:fresh --env=testing

# Seed test database
php artisan db:seed --env=testing

# Run migrations for testing
php artisan migrate --env=testing
```

## 📊 Test Coverage

### Coverage Configuration

Add to `phpunit.xml`:

```xml
<phpunit>
    <!-- ... existing configuration ... -->
    <logging>
        <log type="coverage-html" target="storage/logs/coverage"/>
        <log type="coverage-clover" target="storage/logs/coverage.xml"/>
    </logging>
</phpunit>
```

### Coverage Commands

```bash
# Generate HTML coverage report
./vendor/bin/pest --coverage-html storage/logs/coverage

# Generate XML coverage report
./vendor/bin/pest --coverage-clover storage/logs/coverage.xml

# Generate text coverage report
./vendor/bin/pest --coverage-text
```

## 🚀 CI/CD Integration

### GitHub Actions Workflow

```yaml
name: Tests

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

jobs:
  tests:
    runs-on: ubuntu-latest

    services:
      mysql:
        image: mysql:8.0
        env:
          MYSQL_ROOT_PASSWORD: password
          MYSQL_DATABASE: raujan_pool_test
        ports:
          - 3306:3306
        options: --health-cmd="mysqladmin ping" --health-interval=10s --health-timeout=5s --health-retries=3

    steps:
      - uses: actions/checkout@v3

      - name: Setup PHP
        uses: shivammathur/setup-php@v2
        with:
          php-version: "8.2"
          extensions: mbstring, dom, fileinfo, mysql, redis
          coverage: xdebug

      - name: Copy .env
        run: php -r "file_exists('.env') || copy('.env.testing', '.env');"

      - name: Install Dependencies
        run: composer install -q --no-ansi --no-interaction --no-scripts --no-progress --prefer-dist

      - name: Generate key
        run: php artisan key:generate

      - name: Directory Permissions
        run: chmod -R 777 storage bootstrap/cache

      - name: Create Database
        run: |
          mkdir -p database
          touch database/database.sqlite

      - name: Execute tests (Unit and Feature tests) via PestPHP
        run: vendor/bin/pest --coverage --min=80

      - name: Upload coverage reports to Codecov
        uses: codecov/codecov-action@v3
        with:
          file: ./storage/logs/coverage.xml
          flags: unittests
          name: codecov-umbrella
          fail_ci_if_error: false
```

## ✅ Success Criteria

- [ ] Laravel Pest terinstall dan terkonfigurasi
- [ ] PHPUnit configuration berfungsi
- [ ] Testing database setup berhasil
- [ ] Test factories berfungsi
- [ ] API testing dapat dijalankan
- [ ] Feature tests berjalan dengan baik
- [ ] Unit tests berjalan dengan baik
- [ ] Test coverage > 80%
- [ ] CI/CD integration berfungsi

## 📚 Documentation

- [Laravel Pest Documentation](https://pestphp.com/docs/installation)
- [Laravel Testing Documentation](https://laravel.com/docs/11.x/testing)
- [PHPUnit Documentation](https://phpunit.de/documentation.html)
- [Laravel Factories Documentation](https://laravel.com/docs/11.x/eloquent-factories)
