# 📚 Dokumentasi Raujan Pool Syariah Backend

## 🎯 Overview

Dokumentasi lengkap untuk sistem backend API Raujan Pool Syariah yang dibangun dengan Laravel 11. Dokumentasi ini mencakup semua aspek pengembangan, testing, dan deployment.

## 📁 Struktur Dokumentasi

### 🚀 Frontend Integration

Panduan khusus untuk tim frontend:

-   **[Frontend Developer Guide](frontend-developer-guide.md)** - Panduan lengkap untuk frontend developers
-   **[Integration Examples](integration-examples.md)** - Contoh integrasi dengan berbagai framework
-   **[API Quick Reference](api/quick-reference.md)** - Referensi cepat API endpoints

### 📊 API Documentation (`/api`)

Dokumentasi lengkap untuk semua API endpoints:

-   **[API Overview](api/README.md)** - Overview dan daftar semua endpoints
-   **[Authentication](api/authentication.md)** - JWT authentication dan Google SSO
-   **[Booking Management](api/booking-management.md)** - Sistem booking dan calendar
-   **[Payment System](api/payment-system.md)** - Payment processing dan verification
-   **[Member Management](api/member-management.md)** - Member registration dan quota
-   **[Member Schema Revision v2](api/member-schema-revision-api.md)** - Member schema revision dengan dynamic pricing
-   **[Menu Management](api/menu-management-api.md)** - Cafe menu dan pricing
-   **[Barcode System](api/barcode-system.md)** - Barcode generation dan scanning
-   **[Order Processing](api/order-processing-api.md)** - Order workflow
-   **[Inventory Management](api/inventory-management.md)** - Stock management
-   **[Order Tracking](api/order-tracking-api.md)** - Order status tracking
-   **[Payment Analytics](api/payment-analytics.md)** - Analytics dan reporting
-   **[RBAC](api/rbac.md)** - Role-based access control
-   **[Real-time Availability](api/real-time-availability.md)** - WebSocket integration

### 🔧 Development Guides (`/development`)

Panduan pengembangan dan best practices:

-   **[Environment Setup](development/environment-setup.md)** - Setup development environment
-   **[Coding Standards](development/coding-standards.md)** - PSR-12 dan Laravel standards
-   **[Scripts](development/scripts.md)** - Development dan deployment scripts
-   **[Real-time Availability Setup](development/real-time-availability-setup.md)** - WebSocket setup
-   **[Refund System Development](development/refund-system-development.md)** - Refund implementation
-   **[Session Management Implementation](development/session-management-implementation.md)** - Session handling
-   **[Member Schema Revision v2](development/member-schema-revision-v2.md)** - Member schema revision implementation

### 🧪 Testing Documentation (`/testing`)

Panduan testing dan quality assurance:

-   **[Coverage Guide](testing/coverage-guide.md)** - Test coverage requirements
-   **[Test Helpers](testing/test-helpers.md)** - Testing utilities dan helpers
-   **[Authentication Testing](testing/phase-2-testing-guide.md)** - Auth system testing
-   **[Booking Testing](testing/booking-testing.md)** - Booking system testing
-   **[Payment Testing](testing/payment-tracking-testing.md)** - Payment system testing
-   **[Member Testing](testing/member-testing.md)** - Member management testing
-   **[Member Schema Revision Testing](testing/member-schema-revision-testing.md)** - Member schema revision testing
-   **[Menu Management Testing](testing/menu-management-testing.md)** - Menu system testing
-   **[Order Processing Testing](testing/order-processing-testing.md)** - Order workflow testing

### 🚀 Deployment Guides (`/deployment`)

Panduan deployment dan production setup:

-   **[Quota Management Deployment](deployment/quota-management-deployment.md)** - Production deployment

### 📮 Postman Collections (`/postman`)

API testing collections:

-   **[Postman Collection](postman/README.md)** - Import dan testing guide

## 🎯 Quick Start

### 1. Setup Development Environment

```bash
# Clone repository
git clone https://github.com/your-org/raujan-pool-backend.git
cd raujan-pool-backend

# Install dependencies
composer install
npm install

# Environment setup
cp .env.example .env
php artisan key:generate

# Database setup
php artisan migrate
php artisan db:seed

# Start development server
composer run dev
```

### 2. Running Tests

```bash
# Run all tests
php artisan test

# Run with coverage
composer run test:coverage

# Run specific test suite
composer run test:feature
composer run test:unit
```

### 3. Code Quality

```bash
# Code formatting
./vendor/bin/pint

# Static analysis
./vendor/bin/phpstan analyse
```

## 📊 System Overview

### 🏗️ Architecture

-   **Framework**: Laravel 11.x
-   **Database**: MySQL 8.0
-   **Cache**: Redis 7.0
-   **WebSocket**: Laravel Reverb
-   **Queue**: Redis + Laravel Horizon
-   **Testing**: Pest PHP

### 📈 Implementation Status

-   **Total API Endpoints**: 100+ endpoints
-   **Database Tables**: 48 tables
-   **Models**: 34 models
-   **Test Coverage**: >90%
-   **Documentation Files**: 50+ files

### ✅ Completed Features

-   [x] Authentication & Authorization (JWT + Google SSO)
-   [x] Booking & Calendar System
-   [x] Payment System dengan manual verification
-   [x] Member Management dengan quota system
-   [x] Member Schema Revision v2 dengan dynamic pricing
-   [x] Cafe System dengan barcode integration
-   [x] Real-time notifications
-   [x] Analytics & Reporting

## 🔗 External Resources

### 📚 Laravel Documentation

-   [Laravel 11.x Documentation](https://laravel.com/docs/11.x)
-   [Laravel Sanctum](https://laravel.com/docs/11.x/sanctum)
-   [Laravel Horizon](https://laravel.com/docs/11.x/horizon)
-   [Laravel Reverb](https://laravel.com/docs/11.x/reverb)

### 🧪 Testing Resources

-   [Pest PHP Documentation](https://pestphp.com/docs)
-   [Laravel Testing](https://laravel.com/docs/11.x/testing)

### 🛠️ Development Tools

-   [Laravel Telescope](https://laravel.com/docs/11.x/telescope)
-   [Laravel Pint](https://laravel.com/docs/11.x/pint)
-   [PHPStan](https://phpstan.org/)

## 📞 Support

Untuk pertanyaan atau dukungan teknis:

-   **Issues**: [GitHub Issues](https://github.com/your-org/raujan-pool-backend/issues)
-   **Email**: support@raujanpool.com
-   **Documentation**: Lihat file-file di folder ini

---

**Last updated**: September 2025  
**Version**: 2.0.0  
**Status**: Production Ready ✅
