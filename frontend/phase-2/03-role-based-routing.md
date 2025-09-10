# Role-Based Routing Implementation

## 📋 Overview

Implementasi role-based routing system dengan protected routes, role guards, dan navigation management untuk Raujan Pool Syariah frontend.

## 🎯 Objectives

- Protected routes implementation
- Role-based access control
- Navigation guards
- Route redirection
- Permission management
- Route configuration

## 🔧 Implementation Steps

### Step 1: Create Route Configuration

```bash
# Create route configuration
mkdir -p src/router
touch src/router/routes.ts
touch src/router/routeConfig.ts
touch src/router/routeTypes.ts
```

**Route Configuration:**

- Route definitions
- Route permissions
- Route metadata
- Route guards

### Step 2: Create Route Guards

```bash
# Create route guards
mkdir -p src/router/guards
touch src/router/guards/AuthGuard.tsx
touch src/router/guards/RoleGuard.tsx
touch src/router/guards/PermissionGuard.tsx
```

**Guard Features:**

- Authentication guard
- Role-based guard
- Permission-based guard
- Route protection

### Step 3: Create Route Components

```bash
# Create route components
mkdir -p src/router/components
touch src/router/components/ProtectedRoute.tsx
touch src/router/components/RoleRoute.tsx
touch src/router/components/RouteWrapper.tsx
```

**Component Structure:**

- `ProtectedRoute` - Protected route wrapper
- `RoleRoute` - Role-based route wrapper
- `RouteWrapper` - General route wrapper

### Step 4: Setup Navigation Management

```bash
# Create navigation management
mkdir -p src/router/navigation
touch src/router/navigation/NavigationManager.tsx
touch src/router/navigation/RouteHistory.tsx
```

**Navigation Features:**

- Navigation management
- Route history tracking
- Navigation guards
- Route transitions

### Step 5: Create Route Hooks

```bash
# Create route hooks
touch src/hooks/useRouteGuard.ts
touch src/hooks/useNavigation.ts
touch src/hooks/usePermissions.ts
```

**Hook Features:**

- Route guard hook
- Navigation hook
- Permission hook
- Route state management

## 📊 Configuration Files

### src/router/routes.ts

```typescript
// Route configuration
import { RouteObject } from "react-router-dom";
import { UserRole } from "@/types/auth";

export interface RouteConfig {
  path: string;
  element: React.ComponentType;
  roles?: UserRole[];
  permissions?: string[];
  requiresAuth?: boolean;
  redirectTo?: string;
  meta?: {
    title?: string;
    description?: string;
    requiresAuth?: boolean;
  };
}

export const routes: RouteConfig[] = [
  // Public routes
  {
    path: "/",
    element: () => import("@/pages/HomePage"),
    meta: { title: "Home" },
  },
  {
    path: "/login",
    element: () => import("@/pages/auth/LoginPage"),
    meta: { title: "Login" },
  },
  {
    path: "/register",
    element: () => import("@/pages/auth/RegisterPage"),
    meta: { title: "Register" },
  },

  // Protected routes
  {
    path: "/dashboard",
    element: () => import("@/pages/dashboard/DashboardPage"),
    requiresAuth: true,
    meta: { title: "Dashboard" },
  },

  // Admin routes
  {
    path: "/admin",
    element: () => import("@/pages/admin/AdminDashboard"),
    roles: ["admin"],
    requiresAuth: true,
    meta: { title: "Admin Dashboard" },
  },
  {
    path: "/admin/users",
    element: () => import("@/pages/admin/UserManagement"),
    roles: ["admin"],
    permissions: ["user:read", "user:write"],
    requiresAuth: true,
    meta: { title: "User Management" },
  },

  // Staff routes
  {
    path: "/staff",
    element: () => import("@/pages/staff/StaffDashboard"),
    roles: ["staff", "admin"],
    requiresAuth: true,
    meta: { title: "Staff Dashboard" },
  },
  {
    path: "/staff/bookings",
    element: () => import("@/pages/staff/BookingManagement"),
    roles: ["staff", "admin"],
    permissions: ["booking:read", "booking:write"],
    requiresAuth: true,
    meta: { title: "Booking Management" },
  },

  // Member routes
  {
    path: "/member",
    element: () => import("@/pages/member/MemberDashboard"),
    roles: ["member", "admin"],
    requiresAuth: true,
    meta: { title: "Member Dashboard" },
  },
  {
    path: "/member/profile",
    element: () => import("@/pages/member/ProfilePage"),
    roles: ["member", "admin"],
    requiresAuth: true,
    meta: { title: "Profile" },
  },

  // Guest routes
  {
    path: "/guest",
    element: () => import("@/pages/guest/GuestDashboard"),
    roles: ["guest"],
    meta: { title: "Guest Dashboard" },
  },
];
```

### src/router/guards/AuthGuard.tsx

```typescript
// Authentication guard
import { Navigate, useLocation } from "react-router-dom";
import { useAuth } from "@/hooks/useAuth";
import { Loader2 } from "lucide-react";

interface AuthGuardProps {
  children: React.ReactNode;
  requiresAuth?: boolean;
  redirectTo?: string;
}

export function AuthGuard({
  children,
  requiresAuth = false,
  redirectTo = "/login",
}: AuthGuardProps) {
  const { isAuthenticated, isLoading } = useAuth();
  const location = useLocation();

  if (isLoading) {
    return (
      <div className="flex items-center justify-center min-h-screen">
        <Loader2 className="h-8 w-8 animate-spin" />
      </div>
    );
  }

  if (requiresAuth && !isAuthenticated) {
    return <Navigate to={redirectTo} state={{ from: location }} replace />;
  }

  if (!requiresAuth && isAuthenticated) {
    return <Navigate to="/dashboard" replace />;
  }

  return <>{children}</>;
}
```

### src/router/guards/RoleGuard.tsx

```typescript
// Role-based guard
import { Navigate } from "react-router-dom";
import { useAuth } from "@/hooks/useAuth";
import { UserRole } from "@/types/auth";

interface RoleGuardProps {
  children: React.ReactNode;
  allowedRoles?: UserRole[];
  redirectTo?: string;
}

export function RoleGuard({
  children,
  allowedRoles = [],
  redirectTo = "/dashboard",
}: RoleGuardProps) {
  const { user } = useAuth();

  if (!user) {
    return <Navigate to="/login" replace />;
  }

  if (allowedRoles.length > 0 && !allowedRoles.includes(user.role)) {
    return <Navigate to={redirectTo} replace />;
  }

  return <>{children}</>;
}
```

### src/router/guards/PermissionGuard.tsx

```typescript
// Permission-based guard
import { Navigate } from "react-router-dom";
import { useAuth } from "@/hooks/useAuth";
import { usePermissions } from "@/hooks/usePermissions";

interface PermissionGuardProps {
  children: React.ReactNode;
  requiredPermissions?: string[];
  redirectTo?: string;
}

export function PermissionGuard({
  children,
  requiredPermissions = [],
  redirectTo = "/dashboard",
}: PermissionGuardProps) {
  const { user } = useAuth();
  const { hasPermissions } = usePermissions();

  if (!user) {
    return <Navigate to="/login" replace />;
  }

  if (requiredPermissions.length > 0 && !hasPermissions(requiredPermissions)) {
    return <Navigate to={redirectTo} replace />;
  }

  return <>{children}</>;
}
```

### src/router/components/ProtectedRoute.tsx

```typescript
// Protected route component
import { AuthGuard } from "../guards/AuthGuard";
import { RoleGuard } from "../guards/RoleGuard";
import { PermissionGuard } from "../guards/PermissionGuard";
import { RouteConfig } from "../routes";

interface ProtectedRouteProps {
  children: React.ReactNode;
  config: RouteConfig;
}

export function ProtectedRoute({ children, config }: ProtectedRouteProps) {
  return (
    <AuthGuard requiresAuth={config.requiresAuth}>
      <RoleGuard allowedRoles={config.roles}>
        <PermissionGuard requiredPermissions={config.permissions}>
          {children}
        </PermissionGuard>
      </RoleGuard>
    </AuthGuard>
  );
}
```

## 🛠️ Development Commands

### Role-Based Routing Development

```bash
# Start development server
npm run dev

# Test routing components
npm run test -- --testPathPattern=routing

# Test route guards
npm run test -- --testPathPattern=guards
```

### Role-Based Routing Testing

```bash
# Test routing functionality
npm run test src/router

# Test route guards
npm run test src/router/guards

# Test route components
npm run test src/router/components
```

## 🎨 UI Implementation

### Route Styling

```bash
# Create routing styles
mkdir -p src/styles/router
touch src/styles/router/routeTransitions.css
touch src/styles/router/routeGuards.css
```

**Style Features:**

- Route transition styling
- Route guard styling
- Loading state styling
- Error state styling

### Navigation UI

```bash
# Create navigation components
touch src/components/navigation/RoleBasedNavigation.tsx
touch src/components/navigation/NavigationMenu.tsx
```

**Navigation Features:**

- Role-based navigation
- Navigation menu
- Breadcrumb navigation
- Mobile navigation

## 🔧 Integration Points

### Router Integration

```bash
# Create router integration
touch src/router/AppRouter.tsx
touch src/router/RouterProvider.tsx
```

**Router Features:**

- Main router configuration
- Router provider
- Route management
- Navigation management

### State Management

```bash
# Create routing state management
touch src/store/router/routerStore.ts
touch src/store/router/routerActions.ts
```

**State Features:**

- Route state management
- Navigation state
- Permission state
- Route history

## 🧪 Testing Strategy

### Unit Tests

```bash
# Test routing components
mkdir -p src/router/__tests__
touch src/router/__tests__/AuthGuard.test.tsx
touch src/router/__tests__/RoleGuard.test.tsx
touch src/router/__tests__/PermissionGuard.test.tsx
```

**Test Coverage:**

- Route guards
- Route protection
- Permission checking
- Navigation

### Integration Tests

```bash
# Test routing integration
mkdir -p src/__tests__/integration
touch src/__tests__/integration/role-based-routing.test.tsx
```

**Integration Tests:**

- Complete routing flow
- Role-based access
- Permission-based access
- Navigation flow

## 📱 Mobile Considerations

### Mobile Routing

```bash
# Mobile routing components
touch src/router/mobile/MobileRouteGuard.tsx
touch src/router/mobile/MobileNavigation.tsx
```

**Mobile Features:**

- Mobile route guards
- Mobile navigation
- Touch-friendly routing
- Mobile route transitions

### Performance Optimization

```bash
# Routing performance optimization
touch src/hooks/useRoutingPerformance.ts
```

**Optimizations:**

- Route lazy loading
- Route caching
- Navigation optimization
- Route preloading

## 🔒 Security Considerations

### Route Security

```bash
# Route security utilities
touch src/utils/routeSecurity.ts
touch src/utils/routeValidation.ts
```

**Security Features:**

- Route security validation
- Permission validation
- Role validation
- Route protection

### Data Protection

```bash
# Data protection utilities
touch src/utils/routeDataProtection.ts
touch src/utils/navigationDataProtection.ts
```

**Protection Features:**

- Route data protection
- Navigation data protection
- Permission data protection
- Privacy compliance

## 📊 Analytics & Monitoring

### Routing Analytics

```bash
# Routing analytics
touch src/utils/routingAnalytics.ts
touch src/hooks/useRoutingAnalytics.ts
```

**Analytics Features:**

- Route usage tracking
- Navigation analytics
- Permission analytics
- User behavior tracking

### Error Monitoring

```bash
# Error monitoring untuk routing
touch src/utils/routingErrorMonitoring.ts
touch src/hooks/useRoutingErrorMonitoring.ts
```

**Monitoring Features:**

- Route error tracking
- Navigation error monitoring
- Permission error monitoring
- System alerts

## ✅ Success Criteria

- [ ] Protected routes implementation berfungsi dengan baik
- [ ] Role-based access control implemented
- [ ] Navigation guards berfungsi
- [ ] Route redirection berfungsi
- [ ] Permission management implemented
- [ ] Route configuration dengan proper metadata
- [ ] Route guards dengan proper validation
- [ ] Navigation management dengan state tracking
- [ ] Route hooks dengan proper error handling
- [ ] Unit tests untuk routing components
- [ ] Integration tests untuk routing flow
- [ ] Security measures untuk route protection
- [ ] Data protection untuk navigation data
- [ ] Analytics tracking untuk routing usage
- [ ] Error monitoring dan alerting
- [ ] Performance optimization untuk routing
- [ ] Mobile-responsive routing interface
- [ ] Accessibility features maintained
- [ ] Role-based routing system health monitoring
- [ ] Role-based routing documentation dan user guides

## 📝 Notes

- Pastikan route protection aman dan tidak bypass
- Implementasi proper permission checking untuk semua routes
- Setup proper error handling untuk route failures
- Test role-based routing dengan various user roles
- Consider implementing route backup strategies
- Implementasi role-based routing system reporting features
- Consider adding route notifications
- Implementasi role-based routing system health monitoring
- Add role-based routing system documentation dan training materials
