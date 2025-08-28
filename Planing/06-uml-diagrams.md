# UML Diagrams - Sistem Kolam Renang Syariah

## 1. Use Case Diagram

### 1.1 Use Case Diagram Utama

```mermaid
graph TB
    subgraph "Sistem Kolam Renang Syariah"
        subgraph "Actors"
            A1[Admin]
            A2[Staff Front Desk]
            A3[Staff Cafe]
            A4[Member]
            A5[Non-Member]
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

                subgraph "Comprehensive Reporting System"
                    UC139[Generate Revenue Reports]
                    UC140[Generate Expense Reports]
                    UC141[Generate Profit & Loss Reports]
                    UC142[Generate Cash Flow Reports]
                    UC143[Generate Tax Reports]
                    UC144[Generate Budget Analysis]
                    UC145[Generate Booking Analytics]
                    UC146[Generate Member Reports]
                    UC147[Generate Session Reports]
                    UC148[Generate Staff Reports]
                    UC149[Generate Facility Reports]
                    UC150[Generate Customer Analytics]
                    UC151[Generate Inventory Reports]
                    UC152[Generate Promotional Reports]
                    UC153[Export Reports]
                    UC154[Schedule Reports]
                    UC155[Configure Report Templates]
                    UC156[View Real-time Dashboard]
                end

                subgraph "System Administration"
                    UC157[Manage System Configuration]
                    UC158[Manage User Roles]
                    UC159[Manage Permissions]
                    UC160[System Backup]
                    UC161[System Restore]
                    UC162[View System Logs]
                    UC163[Manage API Keys]
                    UC164[Configure Integrations]
                    UC165[System Monitoring]
                    UC166[Performance Optimization]
                end

                subgraph "Data Management"
                    UC167[Data Import]
                    UC168[Data Export]
                    UC169[Data Validation]
                    UC170[Data Cleanup]
                    UC171[Data Migration]
                    UC172[Data Archival]
                    UC173[Data Recovery]
                    UC174[Data Backup]
                    UC175[Manage Data Retention]
                    UC176[Data Compliance]
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

            A1 -.-> UC139
            A1 -.-> UC140
            A1 -.-> UC141
            A1 -.-> UC142
            A1 -.-> UC143
            A1 -.-> UC144
            A1 -.-> UC145
            A1 -.-> UC146
            A1 -.-> UC147
            A1 -.-> UC148
            A1 -.-> UC149
            A1 -.-> UC150
            A1 -.-> UC151
            A1 -.-> UC152
            A1 -.-> UC153
            A1 -.-> UC154
            A1 -.-> UC155
            A1 -.-> UC156

            A1 -.-> UC157
            A1 -.-> UC158
            A1 -.-> UC159
            A1 -.-> UC160
            A1 -.-> UC161
            A1 -.-> UC162
            A1 -.-> UC163
            A1 -.-> UC164
            A1 -.-> UC165
            A1 -.-> UC166

            A1 -.-> UC167
            A1 -.-> UC168
            A1 -.-> UC169
            A1 -.-> UC170
            A1 -.-> UC171
            A1 -.-> UC172
            A1 -.-> UC173
            A1 -.-> UC174
            A1 -.-> UC175
            A1 -.-> UC176

            A2 -.-> UC145
            A2 -.-> UC146
            A2 -.-> UC147
            A2 -.-> UC148
            A2 -.-> UC149

            A3 -.-> UC145
            A3 -.-> UC151
            A3 -.-> UC153


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

    User -- Member : has
    Member o-- Booking : makes
    Package o-- Member : subscribes
    Booking -- Payment : has
    Booking o-- Session : includes
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

    CafeMenu o-- CafeOrderItem : contains
    CafeOrder o-- CafeOrderItem : has
    CafeMenu -- CafeInventory : tracks
    CafeInventory o-- InventoryLog : logs
    CafeInventory o-- StockAlert : generates
```

### 2.3 Class Diagram Rating & Review System

```mermaid
classDiagram
    class Rating {
        -int id
        -int user_id
        -int booking_id
        -int cafe_order_id
        -decimal overall_rating
        -string comments
        -timestamp created_at
        -boolean is_verified
        +submitRating()
        +updateRating()
        +deleteRating()
        +calculateAverageRating()
    }

    class RatingComponent {
        -int id
        -int rating_id
        -string component_type
        -decimal score
        -string description
        +setScore()
        +getScore()
        +getComponentType()
    }

    class StaffRating {
        -int id
        -int rating_id
        -int staff_id
        -decimal score
        -string feedback
        -timestamp rated_at
        +rateStaff()
        +getStaffRating()
        +updateStaffRating()
    }

    class RatingAnalytics {
        -int id
        -string rating_type
        -decimal average_rating
        -int total_ratings
        -int five_star_count
        -int four_star_count
        -int three_star_count
        -int two_star_count
        -int one_star_count
        +updateAnalytics()
        +getRatingDistribution()
        +calculateGrowthRate()
    }

    Rating o-- RatingComponent : has
    Rating -- StaffRating : includes
    Rating -- RatingAnalytics : contributes_to
```

### 2.4 Class Diagram Promotional System

```mermaid
classDiagram
    class PromotionalCampaign {
        -int id
        -string campaign_name
        -string campaign_type
        -string description
        -date start_date
        -date end_date
        -decimal discount_value
        -string discount_type
        -boolean is_active
        -string targeting_rules
        +createCampaign()
        +updateCampaign()
        +activateCampaign()
        +deactivateCampaign()
        +validateEligibility()
        +applyDiscount()
    }

    class CampaignUsage {
        -int id
        -int campaign_id
        -int user_id
        -int booking_id
        -decimal discount_applied
        -timestamp used_at
        +recordUsage()
        +getUsageCount()
        +validateUsageLimit()
    }

    class PromotionTemplate {
        -int id
        -string template_name
        -string template_type
        -string discount_structure
        -string targeting_criteria
        -boolean is_active
        +createTemplate()
        +applyTemplate()
        +duplicateTemplate()
    }

    class CampaignAnalytics {
        -int id
        -int campaign_id
        -int total_usage
        -decimal total_discount_given
        -int conversion_count
        -decimal conversion_rate
        +updateAnalytics()
        +getCampaignPerformance()
    }

    PromotionalCampaign o-- CampaignUsage : tracks
    PromotionalCampaign -- PromotionTemplate : based_on
    PromotionalCampaign -- CampaignAnalytics : generates
```

### 2.5 Class Diagram Manual Payment System

```mermaid
classDiagram
    class ManualPayment {
        -int id
        -int booking_id
        -int user_id
        -decimal amount
        -string bank_account
        -string transfer_reference
        -string payment_proof_url
        -string status
        -timestamp payment_date
        -timestamp verified_at
        -int verified_by
        +submitPayment()
        +verifyPayment()
        +rejectPayment()
        +generatePaymentInstructions()
    }

    class BankAccountConfig {
        -int id
        -string bank_name
        -string account_number
        -string account_holder
        -string branch_code
        -boolean is_active
        +addBankAccount()
        +updateBankAccount()
        +deactivateAccount()
    }

    class PaymentVerificationLog {
        -int id
        -int payment_id
        -int admin_id
        -string action_type
        -string verification_notes
        -timestamp verified_at
        +logVerification()
        +getVerificationHistory()
    }

    ManualPayment -- BankAccountConfig : uses
    ManualPayment o-- PaymentVerificationLog : has
```

### 2.6 Class Diagram Dynamic Member Quota Management

```mermaid
classDiagram
    class MemberQuotaConfig {
        -int id
        -int max_members
        -int current_members
        -int grace_period_days
        -int warning_period_days
        -boolean is_active
        +updateQuota()
        +getAvailableSlots()
        +checkQuotaFull()
    }

    class MemberQueue {
        -int id
        -int user_id
        -string queue_position
        -date joined_date
        -string status
        -timestamp promoted_at
        +joinQueue()
        +updatePosition()
        +promoteMember()
        +leaveQueue()
    }

    class MemberExpiryTracking {
        -int id
        -int member_id
        -date expiry_date
        -date warning_sent_date
        -date deactivation_date
        -string status
        +trackExpiry()
        +sendWarning()
        +deactivateMember()
    }

    class QuotaHistory {
        -int id
        -int quota_config_id
        -int total_members
        -int active_members
        -int queue_length
        -timestamp recorded_at
        +recordHistory()
        +getQuotaTrends()
    }

    MemberQuotaConfig o-- MemberQueue : manages
    MemberQuotaConfig o-- MemberExpiryTracking : tracks
    MemberQuotaConfig o-- QuotaHistory : generates
```

### 2.7 Class Diagram Member Daily Swimming Limit

```mermaid
classDiagram
    class MemberDailyUsage {
        -int id
        -int member_id
        -date usage_date
        -int free_sessions_used
        -int paid_sessions_used
        -decimal total_paid_amount
        +checkDailyLimit()
        +updateUsage()
        +resetDailyUsage()
        +getUsageSummary()
    }

    class MemberLimitOverride {
        -int id
        -int member_id
        -int admin_id
        -string override_reason
        -timestamp override_date
        -boolean is_active
        +applyOverride()
        +revokeOverride()
        +getOverrideHistory()
    }

    class MemberSessionHistory {
        -int id
        -int member_id
        -int booking_id
        -string session_type
        -decimal session_cost
        -timestamp session_date
        +recordSession()
        +getSessionHistory()
    }

    MemberDailyUsage o-- MemberLimitOverride : allows
    MemberDailyUsage o-- MemberSessionHistory : tracks
```

### 2.8 Class Diagram Private Pool Rental System

```mermaid
classDiagram
    class PrivatePoolBooking {
        -int id
        -int customer_id
        -date booking_date
        -time start_time
        -time end_time
        -int duration_minutes
        -string customer_type
        -decimal base_price
        -decimal additional_charge
        -decimal total_price
        -string status
        +createBooking()
        +calculatePrice()
        +extendBooking()
        +completeBooking()
    }

    class PrivatePoolPricingConfig {
        -int id
        -decimal base_hourly_rate
        -decimal new_customer_bonus_minutes
        -decimal returning_customer_charge
        -int visit_threshold
        -boolean is_active
        +updatePricing()
        +calculateCustomerPrice()
    }

    class CustomerVisitHistory {
        -int id
        -int customer_id
        -int visit_count
        -decimal total_spent
        -date first_visit
        -date last_visit
        +updateVisitHistory()
        +getCustomerType()
        +calculateVisitMetrics()
    }

    PrivatePoolBooking -- PrivatePoolPricingConfig : uses
    PrivatePoolBooking -- CustomerVisitHistory : tracks
```

### 2.9 Class Diagram Barcode System

```mermaid
classDiagram
    class MenuBarcode {
        -int id
        -int menu_id
        -string barcode_value
        -string qr_code_url
        -string barcode_image_url
        -boolean is_active
        -timestamp generated_at
        +generateBarcode()
        +updateBarcode()
        +deactivateBarcode()
        +getBarcodeData()
    }

    class BarcodeLocation {
        -int id
        -string location_name
        -string location_code
        -string description
        -boolean is_active
        -string menu_category_filter
        +addLocation()
        +updateLocation()
        +getMenuByLocation()
    }

    class BarcodeScan {
        -int id
        -int menu_id
        -int user_id
        -string location_code
        -timestamp scanned_at
        -string device_info
        +recordScan()
        +getScanHistory()
        +analyzeScanPatterns()
    }

    MenuBarcode -- BarcodeLocation : available_at
    MenuBarcode o-- BarcodeScan : generates
```

### 2.10 Class Diagram Comprehensive Reporting System

```mermaid
classDiagram
    class Report {
        -int id
        -string report_type
        -string report_name
        -date report_date
        -string report_format
        -string report_url
        -int generated_by
        -timestamp generated_at
        +generateReport()
        +exportReport()
        +scheduleReport()
    }

    class FinancialReport {
        -int id
        -int report_id
        -decimal total_revenue
        -decimal total_expenses
        -decimal net_profit
        -int transaction_count
        -date period_start
        -date period_end
        +calculateMetrics()
        +generatePandL()
        +generateCashFlow()
    }

    class OperationalReport {
        -int id
        -int report_id
        -int total_bookings
        -int total_members
        -int session_utilization
        -int staff_performance_avg
        -date report_period
        +calculateUtilization()
        +generateBookingAnalytics()
        +generateMemberAnalytics()
    }

    class CustomerAnalytics {
        -int id
        -int report_id
        -int total_customers
        -decimal retention_rate
        -decimal satisfaction_score
        -string demographics_data
        -date analysis_period
        +analyzeCustomerBehavior()
        +calculateRetentionMetrics()
        +generateDemographicsReport()
    }

    class ReportSchedule {
        -int id
        -int report_id
        -string schedule_type
        -string frequency
        -time delivery_time
        -string recipients
        -boolean is_active
        +createSchedule()
        +updateSchedule()
        +executeScheduledReport()
    }

    Report -- FinancialReport : includes
    Report -- OperationalReport : includes
    Report -- CustomerAnalytics : includes
    Report o-- ReportSchedule : schedules
```

### 2.11 Class Diagram System Integration

```mermaid
classDiagram
    class Notification {
        -int id
        -int user_id
        -string notification_type
        -string title
        -string message
        -string status
        -timestamp sent_at
        -timestamp read_at
        +sendNotification()
        +markAsRead()
        +getUnreadCount()
    }

    class SystemLog {
        -int id
        -string action_type
        -int user_id
        -string description
        -string ip_address
        -timestamp created_at
        +logAction()
        +getActivityLog()
        +exportLogs()
    }

    class UserSession {
        -int id
        -int user_id
        -string session_token
        -string device_info
        -timestamp login_at
        -timestamp logout_at
        -boolean is_active
        +createSession()
        +validateSession()
        +logoutSession()
    }

    class SSOSession {
        -int id
        -int user_id
        -string provider
        -string provider_user_id
        -string access_token
        -timestamp expires_at
        +createSSOSession()
        +refreshToken()
        +validateSSO()
    }

    Notification -- UserSession : sends_to
    UserSession o-- SystemLog : generates
    UserSession -- SSOSession : authenticates_via
```

## 3. Activity Diagram

### 3.1 Activity Diagram Member Registration

```mermaid
flowchart TD
    A[Start] --> B[User Access Registration Page]
    B --> C[Fill Registration Form]
    C --> D[Upload Required Documents]
    D --> E[Choose Package]
    E --> F[Calculate Total Cost]
    F --> G[Proceed to Payment]
    G --> H[Make Payment]
    H --> I{Payment Successful?}
    I -->|Yes| J[Generate Temporary Account]
    I -->|No| K[Show Payment Error]
    K --> L[Retry Payment]
    L --> I
    J --> M[Admin Review Documents]
    M --> N{Documents Valid?}
    N -->|Yes| O[Activate Member Account]
    N -->|No| P[Request Document Correction]
    P --> Q[User Upload Corrected Documents]
    Q --> M
    O --> R[Generate Member Card]
    R --> S[Send Welcome Email/SMS]
    S --> T[End]
```

### 3.2 Activity Diagram Booking Process

```mermaid
flowchart TD
    A[Start] --> B[User Access Booking Page]
    B --> C[View Calendar Interface]
    C --> D{Navigate to Future Month?}
    D -->|Yes| E[Forward Calendar]
    D -->|No| F[Select Available Date]
    E --> F
    F --> G[View Session Details]
    G --> H{Session Available?}
    H -->|Yes| I[Select Session]
    H -->|No| J[Show Alternative Sessions]
    J --> I
    I --> K[Choose User Type]
    K --> L{Member or Guest?}
    L -->|Member| M[Login to Account]
    L -->|Guest| N[Fill Guest Form]
    M --> O[Load Member Profile]
    N --> O
    O --> P[Calculate Total Cost]
    P --> Q[Review Booking Details]
    Q --> R{Details Correct?}
    R -->|Yes| S[Proceed to Payment]
    R -->|No| T[Edit Booking Details]
    T --> P
    S --> U[Select Payment Method]
    U --> V{Payment Type?}
    V -->|Manual Transfer| W[Show Transfer Instructions]
    V -->|Other| X[Process Online Payment]
    W --> Y[Upload Payment Proof]
    X --> Z{Payment Successful?}
    Z -->|Yes| AA[Generate Booking Confirmation]
    Z -->|No| BB[Show Payment Error]
    BB --> S
    Y --> CC[Admin Verify Payment]
    CC --> DD{Payment Verified?}
    DD -->|Yes| AA
    DD -->|No| EE[Request Payment Correction]
    EE --> Y
    AA --> FF[Send Confirmation Email/SMS]
    FF --> GG[Generate QR Code]
    GG --> HH[End]
```

### 3.3 Activity Diagram Cafe Order Process

```mermaid
flowchart TD
    A[Start] --> B[User Scan Barcode/QR Code]
    B --> C[System Load Menu Based on Location]
    C --> D[Display Available Menu Items]
    D --> E[User Browse Menu]
    E --> F[Select Menu Item]
    F --> G{Item Available?}
    G -->|Yes| H[Add to Cart]
    G -->|No| I[Show Out of Stock Message]
    I --> E
    H --> J[Add Special Notes/Requests]
    J --> K[Update Cart Total]
    K --> L{Add More Items?}
    L -->|Yes| E
    L -->|No| M[Review Cart]
    M --> N{Cart Correct?}
    N -->|Yes| O[Proceed to Payment]
    N -->|No| P[Edit Cart]
    P --> E
    O --> Q[Select Payment Method]
    Q --> R{Payment Type?}
    R -->|Manual Transfer| S[Show Transfer Instructions]
    R -->|Online Payment| T[Process Online Payment]
    S --> U[Upload Payment Proof]
    T --> V{Payment Successful?}
    V -->|Yes| W[Generate Order Confirmation]
    V -->|No| X[Show Payment Error]
    X --> O
    U --> Y[Admin Verify Payment]
    Y --> Z{Payment Valid?}
    Z -->|Yes| W
    Z -->|No| AA[Request Payment Correction]
    BB --> GG[Send Order to Kitchen]
    FF --> GG
    GG --> HH[Update Order Status: Preparing]
    HH --> II[Kitchen Prepare Food]
    II --> JJ[Update Order Status: Ready]
    JJ --> KK[Staff Deliver Order]
    KK --> LL[Customer Confirm Reception]
    LL --> MM[Update Order Status: Delivered]
    MM --> NN[End]
```

### 3.4 Activity Diagram Rating System

```mermaid
flowchart TD
    A[Start] --> B[User Complete Service/Order]
    B --> C[System Request Rating]
    C --> D[User Access Rating Page]
    D --> E[Select Overall Rating 1-5 Stars]
    E --> F[Rate Individual Components]
    F --> G[Rate Booking Experience]
    G --> H[Rate Staff Service]
    H --> I[Rate Facility Quality]
    I --> J[Rate Cafe Service]
    J --> K[Add Written Comments]
    K --> L[Submit Rating]
    L --> M[System Validate Rating]
    M --> N{Rating Valid?}
    N -->|Yes| O[Save Rating to Database]
    N -->|No| P[Show Validation Error]
    P --> E
    O --> Q[Update Rating Analytics]
    Q --> R[Calculate Average Ratings]
    R --> S[Update Staff Performance Metrics]
    S --> T[Generate Rating Summary]
    T --> U[Send Thank You Message]
    U --> V[End]
```

### 3.5 Activity Diagram Check-in Process

```mermaid
flowchart TD
    A[Start] --> B[Customer Arrive at Pool]
    B --> C[Present Booking Reference/QR Code]
    C --> D[Staff Scan/Enter Reference]
    D --> E[System Validate Booking]
    E --> F{Booking Valid?}
    F -->|No| G[Show Invalid Booking Error]
    G --> H[Customer Resolution]
    H --> C
    F -->|Yes| I[Check Booking Status]
    I --> J{Already Checked-in?}
    J -->|Yes| K[Show Already Checked-in Message]
    J -->|No| L[Verify Customer Identity]
    L --> M{Identity Match?}
    M -->|No| N[Request ID Verification]
    N --> L
    M -->|Yes| O[Process Check-in]
    O --> P[Update Booking Status]
    P --> Q[Issue Pool Equipment]
    Q --> R[Record Check-in Time]
    R --> S[Send Check-in Confirmation]
    S --> T[Customer Access Pool]
    T --> U[Monitor Pool Usage]
    U --> V[Customer Request Check-out]
    V --> W[Collect Pool Equipment]
    W --> X[Record Check-out Time]
    X --> Y[Update Attendance Record]
    Y --> Z[Generate Usage Report]
    Z --> AA[End]
```

### 3.6 Activity Diagram Promotional Pricing

```mermaid
flowchart TD
    A[Start] --> B[Admin Access Promotional Management]
    B --> C[Create New Campaign]
    C --> D[Set Campaign Details]
    D --> E[Campaign Name & Description]
    E --> F[Select Campaign Type]
    F --> G{Discount Type?}
    G -->|Percentage| H[Set Discount Percentage]
    G -->|Fixed Amount| I[Set Discount Amount]
    G -->|Buy One Get One| J[Configure BOGO Rules]
    H --> K[Set Campaign Duration]
    I --> K
    J --> K
    K --> L[Configure Targeting Rules]
    L --> M[Select Target Services]
    M --> N[Set User Eligibility]
    N --> O[Configure Time Restrictions]
    O --> P[Activate Campaign]
    P --> Q[System Apply Rules]
    Q --> R[Monitor Campaign Performance]
    R --> S[User Access Booking/Cafe]
    S --> T[System Check Eligibility]
    T --> U{Eligible for Promotion?}
    U -->|Yes| V[Apply Promotional Pricing]
    U -->|No| W[Show Regular Pricing]
    V --> X[Display Promotional Offer]
    X --> Y[User Accept Offer]
    Y --> Z[Apply Discount]
    Z --> AA[Complete Transaction]
    AA --> BB[Update Campaign Usage]
    BB --> CC[Generate Promotional Report]
    CC --> DD[End]
```

### 3.7 Activity Diagram Manual Payment

```mermaid
flowchart TD
    A[Start] --> B[User Select Manual Payment]
    B --> C[System Display Payment Instructions]
    C --> D[Show Bank Account Details]
    D --> E[Generate Payment Reference]
    E --> F[User Make Bank Transfer]
    F --> G[User Upload Payment Proof]
    G --> H[System Receive Payment Proof]
    H --> I[Admin Notification: Payment Received]
    I --> J[Admin Access Payment Verification]
    J --> K[Admin Review Payment Proof]
    K --> L{Proof Valid?}
    L -->|No| M[Admin Reject Payment]
    L -->|Yes| N[Admin Verify Amount]
    M --> O[Send Rejection Notification]
    O --> P[User Upload Corrected Proof]
    P --> K
    N --> Q{Amount Correct?}
    Q -->|No| R[Admin Request Correction]
    Q -->|Yes| S[Admin Confirm Payment]
    R --> T[Send Correction Request]
    T --> P
    S --> U[Update Payment Status: Verified]
    U --> V[Process Booking/Purchase]
    V --> W[Send Confirmation Message]
    W --> X[Generate Receipt]
    X --> Y[End]
```

### 3.8 Activity Diagram Dynamic Member Quota

```mermaid
flowchart TD
    A[Start] --> B[Admin Configure Member Quota]
    B --> C[Set Maximum Member Limit]
    C --> D[Configure Warning Period]
    D --> E[Set Grace Period]
    E --> F[Activate Quota System]
    F --> G[User Request Membership]
    G --> H{Current Members < Max Limit?}
    H -->|Yes| I[Process Membership Registration]
    H -->|No| J[Add User to Queue]
    I --> K[Update Member Count]
    K --> L[End]
    J --> M[Assign Queue Position]
    M --> N[Send Queue Confirmation]
    N --> O[Monitor Member Expiry]
    O --> P{Member Near Expiry?}
    P -->|Yes| Q[Send Warning Notification]
    Q --> R{Member Renew?}
    R -->|Yes| S[Process Renewal]
    R -->|No| T[Wait for Grace Period]
    S --> U[Update Member Status]
    U --> V[End]
    T --> W{Grace Period Expired?}
    W -->|Yes| X[Deactivate Membership]
    W -->|No| T
    X --> Y{Queue Has Waiting Users?}
    Y -->|Yes| Z[Promote First in Queue]
    Y -->|No| AA[Update Quota Statistics]
    Z --> BB[Send Promotion Offer]
    BB --> CC{User Accept?}
    CC -->|Yes| DD[Process Membership]
    CC -->|No| EE[Remove from Queue]
    DD --> FF[Update Member Count]
    EE --> GG[Update Queue Position]
    FF --> HH[End]
    GG --> AA
```

### 3.9 Activity Diagram Member Daily Swimming Limit

```mermaid
flowchart TD
    A[Start] --> B[Member Access Booking]
    B --> C[Select Session Date]
    C --> D[System Check Daily Limit]
    D --> E{Already Used Free Session Today?}
    E -->|No| F[Book Free Session]
    E -->|Yes| G[Check Additional Session Limit]
    F --> H[Confirm Booking]
    H --> I[Update Daily Usage]
    I --> J[End]
    G --> K{Want Additional Session?}
    K -->|No| L[Show Limit Message]
    K -->|Yes| M[Calculate Additional Cost]
    L --> N[End]
    M --> O[Display Cost Information]
    O --> P{Member Accept Cost?}
    P -->|Yes| Q[Process Additional Booking]
    P -->|No| R[Cancel Booking]
    Q --> S[Charge Normal Rate]
    S --> T[Update Daily Usage]
    T --> U[Add to Payment Record]
    U --> V[End]
    R --> W[End]
```

### 3.10 Activity Diagram Private Pool Rental

```mermaid
flowchart TD
    A[Start] --> B[Customer Access Private Pool Booking]
    B --> C[Select Rental Date & Time]
    C --> D[System Check Customer History]
    D --> E{New Customer?}
    E -->|Yes| F[Apply New Customer Bonus]
    E -->|No| G[Calculate Returning Customer Rate]
    F --> H[Standard 1h 30min + 30min Bonus]
    G --> I[Standard 1h 30min + Additional Charges]
    H --> J[Calculate Total Price]
    I --> J
    J --> K[Display Price Breakdown]
    K --> L{Customer Accept Price?}
    L -->|Yes| M[Process Payment]
    L -->|No| N[Cancel Booking]
    M --> O{Payment Successful?}
    O -->|Yes| P[Confirm Booking]
    O -->|No| Q[Show Payment Error]
    P --> R[Update Customer Visit History]
    R --> S[Send Booking Confirmation]
    S --> T[Rental Day Arrives]
    T --> U[Customer Check-in]
    U --> V[Start Rental Timer]
    V --> W[Monitor Usage Time]
    W --> X{Time Expiring Soon?}
    X -->|Yes| Y[Send Time Warning]
    X -->|No| Z{Time Expired?}
    Y --> Z
    Z -->|Yes| AA[End Rental Session]
    Z -->|No| W
    AA --> BB[Customer Check-out]
    BB --> CC[Calculate Actual Usage]
    CC --> DD[Generate Usage Report]
    DD --> EE[Update Customer History]
    EE --> FF[End]
    Q --> GG[Retry Payment]
    GG --> M
    N --> HH[End]
```

### 3.11 Activity Diagram Cafe System with Barcode

```mermaid
flowchart TD
    A[Start] --> B[Customer Arrive at Pool Area]
    B --> C[Locate Menu Barcode/QR Code]
    C --> D[Scan Barcode with Mobile Device]
    D --> E[System Identify Location]
    E --> F[Load Location-Specific Menu]
    F --> G[Display Available Menu Items]
    G --> H[Customer Browse Menu]
    H --> I{Menu Items Available?}
    I -->|Yes| J[Select Menu Item]
    I -->|No| K[Show Out of Stock Items]
    J --> L[Add Item to Cart]
    K --> H
    L --> M[Set Quantity]
    M --> N[Add Special Notes/Requests]
    N --> O[Update Cart Total]
    O --> P{Add More Items?}
    P -->|Yes| H
    P -->|No| Q[Review Cart]
    Q --> R{Cart Correct?}
    R -->|Yes| S[Proceed to Checkout]
    R -->|No| T[Edit Cart Items]
    S --> U[Display Order Summary]
    T --> H
    U --> V[Select Payment Method]
    V --> W{Payment Type?}
    W -->|Manual Transfer| X[Show Transfer Instructions]
    W -->|Online Payment| Y[Process Online Payment]
    X --> Z[Customer Upload Proof]
    Y --> AA{Payment Successful?}
    AA -->|Yes| BB[Generate Order Confirmation]
    AA -->|No| CC[Show Payment Error]
    CC --> V
    Z --> DD[Admin Verify Payment]
    DD --> EE{Payment Valid?}
    EE -->|Yes| BB
    EE -->|No| FF[Request Payment Correction]
    BB --> GG[Send Order to Kitchen]
    FF --> Z
    GG --> HH[Update Order Status: Preparing]
    HH --> II[Kitchen Prepare Food]
    II --> JJ[Update Order Status: Ready]
    JJ --> KK[Staff Deliver Order]
    KK --> LL[Customer Confirm Reception]
    LL --> MM[Update Order Status: Delivered]
    MM --> NN[End]
```

### 3.12 Activity Diagram Dynamic Menu Management

```mermaid
flowchart TD
    A[Start] --> B[Admin Access Menu Management]
    B --> C[Select Menu Action]
    C --> D{Action Type?}
    D -->|Create| E[Create New Menu Item]
    D -->|Update| F[Select Existing Menu]
    D -->|Delete| G[Select Menu to Delete]
    E --> H[Fill Menu Details]
    H --> I[Menu Name & Description]
    I --> J[Upload Menu Image]
    J --> K[Set Base Cost]
    K --> L[Set Selling Price]
    L --> M[Calculate Margin]
    M --> N[Select Menu Category]
    N --> O[Set Dietary Information]
    O --> P[Add Cooking Instructions]
    P --> Q[Set Stock Information]
    Q --> R[Configure Menu Status]
    R --> S[Save Menu Item]
    F --> T[Load Menu Details]
    T --> U[Update Menu Information]
    U --> H
    G --> V[Confirm Deletion]
    V --> W{Confirm Deletion?}
    W -->|Yes| X[Delete Menu Item]
    W -->|No| Y[Cancel Deletion]
    S --> Z[Update Inventory System]
    X --> AA[Remove from Inventory]
    Y --> B
    Z --> BB[Generate Menu Analytics]
    AA --> CC[Update Related Orders]
    BB --> DD[End]
    CC --> DD
```

### 3.13 Activity Diagram Barcode Generation & Download

```mermaid
flowchart TD
    A[Start] --> B[Admin Access Barcode Management]
    B --> C[Select Menu Item]
    C --> D[Choose Barcode Action]
    D --> E{Action Type?}
    E -->|Generate| F[Generate New Barcode]
    E -->|Download| G[Download Existing Barcode]
    E -->|Regenerate| H[Regenerate Barcode]
    F --> I[System Generate Barcode Value]
    I --> J[Create QR Code]
    J --> K[Generate Barcode Image]
    K --> L[Save Barcode Data]
    L --> M[Update Menu Record]
    M --> N[Display Barcode Preview]
    G --> O[Load Barcode Information]
    O --> P[Select Download Format]
    P --> Q{Format Type?}
    Q -->|PNG| R[Generate PNG Barcode]
    Q -->|PDF| S[Generate PDF Barcode]
    Q -->|Bulk Export| T[Select Multiple Menus]
    R --> U[Download PNG File]
    S --> V[Download PDF File]
    T --> W[Generate Bulk Barcode Package]
    V --> X[End]
    U --> X
    W --> Y[Download ZIP Package]
    Y --> X
    H --> Z[Regenerate Barcode Value]
    Z --> I
    N --> AA[Barcode Ready for Use]
    AA --> X
```

### 3.14 Activity Diagram Comprehensive Reporting

```mermaid
flowchart TD
    A[Start] --> B[Admin Access Reporting System]
    B --> C[Select Report Category]
    C --> D{Report Category?}
    D -->|Financial| E[Financial Reports]
    D -->|Operational| F[Operational Reports]
    D -->|Customer| G[Customer Analytics]
    D -->|Inventory| H[Inventory Reports]
    E --> I[Choose Financial Report Type]
    I --> J{Financial Report Type?}
    J -->|Revenue| K[Generate Revenue Report]
    J -->|Expenses| L[Generate Expense Report]
    J -->|Profit & Loss| M[Generate P&L Report]
    J -->|Cash Flow| N[Generate Cash Flow Report]
    J -->|Tax| O[Generate Tax Report]
    F --> P[Choose Operational Report Type]
    P --> Q{Operational Report Type?}
    Q -->|Bookings| R[Generate Booking Analytics]
    Q -->|Sessions| S[Generate Session Reports]
    Q -->|Staff| T[Generate Staff Reports]
    Q -->|Facilities| U[Generate Facility Reports]
    G --> V[Choose Customer Report Type]
    V --> W{Customer Report Type?}
    W -->|Demographics| X[Generate Demographics Report]
    W -->|Behavior| Y[Generate Behavior Analysis]
    W -->|Satisfaction| Z[Generate Satisfaction Report]
    H --> AA[Choose Inventory Report Type]
    AA --> BB{Inventory Report Type?}
    BB -->|Stock Levels| CC[Generate Stock Level Report]
    BB -->|Movement| DD[Generate Stock Movement Report]
    BB -->|Predictions| EE[Generate Stock Prediction Report]
    K --> FF[Configure Report Parameters]
    L --> FF
    M --> FF
    N --> FF
    O --> FF
    R --> FF
    S --> FF
    T --> FF
    U --> FF
    X --> FF
    Y --> FF
    Z --> FF
    CC --> FF
    DD --> FF
    EE --> FF
    FF --> GG[Set Date Range]
    GG --> HH[Select Export Format]
    HH --> II{Export Format?}
    II -->|PDF| JJ[Generate PDF Report]
    II -->|Excel| KK[Generate Excel Report]
    II -->|CSV| LL[Generate CSV Report]
    JJ --> MM[Download Report]
    KK --> MM
    LL --> MM
    MM --> NN[Save Report History]
    NN --> OO[Schedule Future Report]
    OO --> PP[End]
```

## 4. Sequence Diagram

### 4.1 Sequence Diagram Member Registration

```mermaid
sequenceDiagram
    participant U as User
    participant S as System
    participant A as Admin
    participant DB as Database
    participant E as Email/SMS

    U->>S: Access Registration Page
    S->>U: Display Registration Form

    U->>S: Fill Registration Form
    S->>DB: Validate User Data
    DB->>S: Validation Results

    U->>S: Upload Documents
    S->>DB: Save Documents
    DB->>S: Document URLs

    U->>S: Choose Package
    S->>DB: Get Package Details
    DB->>S: Package Information

    U->>S: Submit Registration
    S->>DB: Create Temporary Account
    DB->>S: Account Created

    S->>A: Notify Admin: New Registration
    A->>S: Access Admin Panel

    A->>S: Review Documents
    S->>DB: Get User Documents
    DB->>S: Document Data

    A->>S: Approve/Reject Registration
    alt Registration Approved
        S->>DB: Activate User Account
        DB->>S: Account Activated
        S->>DB: Generate Member Card
        DB->>S: Member Card Data
        S->>E: Send Welcome Email/SMS
        E->>U: Welcome Message
    else Registration Rejected
        S->>E: Send Rejection Notice
        E->>U: Rejection Details
    end
```

### 4.2 Sequence Diagram Booking Process

```mermaid
sequenceDiagram
    participant U as User
    participant S as System
    participant C as Calendar
    participant P as Payment
    participant DB as Database
    participant E as Email/SMS

    U->>S: Access Booking Page
    S->>C: Load Calendar Interface
    C->>S: Current Month Data

    U->>C: Navigate to Future Month
    C->>S: Future Month Data
    S->>U: Display Calendar

    U->>S: Select Available Date
    S->>DB: Get Session Availability
    DB->>S: Session Data

    S->>U: Display Session Options
    U->>S: Select Session
    S->>DB: Check Session Capacity
    DB->>S: Capacity Status

    U->>S: Choose User Type (Member/Guest)
    alt Member User
        U->>S: Login to Account
        S->>DB: Validate Credentials
        DB->>S: User Profile
    else Guest User
        U->>S: Fill Guest Form
        S->>DB: Create Guest Record
        DB->>S: Guest ID
    end

    S->>DB: Calculate Total Cost
    DB->>S: Pricing Information
    S->>U: Display Booking Summary

    U->>S: Confirm Booking
    S->>P: Initiate Payment Process

    alt Manual Payment
        P->>S: Show Transfer Instructions
        S->>U: Payment Instructions
        U->>S: Upload Payment Proof
        S->>DB: Save Payment Proof
        DB->>S: Proof Saved

        S->>A: Notify Admin: Payment Pending

        A->>S: Verify Payment
        S->>DB: Update Payment Status
        DB->>S: Status Updated
    else Online Payment
        P->>S: Process Online Payment
        S->>DB: Save Payment Record
        DB->>S: Payment Confirmed
    end

    S->>DB: Create Booking Record
    DB->>S: Booking Confirmed
    S->>DB: Generate QR Code
    DB->>S: QR Code Data

    S->>E: Send Confirmation
    E->>U: Booking Confirmation
    S->>U: Display Booking Details
```

### 4.3 Sequence Diagram Cafe Order Process

```mermaid
sequenceDiagram
    participant C as Customer
    participant B as Barcode Scanner
    participant S as System
    participant M as Menu
    participant P as Payment
    participant K as Kitchen
    participant DB as Database

    C->>B: Scan Menu Barcode
    B->>S: Barcode Data
    S->>DB: Get Menu by Location
    DB->>S: Menu Items
    S->>M: Load Menu Interface

    C->>M: Browse Menu Items
    M->>S: Get Available Items
    S->>DB: Check Stock Levels
    DB->>S: Availability Data
    S->>M: Display Available Items

    C->>M: Select Menu Item
    M->>S: Add Item to Cart
    S->>DB: Update Cart
    DB->>S: Cart Updated

    C->>M: Add Special Notes
    M->>S: Save Notes
    S->>DB: Store Notes
    DB->>S: Notes Saved

    C->>M: Complete Order
    M->>S: Submit Order
    S->>P: Process Payment

    P->>S: Payment Success
    S->>DB: Create Order Record
    DB->>S: Order Created

    S->>K: Send Order to Kitchen
    K->>S: Order Received

    K->>S: Update Status: Preparing
    S->>DB: Update Order Status
    DB->>S: Status Updated

    K->>S: Update Status: Ready
    S->>C: Notify Customer: Order Ready

    C->>S: Confirm Order Reception
    S->>DB: Update Status: Delivered
    DB->>S: Order Completed
```

### 4.4 Sequence Diagram Rating System

```mermaid
sequenceDiagram
    participant U as User
    participant S as System
    participant R as Rating Module
    participant A as Analytics
    participant DB as Database

    U->>S: Complete Service/Order
    S->>U: Request Rating

    U->>S: Access Rating Page
    S->>R: Load Rating Interface
    R->>U: Display Rating Form

    U->>R: Submit Overall Rating
    U->>R: Rate Individual Components
    U->>R: Add Comments
    R->>S: Submit Rating Data

    S->>DB: Validate Rating Data
    DB->>S: Validation Results

    S->>DB: Save Rating
    DB->>S: Rating Saved

    S->>A: Update Analytics
    A->>DB: Calculate Average Ratings
    DB->>A: Rating Calculations
    A->>DB: Update Analytics Tables

    S->>U: Send Thank You Message
    S->>DB: Generate Rating Summary
    DB->>S: Summary Data
```

### 4.5 Sequence Diagram Check-in Process

```mermaid
sequenceDiagram
    participant C as Customer
    participant S as Staff
    participant SYS as System
    participant DB as Database
    participant E as Equipment

    C->>S: Present Booking Reference
    S->>SYS: Enter/Scan Reference
    SYS->>DB: Validate Booking
    DB->>SYS: Booking Data

    SYS->>S: Display Booking Details
    S->>C: Verify Identity

    S->>SYS: Process Check-in
    SYS->>DB: Update Booking Status
    DB->>SYS: Status Updated

    SYS->>E: Request Equipment
    E->>S: Issue Equipment
    S->>DB: Record Check-in Time
    DB->>SYS: Time Recorded

    SYS->>C: Confirm Check-in
    SYS->>C: Provide Equipment

    Note over C,SYS: Pool Usage Time

    C->>S: Request Check-out
    S->>E: Collect Equipment
    S->>SYS: Process Check-out
    SYS->>DB: Record Check-out Time
    DB->>SYS: Time Recorded

    SYS->>DB: Generate Usage Report
    DB->>SYS: Report Data
    SYS->>C: Confirm Check-out
```

### 4.6 Sequence Diagram Manual Payment System

```mermaid
sequenceDiagram
    participant U as User
    participant S as System
    participant A as Admin
    participant B as Bank System
    participant DB as Database

    U->>S: Select Manual Payment
    S->>U: Display Payment Instructions
    S->>B: Get Bank Account Details
    B->>S: Account Information
    S->>U: Show Transfer Details

    U->>B: Make Bank Transfer
    B->>U: Transfer Confirmation
    U->>S: Upload Payment Proof
    S->>DB: Save Payment Proof
    DB->>S: Proof Saved

    S->>A: Notify Admin: Payment Received
    A->>S: Access Payment Verification

    A->>S: Review Payment Proof
    S->>DB: Get Payment Data
    DB->>S: Payment Information

    A->>S: Verify Payment Details
    S->>DB: Update Payment Status
    DB->>S: Status Updated

    alt Payment Verified
        S->>DB: Process Booking/Purchase
        DB->>S: Transaction Completed
        S->>U: Send Confirmation
    else Payment Rejected
        S->>U: Send Rejection Notice
        S->>DB: Mark for Correction
        DB->>S: Correction Required
    end
```

### 4.7 Sequence Diagram Dynamic Menu Management

```mermaid
sequenceDiagram
    participant A as Admin
    participant S as System
    participant M as Menu Manager
    participant I as Inventory
    participant DB as Database

    A->>S: Access Menu Management
    S->>M: Load Menu Interface
    M->>DB: Get Existing Menus
    DB->>M: Menu Data
    M->>A: Display Menu List

    A->>M: Create New Menu Item
    M->>A: Display Menu Form

    A->>M: Fill Menu Details
    M->>S: Validate Menu Data
    S->>M: Validation Results

    A->>M: Set Pricing Information
    M->>S: Calculate Margin
    S->>M: Margin Calculations

    A->>M: Upload Menu Image
    M->>S: Process Image
    S->>DB: Save Image
    DB->>S: Image URL

    A->>M: Save Menu Item
    M->>DB: Create Menu Record
    DB->>M: Menu Created

    M->>I: Update Inventory System
    I->>DB: Create Inventory Record
    DB->>I: Inventory Created

    M->>S: Generate Menu Analytics
    S->>DB: Update Analytics
    DB->>S: Analytics Updated

    M->>A: Confirm Menu Created
```

### 4.8 Sequence Diagram Barcode Generation & Download

```mermaid
sequenceDiagram
    participant A as Admin
    participant S as System
    participant B as Barcode Generator
    participant DB as Database
    participant F as File System

    A->>S: Access Barcode Management
    S->>DB: Get Menu Items
    DB->>S: Menu Data
    S->>A: Display Menu List

    A->>S: Select Menu for Barcode
    S->>B: Generate Barcode Value
    B->>S: Barcode Value

    S->>B: Create QR Code
    B->>S: QR Code Data

    S->>B: Generate Barcode Image
    B->>F: Save Barcode Image
    F->>B: Image URL

    S->>DB: Update Menu with Barcode
    DB->>S: Menu Updated

    S->>A: Display Barcode Preview

    A->>S: Download Barcode
    S->>F: Get Barcode Files
    F->>S: File Data
    S->>A: Provide Download Link

    A->>S: Bulk Export Request
    S->>DB: Get Multiple Menus
    DB->>S: Menu List

    S->>B: Generate Bulk Barcodes
    B->>F: Create ZIP Package
    F->>S: Package URL
    S->>A: Provide Bulk Download
```

### 4.9 Sequence Diagram Comprehensive Reporting System

```mermaid
sequenceDiagram
    participant A as Admin
    participant S as System
    participant R as Report Generator
    participant DB as Database
    participant F as File Exporter

    A->>S: Access Reporting System
    S->>A: Display Report Categories

    A->>S: Select Report Type
    S->>R: Initialize Report Generation
    R->>DB: Query Report Data

    alt Financial Reports
        R->>DB: Get Financial Data
        DB->>R: Revenue, Expenses, Profit Data
    else Operational Reports
        R->>DB: Get Operational Data
        DB->>R: Bookings, Sessions, Staff Data
    else Customer Reports
        R->>DB: Get Customer Data
        DB->>R: Demographics, Behavior Data
    end

    R->>S: Process Report Data
    S->>R: Format Report

    A->>S: Request Export
    S->>F: Export Report

    F->>S: Generate Export File
    S->>A: Provide Download Link

    A->>S: Schedule Report
    S->>DB: Save Schedule
    DB->>S: Schedule Saved

    S->>A: Confirm Report Actions
```
