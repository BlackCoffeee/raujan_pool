# User Profile UI Implementation

## 📋 Overview

Implementasi user profile management interface dengan profile information, avatar upload, password change, dan emergency contact management untuk Raujan Pool Syariah frontend.

## 🎯 Objectives

- User profile information management
- Avatar upload dan management
- Password change functionality
- Emergency contact management
- Profile validation dan error handling
- Profile synchronization

## 🔧 Implementation Steps

### Step 1: Create Profile Components

```bash
# Create profile components
mkdir -p src/components/profile
touch src/components/profile/ProfileForm.tsx
touch src/components/profile/AvatarUpload.tsx
touch src/components/profile/PasswordChangeForm.tsx
touch src/components/profile/EmergencyContactForm.tsx
```

**Component Structure:**

- `ProfileForm` - Main profile form
- `AvatarUpload` - Avatar upload component
- `PasswordChangeForm` - Password change form
- `EmergencyContactForm` - Emergency contact form

### Step 2: Setup Profile Validation

```bash
# Create profile validation schemas
mkdir -p src/schemas/profile
touch src/schemas/profileSchemas.ts
touch src/schemas/profileValidation.ts
```

**Validation Features:**

- Profile validation schemas
- Avatar validation
- Password validation
- Emergency contact validation

### Step 3: Create Profile Pages

```bash
# Create profile pages
mkdir -p src/pages/profile
touch src/pages/profile/ProfilePage.tsx
touch src/pages/profile/EditProfilePage.tsx
touch src/pages/profile/ChangePasswordPage.tsx
touch src/pages/profile/EmergencyContactPage.tsx
```

**Page Structure:**

- `ProfilePage` - Main profile page
- `EditProfilePage` - Edit profile page
- `ChangePasswordPage` - Change password page
- `EmergencyContactPage` - Emergency contact page

### Step 4: Setup Profile Hooks

```bash
# Create profile hooks
touch src/hooks/useProfile.ts
touch src/hooks/useAvatarUpload.ts
touch src/hooks/usePasswordChange.ts
touch src/hooks/useEmergencyContact.ts
```

**Hook Features:**

- Profile management hook
- Avatar upload hook
- Password change hook
- Emergency contact hook

### Step 5: Create Profile Services

```bash
# Create profile services
mkdir -p src/services/profile
touch src/services/profile/profileService.ts
touch src/services/profile/avatarService.ts
touch src/services/profile/passwordService.ts
```

**Service Features:**

- Profile API service
- Avatar upload service
- Password change service
- Profile synchronization

## 📊 Configuration Files

### src/schemas/profileSchemas.ts

```typescript
// Profile validation schemas
import { z } from "zod";

export const profileSchema = z.object({
  name: z.string().min(2, "Nama minimal 2 karakter"),
  email: z.string().email("Email tidak valid"),
  phone: z.string().optional(),
  dateOfBirth: z.string().optional(),
  gender: z.enum(["male", "female"]).optional(),
  address: z.string().optional(),
  city: z.string().optional(),
  postalCode: z.string().optional(),
  emergencyContact: z
    .object({
      name: z.string().min(2, "Nama kontak darurat minimal 2 karakter"),
      phone: z.string().min(10, "Nomor telepon minimal 10 digit"),
      relationship: z.string().min(2, "Hubungan minimal 2 karakter"),
    })
    .optional(),
});

export const passwordChangeSchema = z
  .object({
    currentPassword: z.string().min(1, "Password saat ini diperlukan"),
    newPassword: z.string().min(6, "Password baru minimal 6 karakter"),
    confirmPassword: z.string().min(1, "Konfirmasi password diperlukan"),
  })
  .refine((data) => data.newPassword === data.confirmPassword, {
    message: "Password baru tidak cocok",
    path: ["confirmPassword"],
  });

export const avatarUploadSchema = z.object({
  file: z.instanceof(File, "File diperlukan"),
  maxSize: z.number().default(5 * 1024 * 1024), // 5MB
  allowedTypes: z
    .array(z.string())
    .default(["image/jpeg", "image/png", "image/webp"]),
});

export type ProfileFormData = z.infer<typeof profileSchema>;
export type PasswordChangeFormData = z.infer<typeof passwordChangeSchema>;
export type AvatarUploadFormData = z.infer<typeof avatarUploadSchema>;
```

### src/hooks/useProfile.ts

```typescript
// Profile management hook
import { useState, useEffect } from "react";
import { useAuth } from "@/hooks/useAuth";
import { profileService } from "@/services/profile/profileService";
import { ProfileFormData } from "@/schemas/profileSchemas";

export function useProfile() {
  const { user, updateProfile } = useAuth();
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const updateUserProfile = async (data: ProfileFormData) => {
    setIsLoading(true);
    setError(null);
    try {
      const updatedProfile = await profileService.updateProfile(data);
      await updateProfile(updatedProfile);
      return { success: true };
    } catch (err) {
      setError(err.message);
      return { success: false, error: err.message };
    } finally {
      setIsLoading(false);
    }
  };

  const uploadAvatar = async (file: File) => {
    setIsLoading(true);
    setError(null);
    try {
      const avatarUrl = await profileService.uploadAvatar(file);
      await updateProfile({ avatar: avatarUrl });
      return { success: true, avatarUrl };
    } catch (err) {
      setError(err.message);
      return { success: false, error: err.message };
    } finally {
      setIsLoading(false);
    }
  };

  const changePassword = async (data: PasswordChangeFormData) => {
    setIsLoading(true);
    setError(null);
    try {
      await profileService.changePassword(data);
      return { success: true };
    } catch (err) {
      setError(err.message);
      return { success: false, error: err.message };
    } finally {
      setIsLoading(false);
    }
  };

  return {
    user,
    isLoading,
    error,
    updateUserProfile,
    uploadAvatar,
    changePassword,
    clearError: () => setError(null),
  };
}
```

### src/components/profile/ProfileForm.tsx

```typescript
// Profile form component
import { useForm } from "react-hook-form";
import { zodResolver } from "@hookform/resolvers/zod";
import { profileSchema, ProfileFormData } from "@/schemas/profileSchemas";
import { useProfile } from "@/hooks/useProfile";
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

export function ProfileForm() {
  const { user, updateUserProfile, isLoading, error, clearError } =
    useProfile();

  const {
    register,
    handleSubmit,
    formState: { errors },
    reset,
  } = useForm<ProfileFormData>({
    resolver: zodResolver(profileSchema),
    defaultValues: {
      name: user?.name || "",
      email: user?.email || "",
      phone: user?.phone || "",
      dateOfBirth: user?.dateOfBirth || "",
      gender: user?.gender || undefined,
      address: user?.address || "",
      city: user?.city || "",
      postalCode: user?.postalCode || "",
    },
  });

  const onSubmit = async (data: ProfileFormData) => {
    clearError();
    const result = await updateUserProfile(data);
    if (result.success) {
      // Show success message
    }
  };

  return (
    <Card className="w-full max-w-2xl">
      <CardHeader>
        <CardTitle>Profile Information</CardTitle>
      </CardHeader>
      <CardContent>
        <form onSubmit={handleSubmit(onSubmit)} className="space-y-6">
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
              <Label htmlFor="dateOfBirth">Tanggal Lahir</Label>
              <Input
                id="dateOfBirth"
                type="date"
                {...register("dateOfBirth")}
              />
              {errors.dateOfBirth && (
                <p className="text-sm text-red-500">
                  {errors.dateOfBirth.message}
                </p>
              )}
            </div>

            <div className="space-y-2">
              <Label htmlFor="gender">Jenis Kelamin</Label>
              <Select {...register("gender")}>
                <SelectTrigger>
                  <SelectValue placeholder="Pilih jenis kelamin" />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="male">Laki-laki</SelectItem>
                  <SelectItem value="female">Perempuan</SelectItem>
                </SelectContent>
              </Select>
              {errors.gender && (
                <p className="text-sm text-red-500">{errors.gender.message}</p>
              )}
            </div>

            <div className="space-y-2">
              <Label htmlFor="city">Kota</Label>
              <Input
                id="city"
                placeholder="Masukkan kota"
                {...register("city")}
              />
              {errors.city && (
                <p className="text-sm text-red-500">{errors.city.message}</p>
              )}
            </div>
          </div>

          <div className="space-y-2">
            <Label htmlFor="address">Alamat</Label>
            <Input
              id="address"
              placeholder="Masukkan alamat lengkap"
              {...register("address")}
            />
            {errors.address && (
              <p className="text-sm text-red-500">{errors.address.message}</p>
            )}
          </div>

          <div className="space-y-2">
            <Label htmlFor="postalCode">Kode Pos</Label>
            <Input
              id="postalCode"
              placeholder="Masukkan kode pos"
              {...register("postalCode")}
            />
            {errors.postalCode && (
              <p className="text-sm text-red-500">
                {errors.postalCode.message}
              </p>
            )}
          </div>

          {error && <p className="text-sm text-red-500">{error}</p>}

          <div className="flex gap-4">
            <Button type="submit" disabled={isLoading}>
              {isLoading ? "Menyimpan..." : "Simpan Perubahan"}
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

### src/components/profile/AvatarUpload.tsx

```typescript
// Avatar upload component
import { useState, useRef } from "react";
import { useProfile } from "@/hooks/useProfile";
import { Button } from "@/components/ui/button";
import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar";
import { Upload, X } from "lucide-react";

export function AvatarUpload() {
  const { user, uploadAvatar, isLoading, error } = useProfile();
  const [preview, setPreview] = useState<string | null>(null);
  const fileInputRef = useRef<HTMLInputElement>(null);

  const handleFileSelect = (event: React.ChangeEvent<HTMLInputElement>) => {
    const file = event.target.files?.[0];
    if (file) {
      const reader = new FileReader();
      reader.onload = (e) => {
        setPreview(e.target?.result as string);
      };
      reader.readAsDataURL(file);
    }
  };

  const handleUpload = async () => {
    const file = fileInputRef.current?.files?.[0];
    if (file) {
      const result = await uploadAvatar(file);
      if (result.success) {
        setPreview(null);
        if (fileInputRef.current) {
          fileInputRef.current.value = "";
        }
      }
    }
  };

  const handleCancel = () => {
    setPreview(null);
    if (fileInputRef.current) {
      fileInputRef.current.value = "";
    }
  };

  return (
    <div className="space-y-4">
      <div className="flex items-center space-x-4">
        <Avatar className="h-20 w-20">
          <AvatarImage src={preview || user?.avatar} alt={user?.name} />
          <AvatarFallback>{user?.name?.charAt(0).toUpperCase()}</AvatarFallback>
        </Avatar>
        <div className="space-y-2">
          <input
            ref={fileInputRef}
            type="file"
            accept="image/*"
            onChange={handleFileSelect}
            className="hidden"
          />
          <Button
            type="button"
            variant="outline"
            onClick={() => fileInputRef.current?.click()}
          >
            <Upload className="h-4 w-4 mr-2" />
            Pilih Foto
          </Button>
          <p className="text-sm text-gray-500">
            JPG, PNG, atau WebP. Maksimal 5MB.
          </p>
        </div>
      </div>

      {preview && (
        <div className="space-y-2">
          <div className="flex items-center space-x-2">
            <Button
              type="button"
              onClick={handleUpload}
              disabled={isLoading}
              size="sm"
            >
              {isLoading ? "Mengupload..." : "Upload"}
            </Button>
            <Button
              type="button"
              variant="outline"
              onClick={handleCancel}
              size="sm"
            >
              <X className="h-4 w-4 mr-2" />
              Batal
            </Button>
          </div>
        </div>
      )}

      {error && <p className="text-sm text-red-500">{error}</p>}
    </div>
  );
}
```

## 🛠️ Development Commands

### Profile Development

```bash
# Start development server
npm run dev

# Test profile components
npm run test -- --testPathPattern=profile

# Test profile forms
npm run test -- --testPathPattern=forms
```

### Profile Testing

```bash
# Test profile functionality
npm run test src/components/profile

# Test profile hooks
npm run test src/hooks/useProfile

# Test profile services
npm run test src/services/profile
```

## 🎨 UI Implementation

### Profile Styling

```bash
# Create profile styles
mkdir -p src/styles/profile
touch src/styles/profile/profileForm.css
touch src/styles/profile/avatarUpload.css
```

**Style Features:**

- Profile form styling
- Avatar upload styling
- Validation styling
- Loading state styling

### Profile Layout

```bash
# Create profile layout
touch src/components/profile/ProfileLayout.tsx
touch src/components/profile/ProfileSidebar.tsx
```

**Layout Features:**

- Profile page layout
- Profile sidebar navigation
- Profile content area
- Responsive design

## 🔧 Integration Points

### API Integration

```bash
# Create profile API service
touch src/services/api/profileApi.ts
touch src/services/api/avatarApi.ts
```

**API Features:**

- Profile API integration
- Avatar upload API
- Password change API
- Profile synchronization

### State Management

```bash
# Create profile state management
touch src/store/profile/profileStore.ts
touch src/store/profile/profileActions.ts
```

**State Features:**

- Profile state management
- Avatar state management
- Profile synchronization
- Error state management

## 🧪 Testing Strategy

### Unit Tests

```bash
# Test profile components
mkdir -p src/components/profile/__tests__
touch src/components/profile/__tests__/ProfileForm.test.tsx
touch src/components/profile/__tests__/AvatarUpload.test.tsx
```

**Test Coverage:**

- Profile form rendering
- Profile form validation
- Avatar upload functionality
- Password change functionality

### Integration Tests

```bash
# Test profile integration
mkdir -p src/__tests__/integration
touch src/__tests__/integration/profile.test.tsx
```

**Integration Tests:**

- Complete profile workflow
- API integration
- State management integration
- Profile synchronization

## 📱 Mobile Considerations

### Mobile Profile

```bash
# Mobile profile components
touch src/components/profile/mobile/MobileProfileForm.tsx
touch src/components/profile/mobile/MobileAvatarUpload.tsx
```

**Mobile Features:**

- Mobile-optimized profile forms
- Mobile avatar upload
- Touch-friendly interface
- Mobile validation

### Performance Optimization

```bash
# Profile performance optimization
touch src/hooks/useProfilePerformance.ts
```

**Optimizations:**

- Profile form optimization
- Avatar upload optimization
- Profile caching
- API call optimization

## 🔒 Security Considerations

### Profile Security

```bash
# Profile security utilities
touch src/utils/profileSecurity.ts
touch src/utils/avatarSecurity.ts
```

**Security Features:**

- Profile data validation
- Avatar file validation
- Password security
- Data encryption

### Data Protection

```bash
# Data protection utilities
touch src/utils/profileDataProtection.ts
touch src/utils/avatarDataProtection.ts
```

**Protection Features:**

- Profile data protection
- Avatar data protection
- Sensitive data masking
- Privacy compliance

## 📊 Analytics & Monitoring

### Profile Analytics

```bash
# Profile analytics
touch src/utils/profileAnalytics.ts
touch src/hooks/useProfileAnalytics.ts
```

**Analytics Features:**

- Profile usage tracking
- Avatar upload analytics
- Profile completion analytics
- User behavior tracking

### Error Monitoring

```bash
# Error monitoring untuk profile
touch src/utils/profileErrorMonitoring.ts
touch src/hooks/useProfileErrorMonitoring.ts
```

**Monitoring Features:**

- Profile error tracking
- Avatar upload error monitoring
- API error monitoring
- System alerts

## ✅ Success Criteria

- [ ] User profile information management berfungsi
- [ ] Avatar upload dan management implemented
- [ ] Password change functionality berfungsi
- [ ] Emergency contact management implemented
- [ ] Profile validation dan error handling berfungsi
- [ ] Profile synchronization berfungsi
- [ ] Profile forms dengan proper validation
- [ ] Profile hooks dengan error handling
- [ ] Profile API integration
- [ ] Unit tests untuk profile components
- [ ] Integration tests untuk profile workflow
- [ ] Security measures untuk profile data
- [ ] Data protection untuk sensitive profile information
- [ ] Analytics tracking untuk profile usage
- [ ] Error monitoring dan alerting
- [ ] Performance optimization untuk profile forms
- [ ] Mobile-responsive profile interface
- [ ] Accessibility features maintained
- [ ] Profile system health monitoring
- [ ] Profile system documentation dan user guides

## 📝 Notes

- Pastikan profile data aman dan tidak vulnerable
- Implementasi proper validation untuk semua profile inputs
- Setup proper error handling untuk profile operations
- Test profile system dengan various scenarios
- Consider implementing profile backup strategies
- Implementasi profile system reporting features
- Consider adding profile notifications
- Implementasi profile system health monitoring
- Add profile system documentation dan training materials
