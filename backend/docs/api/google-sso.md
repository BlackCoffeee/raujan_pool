# Google SSO API Documentation

## Overview

Google Single Sign-On (SSO) integration memungkinkan pengguna untuk login menggunakan akun Google mereka. API ini menggunakan Laravel Socialite untuk mengintegrasikan dengan Google OAuth 2.0.

## Endpoints

### 1. Get Google OAuth Redirect URL

**Endpoint:** `GET /api/v1/auth/google`

**Description:** Mendapatkan URL redirect untuk Google OAuth authentication.

**Request:**

```http
GET /api/v1/auth/google
```

**Response:**

```json
{
    "success": true,
    "message": "Google OAuth redirect URL generated",
    "data": {
        "redirect_url": "https://accounts.google.com/oauth/authorize?client_id=...&redirect_uri=...&scope=openid+profile+email&response_type=code&state=..."
    }
}
```

**Error Response:**

```json
{
    "success": false,
    "message": "Failed to generate Google OAuth URL: [error message]",
    "data": null
}
```

### 2. Google OAuth Callback

**Endpoint:** `GET /api/v1/auth/google/callback`

**Description:** Menangani callback dari Google OAuth setelah user melakukan autentikasi.

**Request:**

```http
GET /api/v1/auth/google/callback?code=[authorization_code]&state=[state_parameter]
```

**Response:**

```json
{
    "success": true,
    "message": "Google authentication successful",
    "data": {
        "user": {
            "id": 1,
            "name": "John Doe",
            "email": "john@gmail.com",
            "google_id": "123456789",
            "google_avatar": "https://lh3.googleusercontent.com/avatar.jpg",
            "email_verified_at": "2025-09-01T02:48:34.000000Z",
            "is_active": true,
            "roles": [
                {
                    "id": 4,
                    "name": "guest",
                    "display_name": "Guest"
                }
            ]
        },
        "token": "1|abcdef123456...",
        "token_type": "Bearer",
        "expires_in": null,
        "is_new_user": true
    }
}
```

**Error Responses:**

**Invalid State Parameter:**

```json
{
    "success": false,
    "message": "Invalid state parameter",
    "data": null
}
```

**Google Authentication Failed:**

```json
{
    "success": false,
    "message": "Failed to authenticate with Google: [error message]",
    "data": null
}
```

**Account Inactive:**

```json
{
    "success": false,
    "message": "Account is inactive",
    "data": null
}
```

### 3. Link Google Account

**Endpoint:** `POST /api/v1/auth/google/link`

**Description:** Menghubungkan akun Google ke user yang sudah login.

**Headers:**

```http
Authorization: Bearer {access_token}
```

**Request:**

```http
POST /api/v1/auth/google/link
```

**Response:**

```json
{
    "success": true,
    "message": "Google account linked successfully",
    "data": {
        "user": {
            "id": 1,
            "name": "John Doe",
            "email": "john@example.com",
            "google_id": "123456789",
            "google_avatar": "https://lh3.googleusercontent.com/avatar.jpg",
            "roles": [...]
        }
    }
}
```

**Error Responses:**

**Already Linked:**

```json
{
    "success": false,
    "message": "Google account is already linked",
    "data": null
}
```

**Account Already Linked to Another User:**

```json
{
    "success": false,
    "message": "This Google account is already linked to another user",
    "data": null
}
```

### 4. Unlink Google Account

**Endpoint:** `DELETE /api/v1/auth/google/unlink`

**Description:** Memutuskan hubungan akun Google dari user.

**Headers:**

```http
Authorization: Bearer {access_token}
```

**Request:**

```http
DELETE /api/v1/auth/google/unlink
```

**Response:**

```json
{
    "success": true,
    "message": "Google account unlinked successfully",
    "data": {
        "user": {
            "id": 1,
            "name": "John Doe",
            "email": "john@example.com",
            "google_id": null,
            "google_avatar": null,
            "roles": [...]
        }
    }
}
```

**Error Responses:**

**No Google Account Linked:**

```json
{
    "success": false,
    "message": "No Google account linked",
    "data": null
}
```

**Cannot Unlink Without Password:**

```json
{
    "success": false,
    "message": "Cannot unlink Google account. Please set a password first.",
    "data": null
}
```

## Authentication Flow

### 1. Frontend Integration

```javascript
// 1. Get Google OAuth URL
const response = await fetch("/api/v1/auth/google");
const data = await response.json();

if (data.success) {
    // 2. Redirect user to Google
    window.location.href = data.data.redirect_url;
}
```

### 2. Callback Handling

```javascript
// After user returns from Google OAuth
// The callback URL will be called automatically
// You can handle the response in your frontend
```

### 3. Link/Unlink Account

```javascript
// Link Google account
const linkResponse = await fetch("/api/v1/auth/google/link", {
    method: "POST",
    headers: {
        Authorization: `Bearer ${token}`,
        "Content-Type": "application/json",
    },
});

// Unlink Google account
const unlinkResponse = await fetch("/api/v1/auth/google/unlink", {
    method: "DELETE",
    headers: {
        Authorization: `Bearer ${token}`,
        "Content-Type": "application/json",
    },
});
```

## Security Features

### 1. State Parameter Validation

-   Setiap request OAuth menggunakan state parameter yang unik
-   State parameter divalidasi untuk mencegah CSRF attacks

### 2. Email Domain Restriction (Optional)

-   Dapat dikonfigurasi untuk membatasi domain email yang diizinkan
-   Konfigurasi melalui `GOOGLE_ALLOWED_DOMAINS` di environment

### 3. Account Linking Protection

-   Mencegah satu akun Google dihubungkan ke multiple user
-   Validasi bahwa user memiliki password sebelum unlink

### 4. Rate Limiting

-   OAuth endpoints dapat dikonfigurasi dengan rate limiting
-   Default: 10 requests per minute per IP

## Configuration

### Environment Variables

```env
# Google OAuth Configuration
GOOGLE_CLIENT_ID=your-google-client-id.apps.googleusercontent.com
GOOGLE_CLIENT_SECRET=your-google-client-secret
GOOGLE_REDIRECT_URI=http://localhost:8000/api/v1/auth/google/callback

# Optional: Restrict to specific email domains
GOOGLE_ALLOWED_DOMAINS=gmail.com,company.com
```

### Google Cloud Console Setup

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project or select existing one
3. Enable Google+ API
4. Go to Credentials → Create Credentials → OAuth 2.0 Client ID
5. Configure OAuth consent screen
6. Add authorized redirect URIs:
    - `http://localhost:8000/api/v1/auth/google/callback` (development)
    - `https://yourdomain.com/api/v1/auth/google/callback` (production)

## User Data Handling

### New User Creation

-   User baru otomatis dibuat dengan role "guest"
-   Email otomatis diverifikasi
-   Password random dibuat untuk keamanan

### Existing User Linking

-   Jika email sudah ada, akun Google dihubungkan ke user existing
-   Profile data Google (avatar, dll) diupdate

### Profile Data Sync

-   `google_id`: ID unik dari Google
-   `google_avatar`: URL avatar dari Google
-   `email_verified_at`: Otomatis diset ke waktu sekarang

## Error Handling

### Common Error Codes

-   `400`: Bad Request (invalid state, already linked, etc.)
-   `403`: Forbidden (account inactive)
-   `500`: Internal Server Error (Google API errors, database errors)

### Error Response Format

```json
{
    "success": false,
    "message": "Error description",
    "data": null,
    "errors": {
        "field": ["Validation error message"]
    }
}
```

## Testing

### Test Coverage

-   Unit tests untuk semua controller methods
-   Integration tests untuk OAuth flow
-   Mock Socialite untuk testing tanpa Google API

### Running Tests

```bash
# Run Google SSO tests
php artisan test tests/Feature/GoogleAuthTest.php

# Run all tests
php artisan test
```

## Best Practices

### 1. Frontend Implementation

-   Selalu gunakan HTTPS di production
-   Implement proper error handling
-   Show loading states during OAuth flow

### 2. Security

-   Jangan expose client secret di frontend
-   Gunakan state parameter untuk CSRF protection
-   Implement rate limiting

### 3. User Experience

-   Berikan fallback untuk user yang tidak bisa menggunakan Google OAuth
-   Tampilkan status linking/unlinking dengan jelas
-   Handle edge cases (network errors, popup blockers)

## Troubleshooting

### Common Issues

1. **"Invalid state parameter"**

    - Pastikan session storage berfungsi dengan baik
    - Check bahwa state parameter tidak expired

2. **"Failed to authenticate with Google"**

    - Verify Google OAuth credentials
    - Check redirect URI configuration
    - Ensure Google+ API is enabled

3. **"Account is inactive"**

    - User account mungkin dinonaktifkan
    - Check `is_active` field di database

4. **"Cannot unlink Google account"**
    - User harus memiliki password sebelum unlink
    - Pastikan user tidak hanya bergantung pada Google OAuth

### Debug Mode

Untuk debugging, tambahkan logging di controller:

```php
Log::info('Google OAuth Debug', [
    'user_id' => $user->id,
    'google_id' => $googleUser->getId(),
    'email' => $googleUser->getEmail()
]);
```
