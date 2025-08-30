# Phase 2: Authentication & User Interface

## 📋 Overview

Implementasi interface autentikasi dan manajemen user dengan Google SSO integration dan responsive design.

## 🎯 Objectives

- Login/signup interface implementation
- Google SSO integration
- User profile management interface
- Role-based navigation
- Responsive design system
- User state management

## 📁 Files Structure

```
phase-2/
├── 01-authentication-interface.md
├── 02-google-sso-integration.md
├── 03-user-profile-management.md
├── 04-role-based-navigation.md
└── 05-responsive-design-system.md
```

## 🔧 Implementation Points

### Point 1: Authentication Interface

**Subpoints:**

- Login form component
- Signup form component
- Password reset interface
- Form validation
- Error handling
- Loading states

**Files:**

- `components/auth/LoginForm.tsx`
- `components/auth/SignupForm.tsx`
- `components/auth/PasswordReset.tsx`
- `hooks/useAuth.ts`
- `lib/validations/auth.ts`

### Point 2: Google SSO Integration

**Subpoints:**

- Google OAuth button component
- SSO flow implementation
- Google callback handling
- Profile data synchronization
- Error handling untuk SSO
- SSO state management

**Files:**

- `components/auth/GoogleSSOButton.tsx`
- `components/auth/SSOCallback.tsx`
- `lib/google-auth.ts`
- `hooks/useGoogleAuth.ts`

### Point 3: User Profile Management

**Subpoints:**

- Profile form component
- Avatar upload interface
- Profile editing functionality
- Emergency contact management
- Profile validation
- Profile history display

**Files:**

- `components/profile/ProfileForm.tsx`
- `components/profile/AvatarUpload.tsx`
- `components/profile/EmergencyContact.tsx`
- `hooks/useProfile.ts`

### Point 4: Role-Based Navigation

**Subpoints:**

- Navigation component
- Role-based menu items
- Protected route wrapper
- Navigation state management
- Mobile navigation
- Breadcrumb component

**Files:**

- `components/navigation/Navbar.tsx`
- `components/navigation/Sidebar.tsx`
- `components/navigation/MobileNav.tsx`
- `components/common/ProtectedRoute.tsx`
- `lib/navigation.ts`

### Point 5: Responsive Design System

**Subpoints:**

- Mobile-first design approach
- Breakpoint system
- Responsive components
- Touch-friendly interface
- Accessibility features
- Performance optimization

**Files:**

- `components/layout/ResponsiveContainer.tsx`
- `components/ui/ResponsiveButton.tsx`
- `styles/responsive.css`
- `lib/breakpoints.ts`

## 📦 Dependencies

### Authentication Dependencies

```json
{
  "next-auth": "^4.24.0",
  "react-hook-form": "^7.48.0",
  "zod": "^3.22.0",
  "@hookform/resolvers": "^3.3.0"
}
```

### UI Dependencies

```json
{
  "@headlessui/react": "^1.7.0",
  "@heroicons/react": "^2.0.0",
  "clsx": "^2.0.0",
  "tailwind-merge": "^2.0.0"
}
```

### State Management

```json
{
  "zustand": "^4.4.0",
  "react-query": "^3.39.0"
}
```

## 🎨 Component Examples

### Login Form Component

```typescript
import { useState } from "react";
import { useForm } from "react-hook-form";
import { zodResolver } from "@hookform/resolvers/zod";
import { loginSchema } from "@/lib/validations/auth";

export const LoginForm = () => {
  const [isLoading, setIsLoading] = useState(false);
  const {
    register,
    handleSubmit,
    formState: { errors },
  } = useForm({
    resolver: zodResolver(loginSchema),
  });

  const onSubmit = async (data: LoginFormData) => {
    setIsLoading(true);
    try {
      // Handle login logic
      await loginUser(data);
    } catch (error) {
      // Handle error
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <form onSubmit={handleSubmit(onSubmit)} className="space-y-4">
      <div>
        <label htmlFor="email">Email</label>
        <input
          {...register("email")}
          type="email"
          className="w-full px-3 py-2 border rounded-md"
        />
        {errors.email && (
          <span className="text-red-500 text-sm">{errors.email.message}</span>
        )}
      </div>

      <div>
        <label htmlFor="password">Password</label>
        <input
          {...register("password")}
          type="password"
          className="w-full px-3 py-2 border rounded-md"
        />
        {errors.password && (
          <span className="text-red-500 text-sm">
            {errors.password.message}
          </span>
        )}
      </div>

      <button
        type="submit"
        disabled={isLoading}
        className="w-full bg-blue-600 text-white py-2 px-4 rounded-md hover:bg-blue-700 disabled:opacity-50"
      >
        {isLoading ? "Logging in..." : "Login"}
      </button>
    </form>
  );
};
```

### Google SSO Button Component

```typescript
import { signIn } from "next-auth/react";

export const GoogleSSOButton = () => {
  const handleGoogleSignIn = () => {
    signIn("google", { callbackUrl: "/dashboard" });
  };

  return (
    <button
      onClick={handleGoogleSignIn}
      className="flex items-center justify-center w-full px-4 py-2 border border-gray-300 rounded-md shadow-sm bg-white text-sm font-medium text-gray-700 hover:bg-gray-50"
    >
      <svg className="w-5 h-5 mr-2" viewBox="0 0 24 24">
        {/* Google icon */}
      </svg>
      Continue with Google
    </button>
  );
};
```

## 📱 Responsive Design

### Breakpoint System

```typescript
export const breakpoints = {
  sm: "640px",
  md: "768px",
  lg: "1024px",
  xl: "1280px",
  "2xl": "1536px",
};
```

### Mobile-First Components

```typescript
export const ResponsiveContainer = ({
  children,
}: {
  children: React.ReactNode;
}) => {
  return (
    <div className="w-full max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
      {children}
    </div>
  );
};
```

## 🔐 Security Features

### Protected Routes

```typescript
export const ProtectedRoute = ({
  children,
  requiredRole,
}: ProtectedRouteProps) => {
  const { user, isLoading } = useAuth();

  if (isLoading) {
    return <LoadingSpinner />;
  }

  if (!user) {
    return <LoginRedirect />;
  }

  if (requiredRole && user.role !== requiredRole) {
    return <AccessDenied />;
  }

  return <>{children}</>;
};
```

## 📚 API Integration

### Authentication API

```typescript
export const authAPI = {
  login: async (credentials: LoginCredentials) => {
    const response = await fetch("/api/auth/login", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(credentials),
    });
    return response.json();
  },

  logout: async () => {
    await fetch("/api/auth/logout", { method: "POST" });
  },

  getProfile: async () => {
    const response = await fetch("/api/auth/profile");
    return response.json();
  },
};
```

## 🧪 Testing

### Component Testing

```typescript
import { render, screen, fireEvent } from "@testing-library/react";
import { LoginForm } from "@/components/auth/LoginForm";

describe("LoginForm", () => {
  it("renders login form", () => {
    render(<LoginForm />);
    expect(screen.getByLabelText(/email/i)).toBeInTheDocument();
    expect(screen.getByLabelText(/password/i)).toBeInTheDocument();
    expect(screen.getByRole("button", { name: /login/i })).toBeInTheDocument();
  });

  it("validates form inputs", () => {
    render(<LoginForm />);
    const submitButton = screen.getByRole("button", { name: /login/i });

    fireEvent.click(submitButton);

    expect(screen.getByText(/email is required/i)).toBeInTheDocument();
    expect(screen.getByText(/password is required/i)).toBeInTheDocument();
  });
});
```

## ✅ Success Criteria

- [ ] Login form berfungsi dengan baik
- [ ] Google SSO integration berjalan
- [ ] User profile management berfungsi
- [ ] Role-based navigation terimplementasi
- [ ] Responsive design pada semua device
- [ ] Form validation berfungsi
- [ ] Error handling terimplementasi
- [ ] Security measures terpasang
- [ ] Testing coverage > 80%

## 📚 Documentation

- Authentication Flow Documentation
- Google SSO Integration Guide
- Component Library Documentation
- Responsive Design Guidelines
- Security Best Practices
