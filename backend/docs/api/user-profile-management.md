# User Profile Management API

## 📋 Overview

API untuk manajemen profil user dengan fitur CRUD operations, validasi, upload gambar, tracking history, dan export data.

## 🔐 Authentication

Semua endpoint profile management memerlukan authentication menggunakan Bearer token, kecuali endpoint public profile.

```http
Authorization: Bearer {token}
```

## 📚 Endpoints

### 1. Get User Profile

Mengambil profil user yang sedang login.

```http
GET /api/v1/profile
```

**Response:**
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
            "postal_code": "12345",
            "country": "Indonesia",
            "emergency_contact_name": "Jane Doe",
            "emergency_contact_phone": "081234567891",
            "emergency_contact_relationship": "spouse",
            "medical_conditions": null,
            "allergies": null,
            "preferred_language": "en",
            "timezone": "UTC",
            "avatar_path": "avatars/1_1234567890.jpg",
            "avatar_url": "http://localhost/storage/avatars/1_1234567890.jpg",
            "bio": "Swimming enthusiast",
            "occupation": "Software Developer",
            "company": "Tech Corp",
            "website": "https://example.com",
            "social_media": {
                "facebook": "https://facebook.com/johndoe",
                "linkedin": "https://linkedin.com/in/johndoe"
            },
            "preferences": {
                "notifications": {
                    "email": true,
                    "sms": false,
                    "push": true
                },
                "privacy": {
                    "profile_visibility": "public",
                    "show_email": false,
                    "show_phone": true
                }
            },
            "is_public": true,
            "last_updated_at": "2024-01-15T10:30:00.000000Z",
            "created_at": "2024-01-01T00:00:00.000000Z",
            "updated_at": "2024-01-15T10:30:00.000000Z"
        },
        "user": {
            "id": 1,
            "name": "John Doe",
            "email": "john@example.com",
            "email_verified_at": "2024-01-01T00:00:00.000000Z"
        }
    }
}
```

### 2. Update User Profile

Mengupdate profil user yang sedang login.

```http
PUT /api/v1/profile
```

**Request Body:**
```json
{
    "name": "John Doe Updated",
    "phone": "081234567890",
    "date_of_birth": "1990-01-01",
    "gender": "male",
    "address": "Jl. Contoh No. 123",
    "city": "Jakarta",
    "postal_code": "12345",
    "country": "Indonesia",
    "emergency_contact_name": "Jane Doe",
    "emergency_contact_phone": "081234567891",
    "emergency_contact_relationship": "spouse",
    "medical_conditions": "None",
    "allergies": "Peanuts",
    "preferred_language": "id",
    "timezone": "Asia/Jakarta",
    "bio": "Updated bio",
    "occupation": "Senior Software Developer",
    "company": "Tech Corp",
    "website": "https://johndoe.com",
    "social_media": {
        "facebook": "https://facebook.com/johndoe",
        "twitter": "https://twitter.com/johndoe",
        "instagram": "https://instagram.com/johndoe",
        "linkedin": "https://linkedin.com/in/johndoe"
    },
    "is_public": true
}
```

**Response:**
```json
{
    "success": true,
    "message": "Profile updated successfully",
    "data": {
        "profile": {
            // Updated profile data
        },
        "user": {
            "id": 1,
            "name": "John Doe Updated",
            "email": "john@example.com"
        }
    }
}
```

### 3. Upload Avatar

Upload gambar avatar untuk profil user.

```http
POST /api/v1/profile/avatar
Content-Type: multipart/form-data
```

**Request Body:**
```
avatar: [image file]
```

**Validation Rules:**
- `avatar`: required, image, mimes:jpeg,png,jpg,gif, max:2048KB, dimensions:100x100-2000x2000

**Response:**
```json
{
    "success": true,
    "message": "Avatar uploaded successfully",
    "data": {
        "avatar_url": "http://localhost/storage/avatars/1_1234567890.jpg",
        "avatar_path": "avatars/1_1234567890.jpg"
    }
}
```

### 4. Delete Avatar

Menghapus avatar dari profil user.

```http
DELETE /api/v1/profile/avatar
```

**Response:**
```json
{
    "success": true,
    "message": "Avatar deleted successfully",
    "data": {
        "avatar_url": "https://www.gravatar.com/avatar/0d078fcfb225a9d27a025231adeef3c4?d=identicon&s=200"
    }
}
```

### 5. Get Profile History

Mengambil riwayat perubahan profil user.

```http
GET /api/v1/profile/history
```

**Query Parameters:**
- `page`: Halaman (default: 1)
- `per_page`: Jumlah item per halaman (default: 20)

**Response:**
```json
{
    "success": true,
    "message": "Profile history retrieved successfully",
    "data": {
        "current_page": 1,
        "data": [
            {
                "id": 1,
                "user_profile_id": 1,
                "old_data": {
                    "phone": "081234567890",
                    "bio": "Old bio"
                },
                "new_data": {
                    "phone": "081234567891",
                    "bio": "New bio"
                },
                "changed_fields": ["phone", "bio"],
                "updated_by": 1,
                "change_reason": null,
                "created_at": "2024-01-15T10:30:00.000000Z",
                "updated_at": "2024-01-15T10:30:00.000000Z",
                "updated_by_user": {
                    "id": 1,
                    "name": "John Doe"
                }
            }
        ],
        "first_page_url": "http://localhost/api/v1/profile/history?page=1",
        "from": 1,
        "last_page": 1,
        "last_page_url": "http://localhost/api/v1/profile/history?page=1",
        "links": [...],
        "next_page_url": null,
        "path": "http://localhost/api/v1/profile/history",
        "per_page": 20,
        "prev_page_url": null,
        "to": 1,
        "total": 1
    }
}
```

### 6. Export Profile Data

Export data profil user dalam format JSON.

```http
GET /api/v1/profile/export
```

**Response:**
```json
{
    "success": true,
    "message": "Profile exported successfully",
    "data": {
        "download_url": "http://localhost/storage/exports/profile_export_1_2024-01-15_10-30-00.json",
        "filename": "profile_export_1_2024-01-15_10-30-00.json",
        "expires_at": "2024-01-22T10:30:00.000000Z"
    }
}
```

### 7. Get Public Profile

Mengambil profil publik user berdasarkan ID (tidak memerlukan authentication).

```http
GET /api/v1/profile/public/{userId}
```

**Response:**
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
            "date_of_birth": "1990-01-01",
            "gender": "male",
            "city": "Jakarta",
            "country": "Indonesia",
            "bio": "Swimming enthusiast",
            "occupation": "Software Developer",
            "company": "Tech Corp",
            "website": "https://example.com",
            "social_media": {
                "facebook": "https://facebook.com/johndoe",
                "linkedin": "https://linkedin.com/in/johndoe"
            },
            "avatar_url": "http://localhost/storage/avatars/1_1234567890.jpg"
        }
    }
}
```

### 8. Update Preferences

Mengupdate preferensi user.

```http
PUT /api/v1/profile/preferences
```

**Request Body:**
```json
{
    "preferences": {
        "notifications": {
            "email": true,
            "sms": false,
            "push": true
        },
        "privacy": {
            "profile_visibility": "public",
            "show_email": false,
            "show_phone": true
        },
        "language": "id",
        "timezone": "Asia/Jakarta"
    }
}
```

**Response:**
```json
{
    "success": true,
    "message": "Preferences updated successfully",
    "data": {
        "preferences": {
            "notifications": {
                "email": true,
                "sms": false,
                "push": true
            },
            "privacy": {
                "profile_visibility": "public",
                "show_email": false,
                "show_phone": true
            },
            "language": "id",
            "timezone": "Asia/Jakarta"
        }
    }
}
```

### 9. Get Profile Statistics

Mengambil statistik profil user.

```http
GET /api/v1/profile/statistics
```

**Response:**
```json
{
    "success": true,
    "message": "Profile statistics retrieved successfully",
    "data": {
        "profile_completion": 100,
        "last_updated": "2024-01-15T10:30:00.000000Z",
        "total_updates": 5,
        "avatar_uploaded": true,
        "is_public": true,
        "age": 34
    }
}
```

## 🔍 Validation Rules

### Profile Update Validation

| Field | Rules |
|-------|-------|
| `name` | sometimes, string, max:255 |
| `phone` | sometimes, string, max:20 |
| `date_of_birth` | sometimes, date, before:today |
| `gender` | sometimes, in:male,female |
| `address` | sometimes, string, max:500 |
| `city` | sometimes, string, max:100 |
| `postal_code` | sometimes, string, max:20 |
| `country` | sometimes, string, max:100 |
| `emergency_contact_name` | sometimes, string, max:255 |
| `emergency_contact_phone` | sometimes, string, max:20 |
| `emergency_contact_relationship` | sometimes, string, max:100 |
| `medical_conditions` | sometimes, string, max:1000 |
| `allergies` | sometimes, string, max:1000 |
| `preferred_language` | sometimes, string, in:en,id |
| `timezone` | sometimes, string, max:50 |
| `bio` | sometimes, string, max:1000 |
| `occupation` | sometimes, string, max:100 |
| `company` | sometimes, string, max:100 |
| `website` | sometimes, url, max:255 |
| `social_media` | sometimes, array |
| `social_media.facebook` | sometimes, url |
| `social_media.twitter` | sometimes, url |
| `social_media.instagram` | sometimes, url |
| `social_media.linkedin` | sometimes, url |
| `is_public` | sometimes, boolean |

### Avatar Upload Validation

| Field | Rules |
|-------|-------|
| `avatar` | required, image, mimes:jpeg,png,jpg,gif, max:2048, dimensions:100x100-2000x2000 |

## ❌ Error Responses

### 400 Bad Request
```json
{
    "success": false,
    "message": "Validation failed",
    "data": {
        "errors": {
            "phone": ["The phone field is required."],
            "gender": ["The selected gender is invalid."]
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

### 404 Not Found
```json
{
    "success": false,
    "message": "No avatar to delete",
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
            "avatar": [
                "The avatar must be an image.",
                "The avatar must not be greater than 2048 kilobytes."
            ]
        }
    }
}
```

## 🔧 Features

### Profile History Tracking
- Setiap perubahan profil otomatis dicatat dalam `user_profile_histories`
- Menyimpan data lama, data baru, dan field yang berubah
- Mencatat user yang melakukan perubahan

### Avatar Management
- Upload avatar dengan validasi ukuran dan format
- Otomatis menghapus avatar lama saat upload yang baru
- Fallback ke Gravatar jika tidak ada avatar

### Profile Export
- Export data profil dalam format JSON
- File export disimpan di storage dengan expiry 7 hari
- Filename unik berdasarkan user ID dan timestamp

### Public Profile
- User dapat membuat profil mereka publik
- Endpoint khusus untuk mengakses profil publik tanpa authentication
- Hanya menampilkan data yang aman untuk publik

### Profile Statistics
- Menghitung persentase kelengkapan profil
- Menampilkan jumlah update yang dilakukan
- Status avatar dan visibility

## 🧪 Testing

Untuk menjalankan tests profile management:

```bash
# Feature tests
php artisan test --filter=ProfileManagementTest

# Unit tests
php artisan test --filter=UserProfileTest
php artisan test --filter=UserProfileHistoryTest

# All profile tests
php artisan test --filter=Profile
```

## 📝 Notes

- Profile otomatis dibuat saat pertama kali diakses jika belum ada
- Data dari User model (phone, date_of_birth, dll) akan di-copy ke profile saat pertama kali dibuat
- Avatar lama otomatis dihapus saat upload avatar baru
- Profile history tidak dapat dihapus untuk audit trail
- Export file akan expired setelah 7 hari
