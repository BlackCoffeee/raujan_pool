# Frontend Integration Guide

## Overview

Panduan lengkap untuk mengintegrasikan frontend dengan API sistem pool management. Dokumentasi ini mencakup setup, authentication, dan implementasi fitur-fitur utama.

## Quick Start

### 1. Base Configuration

#### Environment Variables

```bash
# .env
REACT_APP_API_BASE_URL=http://localhost:8000/api/v1
REACT_APP_WS_URL=ws://localhost:8080
REACT_APP_APP_NAME="Pool Management"
```

#### API Client Setup

```javascript
// src/services/api.js
import axios from "axios";

const API_BASE_URL = process.env.REACT_APP_API_BASE_URL;

const apiClient = axios.create({
    baseURL: API_BASE_URL,
    timeout: 10000,
    headers: {
        "Content-Type": "application/json",
        Accept: "application/json",
    },
});

// Request interceptor untuk menambahkan token
apiClient.interceptors.request.use(
    (config) => {
        const token = localStorage.getItem("auth_token");
        if (token) {
            config.headers.Authorization = `Bearer ${token}`;
        }
        return config;
    },
    (error) => Promise.reject(error)
);

// Response interceptor untuk handling error
apiClient.interceptors.response.use(
    (response) => response,
    (error) => {
        if (error.response?.status === 401) {
            localStorage.removeItem("auth_token");
            window.location.href = "/login";
        }
        return Promise.reject(error);
    }
);

export default apiClient;
```

### 2. Authentication Setup

#### Auth Service

```javascript
// src/services/auth.js
import apiClient from "./api";

export const authService = {
    // Register user
    async register(userData) {
        const response = await apiClient.post("/auth/register", userData);
        return response.data;
    },

    // Login user
    async login(credentials) {
        const response = await apiClient.post("/auth/login", credentials);
        const { data } = response.data;

        // Store token
        localStorage.setItem("auth_token", data.token);
        localStorage.setItem("user", JSON.stringify(data.user));

        return data;
    },

    // Logout user
    async logout() {
        try {
            await apiClient.post("/auth/logout");
        } catch (error) {
            console.error("Logout error:", error);
        } finally {
            localStorage.removeItem("auth_token");
            localStorage.removeItem("user");
        }
    },

    // Get current user
    getCurrentUser() {
        const user = localStorage.getItem("user");
        return user ? JSON.parse(user) : null;
    },

    // Check if user is authenticated
    isAuthenticated() {
        return !!localStorage.getItem("auth_token");
    },

    // Refresh token
    async refreshToken() {
        const response = await apiClient.post("/auth/refresh");
        const { data } = response.data;
        localStorage.setItem("auth_token", data.token);
        return data;
    },
};
```

#### Auth Context (React)

```javascript
// src/contexts/AuthContext.js
import React, { createContext, useContext, useState, useEffect } from "react";
import { authService } from "../services/auth";

const AuthContext = createContext();

export const useAuth = () => {
    const context = useContext(AuthContext);
    if (!context) {
        throw new Error("useAuth must be used within AuthProvider");
    }
    return context;
};

export const AuthProvider = ({ children }) => {
    const [user, setUser] = useState(null);
    const [loading, setLoading] = useState(true);

    useEffect(() => {
        const initAuth = async () => {
            try {
                const currentUser = authService.getCurrentUser();
                if (currentUser && authService.isAuthenticated()) {
                    setUser(currentUser);
                }
            } catch (error) {
                console.error("Auth initialization error:", error);
                authService.logout();
            } finally {
                setLoading(false);
            }
        };

        initAuth();
    }, []);

    const login = async (credentials) => {
        try {
            const data = await authService.login(credentials);
            setUser(data.user);
            return data;
        } catch (error) {
            throw error;
        }
    };

    const register = async (userData) => {
        try {
            const data = await authService.register(userData);
            setUser(data.user);
            return data;
        } catch (error) {
            throw error;
        }
    };

    const logout = async () => {
        try {
            await authService.logout();
            setUser(null);
        } catch (error) {
            console.error("Logout error:", error);
        }
    };

    const value = {
        user,
        login,
        register,
        logout,
        isAuthenticated: !!user,
        loading,
    };

    return (
        <AuthContext.Provider value={value}>{children}</AuthContext.Provider>
    );
};
```

## Core Features Implementation

### 1. Pool Management

#### Pool Service

```javascript
// src/services/pool.js
import apiClient from "./api";

export const poolService = {
    // Get all pools
    async getPools(params = {}) {
        const response = await apiClient.get("/pools", { params });
        return response.data;
    },

    // Get pool details
    async getPool(id) {
        const response = await apiClient.get(`/pools/${id}`);
        return response.data;
    },

    // Get pool availability
    async getPoolAvailability(id, date) {
        const response = await apiClient.get(`/pools/${id}/availability`, {
            params: { date },
        });
        return response.data;
    },

    // Get pool time slots
    async getPoolTimeSlots(id, date) {
        const response = await apiClient.get(`/pools/${id}/time-slots`, {
            params: { date },
        });
        return response.data;
    },
};
```

#### Pool Component (React)

```javascript
// src/components/PoolList.jsx
import React, { useState, useEffect } from "react";
import { poolService } from "../services/pool";

const PoolList = () => {
    const [pools, setPools] = useState([]);
    const [loading, setLoading] = useState(true);
    const [error, setError] = useState(null);

    useEffect(() => {
        fetchPools();
    }, []);

    const fetchPools = async () => {
        try {
            setLoading(true);
            const response = await poolService.getPools();
            setPools(response.data);
        } catch (err) {
            setError(err.message);
        } finally {
            setLoading(false);
        }
    };

    if (loading) return <div>Loading pools...</div>;
    if (error) return <div>Error: {error}</div>;

    return (
        <div className="pool-list">
            <h2>Available Pools</h2>
            <div className="pools-grid">
                {pools.map((pool) => (
                    <div key={pool.id} className="pool-card">
                        <h3>{pool.name}</h3>
                        <p>{pool.description}</p>
                        <div className="pool-info">
                            <span>Capacity: {pool.capacity}</span>
                            <span>Price: ${pool.price_per_hour}/hour</span>
                        </div>
                        <button
                            className="btn-primary"
                            onClick={() => handleSelectPool(pool)}
                        >
                            Select Pool
                        </button>
                    </div>
                ))}
            </div>
        </div>
    );
};

export default PoolList;
```

### 2. Booking Management

#### Booking Service

```javascript
// src/services/booking.js
import apiClient from "./api";

export const bookingService = {
    // Get user bookings
    async getUserBookings(params = {}) {
        const response = await apiClient.get("/bookings", { params });
        return response.data;
    },

    // Create booking
    async createBooking(bookingData) {
        const response = await apiClient.post("/bookings", bookingData);
        return response.data;
    },

    // Get booking details
    async getBooking(id) {
        const response = await apiClient.get(`/bookings/${id}`);
        return response.data;
    },

    // Update booking
    async updateBooking(id, bookingData) {
        const response = await apiClient.put(`/bookings/${id}`, bookingData);
        return response.data;
    },

    // Cancel booking
    async cancelBooking(id) {
        const response = await apiClient.delete(`/bookings/${id}`);
        return response.data;
    },

    // Get booking history
    async getBookingHistory(params = {}) {
        const response = await apiClient.get("/bookings/history", { params });
        return response.data;
    },
};
```

#### Booking Component (React)

```javascript
// src/components/BookingForm.jsx
import React, { useState, useEffect } from "react";
import { bookingService } from "../services/booking";
import { poolService } from "../services/pool";

const BookingForm = ({ poolId, onBookingCreated }) => {
    const [formData, setFormData] = useState({
        pool_id: poolId,
        date: "",
        time_slot: "",
        notes: "",
    });
    const [timeSlots, setTimeSlots] = useState([]);
    const [loading, setLoading] = useState(false);
    const [error, setError] = useState(null);

    useEffect(() => {
        if (formData.date) {
            fetchTimeSlots();
        }
    }, [formData.date]);

    const fetchTimeSlots = async () => {
        try {
            const response = await poolService.getPoolTimeSlots(
                poolId,
                formData.date
            );
            setTimeSlots(response.data);
        } catch (err) {
            setError("Failed to fetch time slots");
        }
    };

    const handleSubmit = async (e) => {
        e.preventDefault();
        setLoading(true);
        setError(null);

        try {
            const response = await bookingService.createBooking(formData);
            onBookingCreated(response.data);
            // Reset form
            setFormData({
                pool_id: poolId,
                date: "",
                time_slot: "",
                notes: "",
            });
        } catch (err) {
            setError(err.response?.data?.message || "Failed to create booking");
        } finally {
            setLoading(false);
        }
    };

    const handleChange = (e) => {
        setFormData({
            ...formData,
            [e.target.name]: e.target.value,
        });
    };

    return (
        <form onSubmit={handleSubmit} className="booking-form">
            <h3>Create New Booking</h3>

            <div className="form-group">
                <label htmlFor="date">Date</label>
                <input
                    type="date"
                    id="date"
                    name="date"
                    value={formData.date}
                    onChange={handleChange}
                    min={new Date().toISOString().split("T")[0]}
                    required
                />
            </div>

            <div className="form-group">
                <label htmlFor="time_slot">Time Slot</label>
                <select
                    id="time_slot"
                    name="time_slot"
                    value={formData.time_slot}
                    onChange={handleChange}
                    required
                >
                    <option value="">Select time slot</option>
                    {timeSlots.map((slot) => (
                        <option
                            key={slot.time}
                            value={slot.time}
                            disabled={!slot.available}
                        >
                            {slot.time}{" "}
                            {slot.available ? "(Available)" : "(Unavailable)"}
                        </option>
                    ))}
                </select>
            </div>

            <div className="form-group">
                <label htmlFor="notes">Notes (Optional)</label>
                <textarea
                    id="notes"
                    name="notes"
                    value={formData.notes}
                    onChange={handleChange}
                    rows="3"
                />
            </div>

            {error && <div className="error-message">{error}</div>}

            <button type="submit" className="btn-primary" disabled={loading}>
                {loading ? "Creating..." : "Create Booking"}
            </button>
        </form>
    );
};

export default BookingForm;
```

### 3. Payment Integration

#### Payment Service

```javascript
// src/services/payment.js
import apiClient from "./api";

export const paymentService = {
    // Get payment methods
    async getPaymentMethods() {
        const response = await apiClient.get("/payments/methods");
        return response.data;
    },

    // Create payment
    async createPayment(paymentData) {
        const response = await apiClient.post("/payments", paymentData);
        return response.data;
    },

    // Get payment details
    async getPayment(id) {
        const response = await apiClient.get(`/payments/${id}`);
        return response.data;
    },

    // Verify payment
    async verifyPayment(id, verificationData) {
        const response = await apiClient.post(
            `/payments/${id}/verify`,
            verificationData
        );
        return response.data;
    },

    // Get payment history
    async getPaymentHistory(params = {}) {
        const response = await apiClient.get("/payments/history", { params });
        return response.data;
    },
};
```

#### Payment Component (React)

```javascript
// src/components/PaymentForm.jsx
import React, { useState, useEffect } from "react";
import { paymentService } from "../services/payment";

const PaymentForm = ({ bookingId, amount, onPaymentSuccess }) => {
    const [formData, setFormData] = useState({
        booking_id: bookingId,
        amount: amount,
        payment_method: "",
        payment_details: {},
    });
    const [paymentMethods, setPaymentMethods] = useState([]);
    const [loading, setLoading] = useState(false);
    const [error, setError] = useState(null);

    useEffect(() => {
        fetchPaymentMethods();
    }, []);

    const fetchPaymentMethods = async () => {
        try {
            const response = await paymentService.getPaymentMethods();
            setPaymentMethods(response.data);
        } catch (err) {
            setError("Failed to fetch payment methods");
        }
    };

    const handleSubmit = async (e) => {
        e.preventDefault();
        setLoading(true);
        setError(null);

        try {
            const response = await paymentService.createPayment(formData);
            onPaymentSuccess(response.data);
        } catch (err) {
            setError(err.response?.data?.message || "Payment failed");
        } finally {
            setLoading(false);
        }
    };

    const handleChange = (e) => {
        setFormData({
            ...formData,
            [e.target.name]: e.target.value,
        });
    };

    const handlePaymentDetailsChange = (e) => {
        setFormData({
            ...formData,
            payment_details: {
                ...formData.payment_details,
                [e.target.name]: e.target.value,
            },
        });
    };

    return (
        <form onSubmit={handleSubmit} className="payment-form">
            <h3>Payment Information</h3>

            <div className="form-group">
                <label>Amount</label>
                <div className="amount-display">${amount}</div>
            </div>

            <div className="form-group">
                <label htmlFor="payment_method">Payment Method</label>
                <select
                    id="payment_method"
                    name="payment_method"
                    value={formData.payment_method}
                    onChange={handleChange}
                    required
                >
                    <option value="">Select payment method</option>
                    {paymentMethods.map((method) => (
                        <option key={method.id} value={method.id}>
                            {method.name}
                        </option>
                    ))}
                </select>
            </div>

            {formData.payment_method === "credit_card" && (
                <div className="payment-details">
                    <div className="form-group">
                        <label htmlFor="card_number">Card Number</label>
                        <input
                            type="text"
                            id="card_number"
                            name="card_number"
                            onChange={handlePaymentDetailsChange}
                            placeholder="1234 5678 9012 3456"
                            required
                        />
                    </div>
                    <div className="form-row">
                        <div className="form-group">
                            <label htmlFor="expiry_date">Expiry Date</label>
                            <input
                                type="text"
                                id="expiry_date"
                                name="expiry_date"
                                onChange={handlePaymentDetailsChange}
                                placeholder="MM/YY"
                                required
                            />
                        </div>
                        <div className="form-group">
                            <label htmlFor="cvv">CVV</label>
                            <input
                                type="text"
                                id="cvv"
                                name="cvv"
                                onChange={handlePaymentDetailsChange}
                                placeholder="123"
                                required
                            />
                        </div>
                    </div>
                </div>
            )}

            {error && <div className="error-message">{error}</div>}

            <button type="submit" className="btn-primary" disabled={loading}>
                {loading ? "Processing..." : "Pay Now"}
            </button>
        </form>
    );
};

export default PaymentForm;
```

## Real-time Features

### 1. WebSocket Setup

#### WebSocket Service

```javascript
// src/services/websocket.js
import Echo from "laravel-echo";
import Pusher from "pusher-js";

// Enable pusher logging
window.Pusher = Pusher;

const echo = new Echo({
    broadcaster: "reverb",
    key: process.env.REACT_APP_WS_KEY,
    wsHost: process.env.REACT_APP_WS_HOST,
    wsPort: process.env.REACT_APP_WS_PORT,
    wssPort: process.env.REACT_APP_WS_PORT,
    forceTLS: false,
    enabledTransports: ["ws", "wss"],
});

export default echo;
```

#### Real-time Hook (React)

```javascript
// src/hooks/useRealtime.js
import { useEffect, useState } from "react";
import { useAuth } from "../contexts/AuthContext";
import echo from "../services/websocket";

export const useRealtime = () => {
    const { user } = useAuth();
    const [notifications, setNotifications] = useState([]);

    useEffect(() => {
        if (!user) return;

        // Listen for user-specific notifications
        const channel = echo.private(`user.${user.id}`);

        channel.listen("BookingStatusUpdated", (e) => {
            setNotifications((prev) => [
                ...prev,
                {
                    id: Date.now(),
                    type: "booking_update",
                    message: `Your booking status has been updated to ${e.booking.status}`,
                    data: e.booking,
                },
            ]);
        });

        channel.listen("PaymentStatusUpdated", (e) => {
            setNotifications((prev) => [
                ...prev,
                {
                    id: Date.now(),
                    type: "payment_update",
                    message: `Payment status updated: ${e.payment.status}`,
                    data: e.payment,
                },
            ]);
        });

        return () => {
            channel.stopListening("BookingStatusUpdated");
            channel.stopListening("PaymentStatusUpdated");
        };
    }, [user]);

    return { notifications, setNotifications };
};
```

### 2. Real-time Pool Availability

#### Pool Availability Hook

```javascript
// src/hooks/usePoolAvailability.js
import { useEffect, useState } from "react";
import echo from "../services/websocket";

export const usePoolAvailability = (poolId, date) => {
    const [availability, setAvailability] = useState(null);
    const [loading, setLoading] = useState(true);

    useEffect(() => {
        if (!poolId || !date) return;

        // Listen for real-time availability updates
        const channel = echo.channel(`pool.${poolId}.availability`);

        channel.listen("AvailabilityUpdated", (e) => {
            if (e.date === date) {
                setAvailability(e.availability);
            }
        });

        return () => {
            channel.stopListening("AvailabilityUpdated");
        };
    }, [poolId, date]);

    return { availability, loading };
};
```

## Error Handling

### 1. Global Error Handler

#### Error Boundary (React)

```javascript
// src/components/ErrorBoundary.jsx
import React from "react";

class ErrorBoundary extends React.Component {
    constructor(props) {
        super(props);
        this.state = { hasError: false, error: null };
    }

    static getDerivedStateFromError(error) {
        return { hasError: true, error };
    }

    componentDidCatch(error, errorInfo) {
        console.error("Error caught by boundary:", error, errorInfo);
        // Log to error reporting service
    }

    render() {
        if (this.state.hasError) {
            return (
                <div className="error-boundary">
                    <h2>Something went wrong</h2>
                    <p>We're sorry, but something unexpected happened.</p>
                    <button onClick={() => window.location.reload()}>
                        Reload Page
                    </button>
                </div>
            );
        }

        return this.props.children;
    }
}

export default ErrorBoundary;
```

### 2. API Error Handler

#### Error Handler Service

```javascript
// src/services/errorHandler.js
export const errorHandler = {
    handle(error) {
        if (error.response) {
            // Server responded with error status
            const { status, data } = error.response;

            switch (status) {
                case 401:
                    return "Please log in to continue";
                case 403:
                    return "You do not have permission to perform this action";
                case 404:
                    return "The requested resource was not found";
                case 422:
                    return data.message || "Validation failed";
                case 429:
                    return "Too many requests. Please try again later";
                case 500:
                    return "Server error. Please try again later";
                default:
                    return data.message || "An error occurred";
            }
        } else if (error.request) {
            // Network error
            return "Network error. Please check your connection";
        } else {
            // Other error
            return error.message || "An unexpected error occurred";
        }
    },
};
```

## State Management

### 1. Redux Setup (Optional)

#### Store Configuration

```javascript
// src/store/index.js
import { configureStore } from "@reduxjs/toolkit";
import authSlice from "./slices/authSlice";
import bookingSlice from "./slices/bookingSlice";
import poolSlice from "./slices/poolSlice";

export const store = configureStore({
    reducer: {
        auth: authSlice,
        bookings: bookingSlice,
        pools: poolSlice,
    },
    middleware: (getDefaultMiddleware) =>
        getDefaultMiddleware({
            serializableCheck: {
                ignoredActions: ["persist/PERSIST"],
            },
        }),
});

export type RootState = ReturnType<typeof store.getState>;
export type AppDispatch = typeof store.dispatch;
```

#### Auth Slice

```javascript
// src/store/slices/authSlice.js
import { createSlice, createAsyncThunk } from "@reduxjs/toolkit";
import { authService } from "../../services/auth";

export const loginUser = createAsyncThunk(
    "auth/login",
    async (credentials, { rejectWithValue }) => {
        try {
            const data = await authService.login(credentials);
            return data;
        } catch (error) {
            return rejectWithValue(
                error.response?.data?.message || "Login failed"
            );
        }
    }
);

export const registerUser = createAsyncThunk(
    "auth/register",
    async (userData, { rejectWithValue }) => {
        try {
            const data = await authService.register(userData);
            return data;
        } catch (error) {
            return rejectWithValue(
                error.response?.data?.message || "Registration failed"
            );
        }
    }
);

const authSlice = createSlice({
    name: "auth",
    initialState: {
        user: null,
        token: null,
        loading: false,
        error: null,
    },
    reducers: {
        logout: (state) => {
            state.user = null;
            state.token = null;
            authService.logout();
        },
        clearError: (state) => {
            state.error = null;
        },
    },
    extraReducers: (builder) => {
        builder
            .addCase(loginUser.pending, (state) => {
                state.loading = true;
                state.error = null;
            })
            .addCase(loginUser.fulfilled, (state, action) => {
                state.loading = false;
                state.user = action.payload.user;
                state.token = action.payload.token;
            })
            .addCase(loginUser.rejected, (state, action) => {
                state.loading = false;
                state.error = action.payload;
            })
            .addCase(registerUser.pending, (state) => {
                state.loading = true;
                state.error = null;
            })
            .addCase(registerUser.fulfilled, (state, action) => {
                state.loading = false;
                state.user = action.payload.user;
                state.token = action.payload.token;
            })
            .addCase(registerUser.rejected, (state, action) => {
                state.loading = false;
                state.error = action.payload;
            });
    },
});

export const { logout, clearError } = authSlice.actions;
export default authSlice.reducer;
```

## Testing

### 1. Component Testing

#### Booking Component Test

```javascript
// src/components/__tests__/BookingForm.test.jsx
import React from "react";
import { render, screen, fireEvent, waitFor } from "@testing-library/react";
import { BookingForm } from "../BookingForm";
import { bookingService } from "../../services/booking";

// Mock the service
jest.mock("../../services/booking");
jest.mock("../../services/pool");

describe("BookingForm", () => {
    const mockOnBookingCreated = jest.fn();

    beforeEach(() => {
        jest.clearAllMocks();
    });

    test("renders booking form correctly", () => {
        render(
            <BookingForm poolId={1} onBookingCreated={mockOnBookingCreated} />
        );

        expect(screen.getByText("Create New Booking")).toBeInTheDocument();
        expect(screen.getByLabelText("Date")).toBeInTheDocument();
        expect(screen.getByLabelText("Time Slot")).toBeInTheDocument();
    });

    test("submits booking form successfully", async () => {
        const mockBooking = { id: 1, status: "pending" };
        bookingService.createBooking.mockResolvedValue({ data: mockBooking });

        render(
            <BookingForm poolId={1} onBookingCreated={mockOnBookingCreated} />
        );

        fireEvent.change(screen.getByLabelText("Date"), {
            target: { value: "2024-12-25" },
        });

        fireEvent.change(screen.getByLabelText("Time Slot"), {
            target: { value: "10:00-12:00" },
        });

        fireEvent.click(screen.getByText("Create Booking"));

        await waitFor(() => {
            expect(bookingService.createBooking).toHaveBeenCalledWith({
                pool_id: 1,
                date: "2024-12-25",
                time_slot: "10:00-12:00",
                notes: "",
            });
            expect(mockOnBookingCreated).toHaveBeenCalledWith(mockBooking);
        });
    });
});
```

### 2. Service Testing

#### Auth Service Test

```javascript
// src/services/__tests__/auth.test.js
import { authService } from "../auth";
import apiClient from "../api";

jest.mock("../api");

describe("authService", () => {
    beforeEach(() => {
        jest.clearAllMocks();
        localStorage.clear();
    });

    test("login stores token and user data", async () => {
        const mockResponse = {
            data: {
                user: { id: 1, name: "John Doe", email: "john@example.com" },
                token: "mock-token",
            },
        };

        apiClient.post.mockResolvedValue(mockResponse);

        const result = await authService.login({
            email: "john@example.com",
            password: "password123",
        });

        expect(localStorage.getItem("auth_token")).toBe("mock-token");
        expect(localStorage.getItem("user")).toBe(
            JSON.stringify(mockResponse.data.user)
        );
        expect(result).toEqual(mockResponse.data);
    });

    test("logout clears stored data", async () => {
        localStorage.setItem("auth_token", "mock-token");
        localStorage.setItem("user", JSON.stringify({ id: 1, name: "John" }));

        await authService.logout();

        expect(localStorage.getItem("auth_token")).toBeNull();
        expect(localStorage.getItem("user")).toBeNull();
    });
});
```

## Performance Optimization

### 1. Code Splitting

#### Route-based Code Splitting

```javascript
// src/App.jsx
import React, { Suspense, lazy } from "react";
import { BrowserRouter as Router, Routes, Route } from "react-router-dom";

// Lazy load components
const Home = lazy(() => import("./pages/Home"));
const Login = lazy(() => import("./pages/Login"));
const Register = lazy(() => import("./pages/Register"));
const Dashboard = lazy(() => import("./pages/Dashboard"));
const Booking = lazy(() => import("./pages/Booking"));

function App() {
    return (
        <Router>
            <Suspense fallback={<div>Loading...</div>}>
                <Routes>
                    <Route path="/" element={<Home />} />
                    <Route path="/login" element={<Login />} />
                    <Route path="/register" element={<Register />} />
                    <Route path="/dashboard" element={<Dashboard />} />
                    <Route path="/booking" element={<Booking />} />
                </Routes>
            </Suspense>
        </Router>
    );
}

export default App;
```

### 2. Caching Strategy

#### API Response Caching

```javascript
// src/services/cache.js
class ApiCache {
    constructor(ttl = 5 * 60 * 1000) {
        // 5 minutes default
        this.cache = new Map();
        this.ttl = ttl;
    }

    set(key, data) {
        this.cache.set(key, {
            data,
            timestamp: Date.now(),
        });
    }

    get(key) {
        const item = this.cache.get(key);
        if (!item) return null;

        if (Date.now() - item.timestamp > this.ttl) {
            this.cache.delete(key);
            return null;
        }

        return item.data;
    }

    clear() {
        this.cache.clear();
    }
}

export const apiCache = new ApiCache();
```

#### Cached API Service

```javascript
// src/services/cachedApi.js
import apiClient from "./api";
import { apiCache } from "./cache";

export const cachedApiService = {
    async get(url, options = {}) {
        const cacheKey = `${url}-${JSON.stringify(options.params || {})}`;

        // Check cache first
        const cachedData = apiCache.get(cacheKey);
        if (cachedData) {
            return cachedData;
        }

        // Fetch from API
        const response = await apiClient.get(url, options);

        // Cache the response
        apiCache.set(cacheKey, response.data);

        return response.data;
    },
};
```

## Deployment

### 1. Environment Configuration

#### Production Environment

```bash
# .env.production
REACT_APP_API_BASE_URL=https://api.poolmanagement.com/api/v1
REACT_APP_WS_URL=wss://ws.poolmanagement.com
REACT_APP_APP_NAME="Pool Management"
REACT_APP_ENVIRONMENT=production
```

### 2. Build Configuration

#### Webpack Configuration

```javascript
// webpack.config.js
const path = require("path");

module.exports = {
    entry: "./src/index.js",
    output: {
        path: path.resolve(__dirname, "build"),
        filename: "static/js/[name].[contenthash].js",
        clean: true,
    },
    optimization: {
        splitChunks: {
            chunks: "all",
            cacheGroups: {
                vendor: {
                    test: /[\\/]node_modules[\\/]/,
                    name: "vendors",
                    chunks: "all",
                },
            },
        },
    },
};
```

## Best Practices

### 1. Code Organization

-   **Services**: API calls and business logic
-   **Components**: UI components with minimal logic
-   **Hooks**: Reusable stateful logic
-   **Context**: Global state management
-   **Utils**: Helper functions and utilities

### 2. Error Handling

-   Use error boundaries for component errors
-   Implement global error handling for API calls
-   Provide user-friendly error messages
-   Log errors for debugging

### 3. Performance

-   Implement code splitting for large applications
-   Use React.memo for expensive components
-   Optimize API calls with caching
-   Minimize bundle size

### 4. Security

-   Never store sensitive data in localStorage
-   Validate all user inputs
-   Use HTTPS in production
-   Implement proper authentication flow

### 5. Testing

-   Write unit tests for services and utilities
-   Test components with user interactions
-   Mock external dependencies
-   Maintain high test coverage

## Conclusion

Panduan ini memberikan fondasi yang solid untuk mengintegrasikan frontend dengan API sistem pool management. Dengan mengikuti best practices dan implementasi yang dijelaskan, tim frontend dapat membangun aplikasi yang robust, scalable, dan user-friendly.

### Key Takeaways

-   **Setup yang Proper**: Konfigurasi API client dan authentication
-   **Real-time Features**: WebSocket integration untuk updates
-   **Error Handling**: Comprehensive error management
-   **Performance**: Optimization strategies
-   **Testing**: Comprehensive testing approach
-   **Security**: Best practices untuk keamanan aplikasi
