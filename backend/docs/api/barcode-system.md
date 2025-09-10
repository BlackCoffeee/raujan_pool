# Barcode System API Documentation

## Overview

Sistem barcode memungkinkan pengelolaan barcode dan QR code untuk menu items dengan fitur generation, scanning, validation, dan analytics.

## Features

-   ✅ Barcode generation (QR, CODE128, EAN13)
-   ✅ Barcode scanning dan validation
-   ✅ Barcode management (activate/deactivate/regenerate)
-   ✅ QR code generation dengan menu information
-   ✅ Barcode analytics dan statistics
-   ✅ Bulk barcode generation
-   ✅ Barcode download

## API Endpoints

### Member Endpoints

#### Scan Barcode

```http
POST /api/v1/members/barcode/scan
```

**Request Body:**

```json
{
    "barcode_value": "QR000001",
    "scan_type": "menu_access",
    "location": {
        "latitude": -6.2,
        "longitude": 106.816666
    }
}
```

**Response:**

```json
{
    "success": true,
    "message": "Barcode scanned successfully",
    "data": {
        "barcode": {
            "id": 1,
            "barcode_value": "QR000001",
            "barcode_type": "QR",
            "is_active": true,
            "qr_code_url": "http://localhost/storage/barcodes/qr-codes/qr_QR000001_menu-item.png"
        },
        "menu_item": {
            "id": 1,
            "name": "Nasi Goreng",
            "price": 25000,
            "description": "Nasi goreng dengan telur dan ayam"
        }
    }
}
```

#### Validate Barcode

```http
POST /api/v1/members/barcode/validate
```

**Request Body:**

```json
{
    "barcode_value": "QR000001"
}
```

**Response:**

```json
{
    "success": true,
    "message": "Barcode is valid",
    "data": {
        "valid": true,
        "barcode": {
            "id": 1,
            "barcode_value": "QR000001",
            "barcode_type": "QR"
        },
        "menu_item": {
            "id": 1,
            "name": "Nasi Goreng",
            "price": 25000
        }
    }
}
```

#### Get Barcode by Code

```http
GET /api/v1/members/barcode/{code}
```

**Response:**

```json
{
    "success": true,
    "message": "Barcode information retrieved successfully",
    "data": {
        "barcode": {
            "id": 1,
            "barcode_value": "QR000001",
            "barcode_type": "QR",
            "is_active": true,
            "qr_code_url": "http://localhost/storage/barcodes/qr-codes/qr_QR000001_menu-item.png"
        },
        "menu_item": {
            "id": 1,
            "name": "Nasi Goreng",
            "price": 25000,
            "description": "Nasi goreng dengan telur dan ayam",
            "is_available": true
        }
    }
}
```

### Admin Endpoints

#### List Barcodes

```http
GET /api/v1/admin/barcodes
```

**Query Parameters:**

-   `menu_item_id` - Filter by menu item ID
-   `barcode_type` - Filter by barcode type (QR, CODE128, EAN13)
-   `is_active` - Filter by active status
-   `start_date` - Filter by start date
-   `end_date` - Filter by end date
-   `per_page` - Number of items per page (default: 15)

**Response:**

```json
{
    "success": true,
    "message": "Barcodes retrieved successfully",
    "data": {
        "data": [
            {
                "id": 1,
                "menu_item_id": 1,
                "barcode_value": "QR000001",
                "barcode_type": "QR",
                "qr_code_path": "barcodes/qr-codes/qr_QR000001_menu-item.png",
                "is_active": true,
                "created_at": "2025-09-04T14:00:00.000000Z",
                "updated_at": "2025-09-04T14:00:00.000000Z",
                "menu_item": {
                    "id": 1,
                    "name": "Nasi Goreng",
                    "price": 25000
                }
            }
        ],
        "links": {...},
        "meta": {...}
    }
}
```

#### Generate Barcode

```http
POST /api/v1/admin/barcodes/generate
```

**Request Body:**

```json
{
    "menu_item_id": 1,
    "barcode_type": "QR"
}
```

**Response:**

```json
{
    "success": true,
    "message": "Barcode generated successfully",
    "data": {
        "id": 1,
        "menu_item_id": 1,
        "barcode_value": "QR000001",
        "barcode_type": "QR",
        "qr_code_path": "barcodes/qr-codes/qr_QR000001_menu-item.png",
        "is_active": true,
        "menu_item": {
            "id": 1,
            "name": "Nasi Goreng",
            "price": 25000
        }
    }
}
```

#### Get Barcode Details

```http
GET /api/v1/admin/barcodes/{id}
```

**Response:**

```json
{
    "success": true,
    "message": "Barcode retrieved successfully",
    "data": {
        "id": 1,
        "menu_item_id": 1,
        "barcode_value": "QR000001",
        "barcode_type": "QR",
        "qr_code_path": "barcodes/qr-codes/qr_QR000001_menu-item.png",
        "is_active": true,
        "created_at": "2025-09-04T14:00:00.000000Z",
        "updated_at": "2025-09-04T14:00:00.000000Z",
        "menu_item": {
            "id": 1,
            "name": "Nasi Goreng",
            "price": 25000
        },
        "scans": [
            {
                "id": 1,
                "scanned_by": 1,
                "scan_type": "menu_access",
                "is_successful": true,
                "created_at": "2025-09-04T14:05:00.000000Z"
            }
        ]
    }
}
```

#### Update Barcode

```http
PUT /api/v1/admin/barcodes/{id}
```

**Request Body:**

```json
{
    "is_active": false
}
```

**Response:**

```json
{
    "success": true,
    "message": "Barcode updated successfully",
    "data": {
        "id": 1,
        "menu_item_id": 1,
        "barcode_value": "QR000001",
        "barcode_type": "QR",
        "is_active": false,
        "menu_item": {
            "id": 1,
            "name": "Nasi Goreng",
            "price": 25000
        }
    }
}
```

#### Delete Barcode

```http
DELETE /api/v1/admin/barcodes/{id}
```

**Response:**

```json
{
    "success": true,
    "message": "Barcode deleted successfully"
}
```

#### Regenerate Barcode

```http
POST /api/v1/admin/barcodes/{id}/regenerate
```

**Response:**

```json
{
    "success": true,
    "message": "Barcode regenerated successfully",
    "data": {
        "id": 1,
        "menu_item_id": 1,
        "barcode_value": "QR000002",
        "barcode_type": "QR",
        "qr_code_path": "barcodes/qr-codes/qr_QR000002_menu-item.png",
        "is_active": true,
        "menu_item": {
            "id": 1,
            "name": "Nasi Goreng",
            "price": 25000
        }
    }
}
```

#### Activate Barcode

```http
POST /api/v1/admin/barcodes/{id}/activate
```

**Response:**

```json
{
    "success": true,
    "message": "Barcode activated successfully",
    "data": {
        "id": 1,
        "is_active": true,
        "menu_item": {
            "id": 1,
            "name": "Nasi Goreng",
            "price": 25000
        }
    }
}
```

#### Deactivate Barcode

```http
POST /api/v1/admin/barcodes/{id}/deactivate
```

**Response:**

```json
{
    "success": true,
    "message": "Barcode deactivated successfully",
    "data": {
        "id": 1,
        "is_active": false,
        "menu_item": {
            "id": 1,
            "name": "Nasi Goreng",
            "price": 25000
        }
    }
}
```

#### Download Barcode

```http
GET /api/v1/admin/barcodes/{id}/download
```

**Response:** File download (PNG image)

#### Bulk Generate Barcodes

```http
POST /api/v1/admin/barcodes/bulk-generate
```

**Request Body:**

```json
{
    "menu_item_ids": [1, 2, 3],
    "barcode_type": "QR"
}
```

**Response:**

```json
{
    "success": true,
    "message": "Bulk barcode generation completed",
    "data": [
        {
            "menu_item_id": 1,
            "success": true,
            "barcode_id": 1,
            "barcode_value": "QR000001"
        },
        {
            "menu_item_id": 2,
            "success": true,
            "barcode_id": 2,
            "barcode_value": "QR000002"
        },
        {
            "menu_item_id": 3,
            "success": false,
            "error": "Menu item not found"
        }
    ]
}
```

#### Get Barcode Statistics

```http
GET /api/v1/admin/barcodes/stats
```

**Query Parameters:**

-   `start_date` - Filter by start date
-   `end_date` - Filter by end date

**Response:**

```json
{
    "success": true,
    "message": "Barcode statistics retrieved successfully",
    "data": {
        "total_barcodes": 100,
        "active_barcodes": 95,
        "inactive_barcodes": 5,
        "qr_codes": 80,
        "code128_barcodes": 15,
        "ean13_barcodes": 5,
        "total_scans": 1250,
        "successful_scans": 1200,
        "failed_scans": 50
    }
}
```

#### Get Barcode Analytics

```http
GET /api/v1/admin/barcodes/analytics
```

**Query Parameters:**

-   `start_date` - Filter by start date
-   `end_date` - Filter by end date

**Response:**

```json
{
    "success": true,
    "message": "Barcode analytics retrieved successfully",
    "data": {
        "scan_analytics": {
            "total_scans": 1250,
            "successful_scans": 1200,
            "failed_scans": 50,
            "success_rate": 96.0
        },
        "barcode_types": [
            {
                "type": "QR",
                "count": 80,
                "percentage": 80.0
            },
            {
                "type": "CODE128",
                "count": 15,
                "percentage": 15.0
            },
            {
                "type": "EAN13",
                "count": 5,
                "percentage": 5.0
            }
        ],
        "top_scanned_barcodes": [
            {
                "id": 1,
                "barcode_value": "QR000001",
                "menu_item_name": "Nasi Goreng",
                "scan_count": 150,
                "last_scanned": "2025-09-04T14:00:00.000000Z"
            }
        ],
        "scan_trends": [
            {
                "date": "2025-09-01",
                "total_scans": 45,
                "successful_scans": 43,
                "failed_scans": 2
            }
        ],
        "scan_locations": [
            {
                "location": {
                    "latitude": -6.2,
                    "longitude": 106.816666
                },
                "scan_count": 25
            }
        ]
    }
}
```

## Error Responses

### 400 Bad Request

```json
{
    "success": false,
    "message": "Invalid barcode",
    "data": null
}
```

### 404 Not Found

```json
{
    "success": false,
    "message": "Barcode not found",
    "data": null
}
```

### 403 Forbidden

```json
{
    "success": false,
    "message": "Unauthorized access",
    "data": null
}
```

## Barcode Types

-   **QR**: QR Code (default)
-   **CODE128**: Code 128 barcode
-   **EAN13**: EAN-13 barcode

## Scan Types

-   **menu_access**: Accessing menu via barcode scan
-   **order_placement**: Placing order via barcode scan
-   **inventory_check**: Checking inventory via barcode scan
-   **admin_scan**: Admin scanning for management purposes

## QR Code Content

QR code berisi informasi JSON dengan struktur:

```json
{
    "barcode": "QR000001",
    "menu_item_id": 1,
    "menu_item_name": "Nasi Goreng",
    "price": 25000,
    "url": "http://localhost/menu/1"
}
```

## File Storage

-   QR code images disimpan di `storage/app/public/barcodes/qr-codes/`
-   Format file: `qr_{barcode_value}_{menu_slug}.png`
-   Size: 300x300 pixels dengan margin 2px
