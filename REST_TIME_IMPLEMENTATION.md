# Rest Time & Clock-In Button Implementation

## Overview
This document describes the implementation of the rest time feature and the conditional clock-in button logic in the driver dashboard.

## Features Implemented

### 1. Rest Time Management

#### Backend Integration
- **API Endpoints Added:**
  - `POST rest/start` - Start a rest break (with optional notes)
  - `POST rest/end` - End rest break and return to work

#### Data Model Updates
- **ClockStatus Model** (`lib/app/data/models/dashboard_model.dart`):
  - Added `hasActiveRest` boolean field to track if driver is currently on rest
  - Field is parsed from API response key `has_active_rest`

#### Service Layer
- **DriverService** (`lib/app/data/services/driver_service.dart`):
  - `startRest({required int clockInId, String? notes})` - Starts rest time with optional notes
  - `endRest({required int clockInId})` - Ends rest time

#### Controller Logic
- **DriverDashboardController** (`lib/app/modules/driver/dashboard/driver_dashboard_controller.dart`):
  - `hasActiveRest` getter - Quick access to rest status
  - `startRest(String? notes)` - Handles rest start with loading, error handling, and dashboard refresh
  - `endRest()` - Handles rest end with confirmation and refresh
  - Special error handling for "already have an active rest time" scenario

### 2. UI Implementation

#### Rest Button in Driver Info Card
Located in `_DriverInfoCard` widget:

**Visibility:**
- Shows ONLY when user is clocked in (`isCurrentlyClockedIn == true`)
- Shows ONLY when there's no urgent clock-out pending (`!hasOldPendingClockOut`)

**Dynamic Behavior:**
- **When NOT on rest** (`hasActiveRest == false`):
  - Button label: "Take a Rest"
  - Button color: Orange
  - Icon: Coffee cup
  - Action: Opens dialog for optional notes input

- **When ON rest** (`hasActiveRest == true`):
  - Button label: "Back to Work"
  - Button color: Green
  - Icon: Work briefcase
  - Action: Shows confirmation dialog, then calls end rest API

#### Rest Notes Dialog
- Title: "Take a Rest" with coffee icon
- Contains optional TextField for notes (max 200 characters)
- Placeholder: "e.g., Lunch break, Rest stop..."
- Actions:
  - Cancel: Dismisses dialog
  - Start Rest: Submits API call with notes (if provided)

#### Back to Work Confirmation
- Simple confirmation dialog
- Asks: "Are you ready to end your rest time and get back to work?"
- Actions:
  - Cancel: Returns to dashboard
  - Yes, Back to Work: Calls end rest API

### 3. Conditional Clock-In Button

#### Logic (Already Implemented)
The Clock-In button visibility is controlled by `shouldShowClockInButton` in `DashboardData` model:

```dart
bool get shouldShowClockInButton => !isCurrentlyClockedIn && canClockInToday;
```

**This means the button shows when:**
1. User is NOT currently clocked in (`!isCurrentlyClockedIn`)
2. AND user CAN clock in today (`canClockInToday == true`)

**After clock out:**
- If API returns `can_clock_in_today: false`, the Clock In button will NOT show
- If API returns `can_clock_in_today: true`, the Clock In button WILL show (user can clock in again today)

## API Response Handling

### Dashboard API Response Structure
```json
{
  "user_data": {
    "clockin_id": 18,
    "user_id": 4,
    ...
  },
  "clock_status": {
    "is_currently_clocked_in": true,
    "has_active_rest": false,
    "can_clock_in_today": true,
    "show_reminder": false,
    ...
  }
}
```

### Start Rest API
**Request:**
```
POST rest/start
{
  "clock_in_id": 18,
  "notes": "Lunch break" // optional
}
```

**Success Response (200 OK):**
```json
{
  "status": true,
  "message": "Rest time started successfully"
}
```

**Error Response (400 Bad Request):**
```json
{
  "message": "You already have an active rest time"
}
```

### End Rest API
**Request:**
```
POST rest/end
{
  "clock_in_id": 18
}
```

**Success Response (200 OK):**
```json
{
  "status": true,
  "message": "Rest time ended successfully",
  "rest_time": {
    "id": 2,
    "clock_in_id": 18,
    "user_id": 4,
    "rest_start": "2025-11-11T04:12:24.000000Z",
    "rest_end": "2025-11-11T04:21:51.000000Z",
    "duration_minutes": 9,
    "notes": "test",
    ...
  }
}
```

## User Flow

### Rest Time Flow
1. **Driver is clocked in** → Dashboard shows "Take a Rest" button (orange)
2. **Driver taps "Take a Rest"** → Dialog opens with optional notes field
3. **Driver enters notes (optional) and taps "Start Rest"** → API call made
4. **Success** → Dashboard refreshes, button changes to "Back to Work" (green)
5. **Driver taps "Back to Work"** → Confirmation dialog shown
6. **Driver confirms** → API call made to end rest
7. **Success** → Dashboard refreshes, button changes back to "Take a Rest" (orange)

### Clock-In After Clock-Out Flow
1. **Driver clocks out** → Dashboard refreshes with API response
2. **If `can_clock_in_today: true`**:
   - Clock In button is visible
   - Driver can clock in again today
3. **If `can_clock_in_today: false`**:
   - Clock In button is hidden
   - Message: "Already Clocked Out Today"
   - Driver cannot clock in again until tomorrow

## Error Handling

### Rest API Errors
- **Network errors**: Shown with red snackbar
- **"Already have active rest"**: Shown with orange snackbar and info icon
- **Other API errors**: Shown with red snackbar with specific error message
- **Loading state**: Circular progress indicator dialog (non-dismissible)

### Dashboard Refresh
- After successful rest start/end, dashboard automatically refreshes
- Gets latest `has_active_rest` status from API
- UI updates button label and color based on new status

## Files Modified

1. **lib/app/data/models/dashboard_model.dart**
   - Added `hasActiveRest` field to `ClockStatus`
   - Updated `fromJson` and `toJson` methods

2. **lib/app/core/values/api_constants.dart**
   - Added `restStart` and `restEnd` endpoint constants

3. **lib/app/data/services/driver_service.dart**
   - Added `startRest()` and `endRest()` methods

4. **lib/app/modules/driver/dashboard/driver_dashboard_controller.dart**
   - Added `hasActiveRest` getter
   - Added `startRest()` and `endRest()` methods with error handling

5. **lib/app/modules/driver/dashboard/driver_dashboard_page.dart**
   - Added Rest/Back to Work button in `_DriverInfoCard`
   - Added `_showRestDialog()` method for notes input
   - Added confirmation dialog for ending rest

## Testing Checklist

### Rest Time Feature
- [ ] Start rest without notes
- [ ] Start rest with notes
- [ ] End rest time
- [ ] Try to start rest when already on rest (should show error)
- [ ] Dashboard refreshes after rest start
- [ ] Dashboard refreshes after rest end
- [ ] Button changes from "Take a Rest" to "Back to Work" correctly
- [ ] Button colors change (orange → green)

### Clock-In Button Logic
- [ ] Clock In button shows when `can_clock_in_today` is true after clock out
- [ ] Clock In button hides when `can_clock_in_today` is false after clock out
- [ ] Clock In button is disabled with proper message when cannot clock in

### Error Scenarios
- [ ] Network error handling
- [ ] "Already have active rest" error displays correctly
- [ ] Loading indicator shows during API calls
- [ ] Success messages display correctly

## Notes
- Rest button only appears when user is actively clocked in
- Rest feature is independent of vehicle inspection/checklist submissions
- Rest time tracking happens on the backend; duration is calculated server-side
- The `can_clock_in_today` flag is fully controlled by the backend API
