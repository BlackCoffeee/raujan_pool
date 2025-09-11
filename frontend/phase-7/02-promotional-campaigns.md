# Promotional Campaigns Implementation

## 📋 Overview

Implementasi promotional campaign management interface dengan campaign creation, template management, dan campaign analytics untuk Raujan Pool Syariah frontend.

## 🎯 Objectives

- Promotional campaign creation dan management
- Campaign template library
- Campaign scheduling dan activation
- Campaign analytics dan performance tracking
- Campaign targeting dan eligibility
- Campaign performance optimization

## 🔧 Implementation Steps

### Step 1: Create Campaign Management Components

```bash
# Create campaign management components
mkdir -p src/components/campaigns
touch src/components/campaigns/CampaignForm.tsx
touch src/components/campaigns/CampaignTemplateLibrary.tsx
touch src/components/campaigns/CampaignScheduler.tsx
touch src/components/campaigns/CampaignAnalytics.tsx
```

**Component Structure:**

- `CampaignForm` - Campaign creation dan editing form
- `CampaignTemplateLibrary` - Campaign template library
- `CampaignScheduler` - Campaign scheduling interface
- `CampaignAnalytics` - Campaign analytics dashboard

### Step 2: Setup Campaign Validation

```bash
# Create campaign validation schemas
mkdir -p src/schemas/campaigns
touch src/schemas/campaignSchemas.ts
touch src/schemas/campaignValidation.ts
```

**Validation Features:**

- Campaign creation validation
- Campaign template validation
- Campaign scheduling validation
- Campaign targeting validation

### Step 3: Create Campaign Management Pages

```bash
# Create campaign management pages
mkdir -p src/pages/campaigns
touch src/pages/campaigns/CampaignsPage.tsx
touch src/pages/campaigns/CampaignTemplatesPage.tsx
touch src/pages/campaigns/CampaignAnalyticsPage.tsx
touch src/pages/campaigns/CampaignSchedulerPage.tsx
```

**Page Structure:**

- `CampaignsPage` - Main campaigns management page
- `CampaignTemplatesPage` - Campaign templates page
- `CampaignAnalyticsPage` - Campaign analytics page
- `CampaignSchedulerPage` - Campaign scheduler page

### Step 4: Setup Campaign Management Hooks

```bash
# Create campaign management hooks
touch src/hooks/useCampaigns.ts
touch src/hooks/useCampaignTemplates.ts
touch src/hooks/useCampaignScheduler.ts
touch src/hooks/useCampaignAnalytics.ts
```

**Hook Features:**

- Campaign management
- Campaign template management
- Campaign scheduling
- Campaign analytics

### Step 5: Create Campaign Management Services

```bash
# Create campaign management services
mkdir -p src/services/campaigns
touch src/services/campaigns/campaignService.ts
touch src/services/campaigns/campaignTemplateService.ts
touch src/services/campaigns/campaignAnalyticsService.ts
```

**Service Features:**

- Campaign API service
- Campaign template API service
- Campaign analytics API service
- Campaign scheduling API service

## 📊 Configuration Files

### src/schemas/campaignSchemas.ts

```typescript
// Campaign validation schemas
import { z } from "zod";

export const campaignSchema = z.object({
  name: z.string().min(2, "Nama campaign minimal 2 karakter"),
  description: z.string().optional(),
  campaignType: z.enum(["discount", "bogo", "seasonal", "member_special"]),
  discountType: z.enum(["percentage", "fixed_amount", "bogo"]),
  discountValue: z.number().min(0, "Nilai diskon tidak boleh negatif"),
  startDate: z.string().min(1, "Tanggal mulai diperlukan"),
  endDate: z.string().min(1, "Tanggal berakhir diperlukan"),
  isActive: z.boolean().default(true),
  targetingRules: z
    .object({
      userTypes: z
        .array(z.enum(["member", "guest", "new_user", "returning_user"]))
        .optional(),
      membershipTypes: z.array(z.enum(["monthly", "quarterly"])).optional(),
      minSpend: z.number().min(0).optional(),
      maxUsage: z.number().min(1).optional(),
      usagePerUser: z.number().min(1).optional(),
    })
    .optional(),
  applicableServices: z
    .array(z.enum(["pool_booking", "cafe_order", "private_pool", "all"]))
    .default(["all"]),
  conditions: z
    .object({
      minBookingDuration: z.number().min(1).optional(),
      specificTimeSlots: z.array(z.string()).optional(),
      specificPools: z.array(z.string()).optional(),
      specificMenuItems: z.array(z.string()).optional(),
    })
    .optional(),
});

export const campaignTemplateSchema = z.object({
  name: z.string().min(2, "Nama template minimal 2 karakter"),
  description: z.string().optional(),
  templateType: z.enum(["discount", "bogo", "seasonal", "member_special"]),
  defaultSettings: z.object({
    discountType: z.enum(["percentage", "fixed_amount", "bogo"]),
    discountValue: z.number().min(0),
    duration: z.number().min(1),
    targetingRules: z.record(z.any()).optional(),
    conditions: z.record(z.any()).optional(),
  }),
  isPublic: z.boolean().default(false),
  category: z.string().optional(),
  tags: z.array(z.string()).optional(),
});

export const campaignAnalyticsSchema = z.object({
  campaignId: z.string().min(1, "Campaign ID diperlukan"),
  dateRange: z.object({
    startDate: z.string().min(1, "Tanggal mulai diperlukan"),
    endDate: z.string().min(1, "Tanggal berakhir diperlukan"),
  }),
  metrics: z
    .array(
      z.enum([
        "total_usage",
        "total_discount_given",
        "conversion_rate",
        "revenue_impact",
        "user_engagement",
        "cost_per_acquisition",
      ])
    )
    .default(["total_usage", "total_discount_given"]),
});

export type CampaignFormData = z.infer<typeof campaignSchema>;
export type CampaignTemplateFormData = z.infer<typeof campaignTemplateSchema>;
export type CampaignAnalyticsFormData = z.infer<typeof campaignAnalyticsSchema>;
```

### src/hooks/useCampaigns.ts

```typescript
// Campaign management hook
import { useState, useEffect } from "react";
import { campaignService } from "@/services/campaigns/campaignService";
import { CampaignFormData } from "@/schemas/campaignSchemas";

export function useCampaigns() {
  const [campaigns, setCampaigns] = useState([]);
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const createCampaign = async (data: CampaignFormData) => {
    setIsLoading(true);
    setError(null);
    try {
      const newCampaign = await campaignService.createCampaign(data);
      setCampaigns((prev) => [...prev, newCampaign]);
      return { success: true, campaign: newCampaign };
    } catch (err) {
      setError(err.message);
      return { success: false, error: err.message };
    } finally {
      setIsLoading(false);
    }
  };

  const updateCampaign = async (id: string, data: CampaignFormData) => {
    setIsLoading(true);
    setError(null);
    try {
      const updatedCampaign = await campaignService.updateCampaign(id, data);
      setCampaigns((prev) =>
        prev.map((campaign) =>
          campaign.id === id ? updatedCampaign : campaign
        )
      );
      return { success: true, campaign: updatedCampaign };
    } catch (err) {
      setError(err.message);
      return { success: false, error: err.message };
    } finally {
      setIsLoading(false);
    }
  };

  const deleteCampaign = async (id: string) => {
    setIsLoading(true);
    setError(null);
    try {
      await campaignService.deleteCampaign(id);
      setCampaigns((prev) => prev.filter((campaign) => campaign.id !== id));
      return { success: true };
    } catch (err) {
      setError(err.message);
      return { success: false, error: err.message };
    } finally {
      setIsLoading(false);
    }
  };

  const activateCampaign = async (id: string) => {
    setIsLoading(true);
    setError(null);
    try {
      const activatedCampaign = await campaignService.activateCampaign(id);
      setCampaigns((prev) =>
        prev.map((campaign) =>
          campaign.id === id ? activatedCampaign : campaign
        )
      );
      return { success: true, campaign: activatedCampaign };
    } catch (err) {
      setError(err.message);
      return { success: false, error: err.message };
    } finally {
      setIsLoading(false);
    }
  };

  const deactivateCampaign = async (id: string) => {
    setIsLoading(true);
    setError(null);
    try {
      const deactivatedCampaign = await campaignService.deactivateCampaign(id);
      setCampaigns((prev) =>
        prev.map((campaign) =>
          campaign.id === id ? deactivatedCampaign : campaign
        )
      );
      return { success: true, campaign: deactivatedCampaign };
    } catch (err) {
      setError(err.message);
      return { success: false, error: err.message };
    } finally {
      setIsLoading(false);
    }
  };

  const getCampaigns = async () => {
    setIsLoading(true);
    setError(null);
    try {
      const campaignsData = await campaignService.getCampaigns();
      setCampaigns(campaignsData);
      return { success: true, campaigns: campaignsData };
    } catch (err) {
      setError(err.message);
      return { success: false, error: err.message };
    } finally {
      setIsLoading(false);
    }
  };

  useEffect(() => {
    getCampaigns();
  }, []);

  return {
    campaigns,
    isLoading,
    error,
    createCampaign,
    updateCampaign,
    deleteCampaign,
    activateCampaign,
    deactivateCampaign,
    getCampaigns,
    clearError: () => setError(null),
  };
}
```

### src/components/campaigns/CampaignForm.tsx

```typescript
// Campaign form component
import { useForm } from "react-hook-form";
import { zodResolver } from "@hookform/resolvers/zod";
import { campaignSchema, CampaignFormData } from "@/schemas/campaignSchemas";
import { useCampaigns } from "@/hooks/useCampaigns";
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

export function CampaignForm() {
  const { createCampaign, isLoading, error, clearError } = useCampaigns();

  const {
    register,
    handleSubmit,
    formState: { errors },
    reset,
    watch,
  } = useForm<CampaignFormData>({
    resolver: zodResolver(campaignSchema),
    defaultValues: {
      isActive: true,
      applicableServices: ["all"],
      targetingRules: {
        userTypes: [],
        membershipTypes: [],
      },
    },
  });

  const campaignType = watch("campaignType");
  const discountType = watch("discountType");

  const onSubmit = async (data: CampaignFormData) => {
    clearError();
    const result = await createCampaign(data);
    if (result.success) {
      reset();
      // Show success message
    }
  };

  return (
    <Card className="w-full max-w-4xl">
      <CardHeader>
        <CardTitle>Buat Campaign Promosi</CardTitle>
        <p className="text-sm text-gray-500">
          Buat campaign promosi untuk menarik lebih banyak pelanggan
        </p>
      </CardHeader>
      <CardContent>
        <form onSubmit={handleSubmit(onSubmit)} className="space-y-6">
          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div className="space-y-2">
              <Label htmlFor="name">Nama Campaign</Label>
              <Input
                id="name"
                placeholder="Masukkan nama campaign"
                {...register("name")}
              />
              {errors.name && (
                <p className="text-sm text-red-500">{errors.name.message}</p>
              )}
            </div>

            <div className="space-y-2">
              <Label htmlFor="campaignType">Jenis Campaign</Label>
              <Select {...register("campaignType")}>
                <SelectTrigger>
                  <SelectValue placeholder="Pilih jenis campaign" />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="discount">Diskon</SelectItem>
                  <SelectItem value="bogo">Buy One Get One</SelectItem>
                  <SelectItem value="seasonal">Musiman</SelectItem>
                  <SelectItem value="member_special">Khusus Member</SelectItem>
                </SelectContent>
              </Select>
              {errors.campaignType && (
                <p className="text-sm text-red-500">
                  {errors.campaignType.message}
                </p>
              )}
            </div>

            <div className="space-y-2">
              <Label htmlFor="discountType">Jenis Diskon</Label>
              <Select {...register("discountType")}>
                <SelectTrigger>
                  <SelectValue placeholder="Pilih jenis diskon" />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="percentage">Persentase (%)</SelectItem>
                  <SelectItem value="fixed_amount">
                    Jumlah Tetap (IDR)
                  </SelectItem>
                  <SelectItem value="bogo">Buy One Get One</SelectItem>
                </SelectContent>
              </Select>
              {errors.discountType && (
                <p className="text-sm text-red-500">
                  {errors.discountType.message}
                </p>
              )}
            </div>

            <div className="space-y-2">
              <Label htmlFor="discountValue">
                {discountType === "percentage"
                  ? "Persentase Diskon (%)"
                  : discountType === "fixed_amount"
                  ? "Jumlah Diskon (IDR)"
                  : "Jumlah Item Gratis"}
              </Label>
              <Input
                id="discountValue"
                type="number"
                placeholder={
                  discountType === "percentage"
                    ? "Masukkan persentase"
                    : discountType === "fixed_amount"
                    ? "Masukkan jumlah"
                    : "Masukkan jumlah item gratis"
                }
                {...register("discountValue", { valueAsNumber: true })}
              />
              {errors.discountValue && (
                <p className="text-sm text-red-500">
                  {errors.discountValue.message}
                </p>
              )}
            </div>

            <div className="space-y-2">
              <Label htmlFor="startDate">Tanggal Mulai</Label>
              <Input
                id="startDate"
                type="datetime-local"
                {...register("startDate")}
              />
              {errors.startDate && (
                <p className="text-sm text-red-500">
                  {errors.startDate.message}
                </p>
              )}
            </div>

            <div className="space-y-2">
              <Label htmlFor="endDate">Tanggal Berakhir</Label>
              <Input
                id="endDate"
                type="datetime-local"
                {...register("endDate")}
              />
              {errors.endDate && (
                <p className="text-sm text-red-500">{errors.endDate.message}</p>
              )}
            </div>
          </div>

          <div className="space-y-2">
            <Label htmlFor="description">Deskripsi Campaign</Label>
            <Input
              id="description"
              placeholder="Masukkan deskripsi campaign"
              {...register("description")}
            />
            {errors.description && (
              <p className="text-sm text-red-500">
                {errors.description.message}
              </p>
            )}
          </div>

          {/* Targeting Rules */}
          <div className="space-y-4">
            <h4 className="font-medium">Aturan Targeting</h4>
            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
              <div className="space-y-2">
                <Label>Jenis Pengguna</Label>
                <div className="space-y-2">
                  {["member", "guest", "new_user", "returning_user"].map(
                    (type) => (
                      <div key={type} className="flex items-center space-x-2">
                        <Checkbox
                          id={`userType-${type}`}
                          {...register(`targetingRules.userTypes.${type}`)}
                        />
                        <Label htmlFor={`userType-${type}`}>
                          {type === "member"
                            ? "Member"
                            : type === "guest"
                            ? "Tamu"
                            : type === "new_user"
                            ? "Pengguna Baru"
                            : "Pengguna Kembali"}
                        </Label>
                      </div>
                    )
                  )}
                </div>
              </div>

              <div className="space-y-2">
                <Label>Jenis Membership</Label>
                <div className="space-y-2">
                  {["monthly", "quarterly"].map((type) => (
                    <div key={type} className="flex items-center space-x-2">
                      <Checkbox
                        id={`membershipType-${type}`}
                        {...register(`targetingRules.membershipTypes.${type}`)}
                      />
                      <Label htmlFor={`membershipType-${type}`}>
                        {type === "monthly" ? "Bulanan" : "Triwulan"}
                      </Label>
                    </div>
                  ))}
                </div>
              </div>
            </div>
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

          <div className="flex items-center space-x-2">
            <Checkbox id="isActive" {...register("isActive")} />
            <Label htmlFor="isActive">Campaign Aktif</Label>
          </div>

          {error && <p className="text-sm text-red-500">{error}</p>}

          <div className="flex gap-4">
            <Button type="submit" disabled={isLoading}>
              {isLoading ? "Menyimpan..." : "Buat Campaign"}
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

### Campaign Management Development

```bash
# Start development server
npm run dev

# Test campaign management components
npm run test -- --testPathPattern=campaigns

# Test campaign management forms
npm run test -- --testPathPattern=campaign-forms
```

### Campaign Management Testing

```bash
# Test campaign management functionality
npm run test src/components/campaigns

# Test campaign management hooks
npm run test src/hooks/useCampaigns

# Test campaign management services
npm run test src/services/campaigns
```

## 🎨 UI Implementation

### Campaign Management Styling

```bash
# Create campaign management styles
mkdir -p src/styles/campaigns
touch src/styles/campaigns/campaignForm.css
touch src/styles/campaigns/campaignAnalytics.css
```

**Style Features:**

- Campaign form styling
- Campaign analytics styling
- Campaign template styling
- Campaign scheduler styling

### Campaign Management Layout

```bash
# Create campaign management layout
touch src/components/campaigns/CampaignLayout.tsx
touch src/components/campaigns/CampaignSidebar.tsx
```

**Layout Features:**

- Campaign management page layout
- Campaign management sidebar navigation
- Campaign management content area
- Responsive design

## 🔧 Integration Points

### API Integration

```bash
# Create campaign management API service
touch src/services/api/campaignApi.ts
touch src/services/api/campaignTemplateApi.ts
```

**API Features:**

- Campaign API integration
- Campaign template API integration
- Campaign analytics API integration
- Campaign scheduling API integration

### State Management

```bash
# Create campaign management state management
touch src/store/campaigns/campaignStore.ts
touch src/store/campaigns/campaignActions.ts
```

**State Features:**

- Campaign state management
- Campaign template state management
- Campaign analytics state management
- Campaign scheduling state management

## 🧪 Testing Strategy

### Unit Tests

```bash
# Test campaign management components
mkdir -p src/components/campaigns/__tests__
touch src/components/campaigns/__tests__/CampaignForm.test.tsx
touch src/components/campaigns/__tests__/CampaignTemplateLibrary.test.tsx
```

**Test Coverage:**

- Campaign form rendering
- Campaign form validation
- Campaign template functionality
- Campaign analytics functionality

### Integration Tests

```bash
# Test campaign management integration
mkdir -p src/__tests__/integration
touch src/__tests__/integration/campaign-management.test.tsx
```

**Integration Tests:**

- Complete campaign management workflow
- API integration
- State management integration
- Campaign validation integration

## 📱 Mobile Considerations

### Mobile Campaign Management

```bash
# Mobile campaign management components
touch src/components/campaigns/mobile/MobileCampaignForm.tsx
touch src/components/campaigns/mobile/MobileCampaignAnalytics.tsx
```

**Mobile Features:**

- Mobile-optimized campaign forms
- Mobile campaign analytics
- Touch-friendly interface
- Mobile campaign validation

### Performance Optimization

```bash
# Campaign management performance optimization
touch src/hooks/useCampaignPerformance.ts
```

**Optimizations:**

- Campaign form optimization
- Campaign analytics optimization
- Campaign template optimization
- API call optimization

## 🔒 Security Considerations

### Campaign Management Security

```bash
# Campaign management security utilities
touch src/utils/campaignSecurity.ts
touch src/utils/campaignValidation.ts
```

**Security Features:**

- Campaign validation
- Campaign template validation
- Campaign targeting validation
- Campaign scheduling validation

### Data Protection

```bash
# Data protection utilities
touch src/utils/campaignDataProtection.ts
touch src/utils/campaignPrivacy.ts
```

**Protection Features:**

- Campaign data protection
- Campaign template data protection
- Sensitive campaign data masking
- Privacy compliance

## 📊 Analytics & Monitoring

### Campaign Management Analytics

```bash
# Campaign management analytics
touch src/utils/campaignAnalytics.ts
touch src/hooks/useCampaignAnalytics.ts
```

**Analytics Features:**

- Campaign usage tracking
- Campaign performance analytics
- Campaign template analytics
- Campaign targeting analytics

### Error Monitoring

```bash
# Error monitoring untuk campaign management
touch src/utils/campaignErrorMonitoring.ts
touch src/hooks/useCampaignErrorMonitoring.ts
```

**Monitoring Features:**

- Campaign error tracking
- Campaign template error monitoring
- API error monitoring
- System alerts

## ✅ Success Criteria

- [ ] Promotional campaign creation dan management berfungsi
- [ ] Campaign template library implemented
- [ ] Campaign scheduling dan activation berfungsi
- [ ] Campaign analytics dan performance tracking implemented
- [ ] Campaign targeting dan eligibility berfungsi
- [ ] Campaign performance optimization implemented
- [ ] Campaign forms dengan proper validation
- [ ] Campaign management hooks dengan error handling
- [ ] Campaign management API integration
- [ ] Unit tests untuk campaign management components
- [ ] Integration tests untuk campaign management workflow
- [ ] Security measures untuk campaign data
- [ ] Data protection untuk sensitive campaign information
- [ ] Analytics tracking untuk campaign usage
- [ ] Error monitoring dan alerting
- [ ] Performance optimization untuk campaign management
- [ ] Mobile-responsive campaign management interface
- [ ] Accessibility features maintained
- [ ] Campaign management system health monitoring
- [ ] Campaign management system documentation dan user guides

## 📝 Notes

- Pastikan campaign management aman dan tidak vulnerable
- Implementasi proper validation untuk semua campaign inputs
- Setup proper error handling untuk campaign operations
- Test campaign management system dengan various scenarios
- Consider implementing campaign backup strategies
- Implementasi campaign management system reporting features
- Consider adding campaign notifications
- Implementasi campaign management system health monitoring
- Add campaign management system documentation dan training materials
