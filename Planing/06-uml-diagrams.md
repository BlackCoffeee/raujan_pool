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

        subgraph "Rating & Review System"
            UC29[Rate Services]
            UC30[Submit Reviews]
            UC31[Manage Rating System]
            UC32[View Rating Analytics]
            UC33[Configure Rating Components]
        end

        subgraph "Promotional System"
            UC34[Create Promotional Campaigns]
            UC35[Manage Campaign Templates]
            UC36[View Campaign Analytics]
            UC37[Configure Dynamic Pricing]
            UC38[Apply Promotional Pricing]
        end

        subgraph "Staff Management"
            UC39[Process Check-in]
            UC40[Manage Equipment]
            UC41[Track Attendance]
            UC42[Handle No-Shows]
            UC43[Manage Staff]
            UC44[Generate Reports]
        end

        subgraph "Dynamic Pricing System"
            UC45[Configure Dynamic Pricing]
            UC46[Update Pricing Configuration]
            UC47[View Pricing History]
            UC48[Manage Pricing Rules]
            UC49[Set Seasonal Pricing]
            UC50[Configure Member Discounts]
        end

        subgraph "Guest User Management"
            UC51[Register as Guest]
            UC52[Convert Guest to Member]
            UC53[Manage Guest Users]
            UC54[Guest User Analytics]
            UC55[Guest Conversion Tracking]
        end

        subgraph "Google SSO Integration"
            UC56[Login via Google SSO]
            UC57[Sign up via Google SSO]
            UC58[Sync Google Profile]
            UC59[Configure SSO Settings]
            UC60[Manage SSO Sessions]
        end

        subgraph "Booking Proof System"
            UC61[Generate QR Code]
            UC62[Generate Booking Reference]
            UC63[Send Email Confirmation]
            UC64[Send SMS Confirmation]
            UC65[Verify Booking Proof]
            UC66[Generate Digital Receipt]
            UC67[Manage Proof Templates]
        end

        subgraph "Notification System"
            UC68[Send Push Notifications]
            UC69[Configure Notifications]
            UC70[Manage Notification Templates]
            UC71[Schedule Notifications]
            UC72[Track Notification Delivery]
        end

        subgraph "Mobile Features"
            UC73[PWA Installation]
            UC74[Offline Support]
            UC75[Mobile-Optimized Interface]
            UC76[Touch Gestures]
            UC77[Mobile Payment Integration]
        end

        subgraph "Advanced Calendar"
            UC78[Forward-Only Navigation]
            UC79[Real-time Availability Display]
            UC80[Date Status Indicators]
            UC81[Capacity Management]
            UC82[Session Slot Management]
        end

        subgraph "Manual Payment System"
            UC83[Select Manual Payment]
            UC84[Upload Transfer Proof]
            UC85[Submit Payment Proof]
            UC86[View Payment Status]
            UC87[Verify Payment Proof]
            UC88[Confirm Payment]
            UC89[Reject Payment]
            UC90[Request Payment Correction]
            UC91[Generate Payment Instructions]
            UC92[Track Payment History]
        end

                        subgraph "Dynamic Member Quota Management"
                    UC93[Configure Member Quota]
                    UC94[Join Member Queue]
                    UC95[Monitor Queue Position]
                    UC96[Process Member Expiry]
                    UC97[Send Expiry Warnings]
                    UC98[Auto-Promote Queue]
                    UC99[Confirm Promotion Offer]
                    UC100[Update Quota Settings]
                    UC101[Track Quota History]
                    UC102[View Quota Dashboard]
                end

                subgraph "Member Daily Swimming Limit"
                    UC103[Check Daily Limit]
                    UC104[Book Free Session]
                    UC105[Book Additional Paid Session]
                    UC106[Apply Limit Override]
                    UC107[Track Daily Usage]
                    UC108[View Usage History]
                    UC109[Generate Usage Reports]
                    UC110[Monitor Limit Compliance]
                end

                subgraph "Private Pool Rental System"
                    UC111[Book Private Pool]
                    UC112[Check New Customer Status]
                    UC113[Apply Time Bonus]
                    UC114[Calculate Dynamic Pricing]
                    UC115[Manage Customer History]
                    UC116[Configure Pricing Rules]
                    UC117[Track Visit Counter]
                    UC118[Generate Analytics]
                    UC119[Process Payment]
                    UC120[Send Notifications]
                end

                subgraph "Cafe System with Barcode"
                    UC121[Scan Barcode/QR Code]
                    UC122[Browse Menu]
                    UC123[Add Item to Cart]
                    UC124[Add Special Notes]
                    UC125[Manage Cart]
                    UC126[Process Payment]
                    UC127[Verify Payment]
                    UC128[Prepare Food]
                    UC129[Deliver Order]
                    UC130[Confirm Reception]
                    UC131[Create Menu]
                    UC132[Update Menu]
                    UC133[Manage Stock]
                    UC134[View Menu Analytics]
                    UC135[Generate Menu Barcode]
                    UC136[Download Barcode]
                    UC137[Generate Financial Reports]
                    UC138[View Analytics Dashboard]
                end
    end

    A1 -.-> UC1
    A1 -.-> UC2
    A1 -.-> UC3
    A1 -.-> UC4
    A1 -.-> UC5
    A1 -.-> UC21
    A1 -.-> UC22
    A1 -.-> UC23
    A1 -.-> UC24
    A1 -.-> UC25
    A1 -.-> UC26
    A1 -.-> UC27
    A1 -.-> UC31
    A1 -.-> UC32
    A1 -.-> UC33
    A1 -.-> UC34
    A1 -.-> UC35
    A1 -.-> UC36
    A1 -.-> UC37
    A1 -.-> UC38
    A1 -.-> UC39
    A1 -.-> UC40
    A1 -.-> UC41
    A1 -.-> UC42
    A1 -.-> UC43
    A1 -.-> UC44
    A1 -.-> UC45
    A1 -.-> UC46
    A1 -.-> UC47
    A1 -.-> UC48
    A1 -.-> UC49
    A1 -.-> UC50
    A1 -.-> UC51
    A1 -.-> UC52
    A1 -.-> UC53
    A1 -.-> UC54
    A1 -.-> UC55
    A1 -.-> UC56
    A1 -.-> UC57
    A1 -.-> UC58
    A1 -.-> UC59
    A1 -.-> UC60
    A1 -.-> UC61
    A1 -.-> UC62
    A1 -.-> UC63
    A1 -.-> UC64
    A1 -.-> UC65
    A1 -.-> UC66
    A1 -.-> UC67
    A1 -.-> UC68
    A1 -.-> UC69
    A1 -.-> UC70
    A1 -.-> UC71
    A1 -.-> UC72
    A1 -.-> UC73
    A1 -.-> UC74
    A1 -.-> UC75
    A1 -.-> UC76
    A1 -.-> UC77
    A1 -.-> UC78
    A1 -.-> UC79
    A1 -.-> UC80
    A1 -.-> UC81
    A1 -.-> UC82
    A1 -.-> UC83
    A1 -.-> UC84
    A1 -.-> UC85
    A1 -.-> UC86
    A1 -.-> UC87
    A1 -.-> UC88
    A1 -.-> UC89
    A1 -.-> UC90
    A1 -.-> UC91
    A1 -.-> UC92
    A1 -.-> UC93
    A1 -.-> UC96
    A1 -.-> UC97
    A1 -.-> UC98
                A1 -.-> UC100
            A1 -.> UC101
            A1 -.-> UC102
            A1 -.-> UC106
            A1 -.-> UC107
            A1 -.-> UC109
            A1 -.-> UC110
            A1 -.-> UC116
            A1 -.-> UC118
            A1 -.-> UC115

            A2 -.-> UC1
    A2 -.-> UC2
    A2 -.-> UC9
    A2 -.-> UC11
    A2 -.-> UC12
    A2 -.-> UC13
    A2 -.-> UC14
    A2 -.-> UC15
    A2 -.-> UC39
    A2 -.-> UC40
    A2 -.-> UC41
    A2 -.-> UC42
    A2 -.-> UC87
    A2 -.-> UC88
    A2 -.-> UC89
                A2 -.-> UC90
            A2 -.-> UC93
            A2 -.-> UC96
            A2 -.-> UC97
            A2 -.> UC98
            A2 -.-> UC100
            A2 -.-> UC101
            A2 -.-> UC102
            A2 -.-> UC106
            A2 -.-> UC107
            A2 -.-> UC110
            A2 -.-> UC111
            A2 -.-> UC112
            A2 -.-> UC115
            A2 -.-> UC119

            A3 -.-> UC26
    A3 -.-> UC27
    A3 -.-> UC28
    A3 -.-> UC40

    A4 -.-> UC2
    A4 -.-> UC4
    A4 -.-> UC6
    A4 -.-> UC7
    A4 -.-> UC8
    A4 -.-> UC10
    A4 -.-> UC11
    A4 -.-> UC12
    A4 -.-> UC13
    A4 -.-> UC14
    A4 -.-> UC18
    A4 -.-> UC19
    A4 -.-> UC24
    A4 -.-> UC25
    A4 -.-> UC29
    A4 -.-> UC30
    A4 -.-> UC38
    A4 -.-> UC5
    A4 -.-> UC94
    A4 -.-> UC95
                A4 -.-> UC99
            A4 -.-> UC103
            A4 -.-> UC104
            A4 -.-> UC105
            A4 -.-> UC108
            A4 -.> UC111
            A4 -.-> UC112
            A4 -.-> UC113
            A4 -.-> UC114
            A4 -.-> UC115
            A4 -.-> UC117
            A4 -.-> UC119

            A5 -.-> UC6
    A5 -.-> UC8
    A5 -.-> UC10
    A5 -.-> UC11
    A5 -.-> UC13
    A5 -.-> UC14
    A5 -.-> UC18
    A5 -.-> UC19
    A5 -.-> UC24
    A5 -.-> UC25
    A5 -.-> UC29
    A5 -.-> UC30
    A5 -.-> UC38
    A5 -.-> UC83
    A5 -.-> UC84
    A5 -.-> UC85
    A5 -.-> UC86
    A5 -.-> UC94
                A5 -.-> UC95
            A5 -.-> UC99
            A5 -.-> UC111
            A5 -.-> UC112
            A5 -.-> UC113
            A5 -.-> UC114
            A5 -.-> UC119

            A1 -.-> UC127
            A1 -.-> UC128
            A1 -.-> UC129
            A1 -.-> UC130

            A3 -.-> UC127
            A3 -.-> UC128
            A3 -.-> UC129
            A3 -.-> UC130

            A4 -.-> UC121
            A4 -.-> UC122
            A4 -.-> UC123
            A4 -.-> UC124
            A4 -.-> UC125
            A4 -.-> UC126
            A4 -.-> UC130

            A5 -.-> UC121
            A5 -.-> UC122
            A5 -.-> UC123
            A5 -.-> UC124
            A5 -.-> UC125
            A5 -.-> UC126
            A5 -.-> UC130

            A1 -.-> UC131
            A1 -.-> UC132
            A1 -.-> UC133
            A1 -.-> UC134
            A1 -.-> UC135
            A1 -.-> UC136
            A1 -.-> UC137
            A1 -.-> UC138

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

    A1 -.-> UC1
    A1 -.-> UC8
    A1 -.-> UC9
    A1 -.-> UC10
    A1 -.-> UC11
    A1 -.-> UC12
    A1 -.-> UC13
    A1 -.-> UC14
    A1 -.-> UC15
    A1 -.-> UC16
    A1 -.-> UC17
    A1 -.-> UC18

    A2 -.-> UC2
    A2 -.-> UC3
    A2 -.-> UC5
    A2 -.-> UC6
    A2 -.-> UC7

    A3 -.-> UC4
    A3 -.-> UC5
    A3 -.-> UC6

    %% Custom styling untuk lines dengan warna berbeda
    linkStyle 0,1,2,3,4,5,6,7,8,9,10,11 stroke:#45b7d1,stroke-width:3px
    linkStyle 12,13,14,15,16 stroke:#ff6b6b,stroke-width:3px
    linkStyle 17,18,19 stroke:#4ecdc4,stroke-width:3px
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

    %% Custom styling untuk relationship lines
    linkStyle 0,1 stroke:#ff6b6b,stroke-width:2px
    linkStyle 2,3 stroke:#45b7d1,stroke-width:2px
    linkStyle 4 stroke:#ffeaa7,stroke-width:2px
    linkStyle 5,6 stroke:#4ecdc4,stroke-width:2px
    linkStyle 7 stroke:#96ceb4,stroke-width:2px
    linkStyle 8 stroke:#ff7675,stroke-width:2px
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

### 2.4 Rating System Sequence Diagram

```mermaid
sequenceDiagram
    participant U as User
    participant W as Web App
    participant A as API Gateway
    participant B as Rating Service
    participant D as Database
    participant N as Notification Service

    Note over U: User completes service
    Note over W: React/Next.js Frontend
    Note over A: Laravel API Gateway
    Note over B: Rating Service
    Note over D: MySQL Database
    Note over N: FCM Push Service

    U->>W: Complete booking/session
    W->>A: Trigger rating request
    A->>B: Get user rating form
    B->>D: Fetch user history
    D-->>B: User history data
    B-->>A: Rating form components
    A-->>W: Display rating interface
    W-->>U: Show rating form

    U->>W: Rate different aspects
    W->>A: Submit ratings
    A->>B: Process rating submission
    B->>D: Store rating data
    B->>D: Update rating analytics
    B->>N: Send feedback notification
    N-->>U: Push notification
    B-->>A: Rating confirmation
    A-->>W: Success message
    W-->>U: Rating submitted

    Note over B: Rating Components
    Note over B: Booking Experience
    Note over B: Cafe Service
    Note over B: Staff Service
    Note over B: Facility Quality
    Note over B: Overall Satisfaction
```

### 2.5 Promotional Pricing Sequence Diagram

```mermaid
sequenceDiagram
    participant U as User
    participant W as Web App
    participant A as API Gateway
    participant P as Pricing Service
    participant C as Campaign Service
    participant D as Database
    participant N as Notification Service

    Note over U: User makes booking
    Note over W: React/Next.js Frontend
    Note over A: Laravel API Gateway
    Note over P: Pricing Service
    Note over C: Campaign Service
    Note over D: MySQL Database
    Note over N: FCM Push Service

    U->>W: Select booking options
    W->>A: Request booking pricing
    A->>P: Calculate base price
    P->>D: Get pricing config
    D-->>P: Current pricing data
    P-->>A: Base price calculated
    A->>C: Check active promotions
    C->>D: Get eligible campaigns
    D-->>C: Campaign data
    C->>C: Evaluate user eligibility
    C->>C: Select best promotion
    C-->>A: Promotion applied
    A->>P: Apply promotional pricing
    P->>D: Store promotion usage
    P-->>A: Final promotional price
    A-->>W: Display pricing options
    W-->>U: Show promotional pricing

    Note over C: Promotion Types
    Note over C: Percentage Discount
    Note over C: Fixed Amount
    Note over C: Free Additional Person
    Note over C: Package Deals
    Note over C: Loyalty Rewards

    U->>W: Confirm booking with promo
    W->>A: Complete promotional booking
    A->>P: Finalize pricing
    A->>N: Send promotion confirmation
    N-->>U: Promotional receipt
    A-->>W: Booking confirmation
    W-->>U: Promotional booking complete
```

### 2.6 Check-in Process Sequence Diagram

```mermaid
sequenceDiagram
    participant G as Guest/Member
    participant S as Staff
    participant W as Web App
    participant A as API Gateway
    participant C as Check-in Service
    participant D as Database
    participant E as Equipment Service
    participant N as Notification Service

    Note over G: Guest/Member arrives
    Note over S: Staff at front desk
    Note over W: React/Next.js Frontend
    Note over A: Laravel API Gateway
    Note over C: Check-in Service
    Note over D: MySQL Database
    Note over E: Equipment Management
    Note over N: FCM Push Service

    G->>S: Arrive at reception
    S->>W: Access check-in interface
    W->>A: Get today's bookings
    A->>C: Fetch booking data
    C->>D: Query bookings
    D-->>C: Booking information
    C-->>A: Today's bookings list
    A-->>W: Display bookings
    W-->>S: Show check-in screen

    S->>G: Request identification
    G->>S: Provide QR/Reference/ID
    S->>W: Input verification method
    W->>A: Verify booking
    A->>C: Validate booking details
    C->>D: Check booking status
    D-->>C: Booking validation result
    C-->>A: Booking verified
    A-->>W: Confirmation
    W-->>S: Booking confirmed

    S->>W: Process check-in
    W->>A: Record attendance
    A->>C: Create attendance record
    C->>D: Store attendance data
    A->>E: Issue equipment
    E->>D: Update equipment inventory
    A->>N: Send check-in confirmation
    N-->>G: Check-in receipt
    A-->>W: Check-in complete
    W-->>S: Success message
    S->>G: Guide to facilities

    Note over C: Verification Methods
    Note over C: QR Code Scan
    Note over C: Reference Number
    Note over C: Phone/Email Search
    Note over C: Member Card
    Note over C: Manual Entry
```

### 2.7 Dynamic Member Quota Management Sequence Diagram

```mermaid
sequenceDiagram
    participant U as User
    participant W as Web App
    participant A as API Gateway
    participant Q as Quota Service
    participant N as Notification Service
    participant D as Database

    Note over U: User wants to become member
    Note over W: React/Next.js Frontend
    Note over A: Laravel API Gateway
    Note over Q: Quota Management Service
    Note over N: FCM Push Service
    Note over D: MySQL Database

    U->>W: Request member registration
    W->>A: Check quota availability
    A->>Q: Get current quota status
    Q->>D: Fetch quota configuration
    D-->>Q: Current quota data
    Q-->>A: Quota status (full/available)
    A-->>W: Quota status response

    alt Quota Available
        W-->>U: Proceed with registration
    else Quota Full
        W-->>U: Offer to join queue
        U->>W: Accept queue invitation
        W->>A: Join member queue
        A->>Q: Add to queue
        Q->>D: Insert queue record
        A->>N: Send queue confirmation
        N-->>U: Queue position notification
        A-->>W: Queue position details
        W-->>U: Queue position confirmed
    end

    Note over Q: Member Expiry Processing (Daily Job)
    Note over Q: Check for expired members
    Q->>D: Get members expiring in 3 days
    D-->>Q: List of expiring members
    Q->>N: Send warning notifications
    N-->>U: Expiry warning (3 days before)

    Note over Q: Grace Period Processing
    Note over Q: Check members in grace period
    Q->>D: Get members past expiry date
    D-->>Q: Members in grace period
    Q->>D: Deactivate members (3 days after expiry)
    Q->>Q: Trigger queue promotion
    Q->>D: Get first in queue
    D-->>Q: Queue member details
    Q->>N: Send promotion offer
    N-->>U: Promotion offer notification

    Note over U: User receives promotion offer
    U->>W: Respond to promotion
    W->>A: Confirm/decline promotion
    A->>Q: Process promotion response
    Q->>D: Update member status

    alt User Accepts
        Q->>D: Activate member
        A->>N: Send activation confirmation
        N-->>U: Member activation success
    else User Declines
        Q->>Q: Promote next in queue
        Q->>N: Send next promotion offer
        N-->>U: Next user gets promotion offer
    end

    Note over Q: Admin Quota Management
    Note over Q: Admin updates quota settings
    A->>Q: Update quota configuration
    Q->>D: Update quota limits
    Q->>Q: Check for available promotions
    Q->>N: Send quota change notifications
    N-->>U: Quota change notification
```

### 2.8 Member Daily Swimming Limit Sequence Diagram

```mermaid
sequenceDiagram
    participant M as Member
    participant W as Web App
    participant A as API Gateway
    participant L as Limit Service
    participant B as Booking Service
    participant P as Payment Service
    participant D as Database

    Note over M: Member wants to book session
    Note over W: React/Next.js Frontend
    Note over A: Laravel API Gateway
    Note over L: Daily Limit Service
    Note over B: Booking Management Service
    Note over P: Payment Processing Service
    Note over D: MySQL Database

    M->>W: Request to book session
    W->>A: Check daily limit for member
    A->>L: Get member daily usage
    L->>D: Fetch daily usage record
    D-->>L: Daily usage data
    L-->>A: Daily limit status
    A-->>W: Can book free session?

    alt Can Book Free Session
        W-->>M: Free session available
        M->>W: Confirm free booking
        W->>A: Create free session booking
        A->>B: Process free booking
        B->>D: Insert booking record
        A->>L: Update daily usage
        L->>D: Update free sessions used
        A-->>W: Booking confirmed (free)
        W-->>M: Free session booked successfully
    else Daily Limit Reached
        W-->>M: Daily limit reached, additional session requires payment
        M->>W: Confirm paid booking
        W->>A: Create paid session booking
        A->>B: Process paid booking
        A->>P: Calculate additional session price
        P->>D: Get pricing configuration
        P-->>A: Additional session price
        A-->>W: Payment required for additional session
        W-->>M: Payment form displayed

        alt Member Completes Payment
            M->>W: Complete payment
            W->>A: Process payment
            A->>P: Process manual payment
            P->>D: Update payment record
            A->>L: Update daily usage
            L->>D: Update paid sessions used
            A-->>W: Payment confirmed, booking created
            W-->>M: Additional session booked successfully
        end
    end

    Note over L: Daily Limit Reset (Midnight)
    Note over L: Reset all member daily usage
    L->>D: Reset daily usage counters
    L->>D: Archive daily usage history

    Note over A: Admin Override System
    Note over A: Admin applies limit override
    A->>L: Apply member limit override
    L->>D: Insert override record
    L->>D: Update daily usage with override
    A->>L: Send override notification
    L-->>M: Override applied notification
```

### 2.9 Private Pool Rental System Sequence Diagram

````mermaid
sequenceDiagram
    participant C as Customer
    participant W as Web App
    participant A as API Gateway
    participant P as Private Pool Service
    participant H as Customer History Service
    participant R as Pricing Service
    participant D as Database

    Note over C: Customer wants to book private pool
    Note over W: React/Next.js Frontend
    Note over A: Laravel API Gateway
    Note over P: Private Pool Management Service
    Note over H: Customer History Service
    Note over R: Dynamic Pricing Service
    Note over D: MySQL Database

    C->>W: Access private pool booking
    W->>A: Get pool availability
    A->>P: Check pool availability
    P->>D: Fetch availability calendar
    D-->>P: Available time slots
    P-->>A: Pool availability data
    A-->>W: Available slots displayed
    W-->>C: Select date and time

    C->>W: Enter customer information
    W->>A: Submit customer details
    A->>H: Check customer history
    H->>D: Query customer visit history
    D-->>H: Customer history data
    H-->>A: Customer classification (new/returning)

    alt New Customer
        A->>R: Calculate price with bonus
        R->>D: Get pricing configuration
        D-->>R: Pricing config (1h 30min + 30min bonus)
        R->>A: Price calculation (base price only)
        A-->>W: Price with 30min bonus time
        W-->>C: Display price: Base Price (1h 33min total)
    else Returning Customer
        A->>R: Calculate price with additional charge
        R->>D: Get visit count and pricing
        D-->>R: Visit count and pricing config
        R->>A: Price calculation (base + additional charge)
        A-->>W: Price with additional charge
        W-->>C: Display price: Base Price + Additional Charge
    end

    C->>W: Confirm booking
    W->>A: Process private pool booking
    A->>P: Create booking record
    P->>D: Insert private pool booking
    A->>H: Update customer history
    H->>D: Update visit counter and spending
    A->>R: Generate receipt
    R-->>A: Receipt with price breakdown
    A-->>W: Booking confirmation with receipt
    W-->>C: Booking confirmed

    Note over A: Admin Pricing Management
    Note over A: Admin updates pricing configuration
    A->>R: Update pricing rules
    R->>D: Update pricing configuration
    A->>R: Apply new pricing to future bookings
    R-->>A: New pricing applied
    A->>H: Send pricing update notifications
    H-->>C: Pricing change notification

    Note over P: Timer Management
    Note over P: Track ongoing pool usage
    P->>D: Start timer for booking
    P->>D: Monitor duration (1h 30min or 2 hours)
    P->>H: Update usage statistics
    H->>D: Update analytics data
                P-->>C: Time remaining notification
            P-->>C: Session completion notification
        ```

        ### 2.7 Cafe System with Barcode Sequence Diagram

        ```mermaid
        sequenceDiagram
            participant C as Customer
            participant B as Barcode Scanner
            participant M as Menu System
            participant A as API Gateway
            participant K as Kitchen System
            participant P as Payment System
            participant N as Notification Service

            Note over C: Customer at pool area
            Note over B: QR Code/Barcode Scanner
            Note over M: React/Next.js Menu Interface
            Note over A: Laravel API Gateway
            Note over K: Kitchen Management System
            Note over P: Manual Payment System
            Note over N: FCM Push Service

            C->>B: Scan barcode/QR code
            B->>M: Redirect to menu page
            M->>A: Get menu for location
            A->>M: Return menu with availability
            M-->>C: Display menu with availability

            C->>M: Browse menu items
            M->>A: Check item availability
            A-->>M: Item availability status
            M-->>C: Show available/unavailable items

            C->>M: Add item to cart
            M->>A: Add item to cart session
            C->>M: Add special notes
            M->>A: Store notes with item
            C->>M: Set quantity
            M->>A: Update cart

            C->>M: Continue shopping
            M-->>C: Updated cart display

            C->>M: Review cart
            M-->>C: Cart summary with total
            C->>M: Proceed to payment
            M->>P: Create payment request
            P-->>M: Payment instructions
            M-->>C: Payment upload interface

            C->>M: Upload payment proof
            M->>A: Submit order with payment proof
            A->>K: Create kitchen order
            A->>N: Send order notification
            N-->>C: Order confirmation notification

            Note over A: Admin Payment Verification
            Note over A: Admin reviews payment proof
            A->>P: Verify payment
            P-->>A: Payment verification result
            A->>K: Confirm payment to kitchen
            K-->>A: Order preparation started

            Note over K: Kitchen Preparation
            K->>K: Prepare food items
            K->>A: Update order status: preparing
            A->>N: Send preparation notification
            N-->>C: Food preparation started

            K->>A: Update order status: ready
            A->>N: Send ready notification
            N-->>C: Food ready notification

            Note over A: Delivery Process
            A->>A: Assign delivery staff
            A->>N: Send delivery notification
            N-->>C: Delivery in progress

            Note over C: Customer Receives Food
            C->>M: Confirm food reception
            M->>A: Update order status: delivered
            A->>N: Send delivery confirmation
            N-->>C: Order completed notification

            Note over A: Order Completion
            A->>A: Mark order as completed
            A->>A: Update inventory
            A->>A: Generate receipt
            A->>N: Send completion notification
            N-->>C: Thank you notification
        ```

### 2.3 Core Booking Flow Sequence Diagram

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

    %% Custom styling untuk activity nodes
    classDef start-end fill:#ff6b6b,stroke:#333,stroke-width:2px,color:#fff
    classDef process fill:#4ecdc4,stroke:#333,stroke-width:2px,color:#fff
    classDef decision fill:#ffeaa7,stroke:#333,stroke-width:2px,color:#000
    classDef success fill:#96ceb4,stroke:#333,stroke-width:2px,color:#fff
    classDef failure fill:#ff7675,stroke:#333,stroke-width:2px,color:#fff

    A:::start-end
    B:::process
    C:::process
    D:::process
    E:::process
    F:::process
    G:::decision
    H:::failure
    I:::process
    J:::process
    K:::decision
    L:::failure
    M:::process
    N:::success
    O:::success
    P:::success
    Q:::success
    R:::start-end
````

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

**Versi**: 1.3  
**Tanggal**: 26 Agustus 2025  
**Status**: Complete dengan Dynamic Pricing, Guest Booking, Google SSO, Mobile-First Web App, Core Booking Flow, Manual Payment, Dynamic Member Quota & Member Daily Swimming Limit  
**Berdasarkan**: PDF Raujan Pool Syariah
