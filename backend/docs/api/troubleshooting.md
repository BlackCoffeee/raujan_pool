# API Troubleshooting

Panduan troubleshooting untuk masalah umum API.

## Common Issues

### 1. Authentication Issues

#### Problem: 401 Unauthorized

```
HTTP/1.1 401 Unauthorized
{
    "success": false,
    "message": "Unauthorized",
    "code": "UNAUTHORIZED"
}
```

**Causes:**

-   Missing or invalid token
-   Expired token
-   Invalid credentials
-   Token format error

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
            // Token is invalid or expired
            localStorage.removeItem("token");
            window.location.href = "/login";
        }
    }
};

// Refresh token
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

#### Problem: 403 Forbidden

```
HTTP/1.1 403 Forbidden
{
    "success": false,
    "message": "Access denied. Admin role required.",
    "code": "FORBIDDEN"
}
```

**Causes:**

-   Insufficient permissions
-   Wrong user role
-   Resource access denied

**Solutions:**

```javascript
// Check user role
const checkUserRole = (requiredRole) => {
    const user = JSON.parse(localStorage.getItem("user"));
    if (!user || user.role !== requiredRole) {
        throw new Error("Insufficient permissions");
    }
};

// Check permissions
const checkPermission = (permission) => {
    const user = JSON.parse(localStorage.getItem("user"));
    if (!user || !user.permissions.includes(permission)) {
        throw new Error("Permission denied");
    }
};
```

### 2. Validation Issues

#### Problem: 422 Validation Error

```
HTTP/1.1 422 Unprocessable Entity
{
    "success": false,
    "message": "Validation failed",
    "errors": {
        "email": ["The email field is required."],
        "password": [
            "The password field is required.",
            "The password must be at least 8 characters."
        ]
    }
}
```

**Solutions:**

```javascript
// Handle validation errors
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

// Validate before submit
const validateForm = (data) => {
    const errors = {};

    if (!data.email) {
        errors.email = ["Email is required"];
    }

    if (!data.password) {
        errors.password = ["Password is required"];
    } else if (data.password.length < 8) {
        errors.password = ["Password must be at least 8 characters"];
    }

    return Object.keys(errors).length === 0 ? null : errors;
};
```

### 3. Network Issues

#### Problem: Network Error

```
Error: Network Error
```

**Causes:**

-   No internet connection
-   Server down
-   CORS issues
-   Firewall blocking

**Solutions:**

```javascript
// Check network connectivity
const checkNetwork = async () => {
    try {
        const response = await fetch("/api/v1/health");
        return response.ok;
    } catch (error) {
        return false;
    }
};

// Retry mechanism
const retryRequest = async (requestFn, maxRetries = 3) => {
    for (let i = 0; i < maxRetries; i++) {
        try {
            return await requestFn();
        } catch (error) {
            if (i === maxRetries - 1) throw error;
            await new Promise((resolve) => setTimeout(resolve, 1000 * (i + 1)));
        }
    }
};
```

### 4. Rate Limiting Issues

#### Problem: 429 Too Many Requests

```
HTTP/1.1 429 Too Many Requests
{
    "success": false,
    "message": "Too many requests. Please try again later.",
    "code": "RATE_LIMIT_EXCEEDED",
    "retry_after": 60
}
```

**Solutions:**

```javascript
// Handle rate limiting
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

// Implement request throttling
const throttle = (func, delay) => {
    let timeoutId;
    let lastExecTime = 0;

    return function (...args) {
        const currentTime = Date.now();

        if (currentTime - lastExecTime > delay) {
            func.apply(this, args);
            lastExecTime = currentTime;
        } else {
            clearTimeout(timeoutId);
            timeoutId = setTimeout(() => {
                func.apply(this, args);
                lastExecTime = Date.now();
            }, delay - (currentTime - lastExecTime));
        }
    };
};
```

### 5. Server Issues

#### Problem: 500 Internal Server Error

```
HTTP/1.1 500 Internal Server Error
{
    "success": false,
    "message": "Internal server error",
    "code": "INTERNAL_ERROR"
}
```

**Solutions:**

```javascript
// Handle server errors
const handleServerError = (error) => {
    if (error.response?.status >= 500) {
        showNotification("Server error. Please try again later.", "error");
        console.error("Server error:", error);
    }
};

// Health check
const healthCheck = async () => {
    try {
        const response = await axios.get("/api/v1/health");
        return response.data;
    } catch (error) {
        console.error("Health check failed:", error);
        return null;
    }
};
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
// Log errors to console
const logError = (error, context = {}) => {
    console.error("API Error:", {
        message: error.message,
        status: error.response?.status,
        data: error.response?.data,
        config: error.config,
        context,
    });
};

// Send errors to logging service
const reportError = (error, context = {}) => {
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

### 3. Performance Monitoring

```javascript
// Monitor API performance
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

// Monitor slow requests
const monitorSlowRequests = (threshold = 1000) => {
    axios.interceptors.response.use((response) => {
        const duration =
            response.config.metadata?.endTime -
            response.config.metadata?.startTime;
        if (duration > threshold) {
            console.warn(
                `Slow request detected: ${response.config.url} took ${duration}ms`
            );
        }
        return response;
    });
};
```

## Common Solutions

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
// Auto-refresh token
const setupTokenRefresh = () => {
    setInterval(async () => {
        try {
            await axios.post("/api/v1/auth/refresh");
        } catch (error) {
            // Redirect to login
            localStorage.removeItem("token");
            window.location.href = "/login";
        }
    }, 15 * 60 * 1000); // Refresh every 15 minutes
};
```

### 3. File Upload Issues

**Problem:** Large file uploads fail

**Solution:**

```javascript
// Handle file uploads
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

### 4. WebSocket Connection Issues

**Problem:** WebSocket connection fails

**Solution:**

```javascript
// Handle WebSocket errors
const handleWebSocketError = (echo) => {
    echo.connector.pusher.connection.bind("error", (error) => {
        console.error("WebSocket error:", error);
        showNotification(
            "Connection error. Attempting to reconnect...",
            "warning"
        );
    });

    echo.connector.pusher.connection.bind("disconnected", () => {
        console.log("WebSocket disconnected");
        showNotification("Disconnected from server", "info");
    });

    echo.connector.pusher.connection.bind("reconnected", () => {
        console.log("WebSocket reconnected");
        showNotification("Reconnected to server", "success");
    });
};
```

## Performance Issues

### 1. Slow API Responses

**Causes:**

-   Database queries not optimized
-   Missing indexes
-   Large response payloads
-   Network latency

**Solutions:**

```javascript
// Implement request caching
const cache = new Map();

const cachedRequest = async (url, options = {}) => {
    const cacheKey = `${url}-${JSON.stringify(options)}`;

    if (cache.has(cacheKey)) {
        return cache.get(cacheKey);
    }

    const response = await axios.get(url, options);
    cache.set(cacheKey, response.data);

    // Clear cache after 5 minutes
    setTimeout(() => {
        cache.delete(cacheKey);
    }, 5 * 60 * 1000);

    return response.data;
};
```

### 2. Memory Leaks

**Causes:**

-   Event listeners not removed
-   Timers not cleared
-   Large objects not garbage collected

**Solutions:**

```javascript
// Clean up resources
const cleanup = () => {
    // Clear timers
    clearInterval(intervalId);
    clearTimeout(timeoutId);

    // Remove event listeners
    window.removeEventListener("resize", handleResize);

    // Clear caches
    cache.clear();

    // Disconnect WebSocket
    if (echo) {
        echo.disconnect();
    }
};

// Use cleanup in useEffect
useEffect(() => {
    // Setup code

    return cleanup;
}, []);
```

## Monitoring and Alerting

### 1. Error Monitoring

```javascript
// Send errors to monitoring service
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
// Monitor API performance
const monitorPerformance = () => {
    const observer = new PerformanceObserver((list) => {
        list.getEntries().forEach((entry) => {
            if (entry.name.includes("/api/")) {
                console.log(`API call: ${entry.name} took ${entry.duration}ms`);
            }
        });
    });

    observer.observe({ entryTypes: ["measure"] });
};
```

## Best Practices

### 1. Error Handling

-   Always handle errors gracefully
-   Provide user-friendly error messages
-   Log errors for debugging
-   Implement retry mechanisms
-   Use proper HTTP status codes

### 2. Performance

-   Implement request caching
-   Use pagination for large datasets
-   Optimize database queries
-   Monitor response times
-   Implement request throttling

### 3. Security

-   Validate all inputs
-   Use HTTPS in production
-   Implement rate limiting
-   Sanitize user data
-   Use secure authentication

### 4. Monitoring

-   Monitor error rates
-   Track performance metrics
-   Set up alerts
-   Log important events
-   Monitor user experience

## Support

### Documentation

-   [API Reference](README.md)
-   [Error Handling](error-handling.md)
-   [Integration Examples](integration-examples.md)
-   [Testing Guide](testing-guide.md)

### Contact

-   **Email**: support@raujanpool.com
-   **GitHub**: https://github.com/raujan-pool/backend/issues
-   **Discord**: https://discord.gg/raujanpool
-   **Documentation**: https://docs.raujanpool.com

### Community

-   **Stack Overflow**: Tag questions with `raujan-pool-api`
-   **Reddit**: r/raujanpool
-   **Twitter**: @raujanpool
-   **LinkedIn**: Raujan Pool

## Notes

-   Selalu test error scenarios
-   Implement proper logging
-   Monitor performance metrics
-   Use debugging tools
-   Follow best practices
-   Keep documentation updated
-   Test with different browsers
-   Monitor user feedback
