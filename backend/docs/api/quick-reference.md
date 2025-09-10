# 🚀 API Quick Reference - Raujan Pool Syariah

## 📋 Most Used Endpoints

### 🔐 Authentication

```bash
# Login
POST /api/v1/auth/login
Body: { "email": "user@example.com", "password": "password" }

# Register
POST /api/v1/auth/register
Body: { "name": "John Doe", "email": "john@example.com", "password": "password", ... }

# Get Current User
GET /api/v1/auth/user
Headers: Authorization: Bearer {token}

# Logout
POST /api/v1/auth/logout
Headers: Authorization: Bearer {token}
```

### 📅 Booking System

```bash
# Check Availability
GET /api/v1/calendar/availability?start_date=2024-01-15&end_date=2024-01-20

# Get Sessions
GET /api/v1/calendar/sessions

# Create Booking
POST /api/v1/bookings
Body: { "session_id": 1, "booking_date": "2024-01-15", "adult_count": 2, "child_count": 1 }

# Get My Bookings
GET /api/v1/bookings/my

# Cancel Booking
POST /api/v1/bookings/{id}/cancel
Body: { "reason": "Change of plans" }
```

### 💰 Payment System

```bash
# Create Payment
POST /api/v1/payments
Body: { "booking_id": 1, "amount": 75000, "payment_method": "bank_transfer" }

# Upload Payment Proof
POST /api/v1/payments/{id}/upload-proof
Body: FormData with image file

# Get Payment Status
GET /api/v1/payments/{id}/status

# Payment Tracking
GET /api/v1/payments/{id}/tracking/timeline
```

### 🍽️ Cafe System

```bash
# Get Menu
GET /api/v1/members/menu

# Get Menu Categories
GET /api/v1/members/menu/categories

# Create Order
POST /api/v1/members/orders
Body: { "items": [{"menu_item_id": 1, "quantity": 2}] }

# Get My Orders
GET /api/v1/members/orders

# Track Order
GET /api/v1/members/orders/{id}/status

# Scan Barcode
POST /api/v1/members/barcode/scan
Body: { "barcode_value": "QR000001" }
```

### 👤 Profile Management

```bash
# Get Profile
GET /api/v1/profile

# Update Profile
PUT /api/v1/profile
Body: { "name": "Updated Name", "phone": "081234567890" }

# Get Member Profile
GET /api/v1/members/profile

# Check Quota
GET /api/v1/members/quota

# Get Usage History
GET /api/v1/members/usage/history
```

### 👨‍💼 Admin Operations

```bash
# Get All Users
GET /api/v1/admin/users

# Create User
POST /api/v1/admin/users
Body: { "name": "New User", "email": "new@example.com", "role": "member" }

# Get All Members
GET /api/v1/admin/members

# Get System Analytics
GET /api/v1/admin/analytics/dashboard

# Get Pending Payments
GET /api/v1/admin/payments?status=pending

# Verify Payment
PUT /api/v1/admin/payments/{id}/verify
```

### 👨‍💻 Staff Operations

```bash
# Get Staff Dashboard
GET /api/v1/staff/front-desk/dashboard

# Check-in Booking
PUT /api/v1/staff/front-desk/bookings/{id}/check-in

# Check-out Booking
PUT /api/v1/staff/front-desk/bookings/{id}/check-out

# Get Pending Payments
GET /api/v1/staff/payments/pending

# Verify Payment
PUT /api/v1/staff/payments/{id}/verify
```

## 🔑 Common Headers

```bash
# Authentication
Authorization: Bearer {token}

# Content Type
Content-Type: application/json

# Accept
Accept: application/json

# API Version
API-Version: v1
```

## 📊 Common Response Patterns

### Success Response

```json
{
    "success": true,
    "message": "Operation successful",
    "data": {
        // Response data
    }
}
```

### Error Response

```json
{
    "success": false,
    "message": "Error message",
    "data": null,
    "errors": {
        "field": ["Error message"]
    }
}
```

### Paginated Response

```json
{
    "success": true,
    "message": "Data retrieved successfully",
    "data": {
        "data": [...],
        "current_page": 1,
        "last_page": 5,
        "per_page": 15,
        "total": 75
    }
}
```

## 🚨 Common Error Codes

| Code | Meaning          | Solution               |
| ---- | ---------------- | ---------------------- |
| 401  | Unauthorized     | Check token validity   |
| 403  | Forbidden        | Check user permissions |
| 404  | Not Found        | Verify resource exists |
| 422  | Validation Error | Check request data     |
| 429  | Rate Limited     | Wait and retry         |

## 🔄 Common Query Parameters

### Pagination

```bash
?page=1&per_page=15
```

### Filtering

```bash
?status=active&type=member&start_date=2024-01-01&end_date=2024-01-31
```

### Searching

```bash
?search=john&q=keyword
```

### Sorting

```bash
?sort=created_at&order=desc
```

## 📱 Frontend Integration Examples

### JavaScript/Fetch

```javascript
// Login
const login = async (email, password) => {
    const response = await fetch("/api/v1/auth/login", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ email, password }),
    });
    return response.json();
};

// Authenticated Request
const getProfile = async (token) => {
    const response = await fetch("/api/v1/profile", {
        headers: { Authorization: `Bearer ${token}` },
    });
    return response.json();
};
```

### Axios

```javascript
// Setup
const api = axios.create({
    baseURL: "/api/v1",
    headers: { "Content-Type": "application/json" },
});

// Request interceptor
api.interceptors.request.use((config) => {
    const token = localStorage.getItem("token");
    if (token) {
        config.headers.Authorization = `Bearer ${token}`;
    }
    return config;
});

// Usage
const createBooking = async (bookingData) => {
    const response = await api.post("/bookings", bookingData);
    return response.data;
};
```

### React Hook Example

```javascript
const useApi = (url, options = {}) => {
    const [data, setData] = useState(null);
    const [loading, setLoading] = useState(false);
    const [error, setError] = useState(null);

    useEffect(() => {
        const fetchData = async () => {
            setLoading(true);
            try {
                const response = await api.get(url, options);
                setData(response.data);
            } catch (err) {
                setError(err.response?.data?.message || "Error occurred");
            } finally {
                setLoading(false);
            }
        };

        fetchData();
    }, [url]);

    return { data, loading, error };
};
```

## 🧪 Testing Commands

```bash
# Test Authentication
curl -X POST http://localhost:8000/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"password"}'

# Test Booking
curl -X GET http://localhost:8000/api/v1/calendar/availability \
  -H "Authorization: Bearer {token}"

# Test Menu
curl -X GET http://localhost:8000/api/v1/members/menu \
  -H "Authorization: Bearer {token}"
```

## 📚 Related Documentation

-   **[Complete API Documentation](./README.md)** - Full API documentation
-   **[Frontend Developer Guide](../frontend-developer-guide.md)** - Frontend integration guide
-   **[Authentication API](./authentication.md)** - Detailed auth documentation
-   **[Booking API](./booking-management.md)** - Booking system documentation
-   **[Payment API](./payment-system.md)** - Payment system documentation

---

**Quick Reference Version**: 1.0.0  
**Last Updated**: December 2024
