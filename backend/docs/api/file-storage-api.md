# File Storage API Documentation

## Overview

Sistem file storage menggunakan Laravel Storage dengan disk khusus untuk setiap tipe file. Dokumentasi ini mencakup semua endpoint dan cara kerja file storage.

## Storage Disks

### Available Disks

| Disk | Purpose | Path | Visibility |
|------|---------|------|------------|
| `avatars` | User profile pictures | `storage/app/public/avatars/` | Public |
| `payment-proofs` | Payment verification documents | `storage/app/public/payment-proofs/` | Public |
| `menu-images` | Menu item images | `storage/app/public/menu-images/` | Public |
| `barcodes` | QR codes and barcode images | `storage/app/public/barcodes/` | Public |
| `exports` | Exported data files | `storage/app/public/exports/` | Public |
| `documents` | Private documents | `storage/app/documents/` | Private |

### Configuration

```php
// config/filesystems.php
'disks' => [
    'avatars' => [
        'driver' => 'local',
        'root' => storage_path('app/public/avatars'),
        'url' => env('APP_URL').'/storage/avatars',
        'visibility' => 'public',
        'throw' => false,
    ],
    'payment-proofs' => [
        'driver' => 'local',
        'root' => storage_path('app/public/payment-proofs'),
        'url' => env('APP_URL').'/storage/payment-proofs',
        'visibility' => 'public',
        'throw' => false,
    ],
    // ... other disks
],
```

## File Upload Endpoints

### Upload Avatar

Upload gambar avatar untuk profil user.

**Endpoint:** `POST /api/v1/profile/avatar`

**Headers:**
```
Authorization: Bearer {token}
Content-Type: multipart/form-data
```

**Request Body:**
```
avatar: [image file]
```

**Validation Rules:**
- Format: JPEG, PNG, JPG, GIF
- Size: Max 2MB
- Dimensions: 100x100 to 2000x2000 pixels

**Response:**
```json
{
    "success": true,
    "message": "Avatar uploaded successfully",
    "data": {
        "avatar_url": "http://localhost/storage/avatars/1_1234567890_abc123.jpg",
        "avatar_path": "1_1234567890_abc123.jpg"
    }
}
```

**Example Usage:**
```javascript
const formData = new FormData();
formData.append('avatar', fileInput.files[0]);

fetch('/api/v1/profile/avatar', {
    method: 'POST',
    headers: {
        'Authorization': `Bearer ${token}`
    },
    body: formData
})
.then(response => response.json())
.then(data => {
    console.log('Avatar uploaded:', data.data.avatar_url);
});
```

### Delete Avatar

Menghapus avatar dari profil user.

**Endpoint:** `DELETE /api/v1/profile/avatar`

**Headers:**
```
Authorization: Bearer {token}
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

### Upload Payment Proof

Upload bukti pembayaran untuk verifikasi.

**Endpoint:** `POST /api/v1/payments/{id}/proof`

**Headers:**
```
Authorization: Bearer {token}
Content-Type: multipart/form-data
```

**Request Body:**
```
payment_proof: [file]
```

**Validation Rules:**
- Format: JPEG, PNG, JPG, PDF
- Size: Max 5MB

**Response:**
```json
{
    "success": true,
    "message": "Payment proof uploaded successfully",
    "data": {
        "payment_proof_url": "http://localhost/storage/payment-proofs/payment_1_1234567890_def456.pdf",
        "payment_proof_path": "payment_1_1234567890_def456.pdf"
    }
}
```

### Upload Menu Image

Upload gambar untuk menu item (Admin only).

**Endpoint:** `POST /api/v1/admin/menu/{id}/image`

**Headers:**
```
Authorization: Bearer {admin_token}
Content-Type: multipart/form-data
```

**Request Body:**
```
image: [image file]
```

**Validation Rules:**
- Format: JPEG, PNG, JPG, WebP
- Size: Max 2MB
- Dimensions: 300x300 to 2000x2000 pixels

**Response:**
```json
{
    "success": true,
    "message": "Menu image uploaded successfully",
    "data": {
        "image_url": "http://localhost/storage/menu-images/menu_1_1234567890_ghi789.jpg",
        "image_path": "menu_1_1234567890_ghi789.jpg"
    }
}
```

### Generate QR Code

Generate QR code untuk menu item (Admin only).

**Endpoint:** `POST /api/v1/admin/barcodes/generate`

**Headers:**
```
Authorization: Bearer {admin_token}
Content-Type: application/json
```

**Request Body:**
```json
{
    "menu_item_id": 1,
    "barcode_type": "QR"
}
```

**Response:**
```json
{
    "success": true,
    "message": "QR code generated successfully",
    "data": {
        "qr_code_path": "qr-codes/qr_QR000001_menu-item.png",
        "qr_code_url": "http://localhost/storage/barcodes/qr-codes/qr_QR000001_menu-item.png",
        "barcode_value": "QR000001"
    }
}
```

### Download QR Code

Download QR code image (Admin only).

**Endpoint:** `GET /api/v1/admin/barcodes/{id}/download`

**Headers:**
```
Authorization: Bearer {admin_token}
```

**Response:** File download (PNG image)

### Export User Profile

Export data profil user.

**Endpoint:** `POST /api/v1/profile/export`

**Headers:**
```
Authorization: Bearer {token}
```

**Response:**
```json
{
    "success": true,
    "message": "Profile data exported successfully",
    "data": {
        "download_url": "http://localhost/storage/exports/profile_export_1_1234567890.json",
        "filename": "profile_export_1_1234567890.json",
        "expires_at": "2024-01-26T12:00:00Z"
    }
}
```

## File Access

### Public File Access

File yang disimpan di disk public dapat diakses langsung melalui URL:

```
http://localhost/storage/avatars/filename.jpg
http://localhost/storage/payment-proofs/filename.pdf
http://localhost/storage/menu-images/filename.jpg
http://localhost/storage/barcodes/qr-codes/filename.png
http://localhost/storage/exports/filename.json
```

### Private File Access

File private diakses melalui API endpoint:

**Endpoint:** `GET /api/v1/documents/{filename}`

**Headers:**
```
Authorization: Bearer {token}
```

**Response:** File download

## Error Responses

### 400 Bad Request

```json
{
    "success": false,
    "message": "Invalid file format",
    "errors": {
        "avatar": ["The avatar must be an image."]
    }
}
```

### 413 Payload Too Large

```json
{
    "success": false,
    "message": "File too large",
    "errors": {
        "avatar": ["The avatar must not be greater than 2048 kilobytes."]
    }
}
```

### 422 Validation Error

```json
{
    "success": false,
    "message": "Validation failed",
    "errors": {
        "image": [
            "The image must be at least 300 pixels wide.",
            "The image must be at least 300 pixels tall."
        ]
    }
}
```

### 403 Forbidden

```json
{
    "success": false,
    "message": "Access denied. Admin role required."
}
```

### 404 Not Found

```json
{
    "success": false,
    "message": "File not found"
}
```

## File Management

### File Naming Convention

Files menggunakan naming convention yang konsisten:

- **Avatars**: `{user_id}_{timestamp}_{random}.{extension}`
- **Payment Proofs**: `payment_{payment_id}_{timestamp}_{random}.{extension}`
- **Menu Images**: `menu_{menu_id}_{timestamp}_{random}.{extension}`
- **QR Codes**: `qr_{barcode_value}_menu-item.png`
- **Exports**: `{type}_export_{user_id}_{timestamp}.{extension}`

### File Cleanup

Sistem otomatis membersihkan file lama:

- **Export files**: Dihapus setelah 24 jam
- **Temporary files**: Dihapus setelah 1 jam
- **Old avatars**: Dihapus saat upload avatar baru

### File Security

- **Validation**: Strict file type dan size validation
- **Path sanitization**: Secure file path generation
- **Access control**: Role-based file access
- **Virus scanning**: File scanning sebelum storage (optional)

## Performance Considerations

### File Compression

Images otomatis di-compress:

```php
// Automatic image compression
$image = Image::make($file);
$image->resize(800, 600, function ($constraint) {
    $constraint->aspectRatio();
    $constraint->upsize();
});
$image->encode('jpg', 80); // 80% quality
```

### Caching

File URLs di-cache untuk performa:

```php
// Cache file URLs
$cacheKey = "file_url_{$filePath}";
return Cache::remember($cacheKey, 3600, function () use ($filePath) {
    return Storage::disk('avatars')->url($filePath);
});
```

### CDN Integration

Siap untuk integrasi CDN:

```php
// CDN URL generation
$cdnUrl = config('app.cdn_url');
return $cdnUrl . '/storage/avatars/' . $filename;
```

## Frontend Integration Examples

### React Component

```jsx
import React, { useState } from 'react';

const AvatarUpload = () => {
    const [uploading, setUploading] = useState(false);
    const [avatarUrl, setAvatarUrl] = useState('');

    const handleFileUpload = async (event) => {
        const file = event.target.files[0];
        if (!file) return;

        setUploading(true);
        const formData = new FormData();
        formData.append('avatar', file);

        try {
            const response = await fetch('/api/v1/profile/avatar', {
                method: 'POST',
                headers: {
                    'Authorization': `Bearer ${localStorage.getItem('token')}`
                },
                body: formData
            });

            const data = await response.json();
            if (data.success) {
                setAvatarUrl(data.data.avatar_url);
            }
        } catch (error) {
            console.error('Upload failed:', error);
        } finally {
            setUploading(false);
        }
    };

    return (
        <div>
            <input
                type="file"
                accept="image/*"
                onChange={handleFileUpload}
                disabled={uploading}
            />
            {uploading && <p>Uploading...</p>}
            {avatarUrl && (
                <img
                    src={avatarUrl}
                    alt="Avatar"
                    style={{ width: 100, height: 100 }}
                />
            )}
        </div>
    );
};

export default AvatarUpload;
```

### Vue.js Component

```vue
<template>
    <div>
        <input
            type="file"
            accept="image/*"
            @change="handleFileUpload"
            :disabled="uploading"
        />
        <div v-if="uploading">Uploading...</div>
        <img
            v-if="avatarUrl"
            :src="avatarUrl"
            alt="Avatar"
            style="width: 100px; height: 100px"
        />
    </div>
</template>

<script setup>
import { ref } from 'vue';

const uploading = ref(false);
const avatarUrl = ref('');

const handleFileUpload = async (event) => {
    const file = event.target.files[0];
    if (!file) return;

    uploading.value = true;
    const formData = new FormData();
    formData.append('avatar', file);

    try {
        const response = await fetch('/api/v1/profile/avatar', {
            method: 'POST',
            headers: {
                'Authorization': `Bearer ${localStorage.getItem('token')}`
            },
            body: formData
        });

        const data = await response.json();
        if (data.success) {
            avatarUrl.value = data.data.avatar_url;
        }
    } catch (error) {
        console.error('Upload failed:', error);
    } finally {
        uploading.value = false;
    }
};
</script>
```

### JavaScript Vanilla

```javascript
class FileUploader {
    constructor(token) {
        this.token = token;
    }

    async uploadAvatar(file) {
        const formData = new FormData();
        formData.append('avatar', file);

        const response = await fetch('/api/v1/profile/avatar', {
            method: 'POST',
            headers: {
                'Authorization': `Bearer ${this.token}`
            },
            body: formData
        });

        return response.json();
    }

    async uploadPaymentProof(paymentId, file) {
        const formData = new FormData();
        formData.append('payment_proof', file);

        const response = await fetch(`/api/v1/payments/${paymentId}/proof`, {
            method: 'POST',
            headers: {
                'Authorization': `Bearer ${this.token}`
            },
            body: formData
        });

        return response.json();
    }
}

// Usage
const uploader = new FileUploader(localStorage.getItem('token'));

document.getElementById('avatar-input').addEventListener('change', async (e) => {
    const file = e.target.files[0];
    if (file) {
        const result = await uploader.uploadAvatar(file);
        if (result.success) {
            document.getElementById('avatar-img').src = result.data.avatar_url;
        }
    }
});
```

## Testing

### Unit Tests

```php
<?php

namespace Tests\Unit\Services;

use Tests\TestCase;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\Storage;
use App\Services\UserProfileService;

class FileStorageTest extends TestCase
{
    protected function setUp(): void
    {
        parent::setUp();
        Storage::fake('avatars');
    }

    /** @test */
    public function it_can_upload_user_avatar()
    {
        $file = UploadedFile::fake()->image('avatar.jpg', 100, 100);
        $service = new UserProfileService();
        
        $result = $service->uploadAvatar(1, $file);
        
        $this->assertArrayHasKey('avatar_url', $result);
        $this->assertArrayHasKey('avatar_path', $result);
        
        Storage::disk('avatars')->assertExists($result['avatar_path']);
    }
}
```

### Feature Tests

```php
<?php

namespace Tests\Feature\Api;

use Tests\TestCase;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\Storage;
use App\Models\User;
use Laravel\Sanctum\Sanctum;

class FileUploadTest extends TestCase
{
    protected function setUp(): void
    {
        parent::setUp();
        Storage::fake('avatars');
    }

    /** @test */
    public function user_can_upload_avatar()
    {
        $user = User::factory()->create();
        Sanctum::actingAs($user);

        $file = UploadedFile::fake()->image('avatar.jpg', 100, 100);

        $response = $this->postJson('/api/v1/profile/avatar', [
            'avatar' => $file
        ]);

        $response->assertStatus(200)
                ->assertJsonStructure([
                    'success',
                    'message',
                    'data' => [
                        'avatar_url',
                        'avatar_path'
                    ]
                ]);
    }
}
```

## Monitoring and Maintenance

### Storage Monitoring

```bash
# Check storage usage
du -sh storage/app/public/*

# Check file counts
find storage/app/public -type f | wc -l

# Check disk space
df -h storage/app/public
```

### Cleanup Script

```php
<?php

namespace App\Console\Commands;

use Illuminate\Console\Command;
use Illuminate\Support\Facades\Storage;
use Carbon\Carbon;

class CleanupOldFiles extends Command
{
    protected $signature = 'storage:cleanup';
    protected $description = 'Clean up old files from storage';

    public function handle()
    {
        // Clean up export files older than 24 hours
        $exportFiles = Storage::disk('exports')->files();
        foreach ($exportFiles as $file) {
            $lastModified = Storage::disk('exports')->lastModified($file);
            if (Carbon::createFromTimestamp($lastModified)->isBefore(now()->subHours(24))) {
                Storage::disk('exports')->delete($file);
                $this->info("Deleted old export file: {$file}");
            }
        }

        $this->info('File cleanup completed');
    }
}
```

## Security Best Practices

1. **File Validation**: Always validate file type, size, and content
2. **Path Sanitization**: Prevent directory traversal attacks
3. **Access Control**: Implement proper authorization
4. **Virus Scanning**: Scan files before storage
5. **Secure URLs**: Use signed URLs for sensitive files
6. **Backup Strategy**: Regular backups of important files

## Troubleshooting

### Common Issues

1. **Storage Link Not Working**
   ```bash
   php artisan storage:link
   ```

2. **Permission Issues**
   ```bash
   chmod -R 755 storage/app/public
   ```

3. **File Not Found**
   - Check file path
   - Verify storage link
   - Check file permissions

4. **Upload Fails**
   - Check file size limits
   - Verify file format
   - Check disk space

---

**Last Updated**: January 26, 2025  
**Version**: 1.0.0  
**Status**: Production Ready ✅
