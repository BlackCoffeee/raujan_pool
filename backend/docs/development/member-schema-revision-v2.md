# Member Schema Revision v2 - Implementation Summary

## 📋 Overview

Implementasi revisi schema database untuk member management system yang mencakup:

1. **Biaya registrasi dinamis** yang dapat dikonfigurasi admin
2. **Status member** yang berubah dari Active → Inactive → Non-Member
3. **Grace period** yang dapat dikonfigurasi admin (default 3 bulan)
4. **Biaya pendaftaran ulang** untuk reaktivasi member

## 🗄️ Database Schema Changes

### 1. **System Configuration Table**

Tabel baru untuk menyimpan konfigurasi sistem yang dapat diubah admin:

```sql
CREATE TABLE system_configurations (
    id INT PRIMARY KEY AUTO_INCREMENT,
    config_key VARCHAR(100) UNIQUE NOT NULL,
    config_value TEXT NOT NULL,
    config_type ENUM('string', 'integer', 'decimal', 'boolean', 'json') NOT NULL,
    description TEXT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    created_by INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);
```

### 2. **Pricing Configuration Table**

Tabel untuk menyimpan konfigurasi harga membership:

```sql
CREATE TABLE pricing_config (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) UNIQUE,
    membership_type ENUM('monthly', 'quarterly') DEFAULT 'monthly',
    registration_fee DECIMAL(10,2) DEFAULT 0.00,
    monthly_fee DECIMAL(10,2) DEFAULT 0.00,
    quarterly_fee DECIMAL(10,2) DEFAULT 0.00,
    quarterly_discount_percentage DECIMAL(5,2) DEFAULT 0.00,
    reactivation_fee DECIMAL(10,2) DEFAULT 0.00,
    is_active BOOLEAN DEFAULT TRUE,
    description TEXT NULL,
    created_by INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);
```

### 3. **Members Table (Updated)**

Schema baru untuk tabel members dengan field yang diperbarui:

```sql
CREATE TABLE members (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    user_profile_id INT NOT NULL,
    member_code VARCHAR(10) UNIQUE,

    -- Status Management
    status ENUM('active', 'inactive', 'non_member') DEFAULT 'active',
    is_active BOOLEAN GENERATED ALWAYS AS (status = 'active') STORED,

    -- Membership Period
    membership_start DATE NOT NULL,
    membership_end DATE NOT NULL,
    membership_type ENUM('monthly', 'quarterly') DEFAULT 'monthly',

    -- Registration Information
    registration_method ENUM('manual', 'google_sso', 'guest_conversion') DEFAULT 'manual',
    converted_from_guest_id INT NULL,

    -- Payment Information
    pricing_package_id INT NULL,
    registration_fee_paid DECIMAL(10,2) DEFAULT 0.00,
    monthly_fee_paid DECIMAL(10,2) DEFAULT 0.00,
    total_paid DECIMAL(10,2) DEFAULT 0.00,

    -- Status Change Tracking
    status_changed_at TIMESTAMP NULL,
    status_changed_by INT NULL,
    status_change_reason TEXT NULL,

    -- Grace Period Tracking
    grace_period_start DATE NULL,
    grace_period_end DATE NULL,
    grace_period_days INT DEFAULT 90,

    -- Reactivation Information
    reactivation_count INT DEFAULT 0,
    last_reactivation_date TIMESTAMP NULL,
    last_reactivation_fee DECIMAL(10,2) DEFAULT 0.00,

    -- Audit Fields
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);
```

### 4. **Member Status History Table**

Tabel untuk tracking perubahan status member:

```sql
CREATE TABLE member_status_history (
    id INT PRIMARY KEY AUTO_INCREMENT,
    member_id INT NOT NULL,
    previous_status ENUM('active', 'inactive', 'non_member') NULL,
    new_status ENUM('active', 'inactive', 'non_member') NOT NULL,
    change_reason TEXT NULL,
    change_type ENUM('automatic', 'manual', 'payment', 'reactivation') NOT NULL,
    changed_by INT NULL,
    changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    membership_end_date DATE NULL,
    grace_period_end_date DATE NULL,
    payment_amount DECIMAL(10,2) DEFAULT 0.00,
    payment_reference VARCHAR(100) NULL
);
```

### 5. **Member Payments Table**

Tabel untuk tracking pembayaran member:

```sql
CREATE TABLE member_payments (
    id INT PRIMARY KEY AUTO_INCREMENT,
    member_id INT NOT NULL,
    payment_type ENUM('registration', 'monthly', 'quarterly', 'reactivation', 'penalty'),
    amount DECIMAL(10,2) NOT NULL,
    payment_method ENUM('cash', 'transfer', 'credit_card', 'debit_card'),
    payment_reference VARCHAR(100) NULL,
    payment_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    payment_status ENUM('pending', 'paid', 'failed', 'refunded') DEFAULT 'pending',
    description TEXT NULL,
    notes TEXT NULL,
    processed_by INT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);
```

## 🔧 Models Implementation

### 1. **Member Model**

Model Member yang telah diperbarui dengan method dan relationship baru:

```php
class Member extends Model
{
    // Relationships
    public function userProfile()
    public function pricingPackage()
    public function statusHistory()
    public function payments()

    // Methods
    public function generateMemberCode()
    public function changeStatus($newStatus, $reason, $changedBy, $changeType)
    public function startGracePeriod($days)
    public function reactivate($paymentAmount, $paymentReference)
    public function renewMembership($newEndDate, $paymentAmount, $paymentType)

    // Static methods
    public static function createNewMember($userData, $membershipType, $registrationMethod)
}
```

### 2. **SystemConfiguration Model**

Model untuk mengelola konfigurasi sistem:

```php
class SystemConfiguration extends Model
{
    // Static methods
    public static function get($key, $default = null)
    public static function set($key, $value, $type, $description, $createdBy)
    public static function getMemberConfig()
    public static function updateMemberConfig($configs, $updatedBy)
}
```

### 3. **PricingConfig Model**

Model untuk mengelola konfigurasi harga:

```php
class PricingConfig extends Model
{
    // Methods
    public function calculateTotalPrice($membershipType, $includeRegistration)
    public function calculateReactivationPrice($membershipType)
    public function getPriceBreakdown($membershipType, $includeRegistration)
    public function getReactivationBreakdown($membershipType)

    // Static methods
    public static function getActiveConfig($membershipType)
    public static function createDefaultConfigs($createdBy)
}
```

### 4. **MemberStatusHistory Model**

Model untuk tracking perubahan status:

```php
class MemberStatusHistory extends Model
{
    // Static methods
    public static function recordStatusChange($memberId, $newStatus, $previousStatus, $changeType, $reason, $changedBy, $paymentAmount, $paymentReference)
    public static function getMemberHistory($memberId, $limit)
    public static function getStatusChangeStats($startDate, $endDate)
}
```

### 5. **MemberPayment Model**

Model untuk mengelola pembayaran member:

```php
class MemberPayment extends Model
{
    // Methods
    public function markAsPaid($processedBy)
    public function markAsFailed($reason)
    public function markAsRefunded($reason, $processedBy)

    // Static methods
    public static function createPayment($memberId, $paymentType, $amount, $paymentMethod, $description, $notes, $processedBy)
    public static function getMemberPayments($memberId, $limit)
    public static function getPaymentStats($startDate, $endDate)
    public static function getTotalRevenue($startDate, $endDate)
}
```

## ⚙️ System Configuration Defaults

Konfigurasi default yang telah di-seed:

```php
[
    'member_registration_fee' => 50000,
    'member_grace_period_days' => 90,
    'member_monthly_fee' => 200000,
    'member_quarterly_fee' => 500000,
    'member_quarterly_discount' => 10,
    'member_reactivation_fee' => 50000,
    'member_auto_status_change' => true,
    'member_notification_days_before_expiry' => 7,
    'member_notification_days_after_expiry' => 3,
]
```

## 🔄 Member Lifecycle Flow

### 1. **Registration Process**

```
User Registration → Pay Registration Fee → Pay Monthly/Quarterly Fee → Status: Active
```

### 2. **Status Change Flow**

```
Active Member → Membership Expired? → Status: Inactive → Grace Period Expired? → Status: Non-Member → Reactivation Required
```

### 3. **Payment Flow**

-   **New Member Monthly**: Registration Fee (50,000) + Monthly Fee (200,000) = 250,000
-   **New Member Quarterly**: Registration Fee (50,000) + Quarterly Fee (500,000) - Discount 10% (55,000) = 495,000
-   **Reactivation Monthly**: Reactivation Fee (50,000) + Monthly Fee (200,000) = 250,000
-   **Reactivation Quarterly**: Reactivation Fee (50,000) + Quarterly Fee (500,000) - Discount 10% (55,000) = 495,000

## 🧪 Testing

Test file telah dibuat di `tests/Feature/MemberSchemaRevisionTest.php` dengan test cases:

-   ✅ New member creation with new schema
-   ✅ Member status change functionality
-   ✅ Member reactivation process
-   ✅ Pricing calculation accuracy
-   ✅ System configuration management

## 📊 Business Rules

### 1. **Registration Rules**

-   Registration Fee: Dinamis, dapat diubah admin
-   Monthly Fee: Dinamis, dapat diubah admin
-   Quarterly Fee: Dinamis, dapat diubah admin
-   Quarterly Discount: Persentase diskon dinamis (default 10%)
-   Status: Setelah pembayaran lengkap → `active`

### 2. **Status Change Rules**

-   Active → Inactive: Otomatis saat membership berakhir
-   Inactive → Non-Member: Setelah grace period (default 3 bulan)
-   Grace Period: Dapat dikonfigurasi admin (default 90 hari)
-   Status Change: Dicatat di `member_status_history`

### 3. **Reactivation Rules**

-   Non-Member → Active: Membutuhkan pembayaran reactivation fee
-   Reactivation Fee: Dinamis, dapat diubah admin
-   Reactivation Count: Dicatat untuk tracking

### 4. **Payment Rules**

-   Registration Payment: Wajib untuk member baru
-   Monthly Payment: Wajib untuk perpanjangan
-   Quarterly Payment: Wajib untuk perpanjangan dengan diskon
-   Reactivation Payment: Wajib untuk reaktivasi
-   Payment History: Dicatat di `member_payments`

## 🚀 Migration Strategy

Migration telah berhasil dijalankan dengan urutan:

1. ✅ Create system_configurations table
2. ✅ Create pricing_config table
3. ✅ Drop foreign key constraints
4. ✅ Recreate members table with new schema
5. ✅ Create member_status_history table
6. ✅ Create member_payments table
7. ✅ Seed default configurations

## 📈 Implementation Status

### ✅ **Completed**

-   [x] Database schema migration
-   [x] Model implementation
-   [x] System configuration seeder
-   [x] Basic testing
-   [x] Documentation

### 🔄 **Next Steps**

-   [ ] API endpoint implementation
-   [ ] Admin interface for configuration
-   [ ] Automated status change jobs
-   [ ] Notification system integration
-   [ ] Comprehensive testing

## 📚 Related Files

-   **Migrations**: `database/migrations/2025_09_10_*`
-   **Models**: `app/Models/Member.php`, `app/Models/SystemConfiguration.php`, dll
-   **Seeder**: `database/seeders/SystemConfigurationSeeder.php`
-   **Tests**: `tests/Feature/MemberSchemaRevisionTest.php`
-   **Plan**: `plan/05-desain-database-v2-member-schema-revision.md`

---

**Version**: 2.0  
**Date**: September 10, 2025  
**Status**: Implementation Complete  
**Author**: Development Team
