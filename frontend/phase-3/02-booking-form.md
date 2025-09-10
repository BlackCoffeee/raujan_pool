# Booking Form Implementation

## 📋 Overview

Implementasi booking form dengan validation, pool selection, time slot picker, dan guest information collection untuk sistem booking pool.

## 🎯 Objectives

- Create booking form dengan comprehensive validation
- Pool selection interface dengan capacity display
- Time slot picker integration
- Guest information collection
- Special requirements handling
- Form state management
- Error handling dan user feedback

## 🔧 Implementation Steps

### Step 1: Setup Booking Form Store

```bash
# Create booking form store
touch src/stores/bookingFormStore.ts
```

**Store Structure:**

- Form data state
- Validation errors
- Loading states
- Pool selection state
- Time slot selection
- Guest information

### Step 2: Create Form Components

```bash
# Create booking form components
mkdir -p src/components/booking/forms
touch src/components/booking/forms/BookingForm.tsx
touch src/components/booking/forms/PoolSelector.tsx
touch src/components/booking/forms/TimeSlotPicker.tsx
touch src/components/booking/forms/GuestInformation.tsx
touch src/components/booking/forms/SpecialRequirements.tsx
```

**Component Structure:**

- `BookingForm` - Main form wrapper
- `PoolSelector` - Pool selection component
- `TimeSlotPicker` - Time slot selection
- `GuestInformation` - Guest details form
- `SpecialRequirements` - Additional requirements

### Step 3: Setup Form Validation

```bash
# Create validation schemas
mkdir -p src/schemas
touch src/schemas/bookingSchema.ts
```

**Validation Rules:**

- Required field validation
- Date/time validation
- Guest count validation
- Pool capacity validation
- Special requirements validation

### Step 4: Create Form Steps

```bash
# Create multi-step form components
mkdir -p src/components/booking/steps
touch src/components/booking/steps/Step1PoolSelection.tsx
touch src/components/booking/steps/Step2DateTime.tsx
touch src/components/booking/steps/Step3GuestInfo.tsx
touch src/components/booking/steps/Step4Confirmation.tsx
```

**Form Steps:**

- Step 1: Pool selection
- Step 2: Date dan time selection
- Step 3: Guest information
- Step 4: Confirmation dan payment

### Step 5: Implement Form State Management

```bash
# Create form state hooks
mkdir -p src/hooks/booking
touch src/hooks/booking/useBookingForm.ts
touch src/hooks/booking/useFormValidation.ts
touch src/hooks/booking/useFormNavigation.ts
```

**Hook Features:**

- Form state management
- Validation handling
- Step navigation
- Auto-save functionality

## 📊 Configuration Files

### src/types/bookingForm.ts

```typescript
// Booking form types
export interface BookingFormData {
  poolId: string;
  date: string;
  timeSlot: string;
  duration: number;
  guestCount: number;
  guestInfo: {
    name: string;
    email: string;
    phone: string;
  };
  specialRequirements?: string;
  recurring?: boolean;
  recurringPattern?: string;
}

export interface FormStep {
  id: string;
  title: string;
  component: React.ComponentType;
  validation: boolean;
  completed: boolean;
}
```

### src/config/bookingForm.ts

```typescript
// Booking form configuration
export const BOOKING_FORM_CONFIG = {
  steps: [
    { id: "pool", title: "Select Pool", validation: true },
    { id: "datetime", title: "Date & Time", validation: true },
    { id: "guests", title: "Guest Info", validation: true },
    { id: "confirm", title: "Confirmation", validation: false },
  ],
  maxGuests: 20,
  minDuration: 1,
  maxDuration: 8,
  advanceBookingDays: 30,
};
```

### src/utils/formHelpers.ts

```typescript
// Form utility functions
export const validateBookingForm = (data: BookingFormData) => {
  // Form validation logic
};

export const calculateBookingPrice = (
  poolId: string,
  duration: number,
  guestCount: number
) => {
  // Price calculation
};

export const formatBookingSummary = (data: BookingFormData) => {
  // Format booking summary
};
```

## 🛠️ Development Commands

### Form Development

```bash
# Start development dengan form focus
npm run dev

# Test form components
npm run test -- --testPathPattern=booking-form

# Test form validation
npm run test -- --testPathPattern=validation
```

### Form Testing

```bash
# Test form functionality
npm run test src/components/booking/forms

# Test form validation
npm run test src/schemas/bookingSchema

# Test form store
npm run test src/stores/bookingFormStore
```

## 🎨 UI Implementation

### Form Styling

```bash
# Create form styles
mkdir -p src/styles/booking
touch src/styles/booking/bookingForm.css
touch src/styles/booking/formSteps.css
```

**Style Features:**

- Multi-step form design
- Progress indicator
- Form validation styling
- Responsive form layout
- Loading states

### Form Components

```bash
# Create reusable form components
mkdir -p src/components/ui/forms
touch src/components/ui/forms/FormStep.tsx
touch src/components/ui/forms/ProgressIndicator.tsx
touch src/components/ui/forms/FormNavigation.tsx
```

**Reusable Components:**

- Step wrapper component
- Progress indicator
- Form navigation buttons
- Error display component

## 🔧 Integration Points

### API Integration

```bash
# Create booking API service
touch src/services/bookingApi.ts
```

**API Endpoints:**

- `GET /api/pools` - Get available pools
- `GET /api/availability` - Check time slot availability
- `POST /api/bookings` - Create new booking
- `PUT /api/bookings/:id` - Update booking
- `DELETE /api/bookings/:id` - Cancel booking

### Real-time Integration

```bash
# Setup real-time form updates
touch src/hooks/useBookingRealTime.ts
```

**Real-time Features:**

- Live availability updates
- Price calculation updates
- Form auto-save
- Conflict detection

## 🧪 Testing Strategy

### Unit Tests

```bash
# Test form components
mkdir -p src/components/booking/forms/__tests__
touch src/components/booking/forms/__tests__/BookingForm.test.tsx
touch src/components/booking/forms/__tests__/PoolSelector.test.tsx
```

**Test Coverage:**

- Form rendering
- Validation logic
- Step navigation
- State management
- Error handling

### Integration Tests

```bash
# Test form integration
mkdir -p src/__tests__/integration
touch src/__tests__/integration/booking-form.test.tsx
```

**Integration Tests:**

- Complete booking flow
- API integration
- Real-time updates
- Form persistence

## 📱 Mobile Considerations

### Mobile Form Optimization

```bash
# Mobile form components
touch src/components/booking/mobile/MobileBookingForm.tsx
touch src/components/booking/mobile/MobileStepNavigation.tsx
```

**Mobile Features:**

- Touch-friendly inputs
- Mobile-optimized date picker
- Swipe navigation
- Mobile keyboard handling

### Performance Optimization

```bash
# Form performance optimization
touch src/hooks/useFormPerformance.ts
```

**Optimizations:**

- Lazy loading form steps
- Debounced validation
- Memoized components
- Optimistic updates

## 🔒 Security Considerations

### Form Security

```bash
# Form security utilities
touch src/utils/formSecurity.ts
```

**Security Features:**

- Input sanitization
- XSS prevention
- CSRF protection
- Rate limiting

### Data Validation

```bash
# Server-side validation
touch src/utils/serverValidation.ts
```

**Validation Features:**

- Client-side validation
- Server-side validation
- Data type checking
- Business rule validation

## ✅ Success Criteria

- [ ] Booking form renders dengan multi-step interface
- [ ] Pool selection component dengan capacity display
- [ ] Time slot picker terintegrasi dengan calendar
- [ ] Guest information form dengan validation
- [ ] Special requirements handling implemented
- [ ] Form state management dengan Zustand
- [ ] Form validation dengan Zod schemas
- [ ] Step navigation dengan progress indicator
- [ ] Auto-save functionality untuk form data
- [ ] Real-time availability checking
- [ ] Price calculation integration
- [ ] Form error handling dan user feedback
- [ ] Mobile-responsive form design
- [ ] Form accessibility features (ARIA labels, keyboard navigation)
- [ ] Unit tests untuk form components
- [ ] Integration tests untuk booking flow
- [ ] Form security measures implemented
- [ ] Performance optimization untuk large forms
- [ ] Form analytics tracking
- [ ] Form data persistence dan recovery

## 📝 Notes

- Pastikan form validation consistent antara client dan server
- Implementasi proper error boundaries untuk form components
- Consider implementing form analytics untuk user behavior
- Test form performance dengan complex validation rules
- Implementasi form accessibility sesuai WCAG guidelines
- Consider adding form auto-complete features
- Implementasi form data encryption untuk sensitive information
- Add form help text dan tooltips untuk better UX
