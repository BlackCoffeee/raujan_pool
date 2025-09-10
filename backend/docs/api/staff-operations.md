# Staff Operations API

API untuk operasi front desk dan verifikasi pembayaran oleh staff.

## Base URL

```
GET /api/v1/staff
```

## Authentication

-   **Required**: Bearer Token (Staff role)
-   **Header**: `Authorization: Bearer {token}`

## Endpoints

### 1. Staff Dashboard

```http
GET /api/v1/staff/dashboard
```

**Response:**

```json
{
    "success": true,
    "data": {
        "today_bookings": 15,
        "pending_payments": 8,
        "checked_in": 12,
        "checked_out": 3,
        "recent_bookings": [
            {
                "id": 1,
                "booking_code": "BK001",
                "customer_name": "John Doe",
                "session_name": "Morning Session",
                "booking_date": "2024-01-15",
                "status": "confirmed",
                "payment_status": "paid"
            }
        ]
    }
}
```

### 2. Today's Bookings

```http
GET /api/v1/staff/bookings/today
```

**Query Parameters:**

-   `status` (optional): `pending`, `confirmed`, `cancelled`
-   `payment_status` (optional): `pending`, `paid`, `failed`

**Response:**

```json
{
    "success": true,
    "data": {
        "bookings": [
            {
                "id": 1,
                "booking_code": "BK001",
                "customer_name": "John Doe",
                "customer_phone": "081234567890",
                "session_name": "Morning Session",
                "booking_date": "2024-01-15",
                "start_time": "08:00",
                "end_time": "10:00",
                "status": "confirmed",
                "payment_status": "paid",
                "total_amount": 50000,
                "created_at": "2024-01-15T08:00:00Z"
            }
        ],
        "total": 15,
        "pending": 3,
        "confirmed": 10,
        "cancelled": 2
    }
}
```

### 3. Check-in Booking

```http
POST /api/v1/staff/bookings/{booking_id}/checkin
```

**Request Body:**

```json
{
    "notes": "Customer arrived on time"
}
```

**Response:**

```json
{
    "success": true,
    "message": "Customer checked in successfully",
    "data": {
        "booking_id": 1,
        "checkin_time": "2024-01-15T08:05:00Z",
        "status": "checked_in"
    }
}
```

### 4. Check-out Booking

```http
POST /api/v1/staff/bookings/{booking_id}/checkout
```

**Request Body:**

```json
{
    "notes": "Customer completed session"
}
```

**Response:**

```json
{
    "success": true,
    "message": "Customer checked out successfully",
    "data": {
        "booking_id": 1,
        "checkout_time": "2024-01-15T10:00:00Z",
        "status": "completed"
    }
}
```

### 5. Pending Payments

```http
GET /api/v1/staff/payments/pending
```

**Response:**

```json
{
    "success": true,
    "data": {
        "payments": [
            {
                "id": 1,
                "booking_id": 1,
                "booking_code": "BK001",
                "customer_name": "John Doe",
                "amount": 50000,
                "payment_method": "bank_transfer",
                "payment_proof": "https://example.com/proof.jpg",
                "submitted_at": "2024-01-15T07:30:00Z",
                "status": "pending"
            }
        ],
        "total": 8,
        "total_amount": 400000
    }
}
```

### 6. Verify Payment

```http
POST /api/v1/staff/payments/{payment_id}/verify
```

**Request Body:**

```json
{
    "notes": "Payment verified successfully"
}
```

**Response:**

```json
{
    "success": true,
    "message": "Payment verified successfully",
    "data": {
        "payment_id": 1,
        "status": "verified",
        "verified_at": "2024-01-15T08:00:00Z",
        "verified_by": "Staff Name"
    }
}
```

### 7. Reject Payment

```http
POST /api/v1/staff/payments/{payment_id}/reject
```

**Request Body:**

```json
{
    "reason": "Invalid payment proof",
    "notes": "Please resubmit with valid proof"
}
```

**Response:**

```json
{
    "success": true,
    "message": "Payment rejected",
    "data": {
        "payment_id": 1,
        "status": "rejected",
        "rejected_at": "2024-01-15T08:00:00Z",
        "rejected_by": "Staff Name",
        "reason": "Invalid payment proof"
    }
}
```

### 8. Booking Details

```http
GET /api/v1/staff/bookings/{booking_id}
```

**Response:**

```json
{
    "success": true,
    "data": {
        "id": 1,
        "booking_code": "BK001",
        "customer_name": "John Doe",
        "customer_phone": "081234567890",
        "customer_email": "john@example.com",
        "session_name": "Morning Session",
        "booking_date": "2024-01-15",
        "start_time": "08:00",
        "end_time": "10:00",
        "status": "confirmed",
        "payment_status": "paid",
        "total_amount": 50000,
        "payment_method": "credit_card",
        "checkin_time": "2024-01-15T08:05:00Z",
        "checkout_time": null,
        "notes": "Customer arrived on time",
        "created_at": "2024-01-15T07:00:00Z"
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
    "message": "Access denied. Staff role required."
}
```

### 404 Not Found

```json
{
    "success": false,
    "message": "Booking not found"
}
```

### 422 Validation Error

```json
{
    "success": false,
    "message": "Validation failed",
    "errors": {
        "notes": ["The notes field is required."]
    }
}
```

## Frontend Integration Examples

### JavaScript/Axios

```javascript
// Get staff dashboard
const getStaffDashboard = async () => {
    try {
        const response = await axios.get("/api/v1/staff/dashboard", {
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

// Check-in customer
const checkInCustomer = async (bookingId, notes = "") => {
    try {
        const response = await axios.post(
            `/api/v1/staff/bookings/${bookingId}/checkin`,
            {
                notes,
            },
            {
                headers: {
                    Authorization: `Bearer ${token}`,
                    Accept: "application/json",
                    "Content-Type": "application/json",
                },
            }
        );
        return response.data;
    } catch (error) {
        console.error("Error checking in customer:", error);
    }
};

// Verify payment
const verifyPayment = async (paymentId, notes = "") => {
    try {
        const response = await axios.post(
            `/api/v1/staff/payments/${paymentId}/verify`,
            {
                notes,
            },
            {
                headers: {
                    Authorization: `Bearer ${token}`,
                    Accept: "application/json",
                    "Content-Type": "application/json",
                },
            }
        );
        return response.data;
    } catch (error) {
        console.error("Error verifying payment:", error);
    }
};
```

### React Component

```jsx
import React, { useState, useEffect } from "react";
import axios from "axios";

const StaffDashboard = () => {
    const [dashboard, setDashboard] = useState(null);
    const [loading, setLoading] = useState(true);

    useEffect(() => {
        const fetchDashboard = async () => {
            try {
                const response = await axios.get("/api/v1/staff/dashboard", {
                    headers: {
                        Authorization: `Bearer ${localStorage.getItem(
                            "token"
                        )}`,
                        Accept: "application/json",
                    },
                });
                setDashboard(response.data.data);
            } catch (error) {
                console.error("Error fetching dashboard:", error);
            } finally {
                setLoading(false);
            }
        };

        fetchDashboard();
    }, []);

    const handleCheckIn = async (bookingId) => {
        try {
            await axios.post(
                `/api/v1/staff/bookings/${bookingId}/checkin`,
                {
                    notes: "Customer checked in",
                },
                {
                    headers: {
                        Authorization: `Bearer ${localStorage.getItem(
                            "token"
                        )}`,
                        Accept: "application/json",
                        "Content-Type": "application/json",
                    },
                }
            );
            // Refresh dashboard
            window.location.reload();
        } catch (error) {
            console.error("Error checking in:", error);
        }
    };

    if (loading) return <div>Loading...</div>;

    return (
        <div>
            <h2>Staff Dashboard</h2>
            <div className="stats">
                <div>Today's Bookings: {dashboard?.today_bookings}</div>
                <div>Pending Payments: {dashboard?.pending_payments}</div>
                <div>Checked In: {dashboard?.checked_in}</div>
                <div>Checked Out: {dashboard?.checked_out}</div>
            </div>

            <h3>Recent Bookings</h3>
            {dashboard?.recent_bookings?.map((booking) => (
                <div key={booking.id} className="booking-item">
                    <span>
                        {booking.booking_code} - {booking.customer_name}
                    </span>
                    <button onClick={() => handleCheckIn(booking.id)}>
                        Check In
                    </button>
                </div>
            ))}
        </div>
    );
};

export default StaffDashboard;
```

### Vue.js Component

```vue
<template>
    <div>
        <h2>Staff Dashboard</h2>
        <div v-if="loading">Loading...</div>
        <div v-else>
            <div class="stats">
                <div>Today's Bookings: {{ dashboard?.today_bookings }}</div>
                <div>Pending Payments: {{ dashboard?.pending_payments }}</div>
                <div>Checked In: {{ dashboard?.checked_in }}</div>
                <div>Checked Out: {{ dashboard?.checked_out }}</div>
            </div>

            <h3>Recent Bookings</h3>
            <div
                v-for="booking in dashboard?.recent_bookings"
                :key="booking.id"
                class="booking-item"
            >
                <span
                    >{{ booking.booking_code }} -
                    {{ booking.customer_name }}</span
                >
                <button @click="checkInCustomer(booking.id)">Check In</button>
            </div>
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
        const response = await axios.get("/api/v1/staff/dashboard", {
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

const checkInCustomer = async (bookingId) => {
    try {
        await axios.post(
            `/api/v1/staff/bookings/${bookingId}/checkin`,
            {
                notes: "Customer checked in",
            },
            {
                headers: {
                    Authorization: `Bearer ${localStorage.getItem("token")}`,
                    Accept: "application/json",
                    "Content-Type": "application/json",
                },
            }
        );
        // Refresh dashboard
        await fetchDashboard();
    } catch (error) {
        console.error("Error checking in:", error);
    }
};

onMounted(() => {
    fetchDashboard();
});
</script>
```

## Notes

-   Semua endpoint memerlukan autentikasi staff
-   Check-in/check-out hanya bisa dilakukan untuk booking yang sudah confirmed
-   Verifikasi pembayaran hanya bisa dilakukan untuk status pending
-   Staff dapat melihat semua booking hari ini dan melakukan operasi front desk
-   Semua operasi dicatat dengan timestamp dan staff yang melakukan
