# Payment Verification API Documentation

## Overview

Payment Verification API memungkinkan admin untuk memverifikasi pembayaran manual transfer dengan berbagai fitur seperti auto-verification, bulk verification, dan assignment system.

## Base URL

```
https://api.raujanpool.com/api/v1/admin/verifications
```

## Authentication

Semua endpoint memerlukan authentication dengan Bearer token dan role admin.

```http
Authorization: Bearer {token}
```

## Endpoints

### 1. Get Pending Verifications

Mendapatkan daftar pembayaran yang menunggu verifikasi.

```http
GET /api/v1/admin/verifications
```

#### Query Parameters

| Parameter         | Type    | Required | Description                  |
| ----------------- | ------- | -------- | ---------------------------- |
| `min_amount`      | integer | No       | Filter minimum amount        |
| `max_amount`      | integer | No       | Filter maximum amount        |
| `payment_method`  | string  | No       | Filter by payment method     |
| `bank_account_id` | integer | No       | Filter by bank account       |
| `created_after`   | date    | No       | Filter by creation date      |
| `per_page`        | integer | No       | Items per page (default: 20) |

#### Response

```json
{
    "success": true,
    "message": "Pending verifications retrieved successfully",
    "data": {
        "current_page": 1,
        "data": [
            {
                "id": 1,
                "booking_id": 1,
                "user_id": 1,
                "amount": 100000,
                "payment_method": "manual_transfer",
                "status": "pending",
                "payment_proof_path": "proofs/payment_1.jpg",
                "bank_account_id": 1,
                "reference": "REF001",
                "transfer_date": "2025-01-15",
                "transfer_time": "14:30:00",
                "sender_name": "John Doe",
                "sender_account": "1234567890",
                "assigned_to": null,
                "created_at": "2025-01-15T14:30:00Z",
                "user": {
                    "id": 1,
                    "full_name": "John Doe",
                    "email": "john@example.com"
                },
                "booking": {
                    "id": 1,
                    "booking_reference": "BK001",
                    "booking_date": "2025-01-20",
                    "session_time": "morning",
                    "total_amount": 100000
                },
                "bank_account": {
                    "id": 1,
                    "bank_name": "BCA",
                    "account_number": "1234567890"
                }
            }
        ],
        "total": 1,
        "per_page": 20
    }
}
```

### 2. Create Verification

Membuat verifikasi pembayaran baru.

```http
POST /api/v1/admin/verifications
```

#### Request Body

```json
{
    "payment_id": 1,
    "status": "approved",
    "note": "Payment verified successfully"
}
```

#### Validation Rules

| Field        | Type    | Required | Rules                            |
| ------------ | ------- | -------- | -------------------------------- |
| `payment_id` | integer | Yes      | Must exist in payments table     |
| `status`     | string  | Yes      | Must be 'approved' or 'rejected' |
| `note`       | string  | No       | Max 500 characters               |

#### Response

```json
{
    "success": true,
    "message": "Verification created successfully",
    "data": {
        "id": 1,
        "payment_id": 1,
        "verified_by": 1,
        "status": "approved",
        "note": "Payment verified successfully",
        "verification_data": {
            "payment_amount": 100000,
            "booking_amount": 100000,
            "amount_match": true,
            "has_proof": true,
            "proof_type": "image",
            "bank_account": "BCA",
            "payment_method": "manual_transfer"
        },
        "proof_validation_score": 100.0,
        "auto_verified": false,
        "verification_duration": 5,
        "created_at": "2025-01-15T14:35:00Z"
    }
}
```

### 3. Get Verification Details

Mendapatkan detail verifikasi berdasarkan ID.

```http
GET /api/v1/admin/verifications/{id}
```

#### Response

```json
{
    "success": true,
    "message": "Verification retrieved successfully",
    "data": {
        "id": 1,
        "payment_id": 1,
        "verified_by": 1,
        "status": "approved",
        "note": "Payment verified successfully",
        "verification_data": {
            "payment_amount": 100000,
            "booking_amount": 100000,
            "amount_match": true,
            "has_proof": true,
            "proof_type": "image",
            "bank_account": "BCA",
            "payment_method": "manual_transfer"
        },
        "proof_validation_score": 100.0,
        "auto_verified": false,
        "verification_duration": 5,
        "created_at": "2025-01-15T14:35:00Z",
        "payment": {
            "id": 1,
            "amount": 100000,
            "status": "verified",
            "user": {
                "id": 1,
                "full_name": "John Doe"
            },
            "booking": {
                "id": 1,
                "booking_reference": "BK001"
            }
        },
        "verified_by_user": {
            "id": 1,
            "full_name": "Admin User"
        }
    }
}
```

### 4. Verify Payment

Memverifikasi pembayaran langsung.

```http
POST /api/v1/admin/verifications/{paymentId}/verify
```

#### Request Body

```json
{
    "status": "approved",
    "note": "Payment verified successfully"
}
```

#### Response

```json
{
    "success": true,
    "message": "Payment verified successfully",
    "data": {
        "id": 1,
        "status": "approved",
        "note": "Payment verified successfully"
    }
}
```

### 5. Auto Verify Payment

Memverifikasi pembayaran secara otomatis berdasarkan kriteria sistem.

```http
POST /api/v1/admin/verifications/{paymentId}/auto-verify
```

#### Response

```json
{
    "success": true,
    "message": "Payment auto-verified successfully",
    "data": {
        "id": 1,
        "status": "approved",
        "auto_verified": true,
        "proof_validation_score": 95.0
    }
}
```

#### Auto-verification Criteria

Sistem akan auto-verify jika score >= 80:

-   **Proof exists** (30 points): Ada bukti pembayaran
-   **Amount match** (25 points): Jumlah pembayaran sesuai booking
-   **Bank account match** (20 points): Rekening bank sesuai
-   **Payment method** (15 points): Metode pembayaran manual_transfer
-   **Not expired** (10 points): Pembayaran belum expired

### 6. Bulk Verify Payments

Memverifikasi multiple pembayaran sekaligus.

```http
POST /api/v1/admin/verifications/bulk-verify
```

#### Request Body

```json
{
    "payment_ids": [1, 2, 3],
    "status": "approved",
    "note": "Bulk verification completed"
}
```

#### Response

```json
{
    "success": true,
    "message": "Bulk verification completed",
    "data": [
        {
            "payment_id": 1,
            "success": true,
            "verification_id": 1
        },
        {
            "payment_id": 2,
            "success": true,
            "verification_id": 2
        },
        {
            "payment_id": 3,
            "success": false,
            "error": "Payment already verified"
        }
    ]
}
```

### 7. Get Verification Statistics

Mendapatkan statistik verifikasi.

```http
GET /api/v1/admin/verifications/stats
```

#### Query Parameters

| Parameter     | Type    | Required | Description        |
| ------------- | ------- | -------- | ------------------ |
| `start_date`  | date    | No       | Start date filter  |
| `end_date`    | date    | No       | End date filter    |
| `verified_by` | integer | No       | Filter by verifier |

#### Response

```json
{
    "success": true,
    "message": "Verification statistics retrieved successfully",
    "data": {
        "total_verifications": 150,
        "approved_verifications": 120,
        "rejected_verifications": 20,
        "auto_verifications": 80,
        "manual_verifications": 70,
        "average_verification_time": 45,
        "average_proof_score": 85.5,
        "verification_by_verifier": [
            {
                "verified_by": 1,
                "count": 50,
                "avg_duration": 40,
                "verifier": {
                    "id": 1,
                    "full_name": "Admin User"
                }
            }
        ]
    }
}
```

### 8. Get Verification History

Mendapatkan riwayat verifikasi untuk pembayaran tertentu.

```http
GET /api/v1/admin/verifications/{paymentId}/history
```

#### Response

```json
{
    "success": true,
    "message": "Verification history retrieved successfully",
    "data": [
        {
            "id": 1,
            "status": "approved",
            "note": "Payment verified successfully",
            "auto_verified": false,
            "created_at": "2025-01-15T14:35:00Z",
            "verified_by": {
                "id": 1,
                "full_name": "Admin User"
            }
        }
    ]
}
```

### 9. Get Verification Queue

Mendapatkan antrian verifikasi.

```http
GET /api/v1/admin/verifications/queue
```

#### Query Parameters

| Parameter     | Type    | Required | Description                 |
| ------------- | ------- | -------- | --------------------------- |
| `verifier_id` | integer | No       | Filter by assigned verifier |

#### Response

```json
{
    "success": true,
    "message": "Verification queue retrieved successfully",
    "data": [
        {
            "id": 1,
            "amount": 100000,
            "status": "pending",
            "payment_proof_path": "proofs/payment_1.jpg",
            "assigned_to": null,
            "created_at": "2025-01-15T14:30:00Z",
            "user": {
                "id": 1,
                "full_name": "John Doe"
            },
            "booking": {
                "id": 1,
                "booking_reference": "BK001"
            }
        }
    ]
}
```

### 10. Assign Verification

Menugaskan verifikasi kepada admin tertentu.

```http
POST /api/v1/admin/verifications/{paymentId}/assign
```

#### Request Body

```json
{
    "verifier_id": 1
}
```

#### Response

```json
{
    "success": true,
    "message": "Verification assigned successfully",
    "data": {
        "id": 1,
        "assigned_to": 1,
        "status": "pending"
    }
}
```

### 11. Unassign Verification

Membatalkan penugasan verifikasi.

```http
DELETE /api/v1/admin/verifications/{paymentId}/assign
```

#### Response

```json
{
    "success": true,
    "message": "Verification unassigned successfully",
    "data": {
        "id": 1,
        "assigned_to": null,
        "status": "pending"
    }
}
```

### 12. Get Verification Details

Mendapatkan detail lengkap untuk verifikasi pembayaran.

```http
GET /api/v1/admin/verifications/{paymentId}/details
```

#### Response

```json
{
    "success": true,
    "message": "Verification details retrieved successfully",
    "data": {
        "payment": {
            "id": 1,
            "amount": 100000,
            "status": "pending",
            "payment_proof_path": "proofs/payment_1.jpg",
            "user": {
                "id": 1,
                "full_name": "John Doe"
            },
            "booking": {
                "id": 1,
                "booking_reference": "BK001",
                "total_amount": 100000
            },
            "bank_account": {
                "id": 1,
                "bank_name": "BCA"
            }
        },
        "verification_score": 95.0,
        "auto_verification_criteria": {
            "can_auto_verify": true,
            "score": 95,
            "criteria_met": {
                "has_proof": true,
                "amount_match": true,
                "valid_bank_account": true,
                "not_expired": true
            }
        },
        "verification_history": []
    }
}
```

## Error Responses

### Validation Error

```json
{
    "success": false,
    "message": "Validation failed",
    "errors": {
        "payment_id": ["Payment is required"],
        "status": ["Invalid verification status"]
    }
}
```

### Business Logic Error

```json
{
    "success": false,
    "message": "Payment cannot be verified"
}
```

### Not Found Error

```json
{
    "success": false,
    "message": "Payment not found"
}
```

## Status Codes

| Code | Description                    |
| ---- | ------------------------------ |
| 200  | Success                        |
| 201  | Created                        |
| 400  | Bad Request / Validation Error |
| 401  | Unauthorized                   |
| 403  | Forbidden (Insufficient role)  |
| 404  | Not Found                      |
| 422  | Validation Error               |
| 500  | Internal Server Error          |

## Models

### PaymentVerification

```php
class PaymentVerification extends Model
{
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
}
```

### Payment

```php
class Payment extends Model
{
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
        'assigned_to',
    ];
}
```

## Business Logic

### Verification Score Calculation

Sistem menghitung score otomatis berdasarkan:

1. **Proof exists** (30 points)
2. **Amount match** (25 points)
3. **Bank account match** (20 points)
4. **Payment method** (15 points)
5. **Not expired** (10 points)

**Total maksimal: 100 points**

### Auto-verification Threshold

-   **Score >= 80**: Auto-verified
-   **Score < 80**: Manual verification required

### Verification Workflow

1. Payment dibuat dengan status `pending`
2. Admin dapat assign verification ke verifier tertentu
3. Verifier melakukan verifikasi manual atau sistem auto-verify
4. Payment status berubah menjadi `verified` atau `rejected`
5. Booking payment status diupdate sesuai hasil verifikasi

## Testing

### Running Tests

```bash
# Run all Payment Verification tests
php artisan test --filter=PaymentVerificationTest

# Run specific test
php artisan test --filter=test_admin_can_assign_verification
```

### Test Coverage

-   ✅ Admin verification interface
-   ✅ Payment proof validation
-   ✅ Verification workflow
-   ✅ Rejection handling
-   ✅ Verification notifications
-   ✅ Verification history
-   ✅ Auto-verification system
-   ✅ Bulk verification
-   ✅ Assignment system
-   ✅ Statistics and reporting

## Security

-   Semua endpoint memerlukan authentication
-   Role-based access control (admin only)
-   Input validation dan sanitization
-   Database transactions untuk data consistency
-   Logging untuk audit trail

## Rate Limiting

-   Default: 60 requests per minute per user
-   Admin endpoints: 120 requests per minute per admin
-   Bulk operations: 10 requests per minute per admin

## Monitoring

-   Verification duration tracking
-   Auto-verification success rate
-   Admin performance metrics
-   Error rate monitoring
-   Queue length monitoring
