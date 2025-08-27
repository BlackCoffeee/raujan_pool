# Arsitektur Sistem - Sistem Kolam Renang Syariah

## 1. Arsitektur Umum

### 1.1 3-Tier Architecture (Mobile-First Web Application)

```mermaid
graph TB
    subgraph "Frontend Layer (Mobile-First Web)"
        FW1[React/Next.js Web App]
        FW2[Progressive Web App PWA]
        FW3[Responsive Design]
        FW4[Mobile-Optimized UI]
    end

    subgraph "API Gateway Layer"
        AG1[Laravel API Gateway]
        AG2[Authentication Service]
        AG3[Rate Limiting]
        AG4[CORS Handling]
        AG5[Request Routing]
    end

    subgraph "Business Logic Layer"
        BL1[Laravel Backend Services]
        BL2[User Management Service]
        BL3[Booking Service]
        BL4[Payment Service]
        BL5[Cafe Management Service]
        BL6[Notification Service]
        BL7[Pricing Engine]
    end

    subgraph "Data Layer"
        DL1[MySQL Database]
        DL2[Redis Cache]
        DL3[File Storage S3]
        DL4[Session Storage]
    end

    subgraph "External Services"
        ES1[Google OAuth API]
        ES2[Payment Gateways]
        ES3[Push Notification Service]
        ES4[Email Service]
        ES5[SMS Gateway]
    end

    FW1 --> AG1
    FW2 --> AG1
    FW3 --> AG1
    FW4 --> AG1

    AG1 --> BL1
    AG2 --> BL1
    AG3 --> BL1
    AG4 --> BL1
    AG5 --> BL1

    BL1 --> DL1
    BL1 --> DL2
    BL1 --> DL3
    BL1 --> DL4

    BL1 --> ES1
    BL1 --> ES2
    BL1 --> ES3
    BL1 --> ES4
    BL1 --> ES5
```

### 1.2 Microservices Architecture (Future Scalability)

```mermaid
graph TB
    subgraph "Frontend Services"
        FS1[Web App - React/Next.js]
        FS2[Mobile App - React Native]
        FS3[Admin Dashboard]
        FS4[Staff Portal]
    end

    subgraph "API Gateway"
        AG1[Laravel API Gateway]
        AG2[Load Balancer]
        AG3[SSL Termination]
    end

    subgraph "Core Services"
        CS1[User Service - Laravel]
        CS2[Booking Service - Laravel]
        CS3[Payment Service - Laravel]
        CS4[Notification Service - Laravel]
        CS5[Pricing Service - Laravel]
        CS6[Cafe Service - Laravel]
    end

    subgraph "Data Services"
        DS1[MySQL Primary]
        DS2[MySQL Replica]
        DS3[Redis Cache]
        DS4[Session Redis]
        DS5[S3 File Storage]
    end

    subgraph "External Integrations"
        EI1[Google OAuth]
        EI2[Midtrans Payment]
        EI3[Firebase Push Notification]
        EI4[SendGrid Email]
        EI5[Twilio SMS]
    end

    FS1 --> AG1
    FS2 --> AG1
    FS3 --> AG1
    FS4 --> AG1

    AG1 --> CS1
    AG1 --> CS2
    AG1 --> CS3
    AG1 --> CS4
    AG1 --> CS5
    AG1 --> CS6

    CS1 --> DS1
    CS2 --> DS1
    CS3 --> DS1
    CS4 --> DS1
    CS5 --> DS1
    CS6 --> DS1

    CS1 --> EI1
    CS3 --> EI2
    CS4 --> EI3
    CS4 --> EI4
    CS4 --> EI5
```

## 2. Technology Stack

### 2.1 Frontend Stack

```json
{
  "frontend": {
    "framework": "React.js / Next.js",
    "styling": "Tailwind CSS",
    "state_management": "Redux Toolkit / Zustand",
    "routing": "React Router v6",
    "ui_components": "Headless UI / Radix UI",
    "mobile_friendly": "Progressive Web App (PWA)",
    "responsive_design": "Mobile-first approach",
    "charts": "Chart.js / Recharts",
    "forms": "React Hook Form",
    "validation": "Yup / Zod",
    "http_client": "Axios / React Query",
    "notifications": "React-Toastify / Hot Toast"
  }
}
```

### 2.2 Backend Stack

```json
{
  "backend": {
    "framework": "Laravel 11",
    "language": "PHP 8.2+",
    "database": "MySQL 8.0",
    "cache": "Redis 7.0",
    "queue": "Laravel Queue + Redis",
    "authentication": "Laravel Sanctum + JWT",
    "file_upload": "Laravel Storage + AWS S3",
    "validation": "Laravel Form Requests",
    "api": "Laravel API Resources",
    "testing": "Laravel Pest / PHPUnit",
    "deployment": "Laravel Forge / Vapor"
  }
}
```

### 2.3 Infrastructure Stack

```json
{
  "infrastructure": {
    "hosting": "AWS EC2 / DigitalOcean",
    "database": "AWS RDS MySQL",
    "cache": "AWS ElastiCache Redis",
    "storage": "AWS S3 + CloudFront",
    "cdn": "CloudFlare",
    "ssl": "Let's Encrypt / AWS Certificate Manager",
    "monitoring": "Laravel Telescope + New Relic",
    "logging": "Laravel Log + CloudWatch"
  }
}
```

### 2.4 External Services Integration

```json
{
  "integrations": {
    "authentication": {
      "google_oauth": "Google OAuth 2.0 API",
      "local_auth": "Laravel Sanctum"
    },
    "payment": {
      "midtrans": "Midtrans Payment Gateway",
      "manual_payment": "Custom Payment Tracker"
    },
    "notifications": {
      "push": "Firebase Cloud Messaging (FCM)",
      "email": "SendGrid / Laravel Mail",
      "sms": "Twilio SMS API"
    },
    "file_storage": {
      "aws_s3": "AWS S3 Bucket",
      "cloudfront": "AWS CloudFront Distribution"
    }
  }
}
```

## 3. Mobile-First Web Application Architecture

### 3.1 Progressive Web App (PWA) Features

```mermaid
graph TD
    A[PWA Architecture] --> B[Service Worker]
    B --> C[Offline Support]
    B --> D[Push Notifications]
    B --> E[Background Sync]

    A --> F[App Manifest]
    F --> G[Install Prompt]
    F --> H[App-like Experience]

    A --> I[Responsive Design]
    I --> J[Mobile-First CSS]
    I --> K[Touch-Friendly UI]
    I --> L[Fast Loading]

    A --> M[Modern Web APIs]
    M --> N[Web Push API]
    M --> O[Notifications API]
    M --> P[Geolocation API]

    subgraph "Mobile Features"
        MF1[Touch Gestures]
        MF2[Swipe Navigation]
        MF3[Pull-to-Refresh]
        MF4[Fast Tap Response]
        MF5[Offline Booking Cache]
    end

    subgraph "Performance"
        PERF1[Lazy Loading]
        PERF2[Image Optimization]
        PERF3[Code Splitting]
        PERF4[Bundle Optimization]
        PERF5[Critical CSS]
    end
```

### 3.2 Responsive Design Strategy

```json
{
  "responsive_breakpoints": {
    "mobile": "320px - 767px",
    "tablet": "768px - 1023px",
    "desktop": "1024px+",
    "large_desktop": "1440px+"
  },
  "design_principles": {
    "mobile_first": "Design for mobile first, then enhance for larger screens",
    "touch_friendly": "Minimum 44px touch targets",
    "fast_loading": "Optimize for slow mobile connections",
    "accessible": "WCAG 2.1 AA compliance",
    "offline_capable": "Core functionality works offline"
  }
}
```

## 4. API Design

### 4.1 Laravel API Architecture

```mermaid
graph TD
    A[React/Next.js Client] --> B[Laravel API Gateway]
    B --> C[Authentication Middleware]
    C --> D[Rate Limiting]
    D --> E[Request Validation]
    E --> F[Controller Layer]
    F --> G[Service Layer]
    G --> H[Repository Layer]
    H --> I[Database Layer]

    subgraph "Laravel API Structure"
        LA1[API Routes - api.php]
        LA2[API Controllers]
        LA3[API Resources]
        LA4[Form Requests]
        LA5[Service Classes]
        LA6[Repository Pattern]
    end

    subgraph "Authentication Flow"
        AF1[Sanctum Token Auth]
        AF2[JWT Tokens]
        AF3[Google OAuth]
        AF4[Guest Access]
    end
```

### 4.2 API Endpoints Structure

```json
{
  "api_versioning": "v1",
  "authentication": {
    "login": "POST /api/v1/auth/login",
    "register": "POST /api/v1/auth/register",
    "google_login": "POST /api/v1/auth/google",
    "logout": "POST /api/v1/auth/logout",
    "refresh": "POST /api/v1/auth/refresh"
  },
  "booking": {
    "create": "POST /api/v1/bookings",
    "list": "GET /api/v1/bookings",
    "show": "GET /api/v1/bookings/{id}",
    "update": "PUT /api/v1/bookings/{id}",
    "cancel": "DELETE /api/v1/bookings/{id}"
  },
  "pricing": {
    "config": "GET /api/v1/pricing/config",
    "calculate": "POST /api/v1/pricing/calculate",
    "admin_update": "PUT /api/v1/pricing/config"
  },
  "notifications": {
    "subscribe": "POST /api/v1/notifications/subscribe",
    "unsubscribe": "POST /api/v1/notifications/unsubscribe"
  }
}
```

## 5. Push Notification Architecture

### 5.1 Firebase Cloud Messaging (FCM) Integration

```mermaid
graph TD
    A[Laravel Backend] --> B[Notification Service]
    B --> C[Firebase Admin SDK]
    C --> D[FCM API]
    D --> E[Device Registration]
    D --> F[Push Delivery]

    A --> G[Event System]
    G --> H[Notification Events]
    H --> I[Queue Jobs]
    I --> J[Background Processing]

    subgraph "Notification Types"
        NT1[Booking Confirmation]
        NT2[Payment Reminder]
        NT3[Session Reminder]
        NT4[Price Updates]
        NT5[Promotional Offers]
    end

    subgraph "Delivery Channels"
        DC1[Push Notifications]
        DC2[Email Notifications]
        DC3[SMS Notifications]
        DC4[In-App Notifications]
    end
```

### 5.2 Web Push Implementation

```javascript
// Service Worker for Push Notifications
self.addEventListener("push", function (event) {
  const options = {
    body: event.data.text(),
    icon: "/icon-192x192.png",
    badge: "/badge-72x72.png",
    vibrate: [100, 50, 100],
    data: {
      dateOfArrival: Date.now(),
      primaryKey: 1,
    },
    actions: [
      {
        action: "explore",
        title: "View Booking",
        icon: "/checkmark.png",
      },
      {
        action: "close",
        title: "Close",
        icon: "/xmark.png",
      },
    ],
  };

  event.waitUntil(self.registration.showNotification("Raujan Pool", options));
});
```

## 6. Security Architecture

### 6.1 Laravel Security Features

```json
{
  "security_layers": {
    "authentication": {
      "sanctum": "Laravel Sanctum for API tokens",
      "oauth": "Google OAuth 2.0 integration",
      "jwt": "JWT tokens for mobile apps",
      "session": "Secure session management"
    },
    "authorization": {
      "gates": "Laravel Gates for authorization",
      "policies": "Resource-based policies",
      "middleware": "Role-based access control"
    },
    "validation": {
      "form_requests": "Laravel Form Request validation",
      "sanitization": "Input sanitization",
      "sql_injection": "Eloquent ORM protection",
      "xss": "Blade template protection"
    },
    "encryption": {
      "hashing": "bcrypt password hashing",
      "encryption": "Laravel encryption API",
      "ssl": "HTTPS enforcement",
      "cors": "Cross-origin resource sharing"
    }
  }
}
```

## 7. Performance Optimization

### 7.1 Frontend Optimizations

```json
{
  "performance_strategies": {
    "code_splitting": "React.lazy() for route-based splitting",
    "lazy_loading": "Intersection Observer for images",
    "caching": "Service worker cache strategies",
    "bundling": "Webpack optimization",
    "preloading": "Critical resource preloading"
  },
  "mobile_optimizations": {
    "touch_optimized": "Large touch targets",
    "fast_rendering": "Optimized CSS and JS",
    "offline_support": "Service worker caching",
    "responsive_images": "WebP format with fallbacks"
  }
}
```

### 7.2 Backend Optimizations

```json
{
  "laravel_optimizations": {
    "caching": "Redis caching for queries and sessions",
    "database": "Query optimization and indexing",
    "queue": "Background job processing",
    "compression": "Gzip compression",
    "cdn": "Static asset delivery via CDN"
  },
  "api_optimizations": {
    "pagination": "API resource pagination",
    "filtering": "Optional field filtering",
    "rate_limiting": "API rate limiting",
    "compression": "Response compression"
  }
}
```

## 8. Deployment Architecture

### 8.1 Laravel Deployment

```mermaid
graph TD
    A[Git Repository] --> B[CI/CD Pipeline]
    B --> C[Automated Testing]
    C --> D[Build Process]
    D --> E[Deployment]
    E --> F[Production Server]

    subgraph "Server Stack"
        SS1[Nginx Web Server]
        SS2[PHP-FPM 8.2]
        SS3[MySQL 8.0]
        SS4[Redis 7.0]
        SS5[SSL Certificate]
    end

    subgraph "Monitoring"
        M1[Laravel Telescope]
        M2[New Relic APM]
        M3[Server Monitoring]
        M4[Error Tracking]
    end
```

---

**Versi**: 1.2  
**Tanggal**: 26 Agustus 2025  
**Status**: Updated dengan Laravel + React/Next.js Stack  
**Berdasarkan**: PDF Raujan Pool Syariah  
**Key Features**:

- 🖥️ **Laravel Backend** dengan API-first approach
- 📱 **Mobile-First Web App** dengan PWA support
- 🔔 **Push Notifications** via Firebase FCM
- ⚡ **Performance Optimized** untuk mobile users
