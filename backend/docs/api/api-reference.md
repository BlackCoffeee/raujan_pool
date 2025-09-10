# API Reference

## Overview

Referensi lengkap untuk semua endpoint API sistem pool management. Dokumentasi ini mencakup semua endpoint, parameter, response format, dan contoh penggunaan.

## Base Information

### Base URL

```
Production: https://api.poolmanagement.com/api/v1
Development: http://localhost:8000/api/v1
```

### Authentication

Semua endpoint yang memerlukan authentication menggunakan Bearer Token:

```
Authorization: Bearer {token}
```

### Response Format

Semua response menggunakan format JSON dengan struktur konsisten:

#### Success Response

```json
{
    "success": true,
    "data": {
        // Response data
    },
    "message": "Success message (optional)"
}
```

#### Error Response

```json
{
    "success": false,
    "message": "Error message",
    "errors": {
        // Validation errors (optional)
    }
}
```

### Status Codes

-   `200` - OK
-   `201` - Created
-   `400` - Bad Request
-   `401` - Unauthorized
-   `403` - Forbidden
-   `404` - Not Found
-   `422` - Validation Error
-   `429` - Too Many Requests
-   `500` - Internal Server Error

## Authentication Endpoints

### POST /auth/register

Register user baru.

#### Request Body

```json
{
    "name": "John Doe",
    "email": "john@example.com",
    "password": "password123",
    "password_confirmation": "password123",
    "phone": "+1234567890",
    "date_of_birth": "1990-01-01"
}
```

#### Response

```json
{
    "success": true,
    "data": {
        "user": {
            "id": 1,
            "name": "John Doe",
            "email": "john@example.com",
            "phone": "+1234567890",
            "date_of_birth": "1990-01-01",
            "role": "user",
            "created_at": "2024-01-01T00:00:00.000000Z",
            "updated_at": "2024-01-01T00:00:00.000000Z"
        },
        "token": "1|abcdef123456..."
    },
    "message": "User registered successfully"
}
```

### POST /auth/login

Login user.

#### Request Body

```json
{
    "email": "john@example.com",
    "password": "password123"
}
```

#### Response

```json
{
    "success": true,
    "data": {
        "user": {
            "id": 1,
            "name": "John Doe",
            "email": "john@example.com",
            "phone": "+1234567890",
            "date_of_birth": "1990-01-01",
            "role": "user",
            "created_at": "2024-01-01T00:00:00.000000Z",
            "updated_at": "2024-01-01T00:00:00.000000Z"
        },
        "token": "1|abcdef123456..."
    },
    "message": "Login successful"
}
```

### POST /auth/logout

Logout user.

#### Headers

```
Authorization: Bearer {token}
```

#### Response

```json
{
    "success": true,
    "message": "Logged out successfully"
}
```

### POST /auth/refresh

Refresh authentication token.

#### Headers

```
Authorization: Bearer {token}
```

#### Response

```json
{
    "success": true,
    "data": {
        "token": "2|xyz789..."
    },
    "message": "Token refreshed successfully"
}
```

### GET /auth/me

Get current user information.

#### Headers

```
Authorization: Bearer {token}
```

#### Response

```json
{
    "success": true,
    "data": {
        "id": 1,
        "name": "John Doe",
        "email": "john@example.com",
        "phone": "+1234567890",
        "date_of_birth": "1990-01-01",
        "role": "user",
        "created_at": "2024-01-01T00:00:00.000000Z",
        "updated_at": "2024-01-01T00:00:00.000000Z"
    }
}
```

## Pool Endpoints

### GET /pools

Get list of all pools.

#### Query Parameters

-   `page` (integer, optional) - Page number for pagination
-   `per_page` (integer, optional) - Number of items per page (default: 15)
-   `search` (string, optional) - Search by pool name
-   `status` (string, optional) - Filter by status (active, inactive)
-   `sort` (string, optional) - Sort by field (name, price, capacity)
-   `order` (string, optional) - Sort order (asc, desc)

#### Response

```json
{
    "success": true,
    "data": [
        {
            "id": 1,
            "name": "Olympic Pool",
            "description": "50m Olympic standard pool",
            "capacity": 50,
            "price_per_hour": 25.0,
            "status": "active",
            "facilities": [
                "Changing rooms",
                "Shower facilities",
                "Lifeguard service"
            ],
            "images": [
                "https://example.com/pool1.jpg",
                "https://example.com/pool2.jpg"
            ],
            "created_at": "2024-01-01T00:00:00.000000Z",
            "updated_at": "2024-01-01T00:00:00.000000Z"
        }
    ],
    "meta": {
        "current_page": 1,
        "last_page": 5,
        "per_page": 15,
        "total": 75
    }
}
```

### GET /pools/{id}

Get specific pool details.

#### Response

```json
{
    "success": true,
    "data": {
        "id": 1,
        "name": "Olympic Pool",
        "description": "50m Olympic standard pool",
        "capacity": 50,
        "price_per_hour": 25.0,
        "status": "active",
        "facilities": [
            "Changing rooms",
            "Shower facilities",
            "Lifeguard service"
        ],
        "images": [
            "https://example.com/pool1.jpg",
            "https://example.com/pool2.jpg"
        ],
        "operating_hours": {
            "monday": "06:00-22:00",
            "tuesday": "06:00-22:00",
            "wednesday": "06:00-22:00",
            "thursday": "06:00-22:00",
            "friday": "06:00-22:00",
            "saturday": "08:00-20:00",
            "sunday": "08:00-20:00"
        },
        "created_at": "2024-01-01T00:00:00.000000Z",
        "updated_at": "2024-01-01T00:00:00.000000Z"
    }
}
```

### GET /pools/{id}/availability

Get pool availability for specific date.

#### Query Parameters

-   `date` (string, required) - Date in YYYY-MM-DD format

#### Response

```json
{
    "success": true,
    "data": {
        "pool_id": 1,
        "date": "2024-12-25",
        "availability": {
            "08:00-10:00": {
                "available": true,
                "booked_slots": 15,
                "total_capacity": 50
            },
            "10:00-12:00": {
                "available": false,
                "booked_slots": 50,
                "total_capacity": 50
            },
            "12:00-14:00": {
                "available": true,
                "booked_slots": 30,
                "total_capacity": 50
            }
        }
    }
}
```

### GET /pools/{id}/time-slots

Get available time slots for specific date.

#### Query Parameters

-   `date` (string, required) - Date in YYYY-MM-DD format

#### Response

```json
{
    "success": true,
    "data": [
        {
            "time": "08:00-10:00",
            "available": true,
            "booked_slots": 15,
            "total_capacity": 50,
            "price": 25.0
        },
        {
            "time": "10:00-12:00",
            "available": false,
            "booked_slots": 50,
            "total_capacity": 50,
            "price": 25.0
        }
    ]
}
```

## Booking Endpoints

### GET /bookings

Get user's bookings.

#### Headers

```
Authorization: Bearer {token}
```

#### Query Parameters

-   `page` (integer, optional) - Page number for pagination
-   `per_page` (integer, optional) - Number of items per page (default: 15)
-   `status` (string, optional) - Filter by status (pending, confirmed, cancelled, completed)
-   `date_from` (string, optional) - Filter from date (YYYY-MM-DD)
-   `date_to` (string, optional) - Filter to date (YYYY-MM-DD)
-   `sort` (string, optional) - Sort by field (date, created_at)
-   `order` (string, optional) - Sort order (asc, desc)

#### Response

```json
{
    "success": true,
    "data": [
        {
            "id": 1,
            "user_id": 1,
            "pool_id": 1,
            "date": "2024-12-25",
            "time_slot": "10:00-12:00",
            "status": "confirmed",
            "notes": "Birthday party",
            "total_amount": 50.0,
            "pool": {
                "id": 1,
                "name": "Olympic Pool",
                "price_per_hour": 25.0
            },
            "payment": {
                "id": 1,
                "status": "completed",
                "amount": 50.0,
                "payment_method": "credit_card"
            },
            "created_at": "2024-01-01T00:00:00.000000Z",
            "updated_at": "2024-01-01T00:00:00.000000Z"
        }
    ],
    "meta": {
        "current_page": 1,
        "last_page": 3,
        "per_page": 15,
        "total": 45
    }
}
```

### POST /bookings

Create new booking.

#### Headers

```
Authorization: Bearer {token}
```

#### Request Body

```json
{
    "pool_id": 1,
    "date": "2024-12-25",
    "time_slot": "10:00-12:00",
    "notes": "Birthday party"
}
```

#### Response

```json
{
    "success": true,
    "data": {
        "id": 1,
        "user_id": 1,
        "pool_id": 1,
        "date": "2024-12-25",
        "time_slot": "10:00-12:00",
        "status": "pending",
        "notes": "Birthday party",
        "total_amount": 50.0,
        "pool": {
            "id": 1,
            "name": "Olympic Pool",
            "price_per_hour": 25.0
        },
        "created_at": "2024-01-01T00:00:00.000000Z",
        "updated_at": "2024-01-01T00:00:00.000000Z"
    },
    "message": "Booking created successfully"
}
```

### GET /bookings/{id}

Get specific booking details.

#### Headers

```
Authorization: Bearer {token}
```

#### Response

```json
{
    "success": true,
    "data": {
        "id": 1,
        "user_id": 1,
        "pool_id": 1,
        "date": "2024-12-25",
        "time_slot": "10:00-12:00",
        "status": "confirmed",
        "notes": "Birthday party",
        "total_amount": 50.0,
        "pool": {
            "id": 1,
            "name": "Olympic Pool",
            "description": "50m Olympic standard pool",
            "price_per_hour": 25.0,
            "facilities": [
                "Changing rooms",
                "Shower facilities",
                "Lifeguard service"
            ]
        },
        "payment": {
            "id": 1,
            "status": "completed",
            "amount": 50.0,
            "payment_method": "credit_card",
            "transaction_id": "txn_123456",
            "created_at": "2024-01-01T00:00:00.000000Z"
        },
        "created_at": "2024-01-01T00:00:00.000000Z",
        "updated_at": "2024-01-01T00:00:00.000000Z"
    }
}
```

### PUT /bookings/{id}

Update booking.

#### Headers

```
Authorization: Bearer {token}
```

#### Request Body

```json
{
    "date": "2024-12-26",
    "time_slot": "14:00-16:00",
    "notes": "Updated notes"
}
```

#### Response

```json
{
    "success": true,
    "data": {
        "id": 1,
        "user_id": 1,
        "pool_id": 1,
        "date": "2024-12-26",
        "time_slot": "14:00-16:00",
        "status": "confirmed",
        "notes": "Updated notes",
        "total_amount": 50.0,
        "pool": {
            "id": 1,
            "name": "Olympic Pool",
            "price_per_hour": 25.0
        },
        "created_at": "2024-01-01T00:00:00.000000Z",
        "updated_at": "2024-01-01T00:00:00.000000Z"
    },
    "message": "Booking updated successfully"
}
```

### DELETE /bookings/{id}

Cancel booking.

#### Headers

```
Authorization: Bearer {token}
```

#### Response

```json
{
    "success": true,
    "message": "Booking cancelled successfully"
}
```

### GET /bookings/history

Get booking history.

#### Headers

```
Authorization: Bearer {token}
```

#### Query Parameters

-   `page` (integer, optional) - Page number for pagination
-   `per_page` (integer, optional) - Number of items per page (default: 15)
-   `date_from` (string, optional) - Filter from date (YYYY-MM-DD)
-   `date_to` (string, optional) - Filter to date (YYYY-MM-DD)
-   `status` (string, optional) - Filter by status

#### Response

```json
{
    "success": true,
    "data": [
        {
            "id": 1,
            "user_id": 1,
            "pool_id": 1,
            "date": "2024-12-25",
            "time_slot": "10:00-12:00",
            "status": "completed",
            "notes": "Birthday party",
            "total_amount": 50.0,
            "pool": {
                "id": 1,
                "name": "Olympic Pool"
            },
            "payment": {
                "id": 1,
                "status": "completed",
                "amount": 50.0
            },
            "created_at": "2024-01-01T00:00:00.000000Z",
            "updated_at": "2024-01-01T00:00:00.000000Z"
        }
    ],
    "meta": {
        "current_page": 1,
        "last_page": 3,
        "per_page": 15,
        "total": 45
    }
}
```

## Payment Endpoints

### GET /payments/methods

Get available payment methods.

#### Response

```json
{
    "success": true,
    "data": [
        {
            "id": "credit_card",
            "name": "Credit Card",
            "description": "Pay with credit card",
            "icon": "https://example.com/credit-card-icon.png",
            "enabled": true
        },
        {
            "id": "bank_transfer",
            "name": "Bank Transfer",
            "description": "Pay via bank transfer",
            "icon": "https://example.com/bank-icon.png",
            "enabled": true
        },
        {
            "id": "digital_wallet",
            "name": "Digital Wallet",
            "description": "Pay with digital wallet",
            "icon": "https://example.com/wallet-icon.png",
            "enabled": false
        }
    ]
}
```

### POST /payments

Create payment for booking.

#### Headers

```
Authorization: Bearer {token}
```

#### Request Body

```json
{
    "booking_id": 1,
    "payment_method": "credit_card",
    "payment_details": {
        "card_number": "4111111111111111",
        "expiry_date": "12/25",
        "cvv": "123",
        "cardholder_name": "John Doe"
    }
}
```

#### Response

```json
{
    "success": true,
    "data": {
        "id": 1,
        "booking_id": 1,
        "amount": 50.0,
        "payment_method": "credit_card",
        "status": "pending",
        "transaction_id": "txn_123456",
        "created_at": "2024-01-01T00:00:00.000000Z",
        "updated_at": "2024-01-01T00:00:00.000000Z"
    },
    "message": "Payment created successfully"
}
```

### GET /payments/{id}

Get payment details.

#### Headers

```
Authorization: Bearer {token}
```

#### Response

```json
{
    "success": true,
    "data": {
        "id": 1,
        "booking_id": 1,
        "amount": 50.0,
        "payment_method": "credit_card",
        "status": "completed",
        "transaction_id": "txn_123456",
        "payment_details": {
            "card_last_four": "1111",
            "card_brand": "visa"
        },
        "created_at": "2024-01-01T00:00:00.000000Z",
        "updated_at": "2024-01-01T00:00:00.000000Z"
    }
}
```

### POST /payments/{id}/verify

Verify payment.

#### Headers

```
Authorization: Bearer {token}
```

#### Request Body

```json
{
    "verification_code": "123456"
}
```

#### Response

```json
{
    "success": true,
    "data": {
        "id": 1,
        "booking_id": 1,
        "amount": 50.0,
        "payment_method": "credit_card",
        "status": "completed",
        "transaction_id": "txn_123456",
        "verified_at": "2024-01-01T00:00:00.000000Z",
        "created_at": "2024-01-01T00:00:00.000000Z",
        "updated_at": "2024-01-01T00:00:00.000000Z"
    },
    "message": "Payment verified successfully"
}
```

### GET /payments/history

Get payment history.

#### Headers

```
Authorization: Bearer {token}
```

#### Query Parameters

-   `page` (integer, optional) - Page number for pagination
-   `per_page` (integer, optional) - Number of items per page (default: 15)
-   `status` (string, optional) - Filter by status (pending, completed, failed)
-   `date_from` (string, optional) - Filter from date (YYYY-MM-DD)
-   `date_to` (string, optional) - Filter to date (YYYY-MM-DD)

#### Response

```json
{
    "success": true,
    "data": [
        {
            "id": 1,
            "booking_id": 1,
            "amount": 50.0,
            "payment_method": "credit_card",
            "status": "completed",
            "transaction_id": "txn_123456",
            "booking": {
                "id": 1,
                "date": "2024-12-25",
                "time_slot": "10:00-12:00",
                "pool": {
                    "id": 1,
                    "name": "Olympic Pool"
                }
            },
            "created_at": "2024-01-01T00:00:00.000000Z",
            "updated_at": "2024-01-01T00:00:00.000000Z"
        }
    ],
    "meta": {
        "current_page": 1,
        "last_page": 2,
        "per_page": 15,
        "total": 30
    }
}
```

## User Profile Endpoints

### GET /profile

Get user profile.

#### Headers

```
Authorization: Bearer {token}
```

#### Response

```json
{
    "success": true,
    "data": {
        "id": 1,
        "name": "John Doe",
        "email": "john@example.com",
        "phone": "+1234567890",
        "date_of_birth": "1990-01-01",
        "role": "user",
        "profile_picture": "https://example.com/profile.jpg",
        "created_at": "2024-01-01T00:00:00.000000Z",
        "updated_at": "2024-01-01T00:00:00.000000Z"
    }
}
```

### PUT /profile

Update user profile.

#### Headers

```
Authorization: Bearer {token}
```

#### Request Body

```json
{
    "name": "John Smith",
    "phone": "+1234567891",
    "date_of_birth": "1990-01-01"
}
```

#### Response

```json
{
    "success": true,
    "data": {
        "id": 1,
        "name": "John Smith",
        "email": "john@example.com",
        "phone": "+1234567891",
        "date_of_birth": "1990-01-01",
        "role": "user",
        "profile_picture": "https://example.com/profile.jpg",
        "created_at": "2024-01-01T00:00:00.000000Z",
        "updated_at": "2024-01-01T00:00:00.000000Z"
    },
    "message": "Profile updated successfully"
}
```

### POST /profile/change-password

Change user password.

#### Headers

```
Authorization: Bearer {token}
```

#### Request Body

```json
{
    "current_password": "oldpassword123",
    "new_password": "newpassword123",
    "new_password_confirmation": "newpassword123"
}
```

#### Response

```json
{
    "success": true,
    "message": "Password changed successfully"
}
```

### POST /profile/upload-avatar

Upload profile picture.

#### Headers

```
Authorization: Bearer {token}
Content-Type: multipart/form-data
```

#### Request Body

```
avatar: [file]
```

#### Response

```json
{
    "success": true,
    "data": {
        "profile_picture": "https://example.com/profile/new-avatar.jpg"
    },
    "message": "Avatar uploaded successfully"
}
```

## Admin Endpoints

### GET /admin/dashboard

Get admin dashboard data.

#### Headers

```
Authorization: Bearer {token}
```

#### Response

```json
{
    "success": true,
    "data": {
        "total_users": 150,
        "total_bookings": 1250,
        "total_revenue": 31250.0,
        "today_bookings": 25,
        "today_revenue": 625.0,
        "recent_bookings": [
            {
                "id": 1,
                "user": {
                    "id": 1,
                    "name": "John Doe",
                    "email": "john@example.com"
                },
                "pool": {
                    "id": 1,
                    "name": "Olympic Pool"
                },
                "date": "2024-12-25",
                "time_slot": "10:00-12:00",
                "status": "confirmed",
                "total_amount": 50.0,
                "created_at": "2024-01-01T00:00:00.000000Z"
            }
        ],
        "revenue_chart": {
            "labels": ["Jan", "Feb", "Mar", "Apr", "May", "Jun"],
            "data": [5000, 7500, 6200, 8100, 9300, 10500]
        }
    }
}
```

### GET /admin/users

Get all users (Admin only).

#### Headers

```
Authorization: Bearer {token}
```

#### Query Parameters

-   `page` (integer, optional) - Page number for pagination
-   `per_page` (integer, optional) - Number of items per page (default: 15)
-   `search` (string, optional) - Search by name or email
-   `role` (string, optional) - Filter by role (user, staff, admin)
-   `status` (string, optional) - Filter by status (active, inactive, suspended)

#### Response

```json
{
    "success": true,
    "data": [
        {
            "id": 1,
            "name": "John Doe",
            "email": "john@example.com",
            "phone": "+1234567890",
            "role": "user",
            "status": "active",
            "total_bookings": 15,
            "total_spent": 750.0,
            "created_at": "2024-01-01T00:00:00.000000Z",
            "updated_at": "2024-01-01T00:00:00.000000Z"
        }
    ],
    "meta": {
        "current_page": 1,
        "last_page": 10,
        "per_page": 15,
        "total": 150
    }
}
```

### PUT /admin/users/{id}/suspend

Suspend user (Admin only).

#### Headers

```
Authorization: Bearer {token}
```

#### Request Body

```json
{
    "reason": "Violation of terms of service",
    "duration_days": 30
}
```

#### Response

```json
{
    "success": true,
    "message": "User suspended successfully"
}
```

### PUT /admin/users/{id}/activate

Activate user (Admin only).

#### Headers

```
Authorization: Bearer {token}
```

#### Response

```json
{
    "success": true,
    "message": "User activated successfully"
}
```

## Staff Endpoints

### GET /staff/dashboard

Get staff dashboard data.

#### Headers

```
Authorization: Bearer {token}
```

#### Response

```json
{
    "success": true,
    "data": {
        "today_bookings": 25,
        "pending_payments": 5,
        "check_ins": 15,
        "check_outs": 10,
        "recent_activities": [
            {
                "id": 1,
                "type": "check_in",
                "user": {
                    "id": 1,
                    "name": "John Doe"
                },
                "pool": {
                    "id": 1,
                    "name": "Olympic Pool"
                },
                "time_slot": "10:00-12:00",
                "created_at": "2024-01-01T00:00:00.000000Z"
            }
        ]
    }
}
```

### GET /staff/bookings/today

Get today's bookings.

#### Headers

```
Authorization: Bearer {token}
```

#### Query Parameters

-   `status` (string, optional) - Filter by status
-   `pool_id` (integer, optional) - Filter by pool

#### Response

```json
{
    "success": true,
    "data": [
        {
            "id": 1,
            "user": {
                "id": 1,
                "name": "John Doe",
                "phone": "+1234567890"
            },
            "pool": {
                "id": 1,
                "name": "Olympic Pool"
            },
            "date": "2024-12-25",
            "time_slot": "10:00-12:00",
            "status": "confirmed",
            "check_in_time": null,
            "check_out_time": null,
            "total_amount": 50.0,
            "payment": {
                "id": 1,
                "status": "completed"
            }
        }
    ]
}
```

### POST /staff/bookings/{id}/check-in

Check in user for booking.

#### Headers

```
Authorization: Bearer {token}
```

#### Response

```json
{
    "success": true,
    "data": {
        "id": 1,
        "check_in_time": "2024-12-25T10:00:00.000000Z",
        "status": "checked_in"
    },
    "message": "Check-in successful"
}
```

### POST /staff/bookings/{id}/check-out

Check out user from booking.

#### Headers

```
Authorization: Bearer {token}
```

#### Response

```json
{
    "success": true,
    "data": {
        "id": 1,
        "check_out_time": "2024-12-25T12:00:00.000000Z",
        "status": "completed"
    },
    "message": "Check-out successful"
}
```

## Analytics Endpoints

### GET /analytics/revenue

Get revenue analytics.

#### Headers

```
Authorization: Bearer {token}
```

#### Query Parameters

-   `period` (string, optional) - Period (daily, weekly, monthly, yearly)
-   `date_from` (string, optional) - Start date (YYYY-MM-DD)
-   `date_to` (string, optional) - End date (YYYY-MM-DD)

#### Response

```json
{
    "success": true,
    "data": {
        "total_revenue": 31250.0,
        "period_revenue": 6250.0,
        "growth_percentage": 15.5,
        "chart_data": {
            "labels": ["2024-01-01", "2024-01-02", "2024-01-03"],
            "data": [500, 750, 625]
        },
        "breakdown": {
            "credit_card": 18750.0,
            "bank_transfer": 12500.0
        }
    }
}
```

### GET /analytics/bookings

Get booking analytics.

#### Headers

```
Authorization: Bearer {token}
```

#### Query Parameters

-   `period` (string, optional) - Period (daily, weekly, monthly, yearly)
-   `date_from` (string, optional) - Start date (YYYY-MM-DD)
-   `date_to` (string, optional) - End date (YYYY-MM-DD)

#### Response

```json
{
    "success": true,
    "data": {
        "total_bookings": 1250,
        "period_bookings": 250,
        "growth_percentage": 12.3,
        "chart_data": {
            "labels": ["2024-01-01", "2024-01-02", "2024-01-03"],
            "data": [25, 30, 28]
        },
        "status_breakdown": {
            "confirmed": 1000,
            "pending": 150,
            "cancelled": 100
        }
    }
}
```

## WebSocket Events

### Connection

```javascript
// Connect to WebSocket
const echo = new Echo({
    broadcaster: "reverb",
    key: "your-key",
    wsHost: "localhost",
    wsPort: 8080,
});

// Listen for global events
echo.channel("global").listen("SystemMaintenance", (e) => {
    console.log("System maintenance:", e.message);
});
```

### User-specific Events

```javascript
// Listen for user-specific events
echo.private(`user.${userId}`)
    .listen("BookingStatusUpdated", (e) => {
        console.log("Booking status updated:", e.booking);
    })
    .listen("PaymentStatusUpdated", (e) => {
        console.log("Payment status updated:", e.payment);
    });
```

### Pool Availability Events

```javascript
// Listen for pool availability updates
echo.channel(`pool.${poolId}.availability`).listen(
    "AvailabilityUpdated",
    (e) => {
        console.log("Pool availability updated:", e.availability);
    }
);
```

## Error Codes

### Common Error Responses

#### 400 Bad Request

```json
{
    "success": false,
    "message": "Invalid request data",
    "errors": {
        "field_name": ["Error message"]
    }
}
```

#### 401 Unauthorized

```json
{
    "success": false,
    "message": "Unauthenticated"
}
```

#### 403 Forbidden

```json
{
    "success": false,
    "message": "Access denied"
}
```

#### 404 Not Found

```json
{
    "success": false,
    "message": "Resource not found"
}
```

#### 422 Validation Error

```json
{
    "success": false,
    "message": "Validation failed",
    "errors": {
        "email": ["The email field is required"],
        "password": ["The password must be at least 8 characters"]
    }
}
```

#### 429 Too Many Requests

```json
{
    "success": false,
    "message": "Too many requests. Please try again later",
    "retry_after": 60
}
```

#### 500 Internal Server Error

```json
{
    "success": false,
    "message": "Internal server error"
}
```

## Rate Limiting

### Limits

-   **Authentication endpoints**: 5 requests per minute
-   **General API endpoints**: 100 requests per minute
-   **File upload endpoints**: 10 requests per minute

### Headers

```
X-RateLimit-Limit: 100
X-RateLimit-Remaining: 95
X-RateLimit-Reset: 1640995200
```

## Pagination

### Query Parameters

-   `page` - Page number (default: 1)
-   `per_page` - Items per page (default: 15, max: 100)

### Response Format

```json
{
  "data": [...],
  "meta": {
    "current_page": 1,
    "last_page": 10,
    "per_page": 15,
    "total": 150,
    "from": 1,
    "to": 15
  },
  "links": {
    "first": "http://api.example.com/endpoint?page=1",
    "last": "http://api.example.com/endpoint?page=10",
    "prev": null,
    "next": "http://api.example.com/endpoint?page=2"
  }
}
```

## Conclusion

Referensi API ini mencakup semua endpoint yang tersedia dalam sistem pool management. Setiap endpoint dilengkapi dengan parameter, response format, dan contoh penggunaan yang jelas untuk memudahkan integrasi frontend.

### Key Features

-   **Comprehensive Coverage**: Semua endpoint API terdokumentasi
-   **Clear Examples**: Request dan response examples untuk setiap endpoint
-   **Error Handling**: Dokumentasi error codes dan handling
-   **Real-time Features**: WebSocket events dan channels
-   **Rate Limiting**: Informasi tentang batasan request
-   **Pagination**: Format pagination yang konsisten
