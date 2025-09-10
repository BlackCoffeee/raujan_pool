# 🚀 Frontend Developer Guide - Raujan Pool Syariah

## 📋 Overview

Panduan lengkap untuk tim frontend dalam mengintegrasikan dengan backend API Raujan Pool Syariah. Dokumentasi ini dirancang khusus untuk memudahkan pengembangan frontend dengan struktur yang jelas dan contoh implementasi yang praktis.

## 🎯 Quick Start

### 1. Base Configuration

```javascript
// config/api.js
const API_CONFIG = {
    baseURL: "http://localhost:8000/api/v1",
    timeout: 10000,
    headers: {
        "Content-Type": "application/json",
        Accept: "application/json",
    },
};

// Axios instance
const api = axios.create(API_CONFIG);

// Request interceptor untuk menambahkan token
api.interceptors.request.use((config) => {
    const token = localStorage.getItem("auth_token");
    if (token) {
        config.headers.Authorization = `Bearer ${token}`;
    }
    return config;
});

// Response interceptor untuk handle error
api.interceptors.response.use(
    (response) => response,
    (error) => {
        if (error.response?.status === 401) {
            // Redirect ke login
            localStorage.removeItem("auth_token");
            window.location.href = "/login";
        }
        return Promise.reject(error);
    }
);
```

### 2. Authentication Setup

```javascript
// services/auth.js
export const authService = {
    async login(email, password) {
        const response = await api.post("/auth/login", { email, password });
        const { token, user } = response.data.data;

        localStorage.setItem("auth_token", token);
        localStorage.setItem("user", JSON.stringify(user));

        return { token, user };
    },

    async register(userData) {
        const response = await api.post("/auth/register", userData);
        const { token, user } = response.data.data;

        localStorage.setItem("auth_token", token);
        localStorage.setItem("user", JSON.stringify(user));

        return { token, user };
    },

    async logout() {
        await api.post("/auth/logout");
        localStorage.removeItem("auth_token");
        localStorage.removeItem("user");
    },

    async getCurrentUser() {
        const response = await api.get("/auth/user");
        return response.data.data;
    },
};
```

## 📚 API Endpoints Overview

### 🔐 Authentication & Authorization

-   **Login/Register**: `/auth/login`, `/auth/register`
-   **Google SSO**: `/auth/google`, `/auth/google/callback`
-   **User Management**: `/auth/user`, `/auth/logout`

### 👤 User & Profile Management

-   **Profile**: `/profile/*` - User profile management
-   **Guest Users**: `/guests/*` - Guest user operations
-   **Member Management**: `/members/*` - Member operations

### 📅 Booking & Calendar

-   **Bookings**: `/bookings/*` - Booking management
-   **Calendar**: `/calendar/*` - Calendar and availability
-   **Sessions**: `/sessions/*` - Swimming sessions
-   **Capacity**: `/capacity/*` - Capacity management

### 💰 Payment System

-   **Payments**: `/payments/*` - Payment processing
-   **Payment Tracking**: `/payments/{id}/tracking/*` - Payment tracking
-   **Refunds**: `/bookings/refunds/*` - Refund management

### 🏊‍♂️ Member Features

-   **Member Profile**: `/members/profile` - Member profile
-   **Quota Management**: `/members/quota` - Quota tracking
-   **Usage Tracking**: `/members/usage/*` - Usage analytics

### 🍽️ Cafe System

-   **Menu**: `/members/menu/*` - Menu browsing
-   **Orders**: `/members/orders/*` - Order management
-   **Barcode**: `/members/barcode/*` - Barcode scanning
-   **Order Tracking**: `/members/orders/{id}/status` - Order tracking

### 👨‍💼 Admin Features

-   **User Management**: `/admin/users/*` - User CRUD
-   **Member Management**: `/admin/members/*` - Member management
-   **Menu Management**: `/admin/menu/*` - Menu CRUD
-   **Inventory**: `/admin/cafe/inventory/*` - Inventory management
-   **Analytics**: `/admin/analytics/*` - System analytics
-   **Payment Management**: `/admin/payments/*` - Payment verification

### 👨‍💻 Staff Features

-   **Front Desk**: `/staff/front-desk/*` - Check-in/out operations
-   **Payment Verification**: `/staff/payments/*` - Payment verification

## 🎨 Common UI Patterns

### 1. Loading States

```javascript
// hooks/useApi.js
import { useState, useEffect } from "react";

export const useApi = (apiCall, dependencies = []) => {
    const [data, setData] = useState(null);
    const [loading, setLoading] = useState(false);
    const [error, setError] = useState(null);

    useEffect(() => {
        const fetchData = async () => {
            setLoading(true);
            setError(null);
            try {
                const result = await apiCall();
                setData(result.data);
            } catch (err) {
                setError(err.response?.data?.message || "An error occurred");
            } finally {
                setLoading(false);
            }
        };

        fetchData();
    }, dependencies);

    return { data, loading, error, refetch: () => fetchData() };
};
```

### 2. Error Handling

```javascript
// components/ErrorBoundary.jsx
import React from "react";

const ErrorDisplay = ({ error, onRetry }) => {
    const getErrorMessage = (error) => {
        if (error.response?.data?.message) {
            return error.response.data.message;
        }
        if (error.response?.data?.errors) {
            return Object.values(error.response.data.errors).flat().join(", ");
        }
        return "An unexpected error occurred";
    };

    return (
        <div className="error-container">
            <h3>Error</h3>
            <p>{getErrorMessage(error)}</p>
            {onRetry && (
                <button onClick={onRetry} className="retry-btn">
                    Try Again
                </button>
            )}
        </div>
    );
};
```

### 3. Form Validation

```javascript
// utils/validation.js
export const validationRules = {
    email: {
        required: "Email is required",
        pattern: {
            value: /^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}$/i,
            message: "Invalid email address",
        },
    },
    password: {
        required: "Password is required",
        minLength: {
            value: 8,
            message: "Password must be at least 8 characters",
        },
    },
    phone: {
        pattern: {
            value: /^(\+62|62|0)[0-9]{9,13}$/,
            message: "Invalid Indonesian phone number",
        },
    },
};
```

## 🔄 Real-time Features

### WebSocket Integration

```javascript
// services/websocket.js
import Echo from "laravel-echo";
import Pusher from "pusher-js";

window.Pusher = Pusher;

const echo = new Echo({
    broadcaster: "pusher",
    key: process.env.REACT_APP_PUSHER_APP_KEY,
    cluster: process.env.REACT_APP_PUSHER_APP_CLUSTER,
    forceTLS: true,
});

export const websocketService = {
    // Listen to availability updates
    listenToAvailability(callback) {
        return echo
            .channel("availability")
            .listen("AvailabilityUpdated", callback);
    },

    // Listen to capacity updates
    listenToCapacity(callback) {
        return echo.channel("capacity").listen("CapacityUpdated", callback);
    },

    // Listen to order updates
    listenToOrderUpdates(orderId, callback) {
        return echo
            .private(`order.${orderId}`)
            .listen("OrderStatusUpdated", callback);
    },
};
```

## 📱 Mobile Considerations

### 1. Responsive Design

```css
/* styles/responsive.css */
@media (max-width: 768px) {
    .booking-form {
        padding: 1rem;
    }

    .menu-grid {
        grid-template-columns: 1fr;
    }

    .calendar-view {
        font-size: 0.9rem;
    }
}
```

### 2. Touch Interactions

```javascript
// utils/touch.js
export const touchHandlers = {
    onSwipeLeft: (callback) => ({
        onTouchStart: (e) => {
            const touchStart = e.touches[0].clientX;
            const touchEnd = (e) => {
                const touchEndX = e.changedTouches[0].clientX;
                if (touchStart - touchEndX > 50) {
                    callback();
                }
            };
            e.target.addEventListener("touchend", touchEnd, { once: true });
        },
    }),
};
```

## 🧪 Testing Integration

### 1. API Mocking

```javascript
// __mocks__/api.js
export const mockApi = {
    get: jest.fn(),
    post: jest.fn(),
    put: jest.fn(),
    delete: jest.fn(),
};

// Mock successful responses
mockApi.get.mockResolvedValue({
    data: {
        success: true,
        message: "Success",
        data: {},
    },
});
```

### 2. Component Testing

```javascript
// tests/components/BookingForm.test.js
import { render, screen, fireEvent } from "@testing-library/react";
import { BookingForm } from "../components/BookingForm";

test("submits booking form with valid data", async () => {
    const mockSubmit = jest.fn();
    render(<BookingForm onSubmit={mockSubmit} />);

    fireEvent.change(screen.getByLabelText(/session/i), {
        target: { value: "1" },
    });
    fireEvent.click(screen.getByRole("button", { name: /book/i }));

    expect(mockSubmit).toHaveBeenCalledWith({
        session_id: "1",
        booking_date: expect.any(String),
    });
});
```

## 🚀 Performance Optimization

### 1. API Caching

```javascript
// services/cache.js
const cache = new Map();

export const cachedApi = {
    async get(url, options = {}) {
        const cacheKey = `${url}-${JSON.stringify(options)}`;

        if (cache.has(cacheKey)) {
            const { data, timestamp } = cache.get(cacheKey);
            // Cache valid for 5 minutes
            if (Date.now() - timestamp < 5 * 60 * 1000) {
                return { data };
            }
        }

        const response = await api.get(url, options);
        cache.set(cacheKey, {
            data: response.data,
            timestamp: Date.now(),
        });

        return response;
    },
};
```

### 2. Lazy Loading

```javascript
// components/LazyMenu.jsx
import { lazy, Suspense } from "react";

const MenuList = lazy(() => import("./MenuList"));

export const LazyMenu = () => (
    <Suspense fallback={<div>Loading menu...</div>}>
        <MenuList />
    </Suspense>
);
```

## 🔧 Development Tools

### 1. API Testing

```javascript
// utils/apiTester.js
export const apiTester = {
    async testEndpoint(method, url, data = null) {
        try {
            const response = await api[method](url, data);
            console.log(`✅ ${method.toUpperCase()} ${url}:`, response.data);
            return response;
        } catch (error) {
            console.error(
                `❌ ${method.toUpperCase()} ${url}:`,
                error.response?.data
            );
            throw error;
        }
    },
};
```

### 2. Debug Mode

```javascript
// config/debug.js
export const debugConfig = {
    enabled: process.env.NODE_ENV === "development",

    logApiCalls: (config) => {
        if (debugConfig.enabled) {
            console.log(
                `🚀 API Call: ${config.method?.toUpperCase()} ${config.url}`
            );
        }
    },

    logApiResponses: (response) => {
        if (debugConfig.enabled) {
            console.log(`📥 API Response:`, response.data);
        }
    },
};
```

## 📋 Checklist for Frontend Integration

### ✅ Authentication

-   [ ] Login/Register forms implemented
-   [ ] Token storage and management
-   [ ] Auto-logout on token expiry
-   [ ] Google SSO integration
-   [ ] Role-based route protection

### ✅ User Management

-   [ ] Profile management forms
-   [ ] Guest user registration
-   [ ] Member conversion flow
-   [ ] User role display

### ✅ Booking System

-   [ ] Calendar component
-   [ ] Session selection
-   [ ] Booking form
-   [ ] Booking history
-   [ ] Real-time availability updates

### ✅ Payment System

-   [ ] Payment form
-   [ ] Payment status tracking
-   [ ] Refund request form
-   [ ] Payment history

### ✅ Cafe System

-   [ ] Menu browsing
-   [ ] Order placement
-   [ ] Barcode scanning
-   [ ] Order tracking
-   [ ] Inventory status display

### ✅ Admin Dashboard

-   [ ] User management interface
-   [ ] Member management
-   [ ] Menu management
-   [ ] Inventory management
-   [ ] Analytics dashboard

### ✅ Staff Interface

-   [ ] Check-in/out interface
-   [ ] Payment verification
-   [ ] Order management

## 🆘 Troubleshooting

### Common Issues

1. **401 Unauthorized**

    - Check if token is valid and not expired
    - Verify token is included in Authorization header
    - Ensure user has proper role permissions

2. **422 Validation Error**

    - Check request body format
    - Verify all required fields are provided
    - Validate field types and formats

3. **Network Errors**

    - Check API base URL configuration
    - Verify CORS settings
    - Check network connectivity

4. **Real-time Updates Not Working**
    - Verify WebSocket connection
    - Check Pusher configuration
    - Ensure proper channel subscription

## 📞 Support

Untuk pertanyaan atau bantuan teknis:

-   **Documentation**: Lihat file-file di folder `docs/api/`
-   **Issues**: [GitHub Issues](https://github.com/your-org/raujan-pool-backend/issues)
-   **Email**: frontend-support@raujanpool.com

---

**Last Updated**: December 2024  
**Version**: 1.0.0  
**Status**: Production Ready ✅
