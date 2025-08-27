# Desain Database (ERD) - Sistem Kolam Renang Syariah

## 1. Entity Relationship Diagram (ERD)

### 1.1 ERD Utama dengan Dynamic Pricing, Guest Users, dan SSO

```mermaid
erDiagram
    USERS ||--o{ USER_PROFILES : has
    USERS ||--o{ SSO_SESSIONS : has
    USER_PROFILES ||--o{ MEMBERS : creates
    USER_PROFILES ||--o{ GUEST_USERS : creates
    MEMBERS ||--o{ BOOKINGS : makes
    GUEST_USERS ||--o{ BOOKINGS : makes
    BOOKINGS ||--o{ BOOKING_PROOFS : generates
    BOOKINGS ||--o{ PAYMENTS : has
    CAFE_ORDERS ||--o{ PAYMENTS : has
    CAFE_MENU ||--o{ CAFE_ORDERS : contains
    CAFE_INVENTORY ||--o{ CAFE_MENU : tracks

    %% Pricing Configuration Tables
    PRICING_CONFIG ||--o{ BOOKINGS : used_in
    PRICING_RULES ||--o{ PRICING_CONFIG : applies_to
    PRICING_HISTORY ||--o{ PRICING_CONFIG : tracks

    %% Authentication & Verification
    VERIFICATION_ATTEMPTS ||--o{ BOOKING_PROOFS : tracks
    AUTHENTICATION_LOGS ||--o{ USERS : logs

    %% Calendar & Availability Management
    CALENDAR_AVAILABILITY ||--o{ DAILY_CAPACITY : manages
    DAILY_CAPACITY ||--o{ SESSION_SLOTS : contains
    SESSION_SLOTS ||--o{ BOOKINGS : reserves
    NOTIFICATIONS ||--o{ NOTIFICATION_LOGS : tracks
    NOTIFICATIONS }o--|| USERS : sent_to
    NOTIFICATIONS }o--|| BOOKINGS : related_to

    USERS {
        int id PK
        string username
        string email
        string password_hash
        string auth_provider
        string auth_provider_id
        boolean is_email_verified
        boolean is_active
        string role
        timestamp last_login_at
        int login_count
        timestamp created_at
        timestamp updated_at
    }

    USER_PROFILES {
        int id PK
        int user_id FK
        string full_name
        string phone
        string avatar_url
        date date_of_birth
        string gender
        string address
        string city
        string postal_code
        string emergency_contact
        string profile_source
        string google_profile_id
        timestamp last_profile_sync
        timestamp created_at
        timestamp updated_at
    }

    MEMBERS {
        int id PK
        int user_id FK
        int user_profile_id FK
        string member_code
        boolean is_active
        date membership_start
        date membership_end
        string membership_type
        int pricing_package_id FK
        string registration_method
        int converted_from_guest_id FK
        timestamp created_at
        timestamp updated_at
    }

    GUEST_USERS {
        int id PK
        int user_profile_id FK
        string full_name
        string phone
        string email
        string emergency_contact
        int total_visits
        date last_visit_date
        boolean is_converted_to_member
        int converted_user_id FK
        string conversion_method
        timestamp conversion_date
        timestamp created_at
        timestamp updated_at
    }

    BOOKINGS {
        int id PK
        int member_id FK
        int guest_user_id FK
        string booking_type
        string booking_reference
        date booking_date
        string session_time
        int adult_count
        int child_count
        string status
        decimal base_amount
        decimal discount_amount
        decimal final_amount
        int pricing_config_id FK
        boolean is_checkin
        timestamp checkin_time
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
        boolean is_halal
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

    %% Dynamic Pricing Tables
    PRICING_CONFIG {
        int id PK
        string config_name
        string category
        string service_type
        decimal base_price
        decimal current_price
        json pricing_rules
        date effective_date
        date expiry_date
        boolean is_active
        int created_by FK
        timestamp created_at
        timestamp updated_at
    }

    PRICING_RULES {
        int id PK
        string rule_name
        string rule_type
        json rule_conditions
        json rule_actions
        int priority
        boolean is_active
        timestamp created_at
        timestamp updated_at
    }

    PRICING_HISTORY {
        int id PK
        int config_id FK
        decimal old_price
        decimal new_price
        string change_reason
        int changed_by FK
        timestamp changed_at
    }

    %% SSO Tables
    SSO_SESSIONS {
        int id PK
        int user_id FK
        string provider
        text access_token
        text refresh_token
        string token_type
        timestamp expires_at
        text scope
        boolean is_active
        timestamp created_at
        timestamp updated_at
    }

    AUTHENTICATION_LOGS {
        int id PK
        int user_id FK
        string auth_method
        string action
        string ip_address
        text user_agent
        boolean success
        string error_message
        timestamp created_at
    }

    %% Guest Proof System Tables
    BOOKING_PROOFS {
        int id PK
        int booking_id FK
        string proof_type
        string reference_number
        string qr_code_hash
        string qr_code_image_url
        string receipt_url
        boolean is_verified
        timestamp verification_time
        int verified_by FK
        timestamp created_at
        timestamp updated_at
    }

    VERIFICATION_ATTEMPTS {
        int id PK
        int booking_id FK
        string attempt_method
        string ip_address
        text user_agent
        boolean success
        timestamp created_at
    }
```

### 1.2 Cafe System ERD

```mermaid
erDiagram
    CAFE_MENU ||--o{ CAFE_ORDER_ITEMS : contains
    CAFE_ORDERS ||--o{ CAFE_ORDER_ITEMS : has
    CAFE_MENU ||--|| CAFE_INVENTORY : tracks
    CAFE_INVENTORY ||--o{ CAFE_INVENTORY_LOG : logs

    CAFE_MENU {
        int id PK
        string name
        string description
        decimal price
        string category
        string image_url
        boolean is_available
        boolean is_halal
        timestamp created_at
        timestamp updated_at
    }

    CAFE_ORDERS {
        int id PK
        int member_id FK
        string order_number
        string status
        decimal total_amount
        timestamp order_date
        timestamp created_at
        timestamp updated_at
    }

    CAFE_ORDER_ITEMS {
        int id PK
        int order_id FK
        int menu_id FK
        int quantity
        decimal unit_price
        decimal total_price
        string notes
        timestamp created_at
    }

    CAFE_INVENTORY {
        int id PK
        int menu_id FK
        int current_stock
        int minimum_stock
        string unit
        timestamp last_updated
        timestamp created_at
    }

    CAFE_INVENTORY_LOG {
        int id PK
        int inventory_id FK
        string action_type
        int quantity_change
        string reason
        timestamp created_at
    }

    NOTIFICATIONS {
        int id PK
        string notification_type
        int user_id FK
        string title
        string message
        string status
        timestamp created_at
        timestamp read_at
    }
```

## 2. Database Schema Detail

### 2.1 Dynamic Pricing Tables

#### 2.1.1 Calendar Availability Table

```sql
CREATE TABLE calendar_availability (
    id INT PRIMARY KEY AUTO_INCREMENT,
    date DATE NOT NULL,
    is_operational BOOLEAN DEFAULT TRUE,
    max_daily_capacity INT DEFAULT 20,
    morning_session_capacity INT DEFAULT 10,
    afternoon_session_capacity INT DEFAULT 10,
    special_rules TEXT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    UNIQUE KEY unique_date (date),
    INDEX idx_date (date),
    INDEX idx_operational (is_operational)
);
```

#### 2.1.2 Daily Capacity Table

```sql
CREATE TABLE daily_capacity (
    id INT PRIMARY KEY AUTO_INCREMENT,
    calendar_availability_id INT NOT NULL,
    date DATE NOT NULL,
    morning_adults_booked INT DEFAULT 0,
    morning_children_booked INT DEFAULT 0,
    afternoon_adults_booked INT DEFAULT 0,
    afternoon_children_booked INT DEFAULT 0,
    total_bookings INT DEFAULT 0,
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    FOREIGN KEY (calendar_availability_id) REFERENCES calendar_availability(id) ON DELETE CASCADE,
    UNIQUE KEY unique_date_capacity (date),
    INDEX idx_date (date),
    INDEX idx_calendar_availability (calendar_availability_id)
);
```

#### 2.1.3 Session Slots Table

```sql
CREATE TABLE session_slots (
    id INT PRIMARY KEY AUTO_INCREMENT,
    daily_capacity_id INT NOT NULL,
    session_type ENUM('morning', 'afternoon') NOT NULL,
    max_adults INT DEFAULT 10,
    max_children INT DEFAULT 10,
    current_adults INT DEFAULT 0,
    current_children INT DEFAULT 0,
    is_available BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    FOREIGN KEY (daily_capacity_id) REFERENCES daily_capacity(id) ON DELETE CASCADE,
    UNIQUE KEY unique_daily_session (daily_capacity_id, session_type),
    INDEX idx_daily_capacity (daily_capacity_id),
    INDEX idx_session_type (session_type),
    INDEX idx_availability (is_available)
);
```

#### 2.1.4 Notifications Table

```sql
CREATE TABLE notifications (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NULL,
    booking_id INT NULL,
    notification_type ENUM('booking_confirmation', 'booking_reminder', 'booking_cancelled', 'session_full', 'promotional') NOT NULL,
    title VARCHAR(255) NOT NULL,
    message TEXT NOT NULL,
    channel ENUM('email', 'sms', 'push', 'in_app') NOT NULL,
    status ENUM('pending', 'sent', 'delivered', 'failed') DEFAULT 'pending',
    scheduled_at TIMESTAMP NULL,
    sent_at TIMESTAMP NULL,
    delivery_attempts INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (booking_id) REFERENCES bookings(id) ON DELETE CASCADE,
    INDEX idx_user_id (user_id),
    INDEX idx_booking_id (booking_id),
    INDEX idx_notification_type (notification_type),
    INDEX idx_status (status),
    INDEX idx_scheduled_at (scheduled_at)
);
```

#### 2.1.5 Notification Logs Table

```sql
CREATE TABLE notification_logs (
    id INT PRIMARY KEY AUTO_INCREMENT,
    notification_id INT NOT NULL,
    channel ENUM('email', 'sms', 'push', 'in_app') NOT NULL,
    status ENUM('sent', 'delivered', 'failed', 'bounced') NOT NULL,
    response_data JSON NULL,
    error_message TEXT NULL,
    sent_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (notification_id) REFERENCES notifications(id) ON DELETE CASCADE,
    INDEX idx_notification_id (notification_id),
    INDEX idx_status (status),
    INDEX idx_sent_at (sent_at)
);
```

#### 2.1.6 PRICING_CONFIG Table

```sql
CREATE TABLE pricing_config (
    id INT PRIMARY KEY AUTO_INCREMENT,
    config_name VARCHAR(100) NOT NULL,
    category ENUM('membership', 'regular_session', 'private_session', 'cafe', 'additional') NOT NULL,
    service_type VARCHAR(50) NOT NULL,
    base_price DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    current_price DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    pricing_rules JSON NULL,
    effective_date DATE NOT NULL,
    expiry_date DATE NULL,
    is_active BOOLEAN DEFAULT TRUE,
    created_by INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    INDEX idx_category (category),
    INDEX idx_service_type (service_type),
    INDEX idx_effective_date (effective_date),
    INDEX idx_is_active (is_active)
);
```

#### 2.1.2 PRICING_RULES Table

```sql
CREATE TABLE pricing_rules (
    id INT PRIMARY KEY AUTO_INCREMENT,
    rule_name VARCHAR(100) NOT NULL,
    rule_type ENUM('time_based', 'seasonal', 'member_discount', 'promotional', 'package', 'capacity') NOT NULL,
    rule_conditions JSON NOT NULL,
    rule_actions JSON NOT NULL,
    priority INT DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    INDEX idx_rule_type (rule_type),
    INDEX idx_priority (priority),
    INDEX idx_is_active (is_active)
);
```

#### 2.1.3 PRICING_HISTORY Table

```sql
CREATE TABLE pricing_history (
    id INT PRIMARY KEY AUTO_INCREMENT,
    config_id INT NOT NULL,
    old_price DECIMAL(10,2),
    new_price DECIMAL(10,2) NOT NULL,
    change_reason VARCHAR(255),
    changed_by INT NOT NULL,
    changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (config_id) REFERENCES pricing_config(id) ON DELETE CASCADE,
    FOREIGN KEY (changed_by) REFERENCES users(id),
    INDEX idx_config_id (config_id),
    INDEX idx_changed_at (changed_at)
);
```

### 2.2 Authentication dan SSO Tables

#### 2.2.1 USERS Table (Updated with SSO Support)

```sql
CREATE TABLE users (
    id INT PRIMARY KEY AUTO_INCREMENT,
    username VARCHAR(50) UNIQUE,
    email VARCHAR(100) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NULL,
    auth_provider ENUM('local', 'google', 'facebook') DEFAULT 'local',
    auth_provider_id VARCHAR(255) NULL,
    is_email_verified BOOLEAN DEFAULT FALSE,
    is_active BOOLEAN DEFAULT TRUE,
    role ENUM('admin', 'staff', 'member', 'guest') DEFAULT 'guest',
    last_login_at TIMESTAMP NULL,
    login_count INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    INDEX idx_email (email),
    INDEX idx_auth_provider (auth_provider),
    INDEX idx_auth_provider_id (auth_provider_id),
    INDEX idx_is_active (is_active)
);
```

#### 2.2.2 USER_PROFILES Table (Enhanced for SSO)

```sql
CREATE TABLE user_profiles (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    full_name VARCHAR(100) NOT NULL,
    phone VARCHAR(15),
    avatar_url VARCHAR(255),
    date_of_birth DATE NULL,
    gender ENUM('male', 'female', 'other') NULL,
    address TEXT,
    city VARCHAR(50),
    postal_code VARCHAR(10),
    emergency_contact VARCHAR(15),
    profile_source ENUM('manual', 'google_sync', 'merged') DEFAULT 'manual',
    google_profile_id VARCHAR(255) NULL,
    last_profile_sync TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_user_id (user_id),
    INDEX idx_google_profile_id (google_profile_id),
    INDEX idx_profile_source (profile_source)
);
```

#### 2.2.3 SSO_SESSIONS Table

```sql
CREATE TABLE sso_sessions (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    provider ENUM('google', 'facebook') NOT NULL,
    access_token TEXT NOT NULL,
    refresh_token TEXT,
    token_type VARCHAR(50) DEFAULT 'Bearer',
    expires_at TIMESTAMP NOT NULL,
    scope TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_user_id (user_id),
    INDEX idx_provider (provider),
    INDEX idx_expires_at (expires_at),
    INDEX idx_is_active (is_active)
);
```

#### 2.2.4 AUTHENTICATION_LOGS Table

```sql
CREATE TABLE authentication_logs (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NULL,
    auth_method ENUM('email_password', 'google_oauth', 'guest_access') NOT NULL,
    action ENUM('login', 'logout', 'failed_login', 'password_reset', 'sso_login') NOT NULL,
    ip_address VARCHAR(45),
    user_agent TEXT,
    success BOOLEAN DEFAULT TRUE,
    error_message VARCHAR(255) NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL,
    INDEX idx_user_id (user_id),
    INDEX idx_auth_method (auth_method),
    INDEX idx_action (action),
    INDEX idx_created_at (created_at)
);
```

### 2.3 Guest User Management Tables

#### 2.3.1 GUEST_USERS Table (Updated for SSO Conversion)

```sql
CREATE TABLE guest_users (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_profile_id INT NULL,
    full_name VARCHAR(100) NOT NULL,
    phone VARCHAR(15) NOT NULL,
    email VARCHAR(100),
    emergency_contact VARCHAR(15),
    total_visits INT DEFAULT 0,
    last_visit_date DATE,
    is_converted_to_member BOOLEAN DEFAULT FALSE,
    converted_user_id INT NULL,
    conversion_method ENUM('manual', 'google_sso') NULL,
    conversion_date TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    FOREIGN KEY (user_profile_id) REFERENCES user_profiles(id) ON DELETE SET NULL,
    FOREIGN KEY (converted_user_id) REFERENCES users(id) ON DELETE SET NULL,
    INDEX idx_phone (phone),
    INDEX idx_email (email),
    INDEX idx_is_converted (is_converted_to_member),
    INDEX idx_conversion_method (conversion_method)
);
```

#### 2.3.2 BOOKING_PROOFS Table

```sql
CREATE TABLE booking_proofs (
    id INT PRIMARY KEY AUTO_INCREMENT,
    booking_id INT NOT NULL,
    proof_type ENUM('qr_code', 'reference', 'receipt', 'sms', 'email') NOT NULL,
    reference_number VARCHAR(20) UNIQUE NOT NULL,
    qr_code_hash VARCHAR(255),
    qr_code_image_url VARCHAR(255),
    receipt_url VARCHAR(255),
    is_verified BOOLEAN DEFAULT FALSE,
    verification_time TIMESTAMP NULL,
    verified_by INT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    FOREIGN KEY (booking_id) REFERENCES bookings(id) ON DELETE CASCADE,
    FOREIGN KEY (verified_by) REFERENCES users(id),
    INDEX idx_booking_id (booking_id),
    INDEX idx_reference_number (reference_number),
    INDEX idx_qr_code_hash (qr_code_hash),
    INDEX idx_is_verified (is_verified)
);
```

#### 2.3.3 VERIFICATION_ATTEMPTS Table

```sql
CREATE TABLE verification_attempts (
    id INT PRIMARY KEY AUTO_INCREMENT,
    booking_id INT NULL,
    attempt_method ENUM('qr', 'reference', 'phone', 'email') NOT NULL,
    ip_address VARCHAR(45),
    user_agent TEXT,
    success BOOLEAN,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (booking_id) REFERENCES bookings(id) ON DELETE SET NULL,
    INDEX idx_booking_id (booking_id),
    INDEX idx_created_at (created_at),
    INDEX idx_success (success)
);
```

### 2.4 Updated Core Tables untuk SSO Support

#### 2.4.1 MEMBERS Table (Updated with Profile Reference)

```sql
CREATE TABLE members (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    user_profile_id INT NOT NULL,
    member_code VARCHAR(10) UNIQUE NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    membership_start DATE NOT NULL,
    membership_end DATE NOT NULL,
    membership_type ENUM('monthly', 'quarterly') NOT NULL,
    pricing_package_id INT NULL,
    registration_method ENUM('manual', 'google_sso', 'guest_conversion') DEFAULT 'manual',
    converted_from_guest_id INT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (user_profile_id) REFERENCES user_profiles(id) ON DELETE CASCADE,
    FOREIGN KEY (pricing_package_id) REFERENCES pricing_config(id),
    FOREIGN KEY (converted_from_guest_id) REFERENCES guest_users(id) ON DELETE SET NULL,
    INDEX idx_member_code (member_code),
    INDEX idx_is_active (is_active),
    INDEX idx_membership_end (membership_end),
    INDEX idx_registration_method (registration_method)
);
```

#### 2.4.2 BOOKINGS Table (Updated with Guest Support)

```sql
CREATE TABLE bookings (
    id INT PRIMARY KEY AUTO_INCREMENT,
    member_id INT NULL,
    guest_user_id INT NULL,
    booking_type ENUM('regular', 'private_silver', 'private_gold') NOT NULL,
    booking_reference VARCHAR(20) UNIQUE NOT NULL,
    booking_date DATE NOT NULL,
    session_time ENUM('morning', 'afternoon') NOT NULL,
    adult_count INT NOT NULL DEFAULT 0,
    child_count INT NOT NULL DEFAULT 0,
    status ENUM('pending', 'confirmed', 'checked_in', 'completed', 'cancelled') DEFAULT 'pending',
    base_amount DECIMAL(10,2) NOT NULL,
    discount_amount DECIMAL(10,2) DEFAULT 0.00,
    final_amount DECIMAL(10,2) NOT NULL,
    pricing_config_id INT NULL,
    is_checkin BOOLEAN DEFAULT FALSE,
    checkin_time TIMESTAMP NULL,
    notes TEXT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    FOREIGN KEY (member_id) REFERENCES members(id) ON DELETE CASCADE,
    FOREIGN KEY (guest_user_id) REFERENCES guest_users(id) ON DELETE CASCADE,
    FOREIGN KEY (pricing_config_id) REFERENCES pricing_config(id),
    INDEX idx_member_id (member_id),
    INDEX idx_guest_user_id (guest_user_id),
    INDEX idx_booking_reference (booking_reference),
    INDEX idx_booking_date (booking_date),
    INDEX idx_status (status),
    INDEX idx_booking_type (booking_type)
);
```

## 3. Data Seeding untuk Dynamic Pricing

### 3.1 Initial Pricing Configuration

```sql
-- Membership Packages
INSERT INTO pricing_config (config_name, category, service_type, base_price, current_price, effective_date, created_by) VALUES
('Monthly Membership', 'membership', 'monthly', 200000.00, 200000.00, '2025-01-01', 1),
('Quarterly Membership', 'membership', 'quarterly', 500000.00, 500000.00, '2025-01-01', 1),
('Quarterly Discount Rate', 'membership', 'quarterly_discount', 10.00, 10.00, '2025-01-01', 1);

-- Regular Sessions
INSERT INTO pricing_config (config_name, category, service_type, base_price, current_price, effective_date, created_by) VALUES
('Regular Weekday Adult', 'regular_session', 'weekday_adult', 25000.00, 25000.00, '2025-01-01', 1),
('Regular Weekday Child', 'regular_session', 'weekday_child', 20000.00, 20000.00, '2025-01-01', 1),
('Regular Weekend Adult', 'regular_session', 'weekend_adult', 30000.00, 30000.00, '2025-01-01', 1),
('Regular Weekend Child', 'regular_session', 'weekend_child', 25000.00, 25000.00, '2025-01-01', 1);

-- Private Sessions
INSERT INTO pricing_config (config_name, category, service_type, base_price, current_price, effective_date, created_by) VALUES
('Private Silver Package', 'private_session', 'silver', 200000.00, 200000.00, '2025-01-01', 1),
('Private Gold Package', 'private_session', 'gold', 400000.00, 400000.00, '2025-01-01', 1);
```

### 3.2 Pricing Rules

```sql
-- Member Discount Rule
INSERT INTO pricing_rules (rule_name, rule_type, rule_conditions, rule_actions, priority) VALUES
('Member Discount', 'member_discount',
 '{"member_status": "active", "membership_end": {"$gte": "current_date"}}',
 '{"discount_type": "percentage", "discount_value": 10}', 1);

-- Seasonal Pricing Rule (High Season)
INSERT INTO pricing_rules (rule_name, rule_type, rule_conditions, rule_actions, priority) VALUES
('High Season Pricing', 'seasonal',
 '{"date_range": {"start": "2025-06-01", "end": "2025-08-31"}, "day_type": ["saturday", "sunday"]}',
 '{"adjustment_type": "percentage", "adjustment_value": 15}', 2);

-- Promotional Pricing Rule
INSERT INTO pricing_rules (rule_name, rule_type, rule_conditions, rule_actions, priority) VALUES
('New Member Promotion', 'promotional',
 '{"member_status": "new", "days_since_registration": {"$lte": 7}}',
 '{"discount_type": "percentage", "discount_value": 20}', 3);
```

## 4. Views untuk Reporting

### 4.1 Pricing Analytics View

```sql
CREATE VIEW pricing_analytics AS
SELECT
    pc.config_name,
    pc.category,
    pc.current_price,
    pc.base_price,
    ((pc.current_price - pc.base_price) / pc.base_price * 100) as price_change_percentage,
    COUNT(pc.id) as times_used,
    SUM(b.final_amount) as total_revenue,
    AVG(b.final_amount) as avg_revenue_per_booking
FROM pricing_config pc
LEFT JOIN bookings b ON pc.id = b.pricing_config_id
WHERE pc.is_active = TRUE
GROUP BY pc.id, pc.config_name, pc.category;
```

### 4.2 Revenue by Pricing Category View

```sql
CREATE VIEW revenue_by_pricing_category AS
SELECT
    pc.category,
    pc.service_type,
    COUNT(b.id) as total_bookings,
    SUM(b.final_amount) as total_revenue,
    AVG(b.final_amount) as avg_revenue,
    MIN(b.final_amount) as min_revenue,
    MAX(b.final_amount) as max_revenue,
    DATE_FORMAT(b.created_at, '%Y-%m') as month
FROM pricing_config pc
JOIN bookings b ON pc.id = b.pricing_config_id
WHERE b.status IN ('confirmed', 'completed')
GROUP BY pc.category, pc.service_type, DATE_FORMAT(b.created_at, '%Y-%m');
```

## 5. Stored Procedures

### 5.1 Get Calendar Availability

```sql
DELIMITER //
CREATE PROCEDURE GetCalendarAvailability(
    IN start_date DATE,
    IN end_date DATE
)
BEGIN
    SELECT
        ca.date,
        ca.is_operational,
        ca.max_daily_capacity,
        ca.morning_session_capacity,
        ca.afternoon_session_capacity,
        dc.morning_adults_booked,
        dc.morning_children_booked,
        dc.afternoon_adults_booked,
        dc.afternoon_children_booked,
        (ca.morning_session_capacity - dc.morning_adults_booked - dc.morning_children_booked) as morning_available,
        (ca.afternoon_session_capacity - dc.afternoon_adults_booked - dc.afternoon_children_booked) as afternoon_available,
        CASE
            WHEN ca.is_operational = FALSE THEN 'closed'
            WHEN (dc.morning_adults_booked + dc.morning_children_booked) >= ca.morning_session_capacity
                 AND (dc.afternoon_adults_booked + dc.afternoon_children_booked) >= ca.afternoon_session_capacity THEN 'full'
            WHEN (dc.morning_adults_booked + dc.morning_children_booked) >= ca.morning_session_capacity
                 OR (dc.afternoon_adults_booked + dc.afternoon_children_booked) >= ca.afternoon_session_capacity THEN 'partial'
            ELSE 'available'
        END as status
    FROM calendar_availability ca
    LEFT JOIN daily_capacity dc ON ca.date = dc.date
    WHERE ca.date BETWEEN start_date AND end_date
    ORDER BY ca.date;
END //
DELIMITER ;
```

### 5.2 Check Session Availability

```sql
DELIMITER //
CREATE PROCEDURE CheckSessionAvailability(
    IN booking_date DATE,
    IN session_type ENUM('morning', 'afternoon'),
    IN adult_count INT,
    IN child_count INT,
    OUT is_available BOOLEAN,
    OUT available_adults INT,
    OUT available_children INT
)
BEGIN
    DECLARE max_adults INT DEFAULT 10;
    DECLARE max_children INT DEFAULT 10;
    DECLARE current_adults INT DEFAULT 0;
    DECLARE current_children INT DEFAULT 0;

    -- Get session capacity
    SELECT
        CASE
            WHEN session_type = 'morning' THEN ca.morning_session_capacity / 2
            ELSE ca.afternoon_session_capacity / 2
        END,
        CASE
            WHEN session_type = 'morning' THEN ca.morning_session_capacity / 2
            ELSE ca.afternoon_session_capacity / 2
        END
    INTO max_adults, max_children
    FROM calendar_availability ca
    WHERE ca.date = booking_date AND ca.is_operational = TRUE;

    -- Get current bookings
    SELECT
        CASE
            WHEN session_type = 'morning' THEN dc.morning_adults_booked
            ELSE dc.afternoon_adults_booked
        END,
        CASE
            WHEN session_type = 'morning' THEN dc.morning_children_booked
            ELSE dc.afternoon_children_booked
        END
    INTO current_adults, current_children
    FROM daily_capacity dc
    WHERE dc.date = booking_date;

    -- Calculate available slots
    SET available_adults = max_adults - current_adults;
    SET available_children = max_children - current_children;

    -- Check if booking is possible
    SET is_available = (available_adults >= adult_count AND available_children >= child_count);
END //
DELIMITER ;
```

### 5.3 Update Session Capacity

```sql
DELIMITER //
CREATE PROCEDURE UpdateSessionCapacity(
    IN booking_date DATE,
    IN session_type ENUM('morning', 'afternoon'),
    IN adult_count INT,
    IN child_count INT,
    IN operation ENUM('add', 'remove')
)
BEGIN
    DECLARE capacity_id INT;

    -- Get or create daily capacity record
    SELECT id INTO capacity_id FROM daily_capacity WHERE date = booking_date;

    IF capacity_id IS NULL THEN
        INSERT INTO daily_capacity (calendar_availability_id, date)
        VALUES ((SELECT id FROM calendar_availability WHERE date = booking_date), booking_date);
        SET capacity_id = LAST_INSERT_ID();
    END IF;

    -- Update capacity based on operation
    IF operation = 'add' THEN
        IF session_type = 'morning' THEN
            UPDATE daily_capacity
            SET morning_adults_booked = morning_adults_booked + adult_count,
                morning_children_booked = morning_children_booked + child_count,
                total_bookings = total_bookings + adult_count + child_count
            WHERE id = capacity_id;
        ELSE
            UPDATE daily_capacity
            SET afternoon_adults_booked = afternoon_adults_booked + adult_count,
                afternoon_children_booked = afternoon_children_booked + child_count,
                total_bookings = total_bookings + adult_count + child_count
            WHERE id = capacity_id;
        END IF;
    ELSE
        IF session_type = 'morning' THEN
            UPDATE daily_capacity
            SET morning_adults_booked = GREATEST(0, morning_adults_booked - adult_count),
                morning_children_booked = GREATEST(0, morning_children_booked - child_count),
                total_bookings = GREATEST(0, total_bookings - adult_count - child_count)
            WHERE id = capacity_id;
        ELSE
            UPDATE daily_capacity
            SET afternoon_adults_booked = GREATEST(0, afternoon_adults_booked - adult_count),
                afternoon_children_booked = GREATEST(0, afternoon_children_booked - child_count),
                total_bookings = GREATEST(0, total_bookings - adult_count - child_count)
            WHERE id = capacity_id;
        END IF;
    END IF;
END //
DELIMITER ;
```

### 5.4 Calculate Dynamic Price Procedure

```sql
DELIMITER //
CREATE PROCEDURE CalculateBookingPrice(
    IN p_booking_type VARCHAR(50),
    IN p_adult_count INT,
    IN p_child_count INT,
    IN p_booking_date DATE,
    IN p_session_time VARCHAR(20),
    IN p_member_id INT,
    OUT p_base_amount DECIMAL(10,2),
    OUT p_discount_amount DECIMAL(10,2),
    OUT p_final_amount DECIMAL(10,2),
    OUT p_pricing_config_id INT
)
BEGIN
    DECLARE v_base_price DECIMAL(10,2) DEFAULT 0;
    DECLARE v_child_price DECIMAL(10,2) DEFAULT 0;
    DECLARE v_discount_percentage DECIMAL(5,2) DEFAULT 0;
    DECLARE v_is_member BOOLEAN DEFAULT FALSE;
    DECLARE v_is_weekend BOOLEAN DEFAULT FALSE;

    -- Check if date is weekend
    SET v_is_weekend = DAYOFWEEK(p_booking_date) IN (1, 7);

    -- Check if member is active
    SELECT EXISTS(SELECT 1 FROM members WHERE id = p_member_id AND is_active = TRUE AND membership_end >= CURDATE()) INTO v_is_member;

    -- Get base pricing
    IF p_booking_type = 'regular' THEN
        IF v_is_weekend THEN
            SELECT current_price INTO v_base_price FROM pricing_config
            WHERE service_type = 'weekend_adult' AND is_active = TRUE LIMIT 1;
            SELECT current_price INTO v_child_price FROM pricing_config
            WHERE service_type = 'weekend_child' AND is_active = TRUE LIMIT 1;
        ELSE
            SELECT current_price INTO v_base_price FROM pricing_config
            WHERE service_type = 'weekday_adult' AND is_active = TRUE LIMIT 1;
            SELECT current_price INTO v_child_price FROM pricing_config
            WHERE service_type = 'weekday_child' AND is_active = TRUE LIMIT 1;
        END IF;

        SET p_base_amount = (v_base_price * p_adult_count) + (v_child_price * p_child_count);

    ELSEIF p_booking_type IN ('private_silver', 'private_gold') THEN
        SELECT current_price INTO v_base_price FROM pricing_config
        WHERE service_type = p_booking_type AND is_active = TRUE LIMIT 1;
        SET p_base_amount = v_base_price;
    END IF;

    -- Apply member discount
    IF v_is_member THEN
        SET v_discount_percentage = 10; -- 10% member discount
        SET p_discount_amount = p_base_amount * (v_discount_percentage / 100);
    ELSE
        SET p_discount_amount = 0;
    END IF;

    SET p_final_amount = p_base_amount - p_discount_amount;

    -- Get pricing config ID
    SELECT id INTO p_pricing_config_id FROM pricing_config
    WHERE service_type = CASE
        WHEN p_booking_type = 'regular' AND v_is_weekend THEN 'weekend_adult'
        WHEN p_booking_type = 'regular' AND NOT v_is_weekend THEN 'weekday_adult'
        ELSE p_booking_type
    END AND is_active = TRUE LIMIT 1;

END //
DELIMITER ;
```

### 5.2 Update Pricing Configuration Procedure

```sql
DELIMITER //
CREATE PROCEDURE UpdatePricingConfig(
    IN p_config_id INT,
    IN p_new_price DECIMAL(10,2),
    IN p_change_reason VARCHAR(255),
    IN p_updated_by INT
)
BEGIN
    DECLARE v_old_price DECIMAL(10,2);
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

    -- Get current price
    SELECT current_price INTO v_old_price FROM pricing_config WHERE id = p_config_id;

    -- Update pricing config
    UPDATE pricing_config
    SET current_price = p_new_price, updated_at = CURRENT_TIMESTAMP
    WHERE id = p_config_id;

    -- Log price change
    INSERT INTO pricing_history (config_id, old_price, new_price, change_reason, changed_by)
    VALUES (p_config_id, v_old_price, p_new_price, p_change_reason, p_updated_by);

    COMMIT;
END //
DELIMITER ;
```

## 6. Triggers

### 6.1 Booking Price Calculation Trigger

```sql
DELIMITER //
CREATE TRIGGER before_booking_insert
BEFORE INSERT ON bookings
FOR EACH ROW
BEGIN
    DECLARE v_base_amount DECIMAL(10,2);
    DECLARE v_discount_amount DECIMAL(10,2);
    DECLARE v_final_amount DECIMAL(10,2);
    DECLARE v_pricing_config_id INT;

    -- Calculate pricing
    CALL CalculateBookingPrice(
        NEW.booking_type,
        NEW.adult_count,
        NEW.child_count,
        NEW.booking_date,
        NEW.session_time,
        NEW.member_id,
        v_base_amount,
        v_discount_amount,
        v_final_amount,
        v_pricing_config_id
    );

    -- Set calculated values
    SET NEW.base_amount = v_base_amount;
    SET NEW.discount_amount = v_discount_amount;
    SET NEW.final_amount = v_final_amount;
    SET NEW.pricing_config_id = v_pricing_config_id;
END //
DELIMITER ;
```

---

**Versi**: 1.2  
**Tanggal**: 26 Agustus 2025  
**Status**: Updated dengan dynamic pricing system  
**Berdasarkan**: PDF Raujan Pool Syariah
