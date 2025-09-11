# Member Quota Configuration Implementation

## 📋 Overview

Implementasi member quota configuration interface dengan quota limit management, quota tracking, dan quota analytics untuk Raujan Pool Syariah frontend.

## 🎯 Objectives

- Member quota limit configuration
- Quota tracking dan monitoring
- Quota analytics dan reporting
- Quota validation dan error handling
- Quota history management
- Quota optimization

## 🔧 Implementation Steps

### Step 1: Create Quota Configuration Components

```bash
# Create quota configuration components
mkdir -p src/components/quota
touch src/components/quota/QuotaConfigForm.tsx
touch src/components/quota/QuotaDashboard.tsx
touch src/components/quota/QuotaAnalytics.tsx
touch src/components/quota/QuotaHistory.tsx
```

**Component Structure:**

- `QuotaConfigForm` - Quota configuration form
- `QuotaDashboard` - Quota dashboard interface
- `QuotaAnalytics` - Quota analytics dan reporting
- `QuotaHistory` - Quota history tracking

### Step 2: Setup Quota Configuration Validation

```bash
# Create quota configuration validation schemas
mkdir -p src/schemas/quota
touch src/schemas/quotaSchemas.ts
touch src/schemas/quotaValidation.ts
```

**Validation Features:**

- Quota configuration validation
- Quota limit validation
- Quota tracking validation
- Quota analytics validation

### Step 3: Create Quota Configuration Pages

```bash
# Create quota configuration pages
mkdir -p src/pages/quota
touch src/pages/quota/QuotaConfigPage.tsx
touch src/pages/quota/QuotaDashboardPage.tsx
touch src/pages/quota/QuotaAnalyticsPage.tsx
touch src/pages/quota/QuotaHistoryPage.tsx
```

**Page Structure:**

- `QuotaConfigPage` - Main quota configuration page
- `QuotaDashboardPage` - Quota dashboard page
- `QuotaAnalyticsPage` - Quota analytics page
- `QuotaHistoryPage` - Quota history page

### Step 4: Setup Quota Configuration Hooks

```bash
# Create quota configuration hooks
touch src/hooks/useQuotaConfig.ts
touch src/hooks/useQuotaDashboard.ts
touch src/hooks/useQuotaAnalytics.ts
touch src/hooks/useQuotaHistory.ts
```

**Hook Features:**

- Quota configuration management
- Quota dashboard management
- Quota analytics management
- Quota history management

### Step 5: Create Quota Configuration Services

```bash
# Create quota configuration services
mkdir -p src/services/quota
touch src/services/quota/quotaConfigService.ts
touch src/services/quota/quotaDashboardService.ts
touch src/services/quota/quotaAnalyticsService.ts
```

**Service Features:**

- Quota configuration API service
- Quota dashboard API service
- Quota analytics API service
- Quota history API service

## 📊 Configuration Files

### src/schemas/quotaSchemas.ts

```typescript
// Quota configuration validation schemas
import { z } from "zod";

export const quotaConfigSchema = z.object({
  name: z.string().min(2, "Nama konfigurasi minimal 2 karakter"),
  description: z.string().optional(),
  maxMembers: z.number().min(1, "Maximum members minimal 1"),
  currentMembers: z.number().min(0, "Current members tidak boleh negatif"),
  gracePeriodDays: z
    .number()
    .min(0, "Grace period tidak boleh negatif")
    .default(90),
  warningPeriodDays: z
    .number()
    .min(0, "Warning period tidak boleh negatif")
    .default(30),
  isActive: z.boolean().default(true),
  autoPromotion: z.boolean().default(true),
  promotionRules: z
    .object({
      minQueueLength: z.number().min(1).optional(),
      maxPromotionPerDay: z.number().min(1).optional(),
      promotionPriority: z
        .enum(["fifo", "lifo", "priority", "random"])
        .default("fifo"),
    })
    .optional(),
  notifications: z
    .object({
      enableEmailNotifications: z.boolean().default(true),
      enableSMSNotifications: z.boolean().default(false),
      enablePushNotifications: z.boolean().default(true),
      notificationRecipients: z.array(z.string().email()).optional(),
    })
    .optional(),
});

export const quotaHistorySchema = z.object({
  quotaConfigId: z.string().min(1, "Quota config ID diperlukan"),
  date: z.string().min(1, "Tanggal diperlukan"),
  totalMembers: z.number().min(0, "Total members tidak boleh negatif"),
  activeMembers: z.number().min(0, "Active members tidak boleh negatif"),
  inactiveMembers: z.number().min(0, "Inactive members tidak boleh negatif"),
  queueLength: z.number().min(0, "Queue length tidak boleh negatif"),
  promotionsCount: z.number().min(0, "Promotions count tidak boleh negatif"),
  expirationsCount: z.number().min(0, "Expirations count tidak boleh negatif"),
  newRegistrations: z.number().min(0, "New registrations tidak boleh negatif"),
});

export const quotaAnalyticsSchema = z.object({
  quotaConfigId: z.string().min(1, "Quota config ID diperlukan"),
  dateRange: z.object({
    startDate: z.string().min(1, "Tanggal mulai diperlukan"),
    endDate: z.string().min(1, "Tanggal berakhir diperlukan"),
  }),
  metrics: z
    .array(
      z.enum([
        "total_members",
        "active_members",
        "inactive_members",
        "queue_length",
        "promotions_count",
        "expirations_count",
        "new_registrations",
        "quota_utilization",
        "queue_wait_time",
        "promotion_rate",
      ])
    )
    .default(["total_members", "active_members"]),
  groupBy: z.enum(["day", "week", "month", "quarter"]).default("day"),
});

export const quotaDashboardSchema = z.object({
  quotaConfigId: z.string().min(1, "Quota config ID diperlukan"),
  displayMetrics: z
    .array(
      z.enum([
        "current_quota",
        "quota_utilization",
        "queue_length",
        "recent_promotions",
        "recent_expirations",
        "quota_trends",
        "queue_trends",
        "promotion_trends",
      ])
    )
    .default(["current_quota", "quota_utilization"]),
  refreshInterval: z.number().min(30).max(3600).default(300), // dalam detik
  enableRealTimeUpdates: z.boolean().default(true),
});

export type QuotaConfigFormData = z.infer<typeof quotaConfigSchema>;
export type QuotaHistoryFormData = z.infer<typeof quotaHistorySchema>;
export type QuotaAnalyticsFormData = z.infer<typeof quotaAnalyticsSchema>;
export type QuotaDashboardFormData = z.infer<typeof quotaDashboardSchema>;
```

### src/hooks/useQuotaConfig.ts

```typescript
// Quota configuration hook
import { useState, useEffect } from "react";
import { quotaConfigService } from "@/services/quota/quotaConfigService";
import { QuotaConfigFormData } from "@/schemas/quotaSchemas";

export function useQuotaConfig() {
  const [quotaConfigs, setQuotaConfigs] = useState([]);
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const createQuotaConfig = async (data: QuotaConfigFormData) => {
    setIsLoading(true);
    setError(null);
    try {
      const newConfig = await quotaConfigService.createQuotaConfig(data);
      setQuotaConfigs((prev) => [...prev, newConfig]);
      return { success: true, config: newConfig };
    } catch (err) {
      setError(err.message);
      return { success: false, error: err.message };
    } finally {
      setIsLoading(false);
    }
  };

  const updateQuotaConfig = async (id: string, data: QuotaConfigFormData) => {
    setIsLoading(true);
    setError(null);
    try {
      const updatedConfig = await quotaConfigService.updateQuotaConfig(
        id,
        data
      );
      setQuotaConfigs((prev) =>
        prev.map((config) => (config.id === id ? updatedConfig : config))
      );
      return { success: true, config: updatedConfig };
    } catch (err) {
      setError(err.message);
      return { success: false, error: err.message };
    } finally {
      setIsLoading(false);
    }
  };

  const deleteQuotaConfig = async (id: string) => {
    setIsLoading(true);
    setError(null);
    try {
      await quotaConfigService.deleteQuotaConfig(id);
      setQuotaConfigs((prev) => prev.filter((config) => config.id !== id));
      return { success: true };
    } catch (err) {
      setError(err.message);
      return { success: false, error: err.message };
    } finally {
      setIsLoading(false);
    }
  };

  const getQuotaConfigs = async () => {
    setIsLoading(true);
    setError(null);
    try {
      const configs = await quotaConfigService.getQuotaConfigs();
      setQuotaConfigs(configs);
      return { success: true, configs };
    } catch (err) {
      setError(err.message);
      return { success: false, error: err.message };
    } finally {
      setIsLoading(false);
    }
  };

  const getQuotaConfig = async (id: string) => {
    setIsLoading(true);
    setError(null);
    try {
      const config = await quotaConfigService.getQuotaConfig(id);
      return { success: true, config };
    } catch (err) {
      setError(err.message);
      return { success: false, error: err.message };
    } finally {
      setIsLoading(false);
    }
  };

  const updateQuotaCount = async (id: string, newCount: number) => {
    setIsLoading(true);
    setError(null);
    try {
      const updatedConfig = await quotaConfigService.updateQuotaCount(
        id,
        newCount
      );
      setQuotaConfigs((prev) =>
        prev.map((config) => (config.id === id ? updatedConfig : config))
      );
      return { success: true, config: updatedConfig };
    } catch (err) {
      setError(err.message);
      return { success: false, error: err.message };
    } finally {
      setIsLoading(false);
    }
  };

  useEffect(() => {
    getQuotaConfigs();
  }, []);

  return {
    quotaConfigs,
    isLoading,
    error,
    createQuotaConfig,
    updateQuotaConfig,
    deleteQuotaConfig,
    getQuotaConfigs,
    getQuotaConfig,
    updateQuotaCount,
    clearError: () => setError(null),
  };
}
```

### src/components/quota/QuotaConfigForm.tsx

```typescript
// Quota configuration form component
import { useForm } from "react-hook-form";
import { zodResolver } from "@hookform/resolvers/zod";
import { quotaConfigSchema, QuotaConfigFormData } from "@/schemas/quotaSchemas";
import { useQuotaConfig } from "@/hooks/useQuotaConfig";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";
import { Checkbox } from "@/components/ui/checkbox";
import { Separator } from "@/components/ui/separator";

export function QuotaConfigForm() {
  const { createQuotaConfig, isLoading, error, clearError } = useQuotaConfig();

  const {
    register,
    handleSubmit,
    formState: { errors },
    reset,
    watch,
  } = useForm<QuotaConfigFormData>({
    resolver: zodResolver(quotaConfigSchema),
    defaultValues: {
      isActive: true,
      autoPromotion: true,
      gracePeriodDays: 90,
      warningPeriodDays: 30,
      promotionRules: {
        promotionPriority: "fifo",
      },
      notifications: {
        enableEmailNotifications: true,
        enableSMSNotifications: false,
        enablePushNotifications: true,
      },
    },
  });

  const autoPromotion = watch("autoPromotion");
  const enableEmailNotifications = watch(
    "notifications.enableEmailNotifications"
  );

  const onSubmit = async (data: QuotaConfigFormData) => {
    clearError();
    const result = await createQuotaConfig(data);
    if (result.success) {
      reset();
      // Show success message
    }
  };

  return (
    <Card className="w-full max-w-4xl">
      <CardHeader>
        <CardTitle>Konfigurasi Quota Member</CardTitle>
        <p className="text-sm text-gray-500">
          Konfigurasi quota member dan aturan promosi otomatis
        </p>
      </CardHeader>
      <CardContent>
        <form onSubmit={handleSubmit(onSubmit)} className="space-y-6">
          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div className="space-y-2">
              <Label htmlFor="name">Nama Konfigurasi</Label>
              <Input
                id="name"
                placeholder="Masukkan nama konfigurasi"
                {...register("name")}
              />
              {errors.name && (
                <p className="text-sm text-red-500">{errors.name.message}</p>
              )}
            </div>

            <div className="space-y-2">
              <Label htmlFor="maxMembers">Maximum Members</Label>
              <Input
                id="maxMembers"
                type="number"
                placeholder="Masukkan maximum members"
                {...register("maxMembers", { valueAsNumber: true })}
              />
              {errors.maxMembers && (
                <p className="text-sm text-red-500">
                  {errors.maxMembers.message}
                </p>
              )}
            </div>

            <div className="space-y-2">
              <Label htmlFor="currentMembers">Current Members</Label>
              <Input
                id="currentMembers"
                type="number"
                placeholder="Masukkan current members"
                {...register("currentMembers", { valueAsNumber: true })}
              />
              {errors.currentMembers && (
                <p className="text-sm text-red-500">
                  {errors.currentMembers.message}
                </p>
              )}
            </div>

            <div className="space-y-2">
              <Label htmlFor="gracePeriodDays">Grace Period (hari)</Label>
              <Input
                id="gracePeriodDays"
                type="number"
                placeholder="Masukkan grace period"
                {...register("gracePeriodDays", { valueAsNumber: true })}
              />
              {errors.gracePeriodDays && (
                <p className="text-sm text-red-500">
                  {errors.gracePeriodDays.message}
                </p>
              )}
            </div>

            <div className="space-y-2">
              <Label htmlFor="warningPeriodDays">Warning Period (hari)</Label>
              <Input
                id="warningPeriodDays"
                type="number"
                placeholder="Masukkan warning period"
                {...register("warningPeriodDays", { valueAsNumber: true })}
              />
              {errors.warningPeriodDays && (
                <p className="text-sm text-red-500">
                  {errors.warningPeriodDays.message}
                </p>
              )}
            </div>
          </div>

          <div className="space-y-2">
            <Label htmlFor="description">Deskripsi</Label>
            <Input
              id="description"
              placeholder="Masukkan deskripsi konfigurasi"
              {...register("description")}
            />
            {errors.description && (
              <p className="text-sm text-red-500">
                {errors.description.message}
              </p>
            )}
          </div>

          <Separator />

          {/* Promotion Rules */}
          <div className="space-y-4">
            <h4 className="font-medium">Aturan Promosi</h4>

            <div className="flex items-center space-x-2">
              <Checkbox id="autoPromotion" {...register("autoPromotion")} />
              <Label htmlFor="autoPromotion">Aktifkan Promosi Otomatis</Label>
            </div>

            {autoPromotion && (
              <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                <div className="space-y-2">
                  <Label htmlFor="minQueueLength">Minimum Queue Length</Label>
                  <Input
                    id="minQueueLength"
                    type="number"
                    placeholder="Masukkan minimum queue length"
                    {...register("promotionRules.minQueueLength", {
                      valueAsNumber: true,
                    })}
                  />
                </div>

                <div className="space-y-2">
                  <Label htmlFor="maxPromotionPerDay">
                    Maximum Promotion per Day
                  </Label>
                  <Input
                    id="maxPromotionPerDay"
                    type="number"
                    placeholder="Masukkan maximum promotion per day"
                    {...register("promotionRules.maxPromotionPerDay", {
                      valueAsNumber: true,
                    })}
                  />
                </div>

                <div className="space-y-2">
                  <Label htmlFor="promotionPriority">Promotion Priority</Label>
                  <Select {...register("promotionRules.promotionPriority")}>
                    <SelectTrigger>
                      <SelectValue placeholder="Pilih promotion priority" />
                    </SelectTrigger>
                    <SelectContent>
                      <SelectItem value="fifo">First In First Out</SelectItem>
                      <SelectItem value="lifo">Last In First Out</SelectItem>
                      <SelectItem value="priority">Priority Based</SelectItem>
                      <SelectItem value="random">Random</SelectItem>
                    </SelectContent>
                  </Select>
                </div>
              </div>
            )}
          </div>

          <Separator />

          {/* Notifications */}
          <div className="space-y-4">
            <h4 className="font-medium">Notifikasi</h4>

            <div className="space-y-2">
              <div className="flex items-center space-x-2">
                <Checkbox
                  id="enableEmailNotifications"
                  {...register("notifications.enableEmailNotifications")}
                />
                <Label htmlFor="enableEmailNotifications">
                  Email Notifications
                </Label>
              </div>

              <div className="flex items-center space-x-2">
                <Checkbox
                  id="enableSMSNotifications"
                  {...register("notifications.enableSMSNotifications")}
                />
                <Label htmlFor="enableSMSNotifications">
                  SMS Notifications
                </Label>
              </div>

              <div className="flex items-center space-x-2">
                <Checkbox
                  id="enablePushNotifications"
                  {...register("notifications.enablePushNotifications")}
                />
                <Label htmlFor="enablePushNotifications">
                  Push Notifications
                </Label>
              </div>
            </div>

            {enableEmailNotifications && (
              <div className="space-y-2">
                <Label htmlFor="notificationRecipients">Email Recipients</Label>
                <Input
                  id="notificationRecipients"
                  placeholder="Masukkan email recipients (pisahkan dengan koma)"
                  {...register("notifications.notificationRecipients")}
                />
              </div>
            )}
          </div>

          <div className="flex items-center space-x-2">
            <Checkbox id="isActive" {...register("isActive")} />
            <Label htmlFor="isActive">Konfigurasi Aktif</Label>
          </div>

          {error && <p className="text-sm text-red-500">{error}</p>}

          <div className="flex gap-4">
            <Button type="submit" disabled={isLoading}>
              {isLoading ? "Menyimpan..." : "Simpan Konfigurasi"}
            </Button>
            <Button type="button" variant="outline" onClick={() => reset()}>
              Reset
            </Button>
          </div>
        </form>
      </CardContent>
    </Card>
  );
}
```

## 🛠️ Development Commands

### Quota Configuration Development

```bash
# Start development server
npm run dev

# Test quota configuration components
npm run test -- --testPathPattern=quota-config

# Test quota configuration forms
npm run test -- --testPathPattern=quota-config-forms
```

### Quota Configuration Testing

```bash
# Test quota configuration functionality
npm run test src/components/quota

# Test quota configuration hooks
npm run test src/hooks/useQuotaConfig

# Test quota configuration services
npm run test src/services/quota
```

## 🎨 UI Implementation

### Quota Configuration Styling

```bash
# Create quota configuration styles
mkdir -p src/styles/quota
touch src/styles/quota/quotaConfig.css
touch src/styles/quota/quotaDashboard.css
```

**Style Features:**

- Quota configuration form styling
- Quota dashboard styling
- Quota analytics styling
- Quota history styling

### Quota Configuration Layout

```bash
# Create quota configuration layout
touch src/components/quota/QuotaLayout.tsx
touch src/components/quota/QuotaSidebar.tsx
```

**Layout Features:**

- Quota configuration page layout
- Quota configuration sidebar navigation
- Quota configuration content area
- Responsive design

## 🔧 Integration Points

### API Integration

```bash
# Create quota configuration API service
touch src/services/api/quotaConfigApi.ts
touch src/services/api/quotaDashboardApi.ts
```

**API Features:**

- Quota configuration API integration
- Quota dashboard API integration
- Quota analytics API integration
- Quota history API integration

### State Management

```bash
# Create quota configuration state management
touch src/store/quota/quotaConfigStore.ts
touch src/store/quota/quotaConfigActions.ts
```

**State Features:**

- Quota configuration state management
- Quota dashboard state management
- Quota analytics state management
- Quota history state management

## 🧪 Testing Strategy

### Unit Tests

```bash
# Test quota configuration components
mkdir -p src/components/quota/__tests__
touch src/components/quota/__tests__/QuotaConfigForm.test.tsx
touch src/components/quota/__tests__/QuotaDashboard.test.tsx
```

**Test Coverage:**

- Quota configuration form rendering
- Quota configuration form validation
- Quota dashboard functionality
- Quota analytics functionality

### Integration Tests

```bash
# Test quota configuration integration
mkdir -p src/__tests__/integration
touch src/__tests__/integration/quota-config.test.tsx
```

**Integration Tests:**

- Complete quota configuration workflow
- API integration
- State management integration
- Quota validation integration

## 📱 Mobile Considerations

### Mobile Quota Configuration

```bash
# Mobile quota configuration components
touch src/components/quota/mobile/MobileQuotaConfigForm.tsx
touch src/components/quota/mobile/MobileQuotaDashboard.tsx
```

**Mobile Features:**

- Mobile-optimized quota configuration forms
- Mobile quota dashboard
- Touch-friendly interface
- Mobile quota validation

### Performance Optimization

```bash
# Quota configuration performance optimization
touch src/hooks/useQuotaConfigPerformance.ts
```

**Optimizations:**

- Quota configuration form optimization
- Quota dashboard optimization
- Quota validation optimization
- API call optimization

## 🔒 Security Considerations

### Quota Configuration Security

```bash
# Quota configuration security utilities
touch src/utils/quotaConfigSecurity.ts
touch src/utils/quotaConfigValidation.ts
```

**Security Features:**

- Quota configuration validation
- Quota limit validation
- Quota tracking validation
- Quota analytics validation

### Data Protection

```bash
# Data protection utilities
touch src/utils/quotaConfigDataProtection.ts
touch src/utils/quotaConfigPrivacy.ts
```

**Protection Features:**

- Quota configuration data protection
- Quota tracking data protection
- Sensitive quota data masking
- Privacy compliance

## 📊 Analytics & Monitoring

### Quota Configuration Analytics

```bash
# Quota configuration analytics
touch src/utils/quotaConfigAnalytics.ts
touch src/hooks/useQuotaConfigAnalytics.ts
```

**Analytics Features:**

- Quota configuration usage tracking
- Quota dashboard analytics
- Quota analytics usage tracking
- Quota history analytics

### Error Monitoring

```bash
# Error monitoring untuk quota configuration
touch src/utils/quotaConfigErrorMonitoring.ts
touch src/hooks/useQuotaConfigErrorMonitoring.ts
```

**Monitoring Features:**

- Quota configuration error tracking
- Quota dashboard error monitoring
- Quota analytics error monitoring
- API error monitoring

## ✅ Success Criteria

- [ ] Member quota limit configuration berfungsi
- [ ] Quota tracking dan monitoring implemented
- [ ] Quota analytics dan reporting berfungsi
- [ ] Quota validation dan error handling implemented
- [ ] Quota history management berfungsi
- [ ] Quota optimization implemented
- [ ] Quota configuration forms dengan proper validation
- [ ] Quota configuration hooks dengan error handling
- [ ] Quota configuration API integration
- [ ] Unit tests untuk quota configuration components
- [ ] Integration tests untuk quota configuration workflow
- [ ] Security measures untuk quota configuration data
- [ ] Data protection untuk sensitive quota information
- [ ] Analytics tracking untuk quota configuration usage
- [ ] Error monitoring dan alerting
- [ ] Performance optimization untuk quota configuration
- [ ] Mobile-responsive quota configuration interface
- [ ] Accessibility features maintained
- [ ] Quota configuration system health monitoring
- [ ] Quota configuration system documentation dan user guides

## 📝 Notes

- Pastikan quota configuration aman dan tidak vulnerable
- Implementasi proper validation untuk semua quota inputs
- Setup proper error handling untuk quota configuration operations
- Test quota configuration system dengan various scenarios
- Consider implementing quota configuration backup strategies
- Implementasi quota configuration system reporting features
- Consider adding quota configuration notifications
- Implementasi quota configuration system health monitoring
- Add quota configuration system documentation dan training materials
