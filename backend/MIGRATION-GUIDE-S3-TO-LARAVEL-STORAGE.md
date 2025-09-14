# Migration Guide: S3 ke Laravel Storage

## 📋 Overview

Panduan lengkap untuk migrasi sistem file storage dari AWS S3 ke Laravel Storage lokal pada backend Raujan Pool.

## 🎯 Prerequisites

### **Requirements**
- Laravel 11.x
- PHP 8.2+
- MySQL 8.0+
- Storage space yang cukup untuk file

### **Backup Requirements**
- [ ] Backup database lengkap
- [ ] Backup semua file yang ada di S3
- [ ] Backup konfigurasi aplikasi
- [ ] Test backup restoration

## 📦 Step-by-Step Migration

### **Step 1: Environment Preparation**

#### **1.1 Update Environment Configuration**

**File**: `.env`

```env
# File Storage Configuration
FILESYSTEM_DISK=local

# Remove S3 configuration (if exists)
# AWS_ACCESS_KEY_ID=
# AWS_SECRET_ACCESS_KEY=
# AWS_DEFAULT_REGION=
# AWS_BUCKET=

# App URL (for file URLs)
APP_URL=http://localhost:8000
```

#### **1.2 Install Dependencies**

```bash
# Install additional packages if needed
composer require intervention/image
composer require simple-qrcode/qrcode

# Update composer
composer update
```

### **Step 2: Storage Configuration**

#### **2.1 Update Filesystem Configuration**

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

        // Specialized storage disks for better organization
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

#### **2.2 Create Storage Directories**

```bash
# Create storage directories
mkdir -p storage/app/public/avatars
mkdir -p storage/app/public/payment-proofs
mkdir -p storage/app/public/menu-images
mkdir -p storage/app/public/barcodes/qr-codes
mkdir -p storage/app/public/exports
mkdir -p storage/app/documents

# Set proper permissions
chmod -R 755 storage/app/public
chmod -R 755 storage/app/documents

# Create symbolic link for public access
php artisan storage:link
```

#### **2.3 Verify Storage Setup**

```bash
# Test storage configuration
php artisan tinker

# In tinker, run:
Storage::disk('avatars')->put('test.txt', 'Hello World');
echo Storage::disk('avatars')->get('test.txt');
Storage::disk('avatars')->delete('test.txt');
```

### **Step 3: Code Migration**

#### **3.1 Update User Profile Service**

**File**: `app/Services/UserProfileService.php`

```php
<?php

namespace App\Services;

use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Str;
use App\Models\UserProfile;

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

    private function getUserProfile(int $userId): ?UserProfile
    {
        return UserProfile::where('user_id', $userId)->first();
    }

    private function formatExportData($profile): array
    {
        return [
            'user_id' => $profile->user_id,
            'name' => $profile->name,
            'email' => $profile->email,
            'phone' => $profile->phone,
            'address' => $profile->address,
            'exported_at' => now()->toISOString()
        ];
    }
}
```

#### **3.2 Update Payment Service**

**File**: `app/Services/PaymentService.php`

```php
<?php

namespace App\Services;

use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Str;
use App\Models\Payment;

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

    private function getPayment(int $paymentId): ?Payment
    {
        return Payment::find($paymentId);
    }
}
```

#### **3.3 Update Menu Service**

**File**: `app/Services/MenuService.php`

```php
<?php

namespace App\Services;

use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Str;
use App\Models\MenuItem;

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

    private function getMenuItem(int $menuItemId): ?MenuItem
    {
        return MenuItem::find($menuItemId);
    }
}
```

#### **3.4 Update Barcode Service**

**File**: `app/Services/BarcodeService.php`

```php
<?php

namespace App\Services;

use Illuminate\Support\Facades\Storage;
use SimpleSoftwareIO\QrCode\Facades\QrCode;
use App\Models\MenuItem;

class BarcodeService
{
    /**
     * Generate QR code for menu item
     */
    public function generateQrCode(int $menuItemId, string $barcodeValue): array
    {
        $menuItem = $this->getMenuItem($menuItemId);
        
        if (!$menuItem) {
            throw new \Exception('Menu item not found');
        }
        
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
        $path = 'qr-codes/' . $filename;
        Storage::disk('barcodes')->put($path, $qrCode);
        
        return [
            'qr_code_path' => $path,
            'qr_code_url' => Storage::disk('barcodes')->url($path),
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

    private function getMenuItem(int $menuItemId): ?MenuItem
    {
        return MenuItem::find($menuItemId);
    }
}
```

### **Step 4: Database Migration**

#### **4.1 Create Migration File**

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
        // Update user_profiles table - extract filename from S3 URLs
        DB::table('user_profiles')
            ->whereNotNull('avatar_path')
            ->where('avatar_path', 'like', 'https://%')
            ->update([
                'avatar_path' => DB::raw("SUBSTRING_INDEX(avatar_path, '/', -1)")
            ]);

        // Update payments table - extract filename from S3 URLs
        DB::table('payments')
            ->whereNotNull('payment_proof_path')
            ->where('payment_proof_path', 'like', 'https://%')
            ->update([
                'payment_proof_path' => DB::raw("SUBSTRING_INDEX(payment_proof_path, '/', -1)")
            ]);

        // Update menu_items table - extract filename from S3 URLs
        DB::table('menu_items')
            ->whereNotNull('image_path')
            ->where('image_path', 'like', 'https://%')
            ->update([
                'image_path' => DB::raw("SUBSTRING_INDEX(image_path, '/', -1)")
            ]);

        // Update barcodes table - extract filename from S3 URLs
        DB::table('barcodes')
            ->whereNotNull('qr_code_path')
            ->where('qr_code_path', 'like', 'https://%')
            ->update([
                'qr_code_path' => DB::raw("SUBSTRING_INDEX(qr_code_path, '/', -1)")
            ]);

        // Log migration completion
        \Log::info('File paths migration completed successfully');
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        // This migration is not easily reversible
        // File paths would need to be manually updated if rollback is needed
        \Log::warning('File paths migration rollback - manual intervention required');
    }
};
```

#### **4.2 Run Migration**

```bash
# Run the migration
php artisan migrate

# Verify migration results
php artisan tinker

# In tinker, check updated paths:
DB::table('user_profiles')->whereNotNull('avatar_path')->get(['id', 'avatar_path']);
DB::table('payments')->whereNotNull('payment_proof_path')->get(['id', 'payment_proof_path']);
DB::table('menu_items')->whereNotNull('image_path')->get(['id', 'image_path']);
DB::table('barcodes')->whereNotNull('qr_code_path')->get(['id', 'qr_code_path']);
```

### **Step 5: File Migration from S3**

#### **5.1 Download Files from S3**

```bash
# Install AWS CLI if not already installed
pip install awscli

# Configure AWS CLI
aws configure

# Download all files from S3 bucket
aws s3 sync s3://your-bucket-name/avatars storage/app/public/avatars/
aws s3 sync s3://your-bucket-name/payment-proofs storage/app/public/payment-proofs/
aws s3 sync s3://your-bucket-name/menu-images storage/app/public/menu-images/
aws s3 sync s3://your-bucket-name/barcodes storage/app/public/barcodes/
aws s3 sync s3://your-bucket-name/exports storage/app/public/exports/
```

#### **5.2 Verify File Migration**

```bash
# Check file counts
ls -la storage/app/public/avatars/ | wc -l
ls -la storage/app/public/payment-proofs/ | wc -l
ls -la storage/app/public/menu-images/ | wc -l
ls -la storage/app/public/barcodes/ | wc -l

# Test file access
php artisan tinker

# In tinker, test file access:
Storage::disk('avatars')->exists('some-filename.jpg');
Storage::disk('payment-proofs')->exists('some-filename.pdf');
```

### **Step 6: Testing**

#### **6.1 Unit Tests**

**File**: `tests/Unit/Services/FileStorageMigrationTest.php`

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

class FileStorageMigrationTest extends TestCase
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
    public function user_profile_service_uses_avatars_disk()
    {
        $file = UploadedFile::fake()->image('avatar.jpg', 100, 100);
        $service = new UserProfileService();
        
        $result = $service->uploadAvatar(1, $file);
        
        $this->assertStringContains('avatars', $result['avatar_url']);
        Storage::disk('avatars')->assertExists($result['avatar_path']);
    }

    /** @test */
    public function payment_service_uses_payment_proofs_disk()
    {
        $file = UploadedFile::fake()->create('proof.pdf', 1024, 'application/pdf');
        $service = new PaymentService();
        
        $result = $service->uploadPaymentProof(1, $file);
        
        $this->assertStringContains('payment-proofs', $result['payment_proof_url']);
        Storage::disk('payment-proofs')->assertExists($result['payment_proof_path']);
    }

    /** @test */
    public function menu_service_uses_menu_images_disk()
    {
        $file = UploadedFile::fake()->image('menu.jpg', 300, 300);
        $service = new MenuService();
        
        $result = $service->uploadMenuImage(1, $file);
        
        $this->assertStringContains('menu-images', $result['image_url']);
        Storage::disk('menu-images')->assertExists($result['image_path']);
    }

    /** @test */
    public function barcode_service_uses_barcodes_disk()
    {
        $service = new BarcodeService();
        
        $result = $service->generateQrCode(1, 'QR000001');
        
        $this->assertStringContains('barcodes', $result['qr_code_url']);
        Storage::disk('barcodes')->assertExists($result['qr_code_path']);
    }
}
```

#### **6.2 Feature Tests**

**File**: `tests/Feature/Api/FileStorageMigrationTest.php`

```php
<?php

namespace Tests\Feature\Api;

use Tests\TestCase;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\Storage;
use App\Models\User;
use Laravel\Sanctum\Sanctum;

class FileStorageMigrationTest extends TestCase
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
    public function avatar_upload_uses_laravel_storage()
    {
        $user = User::factory()->create();
        Sanctum::actingAs($user);

        $file = UploadedFile::fake()->image('avatar.jpg', 100, 100);

        $response = $this->postJson('/api/v1/profile/avatar', [
            'avatar' => $file
        ]);

        $response->assertStatus(200);
        
        $responseData = $response->json('data');
        $this->assertStringContains('/storage/avatars/', $responseData['avatar_url']);
        Storage::disk('avatars')->assertExists($responseData['avatar_path']);
    }

    /** @test */
    public function payment_proof_upload_uses_laravel_storage()
    {
        $user = User::factory()->create();
        Sanctum::actingAs($user);

        $file = UploadedFile::fake()->create('proof.pdf', 1024, 'application/pdf');

        $response = $this->postJson('/api/v1/payments/1/proof', [
            'payment_proof' => $file
        ]);

        $response->assertStatus(200);
        
        $responseData = $response->json('data');
        $this->assertStringContains('/storage/payment-proofs/', $responseData['payment_proof_url']);
        Storage::disk('payment-proofs')->assertExists($responseData['payment_proof_path']);
    }

    /** @test */
    public function menu_image_upload_uses_laravel_storage()
    {
        $admin = User::factory()->create(['role' => 'admin']);
        Sanctum::actingAs($admin);

        $file = UploadedFile::fake()->image('menu.jpg', 300, 300);

        $response = $this->postJson('/api/v1/admin/menu/1/image', [
            'image' => $file
        ]);

        $response->assertStatus(200);
        
        $responseData = $response->json('data');
        $this->assertStringContains('/storage/menu-images/', $responseData['image_url']);
        Storage::disk('menu-images')->assertExists($responseData['image_path']);
    }
}
```

#### **6.3 Run Tests**

```bash
# Run all tests
php artisan test

# Run specific test suites
php artisan test tests/Unit/Services/FileStorageMigrationTest.php
php artisan test tests/Feature/Api/FileStorageMigrationTest.php

# Run with coverage
php artisan test --coverage
```

### **Step 7: Performance Testing**

#### **7.1 File Upload Performance Test**

```bash
# Test file upload performance
php artisan tinker

# In tinker, run performance test:
$startTime = microtime(true);
$file = \Illuminate\Http\UploadedFile::fake()->image('test.jpg', 100, 100);
$service = new \App\Services\UserProfileService();
$result = $service->uploadAvatar(1, $file);
$endTime = microtime(true);
$executionTime = $endTime - $startTime;
echo "Upload time: " . $executionTime . " seconds";
```

#### **7.2 File Access Performance Test**

```bash
# Test file access performance
php artisan tinker

# In tinker, run access test:
$startTime = microtime(true);
$url = \Illuminate\Support\Facades\Storage::disk('avatars')->url('test-file.jpg');
$endTime = microtime(true);
$executionTime = $endTime - $startTime;
echo "URL generation time: " . $executionTime . " seconds";
```

### **Step 8: Deployment**

#### **8.1 Production Deployment**

```bash
# Update production environment
cp .env.example .env.production

# Edit .env.production
FILESYSTEM_DISK=local
APP_URL=https://yourdomain.com

# Deploy to production
git add .
git commit -m "feat: migrate from S3 to Laravel Storage"
git push origin main

# On production server:
git pull origin main
composer install --no-dev --optimize-autoloader
php artisan config:cache
php artisan route:cache
php artisan view:cache
php artisan storage:link
php artisan migrate --force
```

#### **8.2 Verify Production Deployment**

```bash
# Test file upload on production
curl -X POST https://yourdomain.com/api/v1/profile/avatar \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -F "avatar=@test-image.jpg"

# Check storage directories
ls -la storage/app/public/

# Test file access
curl -I https://yourdomain.com/storage/avatars/some-file.jpg
```

## 🔍 Troubleshooting

### **Common Issues**

#### **Issue 1: Storage Link Not Working**

```bash
# Remove existing link
rm public/storage

# Recreate link
php artisan storage:link

# Verify link
ls -la public/storage
```

#### **Issue 2: File Permissions**

```bash
# Fix permissions
chmod -R 755 storage/app/public
chown -R www-data:www-data storage/app/public

# Check permissions
ls -la storage/app/public/
```

#### **Issue 3: File URLs Not Accessible**

```bash
# Check web server configuration
# For Nginx:
location /storage {
    alias /path/to/your/app/storage/app/public;
    expires 1y;
    add_header Cache-Control "public, immutable";
}

# For Apache:
# Add to .htaccess in public directory
RewriteRule ^storage/(.*)$ storage/app/public/$1 [L]
```

#### **Issue 4: Migration Failed**

```bash
# Check migration status
php artisan migrate:status

# Rollback if needed
php artisan migrate:rollback --step=1

# Re-run migration
php artisan migrate
```

### **Performance Issues**

#### **Slow File Access**

```bash
# Enable OPcache in PHP
opcache.enable=1
opcache.memory_consumption=128
opcache.max_accelerated_files=4000

# Enable gzip compression
# In Nginx:
gzip on;
gzip_types image/jpeg image/png image/gif application/pdf;
```

#### **Large File Handling**

```php
// Increase upload limits in php.ini
upload_max_filesize = 10M
post_max_size = 10M
max_execution_time = 300
memory_limit = 256M
```

## 📊 Migration Checklist

### **Pre-Migration**
- [ ] Backup database
- [ ] Backup S3 files
- [ ] Test backup restoration
- [ ] Plan downtime window

### **Migration**
- [ ] Update environment configuration
- [ ] Update filesystem configuration
- [ ] Create storage directories
- [ ] Update service classes
- [ ] Run database migration
- [ ] Download files from S3
- [ ] Verify file migration

### **Testing**
- [ ] Run unit tests
- [ ] Run feature tests
- [ ] Test file uploads
- [ ] Test file access
- [ ] Performance testing

### **Deployment**
- [ ] Deploy to staging
- [ ] Test on staging
- [ ] Deploy to production
- [ ] Verify production deployment
- [ ] Monitor for issues

### **Post-Migration**
- [ ] Update documentation
- [ ] Train team on new system
- [ ] Monitor performance
- [ ] Clean up S3 bucket (after verification)
- [ ] Update backup procedures

## 🎯 Success Metrics

### **Performance Metrics**
- [ ] File upload time < 2 seconds
- [ ] File access time < 100ms
- [ ] Storage usage within limits
- [ ] No 404 errors on file access

### **Functionality Metrics**
- [ ] All file uploads working
- [ ] All file downloads working
- [ ] All image displays working
- [ ] All QR codes generating correctly

### **Business Metrics**
- [ ] No user complaints
- [ ] No data loss
- [ ] Reduced storage costs
- [ ] Improved system reliability

---

**Migration Status**: 📋 Ready to Execute  
**Estimated Time**: 4-6 hours  
**Risk Level**: 🟡 Medium  
**Rollback Plan**: Available (with S3 backup)
