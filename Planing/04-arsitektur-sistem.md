# Arsitektur Sistem - Kolam Renang Syariah

## 1. Arsitektur Umum

### 1.1 Arsitektur 3-Tier

```mermaid
graph TB
    subgraph "Presentation Layer"
        A1[Web Application]
        A2[Mobile Application]
        A3[Admin Dashboard]
        A4[Staff Interface]
    end

    subgraph "Business Logic Layer"
        B1[Member Management Service]
        B2[Booking Service]
        B3[Payment Service]
        B4[Cafe Management Service]
        B5[Notification Service]
        B6[Reporting Service]
    end

    subgraph "Data Layer"
        C1[Database]
        C2[File Storage]
        C3[Payment Gateway]
        C4[Email/SMS Service]
    end

    A1 --> B1
    A1 --> B2
    A1 --> B3
    A1 --> B4
    A2 --> B1
    A2 --> B2
    A2 --> B3
    A3 --> B1
    A3 --> B2
    A3 --> B4
    A3 --> B6
    A4 --> B1
    A4 --> B2
    A4 --> B4

    B1 --> C1
    B2 --> C1
    B3 --> C1
    B3 --> C3
    B4 --> C1
    B5 --> C4
    B6 --> C1
```

### 1.2 Arsitektur Microservices

```mermaid
graph LR
    subgraph "API Gateway"
        G1[API Gateway]
    end

    subgraph "Core Services"
        S1[Member Service]
        S2[Booking Service]
        S3[Payment Service]
        S4[Cafe Service]
        S5[Notification Service]
        S6[Reporting Service]
    end

    subgraph "External Services"
        E1[Payment Gateway]
        E2[Email Service]
        E3[SMS Service]
        E4[File Storage]
    end

    subgraph "Data Layer"
        D1[Member DB]
        D2[Booking DB]
        D3[Payment DB]
        D4[Cafe DB]
    end

    G1 --> S1
    G1 --> S2
    G1 --> S3
    G1 --> S4
    G1 --> S5
    G1 --> S6

    S1 --> D1
    S2 --> D2
    S3 --> D3
    S4 --> D4

    S3 --> E1
    S5 --> E2
    S5 --> E3
    S1 --> E4
    S4 --> E4
```

## 2. Teknologi Stack

### 2.1 Frontend Technologies

- **Web Application**

  - React.js atau Vue.js
  - Responsive design
  - Progressive Web App (PWA)
  - Real-time updates

- **Mobile Application**

  - React Native atau Flutter
  - Cross-platform compatibility
  - Offline capability
  - Push notifications

- **Admin Dashboard**
  - React.js dengan Material-UI
  - Real-time dashboard
  - Advanced analytics
  - Export functionality

### 2.2 Backend Technologies

- **API Framework**

  - Node.js dengan Express.js
  - RESTful API design
  - GraphQL (optional)
  - API documentation

- **Database**

  - MySQL atau PostgreSQL
  - Redis untuk caching
  - Database migration
  - Backup automation

- **Authentication**
  - JWT tokens
  - Role-based access control
  - Multi-factor authentication
  - Session management

### 2.3 Infrastructure

- **Hosting**

  - Cloud hosting (AWS/Azure/GCP)
  - Load balancing
  - Auto-scaling
  - CDN for static assets

- **Monitoring**
  - Application performance monitoring
  - Error tracking
  - Uptime monitoring
  - Log management

## 3. Database Design

### 3.1 Database Schema Overview

```mermaid
erDiagram
    USERS ||--o{ MEMBERS : has
    MEMBERS ||--o{ BOOKINGS : makes
    BOOKINGS ||--o{ PAYMENTS : has
    CAFE_ORDERS ||--o{ PAYMENTS : has
    CAFE_MENU ||--o{ CAFE_ORDERS : contains
    CAFE_INVENTORY ||--o{ CAFE_MENU : tracks

    USERS {
        int id PK
        string username
        string email
        string password_hash
        string role
        boolean is_active
        timestamp created_at
        timestamp updated_at
    }

    MEMBERS {
        int id PK
        int user_id FK
        string member_code
        string full_name
        string phone
        string address
        date birth_date
        string gender
        string photo_url
        string emergency_contact
        boolean is_active
        date membership_start
        date membership_end
        timestamp created_at
        timestamp updated_at
    }

    BOOKINGS {
        int id PK
        int member_id FK
        string booking_type
        date booking_date
        string session_time
        int adult_count
        int child_count
        string status
        decimal total_amount
        timestamp created_at
        timestamp updated_at
    }

    PAYMENTS {
        int id PK
        int booking_id FK
        string payment_method
        decimal amount
        string status
        string transaction_id
        timestamp payment_date
        timestamp created_at
    }

    CAFE_MENU {
        int id PK
        string name
        string description
        decimal price
        string category
        string image_url
        boolean is_available
        timestamp created_at
    }

    CAFE_ORDERS {
        int id PK
        int member_id FK
        string order_number
        string status
        decimal total_amount
        timestamp order_date
        timestamp created_at
    }

    CAFE_INVENTORY {
        int id PK
        int menu_id FK
        int current_stock
        int minimum_stock
        string unit
        timestamp last_updated
    }
```

## 4. API Design

### 4.1 RESTful API Endpoints

```mermaid
graph TD
    subgraph "Member APIs"
        M1[POST /api/members]
        M2[GET /api/members]
        M3[GET /api/members/:id]
        M4[PUT /api/members/:id]
        M5[DELETE /api/members/:id]
    end

    subgraph "Booking APIs"
        B1[POST /api/bookings]
        B2[GET /api/bookings]
        B3[GET /api/bookings/:id]
        B4[PUT /api/bookings/:id]
        B5[DELETE /api/bookings/:id]
        B6[GET /api/bookings/availability]
    end

    subgraph "Payment APIs"
        P1[POST /api/payments]
        P2[GET /api/payments]
        P3[GET /api/payments/:id]
        P4[POST /api/payments/verify]
    end

    subgraph "Cafe APIs"
        C1[GET /api/cafe/menu]
        C2[POST /api/cafe/orders]
        C3[GET /api/cafe/orders]
        C4[PUT /api/cafe/orders/:id]
        C5[GET /api/cafe/inventory]
    end
```

### 4.2 API Response Format

```json
{
  "success": true,
  "data": {
    "id": 1,
    "member_code": "M001",
    "full_name": "Ahmad Rahman",
    "phone": "081234567890",
    "membership_status": "active",
    "membership_end": "2025-09-26"
  },
  "message": "Member retrieved successfully",
  "timestamp": "2025-08-26T10:30:00Z"
}
```

## 5. Security Architecture

### 5.1 Authentication & Authorization

```mermaid
graph TD
    A[User Login] --> B[Validate Credentials]
    B --> C[Generate JWT Token]
    C --> D[Store Token]
    D --> E[API Request]
    E --> F[Verify Token]
    F --> G[Check Permissions]
    G --> H[Allow/Deny Access]

    subgraph "Security Layers"
        I[Rate Limiting]
        J[Input Validation]
        K[SQL Injection Prevention]
        L[XSS Protection]
    end
```

### 5.2 Data Protection

- **Encryption**

  - Data at rest encryption
  - Data in transit encryption (HTTPS)
  - Password hashing (bcrypt)
  - Sensitive data masking

- **Access Control**
  - Role-based access control (RBAC)
  - API key management
  - Session management
  - Audit logging

## 6. Integration Architecture

### 6.1 External Integrations

```mermaid
graph LR
    subgraph "Core System"
        S1[Booking System]
        S2[Payment System]
        S3[Notification System]
    end

    subgraph "External Services"
        E1[Payment Gateway]
        E2[Email Service]
        E3[SMS Service]
        E4[File Storage]
    end

    S1 --> E4
    S2 --> E1
    S3 --> E2
    S3 --> E3
```

### 6.2 Payment Integration

- **Payment Gateways**

  - Midtrans
  - Xendit
  - Doku
  - Manual payment tracking

- **Payment Methods**
  - Bank transfer
  - E-wallet
  - Credit/debit card
  - Cash payment

## 7. Deployment Architecture

### 7.1 Production Environment

```mermaid
graph TB
    subgraph "Load Balancer"
        LB[NGINX Load Balancer]
    end

    subgraph "Application Servers"
        AS1[App Server 1]
        AS2[App Server 2]
        AS3[App Server 3]
    end

    subgraph "Database"
        DB1[Primary DB]
        DB2[Replica DB]
    end

    subgraph "Cache Layer"
        C1[Redis Cache]
    end

    subgraph "Storage"
        S1[File Storage]
        S2[Backup Storage]
    end

    LB --> AS1
    LB --> AS2
    LB --> AS3

    AS1 --> DB1
    AS2 --> DB1
    AS3 --> DB1

    AS1 --> C1
    AS2 --> C1
    AS3 --> C1

    AS1 --> S1
    AS2 --> S1
    AS3 --> S1

    DB1 --> DB2
    DB1 --> S2
```

### 7.2 CI/CD Pipeline

```mermaid
graph LR
    A[Code Commit] --> B[Automated Testing]
    B --> C[Build Application]
    C --> D[Deploy to Staging]
    D --> E[Manual Testing]
    E --> F[Deploy to Production]
    F --> G[Health Check]
    G --> H[Monitor]
```

## 8. Performance & Scalability

### 8.1 Performance Optimization

- **Caching Strategy**

  - Redis for session data
  - CDN for static assets
  - Database query caching
  - API response caching

- **Database Optimization**
  - Indexing strategy
  - Query optimization
  - Connection pooling
  - Read replicas

### 8.2 Scalability Considerations

- **Horizontal Scaling**

  - Load balancing
  - Auto-scaling groups
  - Database sharding
  - Microservices architecture

- **Monitoring & Alerting**
  - Application performance monitoring
  - Infrastructure monitoring
  - Business metrics tracking
  - Automated alerting

---

**Versi**: 1.1  
**Tanggal**: 26 Agustus 2025  
**Status**: Updated berdasarkan PDF Raujan Pool Syariah
