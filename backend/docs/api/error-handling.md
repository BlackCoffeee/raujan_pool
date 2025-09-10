# Error Handling & Troubleshooting

Panduan lengkap untuk error handling dan troubleshooting API.

## Error Response Format

### 1. Standard Error Response

```json
{
    "success": false,
    "message": "Error message",
    "errors": {
        "field_name": ["Validation error message"]
    },
    "code": "ERROR_CODE",
    "timestamp": "2024-01-15T08:00:00Z"
}
```

### 2. HTTP Status Codes

| Status Code | Description           | Usage                         |
| ----------- | --------------------- | ----------------------------- |
| 200         | OK                    | Request successful            |
| 201         | Created               | Resource created successfully |
| 400         | Bad Request           | Invalid request data          |
| 401         | Unauthorized          | Authentication required       |
| 403         | Forbidden             | Access denied                 |
| 404         | Not Found             | Resource not found            |
| 422         | Unprocessable Entity  | Validation failed             |
| 429         | Too Many Requests     | Rate limit exceeded           |
| 500         | Internal Server Error | Server error                  |

## Common Error Scenarios

### 1. Authentication Errors

#### 401 Unauthorized

```json
{
    "success": false,
    "message": "Unauthorized",
    "code": "UNAUTHORIZED",
    "timestamp": "2024-01-15T08:00:00Z"
}
```

**Causes:**

-   Missing or invalid token
-   Expired token
-   Invalid credentials

**Solutions:**

```javascript
// Check token validity
const checkToken = async () => {
    try {
        const response = await axios.get("/api/v1/auth/me", {
            headers: {
                Authorization: `Bearer ${token}`,
                Accept: "application/json",
            },
        });
        return response.data;
    } catch (error) {
        if (error.response?.status === 401) {
            // Redirect to login
            localStorage.removeItem("token");
            window.location.href = "/login";
        }
    }
};
```

#### 403 Forbidden

```json
{
    "success": false,
    "message": "Access denied. Admin role required.",
    "code": "FORBIDDEN",
    "timestamp": "2024-01-15T08:00:00Z"
}
```

**Causes:**

-   Insufficient permissions
-   Wrong user role
-   Resource access denied

**Solutions:**

```javascript
// Check user role before making request
const checkUserRole = (requiredRole) => {
    const user = JSON.parse(localStorage.getItem("user"));
    if (!user || user.role !== requiredRole) {
        throw new Error("Insufficient permissions");
    }
};

// Usage
checkUserRole("admin");
```

### 2. Validation Errors

#### 422 Unprocessable Entity

```json
{
    "success": false,
    "message": "Validation failed",
    "errors": {
        "email": ["The email field is required."],
        "password": [
            "The password field is required.",
            "The password must be at least 8 characters."
        ]
    },
    "code": "VALIDATION_ERROR",
    "timestamp": "2024-01-15T08:00:00Z"
}
```

**Frontend Handling:**

```javascript
const handleValidationErrors = (error) => {
    if (error.response?.status === 422) {
        const errors = error.response.data.errors;
        Object.keys(errors).forEach((field) => {
            const errorElement = document.getElementById(`${field}-error`);
            if (errorElement) {
                errorElement.textContent = errors[field][0];
            }
        });
    }
};
```

### 3. Resource Not Found

#### 404 Not Found

```json
{
    "success": false,
    "message": "Booking not found",
    "code": "NOT_FOUND",
    "timestamp": "2024-01-15T08:00:00Z"
}
```

**Frontend Handling:**

```javascript
const handleNotFound = (error) => {
    if (error.response?.status === 404) {
        // Show user-friendly message
        showNotification("Resource not found", "error");
        // Redirect to appropriate page
        window.location.href = "/bookings";
    }
};
```

### 4. Rate Limiting

#### 429 Too Many Requests

```json
{
    "success": false,
    "message": "Too many requests. Please try again later.",
    "code": "RATE_LIMIT_EXCEEDED",
    "retry_after": 60,
    "timestamp": "2024-01-15T08:00:00Z"
}
```

**Frontend Handling:**

```javascript
const handleRateLimit = (error) => {
    if (error.response?.status === 429) {
        const retryAfter = error.response.data.retry_after;
        showNotification(
            `Too many requests. Try again in ${retryAfter} seconds.`,
            "warning"
        );

        // Disable button temporarily
        const button = document.getElementById("submit-button");
        button.disabled = true;
        setTimeout(() => {
            button.disabled = false;
        }, retryAfter * 1000);
    }
};
```

### 5. Server Errors

#### 500 Internal Server Error

```json
{
    "success": false,
    "message": "Internal server error",
    "code": "INTERNAL_ERROR",
    "timestamp": "2024-01-15T08:00:00Z"
}
```

**Frontend Handling:**

```javascript
const handleServerError = (error) => {
    if (error.response?.status >= 500) {
        showNotification("Server error. Please try again later.", "error");
        // Log error for debugging
        console.error("Server error:", error);
    }
};
```

## Error Handling Utilities

### 1. Axios Interceptor

```javascript
import axios from "axios";

// Request interceptor
axios.interceptors.request.use(
    (config) => {
        const token = localStorage.getItem("token");
        if (token) {
            config.headers.Authorization = `Bearer ${token}`;
        }
        return config;
    },
    (error) => {
        return Promise.reject(error);
    }
);

// Response interceptor
axios.interceptors.response.use(
    (response) => {
        return response;
    },
    (error) => {
        const { response } = error;

        if (response) {
            switch (response.status) {
                case 401:
                    localStorage.removeItem("token");
                    window.location.href = "/login";
                    break;
                case 403:
                    showNotification("Access denied", "error");
                    break;
                case 404:
                    showNotification("Resource not found", "error");
                    break;
                case 422:
                    handleValidationErrors(error);
                    break;
                case 429:
                    handleRateLimit(error);
                    break;
                case 500:
                    handleServerError(error);
                    break;
                default:
                    showNotification("An error occurred", "error");
            }
        } else {
            showNotification(
                "Network error. Please check your connection.",
                "error"
            );
        }

        return Promise.reject(error);
    }
);
```

### 2. Error Handler Hook (React)

```jsx
import { useState, useCallback } from "react";

const useErrorHandler = () => {
    const [error, setError] = useState(null);

    const handleError = useCallback((error) => {
        console.error("Error:", error);
        setError(error);
    }, []);

    const clearError = useCallback(() => {
        setError(null);
    }, []);

    return { error, handleError, clearError };
};

// Usage in component
const MyComponent = () => {
    const { error, handleError, clearError } = useErrorHandler();

    const handleSubmit = async (data) => {
        try {
            await axios.post("/api/v1/bookings", data);
        } catch (error) {
            handleError(error);
        }
    };

    return (
        <div>
            {error && (
                <div className="error-message">
                    <p>{error.message}</p>
                    <button onClick={clearError}>Dismiss</button>
                </div>
            )}
            {/* Rest of component */}
        </div>
    );
};
```

### 3. Error Handler Composable (Vue.js)

```vue
<script setup>
import { ref } from "vue";

const error = ref(null);

const handleError = (err) => {
    console.error("Error:", err);
    error.value = err;
};

const clearError = () => {
    error.value = null;
};

const handleSubmit = async (data) => {
    try {
        await axios.post("/api/v1/bookings", data);
    } catch (err) {
        handleError(err);
    }
};
</script>

<template>
    <div>
        <div v-if="error" class="error-message">
            <p>{{ error.message }}</p>
            <button @click="clearError">Dismiss</button>
        </div>
        <!-- Rest of template -->
    </div>
</template>
```

## Debugging Tools

### 1. Network Debugging

```javascript
// Enable axios debugging
axios.defaults.debug = true;

// Log all requests
axios.interceptors.request.use((config) => {
    console.log("Request:", config);
    return config;
});

// Log all responses
axios.interceptors.response.use((response) => {
    console.log("Response:", response);
    return response;
});
```

### 2. Error Logging

```javascript
const logError = (error, context = {}) => {
    const errorData = {
        message: error.message,
        stack: error.stack,
        url: window.location.href,
        userAgent: navigator.userAgent,
        timestamp: new Date().toISOString(),
        context,
    };

    // Send to logging service
    fetch("/api/v1/logs/error", {
        method: "POST",
        headers: {
            "Content-Type": "application/json",
            Authorization: `Bearer ${localStorage.getItem("token")}`,
        },
        body: JSON.stringify(errorData),
    });
};
```

### 3. Health Check

```javascript
const checkApiHealth = async () => {
    try {
        const response = await axios.get("/api/v1/health");
        return response.data;
    } catch (error) {
        console.error("API health check failed:", error);
        return null;
    }
};

// Usage
setInterval(checkApiHealth, 30000); // Check every 30 seconds
```

## Common Issues and Solutions

### 1. CORS Issues

**Problem:** Cross-origin requests blocked

**Solution:**

```php
// config/cors.php
return [
    'paths' => ['api/*', 'sanctum/csrf-cookie'],
    'allowed_methods' => ['*'],
    'allowed_origins' => ['http://localhost:3000', 'https://yourdomain.com'],
    'allowed_origins_patterns' => [],
    'allowed_headers' => ['*'],
    'exposed_headers' => [],
    'max_age' => 0,
    'supports_credentials' => true,
];
```

### 2. Token Expiration

**Problem:** Token expires during session

**Solution:**

```javascript
const refreshToken = async () => {
    try {
        const response = await axios.post("/api/v1/auth/refresh");
        localStorage.setItem("token", response.data.data.token);
        return response.data.data.token;
    } catch (error) {
        // Redirect to login
        localStorage.removeItem("token");
        window.location.href = "/login";
    }
};
```

### 3. File Upload Issues

**Problem:** Large file uploads fail

**Solution:**

```javascript
const uploadFile = async (file) => {
    const formData = new FormData();
    formData.append("file", file);

    try {
        const response = await axios.post("/api/v1/upload", formData, {
            headers: {
                "Content-Type": "multipart/form-data",
                Authorization: `Bearer ${token}`,
            },
            timeout: 30000, // 30 seconds timeout
            onUploadProgress: (progressEvent) => {
                const percentCompleted = Math.round(
                    (progressEvent.loaded * 100) / progressEvent.total
                );
                console.log(`Upload progress: ${percentCompleted}%`);
            },
        });
        return response.data;
    } catch (error) {
        if (error.code === "ECONNABORTED") {
            throw new Error("Upload timeout. Please try again.");
        }
        throw error;
    }
};
```

## Monitoring and Alerting

### 1. Error Monitoring

```javascript
// Send error to monitoring service
const reportError = (error, context) => {
    if (window.Sentry) {
        window.Sentry.captureException(error, {
            tags: {
                section: "api",
            },
            extra: context,
        });
    }
};
```

### 2. Performance Monitoring

```javascript
const measureApiCall = async (apiCall) => {
    const start = performance.now();
    try {
        const result = await apiCall();
        const end = performance.now();
        console.log(`API call took ${end - start} milliseconds`);
        return result;
    } catch (error) {
        const end = performance.now();
        console.error(
            `API call failed after ${end - start} milliseconds:`,
            error
        );
        throw error;
    }
};
```

## Notes

-   Selalu handle error dengan graceful
-   Log error untuk debugging
-   Berikan feedback yang jelas ke user
-   Implementasikan retry mechanism untuk network errors
-   Monitor error rates dan performance
-   Test error scenarios secara menyeluruh
