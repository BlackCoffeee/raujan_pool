# Phase 6: Cafe System & Barcode Integration

## 📋 Overview

Implementasi sistem cafe dengan barcode integration, menu management, order processing, dan inventory tracking.

## 🎯 Objectives

- Menu management system
- Barcode generation and scanning
- Order processing workflow
- Inventory management
- Payment integration
- Order tracking system

## 📁 Files Structure

```
phase-6/
├── 01-menu-management.md
├── 02-barcode-system.md
├── 03-order-processing.md
├── 04-inventory-management.md
└── 05-order-tracking.md
```

## 🔧 Implementation Points

### Point 1: Menu Management System

**Subpoints:**

- Menu CRUD operations
- Menu categories management
- Menu pricing configuration
- Menu availability status
- Menu image management
- Menu analytics

**Files:**

- `app/Http/Controllers/MenuController.php`
- `app/Models/Menu.php`
- `app/Services/MenuService.php`
- `app/Jobs/ProcessMenuJob.php`

### Point 2: Barcode System

**Subpoints:**

- Barcode generation
- Barcode scanning
- Barcode validation
- Barcode management
- QR code generation
- Barcode analytics

**Files:**

- `app/Http/Controllers/BarcodeController.php`
- `app/Models/Barcode.php`
- `app/Services/BarcodeService.php`
- `app/Jobs/GenerateBarcodeJob.php`

### Point 3: Order Processing

**Subpoints:**

- Order creation workflow
- Order status management
- Order validation
- Order confirmation
- Order notifications
- Order history

**Files:**

- `app/Http/Controllers/OrderController.php`
- `app/Models/Order.php`
- `app/Services/OrderService.php`
- `app/Jobs/ProcessOrderJob.php`

### Point 4: Inventory Management

**Subpoints:**

- Stock tracking
- Stock alerts
- Stock adjustments
- Stock history
- Stock analytics
- Stock optimization

**Files:**

- `app/Http/Controllers/InventoryController.php`
- `app/Models/Inventory.php`
- `app/Services/InventoryService.php`
- `app/Jobs/UpdateStockJob.php`

### Point 5: Order Tracking

**Subpoints:**

- Order status tracking
- Order timeline
- Order notifications
- Order completion
- Order feedback
- Order analytics

**Files:**

- `app/Http/Controllers/OrderTrackingController.php`
- `app/Models/OrderTracking.php`
- `app/Services/TrackingService.php`
- `app/Jobs/SendOrderNotificationsJob.php`

## 📊 Database Schema

### Menu Items Table

```sql
CREATE TABLE menu_items (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT NULL,
    category_id BIGINT UNSIGNED NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    cost_price DECIMAL(10,2) NOT NULL,
    margin_percentage DECIMAL(5,2) GENERATED ALWAYS AS (((price - cost_price) / price) * 100) STORED,
    image_path VARCHAR(255) NULL,
    is_available BOOLEAN DEFAULT TRUE,
    is_featured BOOLEAN DEFAULT FALSE,
    preparation_time INT DEFAULT 15,
    calories INT NULL,
    allergens TEXT NULL,
    barcode VARCHAR(100) UNIQUE NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    FOREIGN KEY (category_id) REFERENCES menu_categories(id)
);
```

### Menu Categories Table

```sql
CREATE TABLE menu_categories (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description TEXT NULL,
    image_path VARCHAR(255) NULL,
    is_active BOOLEAN DEFAULT TRUE,
    sort_order INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);
```

### Orders Table

```sql
CREATE TABLE orders (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    order_number VARCHAR(50) UNIQUE NOT NULL,
    user_id BIGINT UNSIGNED NULL,
    guest_name VARCHAR(255) NULL,
    guest_phone VARCHAR(20) NULL,
    total_amount DECIMAL(10,2) NOT NULL,
    tax_amount DECIMAL(10,2) DEFAULT 0,
    discount_amount DECIMAL(10,2) DEFAULT 0,
    final_amount DECIMAL(10,2) NOT NULL,
    status ENUM('pending', 'confirmed', 'preparing', 'ready', 'delivered', 'cancelled') DEFAULT 'pending',
    payment_status ENUM('unpaid', 'paid', 'refunded') DEFAULT 'unpaid',
    payment_method ENUM('manual_transfer', 'cash', 'online') DEFAULT 'manual_transfer',
    payment_proof_path VARCHAR(255) NULL,
    estimated_ready_time DATETIME NULL,
    actual_ready_time DATETIME NULL,
    delivery_location VARCHAR(255) NULL,
    special_instructions TEXT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    FOREIGN KEY (user_id) REFERENCES users(id)
);
```

### Order Items Table

```sql
CREATE TABLE order_items (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    order_id BIGINT UNSIGNED NOT NULL,
    menu_item_id BIGINT UNSIGNED NOT NULL,
    quantity INT NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    total_price DECIMAL(10,2) NOT NULL,
    special_instructions TEXT NULL,
    status ENUM('pending', 'preparing', 'ready', 'served') DEFAULT 'pending',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    FOREIGN KEY (order_id) REFERENCES orders(id),
    FOREIGN KEY (menu_item_id) REFERENCES menu_items(id)
);
```

### Inventory Table

```sql
CREATE TABLE inventory (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    menu_item_id BIGINT UNSIGNED NOT NULL,
    current_stock INT NOT NULL DEFAULT 0,
    min_stock_level INT NOT NULL DEFAULT 10,
    max_stock_level INT NULL,
    unit VARCHAR(50) NOT NULL,
    cost_per_unit DECIMAL(10,2) NOT NULL,
    supplier VARCHAR(255) NULL,
    last_restocked_at DATETIME NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    FOREIGN KEY (menu_item_id) REFERENCES menu_items(id)
);
```

### Inventory Logs Table

```sql
CREATE TABLE inventory_logs (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    inventory_id BIGINT UNSIGNED NOT NULL,
    action_type ENUM('restock', 'sale', 'adjustment', 'wastage') NOT NULL,
    quantity INT NOT NULL,
    previous_stock INT NOT NULL,
    new_stock INT NOT NULL,
    reference_type ENUM('order', 'manual', 'system') DEFAULT 'manual',
    reference_id BIGINT UNSIGNED NULL,
    notes TEXT NULL,
    created_by BIGINT UNSIGNED NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (inventory_id) REFERENCES inventory(id),
    FOREIGN KEY (created_by) REFERENCES users(id)
);
```

### Barcodes Table

```sql
CREATE TABLE barcodes (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    menu_item_id BIGINT UNSIGNED NOT NULL,
    barcode_value VARCHAR(100) UNIQUE NOT NULL,
    barcode_type ENUM('QR', 'CODE128', 'EAN13') DEFAULT 'QR',
    qr_code_path VARCHAR(255) NULL,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    FOREIGN KEY (menu_item_id) REFERENCES menu_items(id)
);
```

## 📚 API Routes & Endpoints

### Menu Management Routes (Guest/Member)

```php
// Menu Browsing
GET    /api/menu                      // Get all menu items
GET    /api/menu/categories           // Get menu categories
GET    /api/menu/category/{id}        // Get menu by category
GET    /api/menu/{id}                 // Get menu item details
GET    /api/menu/featured             // Get featured menu items
GET    /api/menu/search               // Search menu items

// Barcode Scanning
POST   /api/menu/scan-barcode         // Scan barcode to get menu
GET    /api/menu/barcode/{code}       // Get menu by barcode
```

### Order Routes (Guest/Member)

```php
// Order Management
GET    /api/orders                    // List user orders
POST   /api/orders                    // Create new order
GET    /api/orders/{id}               // Get order details
PUT    /api/orders/{id}               // Update order
DELETE /api/orders/{id}               // Cancel order

// Order Tracking
GET    /api/orders/{id}/status        // Get order status
GET    /api/orders/{id}/timeline      // Get order timeline
POST   /api/orders/{id}/feedback      // Submit order feedback

// Order Payment
POST   /api/orders/{id}/upload-proof  // Upload payment proof
GET    /api/orders/{id}/receipt       // Generate order receipt
```

### Cafe Admin Routes (Admin/Staff)

```php
// Menu Management (Admin)
GET    /api/admin/menu                // List all menu items
POST   /api/admin/menu                // Create menu item
GET    /api/admin/menu/{id}           // Get menu item details
PUT    /api/admin/menu/{id}           // Update menu item
DELETE /api/admin/menu/{id}           // Delete menu item
POST   /api/admin/menu/{id}/toggle    // Toggle menu availability

// Menu Categories (Admin)
GET    /api/admin/menu/categories     // List categories
POST   /api/admin/menu/categories     // Create category
PUT    /api/admin/menu/categories/{id} // Update category
DELETE /api/admin/menu/categories/{id} // Delete category

// Order Management (Admin)
GET    /api/admin/orders              // List all orders
GET    /api/admin/orders/{id}         // Get order details
PUT    /api/admin/orders/{id}/status  // Update order status
PUT    /api/admin/orders/{id}/confirm // Confirm order
PUT    /api/admin/orders/{id}/ready   // Mark order as ready
PUT    /api/admin/orders/{id}/deliver // Mark order as delivered

// Inventory Management (Admin)
GET    /api/admin/inventory           // List inventory
POST   /api/admin/inventory           // Create inventory item
PUT    /api/admin/inventory/{id}      // Update inventory
POST   /api/admin/inventory/{id}/restock // Restock inventory
GET    /api/admin/inventory/alerts    // Get low stock alerts

// Barcode Management (Admin)
GET    /api/admin/barcodes            // List barcodes
POST   /api/admin/barcodes/generate   // Generate new barcode
GET    /api/admin/barcodes/{id}/download // Download barcode
PUT    /api/admin/barcodes/{id}       // Update barcode
DELETE /api/admin/barcodes/{id}       // Delete barcode
```

### Cafe Analytics Routes

```php
// Cafe Analytics
GET    /api/admin/analytics/sales     // Sales analytics
GET    /api/admin/analytics/menu      // Menu performance analytics
GET    /api/admin/analytics/orders    // Order analytics
GET    /api/admin/analytics/inventory // Inventory analytics
GET    /api/admin/analytics/revenue   // Revenue analytics
```

## 🔄 CRUD Operations

### Menu CRUD Operations

#### Create Menu Item

```php
// POST /api/admin/menu
public function store(MenuRequest $request)
{
    $menuItem = MenuItem::create([
        'name' => $request->name,
        'description' => $request->description,
        'category_id' => $request->category_id,
        'price' => $request->price,
        'cost_price' => $request->cost_price,
        'image_path' => $this->uploadImage($request->image),
        'preparation_time' => $request->preparation_time,
        'calories' => $request->calories,
        'allergens' => $request->allergens,
    ]);

    // Generate barcode
    $barcode = $this->generateBarcode($menuItem);

    // Create inventory record
    Inventory::create([
        'menu_item_id' => $menuItem->id,
        'current_stock' => $request->initial_stock ?? 0,
        'min_stock_level' => $request->min_stock_level ?? 10,
    ]);

    return response()->json($menuItem, 201);
}
```

#### Read Menu Item

```php
// GET /api/menu/{id}
public function show($id)
{
    $menuItem = MenuItem::with([
        'category',
        'inventory',
        'barcode',
        'reviews'
    ])->findOrFail($id);

    return response()->json($menuItem);
}
```

#### Update Menu Item

```php
// PUT /api/admin/menu/{id}
public function update(MenuRequest $request, $id)
{
    $menuItem = MenuItem::findOrFail($id);

    $data = $request->validated();

    if ($request->hasFile('image')) {
        $data['image_path'] = $this->uploadImage($request->image);
    }

    $menuItem->update($data);

    return response()->json($menuItem);
}
```

#### Delete Menu Item

```php
// DELETE /api/admin/menu/{id}
public function destroy($id)
{
    $menuItem = MenuItem::findOrFail($id);

    // Check if menu item has active orders
    if ($menuItem->hasActiveOrders()) {
        return response()->json(['error' => 'Cannot delete menu item with active orders'], 422);
    }

    // Delete related data
    $menuItem->barcode()->delete();
    $menuItem->inventory()->delete();
    $menuItem->delete();

    return response()->json(['message' => 'Menu item deleted successfully']);
}
```

### Order CRUD Operations

#### Create Order

```php
// POST /api/orders
public function store(OrderRequest $request)
{
    $order = Order::create([
        'order_number' => $this->generateOrderNumber(),
        'user_id' => auth()->id(),
        'guest_name' => $request->guest_name,
        'guest_phone' => $request->guest_phone,
        'total_amount' => $this->calculateTotal($request->items),
        'final_amount' => $this->calculateFinalAmount($request->items),
        'delivery_location' => $request->delivery_location,
        'special_instructions' => $request->special_instructions,
        'estimated_ready_time' => now()->addMinutes($this->calculatePreparationTime($request->items)),
    ]);

    // Create order items
    foreach ($request->items as $item) {
        OrderItem::create([
            'order_id' => $order->id,
            'menu_item_id' => $item['menu_item_id'],
            'quantity' => $item['quantity'],
            'unit_price' => $item['unit_price'],
            'total_price' => $item['quantity'] * $item['unit_price'],
            'special_instructions' => $item['special_instructions'] ?? null,
        ]);

        // Update inventory
        $this->updateInventory($item['menu_item_id'], $item['quantity']);
    }

    // Send order notification
    event(new OrderCreated($order));

    return response()->json($order, 201);
}
```

#### Read Order

```php
// GET /api/orders/{id}
public function show($id)
{
    $order = Order::with([
        'orderItems.menuItem',
        'user',
        'orderTracking'
    ])->findOrFail($id);

    // Check authorization
    if ($order->user_id !== auth()->id() && !auth()->user()->hasRole('admin')) {
        abort(403);
    }

    return response()->json($order);
}
```

#### Update Order Status (Admin)

```php
// PUT /api/admin/orders/{id}/status
public function updateStatus($id, UpdateStatusRequest $request)
{
    $order = Order::findOrFail($id);
    $oldStatus = $order->status;

    $order->update(['status' => $request->status]);

    // Update order items status
    if (in_array($request->status, ['preparing', 'ready'])) {
        $order->orderItems()->update(['status' => $request->status]);
    }

    // Create tracking record
    OrderTracking::create([
        'order_id' => $order->id,
        'status' => $request->status,
        'notes' => $request->notes,
        'updated_by' => auth()->id(),
    ]);

    // Send notifications
    event(new OrderStatusUpdated($order, $oldStatus));

    return response()->json(['message' => 'Order status updated successfully']);
}
```

### Inventory CRUD Operations

#### Update Inventory

```php
// POST /api/admin/inventory/{id}/restock
public function restock(RestockRequest $request, $id)
{
    $inventory = Inventory::findOrFail($id);
    $previousStock = $inventory->current_stock;

    $inventory->update([
        'current_stock' => $previousStock + $request->quantity,
        'last_restocked_at' => now(),
    ]);

    // Create inventory log
    InventoryLog::create([
        'inventory_id' => $inventory->id,
        'action_type' => 'restock',
        'quantity' => $request->quantity,
        'previous_stock' => $previousStock,
        'new_stock' => $inventory->current_stock,
        'notes' => $request->notes,
        'created_by' => auth()->id(),
    ]);

    return response()->json(['message' => 'Inventory restocked successfully']);
}
```

## 🎭 Actor Perspectives

### Guest User Perspective

- **Browse Menu**: View menu items and categories
- **Scan Barcode**: Scan QR code to access menu
- **Place Order**: Create new order with items
- **Track Order**: Monitor order status and timeline
- **Upload Payment**: Upload payment proof
- **View Receipt**: Access order receipt

### Member Perspective

- **Browse Menu**: Same as guest + member benefits
- **Place Order**: Enhanced ordering with member perks
- **Track Order**: Priority order tracking
- **View History**: Access order history
- **Get Discounts**: Member-specific discounts

### Staff Cafe Perspective

- **View Orders**: Monitor incoming orders
- **Update Status**: Update order preparation status
- **Manage Inventory**: Track stock levels
- **Generate Reports**: Create cafe reports
- **Handle Payments**: Process order payments

### Admin Perspective

- **Manage Menu**: Full menu management
- **Configure Pricing**: Set menu prices and margins
- **Manage Inventory**: Oversee inventory levels
- **Generate Barcodes**: Create and manage barcodes
- **Analytics**: Access comprehensive cafe analytics

## 🧪 Testing

### Menu Testing

```php
// tests/Feature/MenuTest.php
class MenuTest extends TestCase
{
    use RefreshDatabase;

    public function test_user_can_browse_menu()
    {
        $menuItem = MenuItem::factory()->create();

        $response = $this->getJson('/api/menu');

        $response->assertStatus(200)
                ->assertJsonFragment(['name' => $menuItem->name]);
    }

    public function test_admin_can_create_menu_item()
    {
        $admin = User::factory()->create(['role' => 'admin']);
        $category = MenuCategory::factory()->create();

        $response = $this->actingAs($admin)
            ->postJson('/api/admin/menu', [
                'name' => 'Test Menu Item',
                'description' => 'Test description',
                'category_id' => $category->id,
                'price' => 25000,
                'cost_price' => 15000,
                'preparation_time' => 15,
            ]);

        $response->assertStatus(201);
        $this->assertDatabaseHas('menu_items', [
            'name' => 'Test Menu Item',
            'price' => 25000,
        ]);
    }

    public function test_user_can_place_order()
    {
        $user = User::factory()->create();
        $menuItem = MenuItem::factory()->create();

        $response = $this->actingAs($user)
            ->postJson('/api/orders', [
                'items' => [
                    [
                        'menu_item_id' => $menuItem->id,
                        'quantity' => 2,
                        'unit_price' => $menuItem->price,
                    ]
                ],
                'delivery_location' => 'Pool Area',
            ]);

        $response->assertStatus(201);
        $this->assertDatabaseHas('orders', [
            'user_id' => $user->id,
        ]);
    }
}
```

## ✅ Success Criteria

- [ ] Menu management berfungsi dengan baik
- [ ] Barcode generation dan scanning berjalan
- [ ] Order processing workflow terimplementasi
- [ ] Inventory management berfungsi
- [ ] Order tracking system berjalan
- [ ] Payment integration terpasang
- [ ] Order notifications terkirim
- [ ] Cafe analytics dapat diakses
- [ ] Barcode download berfungsi
- [ ] Testing coverage > 90%

## 📚 Documentation

- Cafe System Architecture
- Menu Management Guide
- Barcode System Guide
- Order Processing Guide
- Inventory Management Guide
