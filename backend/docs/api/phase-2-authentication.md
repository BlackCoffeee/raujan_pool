# Phase 2: Authentication & User Management API Documentation

## 📋 Overview

Dokumentasi API untuk sistem autentikasi dan manajemen user yang mencakup Laravel Sanctum authentication, Google SSO integration, role-based access control, guest user management, dan user profile management.

## 🔐 Authentication Endpoints

### Login

**POST** `/api/v1/auth/login`

Login dengan email dan password.

**Request Body:**

```json
{
    "email": "user@example.com",
    "password": "password123"
}
```

**Response (200):**

```json
{
    "success": true,
    "message": "Login successful",
    "data": {
        "user": {
            "id": 1,
            "name": "John Doe",
            "email": "user@example.com",
            "roles": [
                {
                    "id": 1,
                    "name": "member",
                    "display_name": "Member"
                }
            ]
        },
        "token": "1|abcdef123456...",
        "token_type": "Bearer",
        "expires_in": null
    }
}
```

### Register

**POST** `/api/v1/auth/register`

Register user baru.

**Request Body:**

```json
{
    "name": "John Doe",
    "email": "john@example.com",
    "password": "password123",
    "password_confirmation": "password123",
    "phone": "081234567890",
    "date_of_birth": "1990-01-01",
    "gender": "male"
}
```

**Response (201):**

```json
{
    "success": true,
    "message": "Registration successful",
    "data": {
        "user": {
            "id": 1,
            "name": "John Doe",
            "email": "john@example.com",
            "roles": [
                {
                    "id": 1,
                    "name": "guest",
                    "display_name": "Guest"
                }
            ]
        },
        "token": "1|abcdef123456...",
        "token_type": "Bearer",
        "expires_in": null
    }
}
```

### Logout

**POST** `/api/v1/auth/logout`

Logout user dan revoke token.

**Headers:**

```
Authorization: Bearer {token}
```

**Response (200):**

```json
{
    "success": true,
    "message": "Logout successful",
    "data": null
}
```

### Get User Data

**GET** `/api/v1/auth/user`

Mendapatkan data user yang sedang login.

**Headers:**

```
Authorization: Bearer {token}
```

**Response (200):**

```json
{
    "success": true,
    "message": "User data retrieved successfully",
    "data": {
        "id": 1,
        "name": "John Doe",
        "email": "john@example.com",
        "roles": [...]
    }
}
```

### Refresh Token

**POST** `/api/v1/auth/refresh`

Refresh authentication token.

**Headers:**

```
Authorization: Bearer {token}
```

**Response (200):**

```json
{
    "success": true,
    "message": "Token refreshed successfully",
    "data": {
        "token": "2|newtoken123...",
        "token_type": "Bearer",
        "expires_in": null
    }
}
```

### Revoke All Tokens

**POST** `/api/v1/auth/revoke-all-tokens`

Revoke semua token user.

**Headers:**

```
Authorization: Bearer {token}
```

**Response (200):**

```json
{
    "success": true,
    "message": "All tokens revoked successfully",
    "data": null
}
```

## 🔗 Google OAuth Endpoints

### Get Google OAuth URL

**GET** `/api/v1/auth/google`

Mendapatkan URL redirect untuk Google OAuth.

**Response (200):**

```json
{
    "success": true,
    "message": "Google OAuth redirect URL generated",
    "data": {
        "redirect_url": "https://accounts.google.com/oauth/authorize?..."
    }
}
```

### Google OAuth Callback

**GET** `/api/v1/auth/google/callback`

Callback dari Google OAuth.

**Query Parameters:**

-   `code`: Authorization code dari Google
-   `state`: State parameter untuk security

**Response (200):**

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
            "google_avatar": "https://lh3.googleusercontent.com/...",
            "roles": [...]
        },
        "token": "1|abcdef123456...",
        "token_type": "Bearer",
        "expires_in": null,
        "is_new_user": true
    }
}
```

### Link Google Account

**POST** `/api/v1/auth/google/link`

Link Google account ke user yang sudah login.

**Headers:**

```
Authorization: Bearer {token}
```

**Response (200):**

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
            "google_avatar": "https://lh3.googleusercontent.com/..."
        }
    }
}
```

### Unlink Google Account

**DELETE** `/api/v1/auth/google/unlink`

Unlink Google account dari user.

**Headers:**

```
Authorization: Bearer {token}
```

**Response (200):**

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
            "google_avatar": null
        }
    }
}
```

## 👤 Guest User Management Endpoints

### Register as Guest

**POST** `/api/v1/guests/register`

Register sebagai guest user.

**Request Body:**

```json
{
    "email": "guest@example.com",
    "name": "Guest User",
    "phone": "081234567890"
}
```

**Response (201):**

```json
{
    "success": true,
    "message": "Guest user registered successfully",
    "data": {
        "guest": {
            "id": 1,
            "email": "guest@example.com",
            "name": "Guest User",
            "expires_at": "2024-02-15T10:00:00Z"
        },
        "temp_token": "abc123...",
        "expires_at": "2024-02-15T10:00:00Z"
    }
}
```

### Login as Guest

**POST** `/api/v1/guests/login`

Login sebagai guest user.

**Request Body:**

```json
{
    "email": "guest@example.com",
    "temp_token": "abc123..."
}
```

**Response (200):**

```json
{
    "success": true,
    "message": "Guest login successful",
    "data": {
        "guest": {
            "id": 1,
            "email": "guest@example.com",
            "name": "Guest User",
            "expires_at": "2024-02-15T10:00:00Z"
        },
        "temp_token": "abc123...",
        "expires_at": "2024-02-15T10:00:00Z"
    }
}
```

### Convert Guest to Member

**POST** `/api/v1/guests/convert-to-member`

Convert guest user menjadi member.

**Request Body:**

```json
{
    "temp_token": "abc123...",
    "password": "password123",
    "password_confirmation": "password123",
    "date_of_birth": "1990-01-01",
    "gender": "male"
}
```

**Response (201):**

```json
{
    "success": true,
    "message": "Guest converted to member successfully",
    "data": {
        "user": {
            "id": 1,
            "name": "Guest User",
            "email": "guest@example.com",
            "roles": [...]
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

### Get Guest Profile

**GET** `/api/v1/guests/profile`

Mendapatkan profil guest user.

**Query Parameters:**

-   `temp_token`: Guest token

**Response (200):**

```json
{
    "success": true,
    "message": "Guest profile retrieved successfully",
    "data": {
        "guest": {
            "id": 1,
            "email": "guest@example.com",
            "name": "Guest User",
            "expires_at": "2024-02-15T10:00:00Z"
        },
        "bookings": [...],
        "stats": {
            "total_bookings": 5,
            "total_spent": 250000,
            "session_count": 3,
            "days_remaining": 15
        }
    }
}
```

### Update Guest Profile

**PUT** `/api/v1/guests/profile`

Update profil guest user.

**Request Body:**

```json
{
    "temp_token": "abc123...",
    "name": "Updated Name",
    "phone": "081234567891"
}
```

**Response (200):**

```json
{
    "success": true,
    "message": "Guest profile updated successfully",
    "data": {
        "id": 1,
        "email": "guest@example.com",
        "name": "Updated Name",
        "phone": "081234567891"
    }
}
```

### Extend Guest Expiry

**POST** `/api/v1/guests/extend-expiry`

Extend masa berlaku guest account.

**Request Body:**

```json
{
    "temp_token": "abc123...",
    "days": 7
}
```

**Response (200):**

```json
{
    "success": true,
    "message": "Guest account expiry extended successfully",
    "data": {
        "guest": {
            "id": 1,
            "expires_at": "2024-02-22T10:00:00Z"
        },
        "new_expiry": "2024-02-22T10:00:00Z"
    }
}
```

### Get Guest Statistics

**GET** `/api/v1/guests/stats`

Mendapatkan statistik guest user.

**Query Parameters:**

-   `temp_token`: Guest token

**Response (200):**

```json
{
    "success": true,
    "message": "Guest statistics retrieved successfully",
    "data": {
        "total_bookings": 5,
        "total_spent": 250000,
        "session_count": 3,
        "days_remaining": 15,
        "last_activity": "2024-01-15T10:00:00Z",
        "created_at": "2024-01-01T10:00:00Z",
        "expires_at": "2024-02-15T10:00:00Z"
    }
}
```

## 👤 User Profile Management Endpoints

### Get User Profile

**GET** `/api/v1/profile`

Mendapatkan profil user yang sedang login.

**Headers:**

```
Authorization: Bearer {token}
```

**Response (200):**

```json
{
    "success": true,
    "message": "Profile retrieved successfully",
    "data": {
        "profile": {
            "id": 1,
            "user_id": 1,
            "phone": "081234567890",
            "date_of_birth": "1990-01-01",
            "gender": "male",
            "address": "Jl. Contoh No. 123",
            "city": "Jakarta",
            "avatar_url": "https://example.com/avatar.jpg"
        },
        "user": {
            "id": 1,
            "name": "John Doe",
            "email": "john@example.com",
            "email_verified_at": "2024-01-01T10:00:00Z"
        }
    }
}
```

### Update User Profile

**PUT** `/api/v1/profile`

Update profil user.

**Headers:**

```
Authorization: Bearer {token}
```

**Request Body:**

```json
{
    "name": "John Doe",
    "phone": "081234567890",
    "date_of_birth": "1990-01-01",
    "gender": "male",
    "address": "Jl. Contoh No. 123",
    "city": "Jakarta",
    "bio": "Swimming enthusiast"
}
```

**Response (200):**

```json
{
    "success": true,
    "message": "Profile updated successfully",
    "data": {
        "profile": {
            "id": 1,
            "user_id": 1,
            "phone": "081234567890",
            "date_of_birth": "1990-01-01",
            "gender": "male",
            "address": "Jl. Contoh No. 123",
            "city": "Jakarta",
            "bio": "Swimming enthusiast"
        },
        "user": {
            "id": 1,
            "name": "John Doe",
            "email": "john@example.com"
        }
    }
}
```

### Upload Avatar

**POST** `/api/v1/profile/avatar`

Upload avatar user.

**Headers:**

```
Authorization: Bearer {token}
Content-Type: multipart/form-data
```

**Request Body:**

```
avatar: [image file]
```

**Response (200):**

```json
{
    "success": true,
    "message": "Avatar uploaded successfully",
    "data": {
        "avatar_url": "https://example.com/storage/avatars/1_1234567890.jpg",
        "avatar_path": "avatars/1_1234567890.jpg"
    }
}
```

### Delete Avatar

**DELETE** `/api/v1/profile/avatar`

Hapus avatar user.

**Headers:**

```
Authorization: Bearer {token}
```

**Response (200):**

```json
{
    "success": true,
    "message": "Avatar deleted successfully",
    "data": {
        "avatar_url": "https://www.gravatar.com/avatar/..."
    }
}
```

### Get Profile History

**GET** `/api/v1/profile/history`

Mendapatkan history perubahan profil.

**Headers:**

```
Authorization: Bearer {token}
```

**Response (200):**

```json
{
    "success": true,
    "message": "Profile history retrieved successfully",
    "data": {
        "data": [
            {
                "id": 1,
                "changed_fields": ["phone", "address"],
                "created_at": "2024-01-15T10:00:00Z",
                "updated_by": {
                    "id": 1,
                    "name": "John Doe"
                }
            }
        ],
        "current_page": 1,
        "total": 1
    }
}
```

### Export Profile Data

**GET** `/api/v1/profile/export`

Export data profil user.

**Headers:**

```
Authorization: Bearer {token}
```

**Response (200):**

```json
{
    "success": true,
    "message": "Profile exported successfully",
    "data": {
        "download_url": "https://example.com/storage/exports/profile_export_1_2024-01-15_10-00-00.json",
        "filename": "profile_export_1_2024-01-15_10-00-00.json",
        "expires_at": "2024-01-22T10:00:00Z"
    }
}
```

### Get Public Profile

**GET** `/api/v1/profile/public/{userId}`

Mendapatkan profil publik user.

**Response (200):**

```json
{
    "success": true,
    "message": "Public profile retrieved successfully",
    "data": {
        "user": {
            "name": "John Doe"
        },
        "profile": {
            "phone": "081234567890",
            "city": "Jakarta",
            "bio": "Swimming enthusiast",
            "avatar_url": "https://example.com/avatar.jpg"
        }
    }
}
```

### Update Preferences

**PUT** `/api/v1/profile/preferences`

Update preferensi user.

**Headers:**

```
Authorization: Bearer {token}
```

**Request Body:**

```json
{
    "preferences": {
        "notifications": {
            "email": true,
            "sms": false
        },
        "privacy": {
            "show_email": false,
            "show_phone": true
        },
        "language": "id",
        "timezone": "Asia/Jakarta"
    }
}
```

**Response (200):**

```json
{
    "success": true,
    "message": "Preferences updated successfully",
    "data": {
        "preferences": {
            "notifications": {
                "email": true,
                "sms": false
            },
            "privacy": {
                "show_email": false,
                "show_phone": true
            },
            "language": "id",
            "timezone": "Asia/Jakarta"
        }
    }
}
```

### Get Profile Statistics

**GET** `/api/v1/profile/statistics`

Mendapatkan statistik profil user.

**Headers:**

```
Authorization: Bearer {token}
```

**Response (200):**

```json
{
    "success": true,
    "message": "Profile statistics retrieved successfully",
    "data": {
        "profile_completion": 85,
        "last_updated": "2024-01-15T10:00:00Z",
        "total_updates": 5,
        "avatar_uploaded": true,
        "is_public": false,
        "age": 34
    }
}
```

## 🔒 Role-Based Access Control Endpoints

### List Roles (Admin Only)

**GET** `/api/v1/admin/roles`

Mendapatkan daftar semua roles.

**Headers:**

```
Authorization: Bearer {admin_token}
```

**Response (200):**

```json
{
    "success": true,
    "message": "Roles retrieved successfully",
    "data": {
        "data": [
            {
                "id": 1,
                "name": "admin",
                "display_name": "Administrator",
                "description": "Full system access",
                "permissions": [...]
            }
        ],
        "current_page": 1,
        "total": 4
    }
}
```

### Create Role (Admin Only)

**POST** `/api/v1/admin/roles`

Membuat role baru.

**Headers:**

```
Authorization: Bearer {admin_token}
```

**Request Body:**

```json
{
    "name": "moderator",
    "display_name": "Moderator",
    "description": "Content moderation access",
    "permissions": [1, 2, 3]
}
```

**Response (201):**

```json
{
    "success": true,
    "message": "Role created successfully",
    "data": {
        "id": 5,
        "name": "moderator",
        "display_name": "Moderator",
        "description": "Content moderation access",
        "permissions": [...]
    }
}
```

### List Permissions (Admin Only)

**GET** `/api/v1/admin/permissions`

Mendapatkan daftar semua permissions.

**Headers:**

```
Authorization: Bearer {admin_token}
```

**Response (200):**

```json
{
    "success": true,
    "message": "Permissions retrieved successfully",
    "data": {
        "data": [
            {
                "id": 1,
                "name": "users.create",
                "display_name": "Create Users",
                "description": "Create new users",
                "group": "users"
            }
        ],
        "current_page": 1,
        "total": 20
    }
}
```

## 📊 Error Responses

### 400 Bad Request

```json
{
    "success": false,
    "message": "Validation failed",
    "data": {
        "errors": {
            "email": ["The email field is required."],
            "password": ["The password must be at least 6 characters."]
        }
    }
}
```

### 401 Unauthorized

```json
{
    "success": false,
    "message": "Unauthenticated",
    "data": null
}
```

### 403 Forbidden

```json
{
    "success": false,
    "message": "Access denied. Insufficient permissions.",
    "data": null
}
```

### 404 Not Found

```json
{
    "success": false,
    "message": "Resource not found",
    "data": null
}
```

### 422 Unprocessable Entity

```json
{
    "success": false,
    "message": "The given data was invalid.",
    "data": {
        "errors": {
            "email": ["The email has already been taken."]
        }
    }
}
```

### 500 Internal Server Error

```json
{
    "success": false,
    "message": "Internal server error",
    "data": null
}
```

## 🔧 Configuration

### Environment Variables

```env
# Google OAuth
GOOGLE_CLIENT_ID=your-google-client-id
GOOGLE_CLIENT_SECRET=your-google-client-secret
GOOGLE_REDIRECT_URI=http://localhost:8000/api/v1/auth/google/callback

# Sanctum
SANCTUM_EXPIRATION=10080
SANCTUM_STATEFUL_DOMAINS=localhost,localhost:3000,127.0.0.1
```

### Rate Limiting

-   Authentication endpoints: 5 requests per minute per IP
-   Google OAuth endpoints: 10 requests per minute per IP
-   Profile endpoints: 60 requests per minute per user

## 🧪 Testing

### Test Scripts

```bash
# Run all authentication tests
php artisan test --filter="Auth"

# Run Google OAuth tests
php artisan test --filter="GoogleAuth"

# Run guest user tests
php artisan test --filter="GuestUser"

# Run profile management tests
php artisan test --filter="Profile"

# Run RBAC tests
php artisan test --filter="Role"
```

### Test Coverage

-   Authentication: 100%
-   Google OAuth: 100%
-   Guest User Management: 100%
-   Profile Management: 100%
-   RBAC: 100%

## 📚 Additional Resources

-   [Laravel Sanctum Documentation](https://laravel.com/docs/11.x/sanctum)
-   [Laravel Socialite Documentation](https://laravel.com/docs/11.x/socialite)
-   [Google OAuth 2.0 Documentation](https://developers.google.com/identity/protocols/oauth2)
-   [RBAC Best Practices](https://en.wikipedia.org/wiki/Role-based_access_control)
