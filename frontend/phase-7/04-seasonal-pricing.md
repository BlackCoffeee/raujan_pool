# Seasonal Pricing Management Implementation

## 📋 Overview

Implementasi seasonal pricing management interface dengan seasonal pricing rules, holiday pricing, dan event-based pricing untuk Raujan Pool Syariah frontend.

## 🎯 Objectives

- Seasonal pricing configuration
- Holiday pricing management
- Event-based pricing rules
- Seasonal pricing analytics
- Pricing calendar management
- Seasonal pricing optimization

## 🔧 Implementation Steps

### Step 1: Create Seasonal Pricing Components

```bash
# Create seasonal pricing components
mkdir -p src/components/pricing/seasonal
touch src/components/pricing/seasonal/SeasonalPricingForm.tsx
touch src/components/pricing/seasonal/HolidayPricingManager.tsx
touch src/components/pricing/seasonal/EventBasedPricing.tsx
touch src/components/pricing/seasonal/PricingCalendar.tsx
```

**Component Structure:**

- `SeasonalPricingForm` - Seasonal pricing configuration form
- `HolidayPricingManager` - Holiday pricing management
- `EventBasedPricing` - Event-based pricing rules
- `PricingCalendar` - Pricing calendar interface

### Step 2: Setup Seasonal Pricing Validation

```bash
# Create seasonal pricing validation schemas
mkdir -p src/schemas/pricing/seasonal
touch src/schemas/seasonalPricingSchemas.ts
touch src/schemas/holidayPricingSchemas.ts
```

**Validation Features:**

- Seasonal pricing validation
- Holiday pricing validation
- Event-based pricing validation
- Pricing calendar validation

### Step 3: Create Seasonal Pricing Pages

```bash
# Create seasonal pricing pages
mkdir -p src/pages/pricing/seasonal
touch src/pages/pricing/seasonal/SeasonalPricingPage.tsx
touch src/pages/pricing/seasonal/HolidayPricingPage.tsx
touch src/pages/pricing/seasonal/EventBasedPricingPage.tsx
touch src/pages/pricing/seasonal/PricingCalendarPage.tsx
```

**Page Structure:**

- `SeasonalPricingPage` - Main seasonal pricing page
- `HolidayPricingPage` - Holiday pricing page
- `EventBasedPricingPage` - Event-based pricing page
- `PricingCalendarPage` - Pricing calendar page

### Step 4: Setup Seasonal Pricing Hooks

```bash
# Create seasonal pricing hooks
touch src/hooks/useSeasonalPricing.ts
touch src/hooks/useHolidayPricing.ts
touch src/hooks/useEventBasedPricing.ts
touch src/hooks/usePricingCalendar.ts
```

**Hook Features:**

- Seasonal pricing management
- Holiday pricing management
- Event-based pricing management
- Pricing calendar management

### Step 5: Create Seasonal Pricing Services

```bash
# Create seasonal pricing services
mkdir -p src/services/pricing/seasonal
touch src/services/pricing/seasonal/seasonalPricingService.ts
touch src/services/pricing/seasonal/holidayPricingService.ts
touch src/services/pricing/seasonal/eventBasedPricingService.ts
```

**Service Features:**

- Seasonal pricing API service
- Holiday pricing API service
- Event-based pricing API service
- Pricing calendar API service

## 📊 Configuration Files

### src/schemas/seasonalPricingSchemas.ts

```typescript
// Seasonal pricing validation schemas
import { z } from "zod";

export const seasonalPricingSchema = z.object({
  name: z.string().min(2, "Nama seasonal pricing minimal 2 karakter"),
  description: z.string().optional(),
  seasonType: z.enum(["spring", "summer", "autumn", "winter", "rainy", "dry"]),
  startDate: z.string().min(1, "Tanggal mulai diperlukan"),
  endDate: z.string().min(1, "Tanggal berakhir diperlukan"),
  priceMultiplier: z
    .number()
    .min(0.1, "Multiplier minimal 0.1")
    .max(5, "Multiplier maksimal 5"),
  isActive: z.boolean().default(true),
  applicableServices: z
    .array(z.enum(["pool_booking", "cafe_order", "private_pool", "all"]))
    .default(["all"]),
  conditions: z
    .object({
      minTemperature: z.number().optional(),
      maxTemperature: z.number().optional(),
      weatherConditions: z
        .array(z.enum(["sunny", "cloudy", "rainy", "stormy"]))
        .optional(),
      dayOfWeek: z.array(z.number().min(0).max(6)).optional(),
      timeSlots: z.array(z.string()).optional(),
    })
    .optional(),
});

export const holidayPricingSchema = z.object({
  name: z.string().min(2, "Nama holiday pricing minimal 2 karakter"),
  description: z.string().optional(),
  holidayType: z.enum(["national", "religious", "local", "custom"]),
  date: z.string().min(1, "Tanggal holiday diperlukan"),
  priceMultiplier: z
    .number()
    .min(0.1, "Multiplier minimal 0.1")
    .max(5, "Multiplier maksimal 5"),
  isActive: z.boolean().default(true),
  applicableServices: z
    .array(z.enum(["pool_booking", "cafe_order", "private_pool", "all"]))
    .default(["all"]),
  specialOffers: z
    .array(
      z.object({
        name: z.string(),
        description: z.string(),
        discountType: z.enum(["percentage", "fixed_amount"]),
        discountValue: z.number().min(0),
        conditions: z.record(z.any()).optional(),
      })
    )
    .optional(),
});

export const eventBasedPricingSchema = z.object({
  name: z.string().min(2, "Nama event pricing minimal 2 karakter"),
  description: z.string().optional(),
  eventType: z.enum([
    "sports",
    "entertainment",
    "corporate",
    "educational",
    "community",
  ]),
  startDate: z.string().min(1, "Tanggal mulai event diperlukan"),
  endDate: z.string().min(1, "Tanggal berakhir event diperlukan"),
  priceMultiplier: z
    .number()
    .min(0.1, "Multiplier minimal 0.1")
    .max(5, "Multiplier maksimal 5"),
  isActive: z.boolean().default(true),
  applicableServices: z
    .array(z.enum(["pool_booking", "cafe_order", "private_pool", "all"]))
    .default(["all"]),
  eventDetails: z.object({
    eventName: z.string(),
    organizer: z.string(),
    expectedAttendance: z.number().min(0).optional(),
    specialRequirements: z.array(z.string()).optional(),
  }),
  pricingRules: z
    .array(
      z.object({
        condition: z.string(),
        priceModifier: z.number(),
        description: z.string().optional(),
      })
    )
    .optional(),
});

export const pricingCalendarSchema = z.object({
  year: z.number().min(2020).max(2030),
  month: z.number().min(1).max(12),
  pricingEvents: z.array(
    z.object({
      id: z.string(),
      name: z.string(),
      type: z.enum(["seasonal", "holiday", "event"]),
      startDate: z.string(),
      endDate: z.string(),
      priceMultiplier: z.number(),
      color: z.string(),
    })
  ),
});

export type SeasonalPricingFormData = z.infer<typeof seasonalPricingSchema>;
export type HolidayPricingFormData = z.infer<typeof holidayPricingSchema>;
export type EventBasedPricingFormData = z.infer<typeof eventBasedPricingSchema>;
export type PricingCalendarFormData = z.infer<typeof pricingCalendarSchema>;
```

### src/hooks/useSeasonalPricing.ts

```typescript
// Seasonal pricing hook
import { useState, useEffect } from "react";
import { seasonalPricingService } from "@/services/pricing/seasonal/seasonalPricingService";
import { SeasonalPricingFormData } from "@/schemas/seasonalPricingSchemas";

export function useSeasonalPricing() {
  const [seasonalPricings, setSeasonalPricings] = useState([]);
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const createSeasonalPricing = async (data: SeasonalPricingFormData) => {
    setIsLoading(true);
    setError(null);
    try {
      const newPricing = await seasonalPricingService.createSeasonalPricing(
        data
      );
      setSeasonalPricings((prev) => [...prev, newPricing]);
      return { success: true, pricing: newPricing };
    } catch (err) {
      setError(err.message);
      return { success: false, error: err.message };
    } finally {
      setIsLoading(false);
    }
  };

  const updateSeasonalPricing = async (
    id: string,
    data: SeasonalPricingFormData
  ) => {
    setIsLoading(true);
    setError(null);
    try {
      const updatedPricing = await seasonalPricingService.updateSeasonalPricing(
        id,
        data
      );
      setSeasonalPricings((prev) =>
        prev.map((pricing) => (pricing.id === id ? updatedPricing : pricing))
      );
      return { success: true, pricing: updatedPricing };
    } catch (err) {
      setError(err.message);
      return { success: false, error: err.message };
    } finally {
      setIsLoading(false);
    }
  };

  const deleteSeasonalPricing = async (id: string) => {
    setIsLoading(true);
    setError(null);
    try {
      await seasonalPricingService.deleteSeasonalPricing(id);
      setSeasonalPricings((prev) =>
        prev.filter((pricing) => pricing.id !== id)
      );
      return { success: true };
    } catch (err) {
      setError(err.message);
      return { success: false, error: err.message };
    } finally {
      setIsLoading(false);
    }
  };

  const getSeasonalPricings = async () => {
    setIsLoading(true);
    setError(null);
    try {
      const pricings = await seasonalPricingService.getSeasonalPricings();
      setSeasonalPricings(pricings);
      return { success: true, pricings };
    } catch (err) {
      setError(err.message);
      return { success: false, error: err.message };
    } finally {
      setIsLoading(false);
    }
  };

  const getActiveSeasonalPricing = async (date: string) => {
    setIsLoading(true);
    setError(null);
    try {
      const pricing = await seasonalPricingService.getActiveSeasonalPricing(
        date
      );
      return { success: true, pricing };
    } catch (err) {
      setError(err.message);
      return { success: false, error: err.message };
    } finally {
      setIsLoading(false);
    }
  };

  useEffect(() => {
    getSeasonalPricings();
  }, []);

  return {
    seasonalPricings,
    isLoading,
    error,
    createSeasonalPricing,
    updateSeasonalPricing,
    deleteSeasonalPricing,
    getSeasonalPricings,
    getActiveSeasonalPricing,
    clearError: () => setError(null),
  };
}
```

### src/components/pricing/seasonal/SeasonalPricingForm.tsx

```typescript
// Seasonal pricing form component
import { useForm } from "react-hook-form";
import { zodResolver } from "@hookform/resolvers/zod";
import {
  seasonalPricingSchema,
  SeasonalPricingFormData,
} from "@/schemas/seasonalPricingSchemas";
import { useSeasonalPricing } from "@/hooks/useSeasonalPricing";
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
import { Badge } from "@/components/ui/badge";

export function SeasonalPricingForm() {
  const { createSeasonalPricing, isLoading, error, clearError } =
    useSeasonalPricing();

  const {
    register,
    handleSubmit,
    formState: { errors },
    reset,
    watch,
  } = useForm<SeasonalPricingFormData>({
    resolver: zodResolver(seasonalPricingSchema),
    defaultValues: {
      isActive: true,
      applicableServices: ["all"],
      priceMultiplier: 1.0,
    },
  });

  const seasonType = watch("seasonType");
  const priceMultiplier = watch("priceMultiplier");

  const onSubmit = async (data: SeasonalPricingFormData) => {
    clearError();
    const result = await createSeasonalPricing(data);
    if (result.success) {
      reset();
      // Show success message
    }
  };

  return (
    <Card className="w-full max-w-4xl">
      <CardHeader>
        <CardTitle>Konfigurasi Harga Musiman</CardTitle>
        <p className="text-sm text-gray-500">
          Buat konfigurasi harga berdasarkan musim dan kondisi cuaca
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
              <Label htmlFor="seasonType">Jenis Musim</Label>
              <Select {...register("seasonType")}>
                <SelectTrigger>
                  <SelectValue placeholder="Pilih jenis musim" />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="spring">Musim Semi</SelectItem>
                  <SelectItem value="summer">Musim Panas</SelectItem>
                  <SelectItem value="autumn">Musim Gugur</SelectItem>
                  <SelectItem value="winter">Musim Dingin</SelectItem>
                  <SelectItem value="rainy">Musim Hujan</SelectItem>
                  <SelectItem value="dry">Musim Kemarau</SelectItem>
                </SelectContent>
              </Select>
              {errors.seasonType && (
                <p className="text-sm text-red-500">
                  {errors.seasonType.message}
                </p>
              )}
            </div>

            <div className="space-y-2">
              <Label htmlFor="startDate">Tanggal Mulai</Label>
              <Input id="startDate" type="date" {...register("startDate")} />
              {errors.startDate && (
                <p className="text-sm text-red-500">
                  {errors.startDate.message}
                </p>
              )}
            </div>

            <div className="space-y-2">
              <Label htmlFor="endDate">Tanggal Berakhir</Label>
              <Input id="endDate" type="date" {...register("endDate")} />
              {errors.endDate && (
                <p className="text-sm text-red-500">{errors.endDate.message}</p>
              )}
            </div>

            <div className="space-y-2">
              <Label htmlFor="priceMultiplier">
                Multiplier Harga ({priceMultiplier}x)
              </Label>
              <Input
                id="priceMultiplier"
                type="number"
                step="0.1"
                min="0.1"
                max="5"
                placeholder="Masukkan multiplier harga"
                {...register("priceMultiplier", { valueAsNumber: true })}
              />
              {errors.priceMultiplier && (
                <p className="text-sm text-red-500">
                  {errors.priceMultiplier.message}
                </p>
              )}
              <p className="text-xs text-gray-500">
                Multiplier 1.0 = harga normal, 1.5 = 50% lebih mahal, 0.8 = 20%
                lebih murah
              </p>
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

          {/* Applicable Services */}
          <div className="space-y-2">
            <Label>Layanan yang Berlaku</Label>
            <div className="flex flex-wrap gap-2">
              {["all", "pool_booking", "cafe_order", "private_pool"].map(
                (service) => (
                  <Badge
                    key={service}
                    variant="outline"
                    className="cursor-pointer"
                  >
                    {service === "all"
                      ? "Semua Layanan"
                      : service === "pool_booking"
                      ? "Booking Pool"
                      : service === "cafe_order"
                      ? "Pesanan Cafe"
                      : "Private Pool"}
                  </Badge>
                )
              )}
            </div>
          </div>

          {/* Conditions */}
          <div className="space-y-4">
            <h4 className="font-medium">Kondisi Tambahan</h4>
            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
              <div className="space-y-2">
                <Label htmlFor="minTemperature">Suhu Minimum (°C)</Label>
                <Input
                  id="minTemperature"
                  type="number"
                  placeholder="Masukkan suhu minimum"
                  {...register("conditions.minTemperature", {
                    valueAsNumber: true,
                  })}
                />
              </div>
              <div className="space-y-2">
                <Label htmlFor="maxTemperature">Suhu Maksimum (°C)</Label>
                <Input
                  id="maxTemperature"
                  type="number"
                  placeholder="Masukkan suhu maksimum"
                  {...register("conditions.maxTemperature", {
                    valueAsNumber: true,
                  })}
                />
              </div>
            </div>

            <div className="space-y-2">
              <Label>Kondisi Cuaca</Label>
              <div className="flex flex-wrap gap-2">
                {["sunny", "cloudy", "rainy", "stormy"].map((weather) => (
                  <div key={weather} className="flex items-center space-x-2">
                    <Checkbox
                      id={`weather-${weather}`}
                      {...register(`conditions.weatherConditions.${weather}`)}
                    />
                    <Label htmlFor={`weather-${weather}`}>
                      {weather === "sunny"
                        ? "Cerah"
                        : weather === "cloudy"
                        ? "Berawan"
                        : weather === "rainy"
                        ? "Hujan"
                        : "Badai"}
                    </Label>
                  </div>
                ))}
              </div>
            </div>

            <div className="space-y-2">
              <Label>Hari dalam Seminggu</Label>
              <div className="flex flex-wrap gap-2">
                {[
                  { value: 0, label: "Minggu" },
                  { value: 1, label: "Senin" },
                  { value: 2, label: "Selasa" },
                  { value: 3, label: "Rabu" },
                  { value: 4, label: "Kamis" },
                  { value: 5, label: "Jumat" },
                  { value: 6, label: "Sabtu" },
                ].map((day) => (
                  <div key={day.value} className="flex items-center space-x-2">
                    <Checkbox
                      id={`day-${day.value}`}
                      {...register(`conditions.dayOfWeek.${day.value}`)}
                    />
                    <Label htmlFor={`day-${day.value}`}>{day.label}</Label>
                  </div>
                ))}
              </div>
            </div>
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

### Seasonal Pricing Development

```bash
# Start development server
npm run dev

# Test seasonal pricing components
npm run test -- --testPathPattern=seasonal-pricing

# Test seasonal pricing forms
npm run test -- --testPathPattern=seasonal-pricing-forms
```

### Seasonal Pricing Testing

```bash
# Test seasonal pricing functionality
npm run test src/components/pricing/seasonal

# Test seasonal pricing hooks
npm run test src/hooks/useSeasonalPricing

# Test seasonal pricing services
npm run test src/services/pricing/seasonal
```

## 🎨 UI Implementation

### Seasonal Pricing Styling

```bash
# Create seasonal pricing styles
mkdir -p src/styles/pricing/seasonal
touch src/styles/pricing/seasonal/seasonalPricing.css
touch src/styles/pricing/seasonal/pricingCalendar.css
```

**Style Features:**

- Seasonal pricing form styling
- Holiday pricing styling
- Event-based pricing styling
- Pricing calendar styling

### Seasonal Pricing Layout

```bash
# Create seasonal pricing layout
touch src/components/pricing/seasonal/SeasonalPricingLayout.tsx
touch src/components/pricing/seasonal/SeasonalPricingSidebar.tsx
```

**Layout Features:**

- Seasonal pricing page layout
- Seasonal pricing sidebar navigation
- Seasonal pricing content area
- Responsive design

## 🔧 Integration Points

### API Integration

```bash
# Create seasonal pricing API service
touch src/services/api/seasonalPricingApi.ts
touch src/services/api/holidayPricingApi.ts
```

**API Features:**

- Seasonal pricing API integration
- Holiday pricing API integration
- Event-based pricing API integration
- Pricing calendar API integration

### State Management

```bash
# Create seasonal pricing state management
touch src/store/pricing/seasonal/seasonalPricingStore.ts
touch src/store/pricing/seasonal/seasonalPricingActions.ts
```

**State Features:**

- Seasonal pricing state management
- Holiday pricing state management
- Event-based pricing state management
- Pricing calendar state management

## 🧪 Testing Strategy

### Unit Tests

```bash
# Test seasonal pricing components
mkdir -p src/components/pricing/seasonal/__tests__
touch src/components/pricing/seasonal/__tests__/SeasonalPricingForm.test.tsx
touch src/components/pricing/seasonal/__tests__/HolidayPricingManager.test.tsx
```

**Test Coverage:**

- Seasonal pricing form rendering
- Seasonal pricing form validation
- Holiday pricing functionality
- Event-based pricing functionality

### Integration Tests

```bash
# Test seasonal pricing integration
mkdir -p src/__tests__/integration
touch src/__tests__/integration/seasonal-pricing.test.tsx
```

**Integration Tests:**

- Complete seasonal pricing workflow
- API integration
- State management integration
- Pricing calendar integration

## 📱 Mobile Considerations

### Mobile Seasonal Pricing

```bash
# Mobile seasonal pricing components
touch src/components/pricing/seasonal/mobile/MobileSeasonalPricingForm.tsx
touch src/components/pricing/seasonal/mobile/MobilePricingCalendar.tsx
```

**Mobile Features:**

- Mobile-optimized seasonal pricing forms
- Mobile pricing calendar
- Touch-friendly interface
- Mobile pricing validation

### Performance Optimization

```bash
# Seasonal pricing performance optimization
touch src/hooks/useSeasonalPricingPerformance.ts
```

**Optimizations:**

- Seasonal pricing form optimization
- Pricing calendar optimization
- Pricing validation optimization
- API call optimization

## 🔒 Security Considerations

### Seasonal Pricing Security

```bash
# Seasonal pricing security utilities
touch src/utils/seasonalPricingSecurity.ts
touch src/utils/seasonalPricingValidation.ts
```

**Security Features:**

- Seasonal pricing validation
- Holiday pricing validation
- Event-based pricing validation
- Pricing calendar validation

### Data Protection

```bash
# Data protection utilities
touch src/utils/seasonalPricingDataProtection.ts
touch src/utils/seasonalPricingPrivacy.ts
```

**Protection Features:**

- Seasonal pricing data protection
- Holiday pricing data protection
- Sensitive pricing data masking
- Privacy compliance

## 📊 Analytics & Monitoring

### Seasonal Pricing Analytics

```bash
# Seasonal pricing analytics
touch src/utils/seasonalPricingAnalytics.ts
touch src/hooks/useSeasonalPricingAnalytics.ts
```

**Analytics Features:**

- Seasonal pricing usage tracking
- Holiday pricing analytics
- Event-based pricing analytics
- Pricing calendar analytics

### Error Monitoring

```bash
# Error monitoring untuk seasonal pricing
touch src/utils/seasonalPricingErrorMonitoring.ts
touch src/hooks/useSeasonalPricingErrorMonitoring.ts
```

**Monitoring Features:**

- Seasonal pricing error tracking
- Holiday pricing error monitoring
- Event-based pricing error monitoring
- API error monitoring

## ✅ Success Criteria

- [ ] Seasonal pricing configuration berfungsi
- [ ] Holiday pricing management implemented
- [ ] Event-based pricing rules berfungsi
- [ ] Seasonal pricing analytics implemented
- [ ] Pricing calendar management berfungsi
- [ ] Seasonal pricing optimization implemented
- [ ] Seasonal pricing forms dengan proper validation
- [ ] Seasonal pricing hooks dengan error handling
- [ ] Seasonal pricing API integration
- [ ] Unit tests untuk seasonal pricing components
- [ ] Integration tests untuk seasonal pricing workflow
- [ ] Security measures untuk seasonal pricing data
- [ ] Data protection untuk sensitive pricing information
- [ ] Analytics tracking untuk seasonal pricing usage
- [ ] Error monitoring dan alerting
- [ ] Performance optimization untuk seasonal pricing
- [ ] Mobile-responsive seasonal pricing interface
- [ ] Accessibility features maintained
- [ ] Seasonal pricing system health monitoring
- [ ] Seasonal pricing system documentation dan user guides

## 📝 Notes

- Pastikan seasonal pricing aman dan tidak vulnerable
- Implementasi proper validation untuk semua seasonal pricing inputs
- Setup proper error handling untuk seasonal pricing operations
- Test seasonal pricing system dengan various scenarios
- Consider implementing seasonal pricing backup strategies
- Implementasi seasonal pricing system reporting features
- Consider adding seasonal pricing notifications
- Implementasi seasonal pricing system health monitoring
- Add seasonal pricing system documentation dan training materials
