# Point 4: Inventory Management

## 📋 Overview

Implementasi sistem inventory management dengan stock tracking, alerts, adjustments, dan analytics.

## 🎯 Objectives

- Stock tracking
- Stock alerts
- Stock adjustments
- Stock history
- Stock analytics
- Stock optimization

## 📁 Files Structure

```
phase-6/
├── 04-inventory-management.md
├── app/Http/Controllers/InventoryController.php
├── app/Models/Inventory.php
├── app/Services/InventoryService.php
└── app/Jobs/UpdateStockJob.php
```

## 🔧 Implementation Steps

### Step 1: Create Inventory Model

```php
<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Inventory extends Model
{
    use HasFactory;

    protected $fillable = [
        'menu_item_id',
        'current_stock',
        'min_stock_level',
        'max_stock_level',
        'unit',
        'cost_per_unit',
        'supplier',
        'last_restocked_at',
    ];

    protected $casts = [
        'current_stock' => 'integer',
        'min_stock_level' => 'integer',
        'max_stock_level' => 'integer',
        'cost_per_unit' => 'decimal:2',
        'last_restocked_at' => 'datetime',
    ];

    public function menuItem()
    {
        return $this->belongsTo(MenuItem::class);
    }

    public function inventoryLogs()
    {
        return $this->hasMany(InventoryLog::class);
    }

    public function getIsLowStockAttribute()
    {
        return $this->current_stock <= $this->min_stock_level;
    }

    public function getIsOutOfStockAttribute()
    {
        return $this->current_stock <= 0;
    }

    public function getIsOverstockedAttribute()
    {
        return $this->max_stock_level && $this->current_stock > $this->max_stock_level;
    }

    public function getStockStatusAttribute()
    {
        if ($this->is_out_of_stock) {
            return 'out_of_stock';
        } elseif ($this->is_low_stock) {
            return 'low_stock';
        } elseif ($this->is_overstocked) {
            return 'overstocked';
        } else {
            return 'normal';
        }
    }

    public function getStockStatusDisplayAttribute()
    {
        return match($this->stock_status) {
            'out_of_stock' => 'Out of Stock',
            'low_stock' => 'Low Stock',
            'overstocked' => 'Overstocked',
            'normal' => 'Normal',
            default => 'Unknown'
        };
    }

    public function getStockPercentageAttribute()
    {
        if (!$this->max_stock_level) {
            return 0;
        }
        return round(($this->current_stock / $this->max_stock_level) * 100, 2);
    }

    public function getDaysSinceLastRestockAttribute()
    {
        if (!$this->last_restocked_at) {
            return null;
        }
        return $this->last_restocked_at->diffInDays(now());
    }

    public function getTotalValueAttribute()
    {
        return $this->current_stock * $this->cost_per_unit;
    }

    public function getReorderQuantityAttribute()
    {
        if (!$this->max_stock_level) {
            return $this->min_stock_level * 2;
        }
        return $this->max_stock_level - $this->current_stock;
    }

    public function scopeLowStock($query)
    {
        return $query->whereRaw('current_stock <= min_stock_level');
    }

    public function scopeOutOfStock($query)
    {
        return $query->where('current_stock', '<=', 0);
    }

    public function scopeOverstocked($query)
    {
        return $query->whereNotNull('max_stock_level')
            ->whereRaw('current_stock > max_stock_level');
    }

    public function scopeNormalStock($query)
    {
        return $query->whereRaw('current_stock > min_stock_level')
            ->where(function ($q) {
                $q->whereNull('max_stock_level')
                  ->orWhereRaw('current_stock <= max_stock_level');
            });
    }

    public function scopeByMenuItem($query, $menuItemId)
    {
        return $query->where('menu_item_id', $menuItemId);
    }

    public function scopeBySupplier($query, $supplier)
    {
        return $query->where('supplier', $supplier);
    }

    public function scopeNeedsRestock($query)
    {
        return $query->whereRaw('current_stock <= min_stock_level');
    }

    public function scopeRecentlyRestocked($query, $days = 7)
    {
        return $query->where('last_restocked_at', '>=', now()->subDays($days));
    }
}
```

### Step 2: Create Inventory Log Model

```php
<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class InventoryLog extends Model
{
    use HasFactory;

    protected $fillable = [
        'inventory_id',
        'action_type',
        'quantity',
        'previous_stock',
        'new_stock',
        'reference_type',
        'reference_id',
        'notes',
        'created_by',
    ];

    protected $casts = [
        'quantity' => 'integer',
        'previous_stock' => 'integer',
        'new_stock' => 'integer',
    ];

    public function inventory()
    {
        return $this->belongsTo(Inventory::class);
    }

    public function user()
    {
        return $this->belongsTo(User::class, 'created_by');
    }

    public function getActionTypeDisplayAttribute()
    {
        return match($this->action_type) {
            'restock' => 'Restock',
            'sale' => 'Sale',
            'adjustment' => 'Adjustment',
            'wastage' => 'Wastage',
            'transfer' => 'Transfer',
            'return' => 'Return',
            default => 'Unknown'
        };
    }

    public function getReferenceTypeDisplayAttribute()
    {
        return match($this->reference_type) {
            'order' => 'Order',
            'manual' => 'Manual',
            'system' => 'System',
            'transfer' => 'Transfer',
            default => 'Unknown'
        };
    }

    public function getStockChangeAttribute()
    {
        return $this->new_stock - $this->previous_stock;
    }

    public function getIsIncreaseAttribute()
    {
        return $this->stock_change > 0;
    }

    public function getIsDecreaseAttribute()
    {
        return $this->stock_change < 0;
    }

    public function scopeByActionType($query, $actionType)
    {
        return $query->where('action_type', $actionType);
    }

    public function scopeByReferenceType($query, $referenceType)
    {
        return $query->where('reference_type', $referenceType);
    }

    public function scopeByUser($query, $userId)
    {
        return $query->where('created_by', $userId);
    }

    public function scopeIncreases($query)
    {
        return $query->whereRaw('new_stock > previous_stock');
    }

    public function scopeDecreases($query)
    {
        return $query->whereRaw('new_stock < previous_stock');
    }

    public function scopeRecent($query, $days = 30)
    {
        return $query->where('created_at', '>=', now()->subDays($days));
    }

    public function scopeByDateRange($query, $startDate, $endDate)
    {
        return $query->whereBetween('created_at', [$startDate, $endDate]);
    }
}
```

### Step 3: Create Inventory Service

```php
<?php

namespace App\Services;

use App\Models\Inventory;
use App\Models\InventoryLog;
use App\Models\MenuItem;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;

class InventoryService
{
    public function createInventory($data)
    {
        return DB::transaction(function () use ($data) {
            $inventory = Inventory::create($data);

            // Create initial log
            InventoryLog::create([
                'inventory_id' => $inventory->id,
                'action_type' => 'restock',
                'quantity' => $data['current_stock'] ?? 0,
                'previous_stock' => 0,
                'new_stock' => $data['current_stock'] ?? 0,
                'reference_type' => 'manual',
                'notes' => 'Initial inventory setup',
                'created_by' => auth()->id(),
            ]);

            Log::info('Inventory created', [
                'inventory_id' => $inventory->id,
                'menu_item_id' => $inventory->menu_item_id,
                'initial_stock' => $inventory->current_stock,
            ]);

            return $inventory;
        });
    }

    public function updateStock($inventoryId, $actionType, $quantity, $notes = null, $referenceType = 'manual', $referenceId = null)
    {
        return DB::transaction(function () use ($inventoryId, $actionType, $quantity, $notes, $referenceType, $referenceId) {
            $inventory = Inventory::findOrFail($inventoryId);
            $previousStock = $inventory->current_stock;

            // Calculate new stock based on action type
            $newStock = $this->calculateNewStock($previousStock, $actionType, $quantity);

            // Validate stock level
            if ($newStock < 0) {
                throw new \Exception('Insufficient stock for this operation');
            }

            // Update inventory
            $updateData = ['current_stock' => $newStock];

            if ($actionType === 'restock') {
                $updateData['last_restocked_at'] = now();
            }

            $inventory->update($updateData);

            // Create inventory log
            InventoryLog::create([
                'inventory_id' => $inventory->id,
                'action_type' => $actionType,
                'quantity' => $quantity,
                'previous_stock' => $previousStock,
                'new_stock' => $newStock,
                'reference_type' => $referenceType,
                'reference_id' => $referenceId,
                'notes' => $notes,
                'created_by' => auth()->id(),
            ]);

            // Check for low stock alerts
            $this->checkLowStockAlert($inventory);

            Log::info('Stock updated', [
                'inventory_id' => $inventory->id,
                'action_type' => $actionType,
                'quantity' => $quantity,
                'previous_stock' => $previousStock,
                'new_stock' => $newStock,
                'updated_by' => auth()->id(),
            ]);

            return $inventory;
        });
    }

    public function restockInventory($inventoryId, $quantity, $notes = null, $supplier = null)
    {
        return DB::transaction(function () use ($inventoryId, $quantity, $notes, $supplier) {
            $inventory = Inventory::findOrFail($inventoryId);

            // Update supplier if provided
            if ($supplier) {
                $inventory->update(['supplier' => $supplier]);
            }

            return $this->updateStock($inventoryId, 'restock', $quantity, $notes, 'manual');
        });
    }

    public function adjustStock($inventoryId, $newStock, $notes = null)
    {
        return DB::transaction(function () use ($inventoryId, $newStock, $notes) {
            $inventory = Inventory::findOrFail($inventoryId);
            $previousStock = $inventory->current_stock;
            $adjustment = $newStock - $previousStock;

            if ($adjustment == 0) {
                return $inventory;
            }

            $actionType = $adjustment > 0 ? 'adjustment' : 'adjustment';
            $quantity = abs($adjustment);

            return $this->updateStock($inventoryId, $actionType, $quantity, $notes, 'manual');
        });
    }

    public function recordSale($inventoryId, $quantity, $orderId = null)
    {
        return $this->updateStock($inventoryId, 'sale', $quantity, 'Sale recorded', 'order', $orderId);
    }

    public function recordWastage($inventoryId, $quantity, $notes = null)
    {
        return $this->updateStock($inventoryId, 'wastage', $quantity, $notes, 'manual');
    }

    public function getInventoryItems($filters = [])
    {
        $query = Inventory::with(['menuItem', 'inventoryLogs' => function ($q) {
            $q->latest()->limit(5);
        }]);

        // Apply filters
        if (isset($filters['status'])) {
            switch ($filters['status']) {
                case 'low_stock':
                    $query->lowStock();
                    break;
                case 'out_of_stock':
                    $query->outOfStock();
                    break;
                case 'overstocked':
                    $query->overstocked();
                    break;
                case 'normal':
                    $query->normalStock();
                    break;
            }
        }

        if (isset($filters['menu_item_id'])) {
            $query->where('menu_item_id', $filters['menu_item_id']);
        }

        if (isset($filters['supplier'])) {
            $query->where('supplier', $filters['supplier']);
        }

        if (isset($filters['needs_restock']) && $filters['needs_restock']) {
            $query->needsRestock();
        }

        return $query->orderBy('current_stock', 'asc')->paginate($filters['per_page'] ?? 15);
    }

    public function getLowStockAlerts()
    {
        return Inventory::with('menuItem')
            ->lowStock()
            ->orderBy('current_stock', 'asc')
            ->get()
            ->map(function ($inventory) {
                return [
                    'inventory_id' => $inventory->id,
                    'menu_item_name' => $inventory->menuItem->name,
                    'current_stock' => $inventory->current_stock,
                    'min_stock_level' => $inventory->min_stock_level,
                    'stock_deficit' => $inventory->min_stock_level - $inventory->current_stock,
                    'reorder_quantity' => $inventory->reorder_quantity,
                    'supplier' => $inventory->supplier,
                ];
            });
    }

    public function getInventoryStats($filters = [])
    {
        $query = Inventory::query();

        $stats = [
            'total_items' => $query->count(),
            'low_stock_items' => $query->clone()->lowStock()->count(),
            'out_of_stock_items' => $query->clone()->outOfStock()->count(),
            'overstocked_items' => $query->clone()->overstocked()->count(),
            'normal_stock_items' => $query->clone()->normalStock()->count(),
            'total_inventory_value' => $query->clone()->sum(DB::raw('current_stock * cost_per_unit')),
            'average_stock_level' => $query->clone()->avg('current_stock'),
            'items_needing_restock' => $query->clone()->needsRestock()->count(),
        ];

        return $stats;
    }

    public function getInventoryAnalytics($filters = [])
    {
        $query = Inventory::query();

        if (isset($filters['start_date']) && isset($filters['end_date'])) {
            $query->whereHas('inventoryLogs', function ($q) use ($filters) {
                $q->whereBetween('created_at', [$filters['start_date'], $filters['end_date']]);
            });
        }

        $analytics = [
            'stock_movements' => $this->getStockMovements($query->clone()),
            'top_moving_items' => $this->getTopMovingItems($query->clone()),
            'wastage_analytics' => $this->getWastageAnalytics($query->clone()),
            'restock_analytics' => $this->getRestockAnalytics($query->clone()),
            'supplier_performance' => $this->getSupplierPerformance($query->clone()),
        ];

        return $analytics;
    }

    public function bulkRestock($inventoryData)
    {
        $results = [];

        foreach ($inventoryData as $data) {
            try {
                $inventory = $this->restockInventory(
                    $data['inventory_id'],
                    $data['quantity'],
                    $data['notes'] ?? null,
                    $data['supplier'] ?? null
                );

                $results[] = [
                    'inventory_id' => $data['inventory_id'],
                    'success' => true,
                    'new_stock' => $inventory->current_stock,
                ];
            } catch (\Exception $e) {
                $results[] = [
                    'inventory_id' => $data['inventory_id'],
                    'success' => false,
                    'error' => $e->getMessage(),
                ];
            }
        }

        return $results;
    }

    public function generateRestockReport()
    {
        $lowStockItems = $this->getLowStockAlerts();

        return [
            'report_date' => now()->format('Y-m-d H:i:s'),
            'total_items_needing_restock' => $lowStockItems->count(),
            'estimated_restock_cost' => $lowStockItems->sum(function ($item) {
                $inventory = Inventory::find($item['inventory_id']);
                return $item['reorder_quantity'] * $inventory->cost_per_unit;
            }),
            'items' => $lowStockItems,
        ];
    }

    protected function calculateNewStock($currentStock, $actionType, $quantity)
    {
        return match($actionType) {
            'restock', 'return', 'adjustment' => $currentStock + $quantity,
            'sale', 'wastage', 'transfer' => $currentStock - $quantity,
            default => $currentStock
        };
    }

    protected function checkLowStockAlert($inventory)
    {
        if ($inventory->is_low_stock) {
            // Send low stock alert
            Log::warning('Low stock alert', [
                'inventory_id' => $inventory->id,
                'menu_item_name' => $inventory->menuItem->name,
                'current_stock' => $inventory->current_stock,
                'min_stock_level' => $inventory->min_stock_level,
            ]);
        }
    }

    protected function getStockMovements($query)
    {
        $startDate = now()->subDays(30);
        $endDate = now();

        $movements = [];
        $currentDate = $startDate->copy();

        while ($currentDate->lte($endDate)) {
            $date = $currentDate->format('Y-m-d');

            $dayStats = [
                'date' => $date,
                'restocks' => InventoryLog::whereDate('created_at', $date)
                    ->where('action_type', 'restock')
                    ->sum('quantity'),
                'sales' => InventoryLog::whereDate('created_at', $date)
                    ->where('action_type', 'sale')
                    ->sum('quantity'),
                'wastage' => InventoryLog::whereDate('created_at', $date)
                    ->where('action_type', 'wastage')
                    ->sum('quantity'),
            ];

            $movements[] = $dayStats;
            $currentDate->addDay();
        }

        return $movements;
    }

    protected function getTopMovingItems($query)
    {
        return InventoryLog::whereIn('inventory_id', $query->pluck('id'))
            ->with('inventory.menuItem')
            ->selectRaw('inventory_id, SUM(quantity) as total_movement')
            ->groupBy('inventory_id')
            ->orderBy('total_movement', 'desc')
            ->limit(10)
            ->get()
            ->map(function ($log) {
                return [
                    'inventory_id' => $log->inventory_id,
                    'menu_item_name' => $log->inventory->menuItem->name,
                    'total_movement' => $log->total_movement,
                ];
            });
    }

    protected function getWastageAnalytics($query)
    {
        $wastageLogs = InventoryLog::whereIn('inventory_id', $query->pluck('id'))
            ->where('action_type', 'wastage')
            ->get();

        return [
            'total_wastage' => $wastageLogs->sum('quantity'),
            'wastage_by_item' => $wastageLogs->groupBy('inventory_id')
                ->map(function ($logs) {
                    $inventory = Inventory::find($logs->first()->inventory_id);
                    return [
                        'menu_item_name' => $inventory->menuItem->name,
                        'total_wastage' => $logs->sum('quantity'),
                        'wastage_cost' => $logs->sum('quantity') * $inventory->cost_per_unit,
                    ];
                }),
        ];
    }

    protected function getRestockAnalytics($query)
    {
        $restockLogs = InventoryLog::whereIn('inventory_id', $query->pluck('id'))
            ->where('action_type', 'restock')
            ->get();

        return [
            'total_restocks' => $restockLogs->count(),
            'total_restock_quantity' => $restockLogs->sum('quantity'),
            'total_restock_cost' => $restockLogs->sum(function ($log) {
                $inventory = Inventory::find($log->inventory_id);
                return $log->quantity * $inventory->cost_per_unit;
            }),
            'average_restock_quantity' => $restockLogs->avg('quantity'),
        ];
    }

    protected function getSupplierPerformance($query)
    {
        return Inventory::whereNotNull('supplier')
            ->selectRaw('supplier, COUNT(*) as item_count, SUM(current_stock * cost_per_unit) as total_value')
            ->groupBy('supplier')
            ->orderBy('total_value', 'desc')
            ->get()
            ->map(function ($inventory) {
                return [
                    'supplier' => $inventory->supplier,
                    'item_count' => $inventory->item_count,
                    'total_value' => $inventory->total_value,
                ];
            });
    }
}
```

## 📚 API Endpoints

### Inventory Management Endpoints

```
GET    /api/admin/inventory
POST   /api/admin/inventory
GET    /api/admin/inventory/{id}
PUT    /api/admin/inventory/{id}
POST   /api/admin/inventory/{id}/restock
POST   /api/admin/inventory/{id}/adjust
POST   /api/admin/inventory/{id}/wastage
GET    /api/admin/inventory/alerts
GET    /api/admin/inventory/stats
GET    /api/admin/inventory/analytics
POST   /api/admin/inventory/bulk-restock
GET    /api/admin/inventory/restock-report
```

## 🧪 Testing

### InventoryTest.php

```php
<?php

use App\Models\Inventory;
use App\Models\MenuItem;
use App\Services\InventoryService;

describe('Inventory Management', function () {

    beforeEach(function () {
        $this->inventoryService = app(InventoryService::class);
    });

    it('can create inventory', function () {
        $menuItem = MenuItem::factory()->create();

        $inventory = $this->inventoryService->createInventory([
            'menu_item_id' => $menuItem->id,
            'current_stock' => 100,
            'min_stock_level' => 10,
            'max_stock_level' => 200,
            'unit' => 'pcs',
            'cost_per_unit' => 5000,
        ]);

        expect($inventory->menu_item_id)->toBe($menuItem->id);
        expect($inventory->current_stock)->toBe(100);
        expect($inventory->is_low_stock)->toBeFalse();
    });

    it('can update stock', function () {
        $inventory = Inventory::factory()->create(['current_stock' => 50]);

        $updatedInventory = $this->inventoryService->updateStock($inventory->id, 'restock', 30);

        expect($updatedInventory->current_stock)->toBe(80);
    });

    it('can restock inventory', function () {
        $inventory = Inventory::factory()->create(['current_stock' => 20]);

        $restockedInventory = $this->inventoryService->restockInventory($inventory->id, 50, 'Restock from supplier');

        expect($restockedInventory->current_stock)->toBe(70);
        expect($restockedInventory->last_restocked_at)->not->toBeNull();
    });

    it('can adjust stock', function () {
        $inventory = Inventory::factory()->create(['current_stock' => 100]);

        $adjustedInventory = $this->inventoryService->adjustStock($inventory->id, 80, 'Stock adjustment');

        expect($adjustedInventory->current_stock)->toBe(80);
    });

    it('can record sale', function () {
        $inventory = Inventory::factory()->create(['current_stock' => 50]);

        $updatedInventory = $this->inventoryService->recordSale($inventory->id, 5, 123);

        expect($updatedInventory->current_stock)->toBe(45);
    });

    it('can record wastage', function () {
        $inventory = Inventory::factory()->create(['current_stock' => 30]);

        $updatedInventory = $this->inventoryService->recordWastage($inventory->id, 2, 'Expired items');

        expect($updatedInventory->current_stock)->toBe(28);
    });

    it('cannot update stock below zero', function () {
        $inventory = Inventory::factory()->create(['current_stock' => 5]);

        expect(function () use ($inventory) {
            $this->inventoryService->updateStock($inventory->id, 'sale', 10);
        })->toThrow(Exception::class, 'Insufficient stock for this operation');
    });

    it('can get low stock alerts', function () {
        Inventory::factory()->create([
            'current_stock' => 5,
            'min_stock_level' => 10
        ]);

        $alerts = $this->inventoryService->getLowStockAlerts();

        expect($alerts)->toHaveCount(1);
        expect($alerts[0]['stock_deficit'])->toBe(5);
    });

    it('can get inventory statistics', function () {
        Inventory::factory()->count(5)->create();
        actingAsAdmin();

        $response = apiGet('/api/admin/inventory/stats');

        assertApiSuccess($response, 'Inventory statistics retrieved successfully');
        expect($response->json('data.total_items'))->toBe(5);
    });

    it('can generate restock report', function () {
        Inventory::factory()->create([
            'current_stock' => 5,
            'min_stock_level' => 10,
            'cost_per_unit' => 1000
        ]);

        $report = $this->inventoryService->generateRestockReport();

        expect($report['total_items_needing_restock'])->toBe(1);
        expect($report['estimated_restock_cost'])->toBeGreaterThan(0);
    });
});
```

## ✅ Success Criteria

- [ ] Stock tracking berfungsi
- [ ] Stock alerts berjalan
- [ ] Stock adjustments berfungsi
- [ ] Stock history berjalan
- [ ] Stock analytics berfungsi
- [ ] Stock optimization berjalan
- [ ] Testing coverage > 90%

## 📚 Documentation

- [Laravel Database Transactions](https://laravel.com/docs/11.x/database#database-transactions)
- [Laravel Eloquent Relationships](https://laravel.com/docs/11.x/eloquent-relationships)
- [Laravel Jobs](https://laravel.com/docs/11.x/queues)
