# Guest User Management API

## Overview

Sistem manajemen guest user memungkinkan pengguna untuk menggunakan layanan tanpa perlu registrasi penuh sebagai member. Guest user memiliki akun sementara yang dapat dikonversi menjadi member penuh.

## Features

- **Guest Registration**: Registrasi akun guest sementara
- **Guest Login**: Login menggunakan email dan temporary token
- **Guest to Member Conversion**: Konversi akun guest menjadi member penuh
- **Profile Management**: Update profil guest user
- **Expiry Extension**: Perpanjangan masa aktif akun guest
- **Analytics**: Tracking aktivitas dan statistik guest user
- **Automatic Cleanup**: Pembersihan otomatis akun guest yang expired

## API Endpoints

### 1. Guest Registration

**POST** `/api/v1/guests/register`

Mendaftarkan guest user baru.

#### Request Body

```json
{
    "email": "guest@example.com",
    "name": "Guest User",
    "phone": "081234567890"
}
```

#### Response

```json
{
    "success": true,
    "message": "Guest user registered successfully",
    "data": {
        "guest": {
            "id": 1,
            "email": "guest@example.com",
            "name": "Guest User",
            "phone": "081234567890",
            "temp_token": "abc123...",
            "expires_at": "2024-02-15T10:00:00Z",
            "created_at": "2024-01-15T10:00:00Z",
            "updated_at": "2024-01-15T10:00:00Z"
        },
        "temp_token": "abc123...",
        "expires_at": "2024-02-15T10:00:00Z"
    }
}
```

#### Error Responses

- **422**: Email sudah terdaftar sebagai guest atau user
- **422**: Validasi gagal

### 2. Guest Login

**POST** `/api/v1/guests/login`

Login menggunakan email dan temporary token.

#### Request Body

```json
{
    "email": "guest@example.com",
    "temp_token": "abc123..."
}
```

#### Response

```json
{
    "success": true,
    "message": "Guest login successful",
    "data": {
        "guest": {
            "id": 1,
            "email": "guest@example.com",
            "name": "Guest User",
            "phone": "081234567890",
            "temp_token": "abc123...",
            "expires_at": "2024-02-15T10:00:00Z"
        },
        "temp_token": "abc123...",
        "expires_at": "2024-02-15T10:00:00Z"
    }
}
```

#### Error Responses

- **401**: Invalid credentials atau akun expired
- **422**: Validasi gagal

### 3. Convert to Member

**POST** `/api/v1/guests/convert-to-member`

Mengkonversi guest user menjadi member penuh.

#### Request Body

```json
{
    "temp_token": "abc123...",
    "password": "password123",
    "password_confirmation": "password123",
    "name": "Updated Name",
    "phone": "081234567999",
    "date_of_birth": "1990-01-01",
    "gender": "male",
    "address": "Jl. Example No. 123",
    "emergency_contact_name": "Emergency Contact",
    "emergency_contact_phone": "081234567888"
}
```

#### Response

```json
{
    "success": true,
    "message": "Guest converted to member successfully",
    "data": {
        "user": {
            "id": 1,
            "name": "Updated Name",
            "email": "guest@example.com",
            "phone": "081234567999",
            "date_of_birth": "1990-01-01",
            "gender": "male",
            "address": "Jl. Example No. 123",
            "emergency_contact_name": "Emergency Contact",
            "emergency_contact_phone": "081234567888",
            "email_verified_at": "2024-01-15T10:00:00Z",
            "roles": [
                {
                    "id": 2,
                    "name": "member",
                    "display_name": "Member"
                }
            ]
        },
        "token": "1|def456...",
        "token_type": "Bearer",
        "guest_data": {
            "total_bookings": 5,
            "total_spent": 250000,
            "conversion_date": "2024-01-15T10:00:00Z"
        }
    }
}
```

#### Error Responses

- **401**: Invalid token atau akun expired
- **422**: Email sudah terdaftar sebagai user
- **422**: Validasi gagal

### 4. Get Guest Profile

**GET** `/api/v1/guests/profile?temp_token=abc123...`

Mendapatkan profil guest user.

#### Response

```json
{
    "success": true,
    "message": "Guest profile retrieved successfully",
    "data": {
        "guest": {
            "id": 1,
            "email": "guest@example.com",
            "name": "Guest User",
            "phone": "081234567890",
            "temp_token": "abc123...",
            "expires_at": "2024-02-15T10:00:00Z",
            "last_activity_at": "2024-01-15T09:30:00Z",
            "session_count": 5,
            "total_bookings": 3,
            "total_spent": 150000
        },
        "bookings": [],
        "stats": {
            "total_bookings": 3,
            "total_spent": 150000,
            "session_count": 5,
            "days_remaining": 30
        }
    }
}
```

#### Error Responses

- **401**: Invalid token atau akun expired

### 5. Update Guest Profile

**PUT** `/api/v1/guests/profile`

Update profil guest user.

#### Request Body

```json
{
    "temp_token": "abc123...",
    "name": "Updated Name",
    "phone": "081234567999"
}
```

#### Response

```json
{
    "success": true,
    "message": "Guest profile updated successfully",
    "data": {
        "id": 1,
        "email": "guest@example.com",
        "name": "Updated Name",
        "phone": "081234567999",
        "temp_token": "abc123...",
        "expires_at": "2024-02-15T10:00:00Z"
    }
}
```

#### Error Responses

- **401**: Invalid token atau akun expired
- **422**: Validasi gagal

### 6. Extend Guest Expiry

**POST** `/api/v1/guests/extend-expiry`

Memperpanjang masa aktif akun guest.

#### Request Body

```json
{
    "temp_token": "abc123...",
    "days": 15
}
```

#### Response

```json
{
    "success": true,
    "message": "Guest account expiry extended successfully",
    "data": {
        "guest": {
            "id": 1,
            "email": "guest@example.com",
            "name": "Guest User",
            "expires_at": "2024-03-01T10:00:00Z"
        },
        "new_expiry": "2024-03-01T10:00:00Z"
    }
}
```

#### Error Responses

- **401**: Invalid token atau akun expired
- **422**: Validasi gagal

### 7. Get Guest Statistics

**GET** `/api/v1/guests/stats?temp_token=abc123...`

Mendapatkan statistik guest user.

#### Response

```json
{
    "success": true,
    "message": "Guest statistics retrieved successfully",
    "data": {
        "total_bookings": 3,
        "total_spent": 150000,
        "session_count": 5,
        "days_remaining": 30,
        "last_activity": "2024-01-15T09:30:00Z",
        "created_at": "2024-01-15T10:00:00Z",
        "expires_at": "2024-02-15T10:00:00Z"
    }
}
```

#### Error Responses

- **401**: Invalid token atau akun expired

## Data Models

### GuestUser

```php
{
    "id": 1,
    "email": "guest@example.com",
    "name": "Guest User",
    "phone": "081234567890",
    "temp_token": "abc123...",
    "expires_at": "2024-02-15T10:00:00Z",
    "converted_to_member": false,
    "conversion_date": null,
    "member_id": null,
    "last_activity_at": "2024-01-15T09:30:00Z",
    "session_count": 5,
    "total_bookings": 3,
    "total_spent": 150000,
    "created_at": "2024-01-15T10:00:00Z",
    "updated_at": "2024-01-15T10:00:00Z"
}
```

## Business Rules

### Guest Account Lifecycle

1. **Registration**: Guest user terdaftar dengan masa aktif 30 hari
2. **Activity Tracking**: Setiap aktivitas memperbarui `last_activity_at`
3. **Expiry Extension**: Maksimal 30 hari per ekstensi
4. **Conversion**: Guest dapat dikonversi menjadi member kapan saja
5. **Cleanup**: Akun expired dihapus otomatis setelah 7 hari

### Validation Rules

- **Email**: Harus unik, tidak boleh sama dengan user yang sudah ada
- **Name**: Required, maksimal 255 karakter
- **Phone**: Optional, maksimal 20 karakter
- **Password**: Required untuk konversi, minimal 6 karakter, harus confirmed
- **Date of Birth**: Optional, harus sebelum hari ini
- **Gender**: Optional, hanya 'male' atau 'female'

### Security

- **Temporary Token**: 64 karakter random string
- **Token Expiry**: Token tidak valid setelah akun expired
- **Email Verification**: Member yang dikonversi otomatis verified
- **Password Hashing**: Password di-hash menggunakan bcrypt

## Error Codes

| Code | Description |
|------|-------------|
| 400 | Bad Request |
| 401 | Unauthorized (Invalid token/expired) |
| 422 | Validation Error |
| 500 | Internal Server Error |

## Rate Limiting

- **Registration**: 5 requests per minute per IP
- **Login**: 10 requests per minute per IP
- **Other endpoints**: 20 requests per minute per IP

## Testing

### Test Coverage

- Unit tests untuk GuestUser model
- Feature tests untuk semua API endpoints
- Integration tests untuk guest to member conversion
- Validation tests untuk semua request rules

### Test Commands

```bash
# Run all guest user tests
php artisan test --filter=GuestUser

# Run specific test file
php artisan test tests/Feature/GuestUserManagementTest.php
php artisan test tests/Unit/GuestUserTest.php
```

## Scheduled Tasks

### Cleanup Job

- **Schedule**: Daily at 2:00 AM
- **Purpose**: Clean up expired guest accounts
- **Actions**:
  - Delete guest accounts expired > 7 days
  - Extend expiry for inactive accounts (14+ days)
  - Log cleanup statistics

### Manual Cleanup

```bash
# Run cleanup job manually
php artisan queue:work --queue=default
```

## Future Enhancements

1. **Email Notifications**: Notifikasi expiry dan conversion
2. **Guest Analytics**: Dashboard untuk tracking guest behavior
3. **Bulk Operations**: Bulk conversion dan cleanup
4. **Guest Preferences**: Simpan preferensi guest user
5. **Integration**: Integrasi dengan sistem booking dan payment
