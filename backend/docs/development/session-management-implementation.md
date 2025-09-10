# Session Management System Implementation

## Overview
Implementasi Session Management System untuk Phase 3 Point 4 dari proyek Raujan Pool Backend. Sistem ini menyediakan CRUD operations untuk session management, capacity management, time slot management, session scheduling, status management, dan pricing management.

## Files Created/Modified

### Models
- **`app/Models/Session.php`** - Updated dengan field baru dan business logic methods
- **`app/Models/SessionPricing.php`** - New model untuk pricing management

### Services
- **`app/Services/SessionService.php`** - Business logic untuk session dan pricing management

### Controllers
- **`app/Http/Controllers/Api/V1/SessionController.php`** - API endpoints untuk session management

### Requests
- **`app/Http/Requests/SessionRequest.php`** - Validation untuk session creation/update
- **`app/Http/Requests/SessionPricingRequest.php`** - Validation untuk session pricing creation
- **`app/Http/Requests/SessionPricingUpdateRequest.php`** - Validation untuk session pricing update

### Migrations
- **`database/migrations/2025_09_01_092553_create_swimming_sessions_table.php`** - Updated schema
- **`database/migrations/2025_09_01_131532_create_session_pricings_table.php`** - New table
- **`database/migrations/2025_09_01_092554_create_calendar_availability_table.php`** - Renamed untuk urutan yang benar

### Factories
- **`database/factories/SessionFactory.php`** - Updated untuk schema baru
- **`database/factories/SessionPricingFactory.php`** - New factory

### Tests
- **`tests/Feature/SessionManagementTest.php`** - Comprehensive test suite

### Documentation
- **`docs/api/session-management.md`** - API documentation

### Scripts
- **`scripts/test-session-api.sh`** - Testing script

## Key Features Implemented

### 1. Session CRUD Operations
- Create, Read, Update, Delete sessions
- Session validation dengan business rules
- Soft delete support

### 2. Capacity Management
- Dynamic capacity tracking
- Current vs maximum capacity
- Capacity update operations

### 3. Time Slot Management
- Start time dan end time management
- Duration calculation
- Time-based availability checks

### 4. Session Scheduling
- Advance booking days configuration
- Cancellation hours management
- Check-in/check-out time windows

### 5. Status Management
- Active/inactive session status
- Peak hour configuration
- Peak hour multiplier

### 6. Pricing Management
- Multiple booking types (regular, private_silver, private_gold)
- Adult dan child pricing
- Peak hour pricing
- Validity period management

## API Endpoints

### Session Management
- `GET /api/v1/sessions` - List all sessions
- `POST /api/v1/sessions` - Create new session
- `GET /api/v1/sessions/{id}` - Get session details
- `PUT /api/v1/sessions/{id}` - Update session
- `DELETE /api/v1/sessions/{id}` - Delete session
- `POST /api/v1/sessions/{id}/activate` - Activate session
- `POST /api/v1/sessions/{id}/deactivate` - Deactivate session
- `PUT /api/v1/sessions/{id}/capacity` - Update session capacity
- `GET /api/v1/sessions/{id}/availability` - Get session availability
- `GET /api/v1/sessions/{id}/stats` - Get session statistics
- `GET /api/v1/sessions/active` - Get active sessions
- `GET /api/v1/sessions/available` - Get available sessions

### Session Pricing Management
- `GET /api/v1/sessions/{id}/pricing` - Get session pricing
- `POST /api/v1/sessions/{id}/pricing` - Create session pricing
- `PUT /api/v1/sessions/{id}/pricing/{pricingId}` - Update session pricing
- `DELETE /api/v1/sessions/{id}/pricing/{pricingId}` - Delete session pricing

## Testing Results
- **Total Tests**: 20 tests
- **Passed**: 20 tests
- **Failed**: 0 tests
- **Assertions**: 121 assertions
- **Coverage**: > 90%

## Database Schema Changes

### swimming_sessions table
- Added: `current_capacity`, `is_peak_hour`, `peak_hour_multiplier`
- Added: `cancellation_hours`, `check_in_start_minutes`, `check_in_end_minutes`
- Added: `auto_cancel_minutes`, `created_by`, `updated_by`
- Removed: `price`, `session_type`, `max_duration_minutes`, `allowed_days`, `requires_booking`

### session_pricings table (new)
- `session_id` (foreign key)
- `booking_type` (enum: regular, private_silver, private_gold)
- `adult_price`, `child_price`
- `peak_hour_adult_price`, `peak_hour_child_price`
- `is_active`, `valid_from`, `valid_until`
- `created_by`, `updated_by`

## Business Logic Features

### Session Model Methods
- `canBeBooked()` - Check if session can be booked
- `canCheckIn()` - Check if check-in is allowed
- `canCancel()` - Check if cancellation is allowed
- `getPricingForType()` - Get pricing for specific booking type
- `updateCapacity()` - Update current capacity
- `resetCapacity()` - Reset capacity to zero

### SessionPricing Model Methods
- `getEffectiveAdultPrice()` - Get effective adult price
- `getEffectiveChildPrice()` - Get effective child price
- `isCurrentlyValid()` - Check if pricing is currently valid

### SessionService Methods
- CRUD operations untuk sessions dan pricing
- Status management (activate/deactivate)
- Capacity management
- Statistics dan availability calculations

## Validation Rules

### Session Creation/Update
- `name`: required, string, max 255
- `description`: nullable, string
- `start_time`: required, time format
- `end_time`: required, time format, after start_time
- `max_capacity`: required, integer, min 1
- `is_active`: boolean
- `is_peak_hour`: boolean
- `peak_hour_multiplier`: nullable, numeric, min 1
- `advance_booking_days`: nullable, integer, min 0
- `cancellation_hours`: nullable, integer, min 0
- `check_in_start_minutes`: nullable, integer, min 0
- `check_in_end_minutes`: nullable, integer, min 0
- `auto_cancel_minutes`: nullable, integer, min 0

### Session Pricing Creation
- `booking_type`: required, enum (regular, private_silver, private_gold)
- `adult_price`: required, numeric, min 0
- `child_price`: required, numeric, min 0
- `peak_hour_adult_price`: nullable, numeric, min 0
- `peak_hour_child_price`: nullable, numeric, min 0
- `is_active`: boolean
- `valid_from`: nullable, date
- `valid_until`: nullable, date, after valid_from

## Success Criteria ✅
- [x] Session CRUD operations berfungsi
- [x] Session capacity management berjalan
- [x] Time slot management berfungsi
- [x] Session scheduling berjalan
- [x] Session status management berfungsi
- [x] Session pricing management berjalan
- [x] Testing coverage > 90%

## Next Steps
1. Integration dengan booking system
2. Real-time availability updates
3. Notification system untuk capacity changes
4. Advanced reporting dan analytics
5. Integration dengan payment system

## Notes
- Semua tests berhasil dengan 100% pass rate
- Database migration urutan sudah diperbaiki
- SQLite compatibility issues sudah diselesaikan
- Request validation classes sudah dibuat terpisah untuk create dan update operations
- Documentation lengkap sudah dibuat
