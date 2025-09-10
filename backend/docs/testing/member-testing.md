# Member Management Testing Guide (Legacy)

## ⚠️ Notice

**Dokumentasi ini adalah versi legacy. Untuk Member Schema Revision v2, silakan lihat [Member Schema Revision Testing](member-schema-revision-testing.md)**

## Overview

Dokumentasi ini menjelaskan cara melakukan testing untuk Member Management API menggunakan Laravel Pest dan script testing manual (versi legacy).

## Automated Testing dengan Pest

### Menjalankan Test

```bash
# Jalankan semua test Member
php artisan test tests/Feature/MemberTest.php

# Jalankan test tertentu
php artisan test --filter="test_can_register_member"

# Jalankan test dengan verbose output
php artisan test tests/Feature/MemberTest.php -v
```

### Test Coverage

Saat ini coverage: **~59% (10/17 tests passing)**

#### Test yang Berhasil ✅

1. `test_can_register_member` - Member registration workflow
2. `test_can_get_all_members` - Get all members (admin)
3. `test_can_get_member_by_id` - Get member by ID (admin)
4. `test_can_update_member` - Update member (admin)
5. `test_can_delete_member` - Delete member (admin)
6. `test_can_suspend_member` - Suspend member (admin)
7. `test_can_activate_member` - Activate member (admin)
8. `test_can_expire_member` - Expire member (admin)
9. `test_can_renew_membership` - Renew membership (admin)
10. `test_member_quota_management` - Quota management

#### Test yang Gagal ❌

1. `test_can_get_member_profile` - Profile route issue
2. `test_can_update_member_profile` - Profile update validation
3. `test_can_convert_guest_to_member` - Guest user relation issue
4. `test_can_get_member_stats` - Stats route debugging needed
5. `test_can_get_member_analytics` - Analytics route debugging needed
6. `test_can_process_expired_memberships` - Bulk operation testing
7. `test_member_validation_rules` - Validation testing

### Troubleshooting Test Issues

#### 1. Tabel `membership_expiry_trackings` Tidak Ditemukan

**Error:** `SQLSTATE[HY000]: General error: 1 no such table: membership_expiry_trackings`

**Solusi:**

-   Tabel ini opsional dan tidak diperlukan untuk testing dasar
-   Relasi `expiryTracking` sudah di-handle dengan try-catch
-   Test akan tetap berjalan meskipun tabel tidak ada

#### 2. Admin Role Issues

**Error:** `Expected response status code [200] but received 403`

**Solusi:**

-   Pastikan user memiliki role admin
-   Gunakan `User::factory()->admin()->create()`
-   Role admin akan dibuat otomatis oleh factory

#### 3. Guest User Conversion Issues

**Error:** `User is not a guest user`

**Solusi:**

-   Buat `GuestUser` record sebelum conversion
-   Pastikan relasi antara `User` dan `GuestUser` benar

#### 4. Stats/Analytics Route Issues

**Error:** `No query results for model [App\Models\Member] stats`

**Solusi:**

-   Debug method `getMemberStats` di `MemberService`
-   Periksa apakah ada method yang tidak diimplementasi
-   Pastikan data member tersedia untuk analytics

## Manual Testing dengan Script

### Prerequisites

1. Laravel server berjalan (`php artisan serve`)
2. Database sudah migrated dan seeded
3. `jq` installed untuk JSON formatting (optional)

### Script Testing

```bash
# Buat script executable
chmod +x scripts/test-member-api.sh

# Jalankan semua test
./scripts/test-member-api.sh -a

# Test specific endpoint
./scripts/test-member-api.sh -r  # Registration
./scripts/test-member-api.sh -l  # List members
./scripts/test-member-api.sh -s  # Stats
./scripts/test-member-api.sh -p  # Profile
./scripts/test-member-api.sh -u  # Suspend
./scripts/test-member-api.sh -c  # Activate

# Show help
./scripts/test-member-api.sh -h
```

### Script Features

-   **Auto-authentication**: Membuat admin dan member user otomatis
-   **Token management**: Mengelola JWT tokens untuk testing
-   **Colored output**: Output yang mudah dibaca dengan warna
-   **Error handling**: Menangani error dengan graceful
-   **JSON formatting**: Output JSON yang terformat (dengan jq)

## Testing Checklist

### Member Registration

-   [ ] User bisa mendaftar sebagai member
-   [ ] Validation rules berfungsi
-   [ ] Duplicate member tidak bisa dibuat
-   [ ] Quota config otomatis ter-assign
-   [ ] Membership number otomatis generate

### Member Management (Admin)

-   [ ] Admin bisa lihat semua members
-   [ ] Admin bisa lihat detail member
-   [ ] Admin bisa update member
-   [ ] Admin bisa delete member
-   [ ] Admin bisa suspend/activate member
-   [ ] Admin bisa expire member
-   [ ] Admin bisa renew membership

### Member Profile

-   [ ] Member bisa lihat profile sendiri
-   [ ] Member bisa update profile
-   [ ] Member tidak bisa akses member lain
-   [ ] Profile menampilkan quota info
-   [ ] Profile menampilkan booking history

### Member Analytics

-   [ ] Stats endpoint berfungsi
-   [ ] Analytics endpoint berfungsi
-   [ ] Filter parameters berfungsi
-   [ ] Data aggregation benar
-   [ ] Performance acceptable

### Member Conversion

-   [ ] Guest user bisa di-convert
-   [ ] Conversion data tersimpan
-   [ ] Quota config ter-assign
-   [ ] User role berubah

## Performance Testing

### Load Testing

```bash
# Install Apache Bench
brew install httpd  # macOS
sudo apt-get install apache2-utils  # Ubuntu

# Test member list endpoint
ab -n 100 -c 10 -H "Authorization: Bearer $TOKEN" \
   "http://localhost:8000/api/v1/admin/members"

# Test member stats endpoint
ab -n 50 -c 5 -H "Authorization: Bearer $TOKEN" \
   "http://localhost:8000/api/v1/admin/members/stats"
```

### Database Performance

```bash
# Enable query logging
php artisan tinker
DB::enableQueryLog();

# Run member operations
// ... operations ...

# Check query count and time
DB::getQueryLog();
```

## Security Testing

### Authentication

-   [ ] Unauthenticated requests ditolak
-   [ ] Invalid tokens ditolak
-   [ ] Expired tokens ditolak

### Authorization

-   [ ] Non-admin tidak bisa akses admin routes
-   [ ] Member tidak bisa akses member lain
-   [ ] Role-based access control berfungsi

### Input Validation

-   [ ] SQL injection prevention
-   [ ] XSS prevention
-   [ ] CSRF protection
-   [ ] Rate limiting

## Continuous Integration

### GitHub Actions

```yaml
name: Member Management Tests
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
              run: composer install
            - name: Run tests
              run: php artisan test tests/Feature/MemberTest.php
```

### Pre-commit Hooks

```bash
#!/bin/bash
# .git/hooks/pre-commit
php artisan test tests/Feature/MemberTest.php
if [ $? -ne 0 ]; then
    echo "Tests failed. Commit aborted."
    exit 1
fi
```

## Debugging Tips

### 1. Enable Query Logging

```php
// In test or tinker
DB::enableQueryLog();
// ... operations ...
DB::getQueryLog();
```

### 2. Check Database State

```php
// Check if data exists
Member::count();
Member::with('user')->get();

// Check specific member
Member::find(1)->toArray();
```

### 3. Verify Routes

```bash
php artisan route:list | grep member
```

### 4. Check Middleware

```php
// In controller
dd(auth()->user()->roles->pluck('name'));
```

### 5. Validate Data

```php
// Check factory output
Member::factory()->make()->toArray();
```

## Common Issues & Solutions

### Issue 1: Test Database Not Clean

**Solution:**

```php
use RefreshDatabase;

protected function setUp(): void
{
    parent::setUp();
    // Custom setup if needed
}
```

### Issue 2: Foreign Key Constraints

**Solution:**

```php
// Check migration order
php artisan migrate:status

// Fix timestamp order if needed
// Rename migration files to correct order
```

### Issue 3: Factory Dependencies

**Solution:**

```php
// Create dependencies first
$user = User::factory()->create();
$member = Member::factory()->create(['user_id' => $user->id]);
```

### Issue 4: Authentication Issues

**Solution:**

```php
// Use actingAs for authenticated requests
$this->actingAs($user);

// Or create admin user
$admin = User::factory()->admin()->create();
$this->actingAs($admin);
```

## Best Practices

1. **Test Isolation**: Setiap test harus independent
2. **Factory Usage**: Gunakan factory untuk data testing
3. **Assertion Clarity**: Assertion harus jelas dan spesifik
4. **Error Messages**: Error messages harus informatif
5. **Test Naming**: Nama test harus descriptive
6. **Setup/Teardown**: Gunakan setUp/tearDown dengan benar
7. **Mocking**: Mock external dependencies jika perlu
8. **Performance**: Test harus cepat (< 1 detik per test)

## Resources

-   [Laravel Testing Documentation](https://laravel.com/docs/11.x/testing)
-   [Pest PHP Documentation](https://pestphp.com/)
-   [Laravel Factory Documentation](https://laravel.com/docs/11.x/eloquent-factories)
-   [API Testing Best Practices](https://laravel.com/docs/11.x/http-tests)
