# Quick Start Guide

## Overview

Panduan cepat untuk memulai menggunakan API sistem pool management. Dokumentasi ini akan membantu developer frontend untuk setup dan integrasi dengan cepat.

## Prerequisites

### Requirements

-   Node.js 16+ atau versi terbaru
-   npm atau yarn
-   Text editor (VS Code recommended)
-   API endpoint access

### Knowledge

-   Basic JavaScript/TypeScript
-   HTTP requests (fetch, axios)
-   JSON handling
-   Authentication concepts

## 1. Setup Environment

### Install Dependencies

```bash
# Create new project
npx create-react-app pool-management-frontend
cd pool-management-frontend

# Install additional dependencies
npm install axios
npm install @reduxjs/toolkit react-redux
npm install react-router-dom
npm install laravel-echo pusher-js
```

### Environment Configuration

```bash
# .env
REACT_APP_API_BASE_URL=http://localhost:8000/api/v1
REACT_APP_WS_URL=ws://localhost:8080
REACT_APP_APP_NAME="Pool Management"
```

## 2. Basic API Setup

### API Client Configuration

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

// Request interceptor
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

// Response interceptor
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

### Authentication Service

```javascript
// src/services/auth.js
import apiClient from "./api";

export const authService = {
    async login(credentials) {
        const response = await apiClient.post("/auth/login", credentials);
        const { data } = response.data;

        localStorage.setItem("auth_token", data.token);
        localStorage.setItem("user", JSON.stringify(data.user));

        return data;
    },

    async register(userData) {
        const response = await apiClient.post("/auth/register", userData);
        const { data } = response.data;

        localStorage.setItem("auth_token", data.token);
        localStorage.setItem("user", JSON.stringify(data.user));

        return data;
    },

    logout() {
        localStorage.removeItem("auth_token");
        localStorage.removeItem("user");
    },

    getCurrentUser() {
        const user = localStorage.getItem("user");
        return user ? JSON.parse(user) : null;
    },

    isAuthenticated() {
        return !!localStorage.getItem("auth_token");
    },
};
```

## 3. Authentication Flow

### Login Component

```javascript
// src/components/Login.jsx
import React, { useState } from "react";
import { authService } from "../services/auth";

const Login = ({ onLoginSuccess }) => {
    const [formData, setFormData] = useState({
        email: "",
        password: "",
    });
    const [loading, setLoading] = useState(false);
    const [error, setError] = useState("");

    const handleSubmit = async (e) => {
        e.preventDefault();
        setLoading(true);
        setError("");

        try {
            await authService.login(formData);
            onLoginSuccess();
        } catch (err) {
            setError(err.response?.data?.message || "Login failed");
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
        <div className="login-form">
            <h2>Login</h2>
            <form onSubmit={handleSubmit}>
                <div className="form-group">
                    <label htmlFor="email">Email</label>
                    <input
                        type="email"
                        id="email"
                        name="email"
                        value={formData.email}
                        onChange={handleChange}
                        required
                    />
                </div>

                <div className="form-group">
                    <label htmlFor="password">Password</label>
                    <input
                        type="password"
                        id="password"
                        name="password"
                        value={formData.password}
                        onChange={handleChange}
                        required
                    />
                </div>

                {error && <div className="error">{error}</div>}

                <button type="submit" disabled={loading}>
                    {loading ? "Logging in..." : "Login"}
                </button>
            </form>
        </div>
    );
};

export default Login;
```

### Register Component

```javascript
// src/components/Register.jsx
import React, { useState } from "react";
import { authService } from "../services/auth";

const Register = ({ onRegisterSuccess }) => {
    const [formData, setFormData] = useState({
        name: "",
        email: "",
        password: "",
        password_confirmation: "",
        phone: "",
        date_of_birth: "",
    });
    const [loading, setLoading] = useState(false);
    const [error, setError] = useState("");

    const handleSubmit = async (e) => {
        e.preventDefault();
        setLoading(true);
        setError("");

        try {
            await authService.register(formData);
            onRegisterSuccess();
        } catch (err) {
            setError(err.response?.data?.message || "Registration failed");
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
        <div className="register-form">
            <h2>Register</h2>
            <form onSubmit={handleSubmit}>
                <div className="form-group">
                    <label htmlFor="name">Full Name</label>
                    <input
                        type="text"
                        id="name"
                        name="name"
                        value={formData.name}
                        onChange={handleChange}
                        required
                    />
                </div>

                <div className="form-group">
                    <label htmlFor="email">Email</label>
                    <input
                        type="email"
                        id="email"
                        name="email"
                        value={formData.email}
                        onChange={handleChange}
                        required
                    />
                </div>

                <div className="form-group">
                    <label htmlFor="password">Password</label>
                    <input
                        type="password"
                        id="password"
                        name="password"
                        value={formData.password}
                        onChange={handleChange}
                        required
                    />
                </div>

                <div className="form-group">
                    <label htmlFor="password_confirmation">
                        Confirm Password
                    </label>
                    <input
                        type="password"
                        id="password_confirmation"
                        name="password_confirmation"
                        value={formData.password_confirmation}
                        onChange={handleChange}
                        required
                    />
                </div>

                <div className="form-group">
                    <label htmlFor="phone">Phone</label>
                    <input
                        type="tel"
                        id="phone"
                        name="phone"
                        value={formData.phone}
                        onChange={handleChange}
                        required
                    />
                </div>

                <div className="form-group">
                    <label htmlFor="date_of_birth">Date of Birth</label>
                    <input
                        type="date"
                        id="date_of_birth"
                        name="date_of_birth"
                        value={formData.date_of_birth}
                        onChange={handleChange}
                        required
                    />
                </div>

                {error && <div className="error">{error}</div>}

                <button type="submit" disabled={loading}>
                    {loading ? "Registering..." : "Register"}
                </button>
            </form>
        </div>
    );
};

export default Register;
```

## 4. Core Features

### Pool Service

```javascript
// src/services/pool.js
import apiClient from "./api";

export const poolService = {
    async getPools() {
        const response = await apiClient.get("/pools");
        return response.data;
    },

    async getPool(id) {
        const response = await apiClient.get(`/pools/${id}`);
        return response.data;
    },

    async getPoolAvailability(id, date) {
        const response = await apiClient.get(`/pools/${id}/availability`, {
            params: { date },
        });
        return response.data;
    },
};
```

### Pool List Component

```javascript
// src/components/PoolList.jsx
import React, { useState, useEffect } from "react";
import { poolService } from "../services/pool";

const PoolList = () => {
    const [pools, setPools] = useState([]);
    const [loading, setLoading] = useState(true);
    const [error, setError] = useState("");

    useEffect(() => {
        fetchPools();
    }, []);

    const fetchPools = async () => {
        try {
            setLoading(true);
            const response = await poolService.getPools();
            setPools(response.data);
        } catch (err) {
            setError("Failed to fetch pools");
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
                        <button className="btn-primary">Book Now</button>
                    </div>
                ))}
            </div>
        </div>
    );
};

export default PoolList;
```

### Booking Service

```javascript
// src/services/booking.js
import apiClient from "./api";

export const bookingService = {
    async getUserBookings() {
        const response = await apiClient.get("/bookings");
        return response.data;
    },

    async createBooking(bookingData) {
        const response = await apiClient.post("/bookings", bookingData);
        return response.data;
    },

    async cancelBooking(id) {
        const response = await apiClient.delete(`/bookings/${id}`);
        return response.data;
    },
};
```

### Booking Form Component

```javascript
// src/components/BookingForm.jsx
import React, { useState } from "react";
import { bookingService } from "../services/booking";

const BookingForm = ({ poolId, onBookingCreated }) => {
    const [formData, setFormData] = useState({
        pool_id: poolId,
        date: "",
        time_slot: "",
        notes: "",
    });
    const [loading, setLoading] = useState(false);
    const [error, setError] = useState("");

    const handleSubmit = async (e) => {
        e.preventDefault();
        setLoading(true);
        setError("");

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
                    <option value="08:00-10:00">08:00-10:00</option>
                    <option value="10:00-12:00">10:00-12:00</option>
                    <option value="12:00-14:00">12:00-14:00</option>
                    <option value="14:00-16:00">14:00-16:00</option>
                    <option value="16:00-18:00">16:00-18:00</option>
                    <option value="18:00-20:00">18:00-20:00</option>
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

            {error && <div className="error">{error}</div>}

            <button type="submit" disabled={loading}>
                {loading ? "Creating..." : "Create Booking"}
            </button>
        </form>
    );
};

export default BookingForm;
```

## 5. App Structure

### Main App Component

```javascript
// src/App.jsx
import React, { useState, useEffect } from "react";
import { authService } from "./services/auth";
import Login from "./components/Login";
import Register from "./components/Register";
import PoolList from "./components/PoolList";
import BookingForm from "./components/BookingForm";

function App() {
    const [user, setUser] = useState(null);
    const [currentView, setCurrentView] = useState("login");
    const [selectedPool, setSelectedPool] = useState(null);

    useEffect(() => {
        const currentUser = authService.getCurrentUser();
        if (currentUser && authService.isAuthenticated()) {
            setUser(currentUser);
            setCurrentView("pools");
        }
    }, []);

    const handleLoginSuccess = () => {
        const currentUser = authService.getCurrentUser();
        setUser(currentUser);
        setCurrentView("pools");
    };

    const handleRegisterSuccess = () => {
        const currentUser = authService.getCurrentUser();
        setUser(currentUser);
        setCurrentView("pools");
    };

    const handleLogout = () => {
        authService.logout();
        setUser(null);
        setCurrentView("login");
    };

    const handleSelectPool = (pool) => {
        setSelectedPool(pool);
        setCurrentView("booking");
    };

    const handleBookingCreated = (booking) => {
        alert("Booking created successfully!");
        setCurrentView("pools");
        setSelectedPool(null);
    };

    const renderView = () => {
        switch (currentView) {
            case "login":
                return <Login onLoginSuccess={handleLoginSuccess} />;
            case "register":
                return <Register onRegisterSuccess={handleRegisterSuccess} />;
            case "pools":
                return <PoolList onSelectPool={handleSelectPool} />;
            case "booking":
                return (
                    <BookingForm
                        poolId={selectedPool?.id}
                        onBookingCreated={handleBookingCreated}
                    />
                );
            default:
                return <Login onLoginSuccess={handleLoginSuccess} />;
        }
    };

    return (
        <div className="app">
            <header className="app-header">
                <h1>Pool Management System</h1>
                {user && (
                    <div className="user-info">
                        <span>Welcome, {user.name}</span>
                        <button onClick={handleLogout}>Logout</button>
                    </div>
                )}
            </header>

            <nav className="app-nav">
                {!user && (
                    <>
                        <button
                            onClick={() => setCurrentView("login")}
                            className={currentView === "login" ? "active" : ""}
                        >
                            Login
                        </button>
                        <button
                            onClick={() => setCurrentView("register")}
                            className={
                                currentView === "register" ? "active" : ""
                            }
                        >
                            Register
                        </button>
                    </>
                )}
                {user && (
                    <>
                        <button
                            onClick={() => setCurrentView("pools")}
                            className={currentView === "pools" ? "active" : ""}
                        >
                            Pools
                        </button>
                    </>
                )}
            </nav>

            <main className="app-main">{renderView()}</main>
        </div>
    );
}

export default App;
```

## 6. Basic Styling

### CSS Styles

```css
/* src/App.css */
.app {
    max-width: 1200px;
    margin: 0 auto;
    padding: 20px;
}

.app-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 30px;
    padding-bottom: 20px;
    border-bottom: 1px solid #ddd;
}

.app-nav {
    margin-bottom: 30px;
}

.app-nav button {
    margin-right: 10px;
    padding: 10px 20px;
    border: 1px solid #ddd;
    background: white;
    cursor: pointer;
}

.app-nav button.active {
    background: #007bff;
    color: white;
}

.user-info {
    display: flex;
    align-items: center;
    gap: 15px;
}

.form-group {
    margin-bottom: 20px;
}

.form-group label {
    display: block;
    margin-bottom: 5px;
    font-weight: bold;
}

.form-group input,
.form-group select,
.form-group textarea {
    width: 100%;
    padding: 10px;
    border: 1px solid #ddd;
    border-radius: 4px;
    font-size: 16px;
}

.btn-primary {
    background: #007bff;
    color: white;
    padding: 10px 20px;
    border: none;
    border-radius: 4px;
    cursor: pointer;
    font-size: 16px;
}

.btn-primary:hover {
    background: #0056b3;
}

.btn-primary:disabled {
    background: #6c757d;
    cursor: not-allowed;
}

.error {
    color: #dc3545;
    margin-bottom: 20px;
    padding: 10px;
    background: #f8d7da;
    border: 1px solid #f5c6cb;
    border-radius: 4px;
}

.pools-grid {
    display: grid;
    grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
    gap: 20px;
}

.pool-card {
    border: 1px solid #ddd;
    border-radius: 8px;
    padding: 20px;
    background: white;
    box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
}

.pool-card h3 {
    margin-top: 0;
    color: #333;
}

.pool-info {
    display: flex;
    justify-content: space-between;
    margin: 15px 0;
    font-size: 14px;
    color: #666;
}

.booking-form {
    max-width: 500px;
    margin: 0 auto;
    padding: 20px;
    border: 1px solid #ddd;
    border-radius: 8px;
    background: white;
}
```

## 7. Testing the Integration

### Test API Connection

```javascript
// src/utils/testApi.js
import apiClient from "../services/api";

export const testApiConnection = async () => {
    try {
        const response = await apiClient.get("/pools");
        console.log("API Connection successful:", response.data);
        return true;
    } catch (error) {
        console.error("API Connection failed:", error);
        return false;
    }
};

// Call this function in your App component
// testApiConnection();
```

### Test Authentication

```javascript
// src/utils/testAuth.js
import { authService } from "../services/auth";

export const testAuthentication = async () => {
    try {
        // Test login with dummy credentials
        const response = await authService.login({
            email: "test@example.com",
            password: "password123",
        });
        console.log("Authentication successful:", response);
        return true;
    } catch (error) {
        console.error("Authentication failed:", error);
        return false;
    }
};
```

## 8. Common Issues & Solutions

### Issue 1: CORS Error

**Problem**: Browser blocks requests due to CORS policy
**Solution**: Ensure backend CORS is configured properly

```php
// In Laravel backend config/cors.php
'allowed_origins' => ['http://localhost:3000'],
'allowed_methods' => ['*'],
'allowed_headers' => ['*'],
```

### Issue 2: 401 Unauthorized

**Problem**: Token expired or invalid
**Solution**: Implement token refresh logic

```javascript
// Add to api.js
apiClient.interceptors.response.use(
    (response) => response,
    async (error) => {
        if (error.response?.status === 401) {
            // Try to refresh token
            try {
                await authService.refreshToken();
                // Retry original request
                return apiClient.request(error.config);
            } catch (refreshError) {
                // Redirect to login
                authService.logout();
                window.location.href = "/login";
            }
        }
        return Promise.reject(error);
    }
);
```

### Issue 3: Network Error

**Problem**: Cannot connect to API
**Solution**: Check API URL and network connectivity

```javascript
// Add error handling
const handleApiError = (error) => {
    if (error.code === "NETWORK_ERROR") {
        alert(
            "Cannot connect to server. Please check your internet connection."
        );
    } else if (error.response?.status >= 500) {
        alert("Server error. Please try again later.");
    }
};
```

## 9. Next Steps

### Advanced Features

1. **Real-time Updates**: Implement WebSocket for live updates
2. **State Management**: Add Redux for complex state management
3. **Routing**: Implement React Router for navigation
4. **Testing**: Add unit and integration tests
5. **Performance**: Implement code splitting and lazy loading

### Production Considerations

1. **Environment Variables**: Use different configs for dev/prod
2. **Error Monitoring**: Integrate Sentry or similar service
3. **Analytics**: Add user behavior tracking
4. **Security**: Implement proper input validation
5. **Performance**: Optimize bundle size and loading

## Conclusion

Quick start guide ini memberikan fondasi dasar untuk mengintegrasikan frontend dengan API sistem pool management. Dengan mengikuti langkah-langkah ini, developer dapat dengan cepat setup dan mulai mengembangkan aplikasi frontend.

### Key Takeaways

-   **Setup yang Mudah**: Konfigurasi API client dan authentication
-   **Core Features**: Implementasi fitur utama (pools, bookings)
-   **Error Handling**: Penanganan error yang proper
-   **Testing**: Cara test integrasi API
-   **Troubleshooting**: Solusi untuk masalah umum
-   **Next Steps**: Panduan untuk pengembangan lebih lanjut
