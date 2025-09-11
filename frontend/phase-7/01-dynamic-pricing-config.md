# Dynamic Pricing Configuration Implementation

## 📋 Overview

Implementasi dynamic pricing configuration interface dengan pricing rules, time-based pricing, dan capacity-based pricing untuk Raujan Pool Syariah frontend.

## 🎯 Objectives

- Dynamic pricing configuration interface
- Pricing rules management
- Time-based pricing configuration
- Capacity-based pricing configuration
- Event-based pricing configuration
- Pricing validation dan error handling

## 🔧 Implementation Steps

### Step 1: Create Pricing Configuration Components

```bash
# Create pricing configuration components
mkdir -p src/components/pricing
touch src/components/pricing/PricingConfigForm.tsx
touch src/components/pricing/PricingRulesBuilder.tsx
touch src/components/pricing/TimeBasedPricing.tsx
touch src/components/pricing/CapacityBasedPricing.tsx
```

**Component Structure:**

- `PricingConfigForm` - Main pricing configuration form
- `PricingRulesBuilder` - Pricing rules builder interface
- `TimeBasedPricing` - Time-based pricing configuration
- `CapacityBasedPricing` - Capacity-based pricing configuration

### Step 2: Setup Pricing Configuration Validation

```bash
# Create pricing validation schemas
mkdir -p src/schemas/pricing
touch src/schemas/pricingSchemas.ts
touch src/schemas/pricingValidation.ts
```

**Validation Features:**

- Pricing configuration validation
- Pricing rules validation
- Time-based pricing validation
- Capacity-based pricing validation

### Step 3: Create Pricing Configuration Pages

```bash
# Create pricing configuration pages
mkdir -p src/pages/pricing
touch src/pages/pricing/PricingConfigPage.tsx
touch src/pages/pricing/PricingRulesPage.tsx
touch src/pages/pricing/TimeBasedPricingPage.tsx
touch src/pages/pricing/CapacityBasedPricingPage.tsx
```

**Page Structure:**

- `PricingConfigPage` - Main pricing configuration page
- `PricingRulesPage` - Pricing rules management page
- `TimeBasedPricingPage` - Time-based pricing page
- `CapacityBasedPricingPage` - Capacity-based pricing page

### Step 4: Setup Pricing Configuration Hooks

```bash
# Create pricing configuration hooks
touch src/hooks/usePricingConfig.ts
touch src/hooks/usePricingRules.ts
touch src/hooks/useTimeBasedPricing.ts
touch src/hooks/useCapacityBasedPricing.ts
```

**Hook Features:**

- Pricing configuration management
- Pricing rules management
- Time-based pricing management
- Capacity-based pricing management

### Step 5: Create Pricing Configuration Services

```bash
# Create pricing configuration services
mkdir -p src/services/pricing
touch src/services/pricing/pricingConfigService.ts
touch src/services/pricing/pricingRulesService.ts
touch src/services/pricing/timeBasedPricingService.ts
```

**Service Features:**

- Pricing configuration API service
- Pricing rules API service
- Time-based pricing API service
- Capacity-based pricing API service

## 📊 Configuration Files

### src/schemas/pricingSchemas.ts

```typescript
// Pricing configuration validation schemas
import { z } from "zod";

export const pricingConfigSchema = z.object({
  name: z.string().min(2, "Nama konfigurasi minimal 2 karakter"),
  description: z.string().optional(),
  basePrice: z.number().min(0, "Harga dasar tidak boleh negatif"),
  currency: z.string().default("IDR"),
  isActive: z.boolean().default(true),
  validFrom: z.string().min(1, "Tanggal mulai diperlukan"),
  validTo: z.string().min(1, "Tanggal berakhir diperlukan"),
  pricingRules: z.array(
    z.object({
      id: z.string(),
      name: z.string(),
      type: z.enum(["time_based", "capacity_based", "event_based"]),
      conditions: z.record(z.any()),
      priceModifier: z.number(),
      isActive: z.boolean(),
    })
  ),
});

export const timeBasedPricingSchema = z.object({
  timeSlots: z.array(
    z.object({
      startTime: z.string().min(1, "Waktu mulai diperlukan"),
      endTime: z.string().min(1, "Waktu berakhir diperlukan"),
      priceMultiplier: z.number().min(0.1, "Multiplier minimal 0.1"),
      isActive: z.boolean().default(true),
    })
  ),
  daysOfWeek: z.array(z.number().min(0).max(6)).default([0, 1, 2, 3, 4, 5, 6]),
  specialDates: z
    .array(
      z.object({
        date: z.string().min(1, "Tanggal diperlukan"),
        priceMultiplier: z.number().min(0.1, "Multiplier minimal 0.1"),
        description: z.string().optional(),
      })
    )
    .optional(),
});

export const capacityBasedPricingSchema = z.object({
  capacityThresholds: z.array(
    z.object({
      minCapacity: z.number().min(0, "Kapasitas minimal tidak boleh negatif"),
      maxCapacity: z.number().min(0, "Kapasitas maksimal tidak boleh negatif"),
      priceMultiplier: z.number().min(0.1, "Multiplier minimal 0.1"),
      isActive: z.boolean().default(true),
    })
  ),
  poolId: z.string().min(1, "Pool ID diperlukan"),
  sessionType: z.enum(["regular", "private", "vip"]).default("regular"),
});

export type PricingConfigFormData = z.infer<typeof pricingConfigSchema>;
export type TimeBasedPricingFormData = z.infer<typeof timeBasedPricingSchema>;
export type CapacityBasedPricingFormData = z.infer<
  typeof capacityBasedPricingSchema
>;
```

### src/hooks/usePricingConfig.ts

```typescript
// Pricing configuration hook
import { useState, useEffect } from "react";
import { pricingConfigService } from "@/services/pricing/pricingConfigService";
import { PricingConfigFormData } from "@/schemas/pricingSchemas";

export function usePricingConfig() {
  const [configs, setConfigs] = useState([]);
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const createPricingConfig = async (data: PricingConfigFormData) => {
    setIsLoading(true);
    setError(null);
    try {
      const newConfig = await pricingConfigService.createConfig(data);
      setConfigs((prev) => [...prev, newConfig]);
      return { success: true, config: newConfig };
    } catch (err) {
      setError(err.message);
      return { success: false, error: err.message };
    } finally {
      setIsLoading(false);
    }
  };

  const updatePricingConfig = async (
    id: string,
    data: PricingConfigFormData
  ) => {
    setIsLoading(true);
    setError(null);
    try {
      const updatedConfig = await pricingConfigService.updateConfig(id, data);
      setConfigs((prev) =>
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

  const deletePricingConfig = async (id: string) => {
    setIsLoading(true);
    setError(null);
    try {
      await pricingConfigService.deleteConfig(id);
      setConfigs((prev) => prev.filter((config) => config.id !== id));
      return { success: true };
    } catch (err) {
      setError(err.message);
      return { success: false, error: err.message };
    } finally {
      setIsLoading(false);
    }
  };

  const getPricingConfigs = async () => {
    setIsLoading(true);
    setError(null);
    try {
      const configsData = await pricingConfigService.getConfigs();
      setConfigs(configsData);
      return { success: true, configs: configsData };
    } catch (err) {
      setError(err.message);
      return { success: false, error: err.message };
    } finally {
      setIsLoading(false);
    }
  };

  useEffect(() => {
    getPricingConfigs();
  }, []);

  return {
    configs,
    isLoading,
    error,
    createPricingConfig,
    updatePricingConfig,
    deletePricingConfig,
    getPricingConfigs,
    clearError: () => setError(null),
  };
}
```

### src/components/pricing/PricingConfigForm.tsx

```typescript
// Pricing configuration form component
import { useForm } from "react-hook-form";
import { zodResolver } from "@hookform/resolvers/zod";
import {
  pricingConfigSchema,
  PricingConfigFormData,
} from "@/schemas/pricingSchemas";
import { usePricingConfig } from "@/hooks/usePricingConfig";
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

export function PricingConfigForm() {
  const { createPricingConfig, isLoading, error, clearError } =
    usePricingConfig();

  const {
    register,
    handleSubmit,
    formState: { errors },
    reset,
    watch,
  } = useForm<PricingConfigFormData>({
    resolver: zodResolver(pricingConfigSchema),
    defaultValues: {
      currency: "IDR",
      isActive: true,
      pricingRules: [],
    },
  });

  const onSubmit = async (data: PricingConfigFormData) => {
    clearError();
    const result = await createPricingConfig(data);
    if (result.success) {
      reset();
      // Show success message
    }
  };

  return (
    <Card className="w-full max-w-4xl">
      <CardHeader>
        <CardTitle>Konfigurasi Harga Dinamis</CardTitle>
        <p className="text-sm text-gray-500">
          Buat konfigurasi harga yang dapat disesuaikan berdasarkan waktu,
          kapasitas, dan event
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
              <Label htmlFor="basePrice">Harga Dasar (IDR)</Label>
              <Input
                id="basePrice"
                type="number"
                placeholder="Masukkan harga dasar"
                {...register("basePrice", { valueAsNumber: true })}
              />
              {errors.basePrice && (
                <p className="text-sm text-red-500">
                  {errors.basePrice.message}
                </p>
              )}
            </div>

            <div className="space-y-2">
              <Label htmlFor="currency">Mata Uang</Label>
              <Select {...register("currency")}>
                <SelectTrigger>
                  <SelectValue placeholder="Pilih mata uang" />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="IDR">IDR (Rupiah)</SelectItem>
                  <SelectItem value="USD">USD (Dollar)</SelectItem>
                </SelectContent>
              </Select>
              {errors.currency && (
                <p className="text-sm text-red-500">
                  {errors.currency.message}
                </p>
              )}
            </div>

            <div className="space-y-2">
              <Label htmlFor="validFrom">Tanggal Mulai</Label>
              <Input id="validFrom" type="date" {...register("validFrom")} />
              {errors.validFrom && (
                <p className="text-sm text-red-500">
                  {errors.validFrom.message}
                </p>
              )}
            </div>

            <div className="space-y-2">
              <Label htmlFor="validTo">Tanggal Berakhir</Label>
              <Input id="validTo" type="date" {...register("validTo")} />
              {errors.validTo && (
                <p className="text-sm text-red-500">{errors.validTo.message}</p>
              )}
            </div>

            <div className="space-y-2">
              <div className="flex items-center space-x-2">
                <Checkbox id="isActive" {...register("isActive")} />
                <Label htmlFor="isActive">Konfigurasi Aktif</Label>
              </div>
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

### Dynamic Pricing Development

```bash
# Start development server
npm run dev

# Test pricing configuration components
npm run test -- --testPathPattern=pricing

# Test pricing configuration forms
npm run test -- --testPathPattern=pricing-config
```

### Dynamic Pricing Testing

```bash
# Test pricing configuration functionality
npm run test src/components/pricing

# Test pricing configuration hooks
npm run test src/hooks/usePricingConfig

# Test pricing configuration services
npm run test src/services/pricing
```

## 🎨 UI Implementation

### Pricing Configuration Styling

```bash
# Create pricing configuration styles
mkdir -p src/styles/pricing
touch src/styles/pricing/pricingConfig.css
touch src/styles/pricing/pricingRules.css
```

**Style Features:**

- Pricing configuration form styling
- Pricing rules builder styling
- Time-based pricing styling
- Capacity-based pricing styling

### Pricing Configuration Layout

```bash
# Create pricing configuration layout
touch src/components/pricing/PricingConfigLayout.tsx
touch src/components/pricing/PricingConfigSidebar.tsx
```

**Layout Features:**

- Pricing configuration page layout
- Pricing configuration sidebar navigation
- Pricing configuration content area
- Responsive design

## 🔧 Integration Points

### API Integration

```bash
# Create pricing configuration API service
touch src/services/api/pricingConfigApi.ts
touch src/services/api/pricingRulesApi.ts
```

**API Features:**

- Pricing configuration API integration
- Pricing rules API integration
- Time-based pricing API integration
- Capacity-based pricing API integration

### State Management

```bash
# Create pricing configuration state management
touch src/store/pricing/pricingConfigStore.ts
touch src/store/pricing/pricingConfigActions.ts
```

**State Features:**

- Pricing configuration state management
- Pricing rules state management
- Time-based pricing state management
- Capacity-based pricing state management

## 🧪 Testing Strategy

### Unit Tests

```bash
# Test pricing configuration components
mkdir -p src/components/pricing/__tests__
touch src/components/pricing/__tests__/PricingConfigForm.test.tsx
touch src/components/pricing/__tests__/PricingRulesBuilder.test.tsx
```

**Test Coverage:**

- Pricing configuration form rendering
- Pricing configuration form validation
- Pricing rules builder functionality
- Time-based pricing functionality

### Integration Tests

```bash
# Test pricing configuration integration
mkdir -p src/__tests__/integration
touch src/__tests__/integration/pricing-config.test.tsx
```

**Integration Tests:**

- Complete pricing configuration workflow
- API integration
- State management integration
- Pricing validation integration

## 📱 Mobile Considerations

### Mobile Pricing Configuration

```bash
# Mobile pricing configuration components
touch src/components/pricing/mobile/MobilePricingConfigForm.tsx
touch src/components/pricing/mobile/MobilePricingRulesBuilder.tsx
```

**Mobile Features:**

- Mobile-optimized pricing configuration forms
- Mobile pricing rules builder
- Touch-friendly interface
- Mobile pricing validation

### Performance Optimization

```bash
# Pricing configuration performance optimization
touch src/hooks/usePricingConfigPerformance.ts
```

**Optimizations:**

- Pricing configuration form optimization
- Pricing rules builder optimization
- Pricing validation optimization
- API call optimization

## 🔒 Security Considerations

### Pricing Configuration Security

```bash
# Pricing configuration security utilities
touch src/utils/pricingConfigSecurity.ts
touch src/utils/pricingValidation.ts
```

**Security Features:**

- Pricing configuration validation
- Pricing rules validation
- Time-based pricing validation
- Capacity-based pricing validation

### Data Protection

```bash
# Data protection utilities
touch src/utils/pricingDataProtection.ts
touch src/utils/pricingPrivacy.ts
```

**Protection Features:**

- Pricing configuration data protection
- Pricing rules data protection
- Sensitive pricing data masking
- Privacy compliance

## 📊 Analytics & Monitoring

### Pricing Configuration Analytics

```bash
# Pricing configuration analytics
touch src/utils/pricingConfigAnalytics.ts
touch src/hooks/usePricingConfigAnalytics.ts
```

**Analytics Features:**

- Pricing configuration usage tracking
- Pricing rules usage analytics
- Time-based pricing analytics
- Capacity-based pricing analytics

### Error Monitoring

```bash
# Error monitoring untuk pricing configuration
touch src/utils/pricingConfigErrorMonitoring.ts
touch src/hooks/usePricingConfigErrorMonitoring.ts
```

**Monitoring Features:**

- Pricing configuration error tracking
- Pricing rules error monitoring
- API error monitoring
- System alerts

## ✅ Success Criteria

- [ ] Dynamic pricing configuration interface berfungsi
- [ ] Pricing rules management implemented
- [ ] Time-based pricing configuration berfungsi
- [ ] Capacity-based pricing configuration implemented
- [ ] Event-based pricing configuration berfungsi
- [ ] Pricing validation dan error handling implemented
- [ ] Pricing configuration forms dengan proper validation
- [ ] Pricing configuration hooks dengan error handling
- [ ] Pricing configuration API integration
- [ ] Unit tests untuk pricing configuration components
- [ ] Integration tests untuk pricing configuration workflow
- [ ] Security measures untuk pricing configuration data
- [ ] Data protection untuk sensitive pricing information
- [ ] Analytics tracking untuk pricing configuration usage
- [ ] Error monitoring dan alerting
- [ ] Performance optimization untuk pricing configuration forms
- [ ] Mobile-responsive pricing configuration interface
- [ ] Accessibility features maintained
- [ ] Pricing configuration system health monitoring
- [ ] Pricing configuration system documentation dan user guides

## 📝 Notes

- Pastikan pricing configuration aman dan tidak vulnerable
- Implementasi proper validation untuk semua pricing inputs
- Setup proper error handling untuk pricing configuration operations
- Test pricing configuration system dengan various scenarios
- Consider implementing pricing configuration backup strategies
- Implementasi pricing configuration system reporting features
- Consider adding pricing configuration notifications
- Implementasi pricing configuration system health monitoring
- Add pricing configuration system documentation dan training materials
