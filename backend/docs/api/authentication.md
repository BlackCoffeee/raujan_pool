# API Authentication Documentation

## Overview

API authentication menggunakan Laravel Sanctum untuk token-based authentication. Sistem ini menyediakan endpoints untuk login, register, logout, dan manajemen token.

## Base URL

```
https://api.raujanpool.com/api/v1/auth
```

## Authentication Flow

1. **Register/Login** - User mendaftar atau login untuk mendapatkan access token
2. **Token Usage** - Token digunakan dalam header Authorization untuk mengakses protected endpoints
3. **Token Refresh** - Token dapat di-refresh untuk memperpanjang masa aktif
4. **Logout** - Token dapat di-revoke untuk logout

## Endpoints

### 1. Login

**POST** `/api/v1/auth/login`

Login dengan email dan password untuk mendapatkan access token.

#### Request Body

```json
{
    "email": "user@example.com",
    "password": "password123"
}
```

#### Response Success (200)

```json
{
    "success": true,
    "message": "Login successful",
    "data": {
        "user": {
            "id": 1,
            "name": "John Doe",
            "email": "user@example.com",
            "phone": "081234567890",
            "date_of_birth": "1990-01-01",
            "gender": "male",
            "address": "Jl. Example No. 123",
            "emergency_contact_name": "Jane Doe",
            "emergency_contact_phone": "081234567891",
            "is_active": true,
            "last_login_at": "2024-01-01T10:00:00.000000Z",
            "created_at": "2024-01-01T09:00:00.000000Z",
            "updated_at": "2024-01-01T10:00:00.000000Z",
            "roles": [
                {
                    "id": 1,
                    "name": "member",
                    "display_name": "Member",
                    "description": "Regular member"
                }
            ]
        },
        "token": "1|abcdef1234567890abcdef1234567890abcdef12",
        "token_type": "Bearer",
        "expires_in": 10080
    }
}
```

#### Response Error (422)

```json
{
    "success": false,
    "message": "The provided credentials are incorrect.",
    "data": null,
    "errors": {
        "email": ["The provided credentials are incorrect."]
    }
}
```

#### Response Error (403)

```json
{
    "success": false,
    "message": "Account is inactive",
    "data": null
}
```

### 2. Register

**POST** `/api/v1/auth/register`

Mendaftar user baru dan mendapatkan access token.

#### Request Body

```json
{
    "name": "John Doe",
    "email": "john@example.com",
    "password": "password123",
    "password_confirmation": "password123",
    "phone": "081234567890",
    "date_of_birth": "1990-01-01",
    "gender": "male",
    "address": "Jl. Example No. 123",
    "emergency_contact_name": "Jane Doe",
    "emergency_contact_phone": "081234567891"
}
```

#### Response Success (201)

```json
{
    "success": true,
    "message": "Registration successful",
    "data": {
        "user": {
            "id": 2,
            "name": "John Doe",
            "email": "john@example.com",
            "phone": "081234567890",
            "date_of_birth": "1990-01-01",
            "gender": "male",
            "address": "Jl. Example No. 123",
            "emergency_contact_name": "Jane Doe",
            "emergency_contact_phone": "081234567891",
            "is_active": true,
            "last_login_at": null,
            "created_at": "2024-01-01T10:00:00.000000Z",
            "updated_at": "2024-01-01T10:00:00.000000Z",
            "roles": [
                {
                    "id": 3,
                    "name": "guest",
                    "display_name": "Guest",
                    "description": "Guest user"
                }
            ]
        },
        "token": "2|abcdef1234567890abcdef1234567890abcdef12",
        "token_type": "Bearer",
        "expires_in": 10080
    }
}
```

#### Response Error (422)

```json
{
    "success": false,
    "message": "Validation failed",
    "data": null,
    "errors": {
        "email": ["This email is already registered"],
        "password": ["Password confirmation does not match"]
    }
}
```

### 3. Logout

**POST** `/api/v1/auth/logout`

Logout dan revoke current access token.

#### Headers

```
Authorization: Bearer {token}
```

#### Response Success (200)

```json
{
    "success": true,
    "message": "Logout successful",
    "data": null
}
```

### 4. Get User Data

**GET** `/api/v1/auth/user`

Mendapatkan data user yang sedang login.

#### Headers

```
Authorization: Bearer {token}
```

#### Response Success (200)

```json
{
    "success": true,
    "message": "User data retrieved successfully",
    "data": {
        "id": 1,
        "name": "John Doe",
        "email": "user@example.com",
        "phone": "081234567890",
        "date_of_birth": "1990-01-01",
        "gender": "male",
        "address": "Jl. Example No. 123",
        "emergency_contact_name": "Jane Doe",
        "emergency_contact_phone": "081234567891",
        "is_active": true,
        "last_login_at": "2024-01-01T10:00:00.000000Z",
        "created_at": "2024-01-01T09:00:00.000000Z",
        "updated_at": "2024-01-01T10:00:00.000000Z",
        "roles": [
            {
                "id": 1,
                "name": "member",
                "display_name": "Member",
                "description": "Regular member"
            }
        ]
    }
}
```

### 5. Refresh Token

**POST** `/api/v1/auth/refresh`

Refresh access token untuk memperpanjang masa aktif.

#### Headers

```
Authorization: Bearer {token}
```

#### Response Success (200)

```json
{
    "success": true,
    "message": "Token refreshed successfully",
    "data": {
        "token": "3|newabcdef1234567890abcdef1234567890abcdef12",
        "token_type": "Bearer",
        "expires_in": 10080
    }
}
```

### 6. Revoke All Tokens

**POST** `/api/v1/auth/revoke-all-tokens`

Revoke semua token untuk user yang sedang login.

#### Headers

```
Authorization: Bearer {token}
```

#### Response Success (200)

```json
{
    "success": true,
    "message": "All tokens revoked successfully",
    "data": null
}
```

## Token Management

### Token Format

Token menggunakan format Laravel Sanctum:

-   **Type**: Bearer Token
-   **Format**: `{id}|{random_string}`
-   **Expiration**: 7 hari (dapat dikonfigurasi)

### Using Token

Include token dalam header Authorization:

```http
Authorization: Bearer 1|abcdef1234567890abcdef1234567890abcdef12
```

### Token Abilities

Token dapat dibuat dengan abilities tertentu:

```php
// Create token with specific abilities
$token = $user->createToken('auth-token', ['read', 'write']);

// Check token abilities
if ($request->user()->tokenCan('read')) {
    // User can read
}
```

## Error Responses

### 401 Unauthorized

```json
{
    "message": "Unauthenticated."
}
```

### 403 Forbidden

```json
{
    "success": false,
    "message": "Account is inactive",
    "data": null
}
```

### 422 Validation Error

```json
{
    "success": false,
    "message": "Validation failed",
    "data": null,
    "errors": {
        "field_name": ["Error message"]
    }
}
```

## Rate Limiting

Authentication endpoints memiliki rate limiting:

-   **Login**: 5 attempts per minute per IP
-   **Register**: 5 attempts per minute per IP

## Security Features

1. **Token Expiration**: Token memiliki masa aktif 7 hari
2. **Token Revocation**: Token dapat di-revoke kapan saja
3. **Rate Limiting**: Mencegah brute force attacks
4. **Account Status**: Inactive accounts tidak dapat login
5. **Password Hashing**: Password di-hash menggunakan bcrypt
6. **CSRF Protection**: Untuk SPA authentication (jika diperlukan)

## Example Usage

### JavaScript/Fetch

```javascript
// Login
const loginResponse = await fetch("/api/v1/auth/login", {
    method: "POST",
    headers: {
        "Content-Type": "application/json",
        Accept: "application/json",
    },
    body: JSON.stringify({
        email: "user@example.com",
        password: "password123",
    }),
});

const loginData = await loginResponse.json();
const token = loginData.data.token;

// Use token for authenticated requests
const userResponse = await fetch("/api/v1/auth/user", {
    headers: {
        Authorization: `Bearer ${token}`,
        Accept: "application/json",
    },
});

const userData = await userResponse.json();
```

### cURL

```bash
# Login
curl -X POST https://api.raujanpool.com/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d '{
    "email": "user@example.com",
    "password": "password123"
  }'

# Use token
curl -X GET https://api.raujanpool.com/api/v1/auth/user \
  -H "Authorization: Bearer 1|abcdef1234567890abcdef1234567890abcdef12" \
  -H "Accept: application/json"
```

## Testing

Authentication endpoints dapat di-test menggunakan:

```bash
# Run authentication tests
php artisan test tests/Feature/Auth/ApiAuthenticationTest.php

# Run all tests
php artisan test
```

## Configuration

Token expiration dapat dikonfigurasi di `.env`:

```env
SANCTUM_EXPIRATION=10080  # 7 days in minutes
```

Atau di `config/sanctum.php`:

```php
'expiration' => env('SANCTUM_EXPIRATION', 60 * 24 * 7), // 7 days
```
