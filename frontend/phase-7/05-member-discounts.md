# Member Discounts Configuration Implementation

## 📋 Overview

Implementasi member discount configuration interface dengan member tier discounts, loyalty discounts, dan special member offers untuk Raujan Pool Syariah frontend.

## 🎯 Objectives

- Member tier discount configuration
- Loyalty discount management
- Special member offers
- Member discount analytics
- Discount eligibility management
- Member discount optimization

## 🔧 Implementation Steps

### Step 1: Create Member Discount Components

```bash
# Create member discount components
mkdir -p src/components/pricing/member-discounts
touch src/components/pricing/member-discounts/MemberDiscountForm.tsx
touch src/components/pricing/member-discounts/LoyaltyDiscountManager.tsx
touch src/components/pricing/member-discounts/SpecialOffersManager.tsx
touch src/components/pricing/member-discounts/DiscountEligibilityChecker.tsx
```

**Component Structure:**

- `MemberDiscountForm` - Member discount configuration form
- `LoyaltyDiscountManager` - Loyalty discount management
- `SpecialOffersManager` - Special member offers management
- `DiscountEligibilityChecker` - Discount eligibility checker

### Step 2: Setup Member Discount Validation

```bash
# Create member discount validation schemas
mkdir -p src/schemas/pricing/member-discounts
touch src/schemas/memberDiscountSchemas.ts
touch src/schemas/loyaltyDiscountSchemas.ts
```

**Validation Features:**

- Member discount validation
- Loyalty discount validation
- Special offers validation
- Discount eligibility validation

### Step 3: Create Member Discount Pages

```bash
# Create member discount pages
mkdir -p src/pages/pricing/member-discounts
touch src/pages/pricing/member-discounts/MemberDiscountsPage.tsx
touch src/pages/pricing/member-discounts/LoyaltyDiscountsPage.tsx
touch src/pages/pricing/member-discounts/SpecialOffersPage.tsx
touch src/pages/pricing/member-discounts/DiscountAnalyticsPage.tsx
```

**Page Structure:**

- `MemberDiscountsPage` - Main member discounts page
- `LoyaltyDiscountsPage` - Loyalty discounts page
- `SpecialOffersPage` - Special offers page
- `DiscountAnalyticsPage` - Discount analytics page

### Step 4: Setup Member Discount Hooks

```bash
# Create member discount hooks
touch src/hooks/useMemberDiscounts.ts
touch src/hooks/useLoyaltyDiscounts.ts
touch src/hooks/useSpecialOffers.ts
touch src/hooks/useDiscountEligibility.ts
```

**Hook Features:**

- Member discount management
- Loyalty discount management
- Special offers management
- Discount eligibility management

### Step 5: Create Member Discount Services

```bash
# Create member discount services
mkdir -p src/services/pricing/member-discounts
touch src/services/pricing/member-discounts/memberDiscountService.ts
touch src/services/pricing/member-discounts/loyaltyDiscountService.ts
touch src/services/pricing/member-discounts/specialOffersService.ts
```

**Service Features:**

- Member discount API service
- Loyalty discount API service
- Special offers API service
- Discount eligibility API service

## 📊 Configuration Files

### src/schemas/memberDiscountSchemas.ts

```typescript
// Member discount validation schemas
import { z } from "zod";

export const memberDiscountSchema = z.object({
  name: z.string().min(2, "Nama discount minimal 2 karakter"),
  description: z.string().optional(),
  discountType: z.enum(["percentage", "fixed_amount", "tier_based"]),
  discountValue: z.number().min(0, "Nilai discount tidak boleh negatif"),
  memberTier: z.enum(["bronze", "silver", "gold", "platinum", "diamond"]),
  isActive: z.boolean().default(true),
  applicableServices: z
    .array(z.enum(["pool_booking", "cafe_order", "private_pool", "all"]))
    .default(["all"]),
  conditions: z
    .object({
      minMembershipDuration: z.number().min(0).optional(), // dalam bulan
      minSpend: z.number().min(0).optional(),
      maxUsage: z.number().min(1).optional(),
      usagePerUser: z.number().min(1).optional(),
      validFrom: z.string().optional(),
      validTo: z.string().optional(),
    })
    .optional(),
  tierRequirements: z
    .object({
      bronze: z
        .object({
          minSpend: z.number().min(0).optional(),
          minVisits: z.number().min(0).optional(),
          discountPercentage: z.number().min(0).max(100).optional(),
        })
        .optional(),
      silver: z
        .object({
          minSpend: z.number().min(0).optional(),
          minVisits: z.number().min(0).optional(),
          discountPercentage: z.number().min(0).max(100).optional(),
        })
        .optional(),
      gold: z
        .object({
          minSpend: z.number().min(0).optional(),
          minVisits: z.number().min(0).optional(),
          discountPercentage: z.number().min(0).max(100).optional(),
        })
        .optional(),
      platinum: z
        .object({
          minSpend: z.number().min(0).optional(),
          minVisits: z.number().min(0).optional(),
          discountPercentage: z.number().min(0).max(100).optional(),
        })
        .optional(),
      diamond: z
        .object({
          minSpend: z.number().min(0).optional(),
          minVisits: z.number().min(0).optional(),
          discountPercentage: z.number().min(0).max(100).optional(),
        })
        .optional(),
    })
    .optional(),
});

export const loyaltyDiscountSchema = z.object({
  name: z.string().min(2, "Nama loyalty discount minimal 2 karakter"),
  description: z.string().optional(),
  loyaltyType: z.enum([
    "visit_based",
    "spend_based",
    "duration_based",
    "referral_based",
  ]),
  discountValue: z.number().min(0, "Nilai discount tidak boleh negatif"),
  isActive: z.boolean().default(true),
  applicableServices: z
    .array(z.enum(["pool_booking", "cafe_order", "private_pool", "all"]))
    .default(["all"]),
  loyaltyRules: z.object({
    visitBased: z
      .object({
        minVisits: z.number().min(1).optional(),
        maxVisits: z.number().min(1).optional(),
        discountPercentage: z.number().min(0).max(100).optional(),
      })
      .optional(),
    spendBased: z
      .object({
        minSpend: z.number().min(0).optional(),
        maxSpend: z.number().min(0).optional(),
        discountPercentage: z.number().min(0).max(100).optional(),
      })
      .optional(),
    durationBased: z
      .object({
        minDuration: z.number().min(1).optional(), // dalam bulan
        maxDuration: z.number().min(1).optional(),
        discountPercentage: z.number().min(0).max(100).optional(),
      })
      .optional(),
    referralBased: z
      .object({
        minReferrals: z.number().min(1).optional(),
        maxReferrals: z.number().min(1).optional(),
        discountPercentage: z.number().min(0).max(100).optional(),
      })
      .optional(),
  }),
  conditions: z
    .object({
      validFrom: z.string().optional(),
      validTo: z.string().optional(),
      maxUsage: z.number().min(1).optional(),
      usagePerUser: z.number().min(1).optional(),
    })
    .optional(),
});

export const specialOffersSchema = z.object({
  name: z.string().min(2, "Nama special offer minimal 2 karakter"),
  description: z.string().optional(),
  offerType: z.enum([
    "birthday",
    "anniversary",
    "new_member",
    "returning_member",
    "vip",
  ]),
  discountValue: z.number().min(0, "Nilai discount tidak boleh negatif"),
  isActive: z.boolean().default(true),
  applicableServices: z
    .array(z.enum(["pool_booking", "cafe_order", "private_pool", "all"]))
    .default(["all"]),
  offerRules: z.object({
    birthday: z
      .object({
        daysBefore: z.number().min(0).optional(),
        daysAfter: z.number().min(0).optional(),
        discountPercentage: z.number().min(0).max(100).optional(),
      })
      .optional(),
    anniversary: z
      .object({
        yearsRequired: z.number().min(1).optional(),
        daysBefore: z.number().min(0).optional(),
        daysAfter: z.number().min(0).optional(),
        discountPercentage: z.number().min(0).max(100).optional(),
      })
      .optional(),
    newMember: z
      .object({
        daysAfterRegistration: z.number().min(1).optional(),
        discountPercentage: z.number().min(0).max(100).optional(),
      })
      .optional(),
    returningMember: z
      .object({
        daysSinceLastVisit: z.number().min(1).optional(),
        discountPercentage: z.number().min(0).max(100).optional(),
      })
      .optional(),
    vip: z
      .object({
        minSpend: z.number().min(0).optional(),
        minVisits: z.number().min(0).optional(),
        discountPercentage: z.number().min(0).max(100).optional(),
      })
      .optional(),
  }),
  conditions: z
    .object({
      validFrom: z.string().optional(),
      validTo: z.string().optional(),
      maxUsage: z.number().min(1).optional(),
      usagePerUser: z.number().min(1).optional(),
    })
    .optional(),
});

export const discountEligibilitySchema = z.object({
  memberId: z.string().min(1, "Member ID diperlukan"),
  serviceType: z.enum(["pool_booking", "cafe_order", "private_pool"]),
  amount: z.number().min(0, "Amount tidak boleh negatif"),
  date: z.string().min(1, "Tanggal diperlukan"),
  applicableDiscounts: z.array(
    z.object({
      discountId: z.string(),
      discountName: z.string(),
      discountType: z.enum(["percentage", "fixed_amount"]),
      discountValue: z.number(),
      eligibility: z.boolean(),
      reason: z.string().optional(),
    })
  ),
});

export type MemberDiscountFormData = z.infer<typeof memberDiscountSchema>;
export type LoyaltyDiscountFormData = z.infer<typeof loyaltyDiscountSchema>;
export type SpecialOffersFormData = z.infer<typeof specialOffersSchema>;
export type DiscountEligibilityFormData = z.infer<
  typeof discountEligibilitySchema
>;
```

### src/hooks/useMemberDiscounts.ts

```typescript
// Member discount hook
import { useState, useEffect } from "react";
import { memberDiscountService } from "@/services/pricing/member-discounts/memberDiscountService";
import { MemberDiscountFormData } from "@/schemas/memberDiscountSchemas";

export function useMemberDiscounts() {
  const [memberDiscounts, setMemberDiscounts] = useState([]);
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const createMemberDiscount = async (data: MemberDiscountFormData) => {
    setIsLoading(true);
    setError(null);
    try {
      const newDiscount = await memberDiscountService.createMemberDiscount(
        data
      );
      setMemberDiscounts((prev) => [...prev, newDiscount]);
      return { success: true, discount: newDiscount };
    } catch (err) {
      setError(err.message);
      return { success: false, error: err.message };
    } finally {
      setIsLoading(false);
    }
  };

  const updateMemberDiscount = async (
    id: string,
    data: MemberDiscountFormData
  ) => {
    setIsLoading(true);
    setError(null);
    try {
      const updatedDiscount = await memberDiscountService.updateMemberDiscount(
        id,
        data
      );
      setMemberDiscounts((prev) =>
        prev.map((discount) =>
          discount.id === id ? updatedDiscount : discount
        )
      );
      return { success: true, discount: updatedDiscount };
    } catch (err) {
      setError(err.message);
      return { success: false, error: err.message };
    } finally {
      setIsLoading(false);
    }
  };

  const deleteMemberDiscount = async (id: string) => {
    setIsLoading(true);
    setError(null);
    try {
      await memberDiscountService.deleteMemberDiscount(id);
      setMemberDiscounts((prev) =>
        prev.filter((discount) => discount.id !== id)
      );
      return { success: true };
    } catch (err) {
      setError(err.message);
      return { success: false, error: err.message };
    } finally {
      setIsLoading(false);
    }
  };

  const getMemberDiscounts = async () => {
    setIsLoading(true);
    setError(null);
    try {
      const discounts = await memberDiscountService.getMemberDiscounts();
      setMemberDiscounts(discounts);
      return { success: true, discounts };
    } catch (err) {
      setError(err.message);
      return { success: false, error: err.message };
    } finally {
      setIsLoading(false);
    }
  };

  const getMemberDiscountsByTier = async (tier: string) => {
    setIsLoading(true);
    setError(null);
    try {
      const discounts = await memberDiscountService.getMemberDiscountsByTier(
        tier
      );
      return { success: true, discounts };
    } catch (err) {
      setError(err.message);
      return { success: false, error: err.message };
    } finally {
      setIsLoading(false);
    }
  };

  const checkDiscountEligibility = async (
    memberId: string,
    serviceType: string,
    amount: number
  ) => {
    setIsLoading(true);
    setError(null);
    try {
      const eligibility = await memberDiscountService.checkDiscountEligibility(
        memberId,
        serviceType,
        amount
      );
      return { success: true, eligibility };
    } catch (err) {
      setError(err.message);
      return { success: false, error: err.message };
    } finally {
      setIsLoading(false);
    }
  };

  useEffect(() => {
    getMemberDiscounts();
  }, []);

  return {
    memberDiscounts,
    isLoading,
    error,
    createMemberDiscount,
    updateMemberDiscount,
    deleteMemberDiscount,
    getMemberDiscounts,
    getMemberDiscountsByTier,
    checkDiscountEligibility,
    clearError: () => setError(null),
  };
}
```

### src/components/pricing/member-discounts/MemberDiscountForm.tsx

```typescript
// Member discount form component
import { useForm } from "react-hook-form";
import { zodResolver } from "@hookform/resolvers/zod";
import {
  memberDiscountSchema,
  MemberDiscountFormData,
} from "@/schemas/memberDiscountSchemas";
import { useMemberDiscounts } from "@/hooks/useMemberDiscounts";
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

export function MemberDiscountForm() {
  const { createMemberDiscount, isLoading, error, clearError } =
    useMemberDiscounts();

  const {
    register,
    handleSubmit,
    formState: { errors },
    reset,
    watch,
  } = useForm<MemberDiscountFormData>({
    resolver: zodResolver(memberDiscountSchema),
    defaultValues: {
      isActive: true,
      applicableServices: ["all"],
      discountType: "percentage",
      memberTier: "bronze",
    },
  });

  const discountType = watch("discountType");
  const memberTier = watch("memberTier");

  const onSubmit = async (data: MemberDiscountFormData) => {
    clearError();
    const result = await createMemberDiscount(data);
    if (result.success) {
      reset();
      // Show success message
    }
  };

  return (
    <Card className="w-full max-w-4xl">
      <CardHeader>
        <CardTitle>Konfigurasi Diskon Member</CardTitle>
        <p className="text-sm text-gray-500">
          Buat konfigurasi diskon berdasarkan tier member dan loyalitas
        </p>
      </CardHeader>
      <CardContent>
        <form onSubmit={handleSubmit(onSubmit)} className="space-y-6">
          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div className="space-y-2">
              <Label htmlFor="name">Nama Diskon</Label>
              <Input
                id="name"
                placeholder="Masukkan nama diskon"
                {...register("name")}
              />
              {errors.name && (
                <p className="text-sm text-red-500">{errors.name.message}</p>
              )}
            </div>

            <div className="space-y-2">
              <Label htmlFor="memberTier">Tier Member</Label>
              <Select {...register("memberTier")}>
                <SelectTrigger>
                  <SelectValue placeholder="Pilih tier member" />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="bronze">Bronze</SelectItem>
                  <SelectItem value="silver">Silver</SelectItem>
                  <SelectItem value="gold">Gold</SelectItem>
                  <SelectItem value="platinum">Platinum</SelectItem>
                  <SelectItem value="diamond">Diamond</SelectItem>
                </SelectContent>
              </Select>
              {errors.memberTier && (
                <p className="text-sm text-red-500">
                  {errors.memberTier.message}
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
                  <SelectItem value="tier_based">Berdasarkan Tier</SelectItem>
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
                  : "Nilai Diskon"}
              </Label>
              <Input
                id="discountValue"
                type="number"
                placeholder={
                  discountType === "percentage"
                    ? "Masukkan persentase"
                    : discountType === "fixed_amount"
                    ? "Masukkan jumlah"
                    : "Masukkan nilai diskon"
                }
                {...register("discountValue", { valueAsNumber: true })}
              />
              {errors.discountValue && (
                <p className="text-sm text-red-500">
                  {errors.discountValue.message}
                </p>
              )}
            </div>
          </div>

          <div className="space-y-2">
            <Label htmlFor="description">Deskripsi</Label>
            <Input
              id="description"
              placeholder="Masukkan deskripsi diskon"
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
            <h4 className="font-medium">Kondisi Diskon</h4>
            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
              <div className="space-y-2">
                <Label htmlFor="minMembershipDuration">
                  Durasi Membership Minimum (bulan)
                </Label>
                <Input
                  id="minMembershipDuration"
                  type="number"
                  placeholder="Masukkan durasi minimum"
                  {...register("conditions.minMembershipDuration", {
                    valueAsNumber: true,
                  })}
                />
              </div>
              <div className="space-y-2">
                <Label htmlFor="minSpend">Minimum Spend (IDR)</Label>
                <Input
                  id="minSpend"
                  type="number"
                  placeholder="Masukkan minimum spend"
                  {...register("conditions.minSpend", { valueAsNumber: true })}
                />
              </div>
              <div className="space-y-2">
                <Label htmlFor="maxUsage">Maximum Usage</Label>
                <Input
                  id="maxUsage"
                  type="number"
                  placeholder="Masukkan maximum usage"
                  {...register("conditions.maxUsage", { valueAsNumber: true })}
                />
              </div>
              <div className="space-y-2">
                <Label htmlFor="usagePerUser">Usage per User</Label>
                <Input
                  id="usagePerUser"
                  type="number"
                  placeholder="Masukkan usage per user"
                  {...register("conditions.usagePerUser", {
                    valueAsNumber: true,
                  })}
                />
              </div>
              <div className="space-y-2">
                <Label htmlFor="validFrom">Valid From</Label>
                <Input
                  id="validFrom"
                  type="date"
                  {...register("conditions.validFrom")}
                />
              </div>
              <div className="space-y-2">
                <Label htmlFor="validTo">Valid To</Label>
                <Input
                  id="validTo"
                  type="date"
                  {...register("conditions.validTo")}
                />
              </div>
            </div>
          </div>

          {/* Tier Requirements */}
          {discountType === "tier_based" && (
            <div className="space-y-4">
              <h4 className="font-medium">Persyaratan Tier</h4>
              <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                {["bronze", "silver", "gold", "platinum", "diamond"].map(
                  (tier) => (
                    <div key={tier} className="border rounded-lg p-4">
                      <h5 className="font-medium capitalize mb-3">{tier}</h5>
                      <div className="space-y-2">
                        <div className="space-y-1">
                          <Label htmlFor={`${tier}-minSpend`}>
                            Minimum Spend (IDR)
                          </Label>
                          <Input
                            id={`${tier}-minSpend`}
                            type="number"
                            placeholder="Masukkan minimum spend"
                            {...register(`tierRequirements.${tier}.minSpend`, {
                              valueAsNumber: true,
                            })}
                          />
                        </div>
                        <div className="space-y-1">
                          <Label htmlFor={`${tier}-minVisits`}>
                            Minimum Visits
                          </Label>
                          <Input
                            id={`${tier}-minVisits`}
                            type="number"
                            placeholder="Masukkan minimum visits"
                            {...register(`tierRequirements.${tier}.minVisits`, {
                              valueAsNumber: true,
                            })}
                          />
                        </div>
                        <div className="space-y-1">
                          <Label htmlFor={`${tier}-discountPercentage`}>
                            Discount Percentage (%)
                          </Label>
                          <Input
                            id={`${tier}-discountPercentage`}
                            type="number"
                            placeholder="Masukkan discount percentage"
                            {...register(
                              `tierRequirements.${tier}.discountPercentage`,
                              { valueAsNumber: true }
                            )}
                          />
                        </div>
                      </div>
                    </div>
                  )
                )}
              </div>
            </div>
          )}

          <div className="flex items-center space-x-2">
            <Checkbox id="isActive" {...register("isActive")} />
            <Label htmlFor="isActive">Diskon Aktif</Label>
          </div>

          {error && <p className="text-sm text-red-500">{error}</p>}

          <div className="flex gap-4">
            <Button type="submit" disabled={isLoading}>
              {isLoading ? "Menyimpan..." : "Simpan Diskon"}
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

### Member Discount Development

```bash
# Start development server
npm run dev

# Test member discount components
npm run test -- --testPathPattern=member-discounts

# Test member discount forms
npm run test -- --testPathPattern=member-discount-forms
```

### Member Discount Testing

```bash
# Test member discount functionality
npm run test src/components/pricing/member-discounts

# Test member discount hooks
npm run test src/hooks/useMemberDiscounts

# Test member discount services
npm run test src/services/pricing/member-discounts
```

## 🎨 UI Implementation

### Member Discount Styling

```bash
# Create member discount styles
mkdir -p src/styles/pricing/member-discounts
touch src/styles/pricing/member-discounts/memberDiscount.css
touch src/styles/pricing/member-discounts/loyaltyDiscount.css
```

**Style Features:**

- Member discount form styling
- Loyalty discount styling
- Special offers styling
- Discount eligibility styling

### Member Discount Layout

```bash
# Create member discount layout
touch src/components/pricing/member-discounts/MemberDiscountLayout.tsx
touch src/components/pricing/member-discounts/MemberDiscountSidebar.tsx
```

**Layout Features:**

- Member discount page layout
- Member discount sidebar navigation
- Member discount content area
- Responsive design

## 🔧 Integration Points

### API Integration

```bash
# Create member discount API service
touch src/services/api/memberDiscountApi.ts
touch src/services/api/loyaltyDiscountApi.ts
```

**API Features:**

- Member discount API integration
- Loyalty discount API integration
- Special offers API integration
- Discount eligibility API integration

### State Management

```bash
# Create member discount state management
touch src/store/pricing/member-discounts/memberDiscountStore.ts
touch src/store/pricing/member-discounts/memberDiscountActions.ts
```

**State Features:**

- Member discount state management
- Loyalty discount state management
- Special offers state management
- Discount eligibility state management

## 🧪 Testing Strategy

### Unit Tests

```bash
# Test member discount components
mkdir -p src/components/pricing/member-discounts/__tests__
touch src/components/pricing/member-discounts/__tests__/MemberDiscountForm.test.tsx
touch src/components/pricing/member-discounts/__tests__/LoyaltyDiscountManager.test.tsx
```

**Test Coverage:**

- Member discount form rendering
- Member discount form validation
- Loyalty discount functionality
- Special offers functionality

### Integration Tests

```bash
# Test member discount integration
mkdir -p src/__tests__/integration
touch src/__tests__/integration/member-discounts.test.tsx
```

**Integration Tests:**

- Complete member discount workflow
- API integration
- State management integration
- Discount eligibility integration

## 📱 Mobile Considerations

### Mobile Member Discount

```bash
# Mobile member discount components
touch src/components/pricing/member-discounts/mobile/MobileMemberDiscountForm.tsx
touch src/components/pricing/member-discounts/mobile/MobileDiscountEligibility.tsx
```

**Mobile Features:**

- Mobile-optimized member discount forms
- Mobile discount eligibility checker
- Touch-friendly interface
- Mobile discount validation

### Performance Optimization

```bash
# Member discount performance optimization
touch src/hooks/useMemberDiscountPerformance.ts
```

**Optimizations:**

- Member discount form optimization
- Discount eligibility optimization
- Discount validation optimization
- API call optimization

## 🔒 Security Considerations

### Member Discount Security

```bash
# Member discount security utilities
touch src/utils/memberDiscountSecurity.ts
touch src/utils/memberDiscountValidation.ts
```

**Security Features:**

- Member discount validation
- Loyalty discount validation
- Special offers validation
- Discount eligibility validation

### Data Protection

```bash
# Data protection utilities
touch src/utils/memberDiscountDataProtection.ts
touch src/utils/memberDiscountPrivacy.ts
```

**Protection Features:**

- Member discount data protection
- Loyalty discount data protection
- Sensitive discount data masking
- Privacy compliance

## 📊 Analytics & Monitoring

### Member Discount Analytics

```bash
# Member discount analytics
touch src/utils/memberDiscountAnalytics.ts
touch src/hooks/useMemberDiscountAnalytics.ts
```

**Analytics Features:**

- Member discount usage tracking
- Loyalty discount analytics
- Special offers analytics
- Discount eligibility analytics

### Error Monitoring

```bash
# Error monitoring untuk member discount
touch src/utils/memberDiscountErrorMonitoring.ts
touch src/hooks/useMemberDiscountErrorMonitoring.ts
```

**Monitoring Features:**

- Member discount error tracking
- Loyalty discount error monitoring
- Special offers error monitoring
- API error monitoring

## ✅ Success Criteria

- [ ] Member tier discount configuration berfungsi
- [ ] Loyalty discount management implemented
- [ ] Special member offers berfungsi
- [ ] Member discount analytics implemented
- [ ] Discount eligibility management berfungsi
- [ ] Member discount optimization implemented
- [ ] Member discount forms dengan proper validation
- [ ] Member discount hooks dengan error handling
- [ ] Member discount API integration
- [ ] Unit tests untuk member discount components
- [ ] Integration tests untuk member discount workflow
- [ ] Security measures untuk member discount data
- [ ] Data protection untuk sensitive discount information
- [ ] Analytics tracking untuk member discount usage
- [ ] Error monitoring dan alerting
- [ ] Performance optimization untuk member discount
- [ ] Mobile-responsive member discount interface
- [ ] Accessibility features maintained
- [ ] Member discount system health monitoring
- [ ] Member discount system documentation dan user guides

## 📝 Notes

- Pastikan member discount aman dan tidak vulnerable
- Implementasi proper validation untuk semua member discount inputs
- Setup proper error handling untuk member discount operations
- Test member discount system dengan various scenarios
- Consider implementing member discount backup strategies
- Implementasi member discount system reporting features
- Consider adding member discount notifications
- Implementasi member discount system health monitoring
- Add member discount system documentation dan training materials
