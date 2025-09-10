# Member Schema Revision v2 - Testing Guide

## 📋 Overview

Panduan testing untuk Member Schema Revision v2 yang mencakup testing database schema, business logic, dan API endpoints.

## 🧪 Test Categories

### 1. **Database Schema Testing**

#### Test Database Tables

```bash
# Test script untuk verifikasi schema
./scripts/test-member-schema-revision.sh
```

**Test Cases:**

-   ✅ Migration status check
-   ✅ Model files check
-   ✅ Seeder file check
-   ✅ Database tables check
-   ✅ Default configurations check

#### Manual Database Testing

```sql
-- Test system_configurations table
SELECT * FROM system_configurations WHERE config_key LIKE 'member_%';

-- Test pricing_config table
SELECT * FROM pricing_config WHERE is_active = 1;

-- Test members table structure
DESCRIBE members;

-- Test member_status_history table
SELECT * FROM member_status_history LIMIT 5;

-- Test member_payments table
SELECT * FROM member_payments LIMIT 5;
```

### 2. **Model Testing**

#### SystemConfiguration Model

```php
// Test configuration retrieval
$config = SystemConfiguration::get('member_registration_fee');
assert($config == 50000);

// Test configuration update
SystemConfiguration::set('member_registration_fee', 75000, 'decimal', 'Updated fee', 1);
$updatedConfig = SystemConfiguration::get('member_registration_fee');
assert($updatedConfig == 75000);

// Test member configuration
$memberConfig = SystemConfiguration::getMemberConfig();
assert(isset($memberConfig['registration_fee']));
assert(isset($memberConfig['grace_period_days']));
```

#### PricingConfig Model

```php
// Test active configuration retrieval
$pricing = PricingConfig::getActiveConfig('monthly');
assert($pricing !== null);

// Test price calculation
$totalPrice = $pricing->calculateTotalPrice('quarterly', true);
assert($totalPrice > 0);

// Test reactivation price
$reactivationPrice = $pricing->calculateReactivationPrice('quarterly');
assert($reactivationPrice > 0);
```

#### Member Model

```php
// Test member creation
$member = Member::createNewMember([
    'user_id' => 1,
    'user_profile_id' => 1,
], 'monthly', 'manual');

assert($member !== null);
assert($member->status === 'active');
assert(strlen($member->member_code) === 10);

// Test status change
$member->changeStatus('inactive', 'Membership expired', 1, 'automatic');
assert($member->status === 'inactive');

// Test reactivation
$member->reactivate(250000, 'REACT001');
assert($member->status === 'active');
assert($member->reactivation_count === 1);
```

### 3. **Business Logic Testing**

#### Registration Flow Testing

```php
// Test monthly registration
$member = Member::createNewMember([
    'user_id' => 1,
    'user_profile_id' => 1,
], 'monthly', 'manual');

// Verify payment calculation
$pricing = PricingConfig::getActiveConfig('monthly');
$totalPrice = $pricing->calculateTotalPrice('monthly', true);
assert($totalPrice === 250000); // 50,000 + 200,000

// Test quarterly registration
$member = Member::createNewMember([
    'user_id' => 2,
    'user_profile_id' => 2,
], 'quarterly', 'manual');

$pricing = PricingConfig::getActiveConfig('quarterly');
$totalPrice = $pricing->calculateTotalPrice('quarterly', true);
assert($totalPrice === 495000); // (50,000 + 500,000) - 10% discount
```

#### Status Change Testing

```php
// Test automatic status change
$member = Member::factory()->create([
    'status' => 'active',
    'membership_end' => now()->subDays(1)
]);

// Simulate automatic status change
$member->changeStatus('inactive', 'Membership expired', null, 'automatic');
assert($member->status === 'inactive');

// Test grace period
$member->startGracePeriod(90);
assert($member->grace_period_start !== null);
assert($member->grace_period_end !== null);
```

#### Reactivation Testing

```php
// Test reactivation flow
$member = Member::factory()->create([
    'status' => 'non_member',
    'reactivation_count' => 0
]);

$member->reactivate(495000, 'REACT001');
assert($member->status === 'active');
assert($member->reactivation_count === 1);
assert($member->last_reactivation_fee === 50000);
```

### 4. **API Testing**

#### Member Registration API

```bash
# Test member registration
curl -X POST http://localhost:8000/api/v1/members/register \
  -H "Authorization: Bearer {token}" \
  -H "Content-Type: application/json" \
  -d '{
    "user_id": 1,
    "membership_type": "quarterly",
    "payment_method": "transfer"
  }'

# Expected response
{
  "success": true,
  "message": "Member registered successfully",
  "data": {
    "member": {...},
    "total_amount": 495000,
    "breakdown": {
      "registration_fee": 50000,
      "quarterly_fee": 500000,
      "subtotal": 550000,
      "discount_percentage": 10,
      "discount_amount": 55000,
      "final_amount": 495000
    }
  }
}
```

#### Configuration Management API

```bash
# Test configuration retrieval
curl -X GET http://localhost:8000/api/v1/admin/config/member \
  -H "Authorization: Bearer {admin_token}"

# Test configuration update
curl -X PUT http://localhost:8000/api/v1/admin/config/member \
  -H "Authorization: Bearer {admin_token}" \
  -H "Content-Type: application/json" \
  -d '{
    "registration_fee": 75000,
    "grace_period_days": 120,
    "reactivation_fee": 75000
  }'
```

#### Member Reactivation API

```bash
# Test member reactivation
curl -X POST http://localhost:8000/api/v1/members/1/reactivate \
  -H "Authorization: Bearer {token}" \
  -H "Content-Type: application/json" \
  -d '{
    "payment_method": "transfer"
  }'
```

### 5. **Integration Testing**

#### End-to-End Registration Flow

```php
// Test complete registration flow
public function test_complete_registration_flow()
{
    // 1. Create user and profile
    $user = User::factory()->create();
    $profile = UserProfile::factory()->create(['user_id' => $user->id]);

    // 2. Register member
    $response = $this->postJson('/api/v1/members/register', [
        'user_id' => $user->id,
        'membership_type' => 'quarterly',
        'payment_method' => 'transfer'
    ]);

    // 3. Verify response
    $response->assertStatus(201)
        ->assertJsonStructure([
            'success',
            'message',
            'data' => [
                'member',
                'total_amount',
                'breakdown',
                'payment'
            ]
        ]);

    // 4. Verify database
    $this->assertDatabaseHas('members', [
        'user_id' => $user->id,
        'status' => 'active',
        'membership_type' => 'quarterly'
    ]);

    // 5. Verify payment record
    $this->assertDatabaseHas('member_payments', [
        'member_id' => $response->json('data.member.id'),
        'payment_type' => 'registration',
        'amount' => 495000
    ]);
}
```

#### Status Change Automation Testing

```php
// Test automatic status change
public function test_automatic_status_change()
{
    // 1. Create expired member
    $member = Member::factory()->create([
        'status' => 'active',
        'membership_end' => now()->subDays(1)
    ]);

    // 2. Run status change job
    $this->artisan('members:check-expired');

    // 3. Verify status change
    $member->refresh();
    $this->assertEquals('inactive', $member->status);

    // 4. Verify status history
    $this->assertDatabaseHas('member_status_history', [
        'member_id' => $member->id,
        'previous_status' => 'active',
        'new_status' => 'inactive',
        'change_type' => 'automatic'
    ]);
}
```

### 6. **Performance Testing**

#### Database Performance

```sql
-- Test query performance
EXPLAIN SELECT * FROM members WHERE status = 'active';
EXPLAIN SELECT * FROM member_payments WHERE payment_status = 'pending';
EXPLAIN SELECT * FROM member_status_history WHERE member_id = 1;

-- Test index usage
SHOW INDEX FROM members;
SHOW INDEX FROM member_payments;
SHOW INDEX FROM member_status_history;
```

#### API Performance

```bash
# Test API response time
time curl -X GET http://localhost:8000/api/v1/members/1 \
  -H "Authorization: Bearer {token}"

# Test bulk operations
for i in {1..100}; do
  curl -X POST http://localhost:8000/api/v1/members/register \
    -H "Authorization: Bearer {token}" \
    -H "Content-Type: application/json" \
    -d '{
      "user_id": '$i',
      "membership_type": "monthly",
      "payment_method": "transfer"
    }' &
done
wait
```

### 7. **Error Handling Testing**

#### Validation Testing

```php
// Test invalid registration data
$response = $this->postJson('/api/v1/members/register', [
    'user_id' => 'invalid',
    'membership_type' => 'invalid_type'
]);

$response->assertStatus(422)
    ->assertJsonValidationErrors(['user_id', 'membership_type']);

// Test unauthorized access
$response = $this->getJson('/api/v1/admin/config/member');
$response->assertStatus(401);
```

#### Database Constraint Testing

```php
// Test foreign key constraints
$this->expectException(QueryException::class);
Member::create([
    'user_id' => 99999, // Non-existent user
    'user_profile_id' => 1,
    'member_code' => 'TEST001'
]);
```

## 🚀 Running Tests

### Automated Testing

```bash
# Run all tests
php artisan test

# Run specific test file
php artisan test tests/Feature/MemberSchemaRevisionTest.php

# Run with coverage
php artisan test --coverage

# Run specific test method
php artisan test --filter test_member_registration
```

### Manual Testing Script

```bash
# Run comprehensive test script
./scripts/test-member-schema-revision.sh

# Expected output
🧪 Testing Member Schema Revision v2
======================================
✅ Migration status check
✅ Model files check
✅ Seeder file check
✅ Basic functionality test
✅ Database tables check
✅ Default configurations check
✅ Member creation test

📊 Test Summary
===============
Tests passed: 7/7
🎉 All tests passed! Member Schema Revision v2 is working correctly.
```

### Database Testing

```bash
# Test database connection
php artisan tinker --execute="DB::connection()->getPdo();"

# Test model relationships
php artisan tinker --execute="
\$member = App\Models\Member::first();
echo 'Member: ' . \$member->member_code . PHP_EOL;
echo 'User: ' . \$member->user->name . PHP_EOL;
echo 'Profile: ' . \$member->userProfile->phone . PHP_EOL;
"
```

## 📊 Test Coverage

### Required Coverage

-   **Models**: 100% coverage
-   **Business Logic**: 100% coverage
-   **API Endpoints**: 100% coverage
-   **Database Operations**: 100% coverage

### Coverage Report

```bash
# Generate coverage report
php artisan test --coverage --coverage-html=storage/coverage

# View coverage report
open storage/coverage/index.html
```

## 🐛 Debugging

### Common Issues

1. **Foreign Key Constraints**: Pastikan semua referensi valid
2. **Configuration Missing**: Pastikan seeder sudah dijalankan
3. **Status Change Logic**: Pastikan business logic sesuai dengan requirements
4. **Payment Calculation**: Pastikan kalkulasi harga sesuai dengan konfigurasi

### Debug Commands

```bash
# Check migration status
php artisan migrate:status

# Check configuration
php artisan tinker --execute="
\$configs = App\Models\SystemConfiguration::getMemberConfig();
print_r(\$configs);
"

# Check member status
php artisan tinker --execute="
\$members = App\Models\Member::with('user')->get();
foreach(\$members as \$member) {
    echo \$member->member_code . ' - ' . \$member->status . PHP_EOL;
}
"
```

## 📚 Related Documentation

-   [Member Schema Revision Implementation](../development/member-schema-revision-v2.md)
-   [Member Schema Revision API](../api/member-schema-revision-api.md)
-   [Testing Coverage Guide](coverage-guide.md)
-   [Test Helpers](test-helpers.md)

---

**Version**: 2.0  
**Date**: September 10, 2025  
**Status**: Implementation Complete  
**Author**: Development Team
