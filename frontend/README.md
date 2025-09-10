# Frontend Development Plan - Sistem Kolam Renang Syariah

## 📋 Overview

Frontend development menggunakan Vite + React + ShadCN UI dengan struktur modular dan scalable untuk sistem manajemen kolam renang syariah.

## 🏗️ Technology Stack

- **Framework**: React 18 + TypeScript
- **Build Tool**: Vite 5
- **UI Library**: ShadCN UI + Tailwind CSS
- **State Management**: Zustand / Redux Toolkit
- **HTTP Client**: Axios
- **Routing**: React Router v6
- **Form Handling**: React Hook Form + Zod
- **Date/Time**: Day.js
- **Charts**: Recharts
- **Real-time**: Socket.io-client
- **Testing**: Vitest + React Testing Library

## 📁 File Hierarchy Rules

Setiap fitur harus mengikuti urutan hirarki file berikut:

```
Components → Hooks → Services → Pages → Routes
```

### 🔄 Implementation Flow

1. **Components** - Reusable UI components dengan ShadCN
2. **Hooks** - Custom hooks untuk business logic
3. **Services** - API calls dan data management
4. **Pages** - Page components dengan layout
5. **Routes** - Route configuration dan navigation

### 📁 File Structure Example

```
src/
├── components/
│   ├── ui/                 # ShadCN UI components
│   ├── forms/              # Form components
│   ├── layout/             # Layout components
│   └── features/           # Feature-specific components
├── hooks/
│   ├── useAuth.ts
│   ├── useBooking.ts
│   └── usePayment.ts
├── services/
│   ├── api/
│   │   ├── auth.ts
│   │   ├── booking.ts
│   │   └── payment.ts
│   └── socket.ts
├── pages/
│   ├── auth/
│   ├── admin/
│   ├── member/
│   └── staff/
├── stores/
│   ├── authStore.ts
│   ├── bookingStore.ts
│   └── paymentStore.ts
└── types/
    ├── auth.ts
    ├── booking.ts
    └── payment.ts
```

### 🎯 Benefits

- **Component Reusability**: ShadCN UI components yang konsisten
- **Type Safety**: TypeScript untuk type checking
- **Performance**: Vite untuk fast development dan build
- **Maintainability**: Struktur yang jelas dan modular
- **Scalability**: Easy to add new features
- **Developer Experience**: Hot reload dan fast refresh

## 📁 Structure

```
frontend/
├── phase-1/          # Project Setup & Core Infrastructure
│   ├── 01-vite-react-setup.md
│   ├── 02-shadcn-ui-setup.md
│   ├── 03-routing-setup.md
│   ├── 04-state-management.md
│   └── 05-development-tools.md
├── phase-2/          # Authentication & User Management
│   ├── 01-authentication-ui.md
│   ├── 02-google-sso-integration.md
│   ├── 03-role-based-routing.md
│   ├── 04-user-profile-ui.md
│   └── 05-guest-user-ui.md
├── phase-3/          # Booking System & Calendar
│   ├── 01-calendar-ui.md
│   ├── 02-booking-forms.md
│   ├── 03-real-time-availability.md
│   ├── 04-session-management-ui.md
│   └── 05-capacity-display.md
├── phase-4/          # Payment System & Manual Payment
│   ├── 01-payment-forms.md
│   ├── 02-payment-verification-ui.md
│   ├── 03-payment-tracking.md
│   ├── 04-refund-management-ui.md
│   └── 05-payment-analytics-ui.md
├── phase-5/          # Member Management & Quota System
│   ├── 01-member-registration-ui.md
│   ├── 02-quota-management-ui.md
│   ├── 03-queue-system-ui.md
│   ├── 04-membership-expiry-ui.md
│   └── 05-member-notifications-ui.md
└── phase-6/          # Cafe System & Barcode Integration
    ├── 01-menu-management-ui.md
    ├── 02-barcode-scanner-ui.md
    ├── 03-order-processing-ui.md
    ├── 04-inventory-management-ui.md
    └── 05-order-tracking-ui.md
```

## 🎯 Development Phases

### Phase 1: Project Setup & Core Infrastructure (Week 1-2)

- Vite + React + TypeScript setup
- ShadCN UI integration
- Routing configuration
- State management setup
- Development tools configuration

### Phase 2: Authentication & User Management (Week 3-4)

- Authentication UI components
- Google SSO integration
- Role-based routing
- User profile management
- Guest user interface

### Phase 3: Booking System & Calendar (Week 5-6)

- Calendar interface
- Booking forms
- Real-time availability
- Session management UI
- Capacity display

### Phase 4: Payment System & Manual Payment (Week 7-8)

- Payment forms
- Payment verification UI
- Payment tracking
- Refund management
- Payment analytics

### Phase 5: Member Management & Quota System (Week 9-10)

- Member registration UI
- Quota management interface
- Queue system UI
- Membership expiry handling
- Member notifications

### Phase 6: Cafe System & Barcode Integration (Week 11-12)

- Menu management interface
- Barcode scanner integration
- Order processing UI
- Inventory management
- Order tracking

## 🚀 Getting Started

1. Clone repository
2. Install dependencies: `npm install`
3. Copy environment file: `cp .env.example .env`
4. Configure API endpoints
5. Start development server: `npm run dev`

## 📚 Documentation

Each phase contains detailed documentation split into individual files for better organization:

### Phase 1: Project Setup & Core Infrastructure

- [Vite React Setup](phase-1/01-vite-react-setup.md) - Vite + React + TypeScript configuration
- [ShadCN UI Setup](phase-1/02-shadcn-ui-setup.md) - ShadCN UI components integration
- [Routing Setup](phase-1/03-routing-setup.md) - React Router configuration
- [State Management](phase-1/04-state-management.md) - Zustand/Redux setup
- [Development Tools](phase-1/05-development-tools.md) - ESLint, Prettier, and testing tools

### Phase 2: Authentication & User Management

- [Authentication UI](phase-2/01-authentication-ui.md) - Login/Register forms
- [Google SSO Integration](phase-2/02-google-sso-integration.md) - Google OAuth integration
- [Role-based Routing](phase-2/03-role-based-routing.md) - Protected routes
- [User Profile UI](phase-2/04-user-profile-ui.md) - Profile management interface
- [Guest User UI](phase-2/05-guest-user-ui.md) - Guest user interface

### Phase 3: Booking System & Calendar

- [Calendar UI](phase-3/01-calendar-ui.md) - Calendar interface components
- [Booking Forms](phase-3/02-booking-forms.md) - Booking form components
- [Real-time Availability](phase-3/03-real-time-availability.md) - WebSocket integration
- [Session Management UI](phase-3/04-session-management-ui.md) - Session handling interface
- [Capacity Display](phase-3/05-capacity-display.md) - Capacity visualization

### Phase 4: Payment System & Manual Payment

- [Payment Forms](phase-4/01-payment-forms.md) - Payment form components
- [Payment Verification UI](phase-4/02-payment-verification-ui.md) - Admin verification interface
- [Payment Tracking](phase-4/03-payment-tracking.md) - Payment status tracking
- [Refund Management UI](phase-4/04-refund-management-ui.md) - Refund processing interface
- [Payment Analytics UI](phase-4/05-payment-analytics-ui.md) - Payment reports interface

### Phase 5: Member Management & Quota System

- [Member Registration UI](phase-5/01-member-registration-ui.md) - Member registration forms
- [Quota Management UI](phase-5/02-quota-management-ui.md) - Quota management interface
- [Queue System UI](phase-5/03-queue-system-ui.md) - Queue management interface
- [Membership Expiry UI](phase-5/04-membership-expiry-ui.md) - Expiry tracking interface
- [Member Notifications UI](phase-5/05-member-notifications-ui.md) - Notification interface

### Phase 6: Cafe System & Barcode Integration

- [Menu Management UI](phase-6/01-menu-management-ui.md) - Menu management interface
- [Barcode Scanner UI](phase-6/02-barcode-scanner-ui.md) - Barcode scanning interface
- [Order Processing UI](phase-6/03-order-processing-ui.md) - Order workflow interface
- [Inventory Management UI](phase-6/04-inventory-management-ui.md) - Stock management interface
- [Order Tracking UI](phase-6/05-order-tracking-ui.md) - Order status tracking

Each documentation file includes:

- Component specifications
- API integration details
- UI/UX requirements
- Testing procedures
- Success criteria

## 🎨 Design System

### ShadCN UI Components

- **Button**: Primary, secondary, outline, ghost variants
- **Input**: Text, email, password, number inputs
- **Card**: Container components
- **Dialog**: Modal dialogs
- **Form**: Form components with validation
- **Table**: Data tables
- **Calendar**: Date picker components
- **Toast**: Notification system

### Color Palette

- **Primary**: Blue (#3B82F6)
- **Secondary**: Gray (#6B7280)
- **Success**: Green (#10B981)
- **Warning**: Yellow (#F59E0B)
- **Error**: Red (#EF4444)
- **Background**: White (#FFFFFF)
- **Surface**: Gray-50 (#F9FAFB)

### Typography

- **Heading 1**: 32px, font-weight 700
- **Heading 2**: 24px, font-weight 600
- **Heading 3**: 20px, font-weight 600
- **Body**: 16px, font-weight 400
- **Caption**: 14px, font-weight 400
- **Small**: 12px, font-weight 400

## 📱 Responsive Design

- **Mobile**: 320px - 768px
- **Tablet**: 768px - 1024px
- **Desktop**: 1024px+

## 🔧 Development Guidelines

### Code Style

- Use TypeScript for type safety
- Follow React best practices
- Use functional components with hooks
- Implement proper error boundaries
- Use proper naming conventions

### Component Structure

```tsx
// Component example
interface ComponentProps {
  title: string;
  onAction: () => void;
}

export const Component: React.FC<ComponentProps> = ({ title, onAction }) => {
  return (
    <div className="component-container">
      <h2>{title}</h2>
      <Button onClick={onAction}>Action</Button>
    </div>
  );
};
```

### API Integration

```tsx
// API service example
import axios from "axios";

const api = axios.create({
  baseURL: process.env.REACT_APP_API_URL,
  headers: {
    "Content-Type": "application/json",
  },
});

export const authService = {
  login: (credentials: LoginCredentials) =>
    api.post("/auth/login", credentials),
  logout: () => api.post("/auth/logout"),
};
```

## 🧪 Testing Strategy

- **Unit Tests**: Component testing dengan React Testing Library
- **Integration Tests**: API integration testing
- **E2E Tests**: User flow testing dengan Playwright
- **Visual Tests**: Component visual regression testing

## 📦 Build & Deployment

- **Development**: `npm run dev`
- **Build**: `npm run build`
- **Preview**: `npm run preview`
- **Test**: `npm run test`
- **Lint**: `npm run lint`

## 🔗 Backend Integration

Frontend ini terintegrasi dengan backend API yang sudah didokumentasikan di folder `backend/docs/api/`. Setiap endpoint API memiliki dokumentasi lengkap untuk memudahkan integrasi frontend.

### API Base URL

```
Development: http://localhost:8000/api/v1
Production: https://api.raujanpool.com/api/v1
```

### Authentication

Semua request ke API memerlukan Bearer token:

```tsx
const token = localStorage.getItem("auth_token");
api.defaults.headers.common["Authorization"] = `Bearer ${token}`;
```

## 📞 Support

Untuk pertanyaan atau dukungan teknis:

- **Issues**: GitHub Issues
- **Email**: support@raujanpool.com
- **Documentation**: Lihat file-file di folder ini

---

**Last updated**: September 2025  
**Version**: 1.0.0  
**Status**: Development Ready ✅
