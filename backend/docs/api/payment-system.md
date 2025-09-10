# Manual Payment System API Documentation

## Overview

Manual Payment System memungkinkan user untuk melakukan pembayaran manual melalui transfer bank atau pembayaran tunai. Sistem ini mendukung upload bukti pembayaran, verifikasi oleh admin, dan tracking status pembayaran.

## Features

-   ✅ Create payment request
-   ✅ Upload payment proof
-   ✅ Payment verification by admin
-   ✅ Payment status tracking
-   ✅ Payment timeline
-   ✅ Payment statistics
-   ✅ Bank account management
-   ✅ Payment expiry handling

## Database Schema

### Payments Table

```sql
CREATE TABLE payments (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    booking_id BIGINT NOT NULL,
    user_id BIGINT NOT NULL,
    amount DECIMAL(10,2) NOT NULL,
    payment_method ENUM('manual_transfer', 'cash') DEFAULT 'manual_transfer',
    status ENUM('pending', 'verified', 'rejected', 'expired') DEFAULT 'pending',
    bank_account_id BIGINT NULL,
    reference VARCHAR(255) UNIQUE NOT NULL,
    payment_proof_path VARCHAR(255) NULL,
    transfer_date VARCHAR(255) NULL,
    transfer_time VARCHAR(255) NULL,
    sender_name VARCHAR(255) NULL,
    sender_account VARCHAR(255) NULL,
    verified_at TIMESTAMP NULL,
    verified_by BIGINT NULL,
    verification_note TEXT NULL,
    expires_at TIMESTAMP NULL,
    notes TEXT NULL,
    original_filename VARCHAR(255) NULL,
    file_size INT NULL,
    file_type VARCHAR(255) NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);
```

### Bank Accounts Table

```sql
CREATE TABLE bank_accounts (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    bank_name VARCHAR(255) NOT NULL,
    account_number VARCHAR(255) NOT NULL,
    account_holder_name VARCHAR(255) NOT NULL,
    bank_code VARCHAR(255) NULL,
    swift_code VARCHAR(255) NULL,
    description TEXT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    is_primary BOOLEAN DEFAULT FALSE,
    reference_prefix VARCHAR(255) NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);
```

### Payment Verifications Table

```sql
CREATE TABLE payment_verifications (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    payment_id BIGINT NOT NULL,
    verified_by BIGINT NOT NULL,
    status ENUM('verified', 'rejected') NOT NULL,
    note TEXT NULL,
    verification_data JSON NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);
```

## API Endpoints

### User Payment Endpoints

#### 1. Create Payment

```http
POST /api/v1/payments
```

**Request Body:**

```json
{
    "booking_id": 1,
    "amount": 50000,
    "payment_method": "manual_transfer",
    "bank_account_id": 1,
    "notes": "Payment for swimming session"
}
```

**Response:**

```json
{
    "success": true,
    "message": "Payment created successfully",
    "data": {
        "id": 1,
        "booking_id": 1,
        "user_id": 1,
        "amount": "50000.00",
        "payment_method": "manual_transfer",
        "status": "pending",
        "reference": "PAY202509020001",
        "expires_at": "2025-09-03T00:00:00.000000Z"
    }
}
```

#### 2. Get Payment List

```http
GET /api/v1/payments?status=pending&payment_method=manual_transfer
```

**Query Parameters:**

-   `status`: Filter by payment status
-   `payment_method`: Filter by payment method
-   `start_date`: Filter by start date (YYYY-MM-DD)
-   `end_date`: Filter by end date (YYYY-MM-DD)
-   `min_amount`: Filter by minimum amount
-   `max_amount`: Filter by maximum amount
-   `per_page`: Number of items per page (default: 15)

#### 3. Get Payment Details

```http
GET /api/v1/payments/{id}
```

#### 4. Update Payment

```http
PUT /api/v1/payments/{id}
```

#### 5. Cancel Payment

```http
DELETE /api/v1/payments/{id}
```

#### 6. Upload Payment Proof

```http
POST /api/v1/payments/{id}/upload-proof
```

**Request Body (multipart/form-data):**

```
payment_proof: [file] (JPEG, PNG, GIF, PDF, max 5MB)
```

#### 7. Get Payment Status

```http
GET /api/v1/payments/{id}/status
```

**Response:**

```json
{
    "success": true,
    "data": {
        "status": "pending",
        "status_display": "Pending Verification",
        "can_be_updated": true,
        "can_be_cancelled": true,
        "time_until_expiry": "23:45:30",
        "verification_time": null
    }
}
```

#### 8. Get Payment Timeline

```http
GET /api/v1/payments/{id}/timeline
```

#### 9. Generate Receipt

```http
GET /api/v1/payments/{id}/receipt
```

#### 10. Get Payment Statistics

```http
GET /api/v1/payments/stats
```

### Admin Payment Endpoints

#### 1. Get All Payments

```http
GET /api/v1/admin/payments
```

#### 2. Get Payment Details

```http
GET /api/v1/admin/payments/{id}
```

#### 3. Verify Payment

```http
PUT /api/v1/admin/payments/{id}/verify
```

**Request Body:**

```json
{
    "status": "verified",
    "note": "Payment verified successfully"
}
```

#### 4. Reject Payment

```http
PUT /api/v1/admin/payments/{id}/reject
```

**Request Body:**

```json
{
    "reason": "Invalid payment proof"
}
```

#### 5. Get Payment Analytics

```http
GET /api/v1/admin/payments/analytics
```

#### 6. Get Pending Payments

```http
GET /api/v1/admin/payments/pending
```

#### 7. Get Expiring Payments

```http
GET /api/v1/admin/payments/expiring
```

#### 8. Process Expired Payments

```http
POST /api/v1/admin/payments/process-expired
```

## Payment Status Flow

```
[Created] → [Pending] → [Verified/Rejected]
    ↓           ↓
[Expired] ← [Expires]
```

### Status Descriptions

-   **Pending**: Payment created, waiting for proof upload and verification
-   **Verified**: Payment approved by admin
-   **Rejected**: Payment rejected by admin
-   **Expired**: Payment expired without verification

## Payment Methods

### Manual Transfer

-   User transfers money to specified bank account
-   Must upload proof of transfer
-   Reference number required for tracking

### Cash Payment

-   Payment made in cash at venue
-   No proof upload required
-   Immediate verification possible

## File Upload Requirements

### Supported Formats

-   JPEG (.jpg, .jpeg)
-   PNG (.png)
-   GIF (.gif)
-   PDF (.pdf)

### File Size Limit

-   Maximum: 5MB

### Storage Location

-   Files stored in `storage/app/public/payment-proofs/`
-   Accessible via `/storage/payment-proofs/` URL

## Business Rules

### Payment Creation

-   User can only create payments for their own bookings
-   Amount must match booking total amount
-   Payment expires after 24 hours
-   Only one pending payment per booking

### Payment Updates

-   Can only update pending payments
-   Cannot update verified/rejected payments
-   Can cancel pending payments

### Payment Verification

-   Only admin users can verify payments
-   Verification creates audit trail
-   Updates booking payment status

### Payment Expiry

-   Automatic expiry after 24 hours
-   Expired payments cannot be updated
-   Expired payments update booking status to unpaid

## Error Handling

### Common Error Codes

-   `400`: Bad Request (business logic errors)
-   `401`: Unauthorized (authentication required)
-   `403`: Forbidden (insufficient permissions)
-   `404`: Not Found (resource not found)
-   `422`: Validation Error (invalid input data)

### Error Response Format

```json
{
    "success": false,
    "message": "Error description",
    "errors": {
        "field": ["Validation error message"]
    }
}
```

## Testing

### Run Payment Tests

```bash
php artisan test tests/Feature/PaymentTest.php
```

### Test Coverage

-   Payment creation and validation
-   Payment proof upload
-   Payment status management
-   Payment verification workflow
-   Error handling scenarios

## Security Considerations

### Authentication

-   All endpoints require authentication via Sanctum
-   User can only access their own payments
-   Admin endpoints require admin role

### File Upload Security

-   File type validation
-   File size limits
-   Secure file storage
-   Access control for uploaded files

### Data Validation

-   Input sanitization
-   Business rule validation
-   SQL injection prevention
-   XSS protection

## Monitoring and Logging

### Payment Events Logged

-   Payment creation
-   Proof upload
-   Status changes
-   Verification actions
-   Expiry processing

### Log Fields

-   User ID
-   Payment ID
-   Action performed
-   Timestamp
-   Additional context

## Performance Considerations

### Database Indexes

-   `payments.user_id, status`
-   `payments.booking_id`
-   `payments.reference`
-   `payments.expires_at`
-   `payments.verified_at`

### Query Optimization

-   Eager loading for relationships
-   Pagination for large datasets
-   Efficient filtering and sorting

## Future Enhancements

### Planned Features

-   Email notifications for payment status
-   SMS reminders for expiring payments
-   Payment gateway integration
-   Automated verification using AI
-   Payment analytics dashboard
-   Bulk payment processing
-   Payment templates
-   Multi-currency support
