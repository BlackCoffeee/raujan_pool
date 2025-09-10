# Phase 2 Revision: Member Schema Revision - Implementation Plan

## 📋 Overview

Implementasi revisi skema member untuk mengakomodasi perubahan bisnis yang meliputi biaya registrasi dinamis, status member lifecycle, dan sistem reaktivasi.

## 🎯 Objectives

1. **Dynamic Registration Fee**: Admin dapat mengatur biaya registrasi
2. **Member Status Lifecycle**: Active → Inactive → Non-Member
3. **Configurable Grace Period**: Admin dapat mengatur periode tenggang
4. **Reactivation System**: Sistem reaktivasi dengan biaya terpisah

## 📊 Implementation Status

**Status**: 🚧 **IN PROGRESS**  
**Start Date**: January 15, 2025  
**Estimated Duration**: 2-3 weeks  
**Priority**: High

## 🗄️ Database Changes

### 1. **New Tables to Create**

#### **system_configurations**

```sql
-- File: database/migrations/2025_01_15_000001_create_system_configurations_table.php
CREATE TABLE system_configurations (
    id INT PRIMARY KEY AUTO_INCREMENT,
    config_key VARCHAR(100) UNIQUE NOT NULL,
    config_value TEXT NOT NULL,
    config_type ENUM('string', 'integer', 'decimal', 'boolean', 'json') NOT NULL,
    description TEXT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    created_by INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    FOREIGN KEY (created_by) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_config_key (config_key),
    INDEX idx_config_type (config_type),
    INDEX idx_is_active (is_active)
);
```

#### **member_status_history**

```sql
-- File: database/migrations/2025_01_15_000002_create_member_status_history_table.php
CREATE TABLE member_status_history (
    id INT PRIMARY KEY AUTO_INCREMENT,
    member_id INT NOT NULL,
    previous_status ENUM('active', 'inactive', 'non_member') NULL,
    new_status ENUM('active', 'inactive', 'non_member') NOT NULL,
    change_reason TEXT NULL,
    change_type ENUM('automatic', 'manual', 'payment', 'reactivation') NOT NULL,
    changed_by INT NULL,
    changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    -- Additional context
    membership_end_date DATE NULL,
    grace_period_end_date DATE NULL,
    payment_amount DECIMAL(10,2) DEFAULT 0.00,
    payment_reference VARCHAR(100) NULL,

    FOREIGN KEY (member_id) REFERENCES members(id) ON DELETE CASCADE,
    FOREIGN KEY (changed_by) REFERENCES users(id) ON DELETE SET NULL,

    INDEX idx_member_id (member_id),
    INDEX idx_new_status (new_status),
    INDEX idx_change_type (change_type),
    INDEX idx_changed_at (changed_at)
);
```

#### **member_payments**

```sql
-- File: database/migrations/2025_01_15_000003_create_member_payments_table.php
CREATE TABLE member_payments (
    id INT PRIMARY KEY AUTO_INCREMENT,
    member_id INT NOT NULL,
    payment_type ENUM('registration', 'monthly', 'quarterly', 'reactivation', 'penalty') NOT NULL,
    amount DECIMAL(10,2) NOT NULL,
    payment_method ENUM('cash', 'transfer', 'credit_card', 'debit_card') NOT NULL,
    payment_reference VARCHAR(100) NULL,
    payment_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    payment_status ENUM('pending', 'paid', 'failed', 'refunded') DEFAULT 'pending',

    -- Payment details
    description TEXT NULL,
    notes TEXT NULL,
    processed_by INT NULL,

    -- Audit fields
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    FOREIGN KEY (member_id) REFERENCES members(id) ON DELETE CASCADE,
    FOREIGN KEY (processed_by) REFERENCES users(id) ON DELETE SET NULL,

    INDEX idx_member_id (member_id),
    INDEX idx_payment_type (payment_type),
    INDEX idx_payment_status (payment_status),
    INDEX idx_payment_date (payment_date)
);
```

### 2. **Members Table Update**

```sql
-- File: database/migrations/2025_01_15_000004_update_members_table_schema.php
-- Drop existing members table and recreate with new schema
DROP TABLE IF EXISTS members;

CREATE TABLE members (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    user_profile_id INT NOT NULL,
    member_code VARCHAR(10) UNIQUE NOT NULL,

    -- Status Management
    status ENUM('active', 'inactive', 'non_member') DEFAULT 'active',
    is_active BOOLEAN GENERATED ALWAYS AS (status = 'active') STORED,

    -- Membership Period
    membership_start DATE NOT NULL,
    membership_end DATE NOT NULL,
    membership_type ENUM('monthly', 'quarterly') NOT NULL,

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
    grace_period_days INT DEFAULT 90, -- 3 months default

    -- Reactivation Information
    reactivation_count INT DEFAULT 0,
    last_reactivation_date TIMESTAMP NULL,
    last_reactivation_fee DECIMAL(10,2) DEFAULT 0.00,

    -- Audit Fields
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (user_profile_id) REFERENCES user_profiles(id) ON DELETE CASCADE,
    FOREIGN KEY (pricing_package_id) REFERENCES pricing_config(id),
    FOREIGN KEY (converted_from_guest_id) REFERENCES guest_users(id) ON DELETE SET NULL,
    FOREIGN KEY (status_changed_by) REFERENCES users(id) ON DELETE SET NULL,

    INDEX idx_member_code (member_code),
    INDEX idx_status (status),
    INDEX idx_is_active (is_active),
    INDEX idx_membership_end (membership_end),
    INDEX idx_grace_period_end (grace_period_end),
    INDEX idx_status_changed_at (status_changed_at),
    INDEX idx_registration_method (registration_method)
);
```

### 3. **Default Configuration Seeder**

```php
// File: database/seeders/SystemConfigurationSeeder.php
<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;

class SystemConfigurationSeeder extends Seeder
{
    public function run()
    {
        $configurations = [
            [
                'config_key' => 'member_registration_fee',
                'config_value' => '50000',
                'config_type' => 'decimal',
                'description' => 'Biaya registrasi member baru (dapat diubah admin)',
                'created_by' => 1
            ],
            [
                'config_key' => 'member_grace_period_days',
                'config_value' => '90',
                'config_type' => 'integer',
                'description' => 'Periode tenggang sebelum status berubah ke non_member (dalam hari)',
                'created_by' => 1
            ],
            [
                'config_key' => 'member_monthly_fee',
                'config_value' => '200000',
                'config_type' => 'decimal',
                'description' => 'Biaya bulanan membership (dapat diubah admin)',
                'created_by' => 1
            ],
            [
                'config_key' => 'member_quarterly_fee',
                'config_value' => '500000',
                'config_type' => 'decimal',
                'description' => 'Biaya triwulan membership (dapat diubah admin)',
                'created_by' => 1
            ],
            [
                'config_key' => 'member_quarterly_discount',
                'config_value' => '10',
                'config_type' => 'decimal',
                'description' => 'Diskon untuk pembayaran triwulan (dalam persen)',
                'created_by' => 1
            ],
            [
                'config_key' => 'member_reactivation_fee',
                'config_value' => '50000',
                'config_type' => 'decimal',
                'description' => 'Biaya reaktivasi member non-aktif (dapat diubah admin)',
                'created_by' => 1
            ],
            [
                'config_key' => 'member_auto_status_change',
                'config_value' => 'true',
                'config_type' => 'boolean',
                'description' => 'Otomatis ubah status member berdasarkan grace period',
                'created_by' => 1
            ],
            [
                'config_key' => 'member_notification_days_before_expiry',
                'config_value' => '7',
                'config_type' => 'integer',
                'description' => 'Notifikasi berapa hari sebelum membership berakhir',
                'created_by' => 1
            ],
            [
                'config_key' => 'member_notification_days_after_expiry',
                'config_value' => '3',
                'config_type' => 'integer',
                'description' => 'Notifikasi berapa hari setelah membership berakhir',
                'created_by' => 1
            ]
        ];

        DB::table('system_configurations')->insert($configurations);
    }
}
```

## 🏗️ Model Updates

### 1. **SystemConfiguration Model**

```php
// File: app/Models/SystemConfiguration.php
<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class SystemConfiguration extends Model
{
    use HasFactory;

    protected $fillable = [
        'config_key',
        'config_value',
        'config_type',
        'description',
        'is_active',
        'created_by'
    ];

    protected $casts = [
        'is_active' => 'boolean',
        'created_at' => 'datetime',
        'updated_at' => 'datetime'
    ];

    public function creator(): BelongsTo
    {
        return $this->belongsTo(User::class, 'created_by');
    }

    // Helper methods
    public function getValueAttribute()
    {
        return match($this->config_type) {
            'boolean' => filter_var($this->config_value, FILTER_VALIDATE_BOOLEAN),
            'integer' => (int) $this->config_value,
            'decimal' => (float) $this->config_value,
            'json' => json_decode($this->config_value, true),
            default => $this->config_value
        };
    }

    public static function getConfig(string $key, $default = null)
    {
        $config = static::where('config_key', $key)
            ->where('is_active', true)
            ->first();

        return $config ? $config->value : $default;
    }

    public static function setConfig(string $key, $value, string $type = 'string', string $description = null)
    {
        $configValue = match($type) {
            'boolean' => $value ? 'true' : 'false',
            'json' => json_encode($value),
            default => (string) $value
        };

        return static::updateOrCreate(
            ['config_key' => $key],
            [
                'config_value' => $configValue,
                'config_type' => $type,
                'description' => $description,
                'is_active' => true
            ]
        );
    }
}
```

### 2. **Member Model Update**

```php
// File: app/Models/Member.php (Updated)
<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Carbon\Carbon;

class Member extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id',
        'user_profile_id',
        'member_code',
        'status',
        'membership_start',
        'membership_end',
        'membership_type',
        'registration_method',
        'converted_from_guest_id',
        'pricing_package_id',
        'registration_fee_paid',
        'monthly_fee_paid',
        'total_paid',
        'status_changed_at',
        'status_changed_by',
        'status_change_reason',
        'grace_period_start',
        'grace_period_end',
        'grace_period_days',
        'reactivation_count',
        'last_reactivation_date',
        'last_reactivation_fee'
    ];

    protected $casts = [
        'membership_start' => 'date',
        'membership_end' => 'date',
        'grace_period_start' => 'date',
        'grace_period_end' => 'date',
        'status_changed_at' => 'datetime',
        'last_reactivation_date' => 'datetime',
        'registration_fee_paid' => 'decimal:2',
        'monthly_fee_paid' => 'decimal:2',
        'total_paid' => 'decimal:2',
        'last_reactivation_fee' => 'decimal:2',
        'created_at' => 'datetime',
        'updated_at' => 'datetime'
    ];

    // Relationships
    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    public function userProfile(): BelongsTo
    {
        return $this->belongsTo(UserProfile::class);
    }

    public function statusHistory(): HasMany
    {
        return $this->hasMany(MemberStatusHistory::class);
    }

    public function payments(): HasMany
    {
        return $this->hasMany(MemberPayment::class);
    }

    public function statusChangedBy(): BelongsTo
    {
        return $this->belongsTo(User::class, 'status_changed_by');
    }

    // Accessors
    public function getIsActiveAttribute(): bool
    {
        return $this->status === 'active';
    }

    public function getIsExpiredAttribute(): bool
    {
        return $this->membership_end < Carbon::today();
    }

    public function getIsInGracePeriodAttribute(): bool
    {
        if (!$this->is_expired) {
            return false;
        }

        $gracePeriodEnd = $this->grace_period_end ??
            $this->membership_end->addDays($this->grace_period_days);

        return Carbon::today() <= $gracePeriodEnd;
    }

    public function getDaysUntilExpiryAttribute(): int
    {
        return max(0, Carbon::today()->diffInDays($this->membership_end, false));
    }

    public function getDaysInGracePeriodAttribute(): int
    {
        if (!$this->is_expired) {
            return 0;
        }

        $gracePeriodEnd = $this->grace_period_end ??
            $this->membership_end->addDays($this->grace_period_days);

        return max(0, Carbon::today()->diffInDays($gracePeriodEnd, false));
    }

    // Scopes
    public function scopeActive($query)
    {
        return $query->where('status', 'active');
    }

    public function scopeInactive($query)
    {
        return $query->where('status', 'inactive');
    }

    public function scopeNonMember($query)
    {
        return $query->where('status', 'non_member');
    }

    public function scopeExpired($query)
    {
        return $query->where('membership_end', '<', Carbon::today());
    }

    public function scopeInGracePeriod($query)
    {
        return $query->where('status', 'inactive')
            ->where(function($q) {
                $q->where('grace_period_end', '>=', Carbon::today())
                  ->orWhereRaw('DATE_ADD(membership_end, INTERVAL grace_period_days DAY) >= ?', [Carbon::today()]);
            });
    }

    // Methods
    public function changeStatus(string $newStatus, string $reason = null, int $changedBy = null, string $changeType = 'manual')
    {
        $previousStatus = $this->status;

        $this->update([
            'status' => $newStatus,
            'status_changed_at' => now(),
            'status_changed_by' => $changedBy,
            'status_change_reason' => $reason
        ]);

        // Record status change history
        $this->statusHistory()->create([
            'previous_status' => $previousStatus,
            'new_status' => $newStatus,
            'change_reason' => $reason,
            'change_type' => $changeType,
            'changed_by' => $changedBy,
            'membership_end_date' => $this->membership_end,
            'grace_period_end_date' => $this->grace_period_end
        ]);

        return $this;
    }

    public function calculateRegistrationFee(): float
    {
        return (float) SystemConfiguration::getConfig('member_registration_fee', 50000);
    }

    public function calculateMonthlyFee(): float
    {
        return (float) SystemConfiguration::getConfig('member_monthly_fee', 200000);
    }

    public function calculateQuarterlyFee(): float
    {
        return (float) SystemConfiguration::getConfig('member_quarterly_fee', 500000);
    }

    public function calculateReactivationFee(): float
    {
        return (float) SystemConfiguration::getConfig('member_reactivation_fee', 50000);
    }

    public function getTotalRegistrationAmount(): float
    {
        $registrationFee = $this->calculateRegistrationFee();
        $membershipFee = $this->membership_type === 'monthly'
            ? $this->calculateMonthlyFee()
            : $this->calculateQuarterlyFee();

        $subtotal = $registrationFee + $membershipFee;

        // Apply quarterly discount if applicable
        if ($this->membership_type === 'quarterly') {
            $discountPercentage = SystemConfiguration::getConfig('member_quarterly_discount', 10);
            $discountAmount = $subtotal * ($discountPercentage / 100);
            return $subtotal - $discountAmount;
        }

        return $subtotal;
    }

    public function getTotalReactivationAmount(): float
    {
        $reactivationFee = $this->calculateReactivationFee();
        $membershipFee = $this->membership_type === 'monthly'
            ? $this->calculateMonthlyFee()
            : $this->calculateQuarterlyFee();

        $subtotal = $reactivationFee + $membershipFee;

        // Apply quarterly discount if applicable
        if ($this->membership_type === 'quarterly') {
            $discountPercentage = SystemConfiguration::getConfig('member_quarterly_discount', 10);
            $discountAmount = $subtotal * ($discountPercentage / 100);
            return $subtotal - $discountAmount;
        }

        return $subtotal;
    }

    public function getRegistrationBreakdown(): array
    {
        $registrationFee = $this->calculateRegistrationFee();
        $membershipFee = $this->membership_type === 'monthly'
            ? $this->calculateMonthlyFee()
            : $this->calculateQuarterlyFee();

        $subtotal = $registrationFee + $membershipFee;

        if ($this->membership_type === 'quarterly') {
            $discountPercentage = SystemConfiguration::getConfig('member_quarterly_discount', 10);
            $discountAmount = $subtotal * ($discountPercentage / 100);
            $finalAmount = $subtotal - $discountAmount;

            return [
                'registration_fee' => $registrationFee,
                'quarterly_fee' => $membershipFee,
                'subtotal' => $subtotal,
                'discount_percentage' => $discountPercentage,
                'discount_amount' => $discountAmount,
                'final_amount' => $finalAmount
            ];
        }

        return [
            'registration_fee' => $registrationFee,
            'monthly_fee' => $membershipFee,
            'total_amount' => $subtotal
        ];
    }

    public function getReactivationBreakdown(): array
    {
        $reactivationFee = $this->calculateReactivationFee();
        $membershipFee = $this->membership_type === 'monthly'
            ? $this->calculateMonthlyFee()
            : $this->calculateQuarterlyFee();

        $subtotal = $reactivationFee + $membershipFee;

        if ($this->membership_type === 'quarterly') {
            $discountPercentage = SystemConfiguration::getConfig('member_quarterly_discount', 10);
            $discountAmount = $subtotal * ($discountPercentage / 100);
            $finalAmount = $subtotal - $discountAmount;

            return [
                'reactivation_fee' => $reactivationFee,
                'quarterly_fee' => $membershipFee,
                'subtotal' => $subtotal,
                'discount_percentage' => $discountPercentage,
                'discount_amount' => $discountAmount,
                'final_amount' => $finalAmount
            ];
        }

        return [
            'reactivation_fee' => $reactivationFee,
            'monthly_fee' => $membershipFee,
            'total_amount' => $subtotal
        ];
    }
}
```

### 3. **MemberStatusHistory Model**

```php
// File: app/Models/MemberStatusHistory.php
<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class MemberStatusHistory extends Model
{
    use HasFactory;

    protected $fillable = [
        'member_id',
        'previous_status',
        'new_status',
        'change_reason',
        'change_type',
        'changed_by',
        'membership_end_date',
        'grace_period_end_date',
        'payment_amount',
        'payment_reference'
    ];

    protected $casts = [
        'membership_end_date' => 'date',
        'grace_period_end_date' => 'date',
        'payment_amount' => 'decimal:2',
        'changed_at' => 'datetime'
    ];

    public function member(): BelongsTo
    {
        return $this->belongsTo(Member::class);
    }

    public function changedBy(): BelongsTo
    {
        return $this->belongsTo(User::class, 'changed_by');
    }
}
```

### 4. **MemberPayment Model**

```php
// File: app/Models/MemberPayment.php
<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class MemberPayment extends Model
{
    use HasFactory;

    protected $fillable = [
        'member_id',
        'payment_type',
        'amount',
        'payment_method',
        'payment_reference',
        'payment_status',
        'description',
        'notes',
        'processed_by'
    ];

    protected $casts = [
        'amount' => 'decimal:2',
        'payment_date' => 'datetime',
        'created_at' => 'datetime',
        'updated_at' => 'datetime'
    ];

    public function member(): BelongsTo
    {
        return $this->belongsTo(Member::class);
    }

    public function processedBy(): BelongsTo
    {
        return $this->belongsTo(User::class, 'processed_by');
    }
}
```

## 🔧 Service Layer Updates

### 1. **MemberService Update**

```php
// File: app/Services/MemberService.php (Updated)
<?php

namespace App\Services;

use App\Models\Member;
use App\Models\MemberPayment;
use App\Models\MemberStatusHistory;
use App\Models\SystemConfiguration;
use App\Models\User;
use Carbon\Carbon;
use Illuminate\Support\Facades\DB;

class MemberService
{
    public function registerMember(array $data): Member
    {
        return DB::transaction(function () use ($data) {
            // Calculate fees
            $registrationFee = SystemConfiguration::getConfig('member_registration_fee', 50000);
            $monthlyFee = SystemConfiguration::getConfig('member_monthly_fee', 200000);
            $quarterlyFee = SystemConfiguration::getConfig('member_quarterly_fee', 500000);

            $membershipFee = $data['membership_type'] === 'monthly' ? $monthlyFee : $quarterlyFee;
            $subtotal = $registrationFee + $membershipFee;

            // Apply quarterly discount if applicable
            $totalAmount = $subtotal;
            if ($data['membership_type'] === 'quarterly') {
                $discountPercentage = SystemConfiguration::getConfig('member_quarterly_discount', 10);
                $discountAmount = $subtotal * ($discountPercentage / 100);
                $totalAmount = $subtotal - $discountAmount;
            }

            // Create member
            $member = Member::create([
                'user_id' => $data['user_id'],
                'user_profile_id' => $data['user_profile_id'],
                'member_code' => $this->generateMemberCode(),
                'status' => 'active',
                'membership_start' => Carbon::today(),
                'membership_end' => $this->calculateMembershipEnd($data['membership_type']),
                'membership_type' => $data['membership_type'],
                'registration_method' => $data['registration_method'] ?? 'manual',
                'registration_fee_paid' => $registrationFee,
                'monthly_fee_paid' => $membershipFee,
                'total_paid' => $totalAmount,
                'status_changed_at' => now(),
                'status_changed_by' => $data['created_by'] ?? null
            ]);

            // Record payments
            $this->recordPayment($member, 'registration', $registrationFee, $data['payment_method']);
            $this->recordPayment($member, $data['membership_type'], $membershipFee, $data['payment_method']);

            // Record status history
            $member->statusHistory()->create([
                'previous_status' => null,
                'new_status' => 'active',
                'change_reason' => 'Member registration completed',
                'change_type' => 'payment',
                'changed_by' => $data['created_by'] ?? null,
                'payment_amount' => $totalAmount
            ]);

            return $member;
        });
    }

    public function reactivateMember(int $memberId, array $data): Member
    {
        return DB::transaction(function () use ($memberId, $data) {
            $member = Member::findOrFail($memberId);

            if ($member->status !== 'non_member') {
                throw new \Exception('Only non-members can be reactivated');
            }

            // Calculate fees
            $reactivationFee = SystemConfiguration::getConfig('member_reactivation_fee', 50000);
            $monthlyFee = SystemConfiguration::getConfig('member_monthly_fee', 200000);
            $quarterlyFee = SystemConfiguration::getConfig('member_quarterly_fee', 500000);

            $membershipFee = $member->membership_type === 'monthly' ? $monthlyFee : $quarterlyFee;
            $subtotal = $reactivationFee + $membershipFee;

            // Apply quarterly discount if applicable
            $totalAmount = $subtotal;
            if ($member->membership_type === 'quarterly') {
                $discountPercentage = SystemConfiguration::getConfig('member_quarterly_discount', 10);
                $discountAmount = $subtotal * ($discountPercentage / 100);
                $totalAmount = $subtotal - $discountAmount;
            }

            // Update member
            $member->update([
                'status' => 'active',
                'membership_start' => Carbon::today(),
                'membership_end' => $this->calculateMembershipEnd($member->membership_type),
                'reactivation_count' => $member->reactivation_count + 1,
                'last_reactivation_date' => now(),
                'last_reactivation_fee' => $reactivationFee,
                'total_paid' => $member->total_paid + $totalAmount,
                'status_changed_at' => now(),
                'status_changed_by' => $data['processed_by'] ?? null
            ]);

            // Record payments
            $this->recordPayment($member, 'reactivation', $reactivationFee, $data['payment_method']);
            $this->recordPayment($member, $member->membership_type, $membershipFee, $data['payment_method']);

            // Record status history
            $member->statusHistory()->create([
                'previous_status' => 'non_member',
                'new_status' => 'active',
                'change_reason' => 'Member reactivated',
                'change_type' => 'reactivation',
                'changed_by' => $data['processed_by'] ?? null,
                'payment_amount' => $totalAmount
            ]);

            return $member;
        });
    }

    public function processExpiredMembers(): int
    {
        $processedCount = 0;
        $gracePeriodDays = SystemConfiguration::getConfig('member_grace_period_days', 90);

        // Find expired active members
        $expiredMembers = Member::active()
            ->where('membership_end', '<', Carbon::today())
            ->get();

        foreach ($expiredMembers as $member) {
            $member->changeStatus('inactive', 'Membership expired', null, 'automatic');
            $member->update([
                'grace_period_start' => $member->membership_end,
                'grace_period_end' => $member->membership_end->addDays($gracePeriodDays)
            ]);
            $processedCount++;
        }

        // Find members whose grace period has ended
        $gracePeriodExpired = Member::inactive()
            ->where(function($query) use ($gracePeriodDays) {
                $query->where('grace_period_end', '<', Carbon::today())
                      ->orWhereRaw('DATE_ADD(membership_end, INTERVAL grace_period_days DAY) < ?', [Carbon::today()]);
            })
            ->get();

        foreach ($gracePeriodExpired as $member) {
            $member->changeStatus('non_member', 'Grace period expired', null, 'automatic');
            $processedCount++;
        }

        return $processedCount;
    }

    private function generateMemberCode(): string
    {
        do {
            $code = 'M' . str_pad(rand(1, 99999), 5, '0', STR_PAD_LEFT);
        } while (Member::where('member_code', $code)->exists());

        return $code;
    }

    private function calculateMembershipEnd(string $type): Carbon
    {
        return match($type) {
            'monthly' => Carbon::today()->addMonth(),
            'quarterly' => Carbon::today()->addMonths(3),
            default => Carbon::today()->addMonth()
        };
    }

    private function recordPayment(Member $member, string $type, float $amount, string $method): MemberPayment
    {
        return $member->payments()->create([
            'payment_type' => $type,
            'amount' => $amount,
            'payment_method' => $method,
            'payment_status' => 'paid',
            'description' => ucfirst($type) . ' payment for member ' . $member->member_code,
            'processed_by' => auth()->id()
        ]);
    }
}
```

### 2. **SystemConfigurationService**

```php
// File: app/Services/SystemConfigurationService.php
<?php

namespace App\Services;

use App\Models\SystemConfiguration;
use Illuminate\Support\Facades\Cache;

class SystemConfigurationService
{
    public function getMemberConfigurations(): array
    {
        $keys = [
            'member_registration_fee',
            'member_grace_period_days',
            'member_monthly_fee',
            'member_quarterly_fee',
            'member_quarterly_discount',
            'member_reactivation_fee',
            'member_auto_status_change',
            'member_notification_days_before_expiry',
            'member_notification_days_after_expiry'
        ];

        $configurations = [];
        foreach ($keys as $key) {
            $configurations[$key] = $this->getConfig($key);
        }

        return $configurations;
    }

    public function updateMemberConfigurations(array $data): array
    {
        $updated = [];

        foreach ($data as $key => $value) {
            if (str_starts_with($key, 'member_')) {
                $config = SystemConfiguration::where('config_key', $key)->first();
                if ($config) {
                    $config->update(['config_value' => (string) $value]);
                    $updated[$key] = $value;

                    // Clear cache
                    Cache::forget("config.{$key}");
                }
            }
        }

        return $updated;
    }

    public function getConfig(string $key, $default = null)
    {
        return Cache::remember("config.{$key}", 3600, function () use ($key, $default) {
            return SystemConfiguration::getConfig($key, $default);
        });
    }

    public function setConfig(string $key, $value, string $type = 'string', string $description = null): SystemConfiguration
    {
        $config = SystemConfiguration::setConfig($key, $value, $type, $description);

        // Clear cache
        Cache::forget("config.{$key}");

        return $config;
    }
}
```

## 🔌 API Endpoints

### 1. **Member Registration Endpoint**

```php
// File: app/Http/Controllers/Api/V1/MemberController.php (Updated)
<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Http\Requests\MemberRegistrationRequest;
use App\Services\MemberService;
use Illuminate\Http\JsonResponse;

class MemberController extends Controller
{
    public function __construct(
        private MemberService $memberService
    ) {}

    public function register(MemberRegistrationRequest $request): JsonResponse
    {
        $member = $this->memberService->registerMember([
            'user_id' => $request->user_id,
            'user_profile_id' => $request->user_profile_id,
            'membership_type' => $request->membership_type,
            'payment_method' => $request->payment_method,
            'created_by' => auth()->id()
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Member registered successfully',
            'data' => [
                'member' => $member->load(['user', 'userProfile']),
                'total_amount' => $member->getTotalRegistrationAmount(),
                'breakdown' => $member->getRegistrationBreakdown()
            ]
        ], 201);
    }

    public function reactivate(int $id, MemberReactivationRequest $request): JsonResponse
    {
        $member = $this->memberService->reactivateMember($id, [
            'payment_method' => $request->payment_method,
            'processed_by' => auth()->id()
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Member reactivated successfully',
            'data' => [
                'member' => $member->load(['user', 'userProfile']),
                'total_amount' => $member->getTotalReactivationAmount(),
                'breakdown' => $member->getReactivationBreakdown()
            ]
        ]);
    }
}
```

### 2. **System Configuration Endpoints**

```php
// File: app/Http/Controllers/Api/V1/Admin/SystemConfigurationController.php
<?php

namespace App\Http\Controllers\Api\V1\Admin;

use App\Http\Controllers\Controller;
use App\Http\Requests\SystemConfigurationRequest;
use App\Services\SystemConfigurationService;
use Illuminate\Http\JsonResponse;

class SystemConfigurationController extends Controller
{
    public function __construct(
        private SystemConfigurationService $configService
    ) {}

    public function getMemberConfigurations(): JsonResponse
    {
        $configurations = $this->configService->getMemberConfigurations();

        return response()->json([
            'success' => true,
            'data' => $configurations
        ]);
    }

    public function updateMemberConfigurations(SystemConfigurationRequest $request): JsonResponse
    {
        $updated = $this->configService->updateMemberConfigurations($request->validated());

        return response()->json([
            'success' => true,
            'message' => 'Member configurations updated successfully',
            'data' => $updated
        ]);
    }
}
```

## 🧪 Testing

### 1. **Member Registration Test**

```php
// File: tests/Feature/MemberRegistrationTest.php
<?php

namespace Tests\Feature;

use App\Models\User;
use App\Models\UserProfile;
use App\Models\SystemConfiguration;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class MemberRegistrationTest extends TestCase
{
    use RefreshDatabase;

    public function test_member_registration_with_dynamic_fees()
    {
        // Setup configuration
        SystemConfiguration::setConfig('member_registration_fee', 75000, 'decimal');
        SystemConfiguration::setConfig('member_monthly_fee', 250000, 'decimal');

        $user = User::factory()->create();
        $profile = UserProfile::factory()->create(['user_id' => $user->id]);

        $response = $this->postJson('/api/v1/members/register', [
            'user_id' => $user->id,
            'user_profile_id' => $profile->id,
            'membership_type' => 'monthly',
            'payment_method' => 'transfer'
        ]);

        $response->assertStatus(201)
            ->assertJson([
                'success' => true,
                'data' => [
                    'total_amount' => 325000, // 75000 + 250000
                    'breakdown' => [
                        'registration_fee' => 75000,
                        'monthly_fee' => 250000,
                        'total_amount' => 325000
                    ]
                ]
            ]);

        $this->assertDatabaseHas('members', [
            'user_id' => $user->id,
            'status' => 'active',
            'registration_fee_paid' => 75000,
            'monthly_fee_paid' => 250000,
            'total_paid' => 325000
        ]);
    }

    public function test_member_reactivation_with_fees()
    {
        // Setup configuration
        SystemConfiguration::setConfig('member_reactivation_fee', 100000, 'decimal');
        SystemConfiguration::setConfig('member_monthly_fee', 200000, 'decimal');

        $user = User::factory()->create();
        $profile = UserProfile::factory()->create(['user_id' => $user->id]);
        $member = Member::factory()->create([
            'user_id' => $user->id,
            'user_profile_id' => $profile->id,
            'status' => 'non_member'
        ]);

        $response = $this->postJson("/api/v1/members/{$member->id}/reactivate", [
            'payment_method' => 'transfer'
        ]);

        $response->assertStatus(200)
            ->assertJson([
                'success' => true,
                'data' => [
                    'total_amount' => 300000, // 100000 + 200000
                    'breakdown' => [
                        'reactivation_fee' => 100000,
                        'monthly_fee' => 200000,
                        'total_amount' => 300000
                    ]
                ]
            ]);

        $member->refresh();
        $this->assertEquals('active', $member->status);
        $this->assertEquals(1, $member->reactivation_count);
        $this->assertEquals(100000, $member->last_reactivation_fee);
    }

    public function test_quarterly_membership_with_discount()
    {
        // Setup configuration
        SystemConfiguration::setConfig('member_registration_fee', 50000, 'decimal');
        SystemConfiguration::setConfig('member_quarterly_fee', 500000, 'decimal');
        SystemConfiguration::setConfig('member_quarterly_discount', 10, 'decimal');

        $user = User::factory()->create();
        $profile = UserProfile::factory()->create(['user_id' => $user->id]);

        $response = $this->postJson('/api/v1/members/register', [
            'user_id' => $user->id,
            'user_profile_id' => $profile->id,
            'membership_type' => 'quarterly',
            'payment_method' => 'transfer'
        ]);

        $response->assertStatus(201)
            ->assertJson([
                'success' => true,
                'data' => [
                    'total_amount' => 495000, // (50000 + 500000) - 10% = 550000 - 55000
                    'breakdown' => [
                        'registration_fee' => 50000,
                        'quarterly_fee' => 500000,
                        'subtotal' => 550000,
                        'discount_percentage' => 10,
                        'discount_amount' => 55000,
                        'final_amount' => 495000
                    ]
                ]
            ]);

        $this->assertDatabaseHas('members', [
            'user_id' => $user->id,
            'status' => 'active',
            'membership_type' => 'quarterly',
            'total_paid' => 495000
        ]);
    }

    public function test_quarterly_reactivation_with_discount()
    {
        // Setup configuration
        SystemConfiguration::setConfig('member_reactivation_fee', 50000, 'decimal');
        SystemConfiguration::setConfig('member_quarterly_fee', 500000, 'decimal');
        SystemConfiguration::setConfig('member_quarterly_discount', 15, 'decimal');

        $user = User::factory()->create();
        $profile = UserProfile::factory()->create(['user_id' => $user->id]);
        $member = Member::factory()->create([
            'user_id' => $user->id,
            'user_profile_id' => $profile->id,
            'status' => 'non_member',
            'membership_type' => 'quarterly'
        ]);

        $response = $this->postJson("/api/v1/members/{$member->id}/reactivate", [
            'payment_method' => 'transfer'
        ]);

        $response->assertStatus(200)
            ->assertJson([
                'success' => true,
                'data' => [
                    'total_amount' => 467500, // (50000 + 500000) - 15% = 550000 - 82500
                    'breakdown' => [
                        'reactivation_fee' => 50000,
                        'quarterly_fee' => 500000,
                        'subtotal' => 550000,
                        'discount_percentage' => 15,
                        'discount_amount' => 82500,
                        'final_amount' => 467500
                    ]
                ]
            ]);

        $member->refresh();
        $this->assertEquals('active', $member->status);
        $this->assertEquals(1, $member->reactivation_count);
    }
}
```

## 📅 Implementation Timeline

### **Week 1: Database & Models**

- [ ] Create database migrations
- [ ] Update Member model
- [ ] Create new models (SystemConfiguration, MemberStatusHistory, MemberPayment)
- [ ] Create seeders
- [ ] Run migrations and seeders

### **Week 2: Services & Business Logic**

- [ ] Update MemberService
- [ ] Create SystemConfigurationService
- [ ] Implement member registration flow
- [ ] Implement member reactivation flow
- [ ] Implement status change automation

### **Week 3: API & Controllers**

- [ ] Update MemberController
- [ ] Create SystemConfigurationController
- [ ] Update request validation classes
- [ ] Implement API endpoints
- [ ] Update API documentation

### **Week 4: Testing & Documentation**

- [ ] Write comprehensive tests
- [ ] Update existing tests
- [ ] Create API documentation
- [ ] Create user guides
- [ ] Performance testing

## 🚀 Deployment Checklist

### **Pre-deployment**

- [ ] All migrations tested
- [ ] All tests passing
- [ ] Data migration script ready
- [ ] Backup strategy in place
- [ ] Rollback plan prepared

### **Deployment**

- [ ] Run migrations
- [ ] Seed default configurations
- [ ] Migrate existing member data
- [ ] Verify data integrity
- [ ] Test critical flows

### **Post-deployment**

- [ ] Monitor system performance
- [ ] Check error logs
- [ ] Verify member status changes
- [ ] Test payment flows
- [ ] User acceptance testing

---

**Status**: 🚧 **IN PROGRESS**  
**Last Updated**: January 15, 2025  
**Next Review**: January 22, 2025
