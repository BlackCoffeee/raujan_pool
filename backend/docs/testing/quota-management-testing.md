# Quota Management Testing Documentation

## Overview

Dokumentasi ini menjelaskan cara melakukan testing untuk sistem Quota Management, termasuk setup, test cases, dan cara menjalankan test.

## Test Structure

Testing untuk Quota Management dibagi menjadi beberapa kategori:

1. **QuotaService Tests** - Testing business logic
2. **QuotaController Tests** - Testing API endpoints
3. **Member Quota Access Tests** - Testing member-specific functionality
4. **Validation Tests** - Testing input validation

## Setup Testing Environment

### 1. Database Configuration

Pastikan menggunakan database testing yang terpisah:

```bash
# File .env.testing
DB_CONNECTION=sqlite
DB_DATABASE=:memory:
```

### 2. Running Tests

```bash
# Run all quota management tests
php artisan test --filter=QuotaManagementTest

# Run specific test category
php artisan test --filter="QuotaService"
php artisan test --filter="QuotaController"

# Run specific test
php artisan test --filter="it can create quota configuration"
```

## Test Categories

### 1. QuotaService Tests

#### Test: Create Quota Configuration

```bash
php artisan test --filter="it can create quota configuration"
```

**What it tests:**

-   Membuat konfigurasi quota baru
-   Validasi data input
-   Penyimpanan ke database
-   Response format

**Expected result:** Test PASS

#### Test: Update Quota Configuration

```bash
php artisan test --filter="it can update quota configuration"
```

**What it tests:**

-   Mengupdate konfigurasi quota yang ada
-   Validasi data input
-   Update database
-   Response format

**Expected result:** Test PASS

#### Test: Adjust Member Quota

```bash
php artisan test --filter="it can adjust member quota"
```

**What it tests:**

-   Mengatur ulang quota member
-   Pencatatan history
-   Update member data
-   Response format

**Expected result:** Test PASS

#### Test: Use Member Quota

```bash
php artisan test --filter="it can use member quota"
```

**What it tests:**

-   Penggunaan quota member
-   Validasi quota tersedia
-   Update quota remaining dan used
-   Pencatatan history

**Expected result:** Test PASS

#### Test: Restore Member Quota

```bash
php artisan test --filter="it can restore member quota"
```

**What it tests:**

-   Restore quota member
-   Update quota remaining dan used
-   Pencatatan history
-   Response format

**Expected result:** Test PASS

#### Test: Cannot Use More Quota Than Available

```bash
php artisan test --filter="it cannot use more quota than available"
```

**What it tests:**

-   Validasi quota tidak cukup
-   Exception handling
-   Error message

**Expected result:** Test PASS dengan exception

#### Test: Get Quota Statistics

```bash
php artisan test --filter="it can get quota statistics"
```

**What it tests:**

-   Pengambilan statistik quota
-   Perhitungan total, used, remaining
-   Breakdown per membership type
-   Response format

**Expected result:** Test PASS

#### Test: Get Quota Analytics

```bash
php artisan test --filter="it can get quota analytics"
```

**What it tests:**

-   Pengambilan data analitik
-   Usage trends
-   Top quota users
-   Quota efficiency metrics

**Expected result:** Test PASS

#### Test: Bulk Adjust Quota

```bash
php artisan test --filter="it can bulk adjust quota"
```

**What it tests:**

-   Bulk quota adjustment
-   Multiple member processing
-   Success/failure tracking
-   Response format

**Expected result:** Test PASS

#### Test: Updates Existing Members When Quota Config Changes

```bash
php artisan test --filter="it updates existing members when quota config changes"
```

**What it tests:**

-   Auto-update member quota
-   Propagasi perubahan config
-   Database consistency

**Expected result:** Test PASS

### 2. QuotaController Tests

#### Test: Get Quota Configurations

```bash
php artisan test --filter="it can get quota configurations"
```

**What it tests:**

-   API endpoint GET /admin/quota/configs
-   Response structure
-   Data retrieval
-   Authentication

**Expected result:** Test PASS

#### Test: Create Quota Configuration

```bash
php artisan test --filter="it can create quota configuration"
```

**What it tests:**

-   API endpoint POST /admin/quota/configs
-   Request validation
-   Response structure
-   Database creation

**Expected result:** Test PASS

#### Test: Update Quota Configuration

```bash
php artisan test --filter="it can update quota configuration"
```

**What it tests:**

-   API endpoint PUT /admin/quota/configs/{id}
-   Request validation
-   Response structure
-   Database update

**Expected result:** Test PASS

#### Test: Delete Quota Configuration

```bash
php artisan test --filter="it can delete quota configuration"
```

**What it tests:**

-   API endpoint DELETE /admin/quota/configs/{id}
-   Business logic validation
-   Response structure
-   Database deletion

**Expected result:** Test PASS

#### Test: Cannot Delete Quota Config With Active Members

```bash
php artisan test --filter="it cannot delete quota config with active members"
```

**What it tests:**

-   Business rule protection
-   Error response
-   Data integrity

**Expected result:** Test PASS dengan response 400

#### Test: Adjust Member Quota

```bash
php artisan test --filter="it can adjust member quota"
```

**What it tests:**

-   API endpoint POST /admin/quota/members/{id}/adjust
-   Request validation
-   Response structure
-   Quota adjustment

**Expected result:** Test PASS

#### Test: Get Quota Statistics

```bash
php artisan test --filter="it can get quota statistics"
```

**What it tests:**

-   API endpoint GET /admin/quota/stats
-   Response structure
-   Data retrieval
-   Statistics calculation

**Expected result:** Test PASS

#### Test: Get Quota Analytics

```bash
php artisan test --filter="it can get quota analytics"
```

**What it tests:**

-   API endpoint GET /admin/quota/analytics
-   Response structure
-   Data retrieval
-   Analytics calculation

**Expected result:** Test PASS

#### Test: Get Member Quota History

```bash
php artisan test --filter="it can get member quota history"
```

**What it tests:**

-   API endpoint GET /admin/quota/members/{id}/history
-   Response structure
-   Pagination
-   History data

**Expected result:** Test PASS

#### Test: Bulk Adjust Quota

```bash
php artisan test --filter="it can bulk adjust quota"
```

**What it tests:**

-   API endpoint POST /admin/quota/bulk-adjust
-   Request validation
-   Response structure
-   Bulk processing

**Expected result:** Test PASS

#### Test: Get Quota Configuration By ID

```bash
php artisan test --filter="it can get quota configuration by id"
```

**What it tests:**

-   API endpoint GET /admin/quota/configs/{id}
-   Response structure
-   Data retrieval
-   Error handling

**Expected result:** Test PASS

#### Test: Get Members By Quota Status

```bash
php artisan test --filter="it can get members by quota status"
```

**What it tests:**

-   API endpoint GET /admin/quota/members
-   Status filtering
-   Response structure
-   Pagination

**Expected result:** Test PASS

### 3. Member Quota Access Tests

#### Test: Can Get My Quota As Member

```bash
php artisan test --filter="it can get my quota as member"
```

**What it tests:**

-   API endpoint GET /members/quota
-   Member authentication
-   Response structure
-   Quota information

**Expected result:** Test PASS

#### Test: Returns 404 If User Is Not A Member

```bash
php artisan test --filter="it returns 404 if user is not a member"
```

**What it tests:**

-   Error handling
-   Non-member access
-   Response status

**Expected result:** Test PASS dengan response 404

### 4. Validation Tests

#### Test: Validates Required Fields For Creating Quota Config

```bash
php artisan test --filter="it validates required fields for creating quota config"
```

**What it tests:**

-   Required field validation
-   Error messages
-   Response status

**Expected result:** Test PASS dengan validation errors

#### Test: Validates Membership Type Enum

```bash
php artisan test --filter="it validates membership type enum"
```

**What it tests:**

-   Enum validation
-   Invalid values
-   Error messages

**Expected result:** Test PASS dengan validation errors

#### Test: Validates Max Quota Minimum Value

```bash
php artisan test --filter="it validates max quota minimum value"
```

**What it tests:**

-   Minimum value validation
-   Error messages
-   Response status

**Expected result:** Test PASS dengan validation errors

#### Test: Validates Daily Limit Minimum Value

```bash
php artisan test --filter="it validates daily limit minimum value"
```

**What it tests:**

-   Daily limit validation
-   Error messages
-   Response status

**Expected result:** Test PASS dengan validation errors

#### Test: Validates Additional Session Cost Minimum Value

```bash
php artisan test --filter="it validates additional session cost minimum value"
```

**What it tests:**

-   Cost validation
-   Error messages
-   Response status

**Expected result:** Test PASS dengan validation errors

#### Test: Validates Member Quota Adjustment

```bash
php artisan test --filter="it validates member quota adjustment"
```

**What it tests:**

-   Quota adjustment validation
-   Error messages
-   Response status

**Expected result:** Test PASS dengan validation errors

#### Test: Validates Bulk Quota Adjustment

```bash
php artisan test --filter="it validates bulk quota adjustment"
```

**What it tests:**

-   Bulk adjustment validation
-   Error messages
-   Response status

**Expected result:** Test PASS dengan validation errors

## Test Data Setup

### Factories Used

1. **UserFactory** - Membuat user untuk testing
2. **MemberFactory** - Membuat member untuk testing
3. **MemberQuotaConfigFactory** - Membuat konfigurasi quota
4. **MemberQuotaHistoryFactory** - Membuat history quota

### Test Data Isolation

Setiap test menggunakan data yang terisolasi:

```php
// Clear existing data before test
Member::query()->delete();
MemberQuotaConfig::query()->delete();

// Create test data
$config = MemberQuotaConfig::factory()->create();
```

## Common Test Patterns

### 1. Admin Authentication

```php
beforeEach(function () {
    $this->admin = User::factory()->admin()->create();
    $this->actingAs($this->admin);
});
```

### 2. Response Assertions

```php
$response->assertOk()
    ->assertJsonStructure([
        'success',
        'message',
        'data'
    ]);
```

### 3. Database Assertions

```php
$this->assertDatabaseHas('member_quota_config', [
    'membership_type' => 'regular',
    'max_quota' => 50
]);
```

### 4. Exception Testing

```php
expect(function () {
    $this->quotaService->useMemberQuota($member->id, 1000);
})->toThrow(Exception::class, 'Insufficient quota remaining');
```

## Troubleshooting

### Common Issues

1. **Unique Constraint Violation**

    - Clear existing data before test
    - Use different membership types
    - Ensure factory states are unique

2. **Authentication Issues**

    - Use `actingAs()` for authenticated requests
    - Create admin user with proper role

3. **Database State Issues**
    - Use `refresh()` on models after changes
    - Clear database between tests if needed

### Debug Commands

```bash
# Run specific test with verbose output
php artisan test --filter="test_name" -v

# Run test with stop on failure
php artisan test --filter="test_name" --stop-on-failure

# Run test with coverage (if available)
php artisan test --filter="test_name" --coverage
```

## Performance Testing

### Load Testing

```bash
# Run tests multiple times to check performance
for i in {1..5}; do php artisan test --filter=QuotaManagementTest; done
```

### Memory Usage

```bash
# Monitor memory usage during tests
php -d memory_limit=512M artisan test --filter=QuotaManagementTest
```

## Continuous Integration

### GitHub Actions Example

```yaml
- name: Run Quota Management Tests
  run: php artisan test --filter=QuotaManagementTest
```

### Pre-commit Hook

```bash
#!/bin/bash
php artisan test --filter=QuotaManagementTest
if [ $? -ne 0 ]; then
    echo "Tests failed. Please fix before committing."
    exit 1
fi
```

## Best Practices

1. **Test Isolation**: Setiap test harus independen
2. **Clear Naming**: Nama test harus deskriptif
3. **Data Cleanup**: Bersihkan data setelah test
4. **Assertion Clarity**: Assertion harus jelas dan spesifik
5. **Error Handling**: Test semua error scenarios
6. **Performance**: Test harus cepat dan efisien

## Support

Untuk pertanyaan atau masalah testing, silakan:

1. Periksa error messages dengan teliti
2. Gunakan verbose output (`-v` flag)
3. Periksa database state
4. Review factory definitions
5. Hubungi tim development jika diperlukan
