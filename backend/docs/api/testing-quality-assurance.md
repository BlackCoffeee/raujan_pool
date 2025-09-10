# API Testing & Quality Assurance

## Overview

Dokumentasi ini menjelaskan strategi testing dan quality assurance untuk API sistem pool management.

## Testing Strategy

### 1. Unit Testing

#### Model Testing

```php
// tests/Unit/Models/UserTest.php
<?php

use App\Models\User;
use Tests\TestCase;

class UserTest extends TestCase
{
    public function test_user_can_be_created()
    {
        $user = User::factory()->create([
            'name' => 'John Doe',
            'email' => 'john@example.com'
        ]);

        $this->assertDatabaseHas('users', [
            'name' => 'John Doe',
            'email' => 'john@example.com'
        ]);
    }

    public function test_user_has_many_bookings()
    {
        $user = User::factory()->create();
        $booking = $user->bookings()->create([
            'pool_id' => 1,
            'date' => now(),
            'time_slot' => '10:00-12:00'
        ]);

        $this->assertTrue($user->bookings->contains($booking));
    }
}
```

#### Service Testing

```php
// tests/Unit/Services/BookingServiceTest.php
<?php

use App\Services\BookingService;
use App\Models\User;
use App\Models\Pool;
use Tests\TestCase;

class BookingServiceTest extends TestCase
{
    public function test_can_create_booking()
    {
        $user = User::factory()->create();
        $pool = Pool::factory()->create();

        $service = new BookingService();
        $booking = $service->createBooking([
            'user_id' => $user->id,
            'pool_id' => $pool->id,
            'date' => now()->addDay(),
            'time_slot' => '10:00-12:00'
        ]);

        $this->assertNotNull($booking);
        $this->assertEquals($user->id, $booking->user_id);
    }
}
```

### 2. Feature Testing

#### API Endpoint Testing

```php
// tests/Feature/Api/BookingTest.php
<?php

use App\Models\User;
use App\Models\Pool;
use Tests\TestCase;

class BookingTest extends TestCase
{
    public function test_can_create_booking()
    {
        $user = User::factory()->create();
        $pool = Pool::factory()->create();

        $response = $this->actingAs($user, 'sanctum')
            ->postJson('/api/v1/bookings', [
                'pool_id' => $pool->id,
                'date' => now()->addDay()->format('Y-m-d'),
                'time_slot' => '10:00-12:00'
            ]);

        $response->assertStatus(201)
            ->assertJsonStructure([
                'success',
                'data' => [
                    'id',
                    'user_id',
                    'pool_id',
                    'date',
                    'time_slot',
                    'status'
                ]
            ]);
    }

    public function test_cannot_create_booking_without_authentication()
    {
        $pool = Pool::factory()->create();

        $response = $this->postJson('/api/v1/bookings', [
            'pool_id' => $pool->id,
            'date' => now()->addDay()->format('Y-m-d'),
            'time_slot' => '10:00-12:00'
        ]);

        $response->assertStatus(401);
    }
}
```

#### Authentication Testing

```php
// tests/Feature/Api/AuthTest.php
<?php

use App\Models\User;
use Tests\TestCase;

class AuthTest extends TestCase
{
    public function test_can_register_user()
    {
        $response = $this->postJson('/api/v1/auth/register', [
            'name' => 'John Doe',
            'email' => 'john@example.com',
            'password' => 'password123',
            'password_confirmation' => 'password123'
        ]);

        $response->assertStatus(201)
            ->assertJsonStructure([
                'success',
                'data' => [
                    'user' => [
                        'id',
                        'name',
                        'email'
                    ],
                    'token'
                ]
            ]);
    }

    public function test_can_login_user()
    {
        $user = User::factory()->create([
            'email' => 'john@example.com',
            'password' => bcrypt('password123')
        ]);

        $response = $this->postJson('/api/v1/auth/login', [
            'email' => 'john@example.com',
            'password' => 'password123'
        ]);

        $response->assertStatus(200)
            ->assertJsonStructure([
                'success',
                'data' => [
                    'user' => [
                        'id',
                        'name',
                        'email'
                    ],
                    'token'
                ]
            ]);
    }
}
```

### 3. Integration Testing

#### Database Integration

```php
// tests/Feature/Integration/DatabaseTest.php
<?php

use App\Models\User;
use App\Models\Pool;
use App\Models\Booking;
use Tests\TestCase;

class DatabaseTest extends TestCase
{
    public function test_booking_workflow()
    {
        // Create user
        $user = User::factory()->create();

        // Create pool
        $pool = Pool::factory()->create();

        // Create booking
        $booking = Booking::create([
            'user_id' => $user->id,
            'pool_id' => $pool->id,
            'date' => now()->addDay(),
            'time_slot' => '10:00-12:00',
            'status' => 'pending'
        ]);

        // Verify relationships
        $this->assertEquals($user->id, $booking->user->id);
        $this->assertEquals($pool->id, $booking->pool->id);

        // Update booking status
        $booking->update(['status' => 'confirmed']);

        // Verify update
        $this->assertEquals('confirmed', $booking->fresh()->status);
    }
}
```

### 4. Load Testing

#### Using Artillery

```yaml
# artillery-config.yml
config:
    target: "http://localhost:8000"
    phases:
        - duration: 60
          arrivalRate: 10
        - duration: 120
          arrivalRate: 20
        - duration: 60
          arrivalRate: 10

scenarios:
    - name: "API Load Test"
      weight: 100
      flow:
          - post:
                url: "/api/v1/auth/login"
                json:
                    email: "test@example.com"
                    password: "password123"
                capture:
                    - json: "$.data.token"
                      as: "token"

          - get:
                url: "/api/v1/bookings"
                headers:
                    Authorization: "Bearer {{ token }}"

          - post:
                url: "/api/v1/bookings"
                headers:
                    Authorization: "Bearer {{ token }}"
                json:
                    pool_id: 1
                    date: "2024-12-25"
                    time_slot: "10:00-12:00"
```

#### Running Load Tests

```bash
# Install Artillery
npm install -g artillery

# Run load test
artillery run artillery-config.yml

# Run with report
artillery run artillery-config.yml --output report.json
artillery report report.json
```

## Quality Assurance

### 1. Code Quality

#### PHPStan Configuration

```neon
# phpstan.neon
parameters:
    level: 8
    paths:
        - app
        - config
        - database
    excludePaths:
        - vendor
        - storage
        - bootstrap/cache
    ignoreErrors:
        - '#Call to an undefined method#'
```

#### Running PHPStan

```bash
# Install PHPStan
composer require --dev phpstan/phpstan

# Run analysis
./vendor/bin/phpstan analyse
```

#### Laravel Pint Configuration

```json
{
    "preset": "laravel",
    "rules": {
        "simplified_null_return": true,
        "blank_line_before_statement": {
            "statements": [
                "break",
                "continue",
                "declare",
                "return",
                "throw",
                "try"
            ]
        }
    }
}
```

#### Running Pint

```bash
# Install Pint
composer require --dev laravel/pint

# Run formatting
./vendor/bin/pint
```

### 2. API Quality

#### Response Time Monitoring

```php
// app/Http/Middleware/ApiResponseTime.php
<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;

class ApiResponseTime
{
    public function handle(Request $request, Closure $next)
    {
        $start = microtime(true);

        $response = $next($request);

        $duration = microtime(true) - $start;

        $response->headers->set('X-Response-Time', $duration);

        return $response;
    }
}
```

#### API Validation

```php
// app/Http/Requests/CreateBookingRequest.php
<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class CreateBookingRequest extends FormRequest
{
    public function rules()
    {
        return [
            'pool_id' => 'required|exists:pools,id',
            'date' => 'required|date|after:today',
            'time_slot' => 'required|string|in:08:00-10:00,10:00-12:00,12:00-14:00,14:00-16:00,16:00-18:00,18:00-20:00'
        ];
    }

    public function messages()
    {
        return [
            'pool_id.required' => 'Pool ID is required',
            'pool_id.exists' => 'Selected pool does not exist',
            'date.required' => 'Date is required',
            'date.after' => 'Date must be in the future',
            'time_slot.required' => 'Time slot is required',
            'time_slot.in' => 'Invalid time slot selected'
        ];
    }
}
```

### 3. Security Testing

#### Authentication Testing

```php
// tests/Feature/Security/AuthSecurityTest.php
<?php

use App\Models\User;
use Tests\TestCase;

class AuthSecurityTest extends TestCase
{
    public function test_cannot_access_protected_route_without_token()
    {
        $response = $this->getJson('/api/v1/bookings');

        $response->assertStatus(401)
            ->assertJson([
                'success' => false,
                'message' => 'Unauthenticated.'
            ]);
    }

    public function test_cannot_access_protected_route_with_invalid_token()
    {
        $response = $this->withHeaders([
            'Authorization' => 'Bearer invalid-token'
        ])->getJson('/api/v1/bookings');

        $response->assertStatus(401);
    }

    public function test_cannot_access_admin_route_without_admin_role()
    {
        $user = User::factory()->create(['role' => 'user']);

        $response = $this->actingAs($user, 'sanctum')
            ->getJson('/api/v1/admin/users');

        $response->assertStatus(403);
    }
}
```

#### Input Validation Testing

```php
// tests/Feature/Security/InputValidationTest.php
<?php

use App\Models\User;
use Tests\TestCase;

class InputValidationTest extends TestCase
{
    public function test_cannot_create_booking_with_invalid_data()
    {
        $user = User::factory()->create();

        $response = $this->actingAs($user, 'sanctum')
            ->postJson('/api/v1/bookings', [
                'pool_id' => 'invalid',
                'date' => 'invalid-date',
                'time_slot' => 'invalid-slot'
            ]);

        $response->assertStatus(422)
            ->assertJsonValidationErrors(['pool_id', 'date', 'time_slot']);
    }

    public function test_cannot_create_booking_with_sql_injection()
    {
        $user = User::factory()->create();

        $response = $this->actingAs($user, 'sanctum')
            ->postJson('/api/v1/bookings', [
                'pool_id' => "1'; DROP TABLE users; --",
                'date' => now()->addDay()->format('Y-m-d'),
                'time_slot' => '10:00-12:00'
            ]);

        $response->assertStatus(422)
            ->assertJsonValidationErrors(['pool_id']);
    }
}
```

### 4. Performance Testing

#### Database Query Optimization

```php
// tests/Feature/Performance/DatabasePerformanceTest.php
<?php

use App\Models\User;
use App\Models\Pool;
use App\Models\Booking;
use Tests\TestCase;

class DatabasePerformanceTest extends TestCase
{
    public function test_booking_list_performance()
    {
        // Create test data
        $user = User::factory()->create();
        $pools = Pool::factory()->count(10)->create();

        foreach ($pools as $pool) {
            Booking::factory()->count(5)->create([
                'user_id' => $user->id,
                'pool_id' => $pool->id
            ]);
        }

        // Test query performance
        $start = microtime(true);

        $bookings = Booking::with(['user', 'pool'])
            ->where('user_id', $user->id)
            ->get();

        $duration = microtime(true) - $start;

        // Assert performance (should be under 100ms)
        $this->assertLessThan(0.1, $duration);
        $this->assertCount(50, $bookings);
    }
}
```

#### Memory Usage Testing

```php
// tests/Feature/Performance/MemoryUsageTest.php
<?php

use App\Models\User;
use App\Models\Pool;
use App\Models\Booking;
use Tests\TestCase;

class MemoryUsageTest extends TestCase
{
    public function test_memory_usage_with_large_dataset()
    {
        $initialMemory = memory_get_usage();

        // Create large dataset
        $users = User::factory()->count(1000)->create();
        $pools = Pool::factory()->count(100)->create();

        foreach ($users as $user) {
            foreach ($pools as $pool) {
                Booking::factory()->create([
                    'user_id' => $user->id,
                    'pool_id' => $pool->id
                ]);
            }
        }

        $finalMemory = memory_get_usage();
        $memoryUsed = $finalMemory - $initialMemory;

        // Assert memory usage (should be under 50MB)
        $this->assertLessThan(50 * 1024 * 1024, $memoryUsed);
    }
}
```

## Testing Commands

### Running Tests

```bash
# Run all tests
php artisan test

# Run specific test file
php artisan test tests/Feature/Api/BookingTest.php

# Run with coverage
php artisan test --coverage

# Run with verbose output
php artisan test --verbose

# Run specific test method
php artisan test --filter test_can_create_booking
```

### Test Database Setup

```bash
# Create test database
php artisan migrate --env=testing

# Seed test database
php artisan db:seed --env=testing

# Refresh test database
php artisan migrate:refresh --env=testing
```

## CI/CD Integration

### GitHub Actions

```yaml
# .github/workflows/tests.yml
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
                    MYSQL_DATABASE: testing
                ports:
                    - 3306:3306

        steps:
            - uses: actions/checkout@v3

            - name: Setup PHP
              uses: shivammathur/setup-php@v2
              with:
                  php-version: "8.2"
                  extensions: mbstring, dom, fileinfo, mysql

            - name: Copy .env
              run: php -r "file_exists('.env') || copy('.env.example', '.env');"

            - name: Install Dependencies
              run: composer install -q --no-ansi --no-interaction --no-scripts --no-progress --prefer-dist

            - name: Generate key
              run: php artisan key:generate

            - name: Directory Permissions
              run: chmod -R 777 storage bootstrap/cache

            - name: Create Database
              run: |
                  mysql --host 127.0.0.1 --port 3306 -uroot -ppassword -e "CREATE DATABASE IF NOT EXISTS testing;"

            - name: Execute tests (Unit and Feature tests) via PHPUnit
              env:
                  DB_CONNECTION: mysql
                  DB_HOST: 127.0.0.1
                  DB_PORT: 3306
                  DB_DATABASE: testing
                  DB_USERNAME: root
                  DB_PASSWORD: password
              run: php artisan test

            - name: Run PHPStan
              run: ./vendor/bin/phpstan analyse

            - name: Run Pint
              run: ./vendor/bin/pint --test
```

## Best Practices

### 1. Test Organization

-   **Unit Tests**: Test individual methods and classes
-   **Feature Tests**: Test complete user workflows
-   **Integration Tests**: Test component interactions
-   **Load Tests**: Test performance under load

### 2. Test Data Management

-   Use factories for consistent test data
-   Clean up test data after each test
-   Use database transactions for isolation

### 3. Assertion Best Practices

-   Use specific assertions
-   Test both success and failure cases
-   Verify response structure and content

### 4. Performance Considerations

-   Monitor test execution time
-   Use database transactions for speed
-   Avoid unnecessary API calls

### 5. Security Testing

-   Test authentication and authorization
-   Validate input sanitization
-   Test for common vulnerabilities

## Monitoring & Reporting

### Test Coverage

```bash
# Generate coverage report
php artisan test --coverage

# View coverage in browser
php artisan test --coverage --coverage-html coverage/
```

### Performance Monitoring

```php
// app/Http/Middleware/PerformanceMonitor.php
<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Log;

class PerformanceMonitor
{
    public function handle(Request $request, Closure $next)
    {
        $start = microtime(true);
        $startMemory = memory_get_usage();

        $response = $next($request);

        $duration = microtime(true) - $start;
        $memoryUsed = memory_get_usage() - $startMemory;

        Log::info('API Performance', [
            'url' => $request->fullUrl(),
            'method' => $request->method(),
            'duration' => $duration,
            'memory_used' => $memoryUsed,
            'status' => $response->getStatusCode()
        ]);

        return $response;
    }
}
```

## Troubleshooting

### Common Test Issues

#### Database Connection Issues

```bash
# Check database configuration
php artisan config:show database

# Test database connection
php artisan tinker
>>> DB::connection()->getPdo();
```

#### Memory Issues

```bash
# Increase memory limit
php -d memory_limit=512M artisan test

# Check memory usage
php artisan tinker
>>> memory_get_usage(true);
```

#### Slow Tests

```bash
# Run tests in parallel
php artisan test --parallel

# Use in-memory database
DB_CONNECTION=sqlite
DB_DATABASE=:memory:
```

### Test Debugging

```php
// Debug test failures
public function test_debug_example()
{
    $response = $this->getJson('/api/v1/bookings');

    // Dump response for debugging
    dump($response->json());

    // Assert with custom message
    $this->assertTrue($response->successful(), 'API should return successful response');
}
```

## Conclusion

Testing dan quality assurance adalah bagian penting dari pengembangan API. Dengan mengikuti panduan ini, tim dapat memastikan kualitas dan keandalan sistem pool management.

### Key Takeaways

-   **Comprehensive Testing**: Unit, Feature, Integration, dan Load testing
-   **Code Quality**: PHPStan, Pint, dan best practices
-   **Security**: Authentication, authorization, dan input validation
-   **Performance**: Monitoring dan optimization
-   **CI/CD**: Automated testing dan deployment
-   **Monitoring**: Coverage, performance, dan error tracking
