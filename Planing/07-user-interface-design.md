# User Interface Design - Sistem Kolam Renang Syariah

## 1. Design System

### 1.1 Color Palette

```mermaid
graph LR
    subgraph "Primary Colors"
        C1[#2563EB - Primary Blue]
        C2[#1E40AF - Dark Blue]
        C3[#3B82F6 - Light Blue]
    end

    subgraph "Secondary Colors"
        C4[#059669 - Primary Green]
        C5[#047857 - Dark Green]
        C6[#10B981 - Light Green]
    end

    subgraph "Accent Colors"
        C7[#F59E0B - Orange]
        C8[#DC2626 - Red]
        C9[#8B5CF6 - Purple]
    end

    subgraph "Neutral Colors"
        C10[#1F2937 - Dark Gray]
        C11[#6B7280 - Medium Gray]
        C12[#F3F4F6 - Light Gray]
        C13[#FFFFFF - White]
    end
```

### 1.2 Typography

```css
/* Primary Font - Inter */
font-family: 'Inter', sans-serif;

/* Heading Sizes */
h1: 32px, font-weight: 700
h2: 28px, font-weight: 600
h3: 24px, font-weight: 600
h4: 20px, font-weight: 500
h5: 18px, font-weight: 500
h6: 16px, font-weight: 500

/* Body Text */
body: 16px, font-weight: 400
small: 14px, font-weight: 400
caption: 12px, font-weight: 400
```

### 1.3 Component Library

```mermaid
graph TD
    subgraph "Basic Components"
        B1[Button - Primary]
        B2[Button - Secondary]
        B3[Button - Outline]
        B4[Input Field]
        B5[Select Dropdown]
        B6[Checkbox]
        B7[Radio Button]
        B8[Modal]
        B9[Card]
        B10[Badge]
    end

    subgraph "Navigation"
        N1[Header]
        N2[Sidebar]
        N3[Breadcrumb]
        N4[Pagination]
        N5[Tabs]
    end

    subgraph "Data Display"
        D1[Table]
        D2[Data Grid]
        D3[Chart]
        D4[Progress Bar]
        D5[Calendar]
        D6[Timeline]
    end

    subgraph "Feedback"
        F1[Alert]
        F2[Toast]
        F3[Loading Spinner]
        F4[Empty State]
        F5[Error State]
    end
```

## 2. Calendar Interface Design

### 2.1 Main Calendar Component

```mermaid
graph TD
    A[Calendar Page] --> B[Header Section]
    A --> C[Navigation Section]
    A --> D[Calendar Grid]
    A --> E[Footer Section]

    B --> F[Pool Logo & Title]
    B --> G[Current Month/Year Display]
    B --> H[Booking Status Legend]

    C --> I[Previous Month Button]
    C --> J[Next Month Button]
    C --> K[Year Dropdown]

    D --> L[Day Headers]
    D --> M[Date Cells]
    D --> N[Status Indicators]

    subgraph "Calendar Header"
        CH1[Pool Branding]
        CH2[Month/Year Display]
        CH3[Legenda Status]
    end

    subgraph "Navigation Controls"
        NC1[Previous Button - Disabled for Past]
        NC2[Current Month Highlight]
        NC3[Next Button - Always Enabled]
        NC4[Year Selector - Forward Only]
    end

    subgraph "Calendar Grid"
        CG1[Day Headers: Sun-Sat]
        CG2[Date Cells with Status]
        CG3[Clickable Date Areas]
        CG4[Status Color Coding]
    end
```

### 2.2 Mobile-First Calendar Design

```json
{
  "calendar_layout": {
    "mobile_breakpoint": "320px - 767px",
    "tablet_breakpoint": "768px - 1023px",
    "desktop_breakpoint": "1024px+",
    "responsive_features": {
      "mobile": {
        "grid_layout": "7 columns, compact spacing",
        "date_cells": "44px x 44px minimum touch target",
        "navigation": "Swipe gestures + button controls",
        "modal_sessions": "Full-screen session selection"
      },
      "tablet": {
        "grid_layout": "7 columns, comfortable spacing",
        "date_cells": "60px x 60px touch targets",
        "navigation": "Button controls + keyboard shortcuts",
        "modal_sessions": "Overlay modal for session selection"
      },
      "desktop": {
        "grid_layout": "7 columns, spacious layout",
        "date_cells": "80px x 80px hover states",
        "navigation": "Button controls + keyboard shortcuts",
        "modal_sessions": "Sidebar or modal for sessions"
      }
    }
  },
  "status_indicators": {
    "available": {
      "color": "#10B981",
      "icon": "circle-check",
      "label": "Available"
    },
    "partial_available": {
      "color": "#F59E0B",
      "icon": "clock",
      "label": "Limited Slots"
    },
    "fully_booked": {
      "color": "#EF4444",
      "icon": "x-circle",
      "label": "Full"
    },
    "closed": {
      "color": "#6B7280",
      "icon": "lock-closed",
      "label": "Closed"
    }
  }
}
```

### 2.3 Session Selection Modal

```mermaid
graph TD
    A[Date Clicked] --> B[Session Modal Opens]
    B --> C[Modal Header]
    B --> D[Session Options]
    B --> E[Capacity Display]
    B --> F[Action Buttons]

    C --> G[Selected Date Display]
    C --> H[Close Button]

    D --> I[Morning Session Card]
    D --> J[Afternoon Session Card]

    I --> K[Session Time: 06:00-12:00]
    I --> L[Capacity: 10 Adults + 10 Children]
    I --> M[Current Bookings Display]
    I --> N[Available Slots]
    I --> O[Select Button]

    J --> P[Session Time: 13:00-19:00]
    J --> Q[Capacity: 10 Adults + 10 Children]
    J --> R[Current Bookings Display]
    J --> S[Available Slots]
    J --> T[Select Button]

    E --> U[Total Daily Capacity]
    E --> V[Remaining Slots]
    E --> W[Booking Statistics]

    F --> X[Cancel Button]
    F --> Y[Proceed to Registration]

    subgraph "Session Card Design"
        SC1[Session Time Header]
        SC2[Capacity Information]
        SC3[Current Bookings Count]
        SC4[Available Slots Display]
        SC5[Price Information]
        SC6[Action Button State]
    end

    subgraph "Modal Features"
        MF1[Responsive Design]
        MF2[Touch-Friendly Buttons]
        MF3[Real-time Updates]
        MF4[Loading States]
        MF5[Error Handling]
    end
```

### 2.4 User Registration Form

```mermaid
graph TD
    A[Session Selected] --> B[Registration Form Modal]
    B --> C[Form Header]
    B --> D[User Type Selection]
    B --> E[Form Fields]
    B --> F[Terms & Conditions]
    B --> G[Submit Button]

    D --> H[Guest User]
    D --> I[Existing Member]
    D --> J[New Member]

    H --> K[Quick Guest Form]
    K --> L[Full Name]
    K --> M[Phone Number]
    K --> N[Email Address]
    K --> O[Emergency Contact]

    I --> P[Member Login]
    P --> Q[Email/Password]
    P --> R[Google SSO Button]

    J --> S[Registration Options]
    S --> T[Manual Registration]
    S --> U[Google SSO Registration]

    F --> V[Terms Checkbox]
    F --> W[Privacy Policy Checkbox]

    subgraph "Form Validation"
        FV1[Real-time Field Validation]
        FV2[Required Field Indicators]
        FV3[Error Message Display]
        FV4[Success States]
    end

    subgraph "User Experience"
        UE1[Auto-focus First Field]
        UE2[Progress Indicators]
        UE3[Form Persistence]
        UE4[Mobile Keyboard Optimization]
    end
```

### 2.5 Booking Confirmation Screen

```mermaid
graph TD
    A[Booking Success] --> B[Confirmation Page]
    B --> C[Success Message]
    B --> D[Booking Details]
    B --> E[QR Code Display]
    B --> F[Proof Documents]
    B --> G[Action Buttons]

    C --> H[Booking Confirmed Icon]
    C --> I[Reference Number]
    C --> J[Confirmation Message]

    D --> K[Booking Date & Time]
    D --> K1[Session Details]
    D --> K2[User Information]
    D --> K3[Price Information]

    E --> L[QR Code Image]
    E --> M[QR Code Instructions]
    E --> N[Download QR Code]

    F --> O[Email Receipt Link]
    F --> P[SMS Confirmation Status]
    F --> Q[Download Receipt PDF]

    G --> R[Add to Calendar]
    G --> S[Share Booking]
    G --> T[Return to Home]
    G --> U[Book Another Session]

    subgraph "Confirmation Features"
        CF1[Animated Success Icon]
        CF2[Large QR Code Display]
        CF3[Downloadable Documents]
        CF4[Social Sharing Options]
        CF5[Calendar Integration]
    end

    subgraph "Mobile Optimization"
        MO1[Large Touch Targets]
        MO2[Easy QR Code Scanning]
        MO3[Quick Share Options]
        MO4[Offline Access to QR]
    end
```

### 2.6 Progressive Web App Features

```json
{
  "pwa_features": {
    "app_manifest": {
      "name": "Raujan Pool Booking",
      "short_name": "Raujan Pool",
      "description": "Book your swimming session at Raujan Pool Syariah",
      "theme_color": "#2563EB",
      "background_color": "#FFFFFF",
      "display": "standalone",
      "orientation": "portrait",
      "icons": [
        {
          "src": "/icons/icon-192x192.png",
          "sizes": "192x192",
          "type": "image/png"
        },
        {
          "src": "/icons/icon-512x512.png",
          "sizes": "512x512",
          "type": "image/png"
        }
      ]
    },
    "service_worker": {
      "caching_strategy": "Cache First for static assets",
      "offline_booking": "Cache booking form for offline use",
      "push_notifications": "Firebase Cloud Messaging integration",
      "background_sync": "Sync offline bookings when online"
    },
    "mobile_features": {
      "touch_gestures": "Swipe navigation for calendar",
      "haptic_feedback": "Vibration on successful booking",
      "fullscreen_mode": "Hide browser UI for app-like experience",
      "install_prompt": "Add to home screen prompt"
    }
  }
}
```

### 2.7 Responsive Design System

```json
{
  "design_system": {
    "color_palette": {
      "primary": {
        "main": "#2563EB",
        "light": "#3B82F6",
        "dark": "#1D4ED8",
        "contrast": "#FFFFFF"
      },
      "success": {
        "main": "#10B981",
        "light": "#34D399",
        "dark": "#059669"
      },
      "warning": {
        "main": "#F59E0B",
        "light": "#FBBF24",
        "dark": "#D97706"
      },
      "error": {
        "main": "#EF4444",
        "light": "#F87171",
        "dark": "#DC2626"
      },
      "neutral": {
        "main": "#6B7280",
        "light": "#9CA3AF",
        "dark": "#374151"
      }
    },
    "typography": {
      "font_family": "'Inter', system-ui, sans-serif",
      "font_sizes": {
        "xs": "0.75rem",
        "sm": "0.875rem",
        "base": "1rem",
        "lg": "1.125rem",
        "xl": "1.25rem",
        "2xl": "1.5rem",
        "3xl": "1.875rem"
      },
      "line_heights": {
        "tight": "1.25",
        "normal": "1.5",
        "relaxed": "1.75"
      }
    },
    "spacing": {
      "xs": "0.25rem",
      "sm": "0.5rem",
      "md": "1rem",
      "lg": "1.5rem",
      "xl": "2rem",
      "2xl": "3rem"
    },
    "border_radius": {
      "sm": "0.25rem",
      "md": "0.375rem",
      "lg": "0.5rem",
      "xl": "0.75rem",
      "full": "9999px"
    }
  }
}
```

### 2.8 Loading States and Animations

```json
{
  "loading_states": {
    "calendar_loading": {
      "skeleton": "Calendar grid skeleton with shimmer",
      "duration": "0.5s",
      "message": "Loading availability..."
    },
    "session_checking": {
      "spinner": "Small loading spinner in session card",
      "duration": "1-2s",
      "message": "Checking availability..."
    },
    "booking_processing": {
      "progress_bar": "Animated progress bar",
      "duration": "3-5s",
      "message": "Processing your booking..."
    }
  },
  "animations": {
    "calendar_transition": {
      "type": "slide",
      "duration": "300ms",
      "easing": "ease-in-out"
    },
    "modal_open": {
      "type": "fade + scale",
      "duration": "250ms",
      "easing": "ease-out"
    },
    "success_feedback": {
      "type": "bounce + fade",
      "duration": "500ms",
      "easing": "cubic-bezier(0.68, -0.55, 0.265, 1.55)"
    }
  }
}
```

### 2.9 Accessibility Features

```json
{
  "accessibility": {
    "keyboard_navigation": {
      "calendar_navigation": "Arrow keys for month navigation",
      "date_selection": "Enter/Space for date selection",
      "modal_interaction": "Tab navigation and Escape to close"
    },
    "screen_reader": {
      "calendar_announcements": "Announce date status changes",
      "session_information": "Read session details and availability",
      "booking_confirmation": "Announce booking success and reference"
    },
    "visual_indicators": {
      "focus_states": "Clear focus indicators for all interactive elements",
      "high_contrast": "High contrast mode support",
      "color_blind_friendly": "Status indicators with both color and shape"
    },
    "mobile_accessibility": {
      "touch_targets": "Minimum 44px touch targets",
      "voice_control": "Voice control compatibility",
      "magnification": "Support for iOS and Android magnification"
    }
  }
}
```

## 3. Web Application Design

### 3.1 Admin Dashboard Layout

```mermaid
graph TB
    subgraph "Header"
        H1[Logo]
        H2[Search Bar]
        H3[Notifications]
        H4[User Profile]
    end

    subgraph "Sidebar Navigation"
        S1[Dashboard]
        S2[Member Management]
        S3[Booking Management]
        S4[Cafe Management]
        S5[Reports]
        S6[Settings]
    end

    subgraph "Main Content Area"
        M1[Quick Stats Cards]
        M2[Recent Activities]
        M3[Charts & Analytics]
        M4[Data Tables]
    end
```

### 3.2 Key Admin Screens

#### 3.2.1 Member Management

```mermaid
graph TD
    A[Member List] --> B[Search & Filter]
    B --> C[Member Details]
    C --> D[Edit Member]
    C --> E[View History]
    C --> F[Renew Membership]

    subgraph "Member List Table"
        T1[Member Code]
        T2[Full Name]
        T3[Phone]
        T4[Membership Status]
        T5[Expiry Date]
        T6[Actions]
    end

    subgraph "Actions"
        A1[View]
        A2[Edit]
        A3[Deactivate]
        A4[Export]
    end
```

#### 3.2.2 Booking Management

```mermaid
graph TD
    A[Calendar View] --> B[Session Details]
    B --> C[Guest List]
    C --> D[Check-in/Check-out]
    D --> E[Payment Status]

    subgraph "Calendar Features"
        C1[Daily View]
        C2[Weekly View]
        C3[Monthly View]
        C4[Session Indicators]
    end

    subgraph "Session Info"
        S1[Session Time]
        S2[Guest Count]
        S3[Member Status]
        S4[Payment Status]
    end
```

## 4. Responsive Design

### 4.1 Breakpoint Strategy

```css
/* Mobile First Approach */
/* Base: 320px - 767px */
@media (min-width: 768px) {
  /* Tablet: 768px - 1023px */
}
@media (min-width: 1024px) {
  /* Desktop: 1024px+ */
}
@media (min-width: 1440px) {
  /* Large Desktop: 1440px+ */
}
```

### 4.2 Component Responsiveness

```mermaid
graph TD
    subgraph "Navigation"
        N1[Mobile: Bottom Tab]
        N2[Tablet: Sidebar]
        N3[Desktop: Top + Sidebar]
    end

    subgraph "Data Display"
        D1[Mobile: Cards]
        D2[Tablet: Grid]
        D3[Desktop: Tables]
    end

    subgraph "Forms"
        F1[Mobile: Stacked]
        F2[Tablet: 2 Columns]
        F3[Desktop: Multi-column]
    end
```

## 5. Accessibility Guidelines

### 5.1 WCAG 2.1 Compliance

```mermaid
graph TD
    subgraph "Perceivable"
        P1[Color Contrast 4.5:1]
        P2[Text Resize 200%]
        P3[Alt Text for Images]
        P4[Captions for Audio/Video]
    end

    subgraph "Operable"
        O1[Keyboard Navigation]
        O2[Focus Indicators]
        O3[No Auto-play]
        O4[Error Prevention]
    end

    subgraph "Understandable"
        U1[Clear Language]
        U2[Consistent Navigation]
        U3[Error Identification]
        U4[Help Text]
    end

    subgraph "Robust"
        R1[Valid HTML]
        R2[Screen Reader Compatible]
        R3[Assistive Technology Support]
    end
```

### 5.2 Screen Reader Support

```html
<!-- Semantic HTML Structure -->
<header role="banner">
  <nav role="navigation">
    <main role="main">
      <aside role="complementary">
        <footer role="contentinfo">
          <!-- ARIA Labels -->
          <button aria-label="Book Session">
            <input aria-describedby="email-help" />
            <div role="alert" aria-live="polite"></div>
          </button>
        </footer>
      </aside>
    </main>
  </nav>
</header>
```

## 6. Interactive Elements

### 6.1 Button States

```mermaid
graph TD
    subgraph "Button States"
        B1[Default]
        B2[Hover]
        B3[Active/Pressed]
        B4[Focus]
        B5[Disabled]
        B6[Loading]
    end

    subgraph "Visual Feedback"
        V1[Color Change]
        V2[Shadow Effects]
        V3[Scale Transform]
        V4[Opacity Change]
    end
```

### 6.2 Form Validation

```mermaid
graph TD
    A[User Input] --> B[Real-time Validation]
    B --> C{Valid?}
    C -->|Yes| D[Show Success State]
    C -->|No| E[Show Error Message]
    D --> F[Enable Submit]
    E --> G[Disable Submit]

    subgraph "Validation Types"
        V1[Required Fields]
        V2[Email Format]
        V3[Phone Format]
        V4[Date Range]
        V5[Number Range]
    end
```

## 7. Loading States

### 7.1 Loading Patterns

```mermaid
graph TD
    subgraph "Loading States"
        L1[Skeleton Screens]
        L2[Spinner Loaders]
        L3[Progress Bars]
        L4[Skeleton Cards]
    end

    subgraph "Loading Placement"
        P1[Page Level]
        P2[Section Level]
        P3[Component Level]
        P4[Button Level]
    end
```

### 7.2 Error States

```mermaid
graph TD
    subgraph "Error Types"
        E1[Network Error]
        E2[Validation Error]
        E3[Server Error]
        E4[Empty State]
    end

    subgraph "Error Handling"
        H1[Clear Error Messages]
        H2[Retry Options]
        H3[Alternative Actions]
        H4[Help Resources]
    end
```

## 8. Animation Guidelines

### 8.1 Animation Principles

```mermaid
graph TD
    subgraph "Animation Types"
        A1[Page Transitions]
        A2[Component Entrances]
        A3[Micro-interactions]
        A4[Loading Animations]
    end

    subgraph "Timing Functions"
        T1[Ease-in-out: 300ms]
        T2[Ease-out: 200ms]
        T3[Ease-in: 200ms]
        T4[Linear: 150ms]
    end
```

### 8.2 Micro-interactions

```mermaid
graph TD
    subgraph "Button Interactions"
        B1[Hover Scale]
        B2[Click Ripple]
        B3[Focus Ring]
    end

    subgraph "Form Interactions"
        F1[Field Focus]
        F2[Validation States]
        F3[Success Confirmation]
    end

    subgraph "Navigation"
        N1[Tab Transitions]
        N2[Menu Expansions]
        N3[Breadcrumb Updates]
    end
```

---

**Versi**: 1.3  
**Tanggal**: 26 Agustus 2025  
**Status**: Complete dengan Dynamic Pricing, Guest Booking, Google SSO, Mobile-First Web App, Core Booking Flow, Manual Payment, Dynamic Member Quota & Member Daily Swimming Limit  
**Berdasarkan**: PDF Raujan Pool Syariah
