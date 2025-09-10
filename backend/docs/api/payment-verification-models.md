# Payment Verification API - Models & Database

## Database Models

### PaymentVerification Model

Model utama untuk menyimpan data verifikasi pembayaran.

```php
<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class PaymentVerification extends Model
{
    use HasFactory;

    protected $fillable = [
        'payment_id',
        'verified_by',
        'status',
        'note',
        'verification_data',
        'proof_validation_score',
        'auto_verified',
        'verification_duration',
    ];

    protected $casts = [
        'verification_data' => 'array',
        'proof_validation_score' => 'decimal:2',
        'auto_verified' => 'boolean',
        'verification_duration' => 'integer',
    ];

    // Relationships
    public function payment()
    {
        return $this->belongsTo(Payment::class);
    }

    public function verifiedBy()
    {
        return $this->belongsTo(User::class, 'verified_by');
    }

    // Accessors
    public function getStatusDisplayAttribute()
    {
        return match($this->status) {
            'approved' => 'Approved',
            'rejected' => 'Rejected',
            'pending' => 'Pending Review',
            default => 'Unknown'
        };
    }

    public function getIsApprovedAttribute()
    {
        return $this->status === 'approved';
    }

    public function getIsRejectedAttribute()
    {
        return $this->status === 'rejected';
    }

    public function getIsPendingAttribute()
    {
        return $this->status === 'pending';
    }

    public function getVerificationDurationDisplayAttribute()
    {
        if (!$this->verification_duration) {
            return null;
        }

        $minutes = floor($this->verification_duration / 60);
        $seconds = $this->verification_duration % 60;

        return "{$minutes}m {$seconds}s";
    }

    // Query Scopes
    public function scopeApproved($query)
    {
        return $query->where('status', 'approved');
    }

    public function scopeRejected($query)
    {
        return $query->where('status', 'rejected');
    }

    public function scopePending($query)
    {
        return $query->where('status', 'pending');
    }

    public function scopeByVerifier($query, $verifierId)
    {
        return $query->where('verified_by', $verifierId);
    }

    public function scopeAutoVerified($query)
    {
        return $query->where('auto_verified', true);
    }

    public function scopeManualVerified($query)
    {
        return $query->where('auto_verified', false);
    }

    public function scopeByDateRange($query, $startDate, $endDate)
    {
        return $query->whereBetween('created_at', [$startDate, $endDate]);
    }
}
```

### Payment Model

Model untuk data pembayaran yang mendukung field `assigned_to`.

```php
<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class Payment extends Model
{
    use HasFactory;

    protected $fillable = [
        'booking_id',
        'user_id',
        'amount',
        'payment_method',
        'status',
        'payment_proof_path',
        'bank_account_id',
        'reference',
        'transfer_date',
        'transfer_time',
        'sender_name',
        'sender_account',
        'verified_at',
        'verified_by',
        'verification_note',
        'expires_at',
        'notes',
        'original_filename',
        'file_size',
        'file_type',
        'assigned_to', // Field untuk assignment system
    ];

    protected $casts = [
        'amount' => 'decimal:2',
        'transfer_date' => 'date',
        'transfer_time' => 'datetime',
        'verified_at' => 'datetime',
        'expires_at' => 'datetime',
    ];

    // Relationships
    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    public function booking(): BelongsTo
    {
        return $this->belongsTo(Booking::class);
    }

    public function bankAccount(): BelongsTo
    {
        return $this->belongsTo(BankAccount::class);
    }

    public function verifiedBy(): BelongsTo
    {
        return $this->belongsTo(User::class, 'verified_by');
    }

    public function assignedTo(): BelongsTo
    {
        return $this->belongsTo(User::class, 'assigned_to');
    }

    public function paymentVerifications()
    {
        return $this->hasMany(PaymentVerification::class);
    }

    // Accessors
    public function getIsExpiredAttribute()
    {
        if (!$this->expires_at) {
            return false;
        }
        return now()->isAfter($this->expires_at);
    }

    public function getCanBeVerifiedAttribute()
    {
        return $this->status === 'pending' && !$this->is_expired;
    }

    public function getProofTypeAttribute()
    {
        if (!$this->payment_proof_path) {
            return null;
        }

        $extension = pathinfo($this->payment_proof_path, PATHINFO_EXTENSION);

        return match(strtolower($extension)) {
            'jpg', 'jpeg', 'png', 'gif' => 'image',
            'pdf' => 'document',
            default => 'unknown'
        };
    }

    // Query Scopes
    public function scopePending($query)
    {
        return $query->where('status', 'pending');
    }

    public function scopeVerified($query)
    {
        return $query->where('status', 'verified');
    }

    public function scopeRejected($query)
    {
        return $query->where('status', 'rejected');
    }

    public function scopeByPaymentMethod($query, $method)
    {
        return $query->where('payment_method', $method);
    }

    public function scopeByBankAccount($query, $bankAccountId)
    {
        return $query->where('bank_account_id', $bankAccountId);
    }

    public function scopeByAmountRange($query, $minAmount, $maxAmount)
    {
        return $query->whereBetween('amount', [$minAmount, $maxAmount]);
    }

    public function scopeByDateRange($query, $startDate, $endDate)
    {
        return $query->whereBetween('created_at', [$startDate, $endDate]);
    }

    public function scopeAssignedTo($query, $userId)
    {
        return $query->where('assigned_to', $userId);
    }

    public function scopeUnassigned($query)
    {
        return $query->whereNull('assigned_to');
    }
}
```

## Database Migrations

### Payment Verifications Table

```php
<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up()
    {
        Schema::create('payment_verifications', function (Blueprint $table) {
            $table->id();
            $table->foreignId('payment_id')->constrained('payments')->onDelete('cascade');
            $table->foreignId('verified_by')->nullable()->constrained('users')->onDelete('set null');
            $table->enum('status', ['approved', 'rejected', 'pending'])->default('pending');
            $table->text('note')->nullable();
            $table->json('verification_data')->nullable();
            $table->decimal('proof_validation_score', 5, 2)->default(0.00);
            $table->boolean('auto_verified')->default(false);
            $table->integer('verification_duration')->default(0); // in seconds
            $table->timestamps();

            $table->index(['payment_id', 'status']);
            $table->index(['verified_by', 'created_at']);
            $table->index(['auto_verified', 'created_at']);
        });
    }

    public function down()
    {
        Schema::dropIfExists('payment_verifications');
    }
};
```

### Add Assigned To To Payments Table

```php
<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up()
    {
        Schema::table('payments', function (Blueprint $table) {
            $table->foreignId('assigned_to')->nullable()->constrained('users')->onDelete('set null')->after('verified_by');
            $table->index('assigned_to');
        });
    }

    public function down()
    {
        Schema::table('payments', function (Blueprint $table) {
            $table->dropForeign(['assigned_to']);
            $table->dropIndex(['assigned_to']);
            $table->dropColumn('assigned_to');
        });
    }
};
```

## Database Factories

### PaymentVerificationFactory

```php
<?php

namespace Database\Factories;

use App\Models\Payment;
use App\Models\User;
use Illuminate\Database\Eloquent\Factories\Factory;

class PaymentVerificationFactory extends Factory
{
    public function definition()
    {
        return [
            'payment_id' => Payment::factory(),
            'verified_by' => User::factory(),
            'status' => $this->faker->randomElement(['approved', 'rejected', 'pending']),
            'note' => $this->faker->optional()->sentence(),
            'verification_data' => [
                'payment_amount' => $this->faker->numberBetween(50000, 500000),
                'booking_amount' => $this->faker->numberBetween(50000, 500000),
                'amount_match' => $this->faker->boolean(),
                'has_proof' => true,
                'proof_type' => $this->faker->randomElement(['image', 'document']),
                'bank_account' => $this->faker->randomElement(['BCA', 'Mandiri', 'BNI']),
                'payment_method' => 'manual_transfer',
            ],
            'proof_validation_score' => $this->faker->randomFloat(2, 0, 100),
            'auto_verified' => false,
            'verification_duration' => $this->faker->numberBetween(5, 300), // 5 seconds to 5 minutes
        ];
    }

    public function approved()
    {
        return $this->state(function (array $attributes) {
            return [
                'status' => 'approved',
                'verified_by' => User::factory(),
            ];
        });
    }

    public function rejected()
    {
        return $this->state(function (array $attributes) {
            return [
                'status' => 'rejected',
                'verified_by' => User::factory(),
            ];
        });
    }

    public function pending()
    {
        return $this->state(function (array $attributes) {
            return [
                'status' => 'pending',
                'verified_by' => null,
            ];
        });
    }

    public function autoVerified()
    {
        return $this->state(function (array $attributes) {
            return [
                'auto_verified' => true,
                'verified_by' => null,
                'proof_validation_score' => $this->faker->randomFloat(2, 80, 100),
            ];
        });
    }

    public function manualVerified()
    {
        return $this->state(function (array $attributes) {
            return [
                'auto_verified' => false,
                'verified_by' => User::factory(),
            ];
        });
    }
}
```

### PaymentFactory

```php
<?php

namespace Database\Factories;

use App\Models\BankAccount;
use App\Models\Booking;
use App\Models\User;
use Illuminate\Database\Eloquent\Factories\Factory;

class PaymentFactory extends Factory
{
    public function definition()
    {
        return [
            'booking_id' => Booking::factory(),
            'user_id' => User::factory(),
            'amount' => $this->faker->numberBetween(50000, 500000),
            'payment_method' => 'manual_transfer',
            'status' => 'pending',
            'payment_proof_path' => 'proofs/payment_' . $this->faker->unique()->numberBetween(1, 1000) . '.jpg',
            'bank_account_id' => BankAccount::factory(),
            'reference' => 'REF' . $this->faker->unique()->numberBetween(1000, 9999),
            'transfer_date' => $this->faker->dateTimeBetween('-1 month', 'now'),
            'transfer_time' => $this->faker->time(),
            'sender_name' => $this->faker->name(),
            'sender_account' => $this->faker->numerify('##########'),
            'verified_at' => null,
            'verified_by' => null,
            'verification_note' => null,
            'expires_at' => $this->faker->dateTimeBetween('now', '+1 week'),
            'notes' => $this->faker->optional()->sentence(),
            'original_filename' => 'payment_proof.jpg',
            'file_size' => $this->faker->numberBetween(100000, 5000000),
            'file_type' => 'image/jpeg',
            'assigned_to' => null,
        ];
    }

    public function verified()
    {
        return $this->state(function (array $attributes) {
            return [
                'status' => 'verified',
                'verified_at' => now(),
                'verified_by' => User::factory(),
            ];
        });
    }

    public function rejected()
    {
        return $this->state(function (array $attributes) {
            return [
                'status' => 'rejected',
                'verified_at' => now(),
                'verified_by' => User::factory(),
            ];
        });
    }

    public function assigned($userId = null)
    {
        return $this->state(function (array $attributes) use ($userId) {
            return [
                'assigned_to' => $userId ?? User::factory(),
            ];
        });
    }

    public function expired()
    {
        return $this->state(function (array $attributes) {
            return [
                'expires_at' => $this->faker->dateTimeBetween('-1 week', '-1 day'),
            ];
        });
    }
}
```

## Database Relationships

### One-to-Many Relationships

```php
// Payment has many PaymentVerifications
Payment::class
    ->hasMany(PaymentVerification::class);

// PaymentVerification belongs to Payment
PaymentVerification::class
    ->belongsTo(Payment::class);

// User has many PaymentVerifications (as verifier)
User::class
    ->hasMany(PaymentVerification::class, 'verified_by');

// User has many Payments (as assigned verifier)
User::class
    ->hasMany(Payment::class, 'assigned_to');
```

### Many-to-One Relationships

```php
// PaymentVerification belongs to User (verifier)
PaymentVerification::class
    ->belongsTo(User::class, 'verified_by');

// Payment belongs to User (assigned verifier)
Payment::class
    ->belongsTo(User::class, 'assigned_to');
```

## Database Indexes

### Performance Indexes

```sql
-- Payment Verifications Table
CREATE INDEX idx_payment_verifications_payment_status ON payment_verifications(payment_id, status);
CREATE INDEX idx_payment_verifications_verifier_created ON payment_verifications(verified_by, created_at);
CREATE INDEX idx_payment_verifications_auto_verified_created ON payment_verifications(auto_verified, created_at);

-- Payments Table
CREATE INDEX idx_payments_status ON payments(status);
CREATE INDEX idx_payments_assigned_to ON payments(assigned_to);
CREATE INDEX idx_payments_payment_method ON payments(payment_method);
CREATE INDEX idx_payments_bank_account ON payments(bank_account_id);
CREATE INDEX idx_payments_amount_range ON payments(amount);
CREATE INDEX idx_payments_created_at ON payments(created_at);
CREATE INDEX idx_payments_expires_at ON payments(expires_at);
```

## Data Validation

### Model Validation Rules

```php
// PaymentVerification validation
'payment_id' => 'required|exists:payments,id',
'status' => 'required|in:approved,rejected,pending',
'note' => 'nullable|string|max:500',
'verification_data' => 'nullable|array',
'proof_validation_score' => 'nullable|numeric|between:0,100',
'auto_verified' => 'boolean',
'verification_duration' => 'nullable|integer|min:0',

// Payment assignment validation
'verifier_id' => 'required|exists:users,id',
```

### Business Logic Validation

```php
// Payment can be verified
if (!$payment->can_be_verified) {
    throw new \Exception('Payment cannot be verified');
}

// Only pending payments can be assigned
if ($payment->status !== 'pending') {
    throw new \Exception('Only pending payments can be assigned');
}

// Auto-verification criteria check
if (!$autoVerificationResult['can_auto_verify']) {
    throw new \Exception('Payment does not meet auto-verification criteria');
}
```

## Database Transactions

### Verification Process Transaction

```php
public function createVerification($paymentId, $status, $note = null, $verifiedBy = null)
{
    return DB::transaction(function () use ($paymentId, $status, $note, $verifiedBy) {
        // 1. Create verification record
        $verification = PaymentVerification::create([...]);

        // 2. Update payment status
        $payment->update([...]);

        // 3. Update booking payment status
        $booking->update([...]);

        // 4. Calculate verification duration
        $verificationDuration = now()->diffInSeconds($startTime);
        $verification->update(['verification_duration' => $verificationDuration]);

        // 5. Send notifications
        $this->sendVerificationNotifications($payment, $verification);

        return $verification;
    });
}
```

## Data Integrity

### Foreign Key Constraints

```sql
-- Payment Verifications
ALTER TABLE payment_verifications
ADD CONSTRAINT fk_payment_verifications_payment_id
FOREIGN KEY (payment_id) REFERENCES payments(id) ON DELETE CASCADE;

ALTER TABLE payment_verifications
ADD CONSTRAINT fk_payment_verifications_verified_by
FOREIGN KEY (verified_by) REFERENCES users(id) ON DELETE SET NULL;

-- Payments
ALTER TABLE payments
ADD CONSTRAINT fk_payments_assigned_to
FOREIGN KEY (assigned_to) REFERENCES users(id) ON DELETE SET NULL;
```

### Unique Constraints

```sql
-- Prevent duplicate verifications for same payment
ALTER TABLE payment_verifications
ADD CONSTRAINT unique_payment_verification
UNIQUE (payment_id, verified_by, created_at);
```
