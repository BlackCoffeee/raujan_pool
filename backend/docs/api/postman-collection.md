# Postman Collection

Panduan lengkap untuk menggunakan Postman collection API.

## Import Collection

### 1. Download Collection

```bash
# Download dari repository
curl -O https://raw.githubusercontent.com/your-repo/raujan-pool-backend/main/docs/postman/raujan-pool-api.json
```

### 2. Import ke Postman

1. Buka Postman
2. Klik "Import" di sidebar kiri
3. Pilih file `raujan-pool-api.json`
4. Klik "Import"

## Environment Setup

### 1. Create Environment

```json
{
    "name": "Raujan Pool API",
    "values": [
        {
            "key": "base_url",
            "value": "http://localhost:8000/api/v1",
            "enabled": true
        },
        {
            "key": "token",
            "value": "",
            "enabled": true
        },
        {
            "key": "user_id",
            "value": "",
            "enabled": true
        },
        {
            "key": "booking_id",
            "value": "",
            "enabled": true
        },
        {
            "key": "session_id",
            "value": "",
            "enabled": true
        }
    ]
}
```

### 2. Set Environment Variables

-   `base_url`: Base URL API (development/production)
-   `token`: Authentication token
-   `user_id`: Current user ID
-   `booking_id`: Booking ID for testing
-   `session_id`: Session ID for testing

## Collection Structure

### 1. Authentication

```
📁 Authentication
├── 🔐 Register User
├── 🔐 Login User
├── 🔐 Logout User
├── 🔐 Get Current User
└── 🔐 Refresh Token
```

### 2. User Management

```
📁 User Management
├── 👤 Get User Profile
├── ✏️ Update User Profile
├── 🔒 Change Password
├── 🔔 Get Notifications
└── ✅ Mark Notification as Read
```

### 3. Booking System

```
📁 Booking System
├── 📋 List User Bookings
├── ➕ Create New Booking
├── 👁️ Get Booking Details
├── ✏️ Update Booking
├── ❌ Cancel Booking
└── 💳 Submit Payment Proof
```

### 4. Payment System

```
📁 Payment System
├── 💰 List User Payments
├── 👁️ Get Payment Details
├── ✅ Verify Payment (Staff)
├── ❌ Reject Payment (Staff)
└── 💸 Request Refund
```

### 5. Member Management

```
📁 Member Management
├── 👤 Get Member Profile
├── 🔄 Renew Membership
├── 📊 Get Quota Information
├── 📈 Get Usage History
└── ⏰ Get Expiry Information
```

### 6. Calendar & Sessions

```
📁 Calendar & Sessions
├── 📅 List Available Sessions
├── 👁️ Get Session Details
├── 📊 Get Session Availability
├── 📆 Get Calendar View
└── 📈 Get Availability Data
```

### 7. Menu Management

```
📁 Menu Management
├── 🍽️ List Menu Items
├── 👁️ Get Menu Item Details
├── ➕ Create Menu Item (Admin)
├── ✏️ Update Menu Item (Admin)
└── 🗑️ Delete Menu Item (Admin)
```

### 8. Order Processing

```
📁 Order Processing
├── 📋 List User Orders
├── ➕ Create New Order
├── 👁️ Get Order Details
├── ✏️ Update Order
├── 📤 Submit Order
└── 📍 Track Order Status
```

### 9. Inventory Management

```
📁 Inventory Management
├── 📦 List Inventory Items
├── 👁️ Get Inventory Item Details
├── ➕ Create Inventory Item (Admin)
├── ✏️ Update Inventory Item (Admin)
└── 🗑️ Delete Inventory Item (Admin)
```

### 10. Barcode System

```
📁 Barcode System
├── 🔲 Generate Barcode
├── 📱 Scan Barcode
└── 👁️ Get Barcode Details
```

### 11. Notification System

```
📁 Notification System
├── 🔔 List Notifications
├── ✅ Mark as Read
├── ✅ Mark All as Read
└── 📤 Send Notification (Admin)
```

### 12. Queue System

```
📁 Queue System
├── 📊 Get Queue Status
├── ➕ Create Background Job
└── 👁️ Get Job Status
```

### 13. Refund System

```
📁 Refund System
├── 💸 List User Refunds
├── ➕ Request Refund
├── 👁️ Get Refund Details
├── ✅ Approve Refund (Admin)
└── ❌ Reject Refund (Admin)
```

### 14. Analytics (Admin)

```
📁 Analytics (Admin)
├── 📊 Dashboard Overview
├── 💰 Revenue Analytics
├── 👥 User Analytics
├── 📅 Booking Analytics
├── 💳 Payment Method Analytics
└── 👤 Member Analytics
```

### 15. Staff Operations

```
📁 Staff Operations
├── 🏠 Staff Dashboard
├── 📅 Today's Bookings
├── ✅ Check-in Customer
├── ✅ Check-out Customer
├── 💰 Pending Payments
├── ✅ Verify Payment
└── ❌ Reject Payment
```

### 16. Member Usage

```
📁 Member Usage
├── 📈 Usage History
├── 📊 Usage Statistics
├── 📋 Quota Information
└── 📄 Usage Summary
```

### 17. Admin User Management

```
📁 Admin User Management
├── 👥 List All Users
├── 👁️ Get User Details
├── ➕ Create New User
├── ✏️ Update User
├── ⏸️ Suspend User
├── ▶️ Activate User
├── 🗑️ Delete User
└── 📊 User Statistics
```

## Pre-request Scripts

### 1. Global Pre-request Script

```javascript
// Set base URL if not set
if (!pm.environment.get("base_url")) {
    pm.environment.set("base_url", "http://localhost:8000/api/v1");
}

// Add timestamp to requests
pm.environment.set("timestamp", new Date().toISOString());
```

### 2. Authentication Pre-request Script

```javascript
// Check if token exists
const token = pm.environment.get("token");
if (!token) {
    console.log("No token found. Please login first.");
}
```

## Test Scripts

### 1. Global Test Script

```javascript
// Test response structure
pm.test("Response has success field", function () {
    pm.expect(pm.response.json()).to.have.property("success");
});

pm.test("Response is successful", function () {
    pm.expect(pm.response.json().success).to.be.true;
});

pm.test("Response time is less than 2000ms", function () {
    pm.expect(pm.response.responseTime).to.be.below(2000);
});

pm.test("Response has correct content type", function () {
    pm.expect(pm.response.headers.get("Content-Type")).to.include(
        "application/json"
    );
});
```

### 2. Authentication Test Script

```javascript
// Test login response
pm.test("Login successful", function () {
    const response = pm.response.json();
    pm.expect(response.success).to.be.true;
    pm.expect(response.data).to.have.property("token");
    pm.expect(response.data).to.have.property("user");
});

// Store token and user ID
if (pm.response.json().success) {
    const response = pm.response.json();
    pm.environment.set("token", response.data.token);
    pm.environment.set("user_id", response.data.user.id);
}
```

### 3. Booking Test Script

```javascript
// Test booking response
pm.test("Booking created successfully", function () {
    const response = pm.response.json();
    pm.expect(response.success).to.be.true;
    pm.expect(response.data.booking).to.have.property("id");
    pm.expect(response.data.booking).to.have.property("booking_code");
});

// Store booking ID
if (pm.response.json().success) {
    const response = pm.response.json();
    pm.environment.set("booking_id", response.data.booking.id);
}
```

## Environment Variables

### 1. Development Environment

```json
{
    "name": "Development",
    "values": [
        {
            "key": "base_url",
            "value": "http://localhost:8000/api/v1",
            "enabled": true
        },
        {
            "key": "token",
            "value": "",
            "enabled": true
        }
    ]
}
```

### 2. Production Environment

```json
{
    "name": "Production",
    "values": [
        {
            "key": "base_url",
            "value": "https://yourdomain.com/api/v1",
            "enabled": true
        },
        {
            "key": "token",
            "value": "",
            "enabled": true
        }
    ]
}
```

## Collection Runner

### 1. Run All Tests

```bash
# Run collection with environment
newman run raujan-pool-api.json -e development.json
```

### 2. Run Specific Folder

```bash
# Run only authentication tests
newman run raujan-pool-api.json -e development.json --folder "Authentication"
```

### 3. Run with Data File

```bash
# Run with test data
newman run raujan-pool-api.json -e development.json -d test-data.json
```

## Test Data

### 1. Test Users

```json
{
    "users": [
        {
            "name": "Test User",
            "email": "test@example.com",
            "password": "password123",
            "phone": "081234567890"
        },
        {
            "name": "Admin User",
            "email": "admin@example.com",
            "password": "admin123",
            "role": "admin"
        }
    ]
}
```

### 2. Test Bookings

```json
{
    "bookings": [
        {
            "session_id": 1,
            "booking_date": "2024-01-15",
            "notes": "Test booking"
        }
    ]
}
```

## Monitoring and Reporting

### 1. Collection Monitoring

```javascript
// Monitor collection performance
pm.test("Collection performance", function () {
    pm.expect(pm.response.responseTime).to.be.below(1000);
});

// Log performance metrics
console.log("Response time: " + pm.response.responseTime + "ms");
console.log("Status code: " + pm.response.code);
```

### 2. Generate Report

```bash
# Generate HTML report
newman run raujan-pool-api.json -e development.json -r html --reporter-html-export report.html
```

## Best Practices

### 1. Environment Management

-   Use separate environments for development and production
-   Store sensitive data in environment variables
-   Use descriptive variable names
-   Keep environments in sync

### 2. Test Organization

-   Group related tests in folders
-   Use descriptive test names
-   Add meaningful assertions
-   Include error handling tests

### 3. Data Management

-   Use test data files for bulk testing
-   Clean up test data after runs
-   Use unique identifiers for test data
-   Validate data integrity

### 4. Documentation

-   Add descriptions to requests
-   Include example responses
-   Document required parameters
-   Add troubleshooting notes

## Troubleshooting

### 1. Common Issues

-   **401 Unauthorized**: Check token validity
-   **403 Forbidden**: Verify user permissions
-   **404 Not Found**: Check endpoint URL
-   **422 Validation Error**: Validate request data

### 2. Debug Tips

-   Check request headers
-   Verify environment variables
-   Review response body
-   Check console logs

### 3. Performance Issues

-   Monitor response times
-   Check server logs
-   Verify network connectivity
-   Review request payload size

## Notes

-   Selalu gunakan environment variables untuk konfigurasi
-   Test semua endpoint secara menyeluruh
-   Monitor performance dan error rates
-   Update collection secara berkala
-   Dokumentasikan perubahan API
-   Gunakan version control untuk collection
-   Backup environment dan collection files
