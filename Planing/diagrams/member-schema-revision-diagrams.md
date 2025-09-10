# Member Schema Revision - Diagrams

## 📊 Database Schema Diagram

### **New Database Structure**

```mermaid
erDiagram
    USERS {
        int id PK
        string name
        string email
        string phone
        boolean is_active
        timestamp created_at
    }

    USER_PROFILES {
        int id PK
        int user_id FK
        string full_name
        date birth_date
        string address
        string emergency_contact
        timestamp created_at
    }

    MEMBERS {
        int id PK
        int user_id FK
        int user_profile_id FK
        string member_code
        enum status
        boolean is_active
        date membership_start
        date membership_end
        enum membership_type
        enum registration_method
        decimal registration_fee_paid
        decimal monthly_fee_paid
        decimal total_paid
        timestamp status_changed_at
        int status_changed_by FK
        text status_change_reason
        date grace_period_start
        date grace_period_end
        int grace_period_days
        int reactivation_count
        timestamp last_reactivation_date
        decimal last_reactivation_fee
        timestamp created_at
    }

    SYSTEM_CONFIGURATIONS {
        int id PK
        string config_key
        text config_value
        enum config_type
        text description
        boolean is_active
        int created_by FK
        timestamp created_at
    }

    MEMBER_STATUS_HISTORY {
        int id PK
        int member_id FK
        enum previous_status
        enum new_status
        text change_reason
        enum change_type
        int changed_by FK
        timestamp changed_at
        date membership_end_date
        date grace_period_end_date
        decimal payment_amount
        string payment_reference
    }

    MEMBER_PAYMENTS {
        int id PK
        int member_id FK
        enum payment_type
        decimal amount
        enum payment_method
        string payment_reference
        timestamp payment_date
        enum payment_status
        text description
        text notes
        int processed_by FK
        timestamp created_at
    }

    USERS ||--o{ MEMBERS : "has"
    USER_PROFILES ||--o{ MEMBERS : "belongs to"
    USERS ||--o{ SYSTEM_CONFIGURATIONS : "creates"
    USERS ||--o{ MEMBER_STATUS_HISTORY : "changes"
    USERS ||--o{ MEMBER_PAYMENTS : "processes"
    MEMBERS ||--o{ MEMBER_STATUS_HISTORY : "has history"
    MEMBERS ||--o{ MEMBER_PAYMENTS : "makes payments"
```

## 🔄 Member Lifecycle Flow

### **Member Status Lifecycle**

```mermaid
stateDiagram-v2
    [*] --> Registration
    Registration --> Active : Payment Complete

    Active --> Inactive : Membership Expired
    Inactive --> Active : Payment Before Grace Period
    Inactive --> NonMember : Grace Period Expired

    NonMember --> Active : Reactivation Payment

    Active --> [*] : Member Cancelled
    NonMember --> [*] : Permanent Deactivation

    note right of Active
        - Can use pool facilities
        - Full member benefits
        - Regular payment required
    end note

    note right of Inactive
        - Cannot use pool facilities
        - Grace period active
        - Can reactivate with payment
    end note

    note right of NonMember
        - Cannot use pool facilities
        - Requires reactivation fee
        - Must pay full registration again
    end note
```

## 💰 Payment Flow Diagram

### **Registration Payment Flow**

```mermaid
flowchart TD
    A[New Member Registration] --> B[Calculate Registration Fee]
    B --> C[Calculate Monthly/Quarterly Fee]
    C --> D{Membership Type?}
    D -->|Monthly| E[Total = Registration + Monthly Fee]
    D -->|Quarterly| F[Subtotal = Registration + Quarterly Fee]
    F --> G[Apply Quarterly Discount]
    G --> H[Total = Subtotal - Discount]
    E --> I[Payment Processing]
    H --> I
    I --> J{Payment Success?}
    J -->|Yes| K[Create Member Record]
    J -->|No| L[Payment Failed]
    K --> M[Status: Active]
    K --> N[Record Payment History]
    L --> O[Registration Failed]

    style A fill:#e1f5fe
    style M fill:#c8e6c9
    style O fill:#ffcdd2
    style G fill:#fff3e0
```

### **Reactivation Payment Flow**

```mermaid
flowchart TD
    A[Non-Member Reactivation] --> B[Calculate Reactivation Fee]
    B --> C[Calculate Monthly/Quarterly Fee]
    C --> D{Membership Type?}
    D -->|Monthly| E[Total = Reactivation + Monthly Fee]
    D -->|Quarterly| F[Subtotal = Reactivation + Quarterly Fee]
    F --> G[Apply Quarterly Discount]
    G --> H[Total = Subtotal - Discount]
    E --> I[Payment Processing]
    H --> I
    I --> J{Payment Success?}
    J -->|Yes| K[Update Member Record]
    J -->|No| L[Payment Failed]
    K --> M[Status: Active]
    K --> N[Increment Reactivation Count]
    K --> O[Record Payment History]
    L --> P[Reactivation Failed]

    style A fill:#fff3e0
    style M fill:#c8e6c9
    style P fill:#ffcdd2
    style G fill:#fff3e0
```

## ⚙️ System Configuration Flow

### **Configuration Management**

```mermaid
flowchart TD
    A[Admin Login] --> B[Access Configuration Panel]
    B --> C[View Current Member Configurations]
    C --> D{Want to Change?}
    D -->|Yes| E[Update Configuration]
    D -->|No| F[View Only]
    E --> G[Validate Configuration]
    G --> H{Valid?}
    H -->|Yes| I[Save Configuration]
    H -->|No| J[Show Error]
    I --> K[Clear Cache]
    K --> L[Configuration Updated]
    J --> E

    style A fill:#e3f2fd
    style L fill:#c8e6c9
    style J fill:#ffcdd2
```

## 📊 Member Status Distribution

### **Status Change Timeline**

```mermaid
gantt
    title Member Status Lifecycle Timeline
    dateFormat  YYYY-MM-DD
    section Active Period
    Membership Active    :active, 2025-01-01, 30d
    section Grace Period
    Grace Period        :grace, 2025-01-31, 90d
    section Non-Member
    Non-Member Status   :nonmember, 2025-05-01, 365d
    section Reactivation
    Reactivation        :reactivate, 2025-12-01, 1d
```

## 🔧 API Endpoint Flow

### **Member Registration API Flow**

```mermaid
sequenceDiagram
    participant C as Client
    participant API as API Controller
    participant S as MemberService
    participant DB as Database
    participant Config as SystemConfig

    C->>API: POST /api/v1/members/register
    API->>S: registerMember(data)
    S->>Config: getConfig('registration_fee')
    Config-->>S: 50000
    S->>Config: getConfig('monthly_fee')
    Config-->>S: 200000
    S->>DB: Create Member Record
    S->>DB: Create Payment Records
    S->>DB: Create Status History
    DB-->>S: Member Created
    S-->>API: Member Object
    API-->>C: 201 Created + Member Data
```

### **Member Reactivation API Flow**

```mermaid
sequenceDiagram
    participant C as Client
    participant API as API Controller
    participant S as MemberService
    participant DB as Database
    participant Config as SystemConfig

    C->>API: POST /api/v1/members/{id}/reactivate
    API->>S: reactivateMember(id, data)
    S->>DB: Find Member (status = non_member)
    DB-->>S: Member Found
    S->>Config: getConfig('reactivation_fee')
    Config-->>S: 50000
    S->>Config: getConfig('monthly_fee')
    Config-->>S: 200000
    S->>DB: Update Member Status
    S->>DB: Create Payment Records
    S->>DB: Create Status History
    DB-->>S: Member Updated
    S-->>API: Member Object
    API-->>C: 200 OK + Member Data
```

## 📈 Data Flow Diagram

### **Member Data Processing**

```mermaid
flowchart TD
    A[Member Data Input] --> B[Validation]
    B --> C{Valid?}
    C -->|No| D[Return Error]
    C -->|Yes| E[Process Payment]
    E --> F[Update Member Status]
    F --> G[Record Status History]
    G --> H[Create Payment Record]
    H --> I[Update Member Totals]
    I --> J[Send Notifications]
    J --> K[Return Success Response]

    style A fill:#e1f5fe
    style K fill:#c8e6c9
    style D fill:#ffcdd2
```

## 🎯 Business Rules Flow

### **Status Change Rules**

```mermaid
flowchart TD
    A[Member Status Check] --> B{Membership Expired?}
    B -->|No| C[Keep Active]
    B -->|Yes| D[Change to Inactive]
    D --> E[Set Grace Period]
    E --> F{Grace Period Expired?}
    F -->|No| G[Keep Inactive]
    F -->|Yes| H[Change to Non-Member]

    I[Payment Received] --> J{Member Status?}
    J -->|Active| K[Extend Membership]
    J -->|Inactive| L[Reactivate to Active]
    J -->|Non-Member| M[Reactivation Required]

    style C fill:#c8e6c9
    style G fill:#fff3e0
    style H fill:#ffcdd2
    style K fill:#c8e6c9
    style L fill:#c8e6c9
    style M fill:#ffcdd2
```

## 📊 Configuration Impact Diagram

### **Configuration Changes Impact**

```mermaid
flowchart TD
    A[Admin Changes Configuration] --> B[Clear Cache]
    B --> C[Update Database]
    C --> D[Affect New Registrations]
    C --> E[Affect New Reactivations]
    C --> F[Affect Grace Period Calculation]

    D --> G[New Registration Fee Applied]
    E --> H[New Reactivation Fee Applied]
    F --> I[New Grace Period Applied]

    style A fill:#e3f2fd
    style G fill:#c8e6c9
    style H fill:#c8e6c9
    style I fill:#c8e6c9
```

---

**Created**: January 15, 2025  
**Version**: 2.0  
**Status**: ✅ **COMPLETED**
