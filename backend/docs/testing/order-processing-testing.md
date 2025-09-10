# Order Processing Testing Documentation

## Overview

Dokumentasi ini menjelaskan cara melakukan testing untuk Order Processing System, termasuk unit tests, feature tests, dan API testing.

## Test Structure

### 1. Unit Tests

Unit tests untuk Order Processing System terletak di:
- `tests/Feature/OrderProcessingTest.php` - Feature tests untuk Order Processing

### 2. Test Coverage

Order Processing System memiliki test coverage untuk:
- Order creation workflow
- Order status management
- Order validation
- Order confirmation
- Order cancellation
- Payment status management
- Order retrieval and filtering
- Order analytics
- API endpoints (Member dan Admin)
- Error handling
- Model relationships

## Running Tests

### 1. Run All Order Processing Tests

```bash
php artisan test tests/Feature/OrderProcessingTest.php
```

### 2. Run Specific Test Group

```bash
# Test order creation
php artisan test tests/Feature/OrderProcessingTest.php --filter="Order Creation"

# Test order status management
php artisan test tests/Feature/OrderProcessingTest.php --filter="Order Status Management"

# Test API endpoints
php artisan test tests/Feature/OrderProcessingTest.php --filter="Order API Endpoints"

# Test model relationships
php artisan test tests/Feature/OrderProcessingTest.php --filter="Order Model Relationships"
```

### 3. Run with Coverage

```bash
php artisan test tests/Feature/OrderProcessingTest.php --coverage
```

## Test Data Setup

### 1. Database Setup

Tests menggunakan SQLite in-memory database untuk testing:

```php
beforeEach(function () {
    $this->orderService = app(OrderService::class);
    $this->user = User::factory()->create();
    $this->user->assignRole('member');
    $this->category = MenuCategory::factory()->create();
    $this->menuItem = MenuItem::factory()->create([
        'category_id' => $this->category->id,
        'is_available' => true,
        'price' => 25000,
        'preparation_time' => 15
    ]);
});
```

### 2. Factory Usage

Tests menggunakan factories untuk membuat test data:

```php
// Create order
$order = Order::factory()->create(['user_id' => $this->user->id]);

// Create order with specific status
$order = Order::factory()->pending()->create();

// Create order item
$orderItem = OrderItem::factory()->create([
    'order_id' => $order->id,
    'menu_item_id' => $this->menuItem->id
]);

// Create order tracking
$orderTracking = OrderTracking::factory()->create([
    'order_id' => $order->id,
    'updated_by' => $this->user->id
]);
```

## Test Scenarios

### 1. Order Creation Tests

```php
it('can create order with valid data', function () {
    $orderData = [
        'user_id' => $this->user->id,
        'items' => [
            [
                'menu_item_id' => $this->menuItem->id,
                'quantity' => 2,
                'special_instructions' => 'Extra spicy'
            ]
        ],
        'delivery_location' => 'Pool Area',
        'payment_method' => 'manual_transfer'
    ];

    $order = $this->orderService->createOrder($orderData);

    expect($order->order_number)->not->toBeNull();
    expect($order->status)->toBe('pending');
    expect($order->payment_status)->toBe('unpaid');
    expect($order->total_amount)->toBe('50000.00');
    expect($order->tax_amount)->toBe('5000.00');
    expect($order->final_amount)->toBe('55000.00');
});
```

### 2. Order Status Management Tests

```php
it('can update order status with valid transition', function () {
    $order = Order::factory()->create([
        'status' => 'pending',
        'user_id' => $this->user->id
    ]);

    $updatedOrder = $this->orderService->updateOrderStatus($order->id, 'confirmed');

    expect($updatedOrder->status)->toBe('confirmed');
    expect($updatedOrder->orderTracking)->toHaveCount(1);
});

it('cannot update order status with invalid transition', function () {
    $order = Order::factory()->create([
        'status' => 'delivered',
        'user_id' => $this->user->id
    ]);

    expect(function () use ($order) {
        $this->orderService->updateOrderStatus($order->id, 'pending');
    })->toThrow(Exception::class, 'Invalid status transition');
});
```

### 3. API Endpoint Tests

```php
it('can create order via API', function () {
    $this->actingAs($this->user);

    $orderData = [
        'user_id' => $this->user->id,
        'items' => [
            [
                'menu_item_id' => $this->menuItem->id,
                'quantity' => 1
            ]
        ],
        'delivery_location' => 'Pool Area'
    ];

    $response = $this->postJson('/api/v1/members/orders', $orderData);

    $response->assertStatus(201)
        ->assertJsonStructure([
            'success',
            'message',
            'data' => [
                'id',
                'order_number',
                'status',
                'payment_status',
                'order_items'
            ]
        ]);
});
```

## API Testing Script

### 1. Manual API Testing

Gunakan script `scripts/test-order-processing.sh` untuk testing API endpoints:

```bash
# Run with tokens
ADMIN_TOKEN=your_admin_token MEMBER_TOKEN=your_member_token ./scripts/test-order-processing.sh

# Run without tokens (some tests will fail)
./scripts/test-order-processing.sh
```

### 2. Script Features

Script testing mencakup:
- Member order endpoints testing
- Guest order creation testing
- Admin order endpoints testing
- Error cases testing
- Order status transitions testing
- Payment status updates testing

### 3. Expected Output

```
==========================================
      ORDER PROCESSING API TEST SUITE
==========================================

[INFO] Setting up test data...
[SUCCESS] Test passed: POST /admin/menu/categories (Status: 201)
[SUCCESS] Test passed: POST /admin/menu (Status: 201)
[SUCCESS] Test data setup completed

[INFO] Testing Member Order Endpoints...
[SUCCESS] Test passed: POST /members/orders (Status: 201)
[SUCCESS] Test passed: GET /members/orders (Status: 200)
[SUCCESS] Test passed: GET /members/orders/1 (Status: 200)
[SUCCESS] Test passed: PUT /members/orders/1 (Status: 200)
[SUCCESS] Test passed: POST /members/orders/1/cancel (Status: 200)
[SUCCESS] Test passed: GET /members/orders/1/receipt (Status: 200)
[SUCCESS] Member order endpoints testing completed

==========================================
           ORDER PROCESSING TEST RESULTS
==========================================
Total Tests: 25
Passed: 25
Failed: 0
Success Rate: 100%
==========================================
[SUCCESS] All tests passed!
```

## Test Data Cleanup

### 1. Automatic Cleanup

Tests menggunakan database transactions yang otomatis di-rollback setelah setiap test:

```php
use Illuminate\Foundation\Testing\RefreshDatabase;

uses(RefreshDatabase::class);
```

### 2. Manual Cleanup

Jika diperlukan cleanup manual:

```bash
# Reset database
php artisan migrate:fresh --seed

# Clear cache
php artisan cache:clear
php artisan config:clear
```

## Performance Testing

### 1. Load Testing

Untuk testing performa dengan banyak data:

```php
it('can handle multiple orders efficiently', function () {
    // Create multiple orders
    $orders = Order::factory()->count(100)->create();
    
    // Test retrieval performance
    $startTime = microtime(true);
    $retrievedOrders = $this->orderService->getOrders();
    $endTime = microtime(true);
    
    $executionTime = $endTime - $startTime;
    expect($executionTime)->toBeLessThan(1.0); // Should complete in less than 1 second
});
```

### 2. Memory Usage Testing

```php
it('does not cause memory leaks', function () {
    $initialMemory = memory_get_usage();
    
    // Create and process many orders
    for ($i = 0; $i < 1000; $i++) {
        $order = Order::factory()->create();
        $this->orderService->getOrderDetails($order->id);
    }
    
    $finalMemory = memory_get_usage();
    $memoryIncrease = $finalMemory - $initialMemory;
    
    // Memory increase should be reasonable
    expect($memoryIncrease)->toBeLessThan(50 * 1024 * 1024); // Less than 50MB
});
```

## Integration Testing

### 1. Database Integration

```php
it('integrates correctly with database', function () {
    $order = $this->orderService->createOrder([
        'user_id' => $this->user->id,
        'items' => [
            [
                'menu_item_id' => $this->menuItem->id,
                'quantity' => 1
            ]
        ]
    ]);
    
    // Verify data persistence
    $this->assertDatabaseHas('orders', [
        'id' => $order->id,
        'status' => 'pending',
        'payment_status' => 'unpaid'
    ]);
    
    $this->assertDatabaseHas('order_items', [
        'order_id' => $order->id,
        'menu_item_id' => $this->menuItem->id,
        'quantity' => 1
    ]);
    
    $this->assertDatabaseHas('order_tracking', [
        'order_id' => $order->id,
        'status' => 'pending'
    ]);
});
```

### 2. Service Integration

```php
it('integrates with other services', function () {
    $order = $this->orderService->createOrder([
        'user_id' => $this->user->id,
        'items' => [
            [
                'menu_item_id' => $this->menuItem->id,
                'quantity' => 1
            ]
        ]
    ]);
    
    // Test inventory integration
    $inventory = Inventory::where('menu_item_id', $this->menuItem->id)->first();
    expect($inventory->current_stock)->toBeLessThan($inventory->max_stock);
    
    // Test notification integration (if implemented)
    // expect(Notification::sent($this->user, OrderCreated::class))->toBeTrue();
});
```

## Troubleshooting

### 1. Common Issues

**Foreign Key Constraint Errors:**
```php
// Ensure user exists before creating order
$order = Order::factory()->create(['user_id' => $this->user->id]);
```

**Validation Errors:**
```php
// Ensure all required fields are provided
$orderData = [
    'user_id' => $this->user->id, // or guest_name + guest_phone
    'items' => [
        [
            'menu_item_id' => $this->menuItem->id,
            'quantity' => 1
        ]
    ]
];
```

**Authentication Errors:**
```php
// Ensure user is authenticated and has correct role
$this->actingAs($this->user);
$this->user->assignRole('member');
```

### 2. Debug Mode

Enable debug mode for detailed error information:

```bash
# Set debug mode
export APP_DEBUG=true

# Run tests with verbose output
php artisan test tests/Feature/OrderProcessingTest.php -v
```

### 3. Database Debugging

```php
// Enable query logging
DB::enableQueryLog();

// Run test
$order = $this->orderService->createOrder($orderData);

// Check queries
$queries = DB::getQueryLog();
dd($queries);
```

## Best Practices

### 1. Test Organization

- Group related tests using `describe()` blocks
- Use descriptive test names
- Keep tests independent and isolated
- Use factories for test data creation

### 2. Assertions

- Use specific assertions (`toBe()`, `toHaveCount()`, etc.)
- Test both success and failure scenarios
- Verify side effects (database changes, notifications, etc.)

### 3. Performance

- Use database transactions for cleanup
- Avoid creating unnecessary test data
- Use factories instead of manual data creation
- Test with realistic data volumes

### 4. Maintenance

- Update tests when business logic changes
- Keep test data factories up to date
- Regular test review and refactoring
- Monitor test execution time
