# Postman Collection untuk Raujan Pool Syariah API

## 📋 Overview

Folder ini berisi Postman collection untuk testing API Raujan Pool Syariah. Collection akan disediakan dalam format JSON yang dapat diimpor langsung ke Postman.

## 📁 Files

-   `Raujan_Pool_API.postman_collection.json` - Main collection dengan semua endpoints
-   `Raujan_Pool_Environment.postman_environment.json` - Environment variables
-   `README.md` - Panduan penggunaan

## 🚀 Setup

### 1. Import Collection

1. Buka Postman
2. Klik **Import** di sidebar kiri
3. Pilih file `Raujan_Pool_API.postman_collection.json`
4. Klik **Import**

### 2. Import Environment

1. Klik **Import** di sidebar kiri
2. Pilih file `Raujan_Pool_Environment.postman_environment.json`
3. Klik **Import**
4. Pilih environment "Raujan Pool API" di dropdown environment

### 3. Setup Environment Variables

Pastikan environment variables sudah dikonfigurasi:

```json
{
    "base_url": "http://localhost:8000/api/v1",
    "auth_token": "",
    "user_id": "",
    "admin_token": "",
    "staff_token": ""
}
```

## 📊 Collection Structure

### Folders

1. **Public** - Endpoints yang tidak memerlukan autentikasi

    - Health Check
    - API Info

2. **Authentication** - Endpoints untuk autentikasi

    - Login
    - Register
    - Logout
    - Refresh Token
    - Get User Info
    - Google OAuth

3. **Users** - User management endpoints

    - List Users
    - Get User
    - Update User
    - Delete User

4. **Profile** - User profile endpoints

    - Get Profile
    - Update Profile
    - Upload Avatar
    - Delete Avatar

5. **Bookings** - Booking management endpoints

    - List Bookings
    - Create Booking
    - Get Booking
    - Update Booking
    - Delete Booking
    - Confirm Booking
    - Cancel Booking

6. **Calendar** - Calendar endpoints

    - Get Availability
    - Get Sessions
    - Get Date Info

7. **Payments** - Payment endpoints

    - List Payments
    - Create Payment
    - Get Payment
    - Update Payment
    - Upload Proof
    - Get Status

8. **Members** - Member endpoints

    - Get Profile
    - Update Profile
    - Get Quota
    - Get Usage
    - Register Member

9. **Cafe** - Cafe endpoints

    - Get Menu
    - Get Menu Item
    - Create Order
    - Get Orders
    - Get Order
    - Submit Feedback

10. **Admin** - Admin endpoints

    - User Management
    - Booking Management
    - Payment Management
    - Member Management
    - Cafe Management
    - Analytics

11. **Staff** - Staff endpoints
    - Front Desk Operations
    - Payment Verification

## 🔧 Usage

### 1. Testing Public Endpoints

Mulai dengan testing endpoints public untuk memastikan API berjalan:

1. Pilih folder **Public**
2. Jalankan **Health Check** request
3. Jalankan **API Info** request

### 2. Authentication Flow

1. Pilih folder **Authentication**
2. Jalankan **Register** request untuk membuat user baru
3. Jalankan **Login** request untuk mendapatkan token
4. Token akan otomatis disimpan di environment variable `auth_token`

### 3. Testing Protected Endpoints

Setelah mendapatkan token:

1. Pilih folder **Profile**
2. Jalankan **Get Profile** request
3. Token akan otomatis digunakan dari environment

### 4. Testing Admin Endpoints

Untuk testing admin endpoints:

1. Login dengan user admin
2. Token akan disimpan di `admin_token`
3. Pilih folder **Admin** dan test endpoints

## 📝 Environment Variables

### Base Variables

-   `base_url` - Base URL API (default: http://localhost:8000/api/v1)
-   `auth_token` - Token untuk user biasa
-   `admin_token` - Token untuk admin
-   `staff_token` - Token untuk staff

### Dynamic Variables

-   `user_id` - ID user yang sedang login
-   `booking_id` - ID booking untuk testing
-   `payment_id` - ID payment untuk testing

## 🧪 Testing Scenarios

### 1. Basic API Test

```bash
# Test public endpoints
GET {{base_url}}/public/health
GET {{base_url}}/public/info
```

### 2. Authentication Test

```bash
# Register new user
POST {{base_url}}/auth/register
{
  "name": "Test User",
  "email": "test@example.com",
  "password": "password123",
  "password_confirmation": "password123"
}

# Login
POST {{base_url}}/auth/login
{
  "email": "test@example.com",
  "password": "password123"
}
```

### 3. Protected Endpoint Test

```bash
# Get user profile (requires token)
GET {{base_url}}/profile
Authorization: Bearer {{auth_token}}
```

## 🔍 Troubleshooting

### Common Issues

1. **401 Unauthorized**

    - Pastikan token sudah diset di environment
    - Check token belum expired
    - Pastikan header Authorization sudah benar

2. **404 Not Found**

    - Check base_url sudah benar
    - Pastikan endpoint path sudah benar
    - Check API server sudah running

3. **422 Validation Error**

    - Check request body format
    - Pastikan required fields sudah diisi
    - Check data types sesuai requirement

4. **429 Too Many Requests**
    - Rate limit exceeded
    - Tunggu beberapa saat sebelum request lagi

### Debug Tips

1. **Check Response Headers**

    - Lihat status code
    - Check error messages
    - Verify response format

2. **Use Console**

    - Buka Postman Console untuk melihat request/response details
    - Check network tab untuk debugging

3. **Test Environment**
    - Pastikan environment variables sudah benar
    - Check base_url pointing ke server yang benar

## 📚 Additional Resources

-   [Postman Documentation](https://learning.postman.com/docs/)
-   [API Documentation](../api/README.md)
-   [Authentication Guide](../api/authentication.md)
-   [Middleware Documentation](../api/middleware.md)

## 🚀 Next Steps

Setelah collection diimpor:

1. Test semua public endpoints
2. Setup authentication flow
3. Test protected endpoints
4. Test admin/staff endpoints
5. Verify error handling
6. Test rate limiting

Collection ini akan diupdate seiring dengan development API endpoints.


