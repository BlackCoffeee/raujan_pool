# API Documentation

Dokumentasi lengkap untuk Raujan Pool Backend API - Sistem manajemen kolam renang yang komprehensif.

## 📚 Table of Contents

### 🚀 Quick Start & Getting Started

-   [Quick Start Guide](./quick-start-guide.md) - Panduan cepat untuk memulai
-   [API Reference](./api-reference.md) - Referensi lengkap semua endpoint
-   [Frontend Integration Guide](./frontend-integration-guide.md) - Panduan integrasi frontend

### 🔐 Core API Documentation

-   [Authentication](authentication.md) - Login, register, dan token management
-   [User Management](user-management.md) - Profile, roles, dan permissions
-   [Booking System](booking-system.md) - Session booking dan management
-   [Payment System](payment-system.md) - Payment processing dan verification
-   [Member Management](member-management.md) - Membership dan quota management
-   [Calendar & Sessions](calendar-sessions.md) - Session scheduling dan availability
-   [Menu Management](menu-management.md) - Cafe menu dan item management
-   [Order Processing](order-processing.md) - Order tracking dan processing
-   [Inventory Management](inventory-management.md) - Stock management dan tracking
-   [Barcode System](barcode-system.md) - Barcode generation dan scanning
-   [Notification System](notification-system.md) - Push notifications dan alerts
-   [Queue System](queue-system.md) - Background job processing
-   [Refund System](refund-system.md) - Refund processing dan management

### 📊 Advanced Features

-   [Analytics](analytics.md) - Dashboard dan reporting
-   [Staff Operations](staff-operations.md) - Front desk operations
-   [Admin User Management](admin-user-management.md) - User administration
-   [WebSocket & Real-time](websocket-realtime.md) - Real-time updates
-   [WebSocket Integration](websocket-integration.md) - WebSocket setup dan usage

### 🛠️ Development & Deployment

-   [Testing & Quality Assurance](testing-quality-assurance.md) - Testing dan QA
-   [Deployment Guide](deployment-guide.md) - Production deployment
-   [Error Handling](error-handling.md) - Error handling dan troubleshooting
-   [Versioning & Best Practices](versioning-best-practices.md) - API design principles
-   [Integration Examples](integration-examples.md) - Frontend integration examples
-   [Performance Guide](performance.md) - Optimasi performa
-   [Security Guide](security.md) - Keamanan API
-   [Monitoring & Logging](monitoring-logging.md) - Monitoring sistem
-   [Troubleshooting](troubleshooting.md) - Solusi masalah umum

### 📋 Additional Resources

-   [Postman Collection](postman-collection.md) - Collection untuk testing
-   [Changelog](changelog.md) - Riwayat perubahan API

## Quick Start

### 1. Base URL

```
Development: http://localhost:8000/api/v1
Production:  https://yourdomain.com/api/v1
```

### 2. Authentication

```http
Authorization: Bearer {your_token}
```

### 3. Response Format

```json
{
    "success": true,
    "message": "Operation successful",
    "data": {
        // Response data
    },
    "meta": {
        "timestamp": "2024-01-15T08:00:00Z",
        "version": "1.0"
    }
}
```

### 4. Error Format

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

## API Endpoints Overview

### Authentication

-   `POST /auth/register` - User registration
-   `POST /auth/login` - User login
-   `POST /auth/logout` - User logout
-   `GET /auth/me` - Get current user
-   `POST /auth/refresh` - Refresh token

### User Management

-   `GET /users/profile` - Get user profile
-   `PUT /users/profile` - Update user profile
-   `POST /users/change-password` - Change password
-   `GET /users/notifications` - Get notifications
-   `PUT /users/notifications/{id}/read` - Mark notification as read

### Booking System

-   `GET /bookings` - List user bookings
-   `POST /bookings` - Create new booking
-   `GET /bookings/{id}` - Get booking details
-   `PUT /bookings/{id}` - Update booking
-   `POST /bookings/{id}/cancel` - Cancel booking
-   `POST /bookings/{id}/payment` - Submit payment proof

### Payment System

-   `GET /payments` - List user payments
-   `GET /payments/{id}` - Get payment details
-   `POST /payments/{id}/verify` - Verify payment (staff)
-   `POST /payments/{id}/reject` - Reject payment (staff)
-   `POST /payments/{id}/refund` - Request refund

### Member Management

-   `GET /members/profile` - Get member profile
-   `POST /members/renew` - Renew membership
-   `GET /members/quota` - Get quota information
-   `GET /members/usage` - Get usage history
-   `GET /members/expiry` - Get expiry information

### Calendar & Sessions

-   `GET /sessions` - List available sessions
-   `GET /sessions/{id}` - Get session details
-   `GET /sessions/{id}/availability` - Get session availability
-   `GET /calendar` - Get calendar view
-   `GET /calendar/availability` - Get availability data

### Menu Management

-   `GET /menu` - List menu items
-   `GET /menu/{id}` - Get menu item details
-   `POST /menu` - Create menu item (admin)
-   `PUT /menu/{id}` - Update menu item (admin)
-   `DELETE /menu/{id}` - Delete menu item (admin)

### Order Processing

-   `GET /orders` - List user orders
-   `POST /orders` - Create new order
-   `GET /orders/{id}` - Get order details
-   `PUT /orders/{id}` - Update order
-   `POST /orders/{id}/submit` - Submit order
-   `GET /orders/{id}/tracking` - Track order status

### Inventory Management

-   `GET /inventory` - List inventory items
-   `GET /inventory/{id}` - Get inventory item details
-   `POST /inventory` - Create inventory item (admin)
-   `PUT /inventory/{id}` - Update inventory item (admin)
-   `DELETE /inventory/{id}` - Delete inventory item (admin)

### Barcode System

-   `GET /barcodes/generate` - Generate barcode
-   `POST /barcodes/scan` - Scan barcode
-   `GET /barcodes/{id}` - Get barcode details

### Notification System

-   `GET /notifications` - List notifications
-   `PUT /notifications/{id}/read` - Mark as read
-   `PUT /notifications/read-all` - Mark all as read
-   `POST /notifications/send` - Send notification (admin)

### Queue System

-   `GET /queue/status` - Get queue status
-   `POST /queue/jobs` - Create background job
-   `GET /queue/jobs/{id}` - Get job status

### Refund System

-   `GET /refunds` - List user refunds
-   `POST /refunds` - Request refund
-   `GET /refunds/{id}` - Get refund details
-   `POST /refunds/{id}/approve` - Approve refund (admin)
-   `POST /refunds/{id}/reject` - Reject refund (admin)

### Analytics (Admin)

-   `GET /admin/analytics/dashboard` - Dashboard overview
-   `GET /admin/analytics/revenue` - Revenue analytics
-   `GET /admin/analytics/users` - User analytics
-   `GET /admin/analytics/bookings` - Booking analytics
-   `GET /admin/analytics/payment-methods` - Payment method analytics
-   `GET /admin/analytics/members` - Member analytics

### Staff Operations

-   `GET /staff/dashboard` - Staff dashboard
-   `GET /staff/bookings/today` - Today's bookings
-   `POST /staff/bookings/{id}/checkin` - Check-in customer
-   `POST /staff/bookings/{id}/checkout` - Check-out customer
-   `GET /staff/payments/pending` - Pending payments
-   `POST /staff/payments/{id}/verify` - Verify payment
-   `POST /staff/payments/{id}/reject` - Reject payment

### Member Usage

-   `GET /member-usage/history` - Usage history
-   `GET /member-usage/statistics` - Usage statistics
-   `GET /member-usage/quota` - Quota information
-   `GET /member-usage/summary` - Usage summary

### Admin User Management

-   `GET /admin/users` - List all users
-   `GET /admin/users/{id}` - Get user details
-   `POST /admin/users` - Create new user
-   `PUT /admin/users/{id}` - Update user
-   `POST /admin/users/{id}/suspend` - Suspend user
-   `POST /admin/users/{id}/activate` - Activate user
-   `DELETE /admin/users/{id}` - Delete user
-   `GET /admin/users/statistics` - User statistics

## WebSocket Channels

### Public Channels

-   `availability` - Session availability updates
-   `notifications` - System notifications

### Private Channels

-   `booking.{user_id}` - User-specific booking updates
-   `user.{user_id}` - User-specific notifications
-   `admin` - Admin notifications
-   `staff` - Staff notifications

## Rate Limiting

-   **Global**: 60 requests per minute
-   **Authentication**: 5 requests per minute
-   **Booking**: 10 requests per minute
-   **Payment**: 5 requests per minute

## Status Codes

| Code | Description           |
| ---- | --------------------- |
| 200  | OK                    |
| 201  | Created               |
| 400  | Bad Request           |
| 401  | Unauthorized          |
| 403  | Forbidden             |
| 404  | Not Found             |
| 422  | Validation Error      |
| 429  | Too Many Requests     |
| 500  | Internal Server Error |

## Getting Started

1. **Register/Login**: Use authentication endpoints to get access token
2. **Set Authorization Header**: Include `Bearer {token}` in all requests
3. **Explore Endpoints**: Start with user profile and booking endpoints
4. **Handle Errors**: Check response format for error handling
5. **Real-time Updates**: Connect to WebSocket for live updates

## 🎯 Key Features

### 🔐 Authentication & Security

-   **JWT Token Authentication** - Secure token-based authentication
-   **Role-based Access Control** - User, Staff, dan Admin roles
-   **Password Management** - Secure password handling dan reset
-   **Rate Limiting** - Protection against abuse
-   **Input Validation** - Comprehensive data validation

### 🏊 Pool Management

-   **Pool Listing & Details** - Complete pool information
-   **Real-time Availability** - Live availability checking
-   **Time Slot Management** - Flexible scheduling system
-   **Capacity Management** - Automatic capacity tracking

### 📅 Booking System

-   **Easy Booking Creation** - Simple booking process
-   **Booking Management** - Update, cancel, dan track bookings
-   **Conflict Prevention** - Prevents double bookings
-   **Status Tracking** - Real-time booking status updates

### 💳 Payment Processing

-   **Multiple Payment Methods** - Credit card, bank transfer, digital wallet
-   **Payment Verification** - Secure payment verification system
-   **Refund Management** - Automated refund processing
-   **Invoice Generation** - Automatic invoice creation

### 👥 User Management

-   **Profile Management** - Complete user profile system
-   **Member Management** - Membership dan quota tracking
-   **Admin Controls** - User administration tools
-   **Staff Operations** - Front desk operations

### 📊 Analytics & Reporting

-   **Revenue Analytics** - Comprehensive revenue tracking
-   **User Analytics** - User behavior analysis
-   **Booking Analytics** - Booking pattern analysis
-   **Performance Metrics** - System performance monitoring

### 🔄 Real-time Features

-   **WebSocket Integration** - Real-time updates
-   **Live Notifications** - Instant notifications
-   **Availability Updates** - Live pool availability
-   **Status Broadcasting** - Real-time status changes

## 🚀 Getting Started

### 1. Quick Setup

```bash
# Clone repository
git clone https://github.com/your-org/raujan-pool-backend.git

# Install dependencies
composer install

# Setup environment
cp .env.example .env
php artisan key:generate

# Run migrations
php artisan migrate

# Start server
php artisan serve
```

### 2. API Testing

```bash
# Test API connection
curl -X GET http://localhost:8000/api/v1/pools

# Test authentication
curl -X POST http://localhost:8000/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"password123"}'
```

### 3. Frontend Integration

```javascript
// Basic API setup
import axios from "axios";

const api = axios.create({
    baseURL: "http://localhost:8000/api/v1",
    headers: {
        "Content-Type": "application/json",
        Accept: "application/json",
    },
});

// Add authentication
api.interceptors.request.use((config) => {
    const token = localStorage.getItem("auth_token");
    if (token) {
        config.headers.Authorization = `Bearer ${token}`;
    }
    return config;
});
```

## 📈 Performance & Scalability

### Performance Metrics

-   **Response Time**: < 200ms average
-   **Throughput**: 1000+ requests/minute
-   **Uptime**: 99.9% availability
-   **Error Rate**: < 0.1%

### Optimization Features

-   **Database Indexing** - Optimized database queries
-   **Caching System** - Redis caching for better performance
-   **Queue Processing** - Background job processing
-   **API Rate Limiting** - Prevents system overload

## 🔒 Security Features

### Authentication Security

-   **JWT Tokens** - Secure token-based authentication
-   **Token Refresh** - Automatic token renewal
-   **Password Hashing** - Bcrypt password encryption
-   **Session Management** - Secure session handling

### API Security

-   **HTTPS Only** - Encrypted communication
-   **Input Validation** - Comprehensive data validation
-   **SQL Injection Protection** - Parameterized queries
-   **XSS Protection** - Cross-site scripting prevention

### Data Protection

-   **Data Encryption** - Sensitive data encryption
-   **Access Control** - Role-based permissions
-   **Audit Logging** - Complete activity logging
-   **Privacy Compliance** - GDPR compliance ready

## 🛠️ Development Tools

### Testing

-   **Unit Tests** - Comprehensive unit test coverage
-   **Integration Tests** - API integration testing
-   **Load Testing** - Performance testing
-   **Security Testing** - Vulnerability assessment

### Monitoring

-   **Error Tracking** - Real-time error monitoring
-   **Performance Monitoring** - System performance tracking
-   **Log Management** - Centralized logging
-   **Health Checks** - System health monitoring

### Documentation

-   **API Documentation** - Complete endpoint documentation
-   **Code Documentation** - Inline code documentation
-   **Integration Guides** - Frontend integration guides
-   **Best Practices** - Development best practices

## 📞 Support & Resources

### Documentation

-   [Quick Start Guide](./quick-start-guide.md) - Get started quickly
-   [API Reference](./api-reference.md) - Complete API documentation
-   [Frontend Integration Guide](./frontend-integration-guide.md) - Frontend setup
-   [Testing Guide](./testing-quality-assurance.md) - Testing strategies

### Tools & Resources

-   [Postman Collection](./postman-collection.md) - API testing collection
-   [WebSocket Testing](./websocket-integration.md) - Real-time features
-   [Error Handling Guide](./error-handling.md) - Error management
-   [Troubleshooting Guide](./troubleshooting.md) - Common issues

### Community & Support

-   **GitHub Issues** - Bug reports dan feature requests
-   **Documentation Wiki** - Community-contributed guides
-   **Developer Forum** - Discussion dan support
-   **Email Support** - support@raujanpool.com

## 📋 Changelog

### Version 1.0.0 (Current)

-   ✅ Initial API release
-   ✅ Authentication system
-   ✅ Booking management
-   ✅ Payment processing
-   ✅ Member management
-   ✅ Real-time updates
-   ✅ Admin dashboard
-   ✅ Staff operations
-   ✅ Analytics & reporting
-   ✅ WebSocket integration
-   ✅ Comprehensive documentation

### Upcoming Features (v1.1.0)

-   🔄 Mobile app support
-   🔄 Advanced analytics
-   🔄 Multi-language support
-   🔄 Enhanced security features
-   🔄 Performance optimizations
-   🔄 API versioning
-   🔄 GraphQL support

## 📄 License

This API is proprietary software. All rights reserved.

## 🤝 Contributing

We welcome contributions! Please see our contributing guidelines for more information.

## 📧 Contact

For technical support and questions:

-   **Email**: support@raujanpool.com
-   **Documentation**: [docs.raujanpool.com](https://docs.raujanpool.com)
-   **GitHub**: [github.com/raujan-pool/api](https://github.com/raujan-pool/api)
-   **Website**: [raujanpool.com](https://raujanpool.com)
