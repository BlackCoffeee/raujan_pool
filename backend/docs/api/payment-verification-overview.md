# Payment Verification API - Overview

## Deskripsi

Payment Verification API adalah sistem yang memungkinkan admin untuk memverifikasi pembayaran manual transfer dengan berbagai fitur canggih seperti auto-verification, bulk verification, dan assignment system.

## Fitur Utama

-   **Admin Verification Interface** - Interface untuk admin memverifikasi pembayaran
-   **Payment Proof Validation** - Validasi bukti pembayaran dengan scoring system
-   **Auto-verification** - Verifikasi otomatis berdasarkan kriteria sistem
-   **Bulk Verification** - Verifikasi multiple pembayaran sekaligus
-   **Assignment System** - Penugasan verifikasi ke admin tertentu
-   **Statistics & Reporting** - Laporan dan statistik verifikasi
-   **Verification History** - Riwayat lengkap verifikasi

## Base URL

```
https://api.raujanpool.com/api/v1/admin/verifications
```

## Authentication

Semua endpoint memerlukan authentication dengan Bearer token dan role admin.

```http
Authorization: Bearer {token}
```

## Endpoint Groups

### 1. Core Verification

-   `GET /` - Get pending verifications
-   `POST /` - Create verification
-   `GET /{id}` - Get verification details
-   `POST /{paymentId}/verify` - Verify payment

### 2. Auto-verification

-   `POST /{paymentId}/auto-verify` - Auto-verify payment

### 3. Bulk Operations

-   `POST /bulk-verify` - Bulk verify payments

### 4. Statistics & Reporting

-   `GET /stats` - Get verification statistics
-   `GET /{paymentId}/history` - Get verification history
-   `GET /queue` - Get verification queue

### 5. Assignment Management

-   `POST /{paymentId}/assign` - Assign verification
-   `DELETE /{paymentId}/assign` - Unassign verification

### 6. Detailed Information

-   `GET /{paymentId}/details` - Get comprehensive verification details

## Business Logic

### Verification Score System

Sistem menghitung score otomatis berdasarkan:

1. **Proof exists** (30 points) - Ada bukti pembayaran
2. **Amount match** (25 points) - Jumlah pembayaran sesuai booking
3. **Bank account match** (20 points) - Rekening bank sesuai
4. **Payment method** (15 points) - Metode pembayaran manual_transfer
5. **Not expired** (10 points) - Pembayaran belum expired

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

## Security Features

-   Authentication required untuk semua endpoint
-   Role-based access control (admin only)
-   Input validation dan sanitization
-   Database transactions untuk data consistency
-   Comprehensive logging untuk audit trail

## Rate Limiting

-   Default: 60 requests per minute per user
-   Admin endpoints: 120 requests per minute per admin
-   Bulk operations: 10 requests per minute per admin

## Testing Status

✅ **All tests passing** - Sistem telah diuji secara menyeluruh

```bash
# Run all Payment Verification tests
php artisan test --filter=PaymentVerificationTest
```

## Implementation Status

✅ **Complete** - Semua fitur telah diimplementasikan dan berfungsi dengan baik
