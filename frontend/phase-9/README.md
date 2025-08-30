# Phase 9: Final Integration & Testing

## 📋 Overview

Integrasi final semua komponen frontend, testing end-to-end, optimasi performa, dan deployment preparation.

## 🎯 Objectives

- Integration testing
- Performance optimization
- Error handling
- Accessibility compliance
- PWA optimization
- Deployment preparation
- Documentation completion

## 📁 Files Structure

```
phase-9/
├── 01-integration-testing.md
├── 02-performance-optimization.md
├── 03-error-handling.md
├── 04-accessibility-compliance.md
└── 05-deployment-preparation.md
```

## 🔧 Implementation Points

### Point 1: Integration Testing

**Subpoints:**

- End-to-end testing
- Component integration
- API integration testing
- WebSocket integration testing
- Cross-browser testing
- Mobile testing

**Files:**

- `tests/e2e/booking-flow.spec.ts`
- `tests/e2e/payment-flow.spec.ts`
- `tests/e2e/member-flow.spec.ts`
- `tests/e2e/cafe-flow.spec.ts`
- `tests/integration/api-integration.test.ts`
- `tests/integration/websocket-integration.test.ts`

### Point 2: Performance Optimization

**Subpoints:**

- Bundle optimization
- Code splitting
- Lazy loading
- Image optimization
- Caching strategies
- Performance monitoring

**Files:**

- `next.config.js` (optimized)
- `components/LazyComponents.tsx`
- `lib/performance-monitor.ts`
- `hooks/usePerformance.ts`
- `utils/image-optimization.ts`
- `utils/bundle-analyzer.ts`

### Point 3: Error Handling

**Subpoints:**

- Global error boundary
- API error handling
- Network error handling
- User-friendly error messages
- Error logging
- Error recovery

**Files:**

- `components/ErrorBoundary.tsx`
- `components/ErrorFallback.tsx`
- `lib/error-handler.ts`
- `hooks/useErrorHandler.ts`
- `utils/error-logger.ts`
- `types/error-types.ts`

### Point 4: Accessibility Compliance

**Subpoints:**

- WCAG 2.1 AA compliance
- Keyboard navigation
- Screen reader support
- Color contrast
- Focus management
- ARIA labels

**Files:**

- `components/AccessibleButton.tsx`
- `components/AccessibleModal.tsx`
- `components/AccessibleForm.tsx`
- `lib/accessibility-utils.ts`
- `hooks/useAccessibility.ts`
- `utils/aria-helpers.ts`

### Point 5: Deployment Preparation

**Subpoints:**

- Environment configuration
- Build optimization
- Static generation
- CDN configuration
- Monitoring setup
- Documentation

**Files:**

- `.env.production`
- `next.config.production.js`
- `docker/Dockerfile`
- `docker/docker-compose.yml`
- `scripts/deploy.sh`
- `docs/deployment-guide.md`

## 📦 Dependencies

### Testing Dependencies

```json
{
  "@playwright/test": "^1.40.0",
  "@testing-library/jest-dom": "^6.1.0",
  "@testing-library/react": "^14.1.0",
  "@testing-library/user-event": "^14.5.0",
  "jest": "^29.7.0",
  "jest-environment-jsdom": "^29.7.0",
  "msw": "^2.0.0"
}
```

### Performance Dependencies

```json
{
  "@next/bundle-analyzer": "^14.0.0",
  "web-vitals": "^3.5.0",
  "lighthouse": "^11.0.0",
  "workbox-webpack-plugin": "^7.0.0",
  "sharp": "^0.32.0"
}
```

### Monitoring Dependencies

```json
{
  "@sentry/nextjs": "^7.0.0",
  "framer-motion": "^10.16.0",
  "react-intersection-observer": "^9.5.0",
  "react-window": "^1.8.0"
}
```

## 🎨 Component Examples

### Error Boundary Component

```typescript
import React, { Component, ErrorInfo, ReactNode } from "react";
import { AlertTriangle, RefreshCw, Home } from "lucide-react";

interface Props {
  children: ReactNode;
  fallback?: ReactNode;
}

interface State {
  hasError: boolean;
  error?: Error;
  errorInfo?: ErrorInfo;
}

export class ErrorBoundary extends Component<Props, State> {
  constructor(props: Props) {
    super(props);
    this.state = { hasError: false };
  }

  static getDerivedStateFromError(error: Error): State {
    return { hasError: true, error };
  }

  componentDidCatch(error: Error, errorInfo: ErrorInfo) {
    this.setState({ error, errorInfo });

    // Log error to monitoring service
    console.error("Error caught by boundary:", error, errorInfo);

    // Send to error tracking service
    if (typeof window !== "undefined" && window.Sentry) {
      window.Sentry.captureException(error, {
        contexts: { react: { componentStack: errorInfo.componentStack } },
      });
    }
  }

  handleRetry = () => {
    this.setState({ hasError: false, error: undefined, errorInfo: undefined });
  };

  handleGoHome = () => {
    window.location.href = "/";
  };

  render() {
    if (this.state.hasError) {
      if (this.props.fallback) {
        return this.props.fallback;
      }

      return (
        <div className="min-h-screen flex items-center justify-center bg-gray-50">
          <div className="max-w-md w-full bg-white rounded-lg shadow-lg p-6">
            <div className="text-center">
              <div className="w-16 h-16 bg-red-100 rounded-full flex items-center justify-center mx-auto mb-4">
                <AlertTriangle className="w-8 h-8 text-red-600" />
              </div>

              <h1 className="text-xl font-semibold text-gray-900 mb-2">
                Something went wrong
              </h1>

              <p className="text-gray-600 mb-6">
                We're sorry, but something unexpected happened. Please try again
                or go back to the home page.
              </p>

              {process.env.NODE_ENV === "development" && this.state.error && (
                <details className="mb-6 text-left">
                  <summary className="cursor-pointer text-sm text-gray-500 hover:text-gray-700">
                    Error Details (Development)
                  </summary>
                  <div className="mt-2 p-3 bg-gray-100 rounded text-xs font-mono text-gray-800 overflow-auto">
                    <div className="mb-2">
                      <strong>Error:</strong> {this.state.error.message}
                    </div>
                    <div className="mb-2">
                      <strong>Stack:</strong>
                      <pre className="whitespace-pre-wrap">
                        {this.state.error.stack}
                      </pre>
                    </div>
                    {this.state.errorInfo && (
                      <div>
                        <strong>Component Stack:</strong>
                        <pre className="whitespace-pre-wrap">
                          {this.state.errorInfo.componentStack}
                        </pre>
                      </div>
                    )}
                  </div>
                </details>
              )}

              <div className="flex space-x-3">
                <button
                  onClick={this.handleRetry}
                  className="flex-1 bg-blue-600 text-white py-2 px-4 rounded-md hover:bg-blue-700 flex items-center justify-center space-x-2"
                >
                  <RefreshCw className="w-4 h-4" />
                  <span>Try Again</span>
                </button>

                <button
                  onClick={this.handleGoHome}
                  className="flex-1 bg-gray-600 text-white py-2 px-4 rounded-md hover:bg-gray-700 flex items-center justify-center space-x-2"
                >
                  <Home className="w-4 h-4" />
                  <span>Go Home</span>
                </button>
              </div>
            </div>
          </div>
        </div>
      );
    }

    return this.props.children;
  }
}
```

### Performance Monitor Component

```typescript
import { useEffect, useState } from "react";
import { getCLS, getFID, getFCP, getLCP, getTTFB } from "web-vitals";

interface PerformanceMetrics {
  cls: number | null;
  fid: number | null;
  fcp: number | null;
  lcp: number | null;
  ttfb: number | null;
}

export const PerformanceMonitor = () => {
  const [metrics, setMetrics] = useState<PerformanceMetrics>({
    cls: null,
    fid: null,
    fcp: null,
    lcp: null,
    ttfb: null,
  });

  useEffect(() => {
    const handleMetric = (metric: any) => {
      setMetrics((prev) => ({
        ...prev,
        [metric.name]: metric.value,
      }));

      // Send to analytics
      if (typeof window !== "undefined" && window.gtag) {
        window.gtag("event", metric.name, {
          event_category: "Web Vitals",
          value: Math.round(metric.value),
          event_label: metric.id,
          non_interaction: true,
        });
      }
    };

    getCLS(handleMetric);
    getFID(handleMetric);
    getFCP(handleMetric);
    getLCP(handleMetric);
    getTTFB(handleMetric);
  }, []);

  // Only show in development
  if (process.env.NODE_ENV !== "development") {
    return null;
  }

  return (
    <div className="fixed bottom-4 right-4 bg-black bg-opacity-75 text-white p-3 rounded-lg text-xs font-mono z-50">
      <div className="font-bold mb-2">Performance Metrics</div>
      <div>CLS: {metrics.cls?.toFixed(3) || "N/A"}</div>
      <div>FID: {metrics.fid?.toFixed(1) || "N/A"}ms</div>
      <div>FCP: {metrics.fcp?.toFixed(1) || "N/A"}ms</div>
      <div>LCP: {metrics.lcp?.toFixed(1) || "N/A"}ms</div>
      <div>TTFB: {metrics.ttfb?.toFixed(1) || "N/A"}ms</div>
    </div>
  );
};
```

### Accessible Button Component

```typescript
import React, { forwardRef } from "react";
import { clsx } from "clsx";

interface AccessibleButtonProps
  extends React.ButtonHTMLAttributes<HTMLButtonElement> {
  variant?: "primary" | "secondary" | "danger" | "ghost";
  size?: "sm" | "md" | "lg";
  loading?: boolean;
  leftIcon?: React.ReactNode;
  rightIcon?: React.ReactNode;
  fullWidth?: boolean;
}

export const AccessibleButton = forwardRef<
  HTMLButtonElement,
  AccessibleButtonProps
>(
  (
    {
      children,
      variant = "primary",
      size = "md",
      loading = false,
      leftIcon,
      rightIcon,
      fullWidth = false,
      className,
      disabled,
      ...props
    },
    ref
  ) => {
    const baseClasses =
      "inline-flex items-center justify-center font-medium rounded-md transition-colors focus:outline-none focus:ring-2 focus:ring-offset-2 disabled:opacity-50 disabled:cursor-not-allowed";

    const variantClasses = {
      primary: "bg-blue-600 text-white hover:bg-blue-700 focus:ring-blue-500",
      secondary: "bg-gray-600 text-white hover:bg-gray-700 focus:ring-gray-500",
      danger: "bg-red-600 text-white hover:bg-red-700 focus:ring-red-500",
      ghost:
        "bg-transparent text-gray-700 hover:bg-gray-100 focus:ring-gray-500",
    };

    const sizeClasses = {
      sm: "px-3 py-1.5 text-sm",
      md: "px-4 py-2 text-sm",
      lg: "px-6 py-3 text-base",
    };

    const widthClasses = fullWidth ? "w-full" : "";

    return (
      <button
        ref={ref}
        className={clsx(
          baseClasses,
          variantClasses[variant],
          sizeClasses[size],
          widthClasses,
          className
        )}
        disabled={disabled || loading}
        aria-disabled={disabled || loading}
        {...props}
      >
        {loading && (
          <svg
            className="animate-spin -ml-1 mr-2 h-4 w-4"
            xmlns="http://www.w3.org/2000/svg"
            fill="none"
            viewBox="0 0 24 24"
            aria-hidden="true"
          >
            <circle
              className="opacity-25"
              cx="12"
              cy="12"
              r="10"
              stroke="currentColor"
              strokeWidth="4"
            />
            <path
              className="opacity-75"
              fill="currentColor"
              d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"
            />
          </svg>
        )}

        {!loading && leftIcon && (
          <span className="mr-2" aria-hidden="true">
            {leftIcon}
          </span>
        )}

        <span>{children}</span>

        {!loading && rightIcon && (
          <span className="ml-2" aria-hidden="true">
            {rightIcon}
          </span>
        )}
      </button>
    );
  }
);

AccessibleButton.displayName = "AccessibleButton";
```

### Lazy Loading Component

```typescript
import { lazy, Suspense, ComponentType } from "react";
import { Loader2 } from "lucide-react";

// Loading fallback component
const LoadingFallback = () => (
  <div className="flex items-center justify-center p-8">
    <Loader2 className="w-6 h-6 animate-spin text-blue-600" />
    <span className="ml-2 text-gray-600">Loading...</span>
  </div>
);

// Higher-order component for lazy loading
export function withLazyLoading<T extends object>(
  importFunc: () => Promise<{ default: ComponentType<T> }>
) {
  const LazyComponent = lazy(importFunc);

  return function LazyWrapper(props: T) {
    return (
      <Suspense fallback={<LoadingFallback />}>
        <LazyComponent {...props} />
      </Suspense>
    );
  };
}

// Lazy loaded components
export const LazyBookingCalendar = withLazyLoading(
  () => import("@/components/booking/BookingCalendar")
);

export const LazyPaymentForm = withLazyLoading(
  () => import("@/components/payment/PaymentForm")
);

export const LazyMemberDashboard = withLazyLoading(
  () => import("@/components/member/Dashboard")
);

export const LazyCafeInterface = withLazyLoading(
  () => import("@/components/cafe/MenuList")
);

export const LazyRatingInterface = withLazyLoading(
  () => import("@/components/rating/RatingForm")
);

export const LazyCheckinInterface = withLazyLoading(
  () => import("@/components/checkin/QRScanner")
);
```

## 🧪 Testing Examples

### E2E Booking Flow Test

```typescript
import { test, expect } from "@playwright/test";

test.describe("Booking Flow", () => {
  test("complete booking flow from calendar to confirmation", async ({
    page,
  }) => {
    // Navigate to booking page
    await page.goto("/booking");

    // Wait for calendar to load
    await expect(page.locator("[data-testid=booking-calendar]")).toBeVisible();

    // Select a date
    await page.click("[data-testid=calendar-date-15]");

    // Select a session
    await page.click("[data-testid=session-morning]");

    // Fill guest information
    await page.fill("[data-testid=guest-name]", "John Doe");
    await page.fill("[data-testid=guest-phone]", "081234567890");
    await page.fill("[data-testid=guest-email]", "john@example.com");

    // Submit booking
    await page.click("[data-testid=submit-booking]");

    // Wait for confirmation
    await expect(
      page.locator("[data-testid=booking-confirmation]")
    ).toBeVisible();

    // Verify booking details
    await expect(page.locator("[data-testid=booking-reference]")).toContainText(
      "BK"
    );
    await expect(
      page.locator("[data-testid=guest-name-display]")
    ).toContainText("John Doe");
  });

  test("handles booking validation errors", async ({ page }) => {
    await page.goto("/booking");

    // Try to submit without filling required fields
    await page.click("[data-testid=submit-booking]");

    // Check for validation errors
    await expect(page.locator("[data-testid=error-guest-name]")).toBeVisible();
    await expect(page.locator("[data-testid=error-guest-phone]")).toBeVisible();
  });
});
```

### API Integration Test

```typescript
import { rest } from "msw";
import { setupServer } from "msw/node";
import { render, screen, waitFor } from "@testing-library/react";
import { BookingCalendar } from "@/components/booking/BookingCalendar";

// Mock API server
const server = setupServer(
  rest.get("/api/calendar/availability", (req, res, ctx) => {
    return res(
      ctx.json({
        dates: [
          {
            date: "2024-01-15",
            sessions: [
              {
                id: "morning",
                name: "Morning Session",
                available_slots: 10,
                total_slots: 20,
              },
            ],
          },
        ],
      })
    );
  })
);

beforeAll(() => server.listen());
afterEach(() => server.resetHandlers());
afterAll(() => server.close());

describe("API Integration", () => {
  it("loads calendar availability from API", async () => {
    render(<BookingCalendar />);

    await waitFor(() => {
      expect(screen.getByText("Morning Session")).toBeInTheDocument();
    });

    expect(screen.getByText("10/20")).toBeInTheDocument();
  });

  it("handles API errors gracefully", async () => {
    server.use(
      rest.get("/api/calendar/availability", (req, res, ctx) => {
        return res(ctx.status(500), ctx.json({ error: "Server error" }));
      })
    );

    render(<BookingCalendar />);

    await waitFor(() => {
      expect(screen.getByText("Failed to load calendar")).toBeInTheDocument();
    });
  });
});
```

## 📱 PWA Configuration

### Next.js PWA Config

```javascript
// next.config.js
const withPWA = require("next-pwa")({
  dest: "public",
  register: true,
  skipWaiting: true,
  disable: process.env.NODE_ENV === "development",
  runtimeCaching: [
    {
      urlPattern: /^https:\/\/fonts\.googleapis\.com\/.*/i,
      handler: "CacheFirst",
      options: {
        cacheName: "google-fonts",
        expiration: {
          maxEntries: 4,
          maxAgeSeconds: 365 * 24 * 60 * 60, // 365 days
        },
      },
    },
    {
      urlPattern: /^https:\/\/fonts\.gstatic\.com\/.*/i,
      handler: "CacheFirst",
      options: {
        cacheName: "google-fonts-static",
        expiration: {
          maxEntries: 4,
          maxAgeSeconds: 365 * 24 * 60 * 60, // 365 days
        },
      },
    },
    {
      urlPattern: /\.(?:eot|otf|ttc|ttf|woff|woff2|font.css)$/i,
      handler: "StaleWhileRevalidate",
      options: {
        cacheName: "static-font-assets",
        expiration: {
          maxEntries: 4,
          maxAgeSeconds: 7 * 24 * 60 * 60, // 7 days
        },
      },
    },
    {
      urlPattern: /\.(?:jpg|jpeg|gif|png|svg|ico|webp)$/i,
      handler: "StaleWhileRevalidate",
      options: {
        cacheName: "static-image-assets",
        expiration: {
          maxEntries: 64,
          maxAgeSeconds: 24 * 60 * 60, // 24 hours
        },
      },
    },
    {
      urlPattern: /\/_next\/image\?url=.+$/i,
      handler: "StaleWhileRevalidate",
      options: {
        cacheName: "next-image",
        expiration: {
          maxEntries: 64,
          maxAgeSeconds: 24 * 60 * 60, // 24 hours
        },
      },
    },
    {
      urlPattern: /\.(?:js)$/i,
      handler: "StaleWhileRevalidate",
      options: {
        cacheName: "static-js-assets",
        expiration: {
          maxEntries: 32,
          maxAgeSeconds: 24 * 60 * 60, // 24 hours
        },
      },
    },
    {
      urlPattern: /\.(?:css|less)$/i,
      handler: "StaleWhileRevalidate",
      options: {
        cacheName: "static-style-assets",
        expiration: {
          maxEntries: 32,
          maxAgeSeconds: 24 * 60 * 60, // 24 hours
        },
      },
    },
    {
      urlPattern: /^https:\/\/.*\.(?:eot|otf|ttc|ttf|woff|woff2)$/i,
      handler: "StaleWhileRevalidate",
      options: {
        cacheName: "google-fonts-webfonts",
        expiration: {
          maxEntries: 4,
          maxAgeSeconds: 7 * 24 * 60 * 60, // 7 days
        },
      },
    },
    {
      urlPattern: /^https:\/\/fonts\.(?:googleapis|gstatic)\.com\/.*/i,
      handler: "StaleWhileRevalidate",
      options: {
        cacheName: "google-fonts",
        expiration: {
          maxEntries: 4,
          maxAgeSeconds: 7 * 24 * 60 * 60, // 7 days
        },
      },
    },
    {
      urlPattern: /^https:\/\/use\.fontawesome\.com\/.*/i,
      handler: "StaleWhileRevalidate",
      options: {
        cacheName: "fontawesome",
        expiration: {
          maxEntries: 1,
          maxAgeSeconds: 7 * 24 * 60 * 60, // 7 days
        },
      },
    },
  ],
});

module.exports = withPWA({
  reactStrictMode: true,
  swcMinify: true,
  images: {
    domains: ["localhost", "your-domain.com"],
    formats: ["image/webp", "image/avif"],
  },
  experimental: {
    optimizeCss: true,
  },
});
```

## 🚀 Deployment Configuration

### Docker Configuration

```dockerfile
# Dockerfile
FROM node:18-alpine AS base

# Install dependencies only when needed
FROM base AS deps
RUN apk add --no-cache libc6-compat
WORKDIR /app

COPY package.json package-lock.json* ./
RUN npm ci

# Rebuild the source code only when needed
FROM base AS builder
WORKDIR /app
COPY --from=deps /app/node_modules ./node_modules
COPY . .

ENV NEXT_TELEMETRY_DISABLED 1

RUN npm run build

# Production image, copy all the files and run next
FROM base AS runner
WORKDIR /app

ENV NODE_ENV production
ENV NEXT_TELEMETRY_DISABLED 1

RUN addgroup --system --gid 1001 nodejs
RUN adduser --system --uid 1001 nextjs

COPY --from=builder /app/public ./public

# Set the correct permission for prerender cache
RUN mkdir .next
RUN chown nextjs:nodejs .next

# Automatically leverage output traces to reduce image size
COPY --from=builder --chown=nextjs:nodejs /app/.next/standalone ./
COPY --from=builder --chown=nextjs:nodejs /app/.next/static ./.next/static

USER nextjs

EXPOSE 3000

ENV PORT 3000
ENV HOSTNAME "0.0.0.0"

CMD ["node", "server.js"]
```

### Environment Configuration

```bash
# .env.production
NEXT_PUBLIC_API_URL=https://api.your-domain.com
NEXT_PUBLIC_WS_URL=wss://ws.your-domain.com
NEXT_PUBLIC_GOOGLE_CLIENT_ID=your-google-client-id
NEXT_PUBLIC_SENTRY_DSN=your-sentry-dsn
NEXT_PUBLIC_GA_TRACKING_ID=your-ga-tracking-id
```

## ✅ Success Criteria

- [ ] All components terintegrasi dengan baik
- [ ] E2E testing coverage > 90%
- [ ] Performance score > 90 (Lighthouse)
- [ ] Accessibility score > 95 (WCAG 2.1 AA)
- [ ] PWA functionality berjalan sempurna
- [ ] Error handling comprehensive
- [ ] Mobile optimization optimal
- [ ] Deployment siap production
- [ ] Documentation lengkap

## 📚 Documentation

- Integration Testing Guide
- Performance Optimization Guide
- Error Handling Guide
- Accessibility Compliance Guide
- PWA Implementation Guide
- Deployment Guide
- Monitoring & Maintenance Guide
