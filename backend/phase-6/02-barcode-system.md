# Point 2: Barcode System

## 📋 Overview

Implementasi sistem barcode dengan generation, scanning, validation, dan management untuk menu items.

## 🎯 Objectives

- Barcode generation
- Barcode scanning
- Barcode validation
- Barcode management
- QR code generation
- Barcode analytics

## 📁 Files Structure

```
phase-6/
├── 02-barcode-system.md
├── app/Http/Controllers/BarcodeController.php
├── app/Models/Barcode.php
├── app/Services/BarcodeService.php
└── app/Jobs/GenerateBarcodeJob.php
```

## 🔧 Implementation Steps

### Step 1: Create Barcode Model

```php
<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Support\Facades\Storage;

class Barcode extends Model
{
    use HasFactory;

    protected $fillable = [
        'menu_item_id',
        'barcode_value',
        'barcode_type',
        'qr_code_path',
        'is_active',
    ];

    protected $casts = [
        'is_active' => 'boolean',
    ];

    public function menuItem()
    {
        return $this->belongsTo(MenuItem::class);
    }

    public function getQrCodeUrlAttribute()
    {
        return $this->qr_code_path ? Storage::url($this->qr_code_path) : null;
    }

    public function getBarcodeTypeDisplayAttribute()
    {
        return match($this->barcode_type) {
            'QR' => 'QR Code',
            'CODE128' => 'Code 128',
            'EAN13' => 'EAN-13',
            default => 'Unknown'
        };
    }

    public function getIsValidAttribute()
    {
        return $this->is_active && $this->menuItem && $this->menuItem->is_available;
    }

    public function getScanCountAttribute()
    {
        return $this->scans()->count();
    }

    public function getLastScannedAttribute()
    {
        return $this->scans()->latest()->first()?->created_at;
    }

    public function scans()
    {
        return $this->hasMany(BarcodeScan::class);
    }

    public function scopeActive($query)
    {
        return $query->where('is_active', true);
    }

    public function scopeByType($query, $type)
    {
        return $query->where('barcode_type', $type);
    }

    public function scopeByMenuItem($query, $menuItemId)
    {
        return $query->where('menu_item_id', $menuItemId);
    }

    public function scopeValid($query)
    {
        return $query->where('is_active', true)
            ->whereHas('menuItem', function ($q) {
                $q->where('is_available', true);
            });
    }
}
```

### Step 2: Create Barcode Scan Model

```php
<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class BarcodeScan extends Model
{
    use HasFactory;

    protected $fillable = [
        'barcode_id',
        'scanned_by',
        'scan_type',
        'ip_address',
        'user_agent',
        'location',
        'is_successful',
        'error_message',
    ];

    protected $casts = [
        'is_successful' => 'boolean',
        'location' => 'array',
    ];

    public function barcode()
    {
        return $this->belongsTo(Barcode::class);
    }

    public function user()
    {
        return $this->belongsTo(User::class, 'scanned_by');
    }

    public function getScanTypeDisplayAttribute()
    {
        return match($this->scan_type) {
            'menu_access' => 'Menu Access',
            'order_placement' => 'Order Placement',
            'inventory_check' => 'Inventory Check',
            'admin_scan' => 'Admin Scan',
            default => 'Unknown'
        };
    }

    public function scopeSuccessful($query)
    {
        return $query->where('is_successful', true);
    }

    public function scopeFailed($query)
    {
        return $query->where('is_successful', false);
    }

    public function scopeByType($query, $type)
    {
        return $query->where('scan_type', $type);
    }

    public function scopeByUser($query, $userId)
    {
        return $query->where('scanned_by', $userId);
    }

    public function scopeRecent($query, $days = 7)
    {
        return $query->where('created_at', '>=', now()->subDays($days));
    }
}
```

### Step 3: Create Barcode Service

```php
<?php

namespace App\Services;

use App\Models\Barcode;
use App\Models\BarcodeScan;
use App\Models\MenuItem;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Str;
use SimpleSoftwareIO\QrCode\Facades\QrCode;

class BarcodeService
{
    public function generateBarcode($menuItemId, $type = 'QR')
    {
        return DB::transaction(function () use ($menuItemId, $type) {
            $menuItem = MenuItem::findOrFail($menuItemId);

            // Check if barcode already exists
            $existingBarcode = $menuItem->barcode;
            if ($existingBarcode) {
                return $existingBarcode;
            }

            // Generate unique barcode value
            $barcodeValue = $this->generateUniqueBarcodeValue($type);

            // Generate QR code image
            $qrCodePath = $this->generateQrCodeImage($barcodeValue, $menuItem);

            // Create barcode record
            $barcode = Barcode::create([
                'menu_item_id' => $menuItem->id,
                'barcode_value' => $barcodeValue,
                'barcode_type' => $type,
                'qr_code_path' => $qrCodePath,
                'is_active' => true,
            ]);

            return $barcode;
        });
    }

    public function scanBarcode($barcodeValue, $scanData = [])
    {
        return DB::transaction(function () use ($barcodeValue, $scanData) {
            $barcode = Barcode::where('barcode_value', $barcodeValue)
                ->where('is_active', true)
                ->with('menuItem')
                ->first();

            if (!$barcode) {
                $this->recordFailedScan($barcodeValue, $scanData, 'Barcode not found');
                throw new \Exception('Invalid barcode');
            }

            if (!$barcode->menuItem || !$barcode->menuItem->is_available) {
                $this->recordFailedScan($barcodeValue, $scanData, 'Menu item not available');
                throw new \Exception('Menu item not available');
            }

            // Record successful scan
            $this->recordSuccessfulScan($barcode, $scanData);

            return $barcode->load('menuItem');
        });
    }

    public function validateBarcode($barcodeValue)
    {
        $barcode = Barcode::where('barcode_value', $barcodeValue)
            ->where('is_active', true)
            ->with('menuItem')
            ->first();

        if (!$barcode) {
            return [
                'valid' => false,
                'error' => 'Barcode not found',
            ];
        }

        if (!$barcode->menuItem) {
            return [
                'valid' => false,
                'error' => 'Menu item not found',
            ];
        }

        if (!$barcode->menuItem->is_available) {
            return [
                'valid' => false,
                'error' => 'Menu item not available',
            ];
        }

        return [
            'valid' => true,
            'barcode' => $barcode,
            'menu_item' => $barcode->menuItem,
        ];
    }

    public function regenerateBarcode($barcodeId)
    {
        return DB::transaction(function () use ($barcodeId) {
            $barcode = Barcode::findOrFail($barcodeId);

            // Delete old QR code image
            if ($barcode->qr_code_path) {
                Storage::delete($barcode->qr_code_path);
            }

            // Generate new barcode value
            $newBarcodeValue = $this->generateUniqueBarcodeValue($barcode->barcode_type);

            // Generate new QR code image
            $newQrCodePath = $this->generateQrCodeImage($newBarcodeValue, $barcode->menuItem);

            // Update barcode
            $barcode->update([
                'barcode_value' => $newBarcodeValue,
                'qr_code_path' => $newQrCodePath,
            ]);

            return $barcode;
        });
    }

    public function deactivateBarcode($barcodeId)
    {
        $barcode = Barcode::findOrFail($barcodeId);
        $barcode->update(['is_active' => false]);

        return $barcode;
    }

    public function activateBarcode($barcodeId)
    {
        $barcode = Barcode::findOrFail($barcodeId);
        $barcode->update(['is_active' => true]);

        return $barcode;
    }

    public function getBarcodeStats($filters = [])
    {
        $query = Barcode::query();

        if (isset($filters['start_date']) && isset($filters['end_date'])) {
            $query->whereBetween('created_at', [$filters['start_date'], $filters['end_date']]);
        }

        $stats = [
            'total_barcodes' => $query->count(),
            'active_barcodes' => $query->clone()->active()->count(),
            'inactive_barcodes' => $query->clone()->where('is_active', false)->count(),
            'qr_codes' => $query->clone()->byType('QR')->count(),
            'code128_barcodes' => $query->clone()->byType('CODE128')->count(),
            'ean13_barcodes' => $query->clone()->byType('EAN13')->count(),
            'total_scans' => BarcodeScan::count(),
            'successful_scans' => BarcodeScan::successful()->count(),
            'failed_scans' => BarcodeScan::failed()->count(),
        ];

        return $stats;
    }

    public function getBarcodeAnalytics($filters = [])
    {
        $query = Barcode::query();

        if (isset($filters['start_date']) && isset($filters['end_date'])) {
            $query->whereBetween('created_at', [$filters['start_date'], $filters['end_date']]);
        }

        $analytics = [
            'scan_analytics' => $this->getScanAnalytics($query->clone()),
            'barcode_types' => $this->getBarcodeTypes($query->clone()),
            'top_scanned_barcodes' => $this->getTopScannedBarcodes($query->clone()),
            'scan_trends' => $this->getScanTrends($query->clone()),
            'scan_locations' => $this->getScanLocations($query->clone()),
        ];

        return $analytics;
    }

    public function bulkGenerateBarcodes($menuItemIds, $type = 'QR')
    {
        $results = [];

        foreach ($menuItemIds as $menuItemId) {
            try {
                $barcode = $this->generateBarcode($menuItemId, $type);
                $results[] = [
                    'menu_item_id' => $menuItemId,
                    'success' => true,
                    'barcode_id' => $barcode->id,
                    'barcode_value' => $barcode->barcode_value,
                ];
            } catch (\Exception $e) {
                $results[] = [
                    'menu_item_id' => $menuItemId,
                    'success' => false,
                    'error' => $e->getMessage(),
                ];
            }
        }

        return $results;
    }

    public function downloadBarcode($barcodeId)
    {
        $barcode = Barcode::findOrFail($barcodeId);

        if (!$barcode->qr_code_path) {
            throw new \Exception('QR code image not found');
        }

        return Storage::download($barcode->qr_code_path);
    }

    protected function generateUniqueBarcodeValue($type)
    {
        do {
            switch ($type) {
                case 'QR':
                    $barcodeValue = 'QR' . str_pad(rand(1, 999999), 6, '0', STR_PAD_LEFT);
                    break;
                case 'CODE128':
                    $barcodeValue = 'C128' . str_pad(rand(1, 999999), 6, '0', STR_PAD_LEFT);
                    break;
                case 'EAN13':
                    $barcodeValue = 'EAN' . str_pad(rand(1, 999999), 6, '0', STR_PAD_LEFT);
                    break;
                default:
                    $barcodeValue = 'BC' . str_pad(rand(1, 999999), 6, '0', STR_PAD_LEFT);
            }
        } while (Barcode::where('barcode_value', $barcodeValue)->exists());

        return $barcodeValue;
    }

    protected function generateQrCodeImage($barcodeValue, $menuItem)
    {
        $filename = 'qr_' . $barcodeValue . '_' . Str::slug($menuItem->name) . '.png';
        $path = 'barcodes/qr-codes/' . $filename;

        // Generate QR code with menu item information
        $qrData = [
            'barcode' => $barcodeValue,
            'menu_item_id' => $menuItem->id,
            'menu_item_name' => $menuItem->name,
            'price' => $menuItem->price,
            'url' => config('app.url') . '/menu/' . $menuItem->id,
        ];

        $qrCode = QrCode::format('png')
            ->size(300)
            ->margin(2)
            ->generate(json_encode($qrData));

        Storage::put($path, $qrCode);

        return $path;
    }

    protected function recordSuccessfulScan($barcode, $scanData)
    {
        BarcodeScan::create([
            'barcode_id' => $barcode->id,
            'scanned_by' => $scanData['user_id'] ?? null,
            'scan_type' => $scanData['scan_type'] ?? 'menu_access',
            'ip_address' => $scanData['ip_address'] ?? request()->ip(),
            'user_agent' => $scanData['user_agent'] ?? request()->userAgent(),
            'location' => $scanData['location'] ?? null,
            'is_successful' => true,
        ]);
    }

    protected function recordFailedScan($barcodeValue, $scanData, $errorMessage)
    {
        BarcodeScan::create([
            'barcode_id' => null,
            'scanned_by' => $scanData['user_id'] ?? null,
            'scan_type' => $scanData['scan_type'] ?? 'menu_access',
            'ip_address' => $scanData['ip_address'] ?? request()->ip(),
            'user_agent' => $scanData['user_agent'] ?? request()->userAgent(),
            'location' => $scanData['location'] ?? null,
            'is_successful' => false,
            'error_message' => $errorMessage,
        ]);
    }

    protected function getScanAnalytics($query)
    {
        $totalScans = BarcodeScan::count();
        $successfulScans = BarcodeScan::successful()->count();

        return [
            'total_scans' => $totalScans,
            'successful_scans' => $successfulScans,
            'failed_scans' => $totalScans - $successfulScans,
            'success_rate' => $totalScans > 0 ? round(($successfulScans / $totalScans) * 100, 2) : 0,
        ];
    }

    protected function getBarcodeTypes($query)
    {
        return $query->selectRaw('barcode_type, COUNT(*) as count')
            ->groupBy('barcode_type')
            ->orderBy('count', 'desc')
            ->get()
            ->map(function ($item) {
                return [
                    'type' => $item->barcode_type,
                    'count' => $item->count,
                    'percentage' => round(($item->count / $query->count()) * 100, 2),
                ];
            });
    }

    protected function getTopScannedBarcodes($query)
    {
        return $query->with(['menuItem'])
            ->withCount('scans')
            ->orderBy('scans_count', 'desc')
            ->limit(10)
            ->get()
            ->map(function ($barcode) {
                return [
                    'id' => $barcode->id,
                    'barcode_value' => $barcode->barcode_value,
                    'menu_item_name' => $barcode->menuItem->name,
                    'scan_count' => $barcode->scans_count,
                    'last_scanned' => $barcode->last_scanned,
                ];
            });
    }

    protected function getScanTrends($query)
    {
        $startDate = now()->subDays(30);
        $endDate = now();

        $trends = [];
        $currentDate = $startDate->copy();

        while ($currentDate->lte($endDate)) {
            $date = $currentDate->format('Y-m-d');

            $dayStats = [
                'date' => $date,
                'total_scans' => BarcodeScan::whereDate('created_at', $date)->count(),
                'successful_scans' => BarcodeScan::whereDate('created_at', $date)->successful()->count(),
                'failed_scans' => BarcodeScan::whereDate('created_at', $date)->failed()->count(),
            ];

            $trends[] = $dayStats;
            $currentDate->addDay();
        }

        return $trends;
    }

    protected function getScanLocations($query)
    {
        return BarcodeScan::whereNotNull('location')
            ->selectRaw('location, COUNT(*) as count')
            ->groupBy('location')
            ->orderBy('count', 'desc')
            ->limit(10)
            ->get()
            ->map(function ($item) {
                return [
                    'location' => $item->location,
                    'scan_count' => $item->count,
                ];
            });
    }
}
```

## 📚 API Endpoints

### Barcode System Endpoints

```
POST   /api/menu/scan-barcode
GET    /api/menu/barcode/{code}
GET    /api/admin/barcodes
POST   /api/admin/barcodes/generate
GET    /api/admin/barcodes/{id}
PUT    /api/admin/barcodes/{id}
DELETE /api/admin/barcodes/{id}
POST   /api/admin/barcodes/{id}/regenerate
POST   /api/admin/barcodes/{id}/activate
POST   /api/admin/barcodes/{id}/deactivate
GET    /api/admin/barcodes/{id}/download
POST   /api/admin/barcodes/bulk-generate
GET    /api/admin/barcodes/stats
GET    /api/admin/barcodes/analytics
```

## 🧪 Testing

### BarcodeTest.php

```php
<?php

use App\Models\Barcode;
use App\Models\MenuItem;
use App\Services\BarcodeService;

describe('Barcode System', function () {

    beforeEach(function () {
        $this->barcodeService = app(BarcodeService::class);
    });

    it('can generate barcode', function () {
        $menuItem = MenuItem::factory()->create();

        $barcode = $this->barcodeService->generateBarcode($menuItem->id, 'QR');

        expect($barcode->menu_item_id)->toBe($menuItem->id);
        expect($barcode->barcode_type)->toBe('QR');
        expect($barcode->barcode_value)->not->toBeNull();
        expect($barcode->qr_code_path)->not->toBeNull();
    });

    it('can scan valid barcode', function () {
        $menuItem = MenuItem::factory()->create(['is_available' => true]);
        $barcode = Barcode::factory()->create([
            'menu_item_id' => $menuItem->id,
            'is_active' => true
        ]);

        $scannedBarcode = $this->barcodeService->scanBarcode($barcode->barcode_value, [
            'user_id' => 1,
            'scan_type' => 'menu_access'
        ]);

        expect($scannedBarcode->id)->toBe($barcode->id);
        expect($scannedBarcode->menuItem->id)->toBe($menuItem->id);
    });

    it('cannot scan invalid barcode', function () {
        expect(function () {
            $this->barcodeService->scanBarcode('INVALID123', [
                'user_id' => 1,
                'scan_type' => 'menu_access'
            ]);
        })->toThrow(Exception::class, 'Invalid barcode');
    });

    it('cannot scan barcode for unavailable menu item', function () {
        $menuItem = MenuItem::factory()->create(['is_available' => false]);
        $barcode = Barcode::factory()->create([
            'menu_item_id' => $menuItem->id,
            'is_active' => true
        ]);

        expect(function () use ($barcode) {
            $this->barcodeService->scanBarcode($barcode->barcode_value, [
                'user_id' => 1,
                'scan_type' => 'menu_access'
            ]);
        })->toThrow(Exception::class, 'Menu item not available');
    });

    it('can validate barcode', function () {
        $menuItem = MenuItem::factory()->create(['is_available' => true]);
        $barcode = Barcode::factory()->create([
            'menu_item_id' => $menuItem->id,
            'is_active' => true
        ]);

        $validation = $this->barcodeService->validateBarcode($barcode->barcode_value);

        expect($validation['valid'])->toBeTrue();
        expect($validation['barcode']->id)->toBe($barcode->id);
    });

    it('can regenerate barcode', function () {
        $barcode = Barcode::factory()->create();
        $oldValue = $barcode->barcode_value;

        $newBarcode = $this->barcodeService->regenerateBarcode($barcode->id);

        expect($newBarcode->barcode_value)->not->toBe($oldValue);
        expect($newBarcode->qr_code_path)->not->toBeNull();
    });

    it('can get barcode statistics', function () {
        Barcode::factory()->count(5)->create();
        actingAsAdmin();

        $response = apiGet('/api/admin/barcodes/stats');

        assertApiSuccess($response, 'Barcode statistics retrieved successfully');
        expect($response->json('data.total_barcodes'))->toBe(5);
    });

    it('can download barcode', function () {
        $barcode = Barcode::factory()->create(['qr_code_path' => 'test/path.png']);
        actingAsAdmin();

        $response = apiGet("/api/admin/barcodes/{$barcode->id}/download");

        expect($response->status())->toBe(200);
    });
});
```

## ✅ Success Criteria

- [ ] Barcode generation berfungsi
- [ ] Barcode scanning berjalan
- [ ] Barcode validation berfungsi
- [ ] Barcode management berjalan
- [ ] QR code generation berfungsi
- [ ] Barcode analytics berjalan
- [ ] Testing coverage > 90%

## 📚 Documentation

- [SimpleSoftwareIO QrCode](https://github.com/SimpleSoftwareIO/simple-qrcode)
- [Laravel File Storage](https://laravel.com/docs/11.x/filesystem)
- [Laravel Database Transactions](https://laravel.com/docs/11.x/database#database-transactions)
