# Member Schema Revision v2 - API Documentation

## 📋 Overview

Dokumentasi API untuk Member Schema Revision v2 yang mencakup endpoint untuk:

1. **Member Registration** dengan biaya registrasi dinamis
2. **Member Status Management** dengan lifecycle yang jelas
3. **Member Reactivation** dengan biaya reaktivasi
4. **System Configuration** untuk admin
5. **Payment Management** untuk tracking pembayaran

## 🔧 API Endpoints

### 1. **Member Registration**

#### POST `/api/v1/members/register`

Mendaftarkan member baru dengan schema yang telah direvisi.

**Request Body:**

```json
{
    "user_id": 1,
    "membership_type": "quarterly",
    "payment_method": "transfer"
}
```

**Response (Success - 201):**

```json
{
    "success": true,
    "message": "Member registered successfully",
    "data": {
        "member": {
            "id": 1,
            "user_id": 1,
            "user_profile_id": 1,
            "member_code": "Q202509001",
            "status": "active",
            "membership_type": "quarterly",
            "membership_start": "2025-09-10",
            "membership_end": "2025-12-10",
            "registration_method": "manual",
            "registration_fee_paid": 50000,
            "monthly_fee_paid": 0,
            "total_paid": 495000,
            "created_at": "2025-09-10T06:00:00.000000Z",
            "updated_at": "2025-09-10T06:00:00.000000Z"
        },
        "total_amount": 495000,
        "breakdown": {
            "registration_fee": 50000,
            "quarterly_fee": 500000,
            "subtotal": 550000,
            "discount_percentage": 10,
            "discount_amount": 55000,
            "final_amount": 495000
        },
        "payment": {
            "id": 1,
            "payment_type": "registration",
            "amount": 495000,
            "payment_method": "transfer",
            "payment_status": "pending",
            "description": "Member registration payment"
        }
    }
}
```

**Response (Error - 400):**

```json
{
    "success": false,
    "message": "Validation failed",
    "errors": {
        "user_id": ["The user id field is required."],
        "membership_type": ["The selected membership type is invalid."]
    }
}
```

### 2. **Member Status Management**

#### PUT `/api/v1/admin/members/{id}/status`

Mengubah status member (admin only).

**Request Body:**

```json
{
    "status": "inactive",
    "reason": "Membership expired",
    "grace_period_days": 90
}
```

**Response (Success - 200):**

```json
{
    "success": true,
    "message": "Member status updated successfully",
    "data": {
        "member": {
            "id": 1,
            "status": "inactive",
            "status_changed_at": "2025-09-10T06:00:00.000000Z",
            "status_changed_by": 1,
            "status_change_reason": "Membership expired",
            "grace_period_start": "2025-09-10",
            "grace_period_end": "2025-12-09",
            "grace_period_days": 90
        },
        "status_history": {
            "id": 1,
            "previous_status": "active",
            "new_status": "inactive",
            "change_reason": "Membership expired",
            "change_type": "manual",
            "changed_by": 1,
            "changed_at": "2025-09-10T06:00:00.000000Z"
        }
    }
}
```

### 3. **Member Reactivation**

#### POST `/api/v1/members/{id}/reactivate`

Mengaktifkan kembali member yang berstatus non_member.

**Request Body:**

```json
{
    "payment_method": "transfer"
}
```

**Response (Success - 200):**

```json
{
    "success": true,
    "message": "Member reactivated successfully",
    "data": {
        "member": {
            "id": 1,
            "status": "active",
            "reactivation_count": 1,
            "last_reactivation_date": "2025-09-10T06:00:00.000000Z",
            "last_reactivation_fee": 50000
        },
        "total_amount": 495000,
        "breakdown": {
            "reactivation_fee": 50000,
            "quarterly_fee": 500000,
            "subtotal": 550000,
            "discount_percentage": 10,
            "discount_amount": 55000,
            "final_amount": 495000
        },
        "payment": {
            "id": 2,
            "payment_type": "reactivation",
            "amount": 495000,
            "payment_method": "transfer",
            "payment_status": "pending",
            "description": "Member reactivation payment"
        }
    }
}
```

### 4. **System Configuration Management**

#### GET `/api/v1/admin/config/member`

Mendapatkan konfigurasi member saat ini.

**Response (Success - 200):**

```json
{
    "success": true,
    "data": {
        "registration_fee": 50000,
        "grace_period_days": 90,
        "monthly_fee": 200000,
        "quarterly_fee": 500000,
        "quarterly_discount": 10,
        "reactivation_fee": 50000,
        "auto_status_change": true,
        "notification_days_before_expiry": 7,
        "notification_days_after_expiry": 3
    }
}
```

#### PUT `/api/v1/admin/config/member`

Mengupdate konfigurasi member (admin only).

**Request Body:**

```json
{
    "registration_fee": 75000,
    "grace_period_days": 120,
    "reactivation_fee": 75000,
    "quarterly_discount": 15
}
```

**Response (Success - 200):**

```json
{
    "success": true,
    "message": "Member configuration updated successfully",
    "data": {
        "registration_fee": 75000,
        "grace_period_days": 120,
        "monthly_fee": 200000,
        "quarterly_fee": 500000,
        "quarterly_discount": 15,
        "reactivation_fee": 75000,
        "auto_status_change": true,
        "notification_days_before_expiry": 7,
        "notification_days_after_expiry": 3
    }
}
```

### 5. **Member Payment Management**

#### GET `/api/v1/members/{id}/payments`

Mendapatkan riwayat pembayaran member.

**Response (Success - 200):**

```json
{
    "success": true,
    "data": {
        "payments": [
            {
                "id": 1,
                "payment_type": "registration",
                "amount": 495000,
                "payment_method": "transfer",
                "payment_reference": "REG001",
                "payment_date": "2025-09-10T06:00:00.000000Z",
                "payment_status": "paid",
                "description": "Member registration payment",
                "processed_by": 1
            }
        ],
        "total_paid": 495000,
        "total_pending": 0,
        "total_failed": 0
    }
}
```

#### POST `/api/v1/members/{id}/payments`

Membuat pembayaran baru untuk member.

**Request Body:**

```json
{
    "payment_type": "monthly",
    "amount": 200000,
    "payment_method": "transfer",
    "description": "Monthly membership renewal"
}
```

**Response (Success - 201):**

```json
{
    "success": true,
    "message": "Payment created successfully",
    "data": {
        "payment": {
            "id": 2,
            "member_id": 1,
            "payment_type": "monthly",
            "amount": 200000,
            "payment_method": "transfer",
            "payment_status": "pending",
            "description": "Monthly membership renewal",
            "created_at": "2025-09-10T06:00:00.000000Z"
        }
    }
}
```

### 6. **Member Status History**

#### GET `/api/v1/members/{id}/status-history`

Mendapatkan riwayat perubahan status member.

**Response (Success - 200):**

```json
{
    "success": true,
    "data": {
        "history": [
            {
                "id": 1,
                "previous_status": "active",
                "new_status": "inactive",
                "change_reason": "Membership expired",
                "change_type": "automatic",
                "changed_by": null,
                "changed_at": "2025-09-10T06:00:00.000000Z",
                "membership_end_date": "2025-09-10",
                "grace_period_end_date": "2025-12-09"
            }
        ]
    }
}
```

### 7. **Member Information**

#### GET `/api/v1/members/{id}`

Mendapatkan informasi detail member.

**Response (Success - 200):**

```json
{
    "success": true,
    "data": {
        "member": {
            "id": 1,
            "user_id": 1,
            "user_profile_id": 1,
            "member_code": "Q202509001",
            "status": "active",
            "membership_type": "quarterly",
            "membership_start": "2025-09-10",
            "membership_end": "2025-12-10",
            "registration_method": "manual",
            "registration_fee_paid": 50000,
            "monthly_fee_paid": 0,
            "total_paid": 495000,
            "grace_period_start": null,
            "grace_period_end": null,
            "grace_period_days": 90,
            "reactivation_count": 0,
            "last_reactivation_date": null,
            "last_reactivation_fee": 0,
            "created_at": "2025-09-10T06:00:00.000000Z",
            "updated_at": "2025-09-10T06:00:00.000000Z",
            "user": {
                "id": 1,
                "name": "John Doe",
                "email": "john@example.com"
            },
            "user_profile": {
                "id": 1,
                "phone": "+6281234567890",
                "date_of_birth": "1990-01-01"
            }
        }
    }
}
```

## 🔐 Authentication & Authorization

### Authentication

Semua endpoint memerlukan authentication menggunakan Laravel Sanctum:

```bash
Authorization: Bearer {token}
```

### Authorization

-   **Member endpoints**: Hanya member yang bersangkutan atau admin
-   **Admin endpoints**: Hanya admin yang dapat mengakses
-   **Configuration endpoints**: Hanya admin yang dapat mengakses

## 📊 Error Responses

### 400 Bad Request

```json
{
    "success": false,
    "message": "Validation failed",
    "errors": {
        "field_name": ["Error message"]
    }
}
```

### 401 Unauthorized

```json
{
    "success": false,
    "message": "Unauthenticated"
}
```

### 403 Forbidden

```json
{
    "success": false,
    "message": "This action is unauthorized"
}
```

### 404 Not Found

```json
{
    "success": false,
    "message": "Member not found"
}
```

### 500 Internal Server Error

```json
{
    "success": false,
    "message": "Internal server error"
}
```

## 🧪 Testing

### Test Script

Gunakan script testing yang telah disediakan:

```bash
./scripts/test-member-schema-revision.sh
```

### Manual Testing

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

# Test configuration update
curl -X PUT http://localhost:8000/api/v1/admin/config/member \
  -H "Authorization: Bearer {admin_token}" \
  -H "Content-Type: application/json" \
  -d '{
    "registration_fee": 75000,
    "grace_period_days": 120
  }'
```

## 📚 Related Documentation

-   [Member Schema Revision Implementation](../development/member-schema-revision-v2.md)
-   [System Configuration Management](../api/system-configuration.md)
-   [Payment System Documentation](../api/payment-system.md)
-   [Member Management API](../api/member-management.md)

---

**Version**: 2.0  
**Date**: September 10, 2025  
**Status**: Implementation Complete  
**Author**: Development Team
