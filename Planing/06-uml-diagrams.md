# UML Diagrams - Sistem Kolam Renang Syariah

## 1. Use Case Diagram

### 1.1 Use Case Diagram Utama

```mermaid
graph TB
    subgraph "Sistem Kolam Renang Syariah"
        subgraph "Actors"
            A1[Admin]:::admin
            A2[Staff Front Desk]:::staff
            A3[Staff Cafe]:::staff
            A4[Member]:::member
            A5[Non-Member]:::guest
        end

        subgraph "Member Management"
            UC1[Register Member]
            UC2[Update Profile]
            UC3[Manage Packages]
            UC4[View History]
            UC5[Renew Membership]
        end

        subgraph "Booking System"
            UC6[Access Calendar Interface]
            UC7[Navigate Calendar Forward]
            UC8[Select Available Date]
            UC9[View Session Details]
            UC10[Select Session]
            UC11[Register as Guest/Member]
            UC12[Complete Booking]
            UC13[Receive Confirmation]
            UC14[Cancel Booking]
            UC15[Check-in/Check-out]
            UC16[View Schedule]
            UC17[Check Real-time Availability]
            UC18[Book Regular Session]
            UC19[Book Private Session]
        end

        subgraph "Payment System"
            UC20[Pay Membership]
            UC21[Pay Regular Session]
            UC22[Pay Private Session]
            UC23[Process Refund]
        end

        subgraph "Cafe Management"
            UC24[Browse Menu]
            UC25[Place Order]
            UC26[Manage Inventory]
            UC27[Update Stock]
            UC28[Track Sales]
        end

        subgraph "Reporting"
            UC29[Generate Member Report]
            UC30[Generate Booking Report]
            UC31[Generate Sales Report]
            UC32[View Analytics]
        end
    end

    A1 -.-> UC1
    A1 -.-> UC2
    A1 -.-> UC3
    A1 -.-> UC4
    A1 -.-> UC21
    A1 -.-> UC22
    A1 -.-> UC23
    A1 -.-> UC24

    A2 -.-> UC1
    A2 -.-> UC2
    A2 -.-> UC9
    A2 -.-> UC11
    A2 -.-> UC12
    A2 -.-> UC13
    A2 -.-> UC14

    A3 -.-> UC16
    A3 -.-> UC17
    A3 -.-> UC18
    A3 -.-> UC19
    A3 -.-> UC20

    A4 -.-> UC2
    A4 -.-> UC4
    A4 -.-> UC6
    A4 -.-> UC7
    A4 -.-> UC8
    A4 -.-> UC10
    A4 -.-> UC16
    A4 -.-> UC17
    A4 -.-> UC5

    A5 -.-> UC6
    A5 -.-> UC8
    A5 -.-> UC10
    A5 -.-> UC11
    A5 -.-> UC13
    A5 -.-> UC14
    A5 -.-> UC16
    A5 -.-> UC17

    %% Custom styling untuk lines dengan warna berbeda
    linkStyle 0,1,2,3,4,5,6,7 stroke:#ff6b6b,stroke-width:3px
    linkStyle 8,9,10,11,12,13,14 stroke:#4ecdc4,stroke-width:3px
    linkStyle 15,16,17,18,19 stroke:#4ecdc4,stroke-width:3px
    linkStyle 20,21,22,23,24,25,26,27,28 stroke:#45b7d1,stroke-width:3px
    linkStyle 29,30,31,32,33,34,35,36 stroke:#96ceb4,stroke-width:3px
```

### 1.2 Use Case Diagram Detail Member

```mermaid
graph TB
    subgraph "Member Management System"
        subgraph "Actors"
            A1[Member]
            A2[Admin]
            A3[Staff]
        end

        subgraph "Registration Process"
            UC1[Fill Registration Form]
            UC2[Upload Documents]
            UC3[Choose Package]
            UC4[Make Payment]
            UC5[Verify Documents]
            UC6[Activate Account]
            UC7[Generate Member Card]
        end

        subgraph "Profile Management"
            UC8[Update Personal Info]
            UC9[Change Password]
            UC10[Upload Photo]
            UC11[Update Emergency Contact]
            UC12[View Booking History]
            UC13[Check Membership Status]
        end

        subgraph "Membership Management"
            UC14[Renew Membership]
            UC15[Upgrade Package]
            UC16[Cancel Membership]
            UC17[Request Refund]
            UC18[View Payment History]
        end
    end

    A1 --> UC1
    A1 --> UC8
    A1 --> UC9
    A1 --> UC10
    A1 --> UC11
    A1 --> UC12
    A1 --> UC13
    A1 --> UC14
    A1 --> UC15
    A1 --> UC16
    A1 --> UC17
    A1 --> UC18

    A2 --> UC2
    A2 --> UC3
    A2 --> UC5
    A2 --> UC6
    A2 --> UC7

    A3 --> UC4
    A3 --> UC5
    A3 --> UC6
    A3 --> UC7
```

## 2. Class Diagram

### 2.1 Class Diagram Utama

```mermaid
classDiagram
    class User {
        -int id
        -string username
        -string email
        -string password_hash
        -string role
        -boolean is_active
        -timestamp created_at
        -timestamp updated_at
        +login()
        +logout()
        +changePassword()
        +updateProfile()
    }

    class Member {
        -int id
        -int user_id
        -string member_code
        -string full_name
        -string phone
        -string address
        -date birth_date
        -string gender
        -string photo_url
        -string emergency_contact
        -boolean is_active
        -date membership_start
        -date membership_end
        -string membership_type
        +register()
        +updateProfile()
        +renewMembership()
        +checkMembershipStatus()
        +makeBooking()
    }

    classDef user-class fill:#ff6b6b,stroke:#333,stroke-width:2px,color:#fff
    classDef member-class fill:#45b7d1,stroke:#333,stroke-width:2px,color:#fff
    classDef booking-class fill:#4ecdc4,stroke:#333,stroke-width:2px,color:#fff
    classDef session-class fill:#96ceb4,stroke:#333,stroke-width:2px,color:#fff
    classDef package-class fill:#ffeaa7,stroke:#333,stroke-width:2px,color:#000

    User:::user-class
    Member:::member-class

    class Package {
        -int id
        -string name
        -string description
        -decimal price
        -int duration_months
        -int max_adults
        -int max_children
        -boolean is_active
        +calculatePrice()
        +validateCapacity()
        +getDuration()
    }

    class Booking {
        -int id
        -int member_id
        -string booking_type
        -date booking_date
        -string session_time
        -int adult_count
        -int child_count
        -string status
        -decimal total_amount
        -string notes
        +createBooking()
        +cancelBooking()
        +checkIn()
        +checkOut()
        +calculateAmount()
    }

    class Session {
        -int id
        -string session_name
        -string session_time
        -int max_capacity
        -string session_type
        -boolean is_active
        +checkAvailability()
        +getCurrentCapacity()
        +isFull()
        +addBooking()
    }

    class Payment {
        -int id
        -int booking_id
        -string payment_method
        -decimal amount
        -string status
        -string transaction_id
        -timestamp payment_date
        +processPayment()
        +verifyPayment()
        +refundPayment()
        +generateReceipt()
    }

    class CafeMenu {
        -int id
        -string name
        -string description
        -decimal price
        -string category
        -string image_url
        -boolean is_available
        -boolean is_halal
        +isAvailable()
        +updatePrice()
        +checkStock()
        +disableMenu()
    }

    class CafeOrder {
        -int id
        -int member_id
        -string order_number
        -string status
        -decimal total_amount
        -timestamp order_date
        +placeOrder()
        +updateStatus()
        +calculateTotal()
        +addMenuItem()
        +removeMenuItem()
    }

    class CafeInventory {
        -int id
        -int menu_id
        -int current_stock
        -int minimum_stock
        -string unit
        -timestamp last_updated
        +updateStock()
        +checkLowStock()
        +getStockLevel()
        +addStock()
        +removeStock()
    }

    User ||--|| Member : has
    Member ||--o{ Booking : makes
    Member ||--o{ CafeOrder : places
    Package ||--o{ Member : subscribes
    Booking ||--|| Payment : has
    Booking ||--o{ Session : includes
    CafeOrder ||--o{ CafeMenu : contains
    CafeMenu ||--|| CafeInventory : tracks
```

### 2.2 Class Diagram Cafe System

```mermaid
classDiagram
    class CafeMenu {
        -int id
        -string name
        -string description
        -decimal price
        -string category
        -string image_url
        -boolean is_available
        -boolean is_halal
        +isAvailable()
        +updatePrice()
        +checkStock()
        +disableMenu()
    }

    class CafeOrder {
        -int id
        -int member_id
        -string order_number
        -string status
        -decimal total_amount
        -timestamp order_date
        +placeOrder()
        +updateStatus()
        +calculateTotal()
        +addMenuItem()
        +removeMenuItem()
        +confirmOrder()
        +cancelOrder()
    }

    class CafeOrderItem {
        -int id
        -int order_id
        -int menu_id
        -int quantity
        -decimal unit_price
        -decimal total_price
        -string notes
        +calculateTotal()
        +updateQuantity()
        +getSubtotal()
    }

    class CafeInventory {
        -int id
        -int menu_id
        -int current_stock
        -int minimum_stock
        -string unit
        -timestamp last_updated
        +updateStock()
        +checkLowStock()
        +getStockLevel()
        +addStock()
        +removeStock()
        +generateAlert()
    }

    class InventoryLog {
        -int id
        -int inventory_id
        -string action_type
        -int quantity_change
        -string reason
        -timestamp created_at
        +logTransaction()
        +getHistory()
        +generateReport()
    }

    class StockAlert {
        -int id
        -int inventory_id
        -string alert_type
        -string message
        -boolean is_resolved
        +createAlert()
        +resolveAlert()
        +sendNotification()
    }

    CafeMenu ||--o{ CafeOrderItem : contains
    CafeOrder ||--o{ CafeOrderItem : has
    CafeMenu ||--|| CafeInventory : tracks
    CafeInventory ||--o{ InventoryLog : logs
    CafeInventory ||--o{ StockAlert : generates
```

## 3. Sequence Diagram

### 3.1 Core Booking Flow Sequence

```mermaid
sequenceDiagram
    participant U as User
    participant W as Web App
    participant A as API Gateway
    participant B as Booking Service
    participant D as Database
    participant N as Notification Service

    Note over U: Guest/Member User
    Note over W: React/Next.js Frontend
    Note over A: Laravel API Gateway
    Note over B: Booking Service
    Note over D: MySQL Database
    Note over N: FCM Push Service

    U->>W: Access web application
    W->>U: Display landing page
    U->>W: Click "Reservasi" button
    W->>A: Request calendar page
    A->>B: Get current month availability
    B->>D: Query booking data
    D-->>B: Return availability data
    B-->>A: Return calendar data
    A-->>W: Return calendar response
    W->>U: Display calendar interface

    Note over U,W: Calendar Navigation
    U->>W: Navigate to next month
    W->>A: Request next month data
    A->>B: Get month availability
    B->>D: Query month bookings
    D-->>B: Return month data
    B-->>A: Return availability
    A-->>W: Return calendar data
    W->>U: Update calendar display

    Note over U,W: Date Selection
    U->>W: Click available date
    W->>A: Request session details
    A->>B: Get session availability
    B->>D: Query session capacity
    D-->>B: Return session data
    B-->>A: Return session details
    A-->>W: Return session info
    W->>U: Display session modal

    Note over U,W: Session Selection
    U->>W: Select morning/afternoon session
    W->>A: Request session booking
    A->>B: Validate session availability
    B->>D: Check capacity
    D-->>B: Return capacity status
    B-->>A: Return validation result
    A-->>W: Return session confirmation
    W->>U: Display registration form

    Note over U,W: User Registration
    U->>W: Fill registration form
    W->>A: Submit booking request
    A->>B: Process booking
    B->>D: Create booking record
    D-->>B: Return booking ID
    B->>N: Send confirmation notifications
    N-->>B: Confirm notifications sent
    B-->>A: Return booking confirmation
    A-->>W: Return booking details
    W->>U: Display confirmation page
```

### 3.2 Sequence Diagram Member Registration

```mermaid
sequenceDiagram
    participant M as Member
    participant S as Staff
    participant A as Admin
    participant P as Payment System
    participant N as Notification System

    M->>S: Request Registration
    S->>M: Provide Registration Form
    M->>S: Submit Form & Documents
    S->>A: Verify Documents
    A->>S: Document Verification Result
    S->>M: Request Payment
    M->>P: Make Payment
    P->>S: Payment Confirmation
    S->>A: Approve Registration
    A->>N: Activate Member Account
    N->>M: Send Welcome Email
    N->>M: Generate Member Card
    S->>M: Provide Member Card
```

### 3.2 Sequence Diagram Booking Process

```mermaid
sequenceDiagram
    participant M as Member
    participant B as Booking System
    participant S as Session System
    participant P as Payment System
    participant N as Notification System

    M->>B: Request Booking
    B->>S: Check Availability
    S->>B: Availability Status
    alt Available
        B->>M: Show Booking Form
        M->>B: Submit Booking Details
        B->>S: Reserve Slot
        S->>B: Confirmation
        B->>P: Process Payment
        P->>B: Payment Result
        alt Payment Success
            B->>M: Booking Confirmation
            B->>N: Send Confirmation Email
            N->>M: Booking Details
        else Payment Failed
            B->>M: Payment Failed
            S->>B: Release Slot
        end
    else Not Available
        B->>M: Slot Unavailable
        B->>M: Show Alternative Times
    end
```

### 3.3 Sequence Diagram Cafe Order

```mermaid
sequenceDiagram
    participant C as Customer
    participant O as Order System
    participant I as Inventory System
    participant K as Kitchen
    participant P as Payment System

    C->>O: Browse Menu
    O->>C: Show Available Menu
    C->>O: Select Items
    O->>I: Check Stock
    I->>O: Stock Availability
    alt Stock Available
        O->>C: Confirm Order
        C->>P: Make Payment
        P->>O: Payment Confirmation
        O->>I: Update Stock
        I->>O: Stock Updated
        O->>K: Send Order to Kitchen
        K->>O: Order Ready
        O->>C: Order Completed
    else Low Stock
        O->>C: Item Unavailable
        C->>O: Modify Order
    end
```

## 4. Activity Diagram

### 4.1 Activity Diagram Member Registration

```mermaid
graph TD
    A[Start Registration] --> B[Fill Registration Form]
    B --> C[Upload Documents]
    C --> D[Choose Package]
    D --> E[Submit Application]
    E --> F[Staff Verification]
    F --> G{Documents Valid?}
    G -->|No| H[Request Correction]
    H --> B
    G -->|Yes| I[Calculate Payment]
    I --> J[Payment Process]
    J --> K{Payment Success?}
    K -->|No| L[Payment Failed]
    L --> M[Retry Payment]
    M --> J
    K -->|Yes| N[Activate Account]
    N --> O[Generate Member Code]
    O --> P[Send Welcome Email]
    P --> Q[Create Member Card]
    Q --> R[Registration Complete]
```

### 4.2 Activity Diagram Booking Process

```mermaid
graph TD
    A[Start Booking] --> B[Select Date]
    B --> C[Choose Session Type]
    C --> D{Type?}
    D -->|Regular| E[Check Regular Availability]
    D -->|Private| F[Select Private Package]
    F --> G[Check Private Availability]
    E --> H{Slot Available?}
    G --> I{Slot Available?}
    H -->|No| J[Show Alternative]
    I -->|No| K[Show Alternative]
    H -->|Yes| L[Fill Booking Details]
    I -->|Yes| M[Fill Private Details]
    L --> N[Calculate Amount]
    M --> O[Calculate Private Amount]
    N --> P[Payment Process]
    O --> P
    P --> Q{Payment Success?}
    Q -->|No| R[Release Slot]
    R --> S[Booking Failed]
    Q -->|Yes| T[Confirm Booking]
    T --> U[Send Confirmation]
    U --> V[Booking Complete]
```

### 4.3 Activity Diagram Cafe Order

```mermaid
graph TD
    A[Start Order] --> B[Browse Menu]
    B --> C[Select Items]
    C --> D[Check Stock]
    D --> E{Stock Available?}
    E -->|No| F[Remove Item]
    F --> C
    E -->|Yes| G[Add to Cart]
    G --> H[Review Order]
    H --> I{Order Valid?}
    I -->|No| C
    I -->|Yes| J[Process Payment]
    J --> K{Payment Success?}
    K -->|No| L[Order Failed]
    K -->|Yes| M[Update Inventory]
    M --> N[Send to Kitchen]
    N --> O[Prepare Food]
    O --> P[Order Ready]
    P --> Q[Deliver Order]
    Q --> R[Order Complete]
```

## 5. State Diagram

### 5.1 State Diagram Booking Status

```mermaid
stateDiagram-v2
    [*] --> Pending
    Pending --> Confirmed : Payment Success
    Pending --> Cancelled : Customer Cancels
    Pending --> Failed : Payment Failed
    Confirmed --> CheckedIn : Customer Arrives
    Confirmed --> Cancelled : Customer Cancels
    Confirmed --> NoShow : Customer Doesn't Show
    CheckedIn --> Completed : Session Ends
    CheckedIn --> Cancelled : Emergency Cancellation
    Failed --> [*]
    Cancelled --> [*]
    NoShow --> [*]
    Completed --> [*]
```

### 5.2 State Diagram Cafe Order

```mermaid
stateDiagram-v2
    [*] --> Pending
    Pending --> Preparing : Payment Confirmed
    Pending --> Cancelled : Customer Cancels
    Pending --> Failed : Payment Failed
    Preparing --> Ready : Food Prepared
    Preparing --> Cancelled : Kitchen Cancels
    Ready --> Delivered : Customer Picks Up
    Ready --> Cancelled : Customer Doesn't Pick
    Failed --> [*]
    Cancelled --> [*]
    Delivered --> [*]
```

### 5.3 State Diagram Member Status

```mermaid
stateDiagram-v2
    [*] --> Active
    Active --> Expired : Membership Ends
    Active --> Suspended : Violation
    Active --> Cancelled : Member Cancels
    Expired --> Active : Renewal
    Expired --> Cancelled : No Renewal
    Suspended --> Active : Violation Resolved
    Suspended --> Cancelled : Member Cancels
    Cancelled --> [*]
```

## 6. Component Diagram

### 6.1 Component Diagram System Architecture

```mermaid
graph TB
    subgraph "Frontend Layer"
        A1[Web Application]
        A2[Mobile Application]
        A3[Admin Dashboard]
    end

    subgraph "API Gateway"
        B1[API Gateway]
    end

    subgraph "Service Layer"
        C1[Member Service]
        C2[Booking Service]
        C3[Payment Service]
        C4[Cafe Service]
        C5[Notification Service]
        C6[Reporting Service]
    end

    subgraph "Data Layer"
        D1[Member Database]
        D2[Booking Database]
        D3[Payment Database]
        D4[Cafe Database]
    end

    subgraph "External Services"
        E1[Payment Gateway]
        E2[Email Service]
        E3[SMS Service]
        E4[File Storage]
    end

    A1 --> B1
    A2 --> B1
    A3 --> B1

    B1 --> C1
    B1 --> C2
    B1 --> C3
    B1 --> C4
    B1 --> C5
    B1 --> C6

    C1 --> D1
    C2 --> D2
    C3 --> D3
    C4 --> D4
    C5 --> E2
    C5 --> E3
    C3 --> E1
    C1 --> E4
    C4 --> E4
```

---

**Versi**: 1.1  
**Tanggal**: 26 Agustus 2025  
**Status**: Updated berdasarkan PDF Raujan Pool Syariah
