# Diagram Class - Sistem Kolam Renang Syariah

## 1. Diagram Class Utama

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

## 2. Diagram Class Sistem Kafe

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

## 3. Diagram Class Sistem Rating & Review

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

## 4. Diagram Class Sistem Promosi

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

## 5. Diagram Class Sistem Pembayaran Manual

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

## 6. Diagram Class Manajemen Kuota Member Dinamis

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

## 7. Diagram Class Batas Harian Berenang Member

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

## 8. Diagram Class Sistem Sewa Kolam Privat

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

## 9. Diagram Class Sistem Barcode

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

## 10. Diagram Class Sistem Pelaporan Komprehensif

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

## 11. Diagram Class Integrasi Sistem

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
