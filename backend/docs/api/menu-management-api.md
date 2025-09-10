# Menu Management API Documentation

## Overview

Menu Management API menyediakan endpoints untuk mengelola menu items, kategori menu, inventory, dan barcode untuk sistem cafe kolam renang syariah.

## Base URL

```
/api/v1
```

## Authentication

Semua endpoint memerlukan authentication menggunakan Sanctum token.

## Member Menu Endpoints

### Get All Menu Items

**GET** `/members/menu`

Mengambil daftar semua menu items dengan filter opsional.

#### Query Parameters

| Parameter        | Type    | Description                           |
| ---------------- | ------- | ------------------------------------- |
| `category_id`    | integer | Filter berdasarkan kategori           |
| `available_only` | boolean | Hanya menu yang tersedia              |
| `featured_only`  | boolean | Hanya menu yang featured              |
| `search`         | string  | Pencarian berdasarkan nama/deskripsi  |
| `min_price`      | decimal | Harga minimum                         |
| `max_price`      | decimal | Harga maksimum                        |
| `low_stock_only` | boolean | Hanya menu dengan stok rendah         |
| `per_page`       | integer | Jumlah item per halaman (default: 15) |

#### Response

```json
{
    "success": true,
    "message": "Menu items retrieved successfully",
    "data": {
        "data": [
            {
                "id": 1,
                "name": "Nasi Goreng",
                "description": "Nasi goreng dengan telur dan ayam",
                "price": "25000.00",
                "cost_price": "15000.00",
                "preparation_time": 15,
                "calories": 400,
                "allergens": ["gluten", "eggs"],
                "is_available": true,
                "is_featured": false,
                "barcode": "MENU000001",
                "category": {
                    "id": 1,
                    "name": "Makanan",
                    "description": "Menu makanan utama"
                },
                "inventory": {
                    "id": 1,
                    "current_stock": 50,
                    "min_stock_level": 10,
                    "max_stock_level": 100,
                    "unit": "pcs",
                    "is_low_stock": false
                },
                "barcode": {
                    "id": 1,
                    "barcode_value": "MENU000001",
                    "barcode_type": "QR",
                    "qr_code_url": "/api/menu/qr/1",
                    "is_active": true
                }
            }
        ],
        "current_page": 1,
        "last_page": 1,
        "per_page": 15,
        "total": 1
    }
}
```

### Get Menu Categories

**GET** `/members/menu/categories`

Mengambil daftar semua kategori menu yang aktif.

#### Response

```json
{
    "success": true,
    "message": "Menu categories retrieved successfully",
    "data": [
        {
            "id": 1,
            "name": "Makanan",
            "description": "Menu makanan utama",
            "image_path": null,
            "image_url": null,
            "is_active": true,
            "sort_order": 1,
            "active_items_count": 5
        }
    ]
}
```

### Get Menu Items by Category

**GET** `/members/menu/category/{id}`

Mengambil menu items berdasarkan kategori tertentu.

#### Path Parameters

| Parameter | Type    | Description      |
| --------- | ------- | ---------------- |
| `id`      | integer | ID kategori menu |

#### Response

```json
{
    "success": true,
    "message": "Menu items by category retrieved successfully",
    "data": {
        "data": [
            {
                "id": 1,
                "name": "Nasi Goreng",
                "price": "25000.00",
                "category": {
                    "id": 1,
                    "name": "Makanan"
                }
            }
        ]
    }
}
```

### Get Featured Menu Items

**GET** `/members/menu/featured`

Mengambil menu items yang ditandai sebagai featured.

#### Response

```json
{
    "success": true,
    "message": "Featured menu items retrieved successfully",
    "data": {
        "data": [
            {
                "id": 1,
                "name": "Nasi Goreng Special",
                "price": "30000.00",
                "is_featured": true
            }
        ]
    }
}
```

### Search Menu Items

**GET** `/members/menu/search`

Mencari menu items berdasarkan query.

#### Query Parameters

| Parameter | Type   | Description                |
| --------- | ------ | -------------------------- |
| `q`       | string | Query pencarian (required) |

#### Response

```json
{
    "success": true,
    "message": "Search results retrieved successfully",
    "data": {
        "data": [
            {
                "id": 1,
                "name": "Nasi Goreng",
                "price": "25000.00"
            }
        ]
    }
}
```

### Get Specific Menu Item

**GET** `/members/menu/{id}`

Mengambil detail menu item tertentu.

#### Path Parameters

| Parameter | Type    | Description  |
| --------- | ------- | ------------ |
| `id`      | integer | ID menu item |

#### Response

```json
{
    "success": true,
    "message": "Menu item retrieved successfully",
    "data": {
        "id": 1,
        "name": "Nasi Goreng",
        "description": "Nasi goreng dengan telur dan ayam",
        "price": "25000.00",
        "cost_price": "15000.00",
        "preparation_time": 15,
        "calories": 400,
        "allergens": ["gluten", "eggs"],
        "is_available": true,
        "is_featured": false,
        "barcode": "MENU000001",
        "category": {
            "id": 1,
            "name": "Makanan"
        },
        "inventory": {
            "current_stock": 50,
            "min_stock_level": 10,
            "is_low_stock": false
        },
        "barcode": {
            "barcode_value": "MENU000001",
            "barcode_type": "QR",
            "qr_code_url": "/api/menu/qr/1"
        }
    }
}
```

## Admin Menu Endpoints

### Create Menu Item

**POST** `/admin/menu`

Membuat menu item baru.

#### Request Body

```json
{
    "name": "Nasi Goreng",
    "description": "Nasi goreng dengan telur dan ayam",
    "category_id": 1,
    "price": 25000,
    "cost_price": 15000,
    "preparation_time": 15,
    "calories": 400,
    "allergens": ["gluten", "eggs"],
    "initial_stock": 20,
    "min_stock_level": 5,
    "max_stock_level": 100,
    "unit": "pcs"
}
```

#### Validation Rules

| Field              | Type    | Rules                                             |
| ------------------ | ------- | ------------------------------------------------- |
| `name`             | string  | required, max:255                                 |
| `description`      | string  | nullable                                          |
| `category_id`      | integer | required, exists:menu_categories,id               |
| `price`            | decimal | required, numeric, min:0                          |
| `cost_price`       | decimal | required, numeric, min:0                          |
| `preparation_time` | integer | nullable, min:1                                   |
| `calories`         | integer | nullable, min:0                                   |
| `allergens`        | array   | nullable                                          |
| `image`            | file    | nullable, image, mimes:jpeg,png,jpg,gif, max:2048 |
| `initial_stock`    | integer | nullable, min:0                                   |
| `min_stock_level`  | integer | nullable, min:0                                   |
| `max_stock_level`  | integer | nullable, min:0                                   |
| `unit`             | string  | nullable, max:20                                  |

#### Response

```json
{
    "success": true,
    "message": "Menu item created successfully",
    "data": {
        "id": 1,
        "name": "Nasi Goreng",
        "price": "25000.00",
        "barcode": "MENU000001",
        "category": {
            "id": 1,
            "name": "Makanan"
        },
        "inventory": {
            "current_stock": 20,
            "min_stock_level": 5
        },
        "barcode": {
            "barcode_value": "MENU000001",
            "barcode_type": "QR"
        }
    }
}
```

### Update Menu Item

**PUT** `/admin/menu/{id}`

Mengupdate menu item yang sudah ada.

#### Path Parameters

| Parameter | Type    | Description  |
| --------- | ------- | ------------ |
| `id`      | integer | ID menu item |

#### Request Body

```json
{
    "name": "Nasi Goreng Updated",
    "price": 30000,
    "description": "Nasi goreng dengan telur dan ayam yang lebih enak"
}
```

#### Response

```json
{
    "success": true,
    "message": "Menu item updated successfully",
    "data": {
        "id": 1,
        "name": "Nasi Goreng Updated",
        "price": "30000.00"
    }
}
```

### Delete Menu Item

**DELETE** `/admin/menu/{id}`

Menghapus menu item.

#### Path Parameters

| Parameter | Type    | Description  |
| --------- | ------- | ------------ |
| `id`      | integer | ID menu item |

#### Response

```json
{
    "success": true,
    "message": "Menu item deleted successfully"
}
```

### Toggle Menu Availability

**POST** `/admin/menu/{id}/toggle`

Mengubah status ketersediaan menu item.

#### Path Parameters

| Parameter | Type    | Description  |
| --------- | ------- | ------------ |
| `id`      | integer | ID menu item |

#### Response

```json
{
    "success": true,
    "message": "Menu item availability toggled successfully",
    "data": {
        "id": 1,
        "is_available": false
    }
}
```

### Toggle Featured Status

**POST** `/admin/menu/{id}/featured`

Mengubah status featured menu item.

#### Path Parameters

| Parameter | Type    | Description  |
| --------- | ------- | ------------ |
| `id`      | integer | ID menu item |

#### Response

```json
{
    "success": true,
    "message": "Menu item featured status toggled successfully",
    "data": {
        "id": 1,
        "is_featured": true
    }
}
```

### Get Menu Analytics

**GET** `/admin/menu/analytics`

Mengambil analitik menu.

#### Query Parameters

| Parameter    | Type | Description                     |
| ------------ | ---- | ------------------------------- |
| `start_date` | date | Tanggal mulai filter (optional) |
| `end_date`   | date | Tanggal akhir filter (optional) |

#### Response

```json
{
    "success": true,
    "message": "Menu analytics retrieved successfully",
    "data": {
        "total_items": 10,
        "available_items": 8,
        "featured_items": 3,
        "low_stock_items": 2,
        "top_selling_items": [
            {
                "id": 1,
                "name": "Nasi Goreng",
                "category": "Makanan",
                "total_orders": 50,
                "total_revenue": "1250000.00"
            }
        ],
        "category_performance": [
            {
                "id": 1,
                "name": "Makanan",
                "total_items": 5,
                "available_items": 4,
                "total_orders": 100,
                "total_revenue": "2500000.00"
            }
        ],
        "price_analytics": {
            "average_price": "25000.00",
            "min_price": "10000.00",
            "max_price": "50000.00",
            "price_ranges": {
                "under_10k": 2,
                "10k_to_25k": 5,
                "25k_to_50k": 3,
                "over_50k": 0
            }
        }
    }
}
```

## Admin Menu Categories Endpoints

### Create Menu Category

**POST** `/admin/menu/categories`

Membuat kategori menu baru.

#### Request Body

```json
{
    "name": "Makanan",
    "description": "Menu makanan utama",
    "sort_order": 1
}
```

#### Validation Rules

| Field         | Type    | Rules                                             |
| ------------- | ------- | ------------------------------------------------- |
| `name`        | string  | required, max:255                                 |
| `description` | string  | nullable                                          |
| `sort_order`  | integer | nullable, min:0                                   |
| `image`       | file    | nullable, image, mimes:jpeg,png,jpg,gif, max:2048 |

#### Response

```json
{
    "success": true,
    "message": "Menu category created successfully",
    "data": {
        "id": 1,
        "name": "Makanan",
        "description": "Menu makanan utama",
        "sort_order": 1,
        "is_active": true
    }
}
```

### Update Menu Category

**PUT** `/admin/menu/categories/{id}`

Mengupdate kategori menu.

#### Path Parameters

| Parameter | Type    | Description      |
| --------- | ------- | ---------------- |
| `id`      | integer | ID kategori menu |

#### Request Body

```json
{
    "name": "Makanan Updated",
    "description": "Menu makanan utama yang lebih lengkap"
}
```

#### Response

```json
{
    "success": true,
    "message": "Menu category updated successfully",
    "data": {
        "id": 1,
        "name": "Makanan Updated",
        "description": "Menu makanan utama yang lebih lengkap"
    }
}
```

### Delete Menu Category

**DELETE** `/admin/menu/categories/{id}`

Menghapus kategori menu.

#### Path Parameters

| Parameter | Type    | Description      |
| --------- | ------- | ---------------- |
| `id`      | integer | ID kategori menu |

#### Response

```json
{
    "success": true,
    "message": "Menu category deleted successfully"
}
```

## Error Responses

### 400 Bad Request

```json
{
    "success": false,
    "message": "Search query is required"
}
```

### 401 Unauthorized

```json
{
    "message": "Unauthenticated."
}
```

### 403 Forbidden

```json
{
    "message": "This action is unauthorized."
}
```

### 404 Not Found

```json
{
    "success": false,
    "message": "Menu item not found"
}
```

### 422 Validation Error

```json
{
    "message": "The given data was invalid.",
    "errors": {
        "name": ["The name field is required."],
        "price": ["The price must be a number."]
    }
}
```

### 500 Internal Server Error

```json
{
    "success": false,
    "message": "Failed to create menu item: Cannot delete category with menu items"
}
```

## Business Rules

1. **Menu Item Creation**: Setiap menu item yang dibuat akan otomatis memiliki inventory record dan barcode.
2. **Category Deletion**: Kategori tidak dapat dihapus jika masih memiliki menu items.
3. **Menu Item Deletion**: Menu item tidak dapat dihapus jika masih memiliki active orders.
4. **Barcode Generation**: Barcode otomatis digenerate dengan format "MENU" + 6 digit angka.
5. **Image Upload**: Gambar menu disimpan di storage dengan path `menu-images/`.
6. **Stock Management**: Inventory otomatis dibuat saat menu item dibuat.
7. **Analytics**: Analytics dapat difilter berdasarkan tanggal untuk analisis periode tertentu.

## Rate Limiting

-   Member endpoints: 60 requests per minute
-   Admin endpoints: 100 requests per minute

## Notes

-   Semua harga menggunakan format decimal dengan 2 digit desimal
-   Barcode otomatis digenerate dan unik untuk setiap menu item
-   Image upload mendukung format JPEG, PNG, JPG, GIF dengan maksimal 2MB
-   Inventory tracking otomatis untuk setiap menu item
-   Analytics menyediakan insight komprehensif tentang performa menu
