# Test Coverage Guide

## 📋 Overview

Panduan lengkap untuk test coverage di Raujan Pool Backend, termasuk cara mengukur, meningkatkan, dan mempertahankan coverage yang baik.

## 🎯 Coverage Goals

### Target Coverage

-   **Minimum Coverage**: 80%
-   **Critical Components**: 90%+
-   **New Features**: 85%+

### Coverage Categories

1. **Lines**: Percentage of lines executed
2. **Functions**: Percentage of functions called
3. **Classes**: Percentage of classes used
4. **Methods**: Percentage of methods executed

## 📊 Measuring Coverage

### Generate Coverage Reports

```bash
# HTML Coverage Report
./vendor/bin/pest --coverage-html storage/logs/coverage

# XML Coverage Report
./vendor/bin/pest --coverage-clover storage/logs/coverage.xml

# Text Coverage Report
./vendor/bin/pest --coverage-text

# Coverage with minimum threshold
./vendor/bin/pest --coverage --min=80
```

### Coverage Files

-   **HTML Report**: `storage/logs/coverage/index.html`
-   **XML Report**: `storage/logs/coverage.xml`
-   **Text Output**: Console output

### Viewing Coverage Reports

```bash
# Open HTML report in browser
open storage/logs/coverage/index.html

# Or use PHP built-in server
php -S localhost:8000 -t storage/logs/coverage
```

## 🔍 Coverage Analysis

### Understanding Coverage Metrics

#### Line Coverage

-   **100%**: All lines executed
-   **80-99%**: Good coverage
-   **60-79%**: Acceptable coverage
-   **<60%**: Poor coverage

#### Function Coverage

-   **100%**: All functions called
-   **90%+**: Excellent
-   **80-89%**: Good
-   **<80%**: Needs improvement

#### Class Coverage

-   **100%**: All classes used
-   **90%+**: Excellent
-   **80-89%**: Good
-   **<80%**: Needs improvement

### Coverage Reports Structure

```
Coverage Report
├── Summary
│   ├── Total Lines: 1000
│   ├── Covered Lines: 850
│   ├── Coverage: 85%
│   └── Threshold: 80% ✓
├── Files
│   ├── app/Models/User.php (90%)
│   ├── app/Http/Controllers/AuthController.php (85%)
│   └── app/Services/UserService.php (75%)
└── Details
    ├── Line-by-line coverage
    ├── Uncovered lines
    └── Suggestions
```

## 🎯 Critical Components Coverage

### High Priority (90%+ Coverage Required)

1. **Authentication System**

    - Login/Logout
    - Registration
    - Password Reset
    - Email Verification

2. **Authorization System**

    - Role Management
    - Permission Management
    - Access Control

3. **API Controllers**

    - All public endpoints
    - All protected endpoints
    - Error handling

4. **Models**
    - User model
    - Role model
    - Permission model
    - All relationships

### Medium Priority (80%+ Coverage Required)

1. **Services**

    - Business logic
    - Data processing
    - External integrations

2. **Middleware**

    - Authentication middleware
    - Authorization middleware
    - Rate limiting

3. **Form Requests**
    - Validation rules
    - Authorization checks

### Low Priority (70%+ Coverage Required)

1. **Helpers**

    - Utility functions
    - Helper classes

2. **Configurations**
    - Service providers
    - Configuration files

## 📈 Improving Coverage

### 1. Identify Uncovered Code

```bash
# Generate detailed coverage report
./vendor/bin/pest --coverage-html storage/logs/coverage

# Open report and identify red lines
open storage/logs/coverage/index.html
```

### 2. Write Tests for Uncovered Code

#### Example: Uncovered Method

```php
// app/Models/User.php
public function getFullNameAttribute()
{
    return $this->name;
}

// tests/Unit/UserTest.php
it('can get full name attribute', function () {
    $user = User::factory()->create(['name' => 'John Doe']);
    expect($user->full_name)->toBe('John Doe');
});
```

#### Example: Uncovered Exception Handling

```php
// app/Http/Controllers/UserController.php
public function show($id)
{
    try {
        $user = User::findOrFail($id);
        return response()->json(['data' => $user]);
    } catch (ModelNotFoundException $e) {
        return response()->json(['error' => 'User not found'], 404);
    }
}

// tests/Feature/UserTest.php
it('returns 404 for non-existent user', function () {
    $response = apiGet('/api/v1/users/999');
    assertApiError($response, 404, 'User not found');
});
```

### 3. Test Edge Cases

```php
// Test boundary conditions
it('handles empty input', function () {
    $response = apiPost('/api/v1/users', []);
    assertApiValidationError($response);
});

// Test error conditions
it('handles database errors', function () {
    // Mock database error
    DB::shouldReceive('table')->andThrow(new Exception('Database error'));

    $response = apiPost('/api/v1/users', ['name' => 'Test']);
    assertApiError($response, 500);
});
```

### 4. Test All Code Paths

```php
// Test all conditional branches
it('handles different user types', function () {
    // Test admin user
    $admin = User::factory()->create();
    $admin->assignRole('admin');
    expect($admin->isAdmin())->toBeTrue();

    // Test member user
    $member = User::factory()->create();
    $member->assignRole('member');
    expect($member->isMember())->toBeTrue();

    // Test guest user
    $guest = User::factory()->create();
    $guest->assignRole('guest');
    expect($guest->isGuest())->toBeTrue();
});
```

## 🛠️ Coverage Tools

### Xdebug Configuration

```ini
; php.ini
[xdebug]
zend_extension=xdebug.so
xdebug.mode=coverage
xdebug.start_with_request=trigger
xdebug.output_dir=/tmp
```

### PHPUnit Configuration

```xml
<!-- phpunit.xml -->
<phpunit>
    <logging>
        <log type="coverage-html" target="storage/logs/coverage"/>
        <log type="coverage-clover" target="storage/logs/coverage.xml"/>
    </logging>
</phpunit>
```

### Composer Scripts

```json
{
    "scripts": {
        "test:coverage": ["./vendor/bin/pest --coverage --min=80"],
        "test:coverage:html": [
            "./vendor/bin/pest --coverage-html storage/logs/coverage"
        ],
        "test:coverage:xml": [
            "./vendor/bin/pest --coverage-clover storage/logs/coverage.xml"
        ]
    }
}
```

## 📊 Coverage Monitoring

### CI/CD Integration

```yaml
# .github/workflows/tests.yml
- name: Execute tests with coverage
  run: vendor/bin/pest --coverage --min=80

- name: Upload coverage to Codecov
  uses: codecov/codecov-action@v3
  with:
      file: ./storage/logs/coverage.xml
      flags: unittests
      fail_ci_if_error: true
```

### Coverage Badges

```markdown
<!-- README.md -->

[![Coverage](https://codecov.io/gh/username/repo/branch/main/graph/badge.svg)](https://codecov.io/gh/username/repo)
```

### Coverage Trends

Monitor coverage trends over time:

-   **Increasing**: Good progress
-   **Stable**: Maintained quality
-   **Decreasing**: Needs attention

## 🎯 Coverage Best Practices

### 1. Focus on Quality, Not Quantity

```php
// Good: Meaningful test
it('validates user email format', function () {
    $response = apiPost('/api/v1/users', [
        'email' => 'invalid-email'
    ]);
    assertApiValidationError($response, 'email');
});

// Bad: Useless test
it('returns true', function () {
    expect(true)->toBeTrue();
});
```

### 2. Test Business Logic

```php
// Test important business rules
it('calculates user membership fee correctly', function () {
    $user = User::factory()->create(['membership_type' => 'premium']);
    $fee = $user->calculateMembershipFee();
    expect($fee)->toBe(100000); // Premium membership fee
});
```

### 3. Test Error Handling

```php
// Test error scenarios
it('handles invalid user ID', function () {
    $response = apiGet('/api/v1/users/invalid-id');
    assertApiError($response, 400, 'Invalid user ID');
});
```

### 4. Test Edge Cases

```php
// Test boundary conditions
it('handles maximum user limit', function () {
    // Create maximum number of users
    User::factory()->count(1000)->create();

    $response = apiPost('/api/v1/users', [
        'name' => 'New User',
        'email' => 'new@example.com'
    ]);

    assertApiError($response, 429, 'Maximum user limit reached');
});
```

## 🚨 Coverage Anti-Patterns

### 1. Testing Implementation Details

```php
// Bad: Testing internal implementation
it('calls specific method', function () {
    $user = new User();
    $user->setName('John');
    expect($user->getName())->toBe('John');
});

// Good: Testing behavior
it('can update user name', function () {
    $user = User::factory()->create();
    $user->update(['name' => 'John']);
    expect($user->name)->toBe('John');
});
```

### 2. Over-Mocking

```php
// Bad: Over-mocking
it('creates user', function () {
    $mockUser = Mockery::mock(User::class);
    $mockUser->shouldReceive('create')->andReturn($mockUser);

    $result = $mockUser->create(['name' => 'John']);
    expect($result)->toBe($mockUser);
});

// Good: Testing real behavior
it('creates user', function () {
    $user = User::factory()->create(['name' => 'John']);
    expect($user->name)->toBe('John');
});
```

### 3. Testing Framework Code

```php
// Bad: Testing Laravel framework
it('can use Laravel collections', function () {
    $collection = collect([1, 2, 3]);
    expect($collection->count())->toBe(3);
});

// Good: Testing application code
it('can filter active users', function () {
    User::factory()->create(['is_active' => true]);
    User::factory()->create(['is_active' => false]);

    $activeUsers = User::where('is_active', true)->get();
    expect($activeUsers)->toHaveCount(1);
});
```

## 📈 Coverage Metrics

### Key Metrics to Track

1. **Overall Coverage**: Total percentage
2. **Critical Path Coverage**: Important features
3. **New Code Coverage**: Recently added code
4. **Regression Coverage**: Previously working code

### Coverage Reports

```bash
# Generate comprehensive coverage report
./scripts/test-coverage.sh

# View coverage summary
./vendor/bin/pest --coverage-text

# Generate detailed HTML report
./vendor/bin/pest --coverage-html storage/logs/coverage
```

### Coverage Goals by Component

| Component   | Target Coverage | Current Coverage | Status |
| ----------- | --------------- | ---------------- | ------ |
| Models      | 90%             | 85%              | ⚠️     |
| Controllers | 85%             | 80%              | ⚠️     |
| Services    | 80%             | 75%              | ❌     |
| Middleware  | 80%             | 90%              | ✅     |
| Helpers     | 70%             | 65%              | ❌     |

## 🔧 Troubleshooting Coverage

### Common Issues

1. **Low Coverage on New Code**

    - Write tests for new features
    - Test all code paths
    - Include error handling

2. **Coverage Decreased**

    - Check for removed tests
    - Verify new code has tests
    - Review test quality

3. **False Coverage**
    - Avoid testing implementation details
    - Focus on behavior testing
    - Use meaningful assertions

### Coverage Debugging

```bash
# Run specific test with coverage
./vendor/bin/pest --filter="UserTest" --coverage

# Generate coverage for specific file
./vendor/bin/pest --coverage --filter="app/Models/User.php"

# Debug coverage issues
./vendor/bin/pest --coverage --verbose
```

## 📚 Resources

-   [PHPUnit Coverage Documentation](https://phpunit.readthedocs.io/en/9.5/code-coverage-analysis.html)
-   [Xdebug Coverage Documentation](https://xdebug.org/docs/code_coverage)
-   [Laravel Testing Best Practices](https://laravel.com/docs/11.x/testing)
-   [Test Coverage Best Practices](https://martinfowler.com/bliki/TestCoverage.html)
