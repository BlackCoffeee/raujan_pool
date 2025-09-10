# Testing Documentation

## 📋 Overview

Dokumentasi lengkap untuk testing environment Raujan Pool Backend menggunakan Laravel Pest, PHPUnit, dan testing database.

## 🎯 Testing Strategy

### Test Types

1. **Unit Tests** - Test individual components in isolation
2. **Feature Tests** - Test complete features and API endpoints
3. **Integration Tests** - Test interactions between components
4. **Database Tests** - Test database operations and models

### Test Coverage

-   **Target Coverage**: Minimum 80%
-   **Critical Paths**: Authentication, Authorization, API endpoints
-   **Models**: All model methods and relationships
-   **Controllers**: All controller methods and responses

## 🛠️ Setup

### Prerequisites

-   PHP 8.2+
-   Composer
-   SQLite (for testing database)
-   Laravel Pest

### Installation

```bash
# Install dependencies
composer install

# Setup testing database
touch database/testing.sqlite

# Run tests
composer test:quick
```

## 🧪 Running Tests

### Quick Commands

```bash
# Run all tests
composer test:quick

# Run tests with coverage
composer test:coverage

# Run unit tests only
composer test:unit

# Run feature tests only
composer test:feature

# Run tests in parallel
composer test:parallel
```

### Script Commands

```bash
# Quick test script
./scripts/test-quick.sh

# Coverage test script
./scripts/test-coverage.sh
```

### Direct Pest Commands

```bash
# Run all tests
./vendor/bin/pest

# Run specific test file
./vendor/bin/pest tests/Feature/AuthTest.php

# Run tests with coverage
./vendor/bin/pest --coverage

# Run tests in parallel
./vendor/bin/pest --parallel

# Run specific test
./vendor/bin/pest --filter="can login with valid credentials"

# Run tests and stop on first failure
./vendor/bin/pest --stop-on-failure
```

## 📁 Test Structure

```
tests/
├── Feature/                 # Feature tests
│   ├── ApiStructureTest.php
│   ├── RolePermissionTest.php
│   ├── DatabaseTest.php
│   └── Auth/
│       ├── AuthenticationTest.php
│       ├── EmailVerificationTest.php
│       ├── PasswordResetTest.php
│       ├── RegistrationTest.php
│       └── RoleBasedAccessControlTest.php
├── Unit/                    # Unit tests
│   ├── UserTest.php
│   ├── RoleTest.php
│   └── PermissionTest.php
├── Pest.php                 # Test configuration and helpers
└── TestCase.php            # Base test case
```

## 🔧 Test Helpers

### Authentication Helpers

```php
// Act as different user types
actingAsUser($user = null)
actingAsAdmin()
actingAsStaff()
actingAsMember()
actingAsGuest()
```

### API Helpers

```php
// API request helpers
apiGet($uri, $headers = [])
apiPost($uri, $data = [], $headers = [])
apiPut($uri, $data = [], $headers = [])
apiDelete($uri, $headers = [])
```

### Assertion Helpers

```php
// API response assertions
assertApiSuccess($response, $message = null)
assertApiError($response, $status = 400, $message = null)
assertApiValidationError($response, $field = null)
```

### Custom Expectations

```php
// Custom Pest expectations
expect($value)->toBeOne()
expect($value)->toBeValidUuid()
expect($value)->toBeValidEmail()
```

## 📊 Test Examples

### Feature Test Example

```php
<?php

use App\Models\User;

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
});
```

### Unit Test Example

```php
<?php

use App\Models\User;

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

    it('can check if user has role', function () {
        $user = User::factory()->create();
        $role = Role::factory()->create(['name' => 'admin']);
        $user->roles()->attach($role);

        expect($user->hasRole('admin'))->toBeTrue();
        expect($user->hasRole('member'))->toBeFalse();
    });
});
```

## 🗄️ Database Testing

### Test Database Configuration

-   **Driver**: SQLite
-   **Database**: `:memory:` (in-memory database)
-   **Migrations**: Fresh migrations for each test
-   **Seeders**: Default data seeded for each test

### Database Helpers

```php
// Refresh database for each test
uses(RefreshDatabase::class)->in('Feature');

// Use faker for test data
uses(WithFaker::class)->in('Feature', 'Unit');
```

### Factory Usage

```php
// Create test data
$user = User::factory()->create();
$role = Role::factory()->create(['name' => 'admin']);

// Create multiple records
$users = User::factory()->count(10)->create();

// Create with specific attributes
$admin = User::factory()->create(['email' => 'admin@example.com']);
```

## 📈 Coverage Reports

### Generating Coverage

```bash
# Generate HTML coverage report
./vendor/bin/pest --coverage-html storage/logs/coverage

# Generate XML coverage report
./vendor/bin/pest --coverage-clover storage/logs/coverage.xml

# Generate text coverage report
./vendor/bin/pest --coverage-text
```

### Coverage Files

-   **HTML Report**: `storage/logs/coverage/index.html`
-   **XML Report**: `storage/logs/coverage.xml`
-   **Minimum Coverage**: 80%

## 🚀 CI/CD Integration

### GitHub Actions

Tests are automatically run on:

-   Push to `main` or `develop` branches
-   Pull requests to `main` or `develop` branches

### Workflow Steps

1. **Setup PHP 8.2** with required extensions
2. **Install Dependencies** via Composer
3. **Setup Database** (SQLite for testing)
4. **Run Tests** with coverage reporting
5. **Upload Coverage** to Codecov
6. **Code Quality** checks with Laravel Pint and PHPStan

### Local CI Simulation

```bash
# Run the same commands as CI
composer test:coverage
./vendor/bin/pint --test
./vendor/bin/phpstan analyse
```

## 🐛 Debugging Tests

### Common Issues

1. **Database Connection Issues**

    ```bash
    # Clear config cache
    php artisan config:clear

    # Recreate test database
    rm database/testing.sqlite
    touch database/testing.sqlite
    ```

2. **Permission Issues**

    ```bash
    # Fix storage permissions
    chmod -R 777 storage bootstrap/cache
    ```

3. **Memory Issues**
    ```bash
    # Increase memory limit
    php -d memory_limit=2G ./vendor/bin/pest
    ```

### Debug Mode

```bash
# Run tests with verbose output
./vendor/bin/pest --verbose

# Run specific test with debug
./vendor/bin/pest --filter="test name" --verbose

# Stop on first failure
./vendor/bin/pest --stop-on-failure
```

## 📝 Writing Tests

### Test Naming Convention

-   **Feature Tests**: `Feature/FeatureNameTest.php`
-   **Unit Tests**: `Unit/ModelNameTest.php`
-   **Test Methods**: Use descriptive names like `it('can login with valid credentials')`

### Test Structure

```php
describe('Feature Name', function () {

    beforeEach(function () {
        // Setup code
    });

    it('should do something specific', function () {
        // Test implementation
    });

    it('should handle edge cases', function () {
        // Edge case testing
    });
});
```

### Best Practices

1. **Arrange-Act-Assert** pattern
2. **One assertion per test** when possible
3. **Descriptive test names**
4. **Use factories** for test data
5. **Clean up** after tests
6. **Mock external dependencies**

## 🔍 Test Categories

### Critical Tests (Must Pass)

-   Authentication and authorization
-   API endpoint responses
-   Database operations
-   Model relationships
-   Role and permission management

### Important Tests (Should Pass)

-   User management
-   Data validation
-   Error handling
-   Edge cases

### Nice-to-Have Tests

-   Performance tests
-   Integration tests
-   UI tests (if applicable)

## 📚 Resources

-   [Laravel Pest Documentation](https://pestphp.com/docs/installation)
-   [Laravel Testing Documentation](https://laravel.com/docs/11.x/testing)
-   [PHPUnit Documentation](https://phpunit.de/documentation.html)
-   [Laravel Factories Documentation](https://laravel.com/docs/11.x/eloquent-factories)

## 🤝 Contributing

### Adding New Tests

1. Create test file in appropriate directory
2. Follow naming conventions
3. Use existing helpers and factories
4. Ensure tests are isolated and repeatable
5. Add to appropriate test suite

### Test Review Checklist

-   [ ] Tests are isolated and don't depend on each other
-   [ ] Tests use factories for data creation
-   [ ] Tests cover both success and failure cases
-   [ ] Tests have descriptive names
-   [ ] Tests follow the project's coding standards
-   [ ] Coverage is maintained above 80%
