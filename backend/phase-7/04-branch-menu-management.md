# Branch Menu Management - Phase 7.4

## 📋 Overview

Implementasi sistem manajemen menu per cabang untuk Raujan Pool Syariah. Fitur ini memungkinkan setiap cabang memiliki menu cafe dengan harga dan ketersediaan yang berbeda.

## 🎯 Objectives

- **Menu Assignment**: Penugasan menu items ke cabang tertentu
- **Branch-specific Menu Pricing**: Harga menu per cabang
- **Menu Availability per Branch**: Ketersediaan menu per cabang
- **Menu Category Management**: Manajemen kategori menu per cabang
- **Menu Inventory Tracking**: Tracking inventori menu per cabang

## 🏗️ Database Schema

### 4.1 Updated Menu Items Table

```sql
ALTER TABLE menu_items ADD COLUMN branch_id BIGINT UNSIGNED NOT NULL AFTER id;
ALTER TABLE menu_items ADD FOREIGN KEY (branch_id) REFERENCES branches(id) ON DELETE CASCADE;
ALTER TABLE menu_items ADD INDEX idx_menu_items_branch (branch_id);
```

### 4.2 Menu Branch Configuration Table

```sql
CREATE TABLE menu_branch_configs (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    menu_item_id BIGINT UNSIGNED NOT NULL,
    branch_id BIGINT UNSIGNED NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    is_available BOOLEAN NOT NULL DEFAULT TRUE,
    stock_quantity INT DEFAULT NULL,
    min_stock_level INT DEFAULT NULL,
    created_at TIMESTAMP NULL DEFAULT NULL,
    updated_at TIMESTAMP NULL DEFAULT NULL,
    
    FOREIGN KEY (menu_item_id) REFERENCES menu_items(id) ON DELETE CASCADE,
    FOREIGN KEY (branch_id) REFERENCES branches(id) ON DELETE CASCADE,
    
    UNIQUE KEY unique_menu_branch (menu_item_id, branch_id),
    INDEX idx_menu_branch_config_menu (menu_item_id),
    INDEX idx_menu_branch_config_branch (branch_id)
);
```

## 🔧 Implementation

### 4.1 Migration

```php
<?php
// database/migrations/2024_09_04_000006_add_branch_id_to_menu_items_table.php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('menu_items', function (Blueprint $table) {
            $table->foreignId('branch_id')->after('id')->constrained()->onDelete('cascade');
            $table->index('branch_id');
        });
    }

    public function down(): void
    {
        Schema::table('menu_items', function (Blueprint $table) {
            $table->dropForeign(['branch_id']);
            $table->dropIndex(['branch_id']);
            $table->dropColumn('branch_id');
        });
    }
};
```

### 4.2 Service

```php
<?php
// app/Services/BranchMenuService.php

namespace App\Services;

use App\Models\Branch;
use App\Models\MenuItem;
use App\Models\MenuBranchConfig;
use Illuminate\Database\Eloquent\Collection;

class BranchMenuService
{
    public function getBranchMenu(Branch $branch, array $filters = []): Collection
    {
        $query = $branch->menuItems();
        
        if (isset($filters['category'])) {
            $query->where('category', $filters['category']);
        }
        
        if (isset($filters['is_available'])) {
            $query->where('is_available', $filters['is_available']);
        }
        
        return $query->with(['branchConfigs' => function ($q) use ($branch) {
            $q->where('branch_id', $branch->id);
        }])->get();
    }

    public function createBranchMenuItem(Branch $branch, array $data): MenuItem
    {
        $data['branch_id'] = $branch->id;
        return MenuItem::create($data);
    }

    public function configureMenuItemForBranch(MenuItem $menuItem, Branch $branch, array $config): MenuBranchConfig
    {
        return MenuBranchConfig::updateOrCreate(
            [
                'menu_item_id' => $menuItem->id,
                'branch_id' => $branch->id
            ],
            $config
        );
    }

    public function updateMenuItemStock(MenuItem $menuItem, Branch $branch, int $quantity): MenuBranchConfig
    {
        $config = $menuItem->branchConfigs()
            ->where('branch_id', $branch->id)
            ->first();
        
        if (!$config) {
            $config = $this->configureMenuItemForBranch($menuItem, $branch, [
                'price' => $menuItem->price,
                'stock_quantity' => $quantity
            ]);
        } else {
            $config->update(['stock_quantity' => $quantity]);
        }
        
        return $config;
    }

    public function getMenuItemAvailability(MenuItem $menuItem, Branch $branch): array
    {
        $config = $menuItem->branchConfigs()
            ->where('branch_id', $branch->id)
            ->first();
        
        $isAvailable = $menuItem->is_available;
        $stockQuantity = null;
        $isLowStock = false;
        
        if ($config) {
            $isAvailable = $isAvailable && $config->is_available;
            $stockQuantity = $config->stock_quantity;
            
            if ($stockQuantity !== null && $config->min_stock_level !== null) {
                $isLowStock = $stockQuantity <= $config->min_stock_level;
            }
        }
        
        return [
            'menu_item_id' => $menuItem->id,
            'branch_id' => $branch->id,
            'is_available' => $isAvailable,
            'stock_quantity' => $stockQuantity,
            'is_low_stock' => $isLowStock,
            'price' => $config ? $config->price : $menuItem->price
        ];
    }

    public function getBranchMenuAvailability(Branch $branch): Collection
    {
        $menuItems = $this->getBranchMenu($branch, ['is_available' => true]);
        
        return $menuItems->map(function ($menuItem) use ($branch) {
            return [
                'menu_item' => $menuItem,
                'availability' => $this->getMenuItemAvailability($menuItem, $branch)
            ];
        });
    }

    public function getLowStockItems(Branch $branch): Collection
    {
        return $branch->menuItems()
            ->whereHas('branchConfigs', function ($query) use ($branch) {
                $query->where('branch_id', $branch->id)
                      ->whereNotNull('stock_quantity')
                      ->whereNotNull('min_stock_level')
                      ->whereRaw('stock_quantity <= min_stock_level');
            })
            ->with(['branchConfigs' => function ($q) use ($branch) {
                $q->where('branch_id', $branch->id);
            }])
            ->get();
    }
}
```

### 4.3 Controller

```php
<?php
// app/Http/Controllers/Api/V1/BranchMenuController.php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Http\Resources\MenuItemResource;
use App\Models\Branch;
use App\Models\MenuItem;
use App\Services\BranchMenuService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class BranchMenuController extends Controller
{
    public function __construct(
        private BranchMenuService $branchMenuService
    ) {}

    public function index(Branch $branch, Request $request): JsonResponse
    {
        $filters = $request->only(['category', 'is_available']);
        $menuItems = $this->branchMenuService->getBranchMenu($branch, $filters);
        
        return response()->json([
            'success' => true,
            'message' => 'Branch menu retrieved successfully',
            'data' => MenuItemResource::collection($menuItems)
        ]);
    }

    public function store(Request $request, Branch $branch): JsonResponse
    {
        $request->validate([
            'name' => 'required|string|max:255',
            'description' => 'string|max:1000',
            'category' => 'required|string|max:100',
            'price' => 'required|numeric|min:0',
            'is_available' => 'boolean'
        ]);
        
        $menuItem = $this->branchMenuService->createBranchMenuItem($branch, $request->validated());
        
        return response()->json([
            'success' => true,
            'message' => 'Menu item created successfully',
            'data' => new MenuItemResource($menuItem)
        ], 201);
    }

    public function getAvailability(Branch $branch, Request $request): JsonResponse
    {
        $availability = $this->branchMenuService->getBranchMenuAvailability($branch);
        
        return response()->json([
            'success' => true,
            'message' => 'Branch menu availability retrieved successfully',
            'data' => $availability
        ]);
    }

    public function updateStock(Request $request, MenuItem $menuItem, Branch $branch): JsonResponse
    {
        $request->validate([
            'quantity' => 'required|integer|min:0'
        ]);
        
        $config = $this->branchMenuService->updateMenuItemStock(
            $menuItem,
            $branch,
            $request->quantity
        );
        
        return response()->json([
            'success' => true,
            'message' => 'Menu item stock updated successfully',
            'data' => $config
        ]);
    }

    public function getLowStock(Branch $branch): JsonResponse
    {
        $lowStockItems = $this->branchMenuService->getLowStockItems($branch);
        
        return response()->json([
            'success' => true,
            'message' => 'Low stock items retrieved successfully',
            'data' => MenuItemResource::collection($lowStockItems)
        ]);
    }
}
```

## 🧪 Testing

### 4.1 Unit Tests

```php
<?php
// tests/Unit/Services/BranchMenuServiceTest.php

namespace Tests\Unit\Services;

use App\Models\Branch;
use App\Models\MenuItem;
use App\Services\BranchMenuService;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class BranchMenuServiceTest extends TestCase
{
    use RefreshDatabase;

    private BranchMenuService $branchMenuService;

    protected function setUp(): void
    {
        parent::setUp();
        $this->branchMenuService = app(BranchMenuService::class);
    }

    public function test_can_get_branch_menu(): void
    {
        $branch = Branch::factory()->create();
        MenuItem::factory()->count(3)->create(['branch_id' => $branch->id]);
        
        $menuItems = $this->branchMenuService->getBranchMenu($branch);
        
        $this->assertCount(3, $menuItems);
        $this->assertTrue($menuItems->every(fn($item) => $item->branch_id === $branch->id));
    }

    public function test_can_create_branch_menu_item(): void
    {
        $branch = Branch::factory()->create();
        $menuData = [
            'name' => 'Test Menu',
            'description' => 'Test Description',
            'category' => 'Food',
            'price' => 25.00,
            'is_available' => true
        ];
        
        $menuItem = $this->branchMenuService->createBranchMenuItem($branch, $menuData);
        
        $this->assertInstanceOf(MenuItem::class, $menuItem);
        $this->assertEquals($branch->id, $menuItem->branch_id);
        $this->assertEquals('Test Menu', $menuItem->name);
    }

    public function test_can_get_menu_item_availability(): void
    {
        $branch = Branch::factory()->create();
        $menuItem = MenuItem::factory()->create(['branch_id' => $branch->id]);
        
        $availability = $this->branchMenuService->getMenuItemAvailability($menuItem, $branch);
        
        $this->assertArrayHasKey('menu_item_id', $availability);
        $this->assertArrayHasKey('branch_id', $availability);
        $this->assertArrayHasKey('is_available', $availability);
        $this->assertArrayHasKey('price', $availability);
    }
}
```

## 📊 API Endpoints

### 4.1 Branch Menu Management

```http
GET /api/v1/branches/{branch_id}/menu
POST /api/v1/branches/{branch_id}/menu
GET /api/v1/menu-items/{menu_item_id}
PUT /api/v1/menu-items/{menu_item_id}
DELETE /api/v1/menu-items/{menu_item_id}
```

### 4.2 Menu Availability & Stock

```http
GET /api/v1/branches/{branch_id}/menu/availability
PUT /api/v1/menu-items/{menu_item_id}/branches/{branch_id}/stock
GET /api/v1/branches/{branch_id}/menu/low-stock
```

## 🎯 Success Criteria

- [ ] Menu assignment to branches working
- [ ] Branch-specific menu pricing working
- [ ] Menu availability per branch working
- [ ] Menu inventory tracking working
- [ ] Low stock alerts working
- [ ] All tests passing
- [ ] API documentation complete
- [ ] Performance optimized
- [ ] Security implemented
- [ ] Error handling complete

---

**Versi**: 1.0  
**Tanggal**: 4 September 2025  
**Status**: Planning  
**Dependencies**: Phase 7.1-7.3 Complete  
**Key Features**:

- 🍽️ **Menu Management per Branch** dengan konfigurasi khusus
- 💰 **Branch-specific Menu Pricing** untuk setiap item
- 📊 **Menu Availability & Stock Management** dengan tracking real-time
- 🚨 **Low Stock Alerts** untuk manajemen inventori
- 🧪 **Comprehensive Testing** dengan unit dan feature tests
- 📊 **API Documentation** lengkap dengan examples
- 🔒 **Security & Validation** untuk semua operasi
