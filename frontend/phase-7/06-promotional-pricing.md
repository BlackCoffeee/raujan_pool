# Promotional Pricing Application Implementation

## 📋 Overview

Implementasi promotional pricing application interface dengan automatic pricing application, promotional pricing display, dan promotional pricing analytics untuk Raujan Pool Syariah frontend.

## 🎯 Objectives

- Automatic promotional pricing application
- Promotional pricing display interface
- Promotional pricing analytics
- Promotional pricing optimization
- Promotional pricing performance tracking
- Promotional pricing customer experience

## 🔧 Implementation Steps

### Step 1: Create Promotional Pricing Components

```bash
# Create promotional pricing components
mkdir -p src/components/pricing/promotional
touch src/components/pricing/promotional/PromotionalPricingDisplay.tsx
touch src/components/pricing/promotional/PromotionalPricingCalculator.tsx
touch src/components/pricing/promotional/PromotionalPricingAnalytics.tsx
touch src/components/pricing/promotional/PromotionalPricingOptimizer.tsx
```

**Component Structure:**

- `PromotionalPricingDisplay` - Promotional pricing display interface
- `PromotionalPricingCalculator` - Promotional pricing calculator
- `PromotionalPricingAnalytics` - Promotional pricing analytics
- `PromotionalPricingOptimizer` - Promotional pricing optimizer

### Step 2: Setup Promotional Pricing Validation

```bash
# Create promotional pricing validation schemas
mkdir -p src/schemas/pricing/promotional
touch src/schemas/promotionalPricingSchemas.ts
touch src/schemas/promotionalPricingApplicationSchemas.ts
```

**Validation Features:**

- Promotional pricing validation
- Promotional pricing application validation
- Promotional pricing display validation
- Promotional pricing analytics validation

### Step 3: Create Promotional Pricing Pages

```bash
# Create promotional pricing pages
mkdir -p src/pages/pricing/promotional
touch src/pages/pricing/promotional/PromotionalPricingPage.tsx
touch src/pages/pricing/promotional/PromotionalPricingAnalyticsPage.tsx
touch src/pages/pricing/promotional/PromotionalPricingOptimizationPage.tsx
touch src/pages/pricing/promotional/PromotionalPricingPerformancePage.tsx
```

**Page Structure:**

- `PromotionalPricingPage` - Main promotional pricing page
- `PromotionalPricingAnalyticsPage` - Promotional pricing analytics page
- `PromotionalPricingOptimizationPage` - Promotional pricing optimization page
- `PromotionalPricingPerformancePage` - Promotional pricing performance page

### Step 4: Setup Promotional Pricing Hooks

```bash
# Create promotional pricing hooks
touch src/hooks/usePromotionalPricing.ts
touch src/hooks/usePromotionalPricingApplication.ts
touch src/hooks/usePromotionalPricingAnalytics.ts
touch src/hooks/usePromotionalPricingOptimization.ts
```

**Hook Features:**

- Promotional pricing management
- Promotional pricing application management
- Promotional pricing analytics management
- Promotional pricing optimization management

### Step 5: Create Promotional Pricing Services

```bash
# Create promotional pricing services
mkdir -p src/services/pricing/promotional
touch src/services/pricing/promotional/promotionalPricingService.ts
touch src/services/pricing/promotional/promotionalPricingApplicationService.ts
touch src/services/pricing/promotional/promotionalPricingAnalyticsService.ts
```

**Service Features:**

- Promotional pricing API service
- Promotional pricing application API service
- Promotional pricing analytics API service
- Promotional pricing optimization API service

## 📊 Configuration Files

### src/schemas/promotionalPricingSchemas.ts

```typescript
// Promotional pricing validation schemas
import { z } from "zod";

export const promotionalPricingApplicationSchema = z.object({
  campaignId: z.string().min(1, "Campaign ID diperlukan"),
  userId: z.string().min(1, "User ID diperlukan"),
  serviceType: z.enum(["pool_booking", "cafe_order", "private_pool"]),
  originalPrice: z.number().min(0, "Original price tidak boleh negatif"),
  quantity: z.number().min(1, "Quantity minimal 1"),
  date: z.string().min(1, "Tanggal diperlukan"),
  time: z.string().min(1, "Waktu diperlukan"),
  applicableDiscounts: z.array(
    z.object({
      discountId: z.string(),
      discountName: z.string(),
      discountType: z.enum(["percentage", "fixed_amount", "bogo"]),
      discountValue: z.number(),
      eligibility: z.boolean(),
      reason: z.string().optional(),
    })
  ),
  finalPrice: z.number().min(0, "Final price tidak boleh negatif"),
  totalSavings: z.number().min(0, "Total savings tidak boleh negatif"),
});

export const promotionalPricingDisplaySchema = z.object({
  originalPrice: z.number().min(0, "Original price tidak boleh negatif"),
  discountedPrice: z.number().min(0, "Discounted price tidak boleh negatif"),
  discountAmount: z.number().min(0, "Discount amount tidak boleh negatif"),
  discountPercentage: z
    .number()
    .min(0)
    .max(100, "Discount percentage maksimal 100%"),
  savingsAmount: z.number().min(0, "Savings amount tidak boleh negatif"),
  campaignName: z.string().optional(),
  campaignDescription: z.string().optional(),
  validUntil: z.string().optional(),
  termsAndConditions: z.string().optional(),
  displayFormat: z
    .enum(["inline", "modal", "banner", "popup"])
    .default("inline"),
});

export const promotionalPricingAnalyticsSchema = z.object({
  campaignId: z.string().min(1, "Campaign ID diperlukan"),
  dateRange: z.object({
    startDate: z.string().min(1, "Tanggal mulai diperlukan"),
    endDate: z.string().min(1, "Tanggal berakhir diperlukan"),
  }),
  metrics: z
    .array(
      z.enum([
        "total_applications",
        "total_savings",
        "conversion_rate",
        "revenue_impact",
        "customer_satisfaction",
        "usage_frequency",
        "retention_rate",
      ])
    )
    .default(["total_applications", "total_savings"]),
  filters: z
    .object({
      serviceType: z
        .enum(["pool_booking", "cafe_order", "private_pool", "all"])
        .optional(),
      userType: z
        .enum(["member", "guest", "new_user", "returning_user"])
        .optional(),
      discountType: z.enum(["percentage", "fixed_amount", "bogo"]).optional(),
    })
    .optional(),
});

export const promotionalPricingOptimizationSchema = z.object({
  campaignId: z.string().min(1, "Campaign ID diperlukan"),
  optimizationType: z.enum([
    "conversion_rate",
    "revenue",
    "customer_satisfaction",
    "retention_rate",
  ]),
  targetMetrics: z
    .object({
      conversionRate: z.number().min(0).max(1).optional(),
      revenue: z.number().min(0).optional(),
      customerSatisfaction: z.number().min(0).max(5).optional(),
      retentionRate: z.number().min(0).max(1).optional(),
    })
    .optional(),
  constraints: z
    .object({
      minDiscount: z.number().min(0).optional(),
      maxDiscount: z.number().min(0).optional(),
      minPrice: z.number().min(0).optional(),
      maxPrice: z.number().min(0).optional(),
    })
    .optional(),
  optimizationPeriod: z.object({
    startDate: z.string().min(1, "Tanggal mulai diperlukan"),
    endDate: z.string().min(1, "Tanggal berakhir diperlukan"),
  }),
});

export type PromotionalPricingApplicationFormData = z.infer<
  typeof promotionalPricingApplicationSchema
>;
export type PromotionalPricingDisplayFormData = z.infer<
  typeof promotionalPricingDisplaySchema
>;
export type PromotionalPricingAnalyticsFormData = z.infer<
  typeof promotionalPricingAnalyticsSchema
>;
export type PromotionalPricingOptimizationFormData = z.infer<
  typeof promotionalPricingOptimizationSchema
>;
```

### src/hooks/usePromotionalPricing.ts

```typescript
// Promotional pricing hook
import { useState, useEffect } from "react";
import { promotionalPricingService } from "@/services/pricing/promotional/promotionalPricingService";
import { PromotionalPricingApplicationFormData } from "@/schemas/promotionalPricingSchemas";

export function usePromotionalPricing() {
  const [promotionalPricings, setPromotionalPricings] = useState([]);
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const applyPromotionalPricing = async (
    data: PromotionalPricingApplicationFormData
  ) => {
    setIsLoading(true);
    setError(null);
    try {
      const result = await promotionalPricingService.applyPromotionalPricing(
        data
      );
      return { success: true, result };
    } catch (err) {
      setError(err.message);
      return { success: false, error: err.message };
    } finally {
      setIsLoading(false);
    }
  };

  const calculatePromotionalPricing = async (
    campaignId: string,
    originalPrice: number,
    userId: string
  ) => {
    setIsLoading(true);
    setError(null);
    try {
      const calculation =
        await promotionalPricingService.calculatePromotionalPricing(
          campaignId,
          originalPrice,
          userId
        );
      return { success: true, calculation };
    } catch (err) {
      setError(err.message);
      return { success: false, error: err.message };
    } finally {
      setIsLoading(false);
    }
  };

  const getPromotionalPricingHistory = async (
    userId: string,
    dateRange?: { startDate: string; endDate: string }
  ) => {
    setIsLoading(true);
    setError(null);
    try {
      const history =
        await promotionalPricingService.getPromotionalPricingHistory(
          userId,
          dateRange
        );
      return { success: true, history };
    } catch (err) {
      setError(err.message);
      return { success: false, error: err.message };
    } finally {
      setIsLoading(false);
    }
  };

  const getActivePromotionalPricing = async (
    serviceType: string,
    userId: string
  ) => {
    setIsLoading(true);
    setError(null);
    try {
      const activePricing =
        await promotionalPricingService.getActivePromotionalPricing(
          serviceType,
          userId
        );
      return { success: true, activePricing };
    } catch (err) {
      setError(err.message);
      return { success: false, error: err.message };
    } finally {
      setIsLoading(false);
    }
  };

  const validatePromotionalPricing = async (
    campaignId: string,
    userId: string,
    serviceType: string
  ) => {
    setIsLoading(true);
    setError(null);
    try {
      const validation =
        await promotionalPricingService.validatePromotionalPricing(
          campaignId,
          userId,
          serviceType
        );
      return { success: true, validation };
    } catch (err) {
      setError(err.message);
      return { success: false, error: err.message };
    } finally {
      setIsLoading(false);
    }
  };

  return {
    promotionalPricings,
    isLoading,
    error,
    applyPromotionalPricing,
    calculatePromotionalPricing,
    getPromotionalPricingHistory,
    getActivePromotionalPricing,
    validatePromotionalPricing,
    clearError: () => setError(null),
  };
}
```

### src/components/pricing/promotional/PromotionalPricingDisplay.tsx

```typescript
// Promotional pricing display component
import { useState, useEffect } from "react";
import { usePromotionalPricing } from "@/hooks/usePromotionalPricing";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import { Separator } from "@/components/ui/separator";
import { Clock, Tag, Percent, DollarSign, Users, Calendar } from "lucide-react";

interface PromotionalPricingDisplayProps {
  campaignId: string;
  originalPrice: number;
  userId: string;
  serviceType: string;
  onApplyPricing?: (pricing: any) => void;
}

export function PromotionalPricingDisplay({
  campaignId,
  originalPrice,
  userId,
  serviceType,
  onApplyPricing,
}: PromotionalPricingDisplayProps) {
  const {
    calculatePromotionalPricing,
    applyPromotionalPricing,
    isLoading,
    error,
  } = usePromotionalPricing();
  const [pricingData, setPricingData] = useState(null);
  const [isApplied, setIsApplied] = useState(false);

  useEffect(() => {
    const loadPricingData = async () => {
      const result = await calculatePromotionalPricing(
        campaignId,
        originalPrice,
        userId
      );
      if (result.success) {
        setPricingData(result.calculation);
      }
    };

    loadPricingData();
  }, [campaignId, originalPrice, userId]);

  const handleApplyPricing = async () => {
    if (!pricingData) return;

    const applicationData = {
      campaignId,
      userId,
      serviceType,
      originalPrice,
      quantity: 1,
      date: new Date().toISOString().split("T")[0],
      time: new Date().toTimeString().split(" ")[0],
      applicableDiscounts: pricingData.applicableDiscounts,
      finalPrice: pricingData.finalPrice,
      totalSavings: pricingData.totalSavings,
    };

    const result = await applyPromotionalPricing(applicationData);
    if (result.success) {
      setIsApplied(true);
      onApplyPricing?.(result.result);
    }
  };

  if (isLoading) {
    return (
      <Card className="w-full">
        <CardContent className="p-6">
          <div className="flex items-center justify-center">
            <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-blue-600"></div>
            <span className="ml-2">Menghitung harga promosi...</span>
          </div>
        </CardContent>
      </Card>
    );
  }

  if (error) {
    return (
      <Card className="w-full">
        <CardContent className="p-6">
          <div className="text-center text-red-500">
            <p>Error: {error}</p>
          </div>
        </CardContent>
      </Card>
    );
  }

  if (!pricingData) {
    return (
      <Card className="w-full">
        <CardContent className="p-6">
          <div className="text-center text-gray-500">
            <p>Tidak ada harga promosi yang tersedia</p>
          </div>
        </CardContent>
      </Card>
    );
  }

  const discountPercentage =
    ((originalPrice - pricingData.finalPrice) / originalPrice) * 100;

  return (
    <Card className="w-full border-2 border-orange-200 bg-orange-50">
      <CardHeader className="pb-3">
        <div className="flex items-center justify-between">
          <CardTitle className="text-lg text-orange-800">
            🎉 Harga Promosi Tersedia!
          </CardTitle>
          <Badge variant="secondary" className="bg-orange-200 text-orange-800">
            <Percent className="h-3 w-3 mr-1" />
            {discountPercentage.toFixed(0)}% OFF
          </Badge>
        </div>
      </CardHeader>
      <CardContent className="space-y-4">
        {/* Price Comparison */}
        <div className="space-y-2">
          <div className="flex items-center justify-between">
            <span className="text-sm text-gray-600">Harga Normal:</span>
            <span className="text-sm text-gray-500 line-through">
              Rp {originalPrice.toLocaleString()}
            </span>
          </div>
          <div className="flex items-center justify-between">
            <span className="text-sm font-medium text-gray-700">
              Harga Promosi:
            </span>
            <span className="text-lg font-bold text-orange-600">
              Rp {pricingData.finalPrice.toLocaleString()}
            </span>
          </div>
          <Separator />
          <div className="flex items-center justify-between">
            <span className="text-sm font-medium text-green-700">
              Total Hemat:
            </span>
            <span className="text-lg font-bold text-green-600">
              Rp {pricingData.totalSavings.toLocaleString()}
            </span>
          </div>
        </div>

        {/* Campaign Details */}
        {pricingData.campaignName && (
          <div className="space-y-2">
            <h4 className="font-medium text-gray-700">Detail Promosi:</h4>
            <p className="text-sm text-gray-600">{pricingData.campaignName}</p>
            {pricingData.campaignDescription && (
              <p className="text-xs text-gray-500">
                {pricingData.campaignDescription}
              </p>
            )}
          </div>
        )}

        {/* Valid Until */}
        {pricingData.validUntil && (
          <div className="flex items-center text-sm text-gray-600">
            <Clock className="h-4 w-4 mr-2" />
            <span>
              Berlaku hingga:{" "}
              {new Date(pricingData.validUntil).toLocaleDateString()}
            </span>
          </div>
        )}

        {/* Applicable Discounts */}
        {pricingData.applicableDiscounts &&
          pricingData.applicableDiscounts.length > 0 && (
            <div className="space-y-2">
              <h4 className="font-medium text-gray-700">
                Diskon yang Berlaku:
              </h4>
              <div className="space-y-1">
                {pricingData.applicableDiscounts.map((discount, index) => (
                  <div
                    key={index}
                    className="flex items-center justify-between text-sm"
                  >
                    <div className="flex items-center">
                      <Tag className="h-3 w-3 mr-1 text-blue-500" />
                      <span className="text-gray-600">
                        {discount.discountName}
                      </span>
                    </div>
                    <span className="font-medium text-blue-600">
                      {discount.discountType === "percentage"
                        ? `${discount.discountValue}%`
                        : `Rp ${discount.discountValue.toLocaleString()}`}
                    </span>
                  </div>
                ))}
              </div>
            </div>
          )}

        {/* Terms and Conditions */}
        {pricingData.termsAndConditions && (
          <div className="space-y-2">
            <h4 className="font-medium text-gray-700">Syarat dan Ketentuan:</h4>
            <p className="text-xs text-gray-500">
              {pricingData.termsAndConditions}
            </p>
          </div>
        )}

        {/* Apply Button */}
        <div className="pt-4">
          {isApplied ? (
            <Button disabled className="w-full bg-green-600 hover:bg-green-700">
              ✅ Harga Promosi Telah Diterapkan
            </Button>
          ) : (
            <Button
              onClick={handleApplyPricing}
              className="w-full bg-orange-600 hover:bg-orange-700"
            >
              <DollarSign className="h-4 w-4 mr-2" />
              Terapkan Harga Promosi
            </Button>
          )}
        </div>

        {/* Additional Info */}
        <div className="text-xs text-gray-500 text-center">
          <p>Harga promosi ini hanya berlaku untuk layanan yang dipilih</p>
        </div>
      </CardContent>
    </Card>
  );
}
```

## 🛠️ Development Commands

### Promotional Pricing Development

```bash
# Start development server
npm run dev

# Test promotional pricing components
npm run test -- --testPathPattern=promotional-pricing

# Test promotional pricing application
npm run test -- --testPathPattern=promotional-pricing-application
```

### Promotional Pricing Testing

```bash
# Test promotional pricing functionality
npm run test src/components/pricing/promotional

# Test promotional pricing hooks
npm run test src/hooks/usePromotionalPricing

# Test promotional pricing services
npm run test src/services/pricing/promotional
```

## 🎨 UI Implementation

### Promotional Pricing Styling

```bash
# Create promotional pricing styles
mkdir -p src/styles/pricing/promotional
touch src/styles/pricing/promotional/promotionalPricing.css
touch src/styles/pricing/promotional/promotionalPricingDisplay.css
```

**Style Features:**

- Promotional pricing display styling
- Promotional pricing calculator styling
- Promotional pricing analytics styling
- Promotional pricing optimizer styling

### Promotional Pricing Layout

```bash
# Create promotional pricing layout
touch src/components/pricing/promotional/PromotionalPricingLayout.tsx
touch src/components/pricing/promotional/PromotionalPricingSidebar.tsx
```

**Layout Features:**

- Promotional pricing page layout
- Promotional pricing sidebar navigation
- Promotional pricing content area
- Responsive design

## 🔧 Integration Points

### API Integration

```bash
# Create promotional pricing API service
touch src/services/api/promotionalPricingApi.ts
touch src/services/api/promotionalPricingApplicationApi.ts
```

**API Features:**

- Promotional pricing API integration
- Promotional pricing application API integration
- Promotional pricing analytics API integration
- Promotional pricing optimization API integration

### State Management

```bash
# Create promotional pricing state management
touch src/store/pricing/promotional/promotionalPricingStore.ts
touch src/store/pricing/promotional/promotionalPricingActions.ts
```

**State Features:**

- Promotional pricing state management
- Promotional pricing application state management
- Promotional pricing analytics state management
- Promotional pricing optimization state management

## 🧪 Testing Strategy

### Unit Tests

```bash
# Test promotional pricing components
mkdir -p src/components/pricing/promotional/__tests__
touch src/components/pricing/promotional/__tests__/PromotionalPricingDisplay.test.tsx
touch src/components/pricing/promotional/__tests__/PromotionalPricingCalculator.test.tsx
```

**Test Coverage:**

- Promotional pricing display rendering
- Promotional pricing calculator functionality
- Promotional pricing analytics functionality
- Promotional pricing optimizer functionality

### Integration Tests

```bash
# Test promotional pricing integration
mkdir -p src/__tests__/integration
touch src/__tests__/integration/promotional-pricing.test.tsx
```

**Integration Tests:**

- Complete promotional pricing workflow
- API integration
- State management integration
- Promotional pricing application integration

## 📱 Mobile Considerations

### Mobile Promotional Pricing

```bash
# Mobile promotional pricing components
touch src/components/pricing/promotional/mobile/MobilePromotionalPricingDisplay.tsx
touch src/components/pricing/promotional/mobile/MobilePromotionalPricingCalculator.tsx
```

**Mobile Features:**

- Mobile-optimized promotional pricing display
- Mobile promotional pricing calculator
- Touch-friendly interface
- Mobile promotional pricing validation

### Performance Optimization

```bash
# Promotional pricing performance optimization
touch src/hooks/usePromotionalPricingPerformance.ts
```

**Optimizations:**

- Promotional pricing display optimization
- Promotional pricing calculator optimization
- Promotional pricing application optimization
- API call optimization

## 🔒 Security Considerations

### Promotional Pricing Security

```bash
# Promotional pricing security utilities
touch src/utils/promotionalPricingSecurity.ts
touch src/utils/promotionalPricingValidation.ts
```

**Security Features:**

- Promotional pricing validation
- Promotional pricing application validation
- Promotional pricing display validation
- Promotional pricing analytics validation

### Data Protection

```bash
# Data protection utilities
touch src/utils/promotionalPricingDataProtection.ts
touch src/utils/promotionalPricingPrivacy.ts
```

**Protection Features:**

- Promotional pricing data protection
- Promotional pricing application data protection
- Sensitive pricing data masking
- Privacy compliance

## 📊 Analytics & Monitoring

### Promotional Pricing Analytics

```bash
# Promotional pricing analytics
touch src/utils/promotionalPricingAnalytics.ts
touch src/hooks/usePromotionalPricingAnalytics.ts
```

**Analytics Features:**

- Promotional pricing usage tracking
- Promotional pricing application analytics
- Promotional pricing performance analytics
- Promotional pricing customer experience analytics

### Error Monitoring

```bash
# Error monitoring untuk promotional pricing
touch src/utils/promotionalPricingErrorMonitoring.ts
touch src/hooks/usePromotionalPricingErrorMonitoring.ts
```

**Monitoring Features:**

- Promotional pricing error tracking
- Promotional pricing application error monitoring
- Promotional pricing display error monitoring
- API error monitoring

## ✅ Success Criteria

- [ ] Automatic promotional pricing application berfungsi
- [ ] Promotional pricing display interface implemented
- [ ] Promotional pricing analytics berfungsi
- [ ] Promotional pricing optimization implemented
- [ ] Promotional pricing performance tracking berfungsi
- [ ] Promotional pricing customer experience implemented
- [ ] Promotional pricing forms dengan proper validation
- [ ] Promotional pricing hooks dengan error handling
- [ ] Promotional pricing API integration
- [ ] Unit tests untuk promotional pricing components
- [ ] Integration tests untuk promotional pricing workflow
- [ ] Security measures untuk promotional pricing data
- [ ] Data protection untuk sensitive pricing information
- [ ] Analytics tracking untuk promotional pricing usage
- [ ] Error monitoring dan alerting
- [ ] Performance optimization untuk promotional pricing
- [ ] Mobile-responsive promotional pricing interface
- [ ] Accessibility features maintained
- [ ] Promotional pricing system health monitoring
- [ ] Promotional pricing system documentation dan user guides

## 📝 Notes

- Pastikan promotional pricing aman dan tidak vulnerable
- Implementasi proper validation untuk semua promotional pricing inputs
- Setup proper error handling untuk promotional pricing operations
- Test promotional pricing system dengan various scenarios
- Consider implementing promotional pricing backup strategies
- Implementasi promotional pricing system reporting features
- Consider adding promotional pricing notifications
- Implementasi promotional pricing system health monitoring
- Add promotional pricing system documentation dan training materials
