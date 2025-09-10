# Point 3: Order Processing

## 📋 Overview

Implementasi sistem order processing dengan workflow creation, status management, validation, dan order history.

## 🎯 Objectives

- Order creation workflow
- Order status management
- Order validation
- Order confirmation
- Order notifications
- Order history

## 📁 Files Structure

```
phase-6/
├── 03-order-processing.md
├── app/Http/Controllers/OrderController.php
├── app/Models/Order.php
├── app/Services/OrderService.php
└── app/Jobs/ProcessOrderJob.php
```

## 🔧 Implementation Steps

### Step 1: Create Order Model

```php
<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Support\Str;

class Order extends Model
{
    use HasFactory;

    protected $fillable = [
        'order_number',
        'user_id',
        'guest_name',
        'guest_phone',
        'total_amount',
        'tax_amount',
        'discount_amount',
        'final_amount',
        'status',
        'payment_status',
        'payment_method',
        'payment_proof_path',
        'estimated_ready_time',
        'actual_ready_time',
        'delivery_location',
        'special_instructions',
    ];

    protected $casts = [
        'total_amount' => 'decimal:2',
        'tax_amount' => 'decimal:2',
        'discount_amount' => 'decimal:2',
        'final_amount' => 'decimal:2',
        'estimated_ready_time' => 'datetime',
        'actual_ready_time' => 'datetime',
    ];

    public function user()
    {
        return $this->belongsTo(User::class);
    }

    public function orderItems()
    {
        return $this->hasMany(OrderItem::class);
    }

    public function orderTracking()
    {
        return $this->hasMany(OrderTracking::class);
    }

    public function getStatusDisplayAttribute()
    {
        return match($this->status) {
            'pending' => 'Pending',
            'confirmed' => 'Confirmed',
            'preparing' => 'Preparing',
            'ready' => 'Ready',
            'delivered' => 'Delivered',
            'cancelled' => 'Cancelled',
            default => 'Unknown'
        };
    }

    public function getPaymentStatusDisplayAttribute()
    {
        return match($this->payment_status) {
            'unpaid' => 'Unpaid',
            'paid' => 'Paid',
            'refunded' => 'Refunded',
            default => 'Unknown'
        };
    }

    public function getPaymentMethodDisplayAttribute()
    {
        return match($this->payment_method) {
            'manual_transfer' => 'Manual Transfer',
            'cash' => 'Cash',
            'online' => 'Online',
            default => 'Unknown'
        };
    }

    public function getIsPendingAttribute()
    {
        return $this->status === 'pending';
    }

    public function getIsConfirmedAttribute()
    {
        return $this->status === 'confirmed';
    }

    public function getIsPreparingAttribute()
    {
        return $this->status === 'preparing';
    }

    public function getIsReadyAttribute()
    {
        return $this->status === 'ready';
    }

    public function getIsDeliveredAttribute()
    {
        return $this->status === 'delivered';
    }

    public function getIsCancelledAttribute()
    {
        return $this->status === 'cancelled';
    }

    public function getIsPaidAttribute()
    {
        return $this->payment_status === 'paid';
    }

    public function getIsUnpaidAttribute()
    {
        return $this->payment_status === 'unpaid';
    }

    public function getIsRefundedAttribute()
    {
        return $this->payment_status === 'refunded';
    }

    public function getCanBeCancelledAttribute()
    {
        return in_array($this->status, ['pending', 'confirmed']);
    }

    public function getCanBeConfirmedAttribute()
    {
        return $this->status === 'pending' && $this->payment_status === 'paid';
    }

    public function getCanBePreparedAttribute()
    {
        return $this->status === 'confirmed';
    }

    public function getCanBeMarkedReadyAttribute()
    {
        return $this->status === 'preparing';
    }

    public function getCanBeDeliveredAttribute()
    {
        return $this->status === 'ready';
    }

    public function getEstimatedPreparationTimeAttribute()
    {
        return $this->orderItems->sum(function ($item) {
            return $item->menuItem->preparation_time * $item->quantity;
        });
    }

    public function getTotalItemsAttribute()
    {
        return $this->orderItems->sum('quantity');
    }

    public function getCustomerNameAttribute()
    {
        if ($this->user) {
            return $this->user->name;
        }
        return $this->guest_name;
    }

    public function getCustomerPhoneAttribute()
    {
        if ($this->user) {
            return $this->user->phone;
        }
        return $this->guest_phone;
    }

    public function scopeByStatus($query, $status)
    {
        return $query->where('status', $status);
    }

    public function scopeByPaymentStatus($query, $paymentStatus)
    {
        return $query->where('payment_status', $paymentStatus);
    }

    public function scopeByUser($query, $userId)
    {
        return $query->where('user_id', $userId);
    }

    public function scopeByDateRange($query, $startDate, $endDate)
    {
        return $query->whereBetween('created_at', [$startDate, $endDate]);
    }

    public function scopePending($query)
    {
        return $query->where('status', 'pending');
    }

    public function scopeConfirmed($query)
    {
        return $query->where('status', 'confirmed');
    }

    public function scopePreparing($query)
    {
        return $query->where('status', 'preparing');
    }

    public function scopeReady($query)
    {
        return $query->where('status', 'ready');
    }

    public function scopeDelivered($query)
    {
        return $query->where('status', 'delivered');
    }

    public function scopeCancelled($query)
    {
        return $query->where('status', 'cancelled');
    }

    public function scopePaid($query)
    {
        return $query->where('payment_status', 'paid');
    }

    public function scopeUnpaid($query)
    {
        return $query->where('payment_status', 'unpaid');
    }

    public function scopeRecent($query, $days = 7)
    {
        return $query->where('created_at', '>=', now()->subDays($days));
    }

    public function scopeByOrderNumber($query, $orderNumber)
    {
        return $query->where('order_number', $orderNumber);
    }

    public static function generateOrderNumber()
    {
        do {
            $orderNumber = 'ORD' . date('Ymd') . str_pad(rand(1, 9999), 4, '0', STR_PAD_LEFT);
        } while (static::where('order_number', $orderNumber)->exists());

        return $orderNumber;
    }
}
```

### Step 2: Create Order Item Model

```php
<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class OrderItem extends Model
{
    use HasFactory;

    protected $fillable = [
        'order_id',
        'menu_item_id',
        'quantity',
        'unit_price',
        'total_price',
        'special_instructions',
        'status',
    ];

    protected $casts = [
        'unit_price' => 'decimal:2',
        'total_price' => 'decimal:2',
    ];

    public function order()
    {
        return $this->belongsTo(Order::class);
    }

    public function menuItem()
    {
        return $this->belongsTo(MenuItem::class);
    }

    public function getStatusDisplayAttribute()
    {
        return match($this->status) {
            'pending' => 'Pending',
            'preparing' => 'Preparing',
            'ready' => 'Ready',
            'served' => 'Served',
            default => 'Unknown'
        };
    }

    public function getIsPendingAttribute()
    {
        return $this->status === 'pending';
    }

    public function getIsPreparingAttribute()
    {
        return $this->status === 'preparing';
    }

    public function getIsReadyAttribute()
    {
        return $this->status === 'ready';
    }

    public function getIsServedAttribute()
    {
        return $this->status === 'served';
    }

    public function scopeByStatus($query, $status)
    {
        return $query->where('status', $status);
    }

    public function scopePending($query)
    {
        return $query->where('status', 'pending');
    }

    public function scopePreparing($query)
    {
        return $query->where('status', 'preparing');
    }

    public function scopeReady($query)
    {
        return $query->where('status', 'ready');
    }

    public function scopeServed($query)
    {
        return $query->where('status', 'served');
    }
}
```

### Step 3: Create Order Service

```php
<?php

namespace App\Services;

use App\Models\Order;
use App\Models\OrderItem;
use App\Models\OrderTracking;
use App\Models\MenuItem;
use App\Models\Inventory;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;

class OrderService
{
    public function createOrder($data)
    {
        return DB::transaction(function () use ($data) {
            // Validate menu items and calculate totals
            $orderData = $this->validateAndCalculateOrder($data);

            // Create order
            $order = Order::create([
                'order_number' => Order::generateOrderNumber(),
                'user_id' => $data['user_id'] ?? null,
                'guest_name' => $data['guest_name'] ?? null,
                'guest_phone' => $data['guest_phone'] ?? null,
                'total_amount' => $orderData['total_amount'],
                'tax_amount' => $orderData['tax_amount'],
                'discount_amount' => $orderData['discount_amount'],
                'final_amount' => $orderData['final_amount'],
                'delivery_location' => $data['delivery_location'] ?? null,
                'special_instructions' => $data['special_instructions'] ?? null,
                'estimated_ready_time' => now()->addMinutes($orderData['estimated_preparation_time']),
                'status' => 'pending',
                'payment_status' => 'unpaid',
                'payment_method' => $data['payment_method'] ?? 'manual_transfer',
            ]);

            // Create order items
            foreach ($orderData['items'] as $itemData) {
                OrderItem::create([
                    'order_id' => $order->id,
                    'menu_item_id' => $itemData['menu_item_id'],
                    'quantity' => $itemData['quantity'],
                    'unit_price' => $itemData['unit_price'],
                    'total_price' => $itemData['total_price'],
                    'special_instructions' => $itemData['special_instructions'] ?? null,
                    'status' => 'pending',
                ]);

                // Update inventory
                $this->updateInventory($itemData['menu_item_id'], $itemData['quantity']);
            }

            // Create initial tracking record
            OrderTracking::create([
                'order_id' => $order->id,
                'status' => 'pending',
                'notes' => 'Order created',
                'updated_by' => $data['user_id'] ?? null,
            ]);

            // Send order notification
            $this->sendOrderNotification($order, 'created');

            Log::info('Order created', [
                'order_id' => $order->id,
                'order_number' => $order->order_number,
                'user_id' => $order->user_id,
                'total_amount' => $order->total_amount,
            ]);

            return $order->load(['orderItems.menuItem', 'user']);
        });
    }

    public function updateOrderStatus($orderId, $status, $notes = null)
    {
        return DB::transaction(function () use ($orderId, $status, $notes) {
            $order = Order::findOrFail($orderId);
            $oldStatus = $order->status;

            // Validate status transition
            if (!$this->isValidStatusTransition($oldStatus, $status)) {
                throw new \Exception("Invalid status transition from {$oldStatus} to {$status}");
            }

            // Update order status
            $order->update(['status' => $status]);

            // Update order items status if applicable
            if (in_array($status, ['preparing', 'ready'])) {
                $order->orderItems()->update(['status' => $status]);
            }

            // Update actual ready time if status is ready
            if ($status === 'ready' && !$order->actual_ready_time) {
                $order->update(['actual_ready_time' => now()]);
            }

            // Create tracking record
            OrderTracking::create([
                'order_id' => $order->id,
                'status' => $status,
                'notes' => $notes,
                'updated_by' => auth()->id(),
            ]);

            // Send status notification
            $this->sendOrderNotification($order, 'status_updated', [
                'old_status' => $oldStatus,
                'new_status' => $status,
            ]);

            Log::info('Order status updated', [
                'order_id' => $order->id,
                'order_number' => $order->order_number,
                'old_status' => $oldStatus,
                'new_status' => $status,
                'updated_by' => auth()->id(),
            ]);

            return $order;
        });
    }

    public function confirmOrder($orderId)
    {
        return DB::transaction(function () use ($orderId) {
            $order = Order::findOrFail($orderId);

            if (!$order->can_be_confirmed) {
                throw new \Exception('Order cannot be confirmed');
            }

            $order->update(['status' => 'confirmed']);

            // Create tracking record
            OrderTracking::create([
                'order_id' => $order->id,
                'status' => 'confirmed',
                'notes' => 'Order confirmed by admin',
                'updated_by' => auth()->id(),
            ]);

            // Send confirmation notification
            $this->sendOrderNotification($order, 'confirmed');

            return $order;
        });
    }

    public function cancelOrder($orderId, $reason = null)
    {
        return DB::transaction(function () use ($orderId, $reason) {
            $order = Order::findOrFail($orderId);

            if (!$order->can_be_cancelled) {
                throw new \Exception('Order cannot be cancelled');
            }

            // Restore inventory
            foreach ($order->orderItems as $item) {
                $this->restoreInventory($item->menu_item_id, $item->quantity);
            }

            $order->update(['status' => 'cancelled']);

            // Create tracking record
            OrderTracking::create([
                'order_id' => $order->id,
                'status' => 'cancelled',
                'notes' => $reason ? "Order cancelled: {$reason}" : 'Order cancelled',
                'updated_by' => auth()->id(),
            ]);

            // Send cancellation notification
            $this->sendOrderNotification($order, 'cancelled', ['reason' => $reason]);

            return $order;
        });
    }

    public function updatePaymentStatus($orderId, $paymentStatus, $paymentProofPath = null)
    {
        return DB::transaction(function () use ($orderId, $paymentStatus, $paymentProofPath) {
            $order = Order::findOrFail($orderId);

            $updateData = ['payment_status' => $paymentStatus];
            if ($paymentProofPath) {
                $updateData['payment_proof_path'] = $paymentProofPath;
            }

            $order->update($updateData);

            // Create tracking record
            OrderTracking::create([
                'order_id' => $order->id,
                'status' => $order->status,
                'notes' => "Payment status updated to {$paymentStatus}",
                'updated_by' => auth()->id(),
            ]);

            // Auto-confirm order if payment is confirmed and order is pending
            if ($paymentStatus === 'paid' && $order->status === 'pending') {
                $this->confirmOrder($orderId);
            }

            return $order;
        });
    }

    public function getOrders($filters = [])
    {
        $query = Order::with(['orderItems.menuItem', 'user']);

        // Apply filters
        if (isset($filters['status'])) {
            $query->where('status', $filters['status']);
        }

        if (isset($filters['payment_status'])) {
            $query->where('payment_status', $filters['payment_status']);
        }

        if (isset($filters['user_id'])) {
            $query->where('user_id', $filters['user_id']);
        }

        if (isset($filters['start_date']) && isset($filters['end_date'])) {
            $query->whereBetween('created_at', [$filters['start_date'], $filters['end_date']]);
        }

        if (isset($filters['order_number'])) {
            $query->where('order_number', 'like', "%{$filters['order_number']}%");
        }

        return $query->orderBy('created_at', 'desc')->paginate($filters['per_page'] ?? 15);
    }

    public function getOrderDetails($orderId)
    {
        return Order::with([
            'orderItems.menuItem',
            'user',
            'orderTracking' => function ($query) {
                $query->orderBy('created_at', 'desc');
            }
        ])->findOrFail($orderId);
    }

    public function getOrderStats($filters = [])
    {
        $query = Order::query();

        if (isset($filters['start_date']) && isset($filters['end_date'])) {
            $query->whereBetween('created_at', [$filters['start_date'], $filters['end_date']]);
        }

        $stats = [
            'total_orders' => $query->count(),
            'pending_orders' => $query->clone()->pending()->count(),
            'confirmed_orders' => $query->clone()->confirmed()->count(),
            'preparing_orders' => $query->clone()->preparing()->count(),
            'ready_orders' => $query->clone()->ready()->count(),
            'delivered_orders' => $query->clone()->delivered()->count(),
            'cancelled_orders' => $query->clone()->cancelled()->count(),
            'paid_orders' => $query->clone()->paid()->count(),
            'unpaid_orders' => $query->clone()->unpaid()->count(),
            'total_revenue' => $query->clone()->paid()->sum('final_amount'),
            'average_order_value' => $query->clone()->paid()->avg('final_amount'),
        ];

        return $stats;
    }

    public function getOrderAnalytics($filters = [])
    {
        $query = Order::query();

        if (isset($filters['start_date']) && isset($filters['end_date'])) {
            $query->whereBetween('created_at', [$filters['start_date'], $filters['end_date']]);
        }

        $analytics = [
            'order_trends' => $this->getOrderTrends($query->clone()),
            'status_distribution' => $this->getStatusDistribution($query->clone()),
            'payment_methods' => $this->getPaymentMethods($query->clone()),
            'top_menu_items' => $this->getTopMenuItems($query->clone()),
            'average_preparation_time' => $this->getAveragePreparationTime($query->clone()),
        ];

        return $analytics;
    }

    protected function validateAndCalculateOrder($data)
    {
        $items = [];
        $totalAmount = 0;
        $estimatedPreparationTime = 0;

        foreach ($data['items'] as $itemData) {
            $menuItem = MenuItem::findOrFail($itemData['menu_item_id']);

            if (!$menuItem->is_available) {
                throw new \Exception("Menu item {$menuItem->name} is not available");
            }

            // Check inventory
            if ($menuItem->inventory && $menuItem->inventory->current_stock < $itemData['quantity']) {
                throw new \Exception("Insufficient stock for {$menuItem->name}");
            }

            $unitPrice = $menuItem->price;
            $totalPrice = $unitPrice * $itemData['quantity'];

            $items[] = [
                'menu_item_id' => $menuItem->id,
                'quantity' => $itemData['quantity'],
                'unit_price' => $unitPrice,
                'total_price' => $totalPrice,
                'special_instructions' => $itemData['special_instructions'] ?? null,
            ];

            $totalAmount += $totalPrice;
            $estimatedPreparationTime += $menuItem->preparation_time * $itemData['quantity'];
        }

        // Calculate tax and discount
        $taxAmount = $totalAmount * 0.1; // 10% tax
        $discountAmount = $data['discount_amount'] ?? 0;
        $finalAmount = $totalAmount + $taxAmount - $discountAmount;

        return [
            'items' => $items,
            'total_amount' => $totalAmount,
            'tax_amount' => $taxAmount,
            'discount_amount' => $discountAmount,
            'final_amount' => $finalAmount,
            'estimated_preparation_time' => $estimatedPreparationTime,
        ];
    }

    protected function updateInventory($menuItemId, $quantity)
    {
        $inventory = Inventory::where('menu_item_id', $menuItemId)->first();
        if ($inventory) {
            $inventory->decrement('current_stock', $quantity);
        }
    }

    protected function restoreInventory($menuItemId, $quantity)
    {
        $inventory = Inventory::where('menu_item_id', $menuItemId)->first();
        if ($inventory) {
            $inventory->increment('current_stock', $quantity);
        }
    }

    protected function isValidStatusTransition($fromStatus, $toStatus)
    {
        $validTransitions = [
            'pending' => ['confirmed', 'cancelled'],
            'confirmed' => ['preparing', 'cancelled'],
            'preparing' => ['ready', 'cancelled'],
            'ready' => ['delivered'],
            'delivered' => [],
            'cancelled' => [],
        ];

        return in_array($toStatus, $validTransitions[$fromStatus] ?? []);
    }

    protected function sendOrderNotification($order, $type, $data = [])
    {
        // Implement notification logic
        Log::info('Order notification sent', [
            'order_id' => $order->id,
            'order_number' => $order->order_number,
            'type' => $type,
            'data' => $data,
        ]);
    }

    protected function getOrderTrends($query)
    {
        $startDate = now()->subDays(30);
        $endDate = now();

        $trends = [];
        $currentDate = $startDate->copy();

        while ($currentDate->lte($endDate)) {
            $date = $currentDate->format('Y-m-d');

            $dayStats = [
                'date' => $date,
                'total_orders' => $query->clone()->whereDate('created_at', $date)->count(),
                'total_revenue' => $query->clone()->whereDate('created_at', $date)->paid()->sum('final_amount'),
            ];

            $trends[] = $dayStats;
            $currentDate->addDay();
        }

        return $trends;
    }

    protected function getStatusDistribution($query)
    {
        return $query->selectRaw('status, COUNT(*) as count')
            ->groupBy('status')
            ->get()
            ->map(function ($item) {
                return [
                    'status' => $item->status,
                    'count' => $item->count,
                    'percentage' => round(($item->count / $query->count()) * 100, 2),
                ];
            });
    }

    protected function getPaymentMethods($query)
    {
        return $query->selectRaw('payment_method, COUNT(*) as count')
            ->groupBy('payment_method')
            ->get()
            ->map(function ($item) {
                return [
                    'method' => $item->payment_method,
                    'count' => $item->count,
                    'percentage' => round(($item->count / $query->count()) * 100, 2),
                ];
            });
    }

    protected function getTopMenuItems($query)
    {
        return OrderItem::whereIn('order_id', $query->pluck('id'))
            ->with('menuItem')
            ->selectRaw('menu_item_id, SUM(quantity) as total_quantity, SUM(total_price) as total_revenue')
            ->groupBy('menu_item_id')
            ->orderBy('total_quantity', 'desc')
            ->limit(10)
            ->get()
            ->map(function ($item) {
                return [
                    'menu_item_id' => $item->menu_item_id,
                    'menu_item_name' => $item->menuItem->name,
                    'total_quantity' => $item->total_quantity,
                    'total_revenue' => $item->total_revenue,
                ];
            });
    }

    protected function getAveragePreparationTime($query)
    {
        $orders = $query->whereNotNull('actual_ready_time')->get();

        if ($orders->isEmpty()) {
            return 0;
        }

        $totalMinutes = $orders->sum(function ($order) {
            return $order->created_at->diffInMinutes($order->actual_ready_time);
        });

        return round($totalMinutes / $orders->count());
    }
}
```

## 📚 API Endpoints

### Order Processing Endpoints

```
GET    /api/orders
POST   /api/orders
GET    /api/orders/{id}
PUT    /api/orders/{id}
DELETE /api/orders/{id}
POST   /api/orders/{id}/confirm
POST   /api/orders/{id}/cancel
POST   /api/orders/{id}/upload-proof
GET    /api/orders/{id}/receipt
GET    /api/admin/orders
PUT    /api/admin/orders/{id}/status
GET    /api/admin/orders/stats
GET    /api/admin/orders/analytics
```

## 🧪 Testing

### OrderTest.php

```php
<?php

use App\Models\Order;
use App\Models\MenuItem;
use App\Services\OrderService;

describe('Order Processing', function () {

    beforeEach(function () {
        $this->orderService = app(OrderService::class);
    });

    it('can create order', function () {
        $menuItem = MenuItem::factory()->create(['is_available' => true]);

        $order = $this->orderService->createOrder([
            'user_id' => 1,
            'items' => [
                [
                    'menu_item_id' => $menuItem->id,
                    'quantity' => 2,
                    'unit_price' => $menuItem->price,
                ]
            ],
            'delivery_location' => 'Pool Area',
        ]);

        expect($order->order_number)->not->toBeNull();
        expect($order->status)->toBe('pending');
        expect($order->payment_status)->toBe('unpaid');
        expect($order->orderItems)->toHaveCount(1);
    });

    it('can update order status', function () {
        $order = Order::factory()->create(['status' => 'pending']);

        $updatedOrder = $this->orderService->updateOrderStatus($order->id, 'confirmed');

        expect($updatedOrder->status)->toBe('confirmed');
    });

    it('can confirm order', function () {
        $order = Order::factory()->create([
            'status' => 'pending',
            'payment_status' => 'paid'
        ]);

        $confirmedOrder = $this->orderService->confirmOrder($order->id);

        expect($confirmedOrder->status)->toBe('confirmed');
    });

    it('can cancel order', function () {
        $order = Order::factory()->create(['status' => 'pending']);

        $cancelledOrder = $this->orderService->cancelOrder($order->id, 'Customer request');

        expect($cancelledOrder->status)->toBe('cancelled');
    });

    it('can update payment status', function () {
        $order = Order::factory()->create(['payment_status' => 'unpaid']);

        $updatedOrder = $this->orderService->updatePaymentStatus($order->id, 'paid');

        expect($updatedOrder->payment_status)->toBe('paid');
    });

    it('cannot create order with unavailable menu item', function () {
        $menuItem = MenuItem::factory()->create(['is_available' => false]);

        expect(function () use ($menuItem) {
            $this->orderService->createOrder([
                'items' => [
                    [
                        'menu_item_id' => $menuItem->id,
                        'quantity' => 1,
                        'unit_price' => $menuItem->price,
                    ]
                ]
            ]);
        })->toThrow(Exception::class, 'Menu item is not available');
    });

    it('cannot update to invalid status', function () {
        $order = Order::factory()->create(['status' => 'delivered']);

        expect(function () use ($order) {
            $this->orderService->updateOrderStatus($order->id, 'pending');
        })->toThrow(Exception::class, 'Invalid status transition');
    });

    it('can get order statistics', function () {
        Order::factory()->count(5)->create();
        actingAsAdmin();

        $response = apiGet('/api/admin/orders/stats');

        assertApiSuccess($response, 'Order statistics retrieved successfully');
        expect($response->json('data.total_orders'))->toBe(5);
    });
});
```

## ✅ Success Criteria

- [x] Order creation workflow berfungsi
- [x] Order status management berjalan
- [x] Order validation berfungsi
- [x] Order confirmation berjalan
- [x] Order notifications berfungsi
- [x] Order history berjalan
- [x] Testing coverage > 90%

## 📚 Documentation

- [Laravel Database Transactions](https://laravel.com/docs/11.x/database#database-transactions)
- [Laravel Eloquent Relationships](https://laravel.com/docs/11.x/eloquent-relationships)
- [Laravel Events](https://laravel.com/docs/11.x/events)
