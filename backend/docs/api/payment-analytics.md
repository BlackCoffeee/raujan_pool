# Payment Analytics API

## Overview

Payment Analytics API menyediakan endpoint untuk mengakses berbagai analisis dan statistik pembayaran dalam sistem. API ini dirancang untuk admin dan staff yang membutuhkan insight mendalam tentang performa pembayaran.

## Base URL

```
/api/v1/admin/payment-analytics
```

## Authentication

Semua endpoint memerlukan autentikasi dengan token Bearer dan role admin.

```http
Authorization: Bearer {token}
```

## Endpoints

### 1. Get Payment Analytics

Mendapatkan ringkasan lengkap analisis pembayaran.

```http
GET /api/v1/admin/payment-analytics/payments
```

#### Query Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `start_date` | string | No | Tanggal mulai (format: Y-m-d) |
| `end_date` | string | No | Tanggal akhir (format: Y-m-d) |
| `user_id` | integer | No | Filter berdasarkan user ID |
| `status` | string | No | Filter berdasarkan status pembayaran |
| `payment_method` | string | No | Filter berdasarkan metode pembayaran |

#### Response

```json
{
    "success": true,
    "message": "Payment analytics retrieved successfully",
    "data": {
        "payment_stats": {
            "total_payments": 150,
            "total_amount": 15000000,
            "average_amount": 100000,
            "pending_payments": 25,
            "verified_payments": 100,
            "rejected_payments": 15,
            "expired_payments": 5,
            "refunded_payments": 5
        },
        "revenue_stats": {
            "total_revenue": 15000000,
            "monthly_revenue": {
                "2024-01": 5000000,
                "2024-02": 5000000,
                "2024-03": 5000000
            },
            "yearly_revenue": {
                "2024": 15000000
            },
            "average_revenue_per_payment": 100000,
            "revenue_by_status": {
                "verified": 10000000,
                "pending": 2500000,
                "rejected": 1500000,
                "expired": 500000,
                "refunded": 500000
            }
        },
        "payment_method_stats": {
            "manual_transfer": {
                "count": 80,
                "total": 8000000,
                "average": 100000
            },
            "cash": {
                "count": 50,
                "total": 5000000,
                "average": 100000
            },
            "e_wallet": {
                "count": 20,
                "total": 2000000,
                "average": 100000
            }
        },
        "performance_metrics": {
            "verification_rate": 66.67,
            "rejection_rate": 10.0,
            "expiration_rate": 3.33,
            "total_processed": 115,
            "processing_efficiency": 76.67
        },
        "status_distribution": [
            {
                "status": "verified",
                "count": 100,
                "total": 10000000
            },
            {
                "status": "pending",
                "count": 25,
                "total": 2500000
            },
            {
                "status": "rejected",
                "count": 15,
                "total": 1500000
            }
        ]
    }
}
```

### 2. Get Revenue Analytics

Mendapatkan analisis detail tentang revenue dan tren pendapatan.

```http
GET /api/v1/admin/payment-analytics/revenue
```

#### Query Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `start_date` | string | No | Tanggal mulai (format: Y-m-d) |
| `end_date` | string | No | Tanggal akhir (format: Y-m-d) |
| `days` | integer | No | Jumlah hari untuk tren (default: 30) |

#### Response

```json
{
    "success": true,
    "message": "Revenue analytics retrieved successfully",
    "data": {
        "revenue_summary": {
            "gross_revenue": 15000000,
            "refunded_amount": 500000,
            "net_revenue": 14500000,
            "refund_rate": 3.33
        },
        "revenue_trends": [
            {
                "date": "2024-03-01",
                "total_payments": 5,
                "verified_payments": 3,
                "total_amount": 500000,
                "verified_amount": 300000
            }
        ],
        "monthly_revenue": [
            {
                "year": 2024,
                "month": 3,
                "total": 5000000
            }
        ],
        "yearly_revenue": [
            {
                "year": 2024,
                "total": 15000000
            }
        ],
        "revenue_forecast": [
            {
                "day": 1,
                "predicted_revenue": 520000
            }
        ]
    }
}
```

### 3. Get Payment Method Analytics

Mendapatkan analisis berdasarkan metode pembayaran.

```http
GET /api/v1/admin/payment-analytics/payment-methods
```

#### Response

```json
{
    "success": true,
    "message": "Payment method analytics retrieved successfully",
    "data": {
        "method_summary": [
            {
                "payment_method": "manual_transfer",
                "count": 80,
                "total": 8000000,
                "average": 100000
            }
        ],
        "method_trends": [
            {
                "date": "2024-03-01",
                "methods": {
                    "manual_transfer": {
                        "count": 3,
                        "total": 300000
                    }
                }
            }
        ],
        "method_performance": {
            "manual_transfer": {
                "conversion_rate": 85.0,
                "average_amount": 100000,
                "total_revenue": 8000000
            }
        },
        "method_conversion_rates": {
            "manual_transfer": 85.0,
            "cash": 90.0,
            "e_wallet": 75.0
        }
    }
}
```

### 4. Get Performance Metrics

Mendapatkan metrik performa pembayaran.

```http
GET /api/v1/admin/payment-analytics/performance
```

#### Response

```json
{
    "success": true,
    "message": "Performance metrics retrieved successfully",
    "data": {
        "verification_rate": 66.67,
        "rejection_rate": 10.0,
        "expiration_rate": 3.33,
        "total_processed": 115,
        "processing_efficiency": 76.67,
        "average_verification_time": 45.5,
        "average_payment_amount": 100000
    }
}
```

### 5. Get Payment Trends

Mendapatkan tren pembayaran dalam periode tertentu.

```http
GET /api/v1/admin/payment-analytics/trends
```

#### Query Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `days` | integer | No | Jumlah hari (default: 7) |
| `start_date` | string | No | Tanggal mulai (format: Y-m-d) |
| `end_date` | string | No | Tanggal akhir (format: Y-m-d) |

#### Response

```json
{
    "success": true,
    "message": "Payment trends retrieved successfully",
    "data": {
        "payment_trends": [
            {
                "date": "2024-03-01",
                "count": 5,
                "amount": 500000,
                "verified_count": 3,
                "pending_count": 2
            }
        ],
        "top_users": [
            {
                "user_id": 1,
                "payment_count": 10,
                "total_amount": 1000000,
                "user": {
                    "id": 1,
                    "name": "John Doe",
                    "email": "john@example.com"
                }
            }
        ],
        "trend_analysis": {
            "revenue_trend": "increasing",
            "payment_volume_trend": "stable",
            "average_daily_revenue": 500000,
            "average_daily_payments": 5
        },
        "seasonal_patterns": [
            {
                "month": 3,
                "day_of_week": 1,
                "hour": 9,
                "count": 2,
                "total": 200000
            }
        ],
        "growth_metrics": {
            "week_over_week_growth": 15.5,
            "first_week_revenue": 3000000,
            "last_week_revenue": 3500000
        }
    }
}
```

### 6. Generate Payment Report

Membuat laporan pembayaran yang komprehensif.

```http
GET /api/v1/admin/payment-analytics/report
```

#### Query Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `start_date` | string | No | Tanggal mulai (format: Y-m-d) |
| `end_date` | string | No | Tanggal akhir (format: Y-m-d) |
| `include_recommendations` | boolean | No | Sertakan rekomendasi (default: true) |

#### Response

```json
{
    "success": true,
    "message": "Payment report generated successfully",
    "data": {
        "executive_summary": {
            "total_payments": 150,
            "total_revenue": 14500000,
            "verification_rate": 66.67,
            "average_payment_amount": 100000,
            "refund_rate": 3.33
        },
        "payment_analytics": {
            "payment_stats": { ... },
            "revenue_stats": { ... },
            "performance_metrics": { ... }
        },
        "trends_and_insights": {
            "revenue_trends": { ... },
            "payment_patterns": { ... },
            "seasonal_analysis": { ... }
        },
        "recommendations": [
            "Tingkatkan verifikasi pembayaran manual transfer",
            "Optimalkan proses verifikasi untuk mengurangi waktu tunggu",
            "Pertimbangkan promosi untuk metode pembayaran e-wallet"
        ],
        "risk_assessment": {
            "high_risk_payments": 5,
            "suspicious_patterns": 2,
            "recommended_actions": [
                "Review pembayaran dengan nilai tinggi",
                "Monitor pola pembayaran mencurigakan"
            ]
        }
    }
}
```

### 7. Export Payment Data

Mengekspor data pembayaran dalam format CSV atau JSON.

```http
GET /api/v1/admin/payment-analytics/export
```

#### Query Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `format` | string | Yes | Format ekspor: `csv` atau `json` |
| `start_date` | string | No | Tanggal mulai (format: Y-m-d) |
| `end_date` | string | No | Tanggal akhir (format: Y-m-d) |
| `fields` | array | No | Field yang akan diekspor |

#### Response

**CSV Format:**
```http
Content-Type: text/csv
Content-Disposition: attachment; filename="payment_data_2024-03-01.csv"
```

**JSON Format:**
```json
{
    "success": true,
    "message": "Payment data exported successfully",
    "data": [
        {
            "id": 1,
            "reference_number": "PAY-001",
            "user_name": "John Doe",
            "amount": 100000,
            "status": "verified",
            "payment_method": "manual_transfer",
            "created_at": "2024-03-01T10:00:00Z",
            "verified_at": "2024-03-01T10:30:00Z"
        }
    ]
}
```

### 8. Get Dashboard Data

Mendapatkan data untuk dashboard admin.

```http
GET /api/v1/admin/payment-analytics/dashboard
```

#### Response

```json
{
    "success": true,
    "message": "Dashboard data retrieved successfully",
    "data": {
        "quick_stats": {
            "today_payments": 15,
            "today_revenue": 1500000,
            "pending_verifications": 8,
            "month_to_date_revenue": 15000000
        },
        "recent_activity": [
            {
                "id": 1,
                "user_name": "John Doe",
                "amount": 100000,
                "status": "verified",
                "created_at": "2024-03-01T10:00:00Z"
            }
        ],
        "payment_alerts": [
            {
                "type": "high_pending",
                "message": "Ada 8 pembayaran pending yang perlu diverifikasi",
                "count": 8
            }
        ],
        "revenue_chart": {
            "labels": ["Mar 1", "Mar 2", "Mar 3"],
            "data": [500000, 600000, 450000]
        }
    }
}
```

## Error Responses

### 400 Bad Request

```json
{
    "success": false,
    "message": "Invalid date format. Use Y-m-d format",
    "data": null
}
```

### 401 Unauthorized

```json
{
    "success": false,
    "message": "Unauthenticated",
    "data": null
}
```

### 403 Forbidden

```json
{
    "success": false,
    "message": "Access denied. Admin role required",
    "data": null
}
```

### 500 Internal Server Error

```json
{
    "success": false,
    "message": "Failed to generate analytics",
    "data": null
}
```

## Rate Limiting

API ini memiliki rate limiting:
- **Default**: 60 requests per minute per user
- **Export endpoints**: 10 requests per minute per user

## Data Formats

### Date Format
Semua tanggal menggunakan format ISO 8601: `Y-m-d` atau `Y-m-d H:i:s`

### Amount Format
Semua jumlah uang dalam satuan kopeck (sen) untuk presisi tinggi.

### Status Values
- `pending`: Menunggu verifikasi
- `verified`: Sudah diverifikasi
- `rejected`: Ditolak
- `expired`: Kadaluarsa
- `refunded`: Dikembalikan

### Payment Method Values
- `manual_transfer`: Transfer manual
- `cash`: Tunai
- `e_wallet`: E-wallet
- `credit_card`: Kartu kredit
- `debit_card`: Kartu debit

## Examples

### cURL Examples

**Get Payment Analytics:**
```bash
curl -X GET "http://localhost:8000/api/v1/admin/payment-analytics/payments" \
  -H "Authorization: Bearer {token}" \
  -H "Accept: application/json"
```

**Get Revenue Analytics with Date Filter:**
```bash
curl -X GET "http://localhost:8000/api/v1/admin/payment-analytics/revenue?start_date=2024-01-01&end_date=2024-03-31" \
  -H "Authorization: Bearer {token}" \
  -H "Accept: application/json"
```

**Export Payment Data as CSV:**
```bash
curl -X GET "http://localhost:8000/api/v1/admin/payment-analytics/export?format=csv&start_date=2024-01-01" \
  -H "Authorization: Bearer {token}" \
  -H "Accept: text/csv" \
  -o payment_data.csv
```

### JavaScript Examples

**Get Payment Analytics:**
```javascript
const response = await fetch('/api/v1/admin/payment-analytics/payments', {
    headers: {
        'Authorization': `Bearer ${token}`,
        'Accept': 'application/json'
    }
});

const data = await response.json();
console.log(data.data.payment_stats);
```

**Get Revenue Analytics:**
```javascript
const response = await fetch('/api/v1/admin/payment-analytics/revenue?days=30', {
    headers: {
        'Authorization': `Bearer ${token}`,
        'Accept': 'application/json'
    }
});

const data = await response.json();
console.log(data.data.revenue_trends);
```

## Notes

1. **Performance**: Untuk query dengan range tanggal yang besar, gunakan parameter `start_date` dan `end_date` untuk membatasi data.
2. **Caching**: Beberapa endpoint menggunakan caching untuk meningkatkan performa. Cache akan di-refresh setiap 15 menit.
3. **Timezone**: Semua waktu menggunakan timezone server (Asia/Jakarta).
4. **Pagination**: Endpoint yang mengembalikan data dalam jumlah besar akan otomatis dipaginasi.
5. **Filtering**: Semua filter bersifat opsional dan dapat dikombinasikan.

## Support

Untuk pertanyaan atau bantuan teknis, hubungi tim development atau buat issue di repository project.
