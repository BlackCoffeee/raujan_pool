# Environment Configuration Implementation

## 📋 Overview

Implementasi environment configuration untuk multiple stages (development, staging, production) dengan proper environment variable management dan configuration validation.

## 🎯 Objectives

- Multiple environment setup
- Environment variable management
- Configuration validation
- Security configuration
- Feature flags management
- Build configuration

## 🔧 Implementation Steps

### Step 1: Create Environment Files

```bash
# Create environment files
touch .env.example
touch .env.local
touch .env.development
touch .env.staging
touch .env.production
```

**Environment Files:**

- `.env.example` - Template untuk environment variables
- `.env.local` - Local development overrides
- `.env.development` - Development environment
- `.env.staging` - Staging environment
- `.env.production` - Production environment

### Step 2: Setup Environment Configuration

```bash
# Create environment configuration
mkdir -p src/config/environments
touch src/config/environments/index.ts
touch src/config/environments/development.ts
touch src/config/environments/staging.ts
touch src/config/environments/production.ts
```

**Configuration Structure:**

- Environment-specific configurations
- Type-safe environment variables
- Configuration validation
- Default values

### Step 3: Create Environment Service

```bash
# Create environment service
touch src/services/environmentService.ts
touch src/utils/environmentHelpers.ts
```

**Environment Service:**

- Environment variable access
- Configuration validation
- Environment detection
- Security measures

### Step 4: Setup Vite Configuration

```bash
# Create Vite configurations
touch vite.config.development.ts
touch vite.config.staging.ts
touch vite.config.production.ts
```

**Vite Configuration:**

- Environment-specific builds
- Asset optimization
- Development tools
- Production optimizations

### Step 5: Create Environment Types

```bash
# Create environment types
touch src/types/environment.ts
touch src/types/config.ts
```

**Environment Types:**

- TypeScript interfaces
- Environment validation
- Configuration types
- Feature flag types

## 📊 Configuration Files

### .env.example

```env
# API Configuration
VITE_API_URL=http://localhost:8000/api
VITE_SOCKET_URL=http://localhost:8000

# Authentication
VITE_GOOGLE_CLIENT_ID=your_google_client_id
VITE_GOOGLE_CLIENT_SECRET=your_google_client_secret

# Features
VITE_ENABLE_ANALYTICS=true
VITE_ENABLE_DEBUG=false
VITE_ENABLE_MOCK_API=false

# App Configuration
VITE_APP_NAME=Raujan Pool Syariah
VITE_APP_VERSION=1.0.0
VITE_APP_ENVIRONMENT=development

# External Services
VITE_STRIPE_PUBLISHABLE_KEY=your_stripe_key
VITE_MIDTRANS_CLIENT_KEY=your_midtrans_key
```

### src/config/environments/index.ts

```typescript
// Environment configuration
export interface EnvironmentConfig {
  api: {
    baseUrl: string;
    timeout: number;
    retries: number;
  };
  auth: {
    googleClientId: string;
    tokenExpiry: number;
  };
  features: {
    analytics: boolean;
    debug: boolean;
    mockApi: boolean;
  };
  app: {
    name: string;
    version: string;
    environment: string;
  };
  external: {
    stripe: string;
    midtrans: string;
  };
}

export const getConfig = (): EnvironmentConfig => {
  const env = import.meta.env.MODE;

  switch (env) {
    case "development":
      return developmentConfig;
    case "staging":
      return stagingConfig;
    case "production":
      return productionConfig;
    default:
      return developmentConfig;
  }
};
```

### src/config/environments/development.ts

```typescript
// Development environment configuration
export const developmentConfig: EnvironmentConfig = {
  api: {
    baseUrl: import.meta.env.VITE_API_URL || "http://localhost:8000/api",
    timeout: 10000,
    retries: 3,
  },
  auth: {
    googleClientId: import.meta.env.VITE_GOOGLE_CLIENT_ID || "",
    tokenExpiry: 3600,
  },
  features: {
    analytics: import.meta.env.VITE_ENABLE_ANALYTICS === "true",
    debug: import.meta.env.VITE_ENABLE_DEBUG === "true",
    mockApi: import.meta.env.VITE_ENABLE_MOCK_API === "true",
  },
  app: {
    name: import.meta.env.VITE_APP_NAME || "Raujan Pool Syariah",
    version: import.meta.env.VITE_APP_VERSION || "1.0.0",
    environment: "development",
  },
  external: {
    stripe: import.meta.env.VITE_STRIPE_PUBLISHABLE_KEY || "",
    midtrans: import.meta.env.VITE_MIDTRANS_CLIENT_KEY || "",
  },
};
```

### src/services/environmentService.ts

```typescript
// Environment service
import { getConfig } from "@/config/environments";

export class EnvironmentService {
  private static instance: EnvironmentService;
  private config: EnvironmentConfig;

  private constructor() {
    this.config = getConfig();
    this.validateConfig();
  }

  public static getInstance(): EnvironmentService {
    if (!EnvironmentService.instance) {
      EnvironmentService.instance = new EnvironmentService();
    }
    return EnvironmentService.instance;
  }

  public getConfig(): EnvironmentConfig {
    return this.config;
  }

  public getApiUrl(): string {
    return this.config.api.baseUrl;
  }

  public getGoogleClientId(): string {
    return this.config.auth.googleClientId;
  }

  public isFeatureEnabled(
    feature: keyof EnvironmentConfig["features"]
  ): boolean {
    return this.config.features[feature];
  }

  public isDevelopment(): boolean {
    return this.config.app.environment === "development";
  }

  public isProduction(): boolean {
    return this.config.app.environment === "production";
  }

  private validateConfig(): void {
    const required = ["api.baseUrl", "auth.googleClientId"];

    for (const field of required) {
      const value = this.getNestedValue(this.config, field);
      if (!value) {
        throw new Error(`Missing required environment variable: ${field}`);
      }
    }
  }

  private getNestedValue(obj: any, path: string): any {
    return path.split(".").reduce((current, key) => current?.[key], obj);
  }
}
```

## 🛠️ Development Commands

### Environment Development

```bash
# Start development server
npm run dev

# Start staging server
npm run dev:staging

# Build for production
npm run build

# Build for staging
npm run build:staging
```

### Environment Testing

```bash
# Test environment configuration
npm run test -- --testPathPattern=environment

# Test configuration validation
npm run test -- --testPathPattern=config
```

## 🎨 UI Implementation

### Environment Detection

```bash
# Create environment detection components
touch src/components/ui/EnvironmentIndicator.tsx
touch src/hooks/useEnvironment.ts
```

**Environment Features:**

- Environment indicator
- Environment-specific features
- Debug information
- Configuration display

### Feature Flags

```bash
# Create feature flag components
touch src/components/ui/FeatureFlag.tsx
touch src/hooks/useFeatureFlag.ts
```

**Feature Flag Features:**

- Conditional rendering
- Feature toggles
- A/B testing support
- Gradual rollouts

## 🔧 Integration Points

### API Configuration

```bash
# Create API configuration
touch src/services/api/config.ts
touch src/services/api/interceptors.ts
```

**API Features:**

- Environment-specific endpoints
- Request/response interceptors
- Error handling
- Retry logic

### Build Configuration

```bash
# Create build configuration
touch vite.config.base.ts
touch vite.config.plugins.ts
```

**Build Features:**

- Environment-specific builds
- Asset optimization
- Bundle analysis
- Development tools

## 🧪 Testing Strategy

### Unit Tests

```bash
# Test environment configuration
mkdir -p src/config/__tests__
touch src/config/__tests__/environment.test.ts
touch src/config/__tests__/validation.test.ts
```

**Test Coverage:**

- Environment configuration
- Configuration validation
- Feature flags
- Environment detection

### Integration Tests

```bash
# Test environment integration
mkdir -p src/__tests__/integration
touch src/__tests__/integration/environment.test.tsx
```

**Integration Tests:**

- Complete environment setup
- Configuration loading
- Feature flag integration
- Build process

## 📱 Mobile Considerations

### Mobile Environment

```bash
# Mobile environment configuration
touch src/config/environments/mobile.ts
touch src/hooks/useMobileEnvironment.ts
```

**Mobile Features:**

- Mobile-specific configurations
- Touch-friendly features
- Performance optimizations
- Offline support

### Performance Optimization

```bash
# Environment performance optimization
touch src/utils/environmentPerformance.ts
touch src/hooks/useEnvironmentPerformance.ts
```

**Optimizations:**

- Lazy loading configurations
- Environment caching
- Performance monitoring
- Bundle optimization

## 🔒 Security Considerations

### Environment Security

```bash
# Environment security utilities
touch src/utils/environmentSecurity.ts
touch src/utils/configValidation.ts
```

**Security Features:**

- Environment variable validation
- Sensitive data protection
- Configuration encryption
- Access control

### Data Protection

```bash
# Data protection utilities
touch src/utils/environmentDataProtection.ts
touch src/utils/configMasking.ts
```

**Protection Features:**

- Sensitive data masking
- Configuration anonymization
- Data retention policies
- Compliance measures

## 📊 Analytics & Monitoring

### Environment Analytics

```bash
# Environment analytics
touch src/utils/environmentAnalytics.ts
touch src/hooks/useEnvironmentAnalytics.ts
```

**Analytics Features:**

- Environment usage tracking
- Configuration performance
- Feature flag analytics
- Error tracking

### Error Monitoring

```bash
# Error monitoring untuk environment
touch src/utils/environmentErrorMonitoring.ts
touch src/hooks/useEnvironmentErrorMonitoring.ts
```

**Monitoring Features:**

- Environment error tracking
- Configuration failure monitoring
- Performance metrics
- System alerts

## ✅ Success Criteria

- [ ] Multiple environment setup (development, staging, production)
- [ ] Environment variable management dengan validation
- [ ] Configuration validation dan error handling
- [ ] Security configuration untuk sensitive data
- [ ] Feature flags management system
- [ ] Build configuration untuk semua environments
- [ ] Environment service dengan type safety
- [ ] Configuration caching dan optimization
- [ ] Unit tests untuk environment configuration
- [ ] Integration tests untuk environment setup
- [ ] Security measures untuk environment variables
- [ ] Data protection untuk sensitive configuration
- [ ] Analytics tracking untuk environment usage
- [ ] Error monitoring dan alerting
- [ ] Performance optimization untuk configuration loading
- [ ] Mobile-responsive environment configuration
- [ ] Accessibility features maintained
- [ ] Environment configuration system health monitoring
- [ ] Environment configuration documentation dan user guides

## 📝 Notes

- Pastikan environment variables aman dan tidak exposed di client-side
- Implementasi proper validation untuk semua environment configurations
- Setup feature flags untuk gradual rollouts
- Test environment configuration dengan berbagai scenarios
- Consider implementing environment configuration backup strategies
- Implementasi environment configuration system reporting features
- Consider adding environment configuration notifications
- Implementasi environment configuration system health monitoring
- Add environment configuration system documentation dan training materials
