# Planning Refactor: S3 ke Laravel Storage

## 📋 Overview

Dokumen ini berisi planning refactor untuk mengubah sistem file storage dari AWS S3 ke Laravel Storage lokal pada backend yang sudah selesai.

## 🔍 Analisis Backend yang Sudah Ada

### **File Storage yang Ditemukan:**

1. **Profile Avatar Management** (`phase-2/05-user-profile-management.md`)
   - Upload avatar user
   - Delete avatar lama
   - Path: `avatars/`
   - Menggunakan `Storage::disk('public')`

2. **Payment Proof Upload** (`phase-4/01-manual-payment-system.md`)
   - Upload bukti pembayaran
   - Delete payment proof
   - Path: `payment-proofs/`
   - Menggunakan `Storage::disk('public')`

3. **User Profile Export** (`phase-2/05-user-profile-management.md`)
   - Export data profil user
   - Path: `exports/`
   - Menggunakan `Storage::disk('public')`

4. **Menu Image Upload** (`docs/api/menu-management-api.md`)
   - Upload gambar menu
   - Path: `menu-images/`
   - Referensi di dokumentasi API

5. **Barcode QR Code Generation** (`docs/api/barcode-system.md`)
   - Generate QR code untuk menu
   - Path: `barcodes/qr-codes/`
   - File storage untuk QR code images

### **Konfigurasi yang Ditemukan:**

- **Environment**: `FILESYSTEM_DISK=local` (sudah benar)
- **Performance Config**: Ada referensi S3 di `docs/api/performance.md`
- **Deployment Guide**: Sudah menggunakan `FILESYSTEM_DISK=local`

## 🎯 Refactor Strategy

### **Phase 1: Code Refactor (Week 1)**

#### **1.1 Update Storage Configuration**

**File**: `config/filesystems.php`

```php
<?php

return [
    'default' => env('FILESYSTEM_DISK', 'local'),

    'disks' => [
        'local' => [
            'driver' => 'local',
            'root' => storage_path('app'),
            'throw' => false,
        ],

        'public' => [
            'driver' => 'local',
            'root' => storage_path('app/public'),
            'url' => env('APP_URL').'/storage',
            'visibility' => 'public',
            'throw' => false,
        ],

        // Specialized storage disks
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

        'menu-images' => [
            'driver' => 'local',
            'root' => storage_path('app/public/menu-images'),
            'url' => env('APP_URL').'/storage/menu-images',
            'visibility' => 'public',
            'throw' => false,
        ],

        'barcodes' => [
            'driver' => 'local',
            'root' => storage_path('app/public/barcodes'),
            'url' => env('APP_URL').'/storage/barcodes',
            'visibility' => 'public',
            'throw' => false,
        ],

        'exports' => [
            'driver' => 'local',
            'root' => storage_path('app/public/exports'),
            'url' => env('APP_URL').'/storage/exports',
            'visibility' => 'public',
            'throw' => false,
        ],

        'documents' => [
            'driver' => 'local',
            'root' => storage_path('app/documents'),
            'visibility' => 'private',
            'throw' => false,
        ],
    ],

    'links' => [
        public_path('storage') => storage_path('app/public'),
    ],
];
```

#### **1.2 Update User Profile Management**

**File**: `app/Services/UserProfileService.php`

```php
<?php

namespace App\Services;

use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Str;

class UserProfileService
{
    /**
     * Upload user avatar
     */
    public function uploadAvatar(int $userId, UploadedFile $file): array
    {
        // Validate file
        $this->validateAvatarFile($file);
        
        // Delete old avatar if exists
        $this->deleteOldAvatar($userId);
        
        // Generate unique filename
        $filename = $userId . '_' . time() . '_' . Str::random(10) . '.' . $file->getClientOriginalExtension();
        
        // Store file using specialized disk
        $path = $file->storeAs('', $filename, 'avatars');
        
        // Update user profile
        $profile = $this->updateProfileAvatar($userId, $path);
        
        return [
            'avatar_url' => Storage::disk('avatars')->url($filename),
            'avatar_path' => $path,
            'profile' => $profile
        ];
    }

    /**
     * Delete user avatar
     */
    public function deleteAvatar(int $userId): bool
    {
        $profile = $this->getUserProfile($userId);
        
        if ($profile && $profile->avatar_path) {
            // Delete file from storage
            Storage::disk('avatars')->delete($profile->avatar_path);
            
            // Update profile
            $this->updateProfileAvatar($userId, null);
            
            return true;
        }
        
        return false;
    }

    /**
     * Export user profile data
     */
    public function exportProfileData(int $userId): array
    {
        $profile = $this->getUserProfile($userId);
        $exportData = $this->formatExportData($profile);
        
        // Generate filename
        $filename = 'profile_export_' . $userId . '_' . time() . '.json';
        
        // Store export file
        $path = $filename;
        Storage::disk('exports')->put($path, json_encode($exportData, JSON_PRETTY_PRINT));
        
        return [
            'download_url' => Storage::disk('exports')->url($path),
            'filename' => $filename,
            'expires_at' => now()->addHours(24)
        ];
    }

    private function validateAvatarFile(UploadedFile $file): void
    {
        $file->validate([
            'avatar' => [
                'required',
                'image',
                'mimes:jpeg,png,jpg,gif',
                'max:2048',
                'dimensions:min_width=100,min_height=100,max_width=2000,max_height=2000'
            ]
        ]);
    }

    private function deleteOldAvatar(int $userId): void
    {
        $profile = $this->getUserProfile($userId);
        if ($profile && $profile->avatar_path) {
            Storage::disk('avatars')->delete($profile->avatar_path);
        }
    }

    private function updateProfileAvatar(int $userId, ?string $path): object
    {
        return UserProfile::where('user_id', $userId)->update([
            'avatar_path' => $path,
            'updated_at' => now()
        ]);
    }
}
```

#### **1.3 Update Payment System**

**File**: `app/Services/PaymentService.php`

```php
<?php

namespace App\Services;

use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Str;

class PaymentService
{
    /**
     * Upload payment proof
     */
    public function uploadPaymentProof(int $paymentId, UploadedFile $file): array
    {
        // Validate file
        $this->validatePaymentProofFile($file);
        
        // Delete old proof if exists
        $this->deleteOldPaymentProof($paymentId);
        
        // Generate unique filename
        $filename = 'payment_' . $paymentId . '_' . time() . '_' . Str::random(10) . '.' . $file->getClientOriginalExtension();
        
        // Store file using specialized disk
        $path = $file->storeAs('', $filename, 'payment-proofs');
        
        // Update payment record
        $payment = $this->updatePaymentProof($paymentId, $path);
        
        return [
            'payment_proof_url' => Storage::disk('payment-proofs')->url($filename),
            'payment_proof_path' => $path,
            'payment' => $payment
        ];
    }

    /**
     * Delete payment proof
     */
    public function deletePaymentProof(int $paymentId): bool
    {
        $payment = $this->getPayment($paymentId);
        
        if ($payment && $payment->payment_proof_path) {
            // Delete file from storage
            Storage::disk('payment-proofs')->delete($payment->payment_proof_path);
            
            // Update payment record
            $this->updatePaymentProof($paymentId, null);
            
            return true;
        }
        
        return false;
    }

    private function validatePaymentProofFile(UploadedFile $file): void
    {
        $file->validate([
            'payment_proof' => [
                'required',
                'file',
                'mimes:jpeg,png,jpg,pdf',
                'max:5120' // 5MB
            ]
        ]);
    }

    private function deleteOldPaymentProof(int $paymentId): void
    {
        $payment = $this->getPayment($paymentId);
        if ($payment && $payment->payment_proof_path) {
            Storage::disk('payment-proofs')->delete($payment->payment_proof_path);
        }
    }

    private function updatePaymentProof(int $paymentId, ?string $path): object
    {
        return Payment::where('id', $paymentId)->update([
            'payment_proof_path' => $path,
            'updated_at' => now()
        ]);
    }
}
```

#### **1.4 Update Menu Management**

**File**: `app/Services/MenuService.php`

```php
<?php

namespace App\Services;

use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Str;

class MenuService
{
    /**
     * Upload menu image
     */
    public function uploadMenuImage(int $menuItemId, UploadedFile $file): array
    {
        // Validate file
        $this->validateMenuImageFile($file);
        
        // Delete old image if exists
        $this->deleteOldMenuImage($menuItemId);
        
        // Generate unique filename
        $filename = 'menu_' . $menuItemId . '_' . time() . '_' . Str::random(10) . '.' . $file->getClientOriginalExtension();
        
        // Store file using specialized disk
        $path = $file->storeAs('', $filename, 'menu-images');
        
        // Update menu item
        $menuItem = $this->updateMenuImage($menuItemId, $path);
        
        return [
            'image_url' => Storage::disk('menu-images')->url($filename),
            'image_path' => $path,
            'menu_item' => $menuItem
        ];
    }

    private function validateMenuImageFile(UploadedFile $file): void
    {
        $file->validate([
            'image' => [
                'required',
                'image',
                'mimes:jpeg,png,jpg,webp',
                'max:2048',
                'dimensions:min_width=300,min_height=300,max_width=2000,max_height=2000'
            ]
        ]);
    }

    private function deleteOldMenuImage(int $menuItemId): void
    {
        $menuItem = $this->getMenuItem($menuItemId);
        if ($menuItem && $menuItem->image_path) {
            Storage::disk('menu-images')->delete($menuItem->image_path);
        }
    }

    private function updateMenuImage(int $menuItemId, string $path): object
    {
        return MenuItem::where('id', $menuItemId)->update([
            'image_path' => $path,
            'updated_at' => now()
        ]);
    }
}
```

#### **1.5 Update Barcode System**

**File**: `app/Services/BarcodeService.php`

```php
<?php

namespace App\Services;

use Illuminate\Support\Facades\Storage;
use SimpleSoftwareIO\QrCode\Facades\QrCode;

class BarcodeService
{
    /**
     * Generate QR code for menu item
     */
    public function generateQrCode(int $menuItemId, string $barcodeValue): array
    {
        $menuItem = $this->getMenuItem($menuItemId);
        
        // QR code content
        $qrContent = json_encode([
            'barcode' => $barcodeValue,
            'menu_item_id' => $menuItemId,
            'menu_item_name' => $menuItem->name,
            'price' => $menuItem->price,
            'url' => config('app.url') . '/menu/' . $menuItemId
        ]);

        // Generate filename
        $filename = 'qr_' . $barcodeValue . '_menu-item.png';
        
        // Generate QR code and store
        $qrCode = QrCode::format('png')
            ->size(300)
            ->margin(2)
            ->generate($qrContent);

        // Store QR code image
        $path = $filename;
        Storage::disk('barcodes')->put('qr-codes/' . $path, $qrCode);
        
        return [
            'qr_code_path' => 'qr-codes/' . $path,
            'qr_code_url' => Storage::disk('barcodes')->url('qr-codes/' . $filename),
            'barcode_value' => $barcodeValue
        ];
    }

    /**
     * Delete QR code
     */
    public function deleteQrCode(string $qrCodePath): bool
    {
        if ($qrCodePath) {
            return Storage::disk('barcodes')->delete($qrCodePath);
        }
        
        return false;
    }

    /**
     * Download QR code
     */
    public function downloadQrCode(string $qrCodePath): string
    {
        return Storage::disk('barcodes')->path($qrCodePath);
    }
}
```

### **Phase 2: Database Migration (Week 2)**

#### **2.1 Create Storage Directories**

```bash
# Create storage directories
mkdir -p storage/app/public/{avatars,payment-proofs,menu-images,barcodes/qr-codes,exports}
mkdir -p storage/app/documents

# Set permissions
chmod -R 755 storage/app/public
chmod -R 755 storage/app/documents

# Create storage link
php artisan storage:link
```

#### **2.2 Migration Script**

**File**: `database/migrations/2025_01_26_000000_update_file_paths_to_laravel_storage.php`

```php
<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Facades\DB;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        // Update user_profiles table
        DB::table('user_profiles')
            ->whereNotNull('avatar_path')
            ->where('avatar_path', 'like', 'https://%')
            ->update([
                'avatar_path' => DB::raw("SUBSTRING_INDEX(avatar_path, '/', -1)")
            ]);

        // Update payments table
        DB::table('payments')
            ->whereNotNull('payment_proof_path')
            ->where('payment_proof_path', 'like', 'https://%')
            ->update([
                'payment_proof_path' => DB::raw("SUBSTRING_INDEX(payment_proof_path, '/', -1)")
            ]);

        // Update menu_items table
        DB::table('menu_items')
            ->whereNotNull('image_path')
            ->where('image_path', 'like', 'https://%')
            ->update([
                'image_path' => DB::raw("SUBSTRING_INDEX(image_path, '/', -1)")
            ]);

        // Update barcodes table
        DB::table('barcodes')
            ->whereNotNull('qr_code_path')
            ->where('qr_code_path', 'like', 'https://%')
            ->update([
                'qr_code_path' => DB::raw("SUBSTRING_INDEX(qr_code_path, '/', -1)")
            ]);
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        // This migration is not reversible
        // File paths will need to be manually updated if rollback is needed
    }
};
```

### **Phase 3: Testing & Validation (Week 3)**

#### **3.1 Unit Tests Update**

**File**: `tests/Unit/Services/FileStorageTest.php`

```php
<?php

namespace Tests\Unit\Services;

use Tests\TestCase;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\Storage;
use App\Services\UserProfileService;
use App\Services\PaymentService;
use App\Services\MenuService;
use App\Services\BarcodeService;

class FileStorageTest extends TestCase
{
    protected function setUp(): void
    {
        parent::setUp();
        Storage::fake('avatars');
        Storage::fake('payment-proofs');
        Storage::fake('menu-images');
        Storage::fake('barcodes');
    }

    /** @test */
    public function it_can_upload_user_avatar()
    {
        $file = UploadedFile::fake()->image('avatar.jpg', 100, 100);
        $service = new UserProfileService();
        
        $result = $service->uploadAvatar(1, $file);
        
        $this->assertArrayHasKey('avatar_url', $result);
        $this->assertArrayHasKey('avatar_path', $result);
        
        // Verify file is stored in avatars disk
        Storage::disk('avatars')->assertExists($result['avatar_path']);
    }

    /** @test */
    public function it_can_upload_payment_proof()
    {
        $file = UploadedFile::fake()->create('proof.pdf', 1024, 'application/pdf');
        $service = new PaymentService();
        
        $result = $service->uploadPaymentProof(1, $file);
        
        $this->assertArrayHasKey('payment_proof_url', $result);
        $this->assertArrayHasKey('payment_proof_path', $result);
        
        // Verify file is stored in payment-proofs disk
        Storage::disk('payment-proofs')->assertExists($result['payment_proof_path']);
    }

    /** @test */
    public function it_can_upload_menu_image()
    {
        $file = UploadedFile::fake()->image('menu.jpg', 300, 300);
        $service = new MenuService();
        
        $result = $service->uploadMenuImage(1, $file);
        
        $this->assertArrayHasKey('image_url', $result);
        $this->assertArrayHasKey('image_path', $result);
        
        // Verify file is stored in menu-images disk
        Storage::disk('menu-images')->assertExists($result['image_path']);
    }

    /** @test */
    public function it_can_generate_qr_code()
    {
        $service = new BarcodeService();
        
        $result = $service->generateQrCode(1, 'QR000001');
        
        $this->assertArrayHasKey('qr_code_path', $result);
        $this->assertArrayHasKey('qr_code_url', $result);
        
        // Verify QR code is stored in barcodes disk
        Storage::disk('barcodes')->assertExists($result['qr_code_path']);
    }
}
```

#### **3.2 Feature Tests Update**

**File**: `tests/Feature/Api/FileUploadTest.php`

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
        Storage::fake('payment-proofs');
        Storage::fake('menu-images');
        Storage::fake('barcodes');
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

        // Verify file is stored
        $responseData = $response->json('data');
        Storage::disk('avatars')->assertExists($responseData['avatar_path']);
    }

    /** @test */
    public function user_can_upload_payment_proof()
    {
        $user = User::factory()->create();
        Sanctum::actingAs($user);

        $file = UploadedFile::fake()->create('proof.pdf', 1024, 'application/pdf');

        $response = $this->postJson('/api/v1/payments/1/proof', [
            'payment_proof' => $file
        ]);

        $response->assertStatus(200)
                ->assertJsonStructure([
                    'success',
                    'message',
                    'data' => [
                        'payment_proof_url',
                        'payment_proof_path'
                    ]
                ]);

        // Verify file is stored
        $responseData = $response->json('data');
        Storage::disk('payment-proofs')->assertExists($responseData['payment_proof_path']);
    }

    /** @test */
    public function admin_can_upload_menu_image()
    {
        $admin = User::factory()->create(['role' => 'admin']);
        Sanctum::actingAs($admin);

        $file = UploadedFile::fake()->image('menu.jpg', 300, 300);

        $response = $this->postJson('/api/v1/admin/menu/1/image', [
            'image' => $file
        ]);

        $response->assertStatus(200)
                ->assertJsonStructure([
                    'success',
                    'message',
                    'data' => [
                        'image_url',
                        'image_path'
                    ]
                ]);

        // Verify file is stored
        $responseData = $response->json('data');
        Storage::disk('menu-images')->assertExists($responseData['image_path']);
    }
}
```

### **Phase 4: Documentation Update (Week 4)**

#### **4.1 Update API Documentation**

**File**: `docs/api/file-storage-api.md` (New)

```markdown
# File Storage API Documentation

## Overview

Sistem file storage menggunakan Laravel Storage dengan disk khusus untuk setiap tipe file.

## Storage Disks

### Available Disks

- `avatars` - User profile pictures
- `payment-proofs` - Payment verification documents  
- `menu-images` - Menu item images
- `barcodes` - QR codes and barcode images
- `exports` - Exported data files
- `documents` - Private documents

### File Upload Endpoints

#### Upload Avatar

```http
POST /api/v1/profile/avatar
Content-Type: multipart/form-data
Authorization: Bearer {token}

avatar: [image file]
```

**Response:**
```json
{
    "success": true,
    "message": "Avatar uploaded successfully",
    "data": {
        "avatar_url": "http://localhost/storage/avatars/1_1234567890.jpg",
        "avatar_path": "1_1234567890.jpg"
    }
}
```

#### Upload Payment Proof

```http
POST /api/v1/payments/{id}/proof
Content-Type: multipart/form-data
Authorization: Bearer {token}

payment_proof: [file]
```

**Response:**
```json
{
    "success": true,
    "message": "Payment proof uploaded successfully",
    "data": {
        "payment_proof_url": "http://localhost/storage/payment-proofs/payment_1_1234567890.pdf",
        "payment_proof_path": "payment_1_1234567890.pdf"
    }
}
```

## File Validation Rules

### Avatar Upload
- Format: JPEG, PNG, JPG, GIF
- Size: Max 2MB
- Dimensions: 100x100 to 2000x2000 pixels

### Payment Proof
- Format: JPEG, PNG, JPG, PDF
- Size: Max 5MB

### Menu Images
- Format: JPEG, PNG, JPG, WebP
- Size: Max 2MB
- Dimensions: 300x300 to 2000x2000 pixels
```

#### **4.2 Update Performance Documentation**

**File**: `docs/api/performance.md` (Update)

```markdown
## File Storage Performance

### Laravel Storage Configuration

```php
// config/filesystems.php
'disks' => [
    'avatars' => [
        'driver' => 'local',
        'root' => storage_path('app/public/avatars'),
        'url' => env('APP_URL').'/storage/avatars',
        'visibility' => 'public',
    ],
    // ... other disks
],
```

### Performance Optimizations

1. **File Compression**: Automatic image compression
2. **CDN Integration**: Ready for CDN integration
3. **Lazy Loading**: Files loaded on demand
4. **Caching**: File metadata caching
```

#### **4.3 Update Security Documentation**

**File**: `docs/api/security.md` (Update)

```markdown
## File Upload Security

### Laravel Storage Security

```php
// File validation
$file->validate([
    'avatar' => [
        'required',
        'image',
        'mimes:jpeg,png,jpg,gif',
        'max:2048',
        'dimensions:min_width=100,min_height=100'
    ]
]);

// Secure file storage
$path = $file->storeAs('', $filename, 'avatars');
```

### Security Features

1. **File Type Validation**: Strict MIME type checking
2. **Size Limitations**: Configurable file size limits
3. **Path Sanitization**: Secure file path generation
4. **Access Control**: Role-based file access
```

## 🚀 Implementation Timeline

### **Week 1: Code Refactor**
- [ ] Update `config/filesystems.php`
- [ ] Refactor `UserProfileService`
- [ ] Refactor `PaymentService`
- [ ] Refactor `MenuService`
- [ ] Refactor `BarcodeService`
- [ ] Update all controllers

### **Week 2: Database Migration**
- [ ] Create storage directories
- [ ] Run migration script
- [ ] Update file paths in database
- [ ] Test file access

### **Week 3: Testing & Validation**
- [ ] Update unit tests
- [ ] Update feature tests
- [ ] Run integration tests
- [ ] Performance testing

### **Week 4: Documentation Update**
- [ ] Update API documentation
- [ ] Update performance docs
- [ ] Update security docs
- [ ] Create migration guide

## 📊 Benefits

### **Cost Reduction**
- ✅ No AWS S3 costs
- ✅ No data transfer fees
- ✅ No storage per GB fees

### **Performance**
- ✅ Faster file access (local storage)
- ✅ No network latency
- ✅ Direct file serving

### **Simplicity**
- ✅ Easier configuration
- ✅ No external dependencies
- ✅ Simplified deployment

### **Control**
- ✅ Full control over file storage
- ✅ Custom backup strategies
- ✅ Flexible file management

## ⚠️ Considerations

### **Backup Strategy**
- [ ] Implement automated backups
- [ ] Set up file replication
- [ ] Create disaster recovery plan

### **Scalability**
- [ ] Monitor disk space
- [ ] Plan for storage growth
- [ ] Consider load balancing

### **Security**
- [ ] Regular security audits
- [ ] File access monitoring
- [ ] Backup encryption

## 🔧 Maintenance Tasks

### **Daily**
- [ ] Monitor disk space usage
- [ ] Check file upload logs
- [ ] Verify backup status

### **Weekly**
- [ ] Clean up temporary files
- [ ] Review access logs
- [ ] Test backup restoration

### **Monthly**
- [ ] Analyze storage growth
- [ ] Review file access patterns
- [ ] Update security policies

---

**Status**: 📋 Planning  
**Priority**: 🔥 High  
**Estimated Effort**: 4 weeks  
**Risk Level**: 🟡 Medium
