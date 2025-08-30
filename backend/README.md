# Backend Development Plan - Sistem Kolam Renang Syariah

## 📋 Overview

Backend development menggunakan Laravel 11 dengan struktur modular dan scalable.

## 🏗️ Architecture

- **Framework**: Laravel 11
- **Database**: MySQL 8.0
- **Cache**: Redis 7.0
- **WebSocket**: Laravel Reverb
- **Authentication**: JWT + Google OAuth
- **Testing**: Laravel Pest

## 📋 File Hierarchy Rules

Setiap fitur harus mengikuti urutan hirarki file berikut:

```
Database → Model → Repository → Service → Controller
```

### 🔄 Implementation Flow

1. **Database** - Migrations dan database schema
2. **Model** - Eloquent models dengan relationships
3. **Repository** - Data access layer (jika diperlukan)
4. **Service** - Business logic dan complex operations
5. **Controller** - HTTP request handling dan response

### 📁 File Structure Example

```
app/
├── Models/
│   ├── User.php
│   ├── Order.php
│   └── MenuItem.php
├── Repositories/ (optional)
│   ├── UserRepository.php
│   └── OrderRepository.php
├── Services/
│   ├── UserService.php
│   ├── OrderService.php
│   └── MenuService.php
└── Http/Controllers/
    ├── UserController.php
    ├── OrderController.php
    └── MenuController.php
```

### 🎯 Benefits

- **Separation of Concerns**: Setiap layer memiliki tanggung jawab yang jelas
- **Testability**: Mudah untuk unit testing setiap layer
- **Maintainability**: Kode lebih mudah di-maintain dan di-debug
- **Reusability**: Business logic di service bisa digunakan di multiple controller
- **Scalability**: Struktur yang konsisten untuk development tim

## 📁 Structure

```
backend/
├── phase-1/          # Project Setup & Core Infrastructure
│   ├── 01-laravel-setup.md
│   ├── 02-database-configuration.md
│   ├── 03-api-structure.md
│   ├── 04-testing-setup.md
│   └── 05-development-tools.md
├── phase-2/          # Authentication & User Management
│   ├── 01-authentication-setup.md
│   ├── 02-google-sso-integration.md
│   ├── 03-role-based-access-control.md
│   ├── 04-guest-user-management.md
│   └── 05-user-profile-management.md
├── phase-3/          # Booking System & Calendar
│   ├── 01-calendar-backend.md
│   ├── 02-booking-management.md
│   ├── 03-real-time-availability.md
│   ├── 04-session-management.md
│   └── 05-capacity-management.md
├── phase-4/          # Payment System & Manual Payment
│   ├── 01-manual-payment-system.md
│   ├── 02-payment-verification.md
│   ├── 03-payment-tracking.md
│   ├── 04-refund-management.md
│   └── 05-payment-analytics.md
├── phase-5/          # Member Management & Quota System
│   ├── 01-member-registration.md
│   ├── 02-quota-management.md
│   ├── 03-queue-system.md
│   ├── 04-membership-expiry.md
│   └── 05-member-notifications.md
└── phase-6/          # Cafe System & Barcode Integration
    ├── 01-menu-management.md
    ├── 02-barcode-system.md
    ├── 03-order-processing.md
    ├── 04-inventory-management.md
    └── 05-order-tracking.md
```

## 🎯 Development Phases

### Phase 1: Project Setup & Core Infrastructure (Week 1-2)

- Laravel 11 project setup
- Database configuration
- Basic API structure
- Testing environment

### Phase 2: Authentication & User Management (Week 3-4)

- User authentication system
- Google SSO integration
- Role-based access control
- Guest user management

### Phase 3: Booking System & Calendar (Week 5-6)

- Calendar interface backend
- Booking management
- Real-time availability
- Session management

### Phase 4: Payment System & Manual Payment (Week 7-8)

- Payment processing
- Manual payment verification
- Payment status tracking
- Refund management

### Phase 5: Member Management & Quota System (Week 9-10)

- Member registration
- Dynamic quota management
- Queue system
- Membership expiry handling

### Phase 6: Cafe System & Barcode Integration (Week 11-12)

- Menu management
- Order processing
- Barcode generation
- Inventory management
- Order tracking

## 🚀 Getting Started

1. Clone repository
2. Install dependencies: `composer install`
3. Copy environment file: `cp .env.example .env`
4. Configure database settings
5. Run migrations: `php artisan migrate`
6. Start development server: `php artisan serve`

## 📚 Documentation

Each phase contains detailed documentation split into individual files for better organization:

### Phase 1: Project Setup & Core Infrastructure

- [Laravel Setup](phase-1/01-laravel-setup.md) - Laravel 11 installation and configuration
- [Database Configuration](phase-1/02-database-configuration.md) - MySQL setup and migrations
- [API Structure](phase-1/03-api-structure.md) - API routes, middleware, and versioning
- [Testing Setup](phase-1/04-testing-setup.md) - Laravel Pest and testing environment
- [Development Tools](phase-1/05-development-tools.md) - Telescope, Horizon, and code quality tools

### Phase 2: Authentication & User Management

- [Authentication Setup](phase-2/01-authentication-setup.md) - JWT implementation
- [Google SSO Integration](phase-2/02-google-sso-integration.md) - Google OAuth integration
- [Role-Based Access Control](phase-2/03-role-based-access-control.md) - RBAC system
- [Guest User Management](phase-2/04-guest-user-management.md) - Guest user handling
- [User Profile Management](phase-2/05-user-profile-management.md) - Profile CRUD operations

### Phase 3: Booking System & Calendar

- [Calendar Backend](phase-3/01-calendar-backend.md) - Calendar data structure and API
- [Booking Management](phase-3/02-booking-management.md) - Booking CRUD operations
- [Real-time Availability](phase-3/03-real-time-availability.md) - WebSocket integration
- [Session Management](phase-3/04-session-management.md) - Session handling
- [Capacity Management](phase-3/05-capacity-management.md) - Capacity tracking

### Phase 4: Payment System & Manual Payment

- [Manual Payment System](phase-4/01-manual-payment-system.md) - Payment processing
- [Payment Verification](phase-4/02-payment-verification.md) - Admin verification workflow
- [Payment Tracking](phase-4/03-payment-tracking.md) - Payment status tracking
- [Refund Management](phase-4/04-refund-management.md) - Refund processing
- [Payment Analytics](phase-4/05-payment-analytics.md) - Payment reports and analytics

### Phase 5: Member Management & Quota System

- [Member Registration](phase-5/01-member-registration.md) - Member registration workflow
- [Quota Management](phase-5/02-quota-management.md) - Dynamic quota system
- [Queue System](phase-5/03-queue-system.md) - Queue management
- [Membership Expiry](phase-5/04-membership-expiry.md) - Expiry tracking and notifications
- [Member Notifications](phase-5/05-member-notifications.md) - Notification system

### Phase 6: Cafe System & Barcode Integration

- [Menu Management](phase-6/01-menu-management.md) - Menu CRUD operations
- [Barcode System](phase-6/02-barcode-system.md) - Barcode generation and scanning
- [Order Processing](phase-6/03-order-processing.md) - Order workflow
- [Inventory Management](phase-6/04-inventory-management.md) - Stock tracking
- [Order Tracking](phase-6/05-order-tracking.md) - Order status tracking

Each documentation file includes:

- API endpoints
- Database schemas
- Business logic implementation
- Testing procedures
- Success criteria
