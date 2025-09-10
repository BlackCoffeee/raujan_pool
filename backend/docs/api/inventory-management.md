# Inventory Management API Documentation

## Overview

Inventory Management API memungkinkan admin untuk mengelola stok barang, melacak pergerakan stok, dan mendapatkan analisis inventori.

## Base URL

```
/api/v1/admin/cafe/inventory
```

## Authentication

Semua endpoint memerlukan authentication dengan token Bearer dan role admin.

```bash
Authorization: Bearer {token}
```

## Endpoints

### 1. Get All Inventory Items

**GET** `/api/v1/admin/cafe/inventory`

Mengambil daftar semua item inventori dengan filter opsional.

#### Query Parameters

| Parameter       | Type    | Description                                                                          |
| --------------- | ------- | ------------------------------------------------------------------------------------ |
| `status`        | string  | Filter berdasarkan status stok: `low_stock`, `out_of_stock`, `overstocked`, `normal` |
| `menu_item_id`  | integer | Filter berdasarkan ID menu item                                                      |
| `supplier`      | string  | Filter berdasarkan supplier                                                          |
| `needs_restock` | boolean | Filter item yang perlu di-restock                                                    |
| `per_page`      | integer | Jumlah item per halaman (default: 15)                                                |

#### Response

```json
{
  "success": true,
  "message": "Inventory items retrieved successfully",
  "data": {
    "data": [
      {
        "id": 1,
        "menu_item_id": 1,
        "current_stock": 50,
        "min_stock_level": 10,
        "max_stock_level": 100,
        "unit": "pcs",
        "cost_per_unit": "5000.00",
        "supplier": "Supplier ABC",
        "last_restocked_at": "2024-01-15T10:30:00.000000Z",
        "created_at": "2024-01-01T00:00:00.000000Z",
        "updated_at": "2024-01-15T10:30:00.000000Z",
        "menu_item": {
          "id": 1,
          "name": "Nasi Goreng",
          "price": "15000.00"
        },
        "inventory_logs": [
          {
            "id": 1,
            "action_type": "restock",
            "quantity": 30,
            "previous_stock": 20,
            "new_stock": 50,
            "notes": "Restock from supplier",
            "created_at": "2024-01-15T10:30:00.000000Z"
          }
        ]
      }
    ],
    "links": {...},
    "meta": {...}
  }
}
```

### 2. Create Inventory Item

**POST** `/api/v1/admin/cafe/inventory`

Membuat item inventori baru.

#### Request Body

```json
{
    "menu_item_id": 1,
    "current_stock": 100,
    "min_stock_level": 10,
    "max_stock_level": 200,
    "unit": "pcs",
    "cost_per_unit": 5000,
    "supplier": "Supplier ABC"
}
```

#### Response

```json
{
  "success": true,
  "message": "Inventory item created successfully",
  "data": {
    "id": 1,
    "menu_item_id": 1,
    "current_stock": 100,
    "min_stock_level": 10,
    "max_stock_level": 200,
    "unit": "pcs",
    "cost_per_unit": "5000.00",
    "supplier": "Supplier ABC",
    "last_restocked_at": null,
    "created_at": "2024-01-01T00:00:00.000000Z",
    "updated_at": "2024-01-01T00:00:00.000000Z",
    "menu_item": {...},
    "inventory_logs": [...]
  }
}
```

### 3. Get Specific Inventory Item

**GET** `/api/v1/admin/cafe/inventory/{id}`

Mengambil detail item inventori berdasarkan ID.

#### Response

```json
{
  "success": true,
  "message": "Inventory item retrieved successfully",
  "data": {
    "id": 1,
    "menu_item_id": 1,
    "current_stock": 50,
    "min_stock_level": 10,
    "max_stock_level": 100,
    "unit": "pcs",
    "cost_per_unit": "5000.00",
    "supplier": "Supplier ABC",
    "last_restocked_at": "2024-01-15T10:30:00.000000Z",
    "created_at": "2024-01-01T00:00:00.000000Z",
    "updated_at": "2024-01-15T10:30:00.000000Z",
    "menu_item": {...},
    "inventory_logs": [...]
  }
}
```

### 4. Update Inventory Item

**PUT** `/api/v1/admin/cafe/inventory/{id}`

Mengupdate item inventori.

#### Request Body

```json
{
    "menu_item_id": 1,
    "current_stock": 150,
    "min_stock_level": 15,
    "max_stock_level": 300,
    "unit": "kg",
    "cost_per_unit": 7500,
    "supplier": "Updated Supplier"
}
```

#### Response

```json
{
  "success": true,
  "message": "Inventory item updated successfully",
  "data": {
    "id": 1,
    "menu_item_id": 1,
    "current_stock": 150,
    "min_stock_level": 15,
    "max_stock_level": 300,
    "unit": "kg",
    "cost_per_unit": "7500.00",
    "supplier": "Updated Supplier",
    "last_restocked_at": "2024-01-15T10:30:00.000000Z",
    "created_at": "2024-01-01T00:00:00.000000Z",
    "updated_at": "2024-01-15T11:00:00.000000Z",
    "menu_item": {...},
    "inventory_logs": [...]
  }
}
```

### 5. Restock Inventory

**POST** `/api/v1/admin/cafe/inventory/{id}/restock`

Menambah stok item inventori.

#### Request Body

```json
{
    "quantity": 50,
    "notes": "Restock from supplier",
    "supplier": "New Supplier"
}
```

#### Response

```json
{
  "success": true,
  "message": "Inventory restocked successfully",
  "data": {
    "id": 1,
    "current_stock": 70,
    "last_restocked_at": "2024-01-15T12:00:00.000000Z",
    "supplier": "New Supplier",
    "menu_item": {...},
    "inventory_logs": [
      {
        "id": 2,
        "action_type": "restock",
        "quantity": 50,
        "previous_stock": 20,
        "new_stock": 70,
        "notes": "Restock from supplier",
        "created_at": "2024-01-15T12:00:00.000000Z"
      }
    ]
  }
}
```

### 6. Adjust Stock Level

**POST** `/api/v1/admin/cafe/inventory/{id}/adjust`

Menyesuaikan level stok (untuk stock opname).

#### Request Body

```json
{
    "new_stock": 80,
    "notes": "Stock adjustment after count"
}
```

#### Response

```json
{
  "success": true,
  "message": "Stock adjusted successfully",
  "data": {
    "id": 1,
    "current_stock": 80,
    "menu_item": {...},
    "inventory_logs": [
      {
        "id": 3,
        "action_type": "adjustment",
        "quantity": 20,
        "previous_stock": 100,
        "new_stock": 80,
        "notes": "Stock adjustment after count",
        "created_at": "2024-01-15T13:00:00.000000Z"
      }
    ]
  }
}
```

### 7. Record Wastage

**POST** `/api/v1/admin/cafe/inventory/{id}/wastage`

Mencatat barang yang rusak/kadaluarsa.

#### Request Body

```json
{
    "quantity": 5,
    "notes": "Expired items"
}
```

#### Response

```json
{
  "success": true,
  "message": "Wastage recorded successfully",
  "data": {
    "id": 1,
    "current_stock": 25,
    "menu_item": {...},
    "inventory_logs": [
      {
        "id": 4,
        "action_type": "wastage",
        "quantity": 5,
        "previous_stock": 30,
        "new_stock": 25,
        "notes": "Expired items",
        "created_at": "2024-01-15T14:00:00.000000Z"
      }
    ]
  }
}
```

### 8. Get Low Stock Alerts

**GET** `/api/v1/admin/cafe/inventory/alerts`

Mengambil daftar item yang stoknya rendah.

#### Response

```json
{
    "success": true,
    "message": "Low stock alerts retrieved successfully",
    "data": [
        {
            "inventory_id": 1,
            "menu_item_name": "Nasi Goreng",
            "current_stock": 5,
            "min_stock_level": 10,
            "stock_deficit": 5,
            "reorder_quantity": 95,
            "supplier": "Supplier ABC"
        }
    ]
}
```

### 9. Get Inventory Statistics

**GET** `/api/v1/admin/cafe/inventory/stats`

Mengambil statistik inventori.

#### Query Parameters

| Parameter    | Type | Description                     |
| ------------ | ---- | ------------------------------- |
| `start_date` | date | Tanggal mulai filter (optional) |
| `end_date`   | date | Tanggal akhir filter (optional) |

#### Response

```json
{
    "success": true,
    "message": "Inventory statistics retrieved successfully",
    "data": {
        "total_items": 50,
        "low_stock_items": 5,
        "out_of_stock_items": 2,
        "overstocked_items": 3,
        "normal_stock_items": 40,
        "total_inventory_value": 2500000,
        "average_stock_level": 45.5,
        "items_needing_restock": 7
    }
}
```

### 10. Get Inventory Analytics

**GET** `/api/v1/admin/cafe/inventory/analytics`

Mengambil analisis inventori.

#### Query Parameters

| Parameter    | Type | Description                     |
| ------------ | ---- | ------------------------------- |
| `start_date` | date | Tanggal mulai filter (optional) |
| `end_date`   | date | Tanggal akhir filter (optional) |

#### Response

```json
{
    "success": true,
    "message": "Inventory analytics retrieved successfully",
    "data": {
        "stock_movements": [
            {
                "date": "2024-01-15",
                "restocks": 100,
                "sales": 50,
                "wastage": 5
            }
        ],
        "top_moving_items": [
            {
                "inventory_id": 1,
                "menu_item_name": "Nasi Goreng",
                "total_movement": 200
            }
        ],
        "wastage_analytics": {
            "total_wastage": 25,
            "wastage_by_item": {
                "1": {
                    "menu_item_name": "Nasi Goreng",
                    "total_wastage": 10,
                    "wastage_cost": 50000
                }
            }
        },
        "restock_analytics": {
            "total_restocks": 15,
            "total_restock_quantity": 500,
            "total_restock_cost": 2500000,
            "average_restock_quantity": 33.33
        },
        "supplier_performance": [
            {
                "supplier": "Supplier ABC",
                "item_count": 20,
                "total_value": 1000000
            }
        ]
    }
}
```

### 11. Bulk Restock

**POST** `/api/v1/admin/cafe/inventory/bulk-restock`

Melakukan restock untuk multiple item sekaligus.

#### Request Body

```json
{
    "items": [
        {
            "inventory_id": 1,
            "quantity": 20,
            "notes": "Bulk restock 1",
            "supplier": "Supplier A"
        },
        {
            "inventory_id": 2,
            "quantity": 25,
            "notes": "Bulk restock 2",
            "supplier": "Supplier B"
        }
    ]
}
```

#### Response

```json
{
    "success": true,
    "message": "Bulk restock completed",
    "data": [
        {
            "inventory_id": 1,
            "success": true,
            "new_stock": 70
        },
        {
            "inventory_id": 2,
            "success": true,
            "new_stock": 75
        }
    ]
}
```

### 12. Generate Restock Report

**GET** `/api/v1/admin/cafe/inventory/restock-report`

Membuat laporan restock untuk item yang stoknya rendah.

#### Response

```json
{
    "success": true,
    "message": "Restock report generated successfully",
    "data": {
        "report_date": "2024-01-15 15:30:00",
        "total_items_needing_restock": 5,
        "estimated_restock_cost": 500000,
        "items": [
            {
                "inventory_id": 1,
                "menu_item_name": "Nasi Goreng",
                "current_stock": 5,
                "min_stock_level": 10,
                "stock_deficit": 5,
                "reorder_quantity": 95,
                "supplier": "Supplier ABC"
            }
        ]
    }
}
```

## Error Responses

### Validation Error (422)

```json
{
    "success": false,
    "message": "Validation failed",
    "errors": {
        "menu_item_id": ["The menu item id field is required."],
        "current_stock": ["The current stock must be an integer."]
    }
}
```

### Insufficient Stock Error (500)

```json
{
    "success": false,
    "message": "Failed to record wastage",
    "error": "Insufficient stock for this operation"
}
```

### Not Found Error (404)

```json
{
    "success": false,
    "message": "Inventory item not found",
    "error": "No query results for model [App\\Models\\Inventory] 999"
}
```

### Unauthorized Error (403)

```json
{
    "message": "This action is unauthorized."
}
```

## Data Models

### Inventory Model

| Field               | Type      | Description                                |
| ------------------- | --------- | ------------------------------------------ |
| `id`                | integer   | Primary key                                |
| `menu_item_id`      | integer   | Foreign key to menu_items table            |
| `current_stock`     | integer   | Current stock quantity                     |
| `min_stock_level`   | integer   | Minimum stock level for alerts             |
| `max_stock_level`   | integer   | Maximum stock level (optional)             |
| `unit`              | string    | Unit of measurement (pcs, kg, liter, etc.) |
| `cost_per_unit`     | decimal   | Cost per unit                              |
| `supplier`          | string    | Supplier name (optional)                   |
| `last_restocked_at` | timestamp | Last restock date (optional)               |
| `created_at`        | timestamp | Creation timestamp                         |
| `updated_at`        | timestamp | Last update timestamp                      |

### Inventory Log Model

| Field            | Type      | Description                                                          |
| ---------------- | --------- | -------------------------------------------------------------------- |
| `id`             | integer   | Primary key                                                          |
| `inventory_id`   | integer   | Foreign key to inventory table                                       |
| `action_type`    | string    | Type of action: restock, sale, adjustment, wastage, transfer, return |
| `quantity`       | integer   | Quantity involved in the action                                      |
| `previous_stock` | integer   | Stock level before action                                            |
| `new_stock`      | integer   | Stock level after action                                             |
| `reference_type` | string    | Reference type: order, manual, system, transfer                      |
| `reference_id`   | integer   | Reference ID (optional)                                              |
| `notes`          | text      | Additional notes (optional)                                          |
| `created_by`     | integer   | User who performed the action (optional)                             |
| `created_at`     | timestamp | Creation timestamp                                                   |
| `updated_at`     | timestamp | Last update timestamp                                                |

## Usage Examples

### cURL Examples

#### Get All Inventory Items

```bash
curl -X GET "https://api.example.com/api/v1/admin/cafe/inventory?status=low_stock" \
  -H "Authorization: Bearer {token}" \
  -H "Accept: application/json"
```

#### Create New Inventory Item

```bash
curl -X POST "https://api.example.com/api/v1/admin/cafe/inventory" \
  -H "Authorization: Bearer {token}" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d '{
    "menu_item_id": 1,
    "current_stock": 100,
    "min_stock_level": 10,
    "max_stock_level": 200,
    "unit": "pcs",
    "cost_per_unit": 5000,
    "supplier": "Supplier ABC"
  }'
```

#### Restock Inventory

```bash
curl -X POST "https://api.example.com/api/v1/admin/cafe/inventory/1/restock" \
  -H "Authorization: Bearer {token}" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d '{
    "quantity": 50,
    "notes": "Restock from supplier",
    "supplier": "New Supplier"
  }'
```

## Notes

1. Semua endpoint memerlukan authentication dengan role admin
2. Stock tidak bisa dikurangi di bawah 0
3. Setiap perubahan stok akan dicatat dalam inventory_logs
4. Low stock alerts otomatis terpicu ketika current_stock <= min_stock_level
5. Bulk operations akan menangani error secara individual untuk setiap item
6. Analytics data dapat difilter berdasarkan tanggal untuk analisis periode tertentu
