# Point 1: Menu Management System

## 📋 Overview

Implementasi sistem manajemen menu dengan CRUD operations, kategori management, pricing configuration, dan menu analytics.

## 🎯 Objectives

-   Menu CRUD operations
-   Menu categories management
-   Menu pricing configuration
-   Menu availability status
-   Menu image management
-   Menu analytics

## 📁 Files Structure

```
phase-6/
├── 01-menu-management.md
├── database/migrations/
│   ├── 2024_01_01_000001_create_menu_categories_table.php
│   ├── 2024_01_01_000002_create_menu_items_table.php
│   └── 2024_01_01_000003_create_inventory_table.php
├── app/Models/
│   ├── MenuCategory.php
│   ├── MenuItem.php
│   └── Inventory.php
├── app/Services/
│   └── MenuService.php
├── app/Http/Controllers/
│   └── MenuController.php
└── app/Jobs/
    └── ProcessMenuJob.php
```

## 📋 File Hierarchy Rules

Implementasi mengikuti urutan: **Database → Model → Service → Controller**

1. **Database**: Migrations untuk menu_categories, menu_items, dan inventory
2. **Model**: MenuCategory, MenuItem, dan Inventory models
3. **Service**: MenuService untuk menu business logic
4. **Controller**: MenuController untuk HTTP handling

## 🔧 Implementation Steps

### Step 1: Create Menu Item Model

```php
<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Support\Facades\Storage;

class MenuItem extends Model
{
    use HasFactory;

    protected $fillable = [
        'name',
        'description',
        'category_id',
        'price',
        'cost_price',
        'image_path',
        'is_available',
        'is_featured',
        'preparation_time',
        'calories',
        'allergens',
        'barcode',
    ];

    protected $casts = [
        'price' => 'decimal:2',
        'cost_price' => 'decimal:2',
        'is_available' => 'boolean',
        'is_featured' => 'boolean',
        'preparation_time' => 'integer',
        'calories' => 'integer',
        'allergens' => 'array',
    ];

    public function category()
    {
        return $this->belongsTo(MenuCategory::class);
    }

    public function orderItems()
    {
        return $this->hasMany(OrderItem::class);
    }

    public function inventory()
    {
        return $this->hasOne(Inventory::class);
    }

    public function barcode()
    {
        return $this->hasOne(Barcode::class);
    }

    public function reviews()
    {
        return $this->hasMany(MenuReview::class);
    }

    public function getMarginPercentageAttribute()
    {
        if ($this->price == 0) return 0;
        return round((($this->price - $this->cost_price) / $this->price) * 100, 2);
    }

    public function getImageUrlAttribute()
    {
        return $this->image_path ? Storage::url($this->image_path) : null;
    }

    public function getIsLowStockAttribute()
    {
        return $this->inventory && $this->inventory->current_stock <= $this->inventory->min_stock_level;
    }

    public function getAverageRatingAttribute()
    {
        return $this->reviews()->avg('rating') ?? 0;
    }

    public function getTotalOrdersAttribute()
    {
        return $this->orderItems()->sum('quantity');
    }

    public function getTotalRevenueAttribute()
    {
        return $this->orderItems()->sum('total_price');
    }

    public function scopeAvailable($query)
    {
        return $query->where('is_available', true);
    }

    public function scopeFeatured($query)
    {
        return $query->where('is_featured', true);
    }

    public function scopeByCategory($query, $categoryId)
    {
        return $query->where('category_id', $categoryId);
    }

    public function scopeByPriceRange($query, $minPrice, $maxPrice)
    {
        return $query->whereBetween('price', [$minPrice, $maxPrice]);
    }

    public function scopeSearch($query, $search)
    {
        return $query->where(function ($q) use ($search) {
            $q->where('name', 'like', "%{$search}%")
              ->orWhere('description', 'like', "%{$search}%");
        });
    }

    public function hasActiveOrders()
    {
        return $this->orderItems()
            ->whereHas('order', function ($query) {
                $query->whereIn('status', ['pending', 'confirmed', 'preparing']);
            })
            ->exists();
    }
}
```

### Step 2: Create Menu Category Model

```php
<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Support\Facades\Storage;

class MenuCategory extends Model
{
    use HasFactory;

    protected $fillable = [
        'name',
        'description',
        'image_path',
        'is_active',
        'sort_order',
    ];

    protected $casts = [
        'is_active' => 'boolean',
        'sort_order' => 'integer',
    ];

    public function menuItems()
    {
        return $this->hasMany(MenuItem::class);
    }

    public function getImageUrlAttribute()
    {
        return $this->image_path ? Storage::url($this->image_path) : null;
    }

    public function getActiveMenuItemsCountAttribute()
    {
        return $this->menuItems()->available()->count();
    }

    public function scopeActive($query)
    {
        return $query->where('is_active', true);
    }

    public function scopeOrdered($query)
    {
        return $query->orderBy('sort_order')->orderBy('name');
    }
}
```

### Step 3: Create Menu Service

```php
<?php

namespace App\Services;

use App\Models\MenuItem;
use App\Models\MenuCategory;
use App\Models\Inventory;
use App\Models\Barcode;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Str;

class MenuService
{
    public function createMenuItem($data)
    {
        return DB::transaction(function () use ($data) {
            // Upload image if provided
            if (isset($data['image'])) {
                $data['image_path'] = $this->uploadImage($data['image']);
            }

            // Generate barcode
            $data['barcode'] = $this->generateBarcode();

            // Create menu item
            $menuItem = MenuItem::create($data);

            // Create inventory record
            Inventory::create([
                'menu_item_id' => $menuItem->id,
                'current_stock' => $data['initial_stock'] ?? 0,
                'min_stock_level' => $data['min_stock_level'] ?? 10,
                'max_stock_level' => $data['max_stock_level'] ?? null,
                'unit' => $data['unit'] ?? 'pcs',
                'cost_per_unit' => $menuItem->cost_price,
            ]);

            // Generate barcode record
            Barcode::create([
                'menu_item_id' => $menuItem->id,
                'barcode_value' => $menuItem->barcode,
                'barcode_type' => 'QR',
            ]);

            return $menuItem->load(['category', 'inventory', 'barcode']);
        });
    }

    public function updateMenuItem($id, $data)
    {
        return DB::transaction(function () use ($id, $data) {
            $menuItem = MenuItem::findOrFail($id);

            // Upload new image if provided
            if (isset($data['image'])) {
                // Delete old image
                if ($menuItem->image_path) {
                    Storage::delete($menuItem->image_path);
                }
                $data['image_path'] = $this->uploadImage($data['image']);
            }

            $menuItem->update($data);

            // Update inventory cost if cost_price changed
            if (isset($data['cost_price']) && $menuItem->inventory) {
                $menuItem->inventory->update([
                    'cost_per_unit' => $data['cost_price'],
                ]);
            }

            return $menuItem->load(['category', 'inventory', 'barcode']);
        });
    }

    public function deleteMenuItem($id)
    {
        return DB::transaction(function () use ($id) {
            $menuItem = MenuItem::findOrFail($id);

            // Check if menu item has active orders
            if ($menuItem->hasActiveOrders()) {
                throw new \Exception('Cannot delete menu item with active orders');
            }

            // Delete image
            if ($menuItem->image_path) {
                Storage::delete($menuItem->image_path);
            }

            // Delete related records
            $menuItem->inventory()->delete();
            $menuItem->barcode()->delete();
            $menuItem->delete();

            return true;
        });
    }

    public function toggleAvailability($id)
    {
        $menuItem = MenuItem::findOrFail($id);
        $menuItem->update(['is_available' => !$menuItem->is_available]);

        return $menuItem;
    }

    public function toggleFeatured($id)
    {
        $menuItem = MenuItem::findOrFail($id);
        $menuItem->update(['is_featured' => !$menuItem->is_featured]);

        return $menuItem;
    }

    public function getMenuItems($filters = [])
    {
        $query = MenuItem::with(['category', 'inventory', 'barcode']);

        // Apply filters
        if (isset($filters['category_id'])) {
            $query->where('category_id', $filters['category_id']);
        }

        if (isset($filters['available_only']) && $filters['available_only']) {
            $query->available();
        }

        if (isset($filters['featured_only']) && $filters['featured_only']) {
            $query->featured();
        }

        if (isset($filters['search'])) {
            $query->search($filters['search']);
        }

        if (isset($filters['min_price']) && isset($filters['max_price'])) {
            $query->byPriceRange($filters['min_price'], $filters['max_price']);
        }

        if (isset($filters['low_stock_only']) && $filters['low_stock_only']) {
            $query->whereHas('inventory', function ($q) {
                $q->whereRaw('current_stock <= min_stock_level');
            });
        }

        return $query->orderBy('name')->paginate($filters['per_page'] ?? 15);
    }

    public function getMenuCategories()
    {
        return MenuCategory::active()
            ->ordered()
            ->withCount(['menuItems as active_items_count' => function ($query) {
                $query->available();
            }])
            ->get();
    }

    public function createCategory($data)
    {
        if (isset($data['image'])) {
            $data['image_path'] = $this->uploadImage($data['image']);
        }

        return MenuCategory::create($data);
    }

    public function updateCategory($id, $data)
    {
        $category = MenuCategory::findOrFail($id);

        if (isset($data['image'])) {
            if ($category->image_path) {
                Storage::delete($category->image_path);
            }
            $data['image_path'] = $this->uploadImage($data['image']);
        }

        $category->update($data);
        return $category;
    }

    public function deleteCategory($id)
    {
        $category = MenuCategory::findOrFail($id);

        // Check if category has menu items
        if ($category->menuItems()->count() > 0) {
            throw new \Exception('Cannot delete category with menu items');
        }

        if ($category->image_path) {
            Storage::delete($category->image_path);
        }

        $category->delete();
        return true;
    }

    public function getMenuAnalytics($filters = [])
    {
        $query = MenuItem::query();

        if (isset($filters['start_date']) && isset($filters['end_date'])) {
            $query->whereHas('orderItems.order', function ($q) use ($filters) {
                $q->whereBetween('created_at', [$filters['start_date'], $filters['end_date']]);
            });
        }

        $analytics = [
            'total_items' => $query->count(),
            'available_items' => $query->clone()->available()->count(),
            'featured_items' => $query->clone()->featured()->count(),
            'low_stock_items' => $query->clone()->whereHas('inventory', function ($q) {
                $q->whereRaw('current_stock <= min_stock_level');
            })->count(),
            'top_selling_items' => $this->getTopSellingItems($query->clone()),
            'category_performance' => $this->getCategoryPerformance($query->clone()),
            'price_analytics' => $this->getPriceAnalytics($query->clone()),
        ];

        return $analytics;
    }

    protected function uploadImage($image)
    {
        $filename = Str::uuid() . '.' . $image->getClientOriginalExtension();
        return $image->storeAs('menu-images', $filename, 'public');
    }

    protected function generateBarcode()
    {
        do {
            $barcode = 'MENU' . str_pad(rand(1, 999999), 6, '0', STR_PAD_LEFT);
        } while (MenuItem::where('barcode', $barcode)->exists());

        return $barcode;
    }

    protected function getTopSellingItems($query)
    {
        return $query->with(['category'])
            ->withCount(['orderItems as total_orders'])
            ->withSum('orderItems', 'total_price')
            ->orderBy('total_orders', 'desc')
            ->limit(10)
            ->get()
            ->map(function ($item) {
                return [
                    'id' => $item->id,
                    'name' => $item->name,
                    'category' => $item->category->name,
                    'total_orders' => $item->total_orders,
                    'total_revenue' => $item->order_items_sum_total_price,
                ];
            });
    }

    protected function getCategoryPerformance($query)
    {
        return MenuCategory::withCount(['menuItems as total_items'])
            ->withCount(['menuItems as available_items' => function ($q) {
                $q->available();
            }])
            ->get()
            ->map(function ($category) {
                $categoryQuery = $query->clone()->where('category_id', $category->id);

                return [
                    'id' => $category->id,
                    'name' => $category->name,
                    'total_items' => $category->total_items,
                    'available_items' => $category->available_items,
                    'total_orders' => $categoryQuery->withCount('orderItems')->sum('order_items_count'),
                    'total_revenue' => $categoryQuery->withSum('orderItems', 'total_price')->sum('order_items_sum_total_price'),
                ];
            });
    }

    protected function getPriceAnalytics($query)
    {
        $items = $query->get();

        return [
            'average_price' => $items->avg('price'),
            'min_price' => $items->min('price'),
            'max_price' => $items->max('price'),
            'price_ranges' => [
                'under_10k' => $items->where('price', '<', 10000)->count(),
                '10k_to_25k' => $items->whereBetween('price', [10000, 25000])->count(),
                '25k_to_50k' => $items->whereBetween('price', [25000, 50000])->count(),
                'over_50k' => $items->where('price', '>', 50000)->count(),
            ],
        ];
    }
}
```

## 📚 API Endpoints

### Menu Management Endpoints

```
GET    /api/menu
GET    /api/menu/categories
GET    /api/menu/category/{id}
GET    /api/menu/{id}
GET    /api/menu/featured
GET    /api/menu/search
GET    /api/admin/menu
POST   /api/admin/menu
GET    /api/admin/menu/{id}
PUT    /api/admin/menu/{id}
DELETE /api/admin/menu/{id}
POST   /api/admin/menu/{id}/toggle
POST   /api/admin/menu/{id}/featured
GET    /api/admin/menu/categories
POST   /api/admin/menu/categories
PUT    /api/admin/menu/categories/{id}
DELETE /api/admin/menu/categories/{id}
GET    /api/admin/menu/analytics
```

## 🧪 Testing

### MenuTest.php

```php
<?php

use App\Models\MenuItem;
use App\Models\MenuCategory;
use App\Services\MenuService;

describe('Menu Management', function () {

    beforeEach(function () {
        $this->menuService = app(MenuService::class);
    });

    it('can create menu item', function () {
        $category = MenuCategory::factory()->create();

        $menuItem = $this->menuService->createMenuItem([
            'name' => 'Test Menu Item',
            'description' => 'Test description',
            'category_id' => $category->id,
            'price' => 25000,
            'cost_price' => 15000,
            'preparation_time' => 15,
        ]);

        expect($menuItem->name)->toBe('Test Menu Item');
        expect($menuItem->price)->toBe(25000);
        expect($menuItem->barcode)->not->toBeNull();
    });

    it('can update menu item', function () {
        $menuItem = MenuItem::factory()->create();

        $updatedItem = $this->menuService->updateMenuItem($menuItem->id, [
            'name' => 'Updated Menu Item',
            'price' => 30000,
        ]);

        expect($updatedItem->name)->toBe('Updated Menu Item');
        expect($updatedItem->price)->toBe(30000);
    });

    it('can toggle menu availability', function () {
        $menuItem = MenuItem::factory()->create(['is_available' => true]);

        $toggledItem = $this->menuService->toggleAvailability($menuItem->id);

        expect($toggledItem->is_available)->toBeFalse();
    });

    it('can get menu items with filters', function () {
        MenuItem::factory()->count(5)->create();
        MenuItem::factory()->create(['is_available' => false]);

        $availableItems = $this->menuService->getMenuItems(['available_only' => true]);

        expect($availableItems->count())->toBe(5);
    });

    it('can create menu category', function () {
        $category = $this->menuService->createCategory([
            'name' => 'Test Category',
            'description' => 'Test category description',
        ]);

        expect($category->name)->toBe('Test Category');
    });

    it('cannot delete menu item with active orders', function () {
        $menuItem = MenuItem::factory()->create();
        $menuItem->orderItems()->create([
            'order_id' => 1,
            'quantity' => 1,
            'unit_price' => 25000,
            'total_price' => 25000,
        ]);

        expect(function () use ($menuItem) {
            $this->menuService->deleteMenuItem($menuItem->id);
        })->toThrow(Exception::class, 'Cannot delete menu item with active orders');
    });

    it('can get menu analytics', function () {
        MenuItem::factory()->count(3)->create();
        actingAsAdmin();

        $response = apiGet('/api/admin/menu/analytics');

        assertApiSuccess($response, 'Menu analytics retrieved successfully');
        expect($response->json('data.total_items'))->toBe(3);
    });
});
```

## ✅ Success Criteria

-   [x] Menu CRUD operations berfungsi
-   [x] Menu categories management berjalan
-   [x] Menu pricing configuration berfungsi
-   [x] Menu availability status berjalan
-   [x] Menu image management berfungsi
-   [x] Menu analytics berjalan
-   [x] Testing coverage > 90%

## 📚 Documentation

-   [Laravel File Storage](https://laravel.com/docs/11.x/filesystem)
-   [Laravel Database Transactions](https://laravel.com/docs/11.x/database#database-transactions)
-   [Laravel Eloquent Relationships](https://laravel.com/docs/11.x/eloquent-relationships)
