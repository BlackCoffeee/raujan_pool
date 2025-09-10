# Guest User UI Implementation

## 📋 Overview

Implementasi guest user interface dengan limited access, basic booking functionality, dan guest-to-member conversion untuk Raujan Pool Syariah frontend.

## 🎯 Objectives

- Guest user interface implementation
- Limited access management
- Basic booking functionality
- Guest-to-member conversion
- Guest session management
- Guest data collection

## 🔧 Implementation Steps

### Step 1: Create Guest Components

```bash
# Create guest components
mkdir -p src/components/guest
touch src/components/guest/GuestDashboard.tsx
touch src/components/guest/GuestBookingForm.tsx
touch src/components/guest/GuestRegistrationPrompt.tsx
touch src/components/guest/GuestNavigation.tsx
```

**Component Structure:**

- `GuestDashboard` - Guest dashboard interface
- `GuestBookingForm` - Guest booking form
- `GuestRegistrationPrompt` - Registration prompt
- `GuestNavigation` - Guest navigation

### Step 2: Setup Guest State Management

```bash
# Create guest state management
mkdir -p src/store/guest
touch src/store/guest/guestStore.ts
touch src/store/guest/guestActions.ts
touch src/store/guest/guestTypes.ts
```

**State Features:**

- Guest session state
- Guest booking state
- Guest data state
- Guest conversion state

### Step 3: Create Guest Pages

```bash
# Create guest pages
mkdir -p src/pages/guest
touch src/pages/guest/GuestHomePage.tsx
touch src/pages/guest/GuestBookingPage.tsx
touch src/pages/guest/GuestServicesPage.tsx
touch src/pages/guest/GuestContactPage.tsx
```

**Page Structure:**

- `GuestHomePage` - Guest home page
- `GuestBookingPage` - Guest booking page
- `GuestServicesPage` - Guest services page
- `GuestContactPage` - Guest contact page

### Step 4: Setup Guest Hooks

```bash
# Create guest hooks
touch src/hooks/useGuest.ts
touch src/hooks/useGuestBooking.ts
touch src/hooks/useGuestConversion.ts
touch src/hooks/useGuestSession.ts
```

**Hook Features:**

- Guest state management
- Guest booking functionality
- Guest conversion functionality
- Guest session management

### Step 5: Create Guest Services

```bash
# Create guest services
mkdir -p src/services/guest
touch src/services/guest/guestService.ts
touch src/services/guest/guestBookingService.ts
touch src/services/guest/guestConversionService.ts
```

**Service Features:**

- Guest API service
- Guest booking service
- Guest conversion service
- Guest session service

## 📊 Configuration Files

### src/store/guest/guestTypes.ts

```typescript
// Guest types
export interface GuestUser {
  id: string;
  sessionId: string;
  name?: string;
  email?: string;
  phone?: string;
  isRegistered: boolean;
  createdAt: string;
  lastActivity: string;
}

export interface GuestBooking {
  id: string;
  guestId: string;
  poolId: string;
  date: string;
  timeSlot: string;
  duration: number;
  guests: number;
  totalPrice: number;
  status: "pending" | "confirmed" | "cancelled";
  createdAt: string;
}

export interface GuestSession {
  id: string;
  guestId: string;
  startTime: string;
  lastActivity: string;
  isActive: boolean;
  data: {
    pageViews: number;
    actions: string[];
    conversionAttempts: number;
  };
}

export interface GuestConversion {
  guestId: string;
  conversionType: "booking" | "registration" | "contact";
  conversionData: any;
  timestamp: string;
  success: boolean;
}
```

### src/hooks/useGuest.ts

```typescript
// Guest management hook
import { useState, useEffect } from "react";
import { useGuestStore } from "@/store/guest/guestStore";
import { guestService } from "@/services/guest/guestService";

export function useGuest() {
  const {
    guest,
    session,
    isGuest,
    isLoading,
    error,
    createGuestSession,
    updateGuestData,
    clearGuestSession,
  } = useGuestStore();

  const [conversionPrompt, setConversionPrompt] = useState(false);

  useEffect(() => {
    if (!guest) {
      createGuestSession();
    }
  }, [guest, createGuestSession]);

  const updateGuest = async (data: Partial<GuestUser>) => {
    try {
      await updateGuestData(data);
      return { success: true };
    } catch (err) {
      return { success: false, error: err.message };
    }
  };

  const showConversionPrompt = () => {
    setConversionPrompt(true);
  };

  const hideConversionPrompt = () => {
    setConversionPrompt(false);
  };

  const convertToMember = async (memberData: any) => {
    try {
      const result = await guestService.convertToMember(guest.id, memberData);
      if (result.success) {
        clearGuestSession();
        return { success: true, member: result.member };
      }
      return { success: false, error: result.error };
    } catch (err) {
      return { success: false, error: err.message };
    }
  };

  return {
    guest,
    session,
    isGuest,
    isLoading,
    error,
    conversionPrompt,
    updateGuest,
    showConversionPrompt,
    hideConversionPrompt,
    convertToMember,
    clearGuestSession,
  };
}
```

### src/components/guest/GuestDashboard.tsx

```typescript
// Guest dashboard component
import { useGuest } from "@/hooks/useGuest";
import { useGuestBooking } from "@/hooks/useGuestBooking";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import { Calendar, Clock, Users, CreditCard } from "lucide-react";

export function GuestDashboard() {
  const { guest, showConversionPrompt } = useGuest();
  const { bookings, isLoading } = useGuestBooking();

  return (
    <div className="space-y-6">
      {/* Welcome Section */}
      <div className="bg-gradient-to-r from-blue-500 to-green-500 text-white p-6 rounded-lg">
        <h1 className="text-2xl font-bold mb-2">
          Selamat Datang di Raujan Pool Syariah
        </h1>
        <p className="text-blue-100">
          Nikmati pengalaman berenang yang menyenangkan dengan fasilitas terbaik
        </p>
        <Button
          onClick={showConversionPrompt}
          className="mt-4 bg-white text-blue-600 hover:bg-blue-50"
        >
          Daftar sebagai Member
        </Button>
      </div>

      {/* Quick Actions */}
      <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">Booking Cepat</CardTitle>
            <Calendar className="h-4 w-4 text-muted-foreground" />
          </CardHeader>
          <CardContent>
            <Button className="w-full" variant="outline">
              Buat Booking
            </Button>
          </CardContent>
        </Card>

        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">Lihat Jadwal</CardTitle>
            <Clock className="h-4 w-4 text-muted-foreground" />
          </CardHeader>
          <CardContent>
            <Button className="w-full" variant="outline">
              Jadwal Pool
            </Button>
          </CardContent>
        </Card>

        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">Hubungi Kami</CardTitle>
            <Users className="h-4 w-4 text-muted-foreground" />
          </CardHeader>
          <CardContent>
            <Button className="w-full" variant="outline">
              Kontak
            </Button>
          </CardContent>
        </Card>
      </div>

      {/* Recent Bookings */}
      {bookings.length > 0 && (
        <Card>
          <CardHeader>
            <CardTitle>Booking Terbaru</CardTitle>
          </CardHeader>
          <CardContent>
            <div className="space-y-4">
              {bookings.slice(0, 3).map((booking) => (
                <div
                  key={booking.id}
                  className="flex items-center justify-between p-4 border rounded-lg"
                >
                  <div className="space-y-1">
                    <p className="font-medium">Pool {booking.poolId}</p>
                    <p className="text-sm text-gray-500">
                      {new Date(booking.date).toLocaleDateString()} -{" "}
                      {booking.timeSlot}
                    </p>
                  </div>
                  <div className="flex items-center space-x-2">
                    <Badge
                      variant={
                        booking.status === "confirmed"
                          ? "default"
                          : booking.status === "pending"
                          ? "secondary"
                          : "destructive"
                      }
                    >
                      {booking.status}
                    </Badge>
                    <span className="text-sm font-medium">
                      Rp {booking.totalPrice.toLocaleString()}
                    </span>
                  </div>
                </div>
              ))}
            </div>
          </CardContent>
        </Card>
      )}

      {/* Services Overview */}
      <Card>
        <CardHeader>
          <CardTitle>Layanan Kami</CardTitle>
        </CardHeader>
        <CardContent>
          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div className="space-y-2">
              <h4 className="font-medium">Kolam Renang</h4>
              <p className="text-sm text-gray-500">
                Kolam renang dengan standar internasional
              </p>
            </div>
            <div className="space-y-2">
              <h4 className="font-medium">Cafe & Restoran</h4>
              <p className="text-sm text-gray-500">
                Menu sehat dan segar untuk keluarga
              </p>
            </div>
            <div className="space-y-2">
              <h4 className="font-medium">Fasilitas</h4>
              <p className="text-sm text-gray-500">
                Locker, shower, dan area istirahat
              </p>
            </div>
            <div className="space-y-2">
              <h4 className="font-medium">Parkir</h4>
              <p className="text-sm text-gray-500">Area parkir luas dan aman</p>
            </div>
          </div>
        </CardContent>
      </Card>
    </div>
  );
}
```

### src/components/guest/GuestBookingForm.tsx

```typescript
// Guest booking form component
import { useState } from "react";
import { useForm } from "react-hook-form";
import { zodResolver } from "@hookform/resolvers/zod";
import { z } from "zod";
import { useGuestBooking } from "@/hooks/useGuestBooking";
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

const guestBookingSchema = z.object({
  name: z.string().min(2, "Nama minimal 2 karakter"),
  email: z.string().email("Email tidak valid"),
  phone: z.string().min(10, "Nomor telepon minimal 10 digit"),
  poolId: z.string().min(1, "Pilih pool"),
  date: z.string().min(1, "Pilih tanggal"),
  timeSlot: z.string().min(1, "Pilih waktu"),
  duration: z.number().min(1, "Durasi minimal 1 jam"),
  guests: z.number().min(1, "Jumlah tamu minimal 1"),
});

type GuestBookingFormData = z.infer<typeof guestBookingSchema>;

export function GuestBookingForm() {
  const { createBooking, isLoading, error } = useGuestBooking();
  const [showRegistrationPrompt, setShowRegistrationPrompt] = useState(false);

  const {
    register,
    handleSubmit,
    formState: { errors },
    watch,
  } = useForm<GuestBookingFormData>({
    resolver: zodResolver(guestBookingSchema),
  });

  const onSubmit = async (data: GuestBookingFormData) => {
    const result = await createBooking(data);
    if (result.success) {
      setShowRegistrationPrompt(true);
    }
  };

  const duration = watch("duration") || 1;
  const guests = watch("guests") || 1;
  const basePrice = 50000; // Base price per hour
  const totalPrice = basePrice * duration * guests;

  return (
    <Card className="w-full max-w-2xl">
      <CardHeader>
        <CardTitle>Booking sebagai Tamu</CardTitle>
        <p className="text-sm text-gray-500">
          Isi data diri untuk melanjutkan booking
        </p>
      </CardHeader>
      <CardContent>
        <form onSubmit={handleSubmit(onSubmit)} className="space-y-4">
          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div className="space-y-2">
              <Label htmlFor="name">Nama Lengkap</Label>
              <Input
                id="name"
                placeholder="Masukkan nama lengkap"
                {...register("name")}
              />
              {errors.name && (
                <p className="text-sm text-red-500">{errors.name.message}</p>
              )}
            </div>

            <div className="space-y-2">
              <Label htmlFor="email">Email</Label>
              <Input
                id="email"
                type="email"
                placeholder="Masukkan email"
                {...register("email")}
              />
              {errors.email && (
                <p className="text-sm text-red-500">{errors.email.message}</p>
              )}
            </div>

            <div className="space-y-2">
              <Label htmlFor="phone">Nomor Telepon</Label>
              <Input
                id="phone"
                type="tel"
                placeholder="Masukkan nomor telepon"
                {...register("phone")}
              />
              {errors.phone && (
                <p className="text-sm text-red-500">{errors.phone.message}</p>
              )}
            </div>

            <div className="space-y-2">
              <Label htmlFor="poolId">Pilih Pool</Label>
              <Select {...register("poolId")}>
                <SelectTrigger>
                  <SelectValue placeholder="Pilih pool" />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="pool-1">Pool Utama</SelectItem>
                  <SelectItem value="pool-2">Pool Anak</SelectItem>
                  <SelectItem value="pool-3">Pool VIP</SelectItem>
                </SelectContent>
              </Select>
              {errors.poolId && (
                <p className="text-sm text-red-500">{errors.poolId.message}</p>
              )}
            </div>

            <div className="space-y-2">
              <Label htmlFor="date">Tanggal</Label>
              <Input id="date" type="date" {...register("date")} />
              {errors.date && (
                <p className="text-sm text-red-500">{errors.date.message}</p>
              )}
            </div>

            <div className="space-y-2">
              <Label htmlFor="timeSlot">Waktu</Label>
              <Select {...register("timeSlot")}>
                <SelectTrigger>
                  <SelectValue placeholder="Pilih waktu" />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="08:00">08:00</SelectItem>
                  <SelectItem value="09:00">09:00</SelectItem>
                  <SelectItem value="10:00">10:00</SelectItem>
                  <SelectItem value="11:00">11:00</SelectItem>
                  <SelectItem value="12:00">12:00</SelectItem>
                  <SelectItem value="13:00">13:00</SelectItem>
                  <SelectItem value="14:00">14:00</SelectItem>
                  <SelectItem value="15:00">15:00</SelectItem>
                  <SelectItem value="16:00">16:00</SelectItem>
                  <SelectItem value="17:00">17:00</SelectItem>
                  <SelectItem value="18:00">18:00</SelectItem>
                  <SelectItem value="19:00">19:00</SelectItem>
                </SelectContent>
              </Select>
              {errors.timeSlot && (
                <p className="text-sm text-red-500">
                  {errors.timeSlot.message}
                </p>
              )}
            </div>

            <div className="space-y-2">
              <Label htmlFor="duration">Durasi (jam)</Label>
              <Input
                id="duration"
                type="number"
                min="1"
                max="8"
                {...register("duration", { valueAsNumber: true })}
              />
              {errors.duration && (
                <p className="text-sm text-red-500">
                  {errors.duration.message}
                </p>
              )}
            </div>

            <div className="space-y-2">
              <Label htmlFor="guests">Jumlah Tamu</Label>
              <Input
                id="guests"
                type="number"
                min="1"
                max="10"
                {...register("guests", { valueAsNumber: true })}
              />
              {errors.guests && (
                <p className="text-sm text-red-500">{errors.guests.message}</p>
              )}
            </div>
          </div>

          {/* Price Summary */}
          <div className="bg-gray-50 p-4 rounded-lg">
            <h4 className="font-medium mb-2">Ringkasan Harga</h4>
            <div className="space-y-1 text-sm">
              <div className="flex justify-between">
                <span>Harga per jam:</span>
                <span>Rp {basePrice.toLocaleString()}</span>
              </div>
              <div className="flex justify-between">
                <span>Durasi:</span>
                <span>{duration} jam</span>
              </div>
              <div className="flex justify-between">
                <span>Jumlah tamu:</span>
                <span>{guests} orang</span>
              </div>
              <div className="flex justify-between font-medium border-t pt-1">
                <span>Total:</span>
                <span>Rp {totalPrice.toLocaleString()}</span>
              </div>
            </div>
          </div>

          {error && <p className="text-sm text-red-500">{error}</p>}

          <Button type="submit" className="w-full" disabled={isLoading}>
            {isLoading ? "Memproses..." : "Buat Booking"}
          </Button>
        </form>
      </CardContent>
    </Card>
  );
}
```

## 🛠️ Development Commands

### Guest Development

```bash
# Start development server
npm run dev

# Test guest components
npm run test -- --testPathPattern=guest

# Test guest functionality
npm run test -- --testPathPattern=guest-booking
```

### Guest Testing

```bash
# Test guest functionality
npm run test src/components/guest

# Test guest hooks
npm run test src/hooks/useGuest

# Test guest services
npm run test src/services/guest
```

## 🎨 UI Implementation

### Guest Styling

```bash
# Create guest styles
mkdir -p src/styles/guest
touch src/styles/guest/guestDashboard.css
touch src/styles/guest/guestBooking.css
```

**Style Features:**

- Guest dashboard styling
- Guest booking form styling
- Guest navigation styling
- Guest conversion styling

### Guest Layout

```bash
# Create guest layout
touch src/components/guest/GuestLayout.tsx
touch src/components/guest/GuestHeader.tsx
```

**Layout Features:**

- Guest page layout
- Guest header navigation
- Guest content area
- Responsive design

## 🔧 Integration Points

### API Integration

```bash
# Create guest API service
touch src/services/api/guestApi.ts
touch src/services/api/guestBookingApi.ts
```

**API Features:**

- Guest API integration
- Guest booking API
- Guest conversion API
- Guest session API

### State Management

```bash
# Create guest state management
touch src/store/guest/guestStore.ts
touch src/store/guest/guestActions.ts
```

**State Features:**

- Guest state management
- Guest booking state
- Guest session state
- Guest conversion state

## 🧪 Testing Strategy

### Unit Tests

```bash
# Test guest components
mkdir -p src/components/guest/__tests__
touch src/components/guest/__tests__/GuestDashboard.test.tsx
touch src/components/guest/__tests__/GuestBookingForm.test.tsx
```

**Test Coverage:**

- Guest dashboard rendering
- Guest booking form
- Guest navigation
- Guest conversion

### Integration Tests

```bash
# Test guest integration
mkdir -p src/__tests__/integration
touch src/__tests__/integration/guest.test.tsx
```

**Integration Tests:**

- Complete guest workflow
- Guest booking flow
- Guest conversion flow
- Guest session management

## 📱 Mobile Considerations

### Mobile Guest

```bash
# Mobile guest components
touch src/components/guest/mobile/MobileGuestDashboard.tsx
touch src/components/guest/mobile/MobileGuestBooking.tsx
```

**Mobile Features:**

- Mobile-optimized guest interface
- Mobile guest booking
- Touch-friendly interface
- Mobile navigation

### Performance Optimization

```bash
# Guest performance optimization
touch src/hooks/useGuestPerformance.ts
```

**Optimizations:**

- Guest interface optimization
- Guest booking optimization
- Guest session optimization
- API call optimization

## 🔒 Security Considerations

### Guest Security

```bash
# Guest security utilities
touch src/utils/guestSecurity.ts
touch src/utils/guestDataValidation.ts
```

**Security Features:**

- Guest data validation
- Guest session security
- Guest booking security
- Data protection

### Data Protection

```bash
# Data protection utilities
touch src/utils/guestDataProtection.ts
touch src/utils/guestPrivacy.ts
```

**Protection Features:**

- Guest data protection
- Guest privacy protection
- Data anonymization
- Privacy compliance

## 📊 Analytics & Monitoring

### Guest Analytics

```bash
# Guest analytics
touch src/utils/guestAnalytics.ts
touch src/hooks/useGuestAnalytics.ts
```

**Analytics Features:**

- Guest usage tracking
- Guest booking analytics
- Guest conversion analytics
- User behavior tracking

### Error Monitoring

```bash
# Error monitoring untuk guest
touch src/utils/guestErrorMonitoring.ts
touch src/hooks/useGuestErrorMonitoring.ts
```

**Monitoring Features:**

- Guest error tracking
- Guest booking error monitoring
- Guest conversion error monitoring
- System alerts

## ✅ Success Criteria

- [ ] Guest user interface implementation berfungsi
- [ ] Limited access management implemented
- [ ] Basic booking functionality berfungsi
- [ ] Guest-to-member conversion implemented
- [ ] Guest session management berfungsi
- [ ] Guest data collection berfungsi
- [ ] Guest components dengan proper validation
- [ ] Guest hooks dengan error handling
- [ ] Guest API integration
- [ ] Unit tests untuk guest components
- [ ] Integration tests untuk guest workflow
- [ ] Security measures untuk guest data
- [ ] Data protection untuk guest information
- [ ] Analytics tracking untuk guest usage
- [ ] Error monitoring dan alerting
- [ ] Performance optimization untuk guest interface
- [ ] Mobile-responsive guest interface
- [ ] Accessibility features maintained
- [ ] Guest system health monitoring
- [ ] Guest system documentation dan user guides

## 📝 Notes

- Pastikan guest interface user-friendly dan mudah digunakan
- Implementasi proper validation untuk guest data
- Setup proper error handling untuk guest operations
- Test guest system dengan various scenarios
- Consider implementing guest backup strategies
- Implementasi guest system reporting features
- Consider adding guest notifications
- Implementasi guest system health monitoring
- Add guest system documentation dan training materials
