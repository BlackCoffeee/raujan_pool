# Multicabang Architecture Diagram

## 🏗️ Arsitektur Sistem Multicabang Raujan Pool Syariah

### 1. Database Schema Overview

```mermaid
erDiagram
    branches {
        int id PK
        string code UK
        string name
        string address
        string phone
        string email
        decimal latitude
        decimal longitude
        json operating_hours
        int max_capacity
        boolean is_active
        timestamp created_at
        timestamp updated_at
    }

    branch_staff {
        int id PK
        int branch_id FK
        int user_id FK
        string role
        json permissions
        boolean is_active
        timestamp assigned_at
        int assigned_by FK
        timestamp created_at
        timestamp updated_at
    }

    staff_schedules {
        int id PK
        int branch_staff_id FK
        int day_of_week
        time start_time
        time end_time
        boolean is_active
        timestamp created_at
        timestamp updated_at
    }

    pools {
        int id PK
        int branch_id FK
        string name
        string description
        int capacity
        decimal price_per_hour
        boolean is_active
        timestamp created_at
        timestamp updated_at
    }

    menu_items {
        int id PK
        int branch_id FK
        string name
        string description
        string category
        decimal price
        boolean is_available
        timestamp created_at
        timestamp updated_at
    }

    bookings {
        int id PK
        int branch_id FK
        int user_id FK
        int pool_id FK
        date date
        string time_slot
        string status
        decimal total_amount
        text notes
        timestamp created_at
        timestamp updated_at
    }

    orders {
        int id PK
        int branch_id FK
        int user_id FK
        string status
        decimal total_amount
        timestamp created_at
        timestamp updated_at
    }

    branch_analytics {
        int id PK
        int branch_id FK
        date date
        int total_bookings
        decimal total_revenue
        int total_orders
        int total_customers
        decimal average_booking_value
        decimal occupancy_rate
        decimal customer_satisfaction
        timestamp created_at
        timestamp updated_at
    }

    branches ||--o{ branch_staff : "has"
    branches ||--o{ pools : "contains"
    branches ||--o{ menu_items : "serves"
    branches ||--o{ bookings : "receives"
    branches ||--o{ orders : "processes"
    branches ||--o{ branch_analytics : "tracks"

    branch_staff ||--o{ staff_schedules : "has"
    branch_staff }o--|| users : "assigned to"

    pools ||--o{ bookings : "booked for"
    menu_items ||--o{ order_items : "ordered as"

    users ||--o{ bookings : "makes"
    users ||--o{ orders : "places"
```

### 2. System Architecture Overview

```mermaid
graph TB
    subgraph "Frontend Layer"
        A[Admin Dashboard]
        B[Branch Manager Dashboard]
        C[Staff Dashboard]
        D[Customer App]
    end

    subgraph "API Gateway"
        E[Authentication Middleware]
        F[Authorization Middleware]
        G[Rate Limiting]
        H[Request Validation]
    end

    subgraph "Business Logic Layer"
        I[Branch Management Service]
        J[Staff Management Service]
        K[Pool Management Service]
        L[Menu Management Service]
        M[Booking Management Service]
        N[Analytics Service]
    end

    subgraph "Data Access Layer"
        O[Branch Repository]
        P[Staff Repository]
        Q[Pool Repository]
        R[Menu Repository]
        S[Booking Repository]
        T[Analytics Repository]
    end

    subgraph "Database Layer"
        U[(MySQL Database)]
        V[Redis Cache]
        W[File Storage]
    end

    subgraph "External Services"
        X[Payment Gateway]
        Y[Notification Service]
        Z[Geolocation Service]
    end

    A --> E
    B --> E
    C --> E
    D --> E

    E --> F
    F --> G
    G --> H

    H --> I
    H --> J
    H --> K
    H --> L
    H --> M
    H --> N

    I --> O
    J --> P
    K --> Q
    L --> R
    M --> S
    N --> T

    O --> U
    P --> U
    Q --> U
    R --> U
    S --> U
    T --> U

    I --> V
    J --> V
    K --> V
    L --> V
    M --> V
    N --> V

    M --> X
    M --> Y
    I --> Z
```

### 3. Branch Management Flow

```mermaid
sequenceDiagram
    participant Admin
    participant API
    participant BranchService
    participant Database
    participant Cache

    Admin->>API: Create Branch
    API->>BranchService: validateBranchData()
    BranchService->>Database: createBranch()
    Database-->>BranchService: Branch Created
    BranchService->>Cache: updateBranchCache()
    BranchService-->>API: Branch Response
    API-->>Admin: Success Response

    Admin->>API: Assign Staff to Branch
    API->>BranchService: assignStaffToBranch()
    BranchService->>Database: createBranchStaff()
    Database-->>BranchService: Staff Assigned
    BranchService->>Cache: updateStaffCache()
    BranchService-->>API: Staff Response
    API-->>Admin: Success Response
```

### 4. Cross-Branch Booking Flow

```mermaid
sequenceDiagram
    participant Customer
    participant API
    participant BookingService
    participant BranchService
    participant Database
    participant NotificationService

    Customer->>API: Request Cross-Branch Booking
    API->>BookingService: validateCrossBranchBooking()
    BookingService->>BranchService: checkBranchAvailability()
    BranchService->>Database: getBranchConfig()
    Database-->>BranchService: Branch Config
    BranchService-->>BookingService: Availability Status

    alt Branch Available
        BookingService->>Database: createBooking()
        Database-->>BookingService: Booking Created
        BookingService->>NotificationService: sendBookingConfirmation()
        BookingService-->>API: Booking Success
        API-->>Customer: Booking Confirmed
    else Branch Not Available
        BookingService-->>API: Booking Failed
        API-->>Customer: Booking Unavailable
    end
```

### 5. Analytics Data Flow

```mermaid
flowchart TD
    A[Daily Data Collection] --> B[Branch Analytics Service]
    B --> C[Calculate Metrics]
    C --> D[Store in Analytics Table]
    D --> E[Generate Summary Reports]
    E --> F[Update Cache]
    F --> G[API Response]

    H[Real-time Events] --> I[Event Listener]
    I --> J[Update Analytics]
    J --> K[Trigger Notifications]

    L[Scheduled Jobs] --> M[Generate Period Analytics]
    M --> N[Cross-Branch Comparison]
    N --> O[Performance Insights]
    O --> P[Alert Generation]
```

### 6. Security & Access Control

```mermaid
graph TB
    subgraph "User Roles"
        A[Super Admin]
        B[Branch Admin]
        C[Branch Manager]
        D[Staff]
        E[Customer]
    end

    subgraph "Permissions"
        F[Manage All Branches]
        G[Manage Own Branch]
        H[View Own Branch Data]
        I[Manage Staff]
        J[Process Bookings]
        K[View Analytics]
        L[Place Orders]
    end

    A --> F
    A --> G
    A --> H
    A --> I
    A --> J
    A --> K

    B --> G
    B --> H
    B --> I
    B --> J
    B --> K

    C --> H
    C --> I
    C --> J
    C --> K

    D --> H
    D --> J

    E --> L
```

### 7. Deployment Architecture

```mermaid
graph TB
    subgraph "Load Balancer"
        A[Nginx Load Balancer]
    end

    subgraph "Application Servers"
        B[Laravel App Server 1]
        C[Laravel App Server 2]
        D[Laravel App Server 3]
    end

    subgraph "Database Cluster"
        E[MySQL Master]
        F[MySQL Slave 1]
        G[MySQL Slave 2]
    end

    subgraph "Cache Layer"
        H[Redis Cluster]
    end

    subgraph "File Storage"
        I[Laravel Storage]
    end

    subgraph "Monitoring"
        J[Application Monitoring]
        K[Database Monitoring]
        L[Server Monitoring]
    end

    A --> B
    A --> C
    A --> D

    B --> E
    C --> E
    D --> E

    B --> F
    C --> G
    D --> F

    B --> H
    C --> H
    D --> H

    B --> I
    C --> I
    D --> I

    J --> B
    J --> C
    J --> D
    K --> E
    K --> F
    K --> G
    L --> B
    L --> C
    L --> D
```

## 📊 Key Features Summary

### ✅ Implemented Features

- **Branch Management**: CRUD operations untuk cabang
- **Staff Management**: Penugasan dan manajemen staff per cabang
- **Pool Management**: Manajemen kolam renang per cabang
- **Menu Management**: Manajemen menu cafe per cabang
- **Booking Management**: Sistem booking per cabang dan cross-branch
- **Analytics**: Analitik performa per cabang

### 🔧 Technical Features

- **Database Design**: Schema yang terstruktur dengan relasi yang jelas
- **API Design**: RESTful API dengan validasi dan error handling
- **Security**: Role-based access control dan permission management
- **Caching**: Redis cache untuk performa optimal
- **Testing**: Unit dan feature tests yang komprehensif
- **Documentation**: Dokumentasi API yang lengkap

### 📈 Scalability Features

- **Horizontal Scaling**: Load balancer dan multiple app servers
- **Database Scaling**: Master-slave replication
- **Cache Scaling**: Redis cluster untuk high availability
- **File Storage**: Scalable file storage solution
- **Monitoring**: Comprehensive monitoring dan alerting

---

**Versi**: 1.0  
**Tanggal**: 4 September 2025  
**Status**: Planning Complete  
**Dependencies**: Phase 1-6 Complete  
**Next Steps**: Implementation Phase 7.1-7.6
