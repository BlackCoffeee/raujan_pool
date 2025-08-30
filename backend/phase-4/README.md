# Phase 4: Payment System & Manual Payment

## 📋 Overview

Implementasi sistem pembayaran manual dengan verifikasi admin dan tracking lengkap.

## 🎯 Objectives

- Manual payment processing system
- Payment verification workflow
- Payment status tracking
- Refund management
- Payment analytics
- Bank account configuration

## 📁 Files Structure

```
phase-4/
├── 01-manual-payment-system.md
├── 02-payment-verification.md
├── 03-payment-tracking.md
├── 04-refund-management.md
└── 05-payment-analytics.md
```

## 🔧 Implementation Points

### Point 1: Manual Payment System

**Subpoints:**

- Payment record creation
- Payment proof upload
- Payment status management
- Payment validation
- Payment notifications
- Payment history

**Files:**

- `app/Http/Controllers/PaymentController.php`
- `app/Models/Payment.php`
- `app/Services/PaymentService.php`
- `app/Jobs/ProcessPaymentJob.php`

### Point 2: Payment Verification

**Subpoints:**

- Admin verification interface
- Payment proof validation
- Verification workflow
- Rejection handling
- Verification notifications
- Verification history

**Files:**

- `app/Http/Controllers/PaymentVerificationController.php`
- `app/Models/PaymentVerification.php`
- `app/Services/VerificationService.php`

### Point 3: Payment Tracking

**Subpoints:**

- Payment status tracking
- Payment timeline
- Payment reminders
- Payment expiry handling
- Payment reconciliation
- Payment reporting

**Files:**

- `app/Http/Controllers/PaymentTrackingController.php`
- `app/Models/PaymentTracking.php`
- `app/Services/TrackingService.php`

### Point 4: Refund Management

**Subpoints:**

- Refund request processing
- Refund approval workflow
- Refund calculation
- Refund notifications
- Refund history
- Refund analytics

**Files:**

- `app/Http/Controllers/RefundController.php`
- `app/Models/Refund.php`
- `app/Services/RefundService.php`

### Point 5: Payment Analytics

**Subpoints:**

- Payment statistics
- Revenue tracking
- Payment method analytics
- Payment performance metrics
- Payment trends
- Payment reports

**Files:**

- `app/Http/Controllers/PaymentAnalyticsController.php`
- `app/Services/AnalyticsService.php`
- `app/Repositories/PaymentRepository.php`

## 📊 Database Schema

### Payments Table

```sql
CREATE TABLE payments (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    booking_id BIGINT UNSIGNED NOT NULL,
    user_id BIGINT UNSIGNED NOT NULL,
    amount DECIMAL(10,2) NOT NULL,
    payment_method ENUM('manual_transfer', 'cash', 'refund') DEFAULT 'manual_transfer',
    status ENUM('pending', 'verified', 'rejected', 'expired', 'refunded') DEFAULT 'pending',
    payment_proof_path VARCHAR(255) NULL,
    bank_account_id BIGINT UNSIGNED NULL,
    reference_number VARCHAR(100) UNIQUE NOT NULL,
    transfer_date DATETIME NULL,
    verified_at DATETIME NULL,
    verified_by BIGINT UNSIGNED NULL,
    verification_note TEXT NULL,
    expires_at DATETIME NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    FOREIGN KEY (booking_id) REFERENCES bookings(id),
    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (bank_account_id) REFERENCES bank_accounts(id),
    FOREIGN KEY (verified_by) REFERENCES users(id)
);
```

### Bank Accounts Table

```sql
CREATE TABLE bank_accounts (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    bank_name VARCHAR(100) NOT NULL,
    account_number VARCHAR(50) NOT NULL,
    account_holder VARCHAR(100) NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);
```

### Payment Verifications Table

```sql
CREATE TABLE payment_verifications (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    payment_id BIGINT UNSIGNED NOT NULL,
    verified_by BIGINT UNSIGNED NOT NULL,
    status ENUM('approved', 'rejected') NOT NULL,
    note TEXT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (payment_id) REFERENCES payments(id),
    FOREIGN KEY (verified_by) REFERENCES users(id)
);
```

### Refunds Table

```sql
CREATE TABLE refunds (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    payment_id BIGINT UNSIGNED NOT NULL,
    booking_id BIGINT UNSIGNED NOT NULL,
    amount DECIMAL(10,2) NOT NULL,
    reason TEXT NOT NULL,
    status ENUM('pending', 'approved', 'rejected', 'processed') DEFAULT 'pending',
    requested_by BIGINT UNSIGNED NOT NULL,
    approved_by BIGINT UNSIGNED NULL,
    processed_at DATETIME NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    FOREIGN KEY (payment_id) REFERENCES payments(id),
    FOREIGN KEY (booking_id) REFERENCES bookings(id),
    FOREIGN KEY (requested_by) REFERENCES users(id),
    FOREIGN KEY (approved_by) REFERENCES users(id)
);
```

## 📚 API Routes & Endpoints

### Payment Routes (Guest/Member)

```php
// Payment Management
GET    /api/payments                    // List user payments
GET    /api/payments/{id}               // Get payment details
POST   /api/payments                    // Create payment
PUT    /api/payments/{id}               // Update payment
DELETE /api/payments/{id}               // Cancel payment
POST   /api/payments/{id}/upload-proof  // Upload payment proof
GET    /api/payments/{id}/status        // Get payment status

// Payment Tracking
GET    /api/payments/{id}/timeline      // Get payment timeline
GET    /api/payments/{id}/receipt       // Generate receipt
GET    /api/payments/user/{userId}      // Get user payment history

// Refund Requests
GET    /api/refunds                     // List user refunds
POST   /api/refunds                     // Request refund
GET    /api/refunds/{id}                // Get refund details
PUT    /api/refunds/{id}                // Update refund request
DELETE /api/refunds/{id}                // Cancel refund request
```

### Payment Admin Routes (Admin/Staff)

```php
// Payment Management (Admin)
GET    /api/admin/payments              // List all payments
GET    /api/admin/payments/{id}         // Get payment details
PUT    /api/admin/payments/{id}/verify  // Verify payment
PUT    /api/admin/payments/{id}/reject  // Reject payment
POST   /api/admin/payments/{id}/note    // Add admin note

// Payment Verification
GET    /api/admin/verifications         // List pending verifications
POST   /api/admin/verifications         // Create verification
PUT    /api/admin/verifications/{id}    // Update verification
GET    /api/admin/verifications/stats   // Verification statistics

// Refund Management (Admin)
GET    /api/admin/refunds               // List all refunds
PUT    /api/admin/refunds/{id}/approve  // Approve refund
PUT    /api/admin/refunds/{id}/reject   // Reject refund
POST   /api/admin/refunds/{id}/process  // Process refund

// Bank Account Management
GET    /api/admin/bank-accounts         // List bank accounts
POST   /api/admin/bank-accounts         // Create bank account
PUT    /api/admin/bank-accounts/{id}    // Update bank account
DELETE /api/admin/bank-accounts/{id}    // Delete bank account
```

### Payment Analytics Routes

```php
// Payment Analytics
GET    /api/admin/analytics/payments    // Payment statistics
GET    /api/admin/analytics/revenue     // Revenue analytics
GET    /api/admin/analytics/verification // Verification analytics
GET    /api/admin/analytics/refunds     // Refund analytics
GET    /api/admin/analytics/export      // Export payment data
```

## 🔄 CRUD Operations

### Payment CRUD Operations

#### Create Payment

```php
// POST /api/payments
public function store(PaymentRequest $request)
{
    $payment = Payment::create([
        'booking_id' => $request->booking_id,
        'user_id' => auth()->id(),
        'amount' => $request->amount,
        'payment_method' => 'manual_transfer',
        'reference_number' => $this->generateReferenceNumber(),
        'expires_at' => now()->addHours(24),
    ]);

    return response()->json($payment, 201);
}
```

#### Read Payment

```php
// GET /api/payments/{id}
public function show($id)
{
    $payment = Payment::with(['booking', 'user', 'bankAccount'])
        ->where('user_id', auth()->id())
        ->findOrFail($id);

    return response()->json($payment);
}
```

#### Update Payment

```php
// PUT /api/payments/{id}
public function update(PaymentRequest $request, $id)
{
    $payment = Payment::where('user_id', auth()->id())->findOrFail($id);

    if ($payment->status !== 'pending') {
        return response()->json(['error' => 'Payment cannot be updated'], 422);
    }

    $payment->update($request->validated());

    return response()->json($payment);
}
```

#### Delete Payment

```php
// DELETE /api/payments/{id}
public function destroy($id)
{
    $payment = Payment::where('user_id', auth()->id())->findOrFail($id);

    if ($payment->status !== 'pending') {
        return response()->json(['error' => 'Payment cannot be cancelled'], 422);
    }

    $payment->delete();

    return response()->json(['message' => 'Payment cancelled successfully']);
}
```

### Payment Verification CRUD Operations

#### Create Verification (Admin)

```php
// POST /api/admin/verifications
public function createVerification(VerificationRequest $request)
{
    $verification = PaymentVerification::create([
        'payment_id' => $request->payment_id,
        'verified_by' => auth()->id(),
        'status' => $request->status,
        'note' => $request->note,
    ]);

    // Update payment status
    $payment = Payment::find($request->payment_id);
    $payment->update([
        'status' => $request->status === 'approved' ? 'verified' : 'rejected',
        'verified_at' => now(),
        'verified_by' => auth()->id(),
        'verification_note' => $request->note,
    ]);

    // Send notifications
    event(new PaymentVerificationCompleted($payment));

    return response()->json($verification, 201);
}
```

#### List Verifications (Admin)

```php
// GET /api/admin/verifications
public function index(Request $request)
{
    $verifications = PaymentVerification::with(['payment', 'verifiedBy'])
        ->when($request->status, function($query, $status) {
            return $query->where('status', $status);
        })
        ->when($request->date, function($query, $date) {
            return $query->whereDate('created_at', $date);
        })
        ->orderBy('created_at', 'desc')
        ->paginate(20);

    return response()->json($verifications);
}
```

### Refund CRUD Operations

#### Create Refund Request

```php
// POST /api/refunds
public function store(RefundRequest $request)
{
    $refund = Refund::create([
        'payment_id' => $request->payment_id,
        'booking_id' => $request->booking_id,
        'amount' => $request->amount,
        'reason' => $request->reason,
        'requested_by' => auth()->id(),
    ]);

    // Send notification to admin
    event(new RefundRequestCreated($refund));

    return response()->json($refund, 201);
}
```

#### Approve Refund (Admin)

```php
// PUT /api/admin/refunds/{id}/approve
public function approveRefund($id, ApproveRefundRequest $request)
{
    $refund = Refund::findOrFail($id);
    $refund->update([
        'status' => 'approved',
        'approved_by' => auth()->id(),
    ]);

    // Process refund logic
    $this->processRefund($refund);

    // Send notification
    event(new RefundApproved($refund));

    return response()->json(['message' => 'Refund approved successfully']);
}
```

## 🎭 Actor Perspectives

### Guest User Perspective

- **Create Payment**: Upload payment proof after booking
- **Track Payment**: Monitor payment status and verification
- **Request Refund**: Cancel booking and request refund
- **View History**: Access payment history and receipts

### Member Perspective

- **Create Payment**: Same as guest + member benefits
- **Track Payment**: Enhanced tracking with member perks
- **Request Refund**: Faster refund processing
- **View History**: Detailed payment analytics

### Staff Front Desk Perspective

- **View Payments**: Monitor incoming payments
- **Verify Payments**: Approve/reject payment proofs
- **Process Refunds**: Handle refund requests
- **Generate Reports**: Create payment reports

### Admin Perspective

- **Manage Payments**: Full payment system control
- **Configure Banks**: Manage bank account details
- **Analytics**: Access payment analytics and reports
- **System Settings**: Configure payment rules and policies

## 🧪 Testing

### Payment Testing

```php
// tests/Feature/PaymentTest.php
class PaymentTest extends TestCase
{
    use RefreshDatabase;

    public function test_user_can_create_payment()
    {
        $user = User::factory()->create();
        $booking = Booking::factory()->create(['user_id' => $user->id]);

        $response = $this->actingAs($user)
            ->postJson('/api/payments', [
                'booking_id' => $booking->id,
                'amount' => 150000,
            ]);

        $response->assertStatus(201);
        $this->assertDatabaseHas('payments', [
            'booking_id' => $booking->id,
            'user_id' => $user->id,
            'amount' => 150000,
        ]);
    }

    public function test_admin_can_verify_payment()
    {
        $admin = User::factory()->create(['role' => 'admin']);
        $payment = Payment::factory()->create(['status' => 'pending']);

        $response = $this->actingAs($admin)
            ->putJson("/api/admin/payments/{$payment->id}/verify", [
                'status' => 'approved',
                'note' => 'Payment verified',
            ]);

        $response->assertStatus(200);
        $this->assertDatabaseHas('payments', [
            'id' => $payment->id,
            'status' => 'verified',
        ]);
    }
}
```

## ✅ Success Criteria

- [ ] Payment creation berfungsi dengan baik
- [ ] Payment verification workflow berjalan
- [ ] Payment tracking terimplementasi
- [ ] Refund management berfungsi
- [ ] Payment analytics dapat diakses
- [ ] Bank account management berjalan
- [ ] Payment notifications terkirim
- [ ] Payment security measures terpasang
- [ ] Testing coverage > 90%

## 📚 Documentation

- Payment System Architecture
- Manual Payment Workflow
- Payment Verification Guide
- Refund Management Guide
- Payment Analytics Guide
