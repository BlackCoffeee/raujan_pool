# WebSocket & Real-time API

API untuk fitur real-time menggunakan WebSocket dan Laravel Echo.

## Base URL

```
WebSocket: ws://localhost:6001
```

## Authentication

-   **Required**: Bearer Token untuk private channels
-   **Header**: `Authorization: Bearer {token}`

## Channels

### 1. Availability Channel

Channel untuk update ketersediaan session secara real-time.

**Channel Name:** `availability`

**Events:**

#### Session Availability Updated

```javascript
{
    "event": "AvailabilityUpdated",
    "data": {
        "session_id": 1,
        "session_name": "Morning Session",
        "date": "2024-01-15",
        "available_slots": 5,
        "total_capacity": 20,
        "updated_at": "2024-01-15T08:00:00Z"
    }
}
```

#### Capacity Updated

```javascript
{
    "event": "CapacityUpdated",
    "data": {
        "session_id": 1,
        "session_name": "Morning Session",
        "date": "2024-01-15",
        "current_capacity": 15,
        "max_capacity": 20,
        "updated_at": "2024-01-15T08:00:00Z"
    }
}
```

### 2. Booking Channel

Channel untuk update status booking secara real-time.

**Channel Name:** `booking.{user_id}`

**Events:**

#### Booking Status Updated

```javascript
{
    "event": "BookingStatusUpdated",
    "data": {
        "booking_id": 1,
        "booking_code": "BK001",
        "status": "confirmed",
        "payment_status": "paid",
        "updated_at": "2024-01-15T08:00:00Z"
    }
}
```

#### Payment Status Updated

```javascript
{
    "event": "PaymentStatusUpdated",
    "data": {
        "booking_id": 1,
        "booking_code": "BK001",
        "payment_status": "verified",
        "updated_at": "2024-01-15T08:00:00Z"
    }
}
```

### 3. Admin Channel

Channel untuk notifikasi admin.

**Channel Name:** `admin`

**Events:**

#### New Booking Notification

```javascript
{
    "event": "NewBookingNotification",
    "data": {
        "booking_id": 1,
        "booking_code": "BK001",
        "customer_name": "John Doe",
        "session_name": "Morning Session",
        "booking_date": "2024-01-15",
        "total_amount": 50000,
        "created_at": "2024-01-15T08:00:00Z"
    }
}
```

#### Payment Verification Required

```javascript
{
    "event": "PaymentVerificationRequired",
    "data": {
        "payment_id": 1,
        "booking_id": 1,
        "booking_code": "BK001",
        "customer_name": "John Doe",
        "amount": 50000,
        "payment_method": "bank_transfer",
        "submitted_at": "2024-01-15T08:00:00Z"
    }
}
```

### 4. Staff Channel

Channel untuk notifikasi staff.

**Channel Name:** `staff`

**Events:**

#### Check-in Notification

```javascript
{
    "event": "CheckInNotification",
    "data": {
        "booking_id": 1,
        "booking_code": "BK001",
        "customer_name": "John Doe",
        "session_name": "Morning Session",
        "checkin_time": "2024-01-15T08:05:00Z"
    }
}
```

#### Check-out Notification

```javascript
{
    "event": "CheckOutNotification",
    "data": {
        "booking_id": 1,
        "booking_code": "BK001",
        "customer_name": "John Doe",
        "session_name": "Morning Session",
        "checkout_time": "2024-01-15T10:00:00Z"
    }
}
```

## Frontend Integration Examples

### Laravel Echo Setup

```javascript
import Echo from "laravel-echo";
import Pusher from "pusher-js";

window.Pusher = Pusher;

window.Echo = new Echo({
    broadcaster: "pusher",
    key: process.env.MIX_PUSHER_APP_KEY,
    cluster: process.env.MIX_PUSHER_APP_CLUSTER,
    forceTLS: true,
    authEndpoint: "/api/broadcasting/auth",
    auth: {
        headers: {
            Authorization: `Bearer ${localStorage.getItem("token")}`,
        },
    },
});
```

### React Hook for Real-time Updates

```jsx
import { useEffect, useState } from "react";
import Echo from "laravel-echo";

const useRealtimeAvailability = () => {
    const [availability, setAvailability] = useState({});

    useEffect(() => {
        const echo = new Echo({
            broadcaster: "pusher",
            key: process.env.REACT_APP_PUSHER_KEY,
            cluster: process.env.REACT_APP_PUSHER_CLUSTER,
            forceTLS: true,
            authEndpoint: "/api/broadcasting/auth",
            auth: {
                headers: {
                    Authorization: `Bearer ${localStorage.getItem("token")}`,
                },
            },
        });

        // Listen to availability updates
        echo.channel("availability")
            .listen("AvailabilityUpdated", (e) => {
                setAvailability((prev) => ({
                    ...prev,
                    [e.data.session_id]: e.data,
                }));
            })
            .listen("CapacityUpdated", (e) => {
                setAvailability((prev) => ({
                    ...prev,
                    [e.data.session_id]: {
                        ...prev[e.data.session_id],
                        current_capacity: e.data.current_capacity,
                        max_capacity: e.data.max_capacity,
                    },
                }));
            });

        return () => {
            echo.leave("availability");
        };
    }, []);

    return availability;
};

export default useRealtimeAvailability;
```

### Vue.js Composition API

```vue
<template>
    <div>
        <h2>Real-time Availability</h2>
        <div v-for="session in availability" :key="session.session_id">
            <h3>{{ session.session_name }}</h3>
            <p>
                Available: {{ session.available_slots }}/{{
                    session.total_capacity
                }}
            </p>
        </div>
    </div>
</template>

<script setup>
import { ref, onMounted, onUnmounted } from "vue";
import Echo from "laravel-echo";

const availability = ref({});
let echo = null;

onMounted(() => {
    echo = new Echo({
        broadcaster: "pusher",
        key: import.meta.env.VITE_PUSHER_KEY,
        cluster: import.meta.env.VITE_PUSHER_CLUSTER,
        forceTLS: true,
        authEndpoint: "/api/broadcasting/auth",
        auth: {
            headers: {
                Authorization: `Bearer ${localStorage.getItem("token")}`,
            },
        },
    });

    // Listen to availability updates
    echo.channel("availability")
        .listen("AvailabilityUpdated", (e) => {
            availability.value[e.data.session_id] = e.data;
        })
        .listen("CapacityUpdated", (e) => {
            if (availability.value[e.data.session_id]) {
                availability.value[e.data.session_id].current_capacity =
                    e.data.current_capacity;
                availability.value[e.data.session_id].max_capacity =
                    e.data.max_capacity;
            }
        });
});

onUnmounted(() => {
    if (echo) {
        echo.leave("availability");
    }
});
</script>
```

### JavaScript/Axios for Broadcasting Auth

```javascript
// Broadcasting authentication endpoint
const authenticateBroadcasting = async (socketId, channelName) => {
    try {
        const response = await axios.post(
            "/api/broadcasting/auth",
            {
                socket_id: socketId,
                channel_name: channelName,
            },
            {
                headers: {
                    Authorization: `Bearer ${localStorage.getItem("token")}`,
                    Accept: "application/json",
                    "Content-Type": "application/json",
                },
            }
        );
        return response.data;
    } catch (error) {
        console.error("Error authenticating broadcasting:", error);
    }
};
```

### React Component for Booking Updates

```jsx
import React, { useEffect, useState } from "react";
import Echo from "laravel-echo";

const BookingStatus = ({ bookingId }) => {
    const [booking, setBooking] = useState(null);
    const [status, setStatus] = useState("pending");

    useEffect(() => {
        const echo = new Echo({
            broadcaster: "pusher",
            key: process.env.REACT_APP_PUSHER_KEY,
            cluster: process.env.REACT_APP_PUSHER_CLUSTER,
            forceTLS: true,
            authEndpoint: "/api/broadcasting/auth",
            auth: {
                headers: {
                    Authorization: `Bearer ${localStorage.getItem("token")}`,
                },
            },
        });

        // Listen to booking updates for specific user
        const userId = localStorage.getItem("user_id");
        echo.private(`booking.${userId}`)
            .listen("BookingStatusUpdated", (e) => {
                if (e.data.booking_id === bookingId) {
                    setStatus(e.data.status);
                }
            })
            .listen("PaymentStatusUpdated", (e) => {
                if (e.data.booking_id === bookingId) {
                    setBooking((prev) => ({
                        ...prev,
                        payment_status: e.data.payment_status,
                    }));
                }
            });

        return () => {
            echo.leave(`booking.${userId}`);
        };
    }, [bookingId]);

    return (
        <div className="booking-status">
            <h3>Booking Status</h3>
            <p>Status: {status}</p>
            {booking && <p>Payment: {booking.payment_status}</p>}
        </div>
    );
};

export default BookingStatus;
```

### Admin Dashboard Real-time Notifications

```jsx
import React, { useEffect, useState } from "react";
import Echo from "laravel-echo";

const AdminNotifications = () => {
    const [notifications, setNotifications] = useState([]);

    useEffect(() => {
        const echo = new Echo({
            broadcaster: "pusher",
            key: process.env.REACT_APP_PUSHER_KEY,
            cluster: process.env.REACT_APP_PUSHER_CLUSTER,
            forceTLS: true,
            authEndpoint: "/api/broadcasting/auth",
            auth: {
                headers: {
                    Authorization: `Bearer ${localStorage.getItem("token")}`,
                },
            },
        });

        // Listen to admin notifications
        echo.channel("admin")
            .listen("NewBookingNotification", (e) => {
                setNotifications((prev) => [
                    {
                        id: Date.now(),
                        type: "new_booking",
                        message: `New booking from ${e.data.customer_name}`,
                        data: e.data,
                        timestamp: new Date(),
                    },
                    ...prev,
                ]);
            })
            .listen("PaymentVerificationRequired", (e) => {
                setNotifications((prev) => [
                    {
                        id: Date.now(),
                        type: "payment_verification",
                        message: `Payment verification required for ${e.data.customer_name}`,
                        data: e.data,
                        timestamp: new Date(),
                    },
                    ...prev,
                ]);
            });

        return () => {
            echo.leave("admin");
        };
    }, []);

    return (
        <div className="admin-notifications">
            <h3>Real-time Notifications</h3>
            {notifications.map((notification) => (
                <div key={notification.id} className="notification">
                    <p>{notification.message}</p>
                    <small>{notification.timestamp.toLocaleTimeString()}</small>
                </div>
            ))}
        </div>
    );
};

export default AdminNotifications;
```

## Configuration

### Environment Variables

```env
PUSHER_APP_ID=your_pusher_app_id
PUSHER_APP_KEY=your_pusher_app_key
PUSHER_APP_SECRET=your_pusher_app_secret
PUSHER_APP_CLUSTER=your_pusher_cluster

BROADCAST_DRIVER=pusher
```

### Laravel Echo Configuration

```javascript
// resources/js/bootstrap.js
import Echo from "laravel-echo";
import Pusher from "pusher-js";

window.Pusher = Pusher;

window.Echo = new Echo({
    broadcaster: "pusher",
    key: process.env.MIX_PUSHER_APP_KEY,
    cluster: process.env.MIX_PUSHER_APP_CLUSTER,
    forceTLS: true,
    authEndpoint: "/api/broadcasting/auth",
});
```

## Notes

-   WebSocket memerlukan autentikasi untuk private channels
-   Broadcasting auth endpoint: `/api/broadcasting/auth`
-   Semua events menggunakan format JSON yang konsisten
-   Channel names mengikuti konvensi Laravel Echo
-   Real-time updates otomatis tersinkronisasi dengan database
