# Analisa Domain dan Bisnis - Sistem Kolam Renang Syariah

## 1. Model Bisnis

### 1.1 Revenue Streams

```mermaid
graph TD
    subgraph "Revenue Streams"
        A[Membership Fees]
        B[Regular Session Fees]
        C[Private Session Fees]
        D[Cafe Sales]
        E[Additional Services]
    end

    subgraph "Pricing Model"
        P1[Dynamic Pricing System]
        P2[Configurable Rates]
        P3[Time-based Pricing]
        P4[Package-based Pricing]
        P5[Seasonal Pricing]
    end
```

### 1.2 Dynamic Pricing Configuration

```mermaid
graph LR
    subgraph "Pricing Configuration"
        A[System Configuration]
        B[Pricing Rules]
        C[Rate Cards]
        D[Seasonal Adjustments]
    end

    subgraph "Pricing Components"
        P1[Base Rates]
        P2[Adjustments]
        P3[Discounts]
        P4[Taxes & Fees]
    end

    subgraph "Pricing Flexibility"
        F1[Admin Control]
        F2[Scheduled Changes]
        F3[Promotional Pricing]
        F4[Member Pricing]
    end
```

## 2. Dynamic Pricing Structure

### 2.1 Configurable Pricing Categories

```json
{
  "pricing_configuration": {
    "membership_packages": {
      "monthly": {
        "base_price": "configurable",
        "duration_days": 30,
        "max_adults": 3,
        "max_children": 2,
        "description": "Monthly membership package"
      },
      "quarterly": {
        "base_price": "configurable",
        "duration_days": 90,
        "max_adults": 3,
        "max_children": 2,
        "discount_percentage": "configurable",
        "description": "Quarterly membership package with discount"
      }
    },
    "session_types": {
      "regular_weekday": {
        "adult_price": "configurable",
        "child_price": "configurable",
        "description": "Regular session on weekdays"
      },
      "regular_weekend": {
        "adult_price": "configurable",
        "child_price": "configurable",
        "description": "Regular session on weekends"
      }
    },
    "private_packages": {
      "silver": {
        "base_price": "configurable",
        "duration_hours": 1.5,
        "max_adults": 5,
        "max_children": 5,
        "description": "Private session silver package"
      },
      "gold": {
        "base_price": "configurable",
        "duration_hours": 3,
        "max_adults": 10,
        "max_children": 10,
        "description": "Private session gold package"
      }
    }
  }
}
```

### 2.2 Pricing Rules Engine

```mermaid
graph TD
    A[Pricing Request] --> B[Rule Engine]
    B --> C{Check Rules}
    C -->|Time-based| D[Apply Time Rules]
    C -->|Seasonal| E[Apply Seasonal Rules]
    C -->|Member| F[Apply Member Rules]
    C -->|Promotional| G[Apply Promo Rules]

    D --> H[Calculate Final Price]
    E --> H
    F --> H
    G --> H

    H --> I[Return Price]

    subgraph "Rule Types"
        R1[Time-based Pricing]
        R2[Seasonal Adjustments]
        R3[Member Discounts]
        R4[Promotional Pricing]
        R5[Package Pricing]
    end
```

## 3. Business Processes

### 3.1 Dynamic Pricing Management Process

```mermaid
graph TD
    A[Pricing Review] --> B[Market Analysis]
    B --> C[Competitor Benchmarking]
    C --> D[Cost Analysis]
    D --> E[Profit Margin Calculation]
    E --> F[Pricing Strategy]
    F --> G[Admin Approval]
    G --> H[Update Configuration]
    H --> I[Apply to System]
    I --> J[Notify Stakeholders]

    subgraph "Pricing Updates"
        U1[Scheduled Updates]
        U2[Emergency Changes]
        U3[Promotional Pricing]
        U4[Seasonal Adjustments]
    end
```

### 3.2 Revenue Optimization Process

```mermaid
graph TD
    A[Revenue Analysis] --> B[Identify Opportunities]
    B --> C[Pricing Optimization]
    C --> D[Capacity Management]
    D --> E[Demand Forecasting]
    E --> F[Pricing Adjustments]
    F --> G[Monitor Performance]
    G --> H[Iterate Strategy]

    subgraph "Optimization Factors"
        O1[Demand Patterns]
        O2[Competition]
        O3[Cost Changes]
        O4[Seasonal Trends]
        O5[Member Behavior]
    end
```

## 4. Business Rules and Constraints

### 4.1 Pricing Business Rules

```mermaid
graph TD
    subgraph "Static Business Rules"
        A1[Capacity Limits: 20 orang/hari]
        A2[Member Quota: 100 member aktif]
        A3[Jadwal: 2 sesi/hari, libur Jumat]
        A4[Private: Bergantian pagi/siang, libur Minggu]
        A5[Document Requirements: KTP/KK]
        A6[Age Requirements: Minimum 5 tahun]
    end

    subgraph "Dynamic Pricing Rules"
        B1[Base Prices: Configurable via admin]
        B2[Discounts: Flexible percentage]
        B3[Seasonal Rates: Time-based adjustments]
        B4[Member Rates: Tiered pricing]
        B5[Package Pricing: Bundled discounts]
        B6[Promotional Pricing: Limited time offers]
    end
```

### 4.2 Configuration Management Rules

| Rule Category        | Description             | Change Frequency   | Approval Required |
| -------------------- | ----------------------- | ------------------ | ----------------- |
| Base Pricing         | Core rates for services | Quarterly/Annually | Owner/Manager     |
| Seasonal Adjustments | Peak/off-peak pricing   | Monthly            | Manager           |
| Promotional Pricing  | Special offers          | As needed          | Manager           |
| Package Pricing      | Membership bundles      | Quarterly          | Owner             |
| Discount Rules       | Percentage discounts    | Monthly            | Manager           |
| Tax Configuration    | Tax rates and rules     | As per regulation  | Legal             |

### 4.3 Operational Constraints

```mermaid
graph TD
    subgraph "Fixed Constraints"
        A[Pool Capacity: 20 max/day]
        B[Member Limit: 100 active]
        C[Session Duration: 2.5 hours]
        D[Operating Hours: Configurable]
        E[Holiday Schedule: Configurable]
    end

    subgraph "Flexible Constraints"
        F[Pricing: Fully configurable]
        G[Packages: Dynamic creation]
        H[Discounts: Rule-based]
        I[Payment Methods: Extensible]
        J[Booking Rules: Configurable]
    end
```

## 5. Dynamic Configuration System

### 5.1 Configuration Management

```mermaid
graph TD
    A[Admin Interface] --> B[Configuration Panel]
    B --> C[Pricing Management]
    B --> D[Package Management]
    B --> E[Rule Management]
    B --> F[Schedule Management]

    C --> G[Update Prices]
    D --> H[Create/Edit Packages]
    E --> I[Define Rules]
    F --> J[Set Schedules]

    subgraph "Configuration Types"
        T1[Immediate Changes]
        T2[Scheduled Changes]
        T3[Temporary Overrides]
        T4[Conditional Rules]
    end
```

### 5.2 Pricing Configuration Interface

```json
{
  "pricing_interface": {
    "base_pricing": {
      "regular_sessions": {
        "weekday_adult": "configurable_field",
        "weekday_child": "configurable_field",
        "weekend_adult": "configurable_field",
        "weekend_child": "configurable_field"
      },
      "private_sessions": {
        "silver_base": "configurable_field",
        "gold_base": "configurable_field"
      },
      "membership_packages": {
        "monthly_base": "configurable_field",
        "quarterly_base": "configurable_field",
        "quarterly_discount": "configurable_field"
      }
    },
    "adjustments": {
      "seasonal_rates": "configurable_percentage",
      "member_discounts": "configurable_percentage",
      "promotional_rates": "configurable_percentage"
    },
    "rules": {
      "minimum_booking": "configurable_value",
      "cancellation_policy": "configurable_hours",
      "payment_terms": "configurable_days"
    }
  }
}
```

## 6. Revenue Tracking and Analytics

### 6.1 Dynamic Revenue Metrics

```mermaid
graph TD
    A[Revenue Data] --> B[Pricing Analytics]
    B --> C[Performance Analysis]
    C --> D[Optimization Recommendations]
    D --> E[Pricing Adjustments]

    subgraph "Analytics Metrics"
        M1[Revenue by Pricing Tier]
        M2[Optimal Pricing Points]
        M3[Seasonal Performance]
        M4[Member vs Non-member Revenue]
        M5[Package Performance]
        M6[Price Elasticity]
    end
```

### 6.2 Pricing Performance Dashboard

| Metric                      | Description                        | Update Frequency | Action Trigger        |
| --------------------------- | ---------------------------------- | ---------------- | --------------------- |
| Average Revenue per Session | Total revenue / Number of sessions | Daily            | < Target threshold    |
| Member Utilization Rate     | Active members / Total capacity    | Weekly           | < 80% utilization     |
| Price Elasticity            | Revenue change / Price change      | Monthly          | Elastic > -1          |
| Competitive Position        | Price vs competitors               | Quarterly        | Higher than market    |
| Seasonal Trends             | Revenue patterns by season         | Monthly          | Significant deviation |

## 7. Implementation Guidelines

### 7.1 Configuration Database Design

```sql
-- Pricing configuration tables
CREATE TABLE pricing_config (
    config_id INT PRIMARY KEY AUTO_INCREMENT,
    config_name VARCHAR(100) NOT NULL,
    config_value DECIMAL(10,2) NOT NULL,
    config_type ENUM('base_price', 'discount', 'adjustment', 'rule') NOT NULL,
    category VARCHAR(50) NOT NULL,
    effective_date DATE NOT NULL,
    expiry_date DATE NULL,
    created_by INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

CREATE TABLE pricing_rules (
    rule_id INT PRIMARY KEY AUTO_INCREMENT,
    rule_name VARCHAR(100) NOT NULL,
    rule_type ENUM('time_based', 'seasonal', 'member', 'promotional') NOT NULL,
    rule_condition JSON NOT NULL,
    rule_action JSON NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    priority INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### 7.2 Pricing API Endpoints

```javascript
// Pricing configuration endpoints
GET /api/pricing/config - Get current pricing configuration
PUT /api/pricing/config - Update pricing configuration
POST /api/pricing/calculate - Calculate price for booking
GET /api/pricing/history - Get pricing change history

// Example pricing calculation
POST /api/pricing/calculate
{
  "session_type": "regular",
  "date": "2025-09-30",
  "time": "morning",
  "adult_count": 2,
  "child_count": 1,
  "member_id": "M001"
}

Response:
{
  "base_price": 65000,
  "member_discount": 5000,
  "seasonal_adjustment": 0,
  "final_price": 60000,
  "breakdown": {...}
}
```

## 8. Change Management Process

### 8.1 Pricing Change Workflow

```mermaid
graph TD
    A[Pricing Change Request] --> B[Impact Analysis]
    B --> C[Revenue Impact Assessment]
    C --> D[Stakeholder Approval]
    D --> E[Implementation Planning]
    E --> F[System Update]
    F --> G[Testing & Validation]
    G --> H[Deployment]
    H --> I[Monitoring & Feedback]

    subgraph "Approval Levels"
        L1[Minor Changes: Manager]
        L2[Major Changes: Owner]
        L3[Strategic Changes: Board]
    end
```

### 8.2 Communication Plan

| Change Type          | Communication Channel       | Audience            | Timeline       |
| -------------------- | --------------------------- | ------------------- | -------------- |
| Base Price Changes   | Email + SMS                 | All members         | 2 weeks notice |
| Promotional Pricing  | Social media + App          | Potential customers | 1 week notice  |
| Package Changes      | Email + In-app notification | Active members      | 1 month notice |
| Seasonal Adjustments | Website + App               | All users           | 2 weeks notice |

---

**Versi**: 1.3  
**Tanggal**: 26 Agustus 2025  
**Status**: Complete dengan Dynamic Pricing, Guest Booking, Google SSO, Mobile-First Web App, Core Booking Flow, Manual Payment, Dynamic Member Quota & Member Daily Swimming Limit  
**Berdasarkan**: PDF Raujan Pool Syariah
