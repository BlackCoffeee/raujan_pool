# Test Helpers Documentation

## 📋 Overview

Dokumentasi lengkap untuk test helpers yang tersedia di Raujan Pool Backend testing environment.

## 🔐 Authentication Helpers

### actingAsUser($user = null)

Mengautentikasi test sebagai user biasa.

```php
// Menggunakan user yang dibuat otomatis
actingAsUser();

// Menggunakan user yang sudah ada
$user = User::factory()->create();
actingAsUser($user);
```

### actingAsAdmin()

Mengautentikasi test sebagai admin user.

```php
it('can access admin endpoints', function () {
    actingAsAdmin();

    $response = apiGet('/api/v1/admin/users');
    $response->assertStatus(200);
});
```

### actingAsStaff()

Mengautentikasi test sebagai staff user.

```php
it('can access staff endpoints', function () {
    actingAsStaff();

    $response = apiGet('/api/v1/staff/front-desk/dashboard');
    $response->assertStatus(200);
});
```

### actingAsMember()

Mengautentikasi test sebagai member user.

```php
it('can access member endpoints', function () {
    actingAsMember();

    $response = apiGet('/api/v1/members/profile');
    $response->assertStatus(200);
});
```

### actingAsGuest()

Mengautentikasi test sebagai guest user.

```php
it('can access guest endpoints', function () {
    actingAsGuest();

    $response = apiGet('/api/v1/public/info');
    $response->assertStatus(200);
});
```

## 🌐 API Helpers

### apiGet($uri, $headers = [])

Membuat GET request ke API endpoint.

```php
it('can get user data', function () {
    actingAsUser();

    $response = apiGet('/api/v1/auth/user');
    assertApiSuccess($response);
});
```

### apiPost($uri, $data = [], $headers = [])

Membuat POST request ke API endpoint.

```php
it('can create user', function () {
    actingAsAdmin();

    $userData = [
        'name' => 'John Doe',
        'email' => 'john@example.com',
        'password' => 'password123'
    ];

    $response = apiPost('/api/v1/admin/users', $userData);
    assertApiSuccess($response, 'User created successfully');
});
```

### apiPut($uri, $data = [], $headers = [])

Membuat PUT request ke API endpoint.

```php
it('can update user', function () {
    actingAsAdmin();
    $user = User::factory()->create();

    $updateData = [
        'name' => 'Updated Name'
    ];

    $response = apiPut("/api/v1/admin/users/{$user->id}", $updateData);
    assertApiSuccess($response, 'User updated successfully');
});
```

### apiDelete($uri, $headers = [])

Membuat DELETE request ke API endpoint.

```php
it('can delete user', function () {
    actingAsAdmin();
    $user = User::factory()->create();

    $response = apiDelete("/api/v1/admin/users/{$user->id}");
    assertApiSuccess($response, 'User deleted successfully');
});
```

## ✅ Assertion Helpers

### assertApiSuccess($response, $message = null)

Memvalidasi response API yang berhasil.

```php
it('returns success response', function () {
    $response = apiGet('/api/v1/public/health');

    assertApiSuccess($response);
    // Atau dengan pesan spesifik
    assertApiSuccess($response, 'Health check successful');
});
```

**Validasi yang dilakukan:**

-   Status code 200
-   Struktur JSON dengan `success`, `message`, `data`
-   `success` bernilai `true`
-   Pesan sesuai (jika disediakan)

### assertApiError($response, $status = 400, $message = null)

Memvalidasi response API yang error.

```php
it('returns error response', function () {
    $response = apiGet('/api/v1/nonexistent');

    assertApiError($response, 404, 'API endpoint not found');
});
```

**Validasi yang dilakukan:**

-   Status code sesuai (default 400)
-   Struktur JSON dengan `success`, `message`, `data`
-   `success` bernilai `false`
-   Pesan sesuai (jika disediakan)

### assertApiValidationError($response, $field = null)

Memvalidasi response API validation error.

```php
it('returns validation error', function () {
    $response = apiPost('/api/v1/auth/register', [
        'name' => '', // Invalid data
        'email' => 'invalid-email'
    ]);

    assertApiValidationError($response);
    // Atau dengan field spesifik
    assertApiValidationError($response, 'email');
});
```

**Validasi yang dilakukan:**

-   Status code 422
-   Struktur JSON dengan `success`, `message`, `data`, `errors`
-   `success` bernilai `false`
-   Field error sesuai (jika disediakan)

## 🎯 Custom Expectations

### toBeOne()

Memvalidasi nilai sama dengan 1.

```php
it('returns one result', function () {
    $count = 1;
    expect($count)->toBeOne();
});
```

### toBeValidUuid()

Memvalidasi format UUID yang valid.

```php
it('generates valid UUID', function () {
    $uuid = Str::uuid();
    expect($uuid)->toBeValidUuid();
});
```

### toBeValidEmail()

Memvalidasi format email yang valid.

```php
it('has valid email format', function () {
    $email = 'user@example.com';
    expect($email)->toBeValidEmail();
});
```

## 🏭 Factory Helpers

### User Factory

```php
// User dasar
$user = User::factory()->create();

// User dengan atribut spesifik
$admin = User::factory()->create([
    'email' => 'admin@example.com',
    'is_active' => true
]);

// Multiple users
$users = User::factory()->count(10)->create();
```

### Role Factory

```php
// Role dasar
$role = Role::factory()->create();

// Role dengan atribut spesifik
$adminRole = Role::factory()->create([
    'name' => 'admin',
    'display_name' => 'Administrator'
]);
```

### Permission Factory

```php
// Permission dasar
$permission = Permission::factory()->create();

// Permission dengan atribut spesifik
$userPermission = Permission::factory()->create([
    'name' => 'users.create',
    'group' => 'users'
]);
```

## 🔗 Relationship Helpers

### Assign Role to User

```php
it('can assign role to user', function () {
    $user = User::factory()->create();
    $role = Role::factory()->create(['name' => 'member']);

    $user->roles()->attach($role);

    expect($user->hasRole('member'))->toBeTrue();
});
```

### Assign Permission to Role

```php
it('can assign permission to role', function () {
    $role = Role::factory()->create(['name' => 'admin']);
    $permission = Permission::factory()->create(['name' => 'users.create']);

    $role->permissions()->attach($permission);

    expect($role->hasPermission('users.create'))->toBeTrue();
});
```

### Check User Permissions

```php
it('can check user permissions', function () {
    $user = User::factory()->create();
    $role = Role::factory()->create(['name' => 'admin']);
    $permission = Permission::factory()->create(['name' => 'users.create']);

    $role->permissions()->attach($permission);
    $user->roles()->attach($role);

    expect($user->hasPermission('users.create'))->toBeTrue();
});
```

## 📊 Database Helpers

### RefreshDatabase

Otomatis refresh database untuk setiap test.

```php
uses(RefreshDatabase::class)->in('Feature');
```

### WithFaker

Menyediakan faker instance untuk data testing.

```php
uses(WithFaker::class)->in('Feature', 'Unit');

it('can create user with faker data', function () {
    $userData = [
        'name' => $this->faker->name(),
        'email' => $this->faker->email(),
        'phone' => $this->faker->phoneNumber()
    ];

    $user = User::factory()->create($userData);
    expect($user->name)->toBe($userData['name']);
});
```

### Database Assertions

```php
it('creates user in database', function () {
    $userData = [
        'name' => 'John Doe',
        'email' => 'john@example.com'
    ];

    $response = apiPost('/api/v1/admin/users', $userData);

    $this->assertDatabaseHas('users', [
        'email' => 'john@example.com'
    ]);
});

it('deletes user from database', function () {
    $user = User::factory()->create();

    $response = apiDelete("/api/v1/admin/users/{$user->id}");

    $this->assertDatabaseMissing('users', [
        'id' => $user->id
    ]);
});
```

## 🎨 Test Data Helpers

### Create Test Data

```php
it('can create test data', function () {
    // Create users with different roles
    $admin = User::factory()->create();
    $adminRole = Role::where('name', 'admin')->first();
    $admin->roles()->attach($adminRole);

    $member = User::factory()->create();
    $memberRole = Role::where('name', 'member')->first();
    $member->roles()->attach($memberRole);

    expect($admin->isAdmin())->toBeTrue();
    expect($member->isMember())->toBeTrue();
});
```

### Mock External Services

```php
it('can mock external service', function () {
    // Mock Google OAuth service
    Http::fake([
        'https://oauth2.googleapis.com/token' => Http::response([
            'access_token' => 'fake-token',
            'token_type' => 'Bearer'
        ])
    ]);

    $response = apiPost('/api/v1/auth/google/callback', [
        'code' => 'fake-code'
    ]);

    assertApiSuccess($response);
});
```

## 🔧 Custom Helper Functions

### Create Helper Function

```php
// Di tests/Pest.php
function createUserWithRole($roleName) {
    $user = User::factory()->create();
    $role = Role::where('name', $roleName)->first();
    $user->roles()->attach($role);
    return $user;
}

// Penggunaan
it('can create admin user', function () {
    $admin = createUserWithRole('admin');
    expect($admin->isAdmin())->toBeTrue();
});
```

### API Response Helper

```php
// Di tests/Pest.php
function getApiData($response) {
    return $response->json('data');
}

// Penggunaan
it('returns user data', function () {
    actingAsUser();

    $response = apiGet('/api/v1/auth/user');
    $userData = getApiData($response);

    expect($userData)->toHaveKey('id');
    expect($userData)->toHaveKey('email');
});
```

## 📝 Best Practices

### 1. Use Descriptive Test Names

```php
// Good
it('can login with valid credentials')

// Bad
it('test login')
```

### 2. Arrange-Act-Assert Pattern

```php
it('can create user', function () {
    // Arrange
    $userData = [
        'name' => 'John Doe',
        'email' => 'john@example.com'
    ];

    // Act
    $response = apiPost('/api/v1/admin/users', $userData);

    // Assert
    assertApiSuccess($response);
    $this->assertDatabaseHas('users', ['email' => 'john@example.com']);
});
```

### 3. Use Factories for Test Data

```php
// Good
$user = User::factory()->create();

// Bad
$user = new User();
$user->name = 'Test User';
$user->email = 'test@example.com';
$user->save();
```

### 4. Clean Up After Tests

```php
it('can create and delete user', function () {
    $user = User::factory()->create();

    // Test creation
    expect($user->exists)->toBeTrue();

    // Test deletion
    $user->delete();
    expect($user->exists)->toBeFalse();
});
```

### 5. Test Both Success and Failure Cases

```php
it('can handle valid and invalid data', function () {
    // Test valid data
    $validData = ['name' => 'John Doe', 'email' => 'john@example.com'];
    $response = apiPost('/api/v1/users', $validData);
    assertApiSuccess($response);

    // Test invalid data
    $invalidData = ['name' => '', 'email' => 'invalid-email'];
    $response = apiPost('/api/v1/users', $invalidData);
    assertApiValidationError($response);
});
```
