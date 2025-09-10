# Analytics API

API untuk analisis dan dashboard admin.

## Base URL

```
GET /api/v1/admin/analytics
```

## Authentication

-   **Required**: Bearer Token (Admin role)
-   **Header**: `Authorization: Bearer {token}`

## Endpoints

### 1. Dashboard Overview

```http
GET /api/v1/admin/analytics/dashboard
```

**Response:**

```json
{
    "success": true,
    "data": {
        "total_revenue": 15000000,
        "total_bookings": 250,
        "total_members": 45,
        "total_users": 120,
        "revenue_today": 500000,
        "bookings_today": 8,
        "active_members": 35,
        "new_users_today": 3
    }
}
```

### 2. Revenue Analytics

```http
GET /api/v1/admin/analytics/revenue?period=month&year=2024
```

**Parameters:**

-   `period` (optional): `day`, `week`, `month`, `year` (default: `month`)
-   `year` (optional): Tahun (default: tahun saat ini)
-   `month` (optional): Bulan (1-12, hanya untuk period=month)

**Response:**

```json
{
    "success": true,
    "data": {
        "total_revenue": 15000000,
        "period": "month",
        "year": 2024,
        "month": 1,
        "daily_revenue": [
            {
                "date": "2024-01-01",
                "revenue": 500000,
                "bookings": 8
            }
        ],
        "growth_percentage": 15.5
    }
}
```

### 3. User Analytics

```http
GET /api/v1/admin/analytics/users?period=month
```

**Response:**

```json
{
    "success": true,
    "data": {
        "total_users": 120,
        "new_users": 15,
        "active_users": 85,
        "user_growth": [
            {
                "date": "2024-01-01",
                "new_users": 3,
                "total_users": 120
            }
        ],
        "user_roles": {
            "admin": 2,
            "staff": 5,
            "member": 45,
            "regular": 68
        }
    }
}
```

### 4. Booking Analytics

```http
GET /api/v1/admin/analytics/bookings?period=week
```

**Response:**

```json
{
    "success": true,
    "data": {
        "total_bookings": 250,
        "successful_bookings": 240,
        "cancelled_bookings": 10,
        "booking_trends": [
            {
                "date": "2024-01-01",
                "bookings": 8,
                "revenue": 500000
            }
        ],
        "popular_sessions": [
            {
                "session_name": "Morning Session",
                "bookings": 45,
                "revenue": 2250000
            }
        ]
    }
}
```

### 5. Payment Method Analytics

```http
GET /api/v1/admin/analytics/payment-methods
```

**Response:**

```json
{
    "success": true,
    "data": {
        "payment_methods": [
            {
                "method": "credit_card",
                "count": 120,
                "total_amount": 6000000,
                "percentage": 40.0
            },
            {
                "method": "bank_transfer",
                "count": 80,
                "total_amount": 4000000,
                "percentage": 26.7
            }
        ],
        "total_transactions": 300,
        "total_amount": 15000000
    }
}
```

### 6. Member Analytics

```http
GET /api/v1/admin/analytics/members
```

**Response:**

```json
{
    "success": true,
    "data": {
        "total_members": 45,
        "active_members": 35,
        "expired_members": 10,
        "membership_types": {
            "monthly": 25,
            "quarterly": 15,
            "yearly": 5
        },
        "member_usage": [
            {
                "member_id": 1,
                "name": "John Doe",
                "usage_count": 15,
                "last_visit": "2024-01-15"
            }
        ]
    }
}
```

## Error Responses

### 401 Unauthorized

```json
{
    "success": false,
    "message": "Unauthorized"
}
```

### 403 Forbidden

```json
{
    "success": false,
    "message": "Access denied. Admin role required."
}
```

### 422 Validation Error

```json
{
    "success": false,
    "message": "Validation failed",
    "errors": {
        "period": ["The period field is required."]
    }
}
```

## Frontend Integration Examples

### JavaScript/Axios

```javascript
// Dashboard overview
const getDashboard = async () => {
    try {
        const response = await axios.get("/api/v1/admin/analytics/dashboard", {
            headers: {
                Authorization: `Bearer ${token}`,
                Accept: "application/json",
            },
        });
        return response.data;
    } catch (error) {
        console.error("Error fetching dashboard:", error);
    }
};

// Revenue analytics with filters
const getRevenueAnalytics = async (
    period = "month",
    year = new Date().getFullYear()
) => {
    try {
        const response = await axios.get("/api/v1/admin/analytics/revenue", {
            params: { period, year },
            headers: {
                Authorization: `Bearer ${token}`,
                Accept: "application/json",
            },
        });
        return response.data;
    } catch (error) {
        console.error("Error fetching revenue analytics:", error);
    }
};
```

### React Hook

```jsx
import { useState, useEffect } from "react";
import axios from "axios";

const useAnalytics = () => {
    const [dashboard, setDashboard] = useState(null);
    const [loading, setLoading] = useState(true);

    useEffect(() => {
        const fetchDashboard = async () => {
            try {
                const response = await axios.get(
                    "/api/v1/admin/analytics/dashboard",
                    {
                        headers: {
                            Authorization: `Bearer ${localStorage.getItem(
                                "token"
                            )}`,
                            Accept: "application/json",
                        },
                    }
                );
                setDashboard(response.data.data);
            } catch (error) {
                console.error("Error fetching dashboard:", error);
            } finally {
                setLoading(false);
            }
        };

        fetchDashboard();
    }, []);

    return { dashboard, loading };
};
```

### Vue.js Composition API

```vue
<template>
    <div>
        <div v-if="loading">Loading...</div>
        <div v-else>
            <h2>Dashboard</h2>
            <p>Total Revenue: {{ formatCurrency(dashboard?.total_revenue) }}</p>
            <p>Total Bookings: {{ dashboard?.total_bookings }}</p>
        </div>
    </div>
</template>

<script setup>
import { ref, onMounted } from "vue";
import axios from "axios";

const dashboard = ref(null);
const loading = ref(true);

const fetchDashboard = async () => {
    try {
        const response = await axios.get("/api/v1/admin/analytics/dashboard", {
            headers: {
                Authorization: `Bearer ${localStorage.getItem("token")}`,
                Accept: "application/json",
            },
        });
        dashboard.value = response.data.data;
    } catch (error) {
        console.error("Error fetching dashboard:", error);
    } finally {
        loading.value = false;
    }
};

const formatCurrency = (amount) => {
    return new Intl.NumberFormat("id-ID", {
        style: "currency",
        currency: "IDR",
    }).format(amount);
};

onMounted(() => {
    fetchDashboard();
});
</script>
```

## Notes

-   Semua endpoint memerlukan autentikasi admin
-   Data analytics dihitung secara real-time
-   Period filter mendukung berbagai format waktu
-   Response selalu dalam format JSON dengan struktur yang konsisten
