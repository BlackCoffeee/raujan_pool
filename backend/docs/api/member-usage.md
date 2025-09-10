# Member Usage API

API untuk tracking penggunaan member dan history.

## Base URL

```
GET /api/v1/member-usage
```

## Authentication

-   **Required**: Bearer Token (Member role)
-   **Header**: `Authorization: Bearer {token}`

## Endpoints

### 1. Member Usage History

```http
GET /api/v1/member-usage/history
```

**Query Parameters:**

-   `page` (optional): Halaman (default: 1)
-   `per_page` (optional): Jumlah data per halaman (default: 15)
-   `date_from` (optional): Tanggal mulai (YYYY-MM-DD)
-   `date_to` (optional): Tanggal akhir (YYYY-MM-DD)

**Response:**

```json
{
    "success": true,
    "data": {
        "usage_history": [
            {
                "id": 1,
                "booking_id": 1,
                "booking_code": "BK001",
                "session_name": "Morning Session",
                "booking_date": "2024-01-15",
                "start_time": "08:00",
                "end_time": "10:00",
                "status": "completed",
                "used_at": "2024-01-15T08:00:00Z"
            }
        ],
        "pagination": {
            "current_page": 1,
            "per_page": 15,
            "total": 25,
            "last_page": 2
        }
    }
}
```

### 2. Member Usage Statistics

```http
GET /api/v1/member-usage/statistics
```

**Query Parameters:**

-   `period` (optional): `week`, `month`, `year` (default: `month`)

**Response:**

```json
{
    "success": true,
    "data": {
        "total_usage": 25,
        "period": "month",
        "usage_by_period": [
            {
                "date": "2024-01-01",
                "usage_count": 3
            }
        ],
        "usage_by_session": [
            {
                "session_name": "Morning Session",
                "usage_count": 15,
                "percentage": 60.0
            }
        ],
        "average_usage_per_week": 6.25
    }
}
```

### 3. Member Quota Information

```http
GET /api/v1/member-usage/quota
```

**Response:**

```json
{
    "success": true,
    "data": {
        "membership_type": "monthly",
        "quota_limit": 20,
        "quota_used": 15,
        "quota_remaining": 5,
        "quota_percentage": 75.0,
        "membership_expires_at": "2024-02-15T23:59:59Z",
        "days_remaining": 15
    }
}
```

### 4. Member Usage Summary

```http
GET /api/v1/member-usage/summary
```

**Response:**

```json
{
    "success": true,
    "data": {
        "current_month": {
            "usage_count": 8,
            "quota_used": 8,
            "quota_remaining": 12
        },
        "last_month": {
            "usage_count": 12,
            "quota_used": 12,
            "quota_remaining": 8
        },
        "total_usage": 25,
        "membership_start_date": "2024-01-01",
        "membership_end_date": "2024-02-15"
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
    "message": "Access denied. Member role required."
}
```

### 404 Not Found

```json
{
    "success": false,
    "message": "Member not found"
}
```

## Frontend Integration Examples

### JavaScript/Axios

```javascript
// Get member usage history
const getMemberUsageHistory = async (
    page = 1,
    dateFrom = null,
    dateTo = null
) => {
    try {
        const params = { page };
        if (dateFrom) params.date_from = dateFrom;
        if (dateTo) params.date_to = dateTo;

        const response = await axios.get("/api/v1/member-usage/history", {
            params,
            headers: {
                Authorization: `Bearer ${token}`,
                Accept: "application/json",
            },
        });
        return response.data;
    } catch (error) {
        console.error("Error fetching usage history:", error);
    }
};

// Get member quota information
const getMemberQuota = async () => {
    try {
        const response = await axios.get("/api/v1/member-usage/quota", {
            headers: {
                Authorization: `Bearer ${token}`,
                Accept: "application/json",
            },
        });
        return response.data;
    } catch (error) {
        console.error("Error fetching quota:", error);
    }
};
```

### React Hook

```jsx
import { useState, useEffect } from "react";
import axios from "axios";

const useMemberUsage = () => {
    const [usageHistory, setUsageHistory] = useState([]);
    const [quota, setQuota] = useState(null);
    const [loading, setLoading] = useState(true);

    useEffect(() => {
        const fetchMemberData = async () => {
            try {
                const [historyResponse, quotaResponse] = await Promise.all([
                    axios.get("/api/v1/member-usage/history", {
                        headers: {
                            Authorization: `Bearer ${localStorage.getItem(
                                "token"
                            )}`,
                            Accept: "application/json",
                        },
                    }),
                    axios.get("/api/v1/member-usage/quota", {
                        headers: {
                            Authorization: `Bearer ${localStorage.getItem(
                                "token"
                            )}`,
                            Accept: "application/json",
                        },
                    }),
                ]);

                setUsageHistory(historyResponse.data.data.usage_history);
                setQuota(quotaResponse.data.data);
            } catch (error) {
                console.error("Error fetching member data:", error);
            } finally {
                setLoading(false);
            }
        };

        fetchMemberData();
    }, []);

    return { usageHistory, quota, loading };
};
```

### Vue.js Component

```vue
<template>
    <div>
        <h2>Member Usage</h2>
        <div v-if="loading">Loading...</div>
        <div v-else>
            <div class="quota-info">
                <h3>Quota Information</h3>
                <p>Used: {{ quota?.quota_used }}/{{ quota?.quota_limit }}</p>
                <p>Remaining: {{ quota?.quota_remaining }}</p>
                <p>Expires: {{ formatDate(quota?.membership_expires_at) }}</p>
            </div>

            <div class="usage-history">
                <h3>Usage History</h3>
                <div
                    v-for="usage in usageHistory"
                    :key="usage.id"
                    class="usage-item"
                >
                    <span
                        >{{ usage.booking_code }} -
                        {{ usage.session_name }}</span
                    >
                    <span>{{ formatDate(usage.used_at) }}</span>
                </div>
            </div>
        </div>
    </div>
</template>

<script setup>
import { ref, onMounted } from "vue";
import axios from "axios";

const usageHistory = ref([]);
const quota = ref(null);
const loading = ref(true);

const fetchMemberData = async () => {
    try {
        const [historyResponse, quotaResponse] = await Promise.all([
            axios.get("/api/v1/member-usage/history", {
                headers: {
                    Authorization: `Bearer ${localStorage.getItem("token")}`,
                    Accept: "application/json",
                },
            }),
            axios.get("/api/v1/member-usage/quota", {
                headers: {
                    Authorization: `Bearer ${localStorage.getItem("token")}`,
                    Accept: "application/json",
                },
            }),
        ]);

        usageHistory.value = historyResponse.data.data.usage_history;
        quota.value = quotaResponse.data.data;
    } catch (error) {
        console.error("Error fetching member data:", error);
    } finally {
        loading.value = false;
    }
};

const formatDate = (dateString) => {
    return new Date(dateString).toLocaleDateString("id-ID");
};

onMounted(() => {
    fetchMemberData();
});
</script>
```

## Notes

-   Semua endpoint memerlukan autentikasi member
-   Data usage history dapat difilter berdasarkan tanggal
-   Quota information menampilkan informasi membership saat ini
-   Statistics memberikan analisis penggunaan member
-   Pagination tersedia untuk usage history
