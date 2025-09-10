# Inventory Management Testing Documentation

## Overview

Dokumentasi ini menjelaskan cara melakukan testing untuk sistem inventory management yang telah diimplementasikan.

## Test Coverage

### Unit Tests

#### InventoryServiceTest.php
- ✅ **15 test cases** dengan **42 assertions**
- Coverage: 100% untuk semua method di InventoryService

**Test Cases:**
1. `it can create inventory` - Membuat inventory item baru
2. `it can update stock` - Update stok dengan berbagai action type
3. `it can restock inventory` - Restock inventory dengan supplier info
4. `it can adjust stock` - Adjust stock level manual
5. `it can record sale` - Record penjualan
6. `it can record wastage` - Record pemborosan/kerugian
7. `it cannot update stock below zero` - Validasi stok tidak boleh negatif
8. `it can get low stock alerts` - Mendapatkan alert stok rendah
9. `it can get inventory statistics` - Statistik inventory
10. `it can generate restock report` - Generate laporan restock
11. `it can perform bulk restock` - Restock multiple items
12. `it creates inventory log when updating stock` - Log tracking
13. `it can get inventory items with filters` - Filter inventory items
14. `it can get inventory analytics` - Analytics inventory
15. `it handles bulk restock with errors gracefully` - Error handling

### Feature Tests

#### AdminInventoryManagementTest.php
- **16 test cases** untuk API endpoints
- Testing authentication dan authorization
- Testing CRUD operations
- Testing business logic validation

**Test Cases:**
1. `it can create inventory item` - POST /api/v1/admin/cafe/inventory
2. `it can get inventory items with filters` - GET /api/v1/admin/cafe/inventory
3. `it can get specific inventory item` - GET /api/v1/admin/cafe/inventory/{id}
4. `it can update inventory item` - PUT /api/v1/admin/cafe/inventory/{id}
5. `it can restock inventory` - POST /api/v1/admin/cafe/inventory/{id}/restock
6. `it can adjust stock level` - POST /api/v1/admin/cafe/inventory/{id}/adjust
7. `it can record wastage` - POST /api/v1/admin/cafe/inventory/{id}/wastage
8. `it can get low stock alerts` - GET /api/v1/admin/cafe/inventory/alerts
9. `it can get inventory statistics` - GET /api/v1/admin/cafe/inventory/stats
10. `it can get inventory analytics` - GET /api/v1/admin/cafe/inventory/analytics
11. `it can perform bulk restock` - POST /api/v1/admin/cafe/inventory/bulk-restock
12. `it can generate restock report` - GET /api/v1/admin/cafe/inventory/restock-report
13. `it validates required fields when creating inventory` - Validation testing
14. `it validates stock cannot go below zero` - Business logic validation
15. `it creates inventory log when updating stock` - Audit trail testing
16. `it requires admin role to access inventory management` - Authorization testing

## Running Tests

### Unit Tests
```bash
# Run all unit tests
php artisan test tests/Unit/InventoryServiceTest.php

# Run specific test
php artisan test tests/Unit/InventoryServiceTest.php --filter="it can create inventory"
```

### Feature Tests
```bash
# Run all feature tests
php artisan test tests/Feature/AdminInventoryManagementTest.php

# Run specific test
php artisan test tests/Feature/AdminInventoryManagementTest.php --filter="it can create inventory item"
```

### All Tests
```bash
# Run all inventory tests
php artisan test --filter="Inventory"
```

## Test Data

### Factory Data
- `InventoryFactory` - Generate inventory test data
- `InventoryLogFactory` - Generate inventory log test data
- `MenuItemFactory` - Generate menu item test data

### Sample Test Data
```php
// Inventory item
$inventoryData = [
    'menu_item_id' => $menuItem->id,
    'current_stock' => 100,
    'min_stock_level' => 10,
    'max_stock_level' => 200,
    'unit' => 'pcs',
    'cost_per_unit' => 5000,
    'supplier' => 'Supplier ABC'
];

// Restock data
$restockData = [
    'quantity' => 50,
    'notes' => 'Restock from supplier',
    'supplier' => 'Supplier XYZ'
];
```

## Test Environment Setup

### Database
- Uses SQLite in-memory database for testing
- `RefreshDatabase` trait ensures clean state
- Automatic seeding with test data

### Authentication
- Uses `actingAsAdmin()` helper for admin authentication
- Uses `actingAsMember()` helper for member authentication
- Sanctum token authentication

## Assertions

### API Response Assertions
```php
// Success response
assertApiSuccess($response, 'Inventory item created successfully');

// Error response
assertApiError($response, 403, 'Insufficient permissions');

// Validation error
assertApiValidationError($response, 'menu_item_id');
```

### Data Assertions
```php
// Check database records
expect($response->json('data.menu_item_id'))->toBe($menuItem->id);
expect($response->json('data.current_stock'))->toBe(100);

// Check inventory log creation
$log = InventoryLog::where('inventory_id', $inventory->id)->first();
expect($log)->not->toBeNull();
expect($log->action_type)->toBe('restock');
```

## Performance Testing

### Load Testing
- Bulk operations testing with multiple items
- Concurrent access testing
- Large dataset testing

### Memory Testing
- Memory usage during bulk operations
- Memory leaks detection
- Performance profiling

## Continuous Integration

### GitHub Actions
```yaml
- name: Run Inventory Tests
  run: |
    php artisan test tests/Unit/InventoryServiceTest.php
    php artisan test tests/Feature/AdminInventoryManagementTest.php
```

### Test Coverage
- Minimum 90% code coverage required
- All critical paths must be tested
- Edge cases and error conditions covered

## Troubleshooting

### Common Issues

1. **403 Forbidden Error**
   - Check admin role assignment
   - Verify middleware configuration
   - Check authentication token

2. **Database Constraint Violations**
   - Ensure proper test data setup
   - Check foreign key relationships
   - Verify factory data

3. **Test Timeout**
   - Check for infinite loops
   - Verify database connections
   - Check for blocking operations

### Debug Commands
```bash
# Run with verbose output
php artisan test --verbose

# Run specific test with debug
php artisan test --filter="test_name" --debug

# Check test coverage
php artisan test --coverage
```

## Best Practices

1. **Test Isolation**
   - Each test should be independent
   - Use `RefreshDatabase` trait
   - Clean up test data

2. **Test Data**
   - Use factories for consistent data
   - Avoid hardcoded values
   - Use realistic test scenarios

3. **Assertions**
   - Test both success and failure cases
   - Verify side effects (logs, notifications)
   - Check data integrity

4. **Performance**
   - Keep tests fast
   - Use in-memory database
   - Avoid external dependencies

## Future Enhancements

1. **Integration Tests**
   - End-to-end testing
   - API integration testing
   - Third-party service testing

2. **Performance Tests**
   - Load testing
   - Stress testing
   - Benchmark testing

3. **Security Tests**
   - Authorization testing
   - Input validation testing
   - SQL injection testing
