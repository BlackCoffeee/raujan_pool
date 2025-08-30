# Phase 2: Authentication & User Management

## 📋 Overview

Implementasi sistem autentikasi dan manajemen user dengan Google SSO integration.

## 🎯 Objectives

- Setup Laravel Sanctum authentication
- Implementasi Google SSO integration
- Role-based access control (RBAC)
- Guest user management system
- User profile management

## 📁 Files Structure

```
phase-2/
├── 01-authentication-setup.md
├── 02-google-sso-integration.md
├── 03-role-based-access-control.md
├── 04-guest-user-management.md
└── 05-user-profile-management.md
```

## 🔧 Implementation Points

### Point 1: Laravel Sanctum Authentication

**Subpoints:**

- Install dan konfigurasi Laravel Sanctum
- Setup API token authentication
- Implementasi login/logout endpoints
- Token refresh mechanism
- Session management
- Security middleware

**Files:**

- `app/Http/Controllers/AuthController.php`
- `app/Http/Middleware/Authenticate.php`
- `routes/api.php` - Auth routes
- `config/sanctum.php`

### Point 2: Google SSO Integration

**Subpoints:**

- Install Laravel Socialite
- Konfigurasi Google OAuth credentials
- Implementasi Google login flow
- Handle Google callback
- Sync Google profile data
- Error handling for SSO

**Files:**

- `app/Http/Controllers/GoogleAuthController.php`
- `config/services.php` - Google config
- `app/Models/User.php` - Google fields
- `database/migrations/` - User table updates

### Point 3: Role-Based Access Control (RBAC)

**Subpoints:**

- Define user roles (Admin, Staff, Member, Guest)
- Implementasi permissions system
- Role assignment mechanism
- Permission checking middleware
- Role-based route protection
- Admin role management

**Files:**

- `app/Models/Role.php`
- `app/Models/Permission.php`
- `app/Http/Middleware/CheckRole.php`
- `database/migrations/` - Roles & permissions tables

### Point 4: Guest User Management

**Subpoints:**

- Guest user registration system
- Temporary user accounts
- Guest to member conversion
- Guest session management
- Guest data cleanup
- Guest analytics tracking

**Files:**

- `app/Models/GuestUser.php`
- `app/Http/Controllers/GuestController.php`
- `database/migrations/` - Guest users table
- `app/Jobs/` - Guest cleanup jobs

### Point 5: User Profile Management

**Subpoints:**

- User profile CRUD operations
- Profile validation rules
- Profile image upload
- Emergency contact management
- Profile history tracking
- Profile export functionality

**Files:**

- `app/Http/Controllers/ProfileController.php`
- `app/Http/Requests/` - Profile validation
- `app/Models/UserProfile.php`
- `database/migrations/` - Profile tables

## 📊 Database Schema

### Users Table

```sql
CREATE TABLE users (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    password VARCHAR(255) NULL,
    google_id VARCHAR(255) UNIQUE NULL,
    email_verified_at TIMESTAMP NULL,
    role_id BIGINT UNSIGNED NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    last_login_at TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);
```

### Roles Table

```sql
CREATE TABLE roles (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    display_name VARCHAR(100) NOT NULL,
    description TEXT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);
```

### Guest Users Table

```sql
CREATE TABLE guest_users (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    email VARCHAR(255) NOT NULL,
    name VARCHAR(255) NOT NULL,
    phone VARCHAR(20) NULL,
    temp_token VARCHAR(255) UNIQUE NOT NULL,
    expires_at TIMESTAMP NOT NULL,
    converted_to_member BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);
```

## 🔐 Security Considerations

- Password hashing dengan bcrypt
- CSRF protection
- Rate limiting untuk auth endpoints
- Input validation dan sanitization
- Secure cookie configuration
- JWT token expiration

## 🧪 Testing

- Unit tests untuk auth controllers
- Integration tests untuk SSO flow
- Feature tests untuk role permissions
- API tests untuk auth endpoints
- Security tests untuk vulnerabilities

## 📚 API Endpoints

### Authentication Endpoints

```
POST /api/auth/login
POST /api/auth/logout
POST /api/auth/refresh
POST /api/auth/google
GET  /api/auth/user
```

### User Management Endpoints

```
GET    /api/users
POST   /api/users
GET    /api/users/{id}
PUT    /api/users/{id}
DELETE /api/users/{id}
```

### Profile Endpoints

```
GET    /api/profile
PUT    /api/profile
POST   /api/profile/avatar
DELETE /api/profile/avatar
```

## ✅ Success Criteria

- [ ] User dapat login dengan email/password
- [ ] User dapat login dengan Google SSO
- [ ] Role-based access control berfungsi
- [ ] Guest user dapat register dan convert
- [ ] Profile management berfungsi
- [ ] Security measures terimplementasi
- [ ] Testing coverage > 80%

## 📚 Documentation

- Laravel Sanctum Documentation
- Laravel Socialite Documentation
- Google OAuth 2.0 Documentation
- RBAC Best Practices
