# Phase 2: Authentication & User Management

## 📋 Overview

Phase 2 fokus pada implementasi sistem authentication dan user management dengan berbagai role (admin, staff, member, guest) dan integrasi Google SSO.

## 🎯 Objectives

- Implementasi authentication UI components
- Integrasi Google SSO
- Role-based routing dan navigation
- User profile management interface
- Guest user interface
- Session management
- Basic notification system
- User notification preferences
- Authentication notifications
- Branch selection integration
- Cross-branch user management

## 📁 Files

- [01-authentication-ui.md](01-authentication-ui.md) - Login/Register forms dan authentication flow
- [02-google-sso-integration.md](02-google-sso-integration.md) - Google OAuth integration
- [03-role-based-routing.md](03-role-based-routing.md) - Protected routes dan role guards
- [04-user-profile-ui.md](04-user-profile-ui.md) - Profile management interface
- [05-guest-user-ui.md](05-guest-user-ui.md) - Guest user interface
- [06-basic-notifications.md](06-basic-notifications.md) - Basic notification system

## 🚀 Getting Started

1. **Setup Authentication Store**

   ```bash
   # Authentication store sudah dibuat di phase-1
   # Pastikan authStore.ts sudah terkonfigurasi
   ```

2. **Install Additional Dependencies**

   ```bash
   npm install @google-cloud/oauth2
   npm install react-google-login
   npm install react-hook-form @hookform/resolvers zod
   ```

3. **Setup Environment Variables**
   ```env
   VITE_GOOGLE_CLIENT_ID=your-google-client-id
   VITE_GOOGLE_CLIENT_SECRET=your-google-client-secret
   ```

## 📊 Progress Tracking

- [ ] Authentication UI components
- [ ] Google SSO integration
- [ ] Role-based routing
- [ ] User profile management
- [ ] Guest user interface
- [ ] Session management
- [ ] Password reset functionality
- [ ] Email verification
- [ ] Basic notification system
- [ ] User notification preferences
- [ ] Authentication notifications

## 🔐 Authentication Flow

### Login Flow

1. User memasukkan email dan password
2. Validasi input dengan Zod schema
3. API call ke `/auth/login`
4. Store token dan user data
5. Redirect ke dashboard berdasarkan role

### Register Flow

1. User mengisi form registrasi
2. Validasi input dengan Zod schema
3. API call ke `/auth/register`
4. Store token dan user data
5. Redirect ke dashboard berdasarkan role

### Google SSO Flow

1. User klik "Login with Google"
2. Redirect ke Google OAuth
3. User authorize aplikasi
4. Google redirect dengan code
5. Exchange code untuk token
6. Store token dan user data

## 👥 User Roles

### Admin

- Full access ke semua fitur
- User management
- System configuration
- Analytics dan reporting

### Staff

- Access ke staff dashboard
- Booking management
- Payment verification
- Customer service

### Member

- Access ke member dashboard
- Booking management
- Payment history
- Profile management

### Guest

- Limited access
- Basic booking
- No profile management

## 🔔 Basic Notification System

### Authentication Notifications

- Login success notifications
- Logout confirmations
- Registration success
- Password reset notifications
- Email verification notifications

### User Notification Preferences

- Basic notification settings
- Notification channel preferences
- Notification frequency settings
- Do not disturb mode

### Notification Types

- Success notifications
- Error notifications
- Warning notifications
- Info notifications

## 🎨 UI Components

### Authentication Forms

- Login form dengan validation
- Register form dengan validation
- Password reset form
- Email verification form

### User Profile

- Profile information form
- Password change form
- Avatar upload
- Emergency contact form

### Navigation

- Role-based navigation menu
- User dropdown menu
- Breadcrumb navigation
- Mobile navigation

## 📱 Responsive Design

### Mobile

- Touch-friendly forms
- Responsive navigation
- Mobile-optimized layouts
- Swipe gestures

### Desktop

- Keyboard navigation
- Hover effects
- Desktop-optimized layouts
- Multi-column layouts

## 🔧 Development Guidelines

### Form Validation

- Use Zod schemas untuk validation
- Real-time validation feedback
- Error message display
- Success feedback

### State Management

- Use Zustand stores
- Persistent authentication state
- Real-time updates
- Error handling

### Security

- Token management
- Secure storage
- CSRF protection
- Rate limiting

## 📝 Notes

- Pastikan semua API endpoints sesuai dengan backend documentation
- Implementasi proper error handling
- Use TypeScript untuk type safety
- Test semua authentication flows
- Implementasi proper loading states
