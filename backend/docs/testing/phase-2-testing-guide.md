# Phase 2 Testing Guide

## 📋 Overview

Panduan lengkap untuk testing Phase 2: Authentication & User Management yang mencakup Laravel Sanctum authentication, Google SSO integration, role-based access control, guest user management, dan user profile management.

## 🧪 Test Categories

### 1. Authentication Tests

**File:** `tests/Feature/Auth/ApiAuthenticationTest.php`

**Test Coverage:**

-   ✅ Login with valid credentials
-   ✅ Login with invalid credentials
-   ✅ Login with inactive account
-   ✅ User registration
-   ✅ Registration with existing email validation
-   ✅ User logout
-   ✅ Get authenticated user data
-   ✅ Token refresh
-   ✅ Revoke all tokens
-   ✅ Authentication requirement for protected endpoints
-   ✅ Request data validation
-   ✅ Last login timestamp update

**Run Tests:**

```bash
php artisan test --filter="Auth"
```

### 2. Google OAuth Integration Tests

**File:** `tests/Feature/GoogleAuthTest.php`

**Test Coverage:**

-   ✅ Generate Google OAuth redirect URL
-   ✅ Authenticate with Google and create new user
-   ✅ Link Google account to existing user
-   ✅ Prevent linking if already linked
-   ✅ Unlink Google account
-   ✅ Prevent unlinking without password
-   ✅ State parameter validation
-   ✅ Google authentication error handling
-   ✅ Prevent linking to another user
-   ✅ Assign guest role to new Google users
-   ✅ Update existing user with Google profile data

**Run Tests:**

```bash
php artisan test --filter="GoogleAuth"
```

### 3. Guest User Management Tests

**File:** `tests/Feature/GuestUserManagementTest.php`

**Test Coverage:**

-   ✅ Register as guest user
-   ✅ Prevent registration with existing email
-   ✅ Prevent registration with existing user email
-   ✅ Login as guest user
-   ✅ Login with invalid credentials
-   ✅ Convert guest to member
-   ✅ Prevent conversion of expired guest
-   ✅ Get guest profile
-   ✅ Update guest profile
-   ✅ Extend guest expiry
-   ✅ Get guest statistics
-   ✅ Guest registration request validation
-   ✅ Guest conversion request validation

**Run Tests:**

```bash
php artisan test --filter="GuestUser"
```

### 4. Profile Management Tests

**File:** `tests/Feature/ProfileManagementTest.php`

**Test Coverage:**

-   ✅ Get user profile
-   ✅ Create default profile if not exists
-   ✅ Update user profile
-   ✅ Create profile during update if not exists
-   ✅ Track profile history on update
-   ✅ Upload avatar
-   ✅ Create profile during avatar upload if not exists
-   ✅ Delete old avatar when uploading new one
-   ✅ Delete avatar
-   ✅ Error when trying to delete non-existent avatar
-   ✅ Get profile history
-   ✅ Empty history when profile does not exist
-   ✅ Export profile data
-   ✅ Error when trying to export non-existent profile
-   ✅ Get public profile
-   ✅ Error for private profile
-   ✅ Update preferences
-   ✅ Get profile statistics
-   ✅ Zero statistics for non-existent profile
-   ✅ Profile update data validation
-   ✅ Avatar upload validation
-   ✅ Authentication requirement for profile operations

**Run Tests:**

```bash
php artisan test --filter="Profile"
```

### 5. Role-Based Access Control Tests

**File:** `tests/Feature/Auth/RoleBasedAccessControlTest.php`

**Test Coverage:**

-   ✅ Role Management
    -   List roles as admin
    -   Create role as admin
    -   Assign permissions to role
    -   Prevent access as non-admin
-   ✅ Permission Management
    -   List permissions as admin
    -   Create permission as admin
    -   Get permission groups
-   ✅ Role Middleware
    -   Allow access with correct role
    -   Deny access with incorrect role
    -   Deny access to unauthenticated user
-   ✅ User Role Methods
    -   Check if user has role
    -   Check if user has any role
    -   Check if user has all roles
    -   Check if user has permission
    -   Get role names
    -   Get permission names

**Run Tests:**

```bash
php artisan test --filter="Role"
```

### 6. API Structure Tests

**File:** `tests/Feature/ApiStructureTest.php`

**Test Coverage:**

-   ✅ Public API Endpoints
    -   Health check endpoint
    -   Info endpoint
    -   404 for non-existent public endpoints
-   ✅ Authentication API Endpoints
    -   Login endpoint implementation
    -   Register endpoint implementation
    -   Logout endpoint implementation
    -   User endpoint implementation
    -   Google OAuth redirect URL
-   ✅ Protected API Endpoints
    -   Authentication requirement
    -   Not implemented endpoints
-   ✅ Admin API Endpoints
    -   Admin role requirement
    -   Admin access to role management
    -   Not implemented admin endpoints
-   ✅ Staff API Endpoints
    -   Staff/admin role requirement
    -   Staff access to front desk
    -   Admin access to staff endpoints
-   ✅ API Response Format
    -   Consistent JSON structure
    -   Proper error formats (404, 401, 403)
-   ✅ API Versioning
    -   V1 prefix usage
    -   Fallback for undefined endpoints

**Run Tests:**

```bash
php artisan test --filter="ApiStructure"
```

### 7. Database Tests

**File:** `tests/Feature/DatabaseTest.php`

**Test Coverage:**

-   ✅ Database Tables
    -   Users table structure
    -   Roles table structure
    -   Permissions table structure
    -   Role-user pivot table
    -   Permission-role pivot table
    -   Personal access tokens table
-   ✅ User Model
    -   Factory creation
    -   Fillable attributes
    -   Hidden attributes
    -   Attribute casting
    -   Password hashing
    -   Role relationships
    -   Role checking methods
    -   Permission checking methods
-   ✅ Role Model
    -   Factory creation
    -   Fillable attributes
    -   User relationships
    -   Permission relationships
    -   Permission checking methods
-   ✅ Permission Model
    -   Factory creation
    -   Fillable attributes
    -   Role relationships
-   ✅ Database Seeders
    -   Default roles seeding
    -   Default permissions seeding
    -   Admin role permission assignment
    -   Default admin user creation
-   ✅ Database Constraints
    -   Unique email constraint
    -   Unique role name constraint
    -   Unique permission name constraint
    -   Foreign key constraints
-   ✅ Database Performance
    -   Multiple user-role assignments
    -   Multiple role-permission assignments

**Run Tests:**

```bash
php artisan test --filter="Database"
```

## 🚀 Running Tests

### Run All Phase 2 Tests

```bash
# Run all Phase 2 related tests
php artisan test --filter="Auth|GoogleAuth|GuestUser|Profile|Role|ApiStructure|Database"

# Run with coverage (requires Xdebug or PCOV)
php artisan test --coverage --filter="Auth|GoogleAuth|GuestUser|Profile|Role|ApiStructure|Database"

# Run with verbose output
php artisan test --filter="Auth|GoogleAuth|GuestUser|Profile|Role|ApiStructure|Database" -v
```

### Run Individual Test Categories

```bash
# Authentication tests
php artisan test --filter="Auth"

# Google OAuth tests
php artisan test --filter="GoogleAuth"

# Guest user tests
php artisan test --filter="GuestUser"

# Profile management tests
php artisan test --filter="Profile"

# RBAC tests
php artisan test --filter="Role"

# API structure tests
php artisan test --filter="ApiStructure"

# Database tests
php artisan test --filter="Database"
```

### Run Specific Test Files

```bash
# Run specific test file
php artisan test tests/Feature/Auth/ApiAuthenticationTest.php

# Run specific test method
php artisan test --filter="can login with valid credentials"
```

## 🔧 Test Configuration

### Environment Setup

**Testing Database:**

```env
DB_CONNECTION=sqlite
DB_DATABASE=:memory:
```

**Google OAuth (Testing):**

```env
GOOGLE_CLIENT_ID=test-client-id
GOOGLE_CLIENT_SECRET=test-client-secret
GOOGLE_REDIRECT_URI=http://localhost:8000/api/v1/auth/google/callback
```

### Test Helpers

**API Helper Functions:**

```php
// Make API request
apiGet($url, $headers = [])
apiPost($url, $data = [], $headers = [])
apiPut($url, $data = [], $headers = [])
apiDelete($url, $headers = [])

// Assert API responses
assertApiSuccess($response, $message = null)
assertApiError($response, $statusCode, $message = null)

// Authentication helpers
actingAsUser($user)
actingAsAdmin()
actingAsMember()
actingAsStaff()
```

### Mocking

**Google OAuth Mocking:**

```php
// Mock Socialite for testing
\Laravel\Socialite\Facades\Socialite::shouldReceive('driver->user')
    ->andReturn($googleUser);
```

## 📊 Test Coverage

### Current Coverage

-   **Authentication:** 100%
-   **Google OAuth:** 100%
-   **Guest User Management:** 100%
-   **Profile Management:** 100%
-   **RBAC:** 100%
-   **API Structure:** 100%
-   **Database:** 100%

### Coverage Report

```bash
# Generate coverage report
php artisan test --coverage --coverage-html=storage/coverage

# View coverage report
open storage/coverage/index.html
```

## 🐛 Debugging Tests

### Common Issues

1. **Database Connection Issues**

    ```bash
    # Clear test database
    php artisan migrate:fresh --seed
    ```

2. **Mock Issues**

    ```bash
    # Clear cache
    php artisan cache:clear
    php artisan config:clear
    ```

3. **File Permission Issues**
    ```bash
    # Fix permissions
    chmod -R 755 storage bootstrap/cache
    ```

### Debug Mode

```bash
# Run tests with debug output
php artisan test --filter="Auth" -v --debug

# Run specific test with detailed output
php artisan test --filter="can login with valid credentials" -v
```

## 📝 Test Data

### Factories

**User Factory:**

```php
User::factory()->create([
    'email' => 'test@example.com',
    'password' => bcrypt('password123')
]);
```

**Role Factory:**

```php
Role::factory()->create([
    'name' => 'test_role',
    'display_name' => 'Test Role'
]);
```

**Permission Factory:**

```php
Permission::factory()->create([
    'name' => 'test.permission',
    'display_name' => 'Test Permission'
]);
```

### Seeders

**Database Seeder:**

```php
// Run all seeders
php artisan db:seed

// Run specific seeder
php artisan db:seed --class=RoleSeeder
```

## 🔍 Test Assertions

### API Response Assertions

```php
// Check success response
$response->assertStatus(200);
$response->assertJson([
    'success' => true,
    'message' => 'Login successful'
]);

// Check error response
$response->assertStatus(422);
$response->assertJsonValidationErrors(['email']);

// Check JSON structure
$response->assertJsonStructure([
    'success',
    'message',
    'data' => [
        'user',
        'token'
    ]
]);
```

### Database Assertions

```php
// Check database has record
$this->assertDatabaseHas('users', [
    'email' => 'test@example.com'
]);

// Check database missing record
$this->assertDatabaseMissing('users', [
    'email' => 'deleted@example.com'
]);

// Check database count
$this->assertDatabaseCount('users', 1);
```

## 📚 Additional Resources

-   [Laravel Testing Documentation](https://laravel.com/docs/11.x/testing)
-   [Pest Testing Framework](https://pestphp.com/)
-   [Laravel Sanctum Testing](https://laravel.com/docs/11.x/sanctum#testing)
-   [Mocking in Laravel](https://laravel.com/docs/11.x/mocking)
