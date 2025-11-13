# 🔄 Undo Clock Out Feature Implementation

## Overview
Implemented the "Undo Clock Out" feature that allows drivers to reverse their recent clock-out action and return to clocked-in status. The feature is controlled by the `can_undo_clockout` flag from the dashboard API.

## 📋 What Was Implemented

### 1. **Dashboard API Model Update**

#### Added `canUndoClockout` to ClockStatus Model
**File:** `lib/app/data/models/dashboard_model.dart`

```dart
class ClockStatus {
  final bool isCurrentlyClockedIn;
  final bool hasOldPendingClockOut;
  final bool canClockInToday;
  final bool showReminder;
  final String? lastClockInTime;
  final String? odometer;
  final bool canUndoClockout;  // ✅ NEW FIELD
  
  // Constructor and methods...
}
```

**API Field Mapping:**
- JSON: `can_undo_clockout` (boolean)
- Model: `canUndoClockout` (boolean)
- Default: `false` if not present

### 2. **API Endpoint Configuration**

#### Added API Constant
**File:** `lib/app/core/values/api_constants.dart`

```dart
class ApiConstants {
  // Driver Endpoints
  static const String undoClockOut = 'undo-clock-out';  // ✅ NEW
}
```

**Endpoint Details:**
- **URL:** `{{APP_URL}}/undo-clock-out`
- **Method:** POST
- **Content-Type:** form-data
- **Required Parameter:** `user_id`

### 3. **Driver Service Method**

#### Added `undoClockOut()` Method
**File:** `lib/app/data/services/driver_service.dart`

```dart
/// Undo Clock Out
Future<Map<String, dynamic>> undoClockOut(int userId) async {
  try {
    final response = await _apiClient.postFormData(
      ApiConstants.undoClockOut,
      data: {'user_id': userId.toString()},
    );

    return {
      'status': response.status,
      'message': response.message,
      'data': response.data,
    };
  } catch (e) {
    rethrow;
  }
}
```

### 4. **Dashboard Controller Logic**

#### Added `undoClockOut()` Method
**File:** `lib/app/modules/driver/dashboard/driver_dashboard_controller.dart`

**Features:**
1. ✅ Shows loading indicator during API call
2. ✅ Validates user ID before calling API
3. ✅ Handles success/error responses
4. ✅ Shows success/error snackbar messages
5. ✅ Refreshes dashboard after successful undo

```dart
Future<void> undoClockOut() async {
  try {
    // Show loading dialog
    Get.dialog(
      const Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );

    final userId = dashboardData.value?.userData.userId;
    if (userId == null) {
      // Handle error
      return;
    }

    // Call API
    final response = await _driverService.undoClockOut(userId);

    Get.back(); // Close loading

    if (response['status'] == true || response['status'] == 1) {
      // Show success message
      Get.snackbar(
        'Success',
        response['message'] ?? 'Clockout undone successfully.',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      // Refresh dashboard
      await refreshDashboard();
    } else {
      // Show error message
      Get.snackbar(
        'Error',
        response['message'] ?? 'Failed to undo clock out',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  } catch (e) {
    // Handle exceptions
  }
}
```

### 5. **UI Implementation**

#### Added "Undo Clock Out" Button
**File:** `lib/app/modules/driver/dashboard/driver_dashboard_page.dart`

**Button Design:**
- **Color:** Orange (`Colors.orange`)
- **Icon:** Undo icon (`Icons.undo`)
- **Text:** "Undo Clock Out"
- **Position:** After urgent clock out button
- **Visibility:** Only shows when `data.clockStatus.canUndoClockout == true`

**Confirmation Dialog:**
```dart
AlertDialog(
  title: Text('Undo Clock Out?'),
  content: Text(
    'Are you sure you want to undo your recent clock out? 
     You will be clocked in again.',
  ),
  actions: [
    TextButton(child: Text('Cancel')),
    ElevatedButton(
      onPressed: () {
        Get.back(); // Close dialog
        controller.undoClockOut(); // Call API
      },
      child: Text('Yes, Undo'),
    ),
  ],
)
```

## 🎯 Business Logic

### When Button Appears
**Condition:** `can_undo_clockout = true` in dashboard API response

### Button Flow
```
User Taps "Undo Clock Out" Button
    ↓
Confirmation Dialog Shows
    ↓
User Clicks "Yes, Undo"
    ↓
Loading Indicator Displays
    ↓
API Call to /undo-clock-out
    ↓
API Response Received
    ↓
Success → Green Snackbar + Dashboard Refresh
Error → Red Snackbar
```

### API Request & Response

#### Request
```json
POST {{APP_URL}}/undo-clock-out
Content-Type: multipart/form-data

{
  "user_id": "4"
}
```

#### Success Response
```json
{
  "status": true,
  "message": "Clockout undone successfully. You are now clocked in again.",
  "data": {
    "clock_in_id": 6,
    "clock_in_time": "2025-10-09T02:36:54.000000Z",
    "is_currently_clocked_in": true
  }
}
```

#### Error Response
```json
{
  "status": false,
  "message": "Unable to undo clock out. Time limit exceeded.",
  "data": null
}
```

## 📊 Dashboard States

### State 1: Normal (No Undo Available)
```json
{
  "clock_status": {
    "can_undo_clockout": false,
    "is_currently_clocked_in": true
  }
}
```
**UI:** No "Undo Clock Out" button visible

---

### State 2: Undo Available
```json
{
  "clock_status": {
    "can_undo_clockout": true,
    "is_currently_clocked_in": false
  }
}
```
**UI:** Orange "Undo Clock Out" button visible

---

### State 3: After Successful Undo
```json
{
  "clock_status": {
    "can_undo_clockout": false,
    "is_currently_clocked_in": true
  }
}
```
**UI:** Button disappears, user is clocked in again

## 🎨 Visual Design

### Button Appearance
```
┌─────────────────────────────────┐
│  🔄  Undo Clock Out            │  ← Orange button
└─────────────────────────────────┘
```

### Button States
| State | Appearance | Action |
|-------|------------|--------|
| **Visible** | Orange button with undo icon | Shows confirmation dialog |
| **Hidden** | Not rendered | `can_undo_clockout = false` |
| **Loading** | Circular progress indicator | API call in progress |

### Confirmation Dialog
```
┌────────────────────────────┐
│  Undo Clock Out?           │
│                            │
│  Are you sure you want to  │
│  undo your recent clock    │
│  out? You will be clocked  │
│  in again.                 │
│                            │
│  [Cancel]    [Yes, Undo]   │
└────────────────────────────┘
```

## 🔄 User Flow Examples

### Scenario 1: Driver Accidentally Clocked Out
```
1. Driver clocks out by mistake
   ↓
2. Dashboard shows "Undo Clock Out" button (orange)
   ↓
3. Driver taps "Undo Clock Out"
   ↓
4. Confirmation dialog appears
   ↓
5. Driver confirms "Yes, Undo"
   ↓
6. Loading indicator shows
   ↓
7. API call successful
   ↓
8. Green snackbar: "Clockout undone successfully"
   ↓
9. Dashboard refreshes
   ↓
10. Driver is clocked in again
    ↓
11. "Undo Clock Out" button disappears
```

### Scenario 2: Time Limit Exceeded
```
1. Driver clocked out 2 hours ago
   ↓
2. Dashboard shows "Undo Clock Out" button
   ↓
3. Driver taps button and confirms
   ↓
4. API returns error: "Time limit exceeded"
   ↓
5. Red snackbar shows error message
   ↓
6. Button may still be visible (depends on API response)
   ↓
7. Driver must clock in normally
```

## 🚀 Integration Steps

### Backend Requirements
The backend API should:

1. **Validate Request**
   - Check if user_id exists
   - Verify recent clock-out exists
   - Check time limit (e.g., within 30 minutes)

2. **Update Database**
   - Delete clock-out record OR
   - Mark clock-out as reversed
   - Update user's clock-in status

3. **Return Response**
   ```json
   {
     "status": true,
     "message": "Success message",
     "data": {
       "clock_in_id": 6,
       "clock_in_time": "2025-10-09T02:36:54.000000Z",
       "is_currently_clocked_in": true
     }
   }
   ```

4. **Update Dashboard API**
   - Set `can_undo_clockout: true` after clock-out
   - Set `can_undo_clockout: false` after time limit
   - Set `can_undo_clockout: false` after successful undo

## 📝 Testing Checklist

### UI Tests
- [ ] Button appears when `can_undo_clockout = true`
- [ ] Button hidden when `can_undo_clockout = false`
- [ ] Button is orange with undo icon
- [ ] Confirmation dialog shows on button tap
- [ ] "Cancel" closes dialog without action
- [ ] "Yes, Undo" proceeds with API call

### Functional Tests
- [ ] Loading indicator shows during API call
- [ ] Success message displays on successful undo
- [ ] Error message displays on failed undo
- [ ] Dashboard refreshes after successful undo
- [ ] User is clocked in after successful undo
- [ ] Button disappears after successful undo

### API Integration Tests
- [ ] POST request sent to correct endpoint
- [ ] `user_id` parameter included in request
- [ ] Success response handled correctly
- [ ] Error response handled correctly
- [ ] Network errors handled gracefully

### Edge Cases
- [ ] No user ID available (shows error)
- [ ] API timeout (shows error)
- [ ] Multiple rapid taps (prevented by loading state)
- [ ] Undo after time limit (shows API error message)

## 🔍 Troubleshooting

### Button Not Showing
**Check:**
1. Is `can_undo_clockout` true in API response?
2. Is dashboard data loaded successfully?
3. Is user recently clocked out?

### API Call Fails
**Check:**
1. Is user_id available?
2. Is network connection active?
3. Is API endpoint correct?
4. Does backend validate time limit?

### Dashboard Not Refreshing
**Check:**
1. Is `refreshDashboard()` called after success?
2. Is API returning updated `can_undo_clockout` value?
3. Are there any errors in refresh method?

## ✨ Key Features

1. **Smart Visibility** - Button only shows when undo is possible
2. **Confirmation Dialog** - Prevents accidental undo actions
3. **Loading Feedback** - Shows progress during API call
4. **Success/Error Messages** - Clear user feedback
5. **Auto Refresh** - Dashboard updates after successful undo
6. **Clean UI** - Orange button stands out but doesn't overwhelm

## 🎯 Summary

**What This Does:**
- ✅ Adds `can_undo_clockout` field to dashboard API model
- ✅ Creates undo clock-out API service method
- ✅ Implements controller logic with error handling
- ✅ Shows orange "Undo Clock Out" button when available
- ✅ Displays confirmation dialog before undo
- ✅ Refreshes dashboard after successful undo
- ✅ Provides clear success/error feedback to user

**Result:** Drivers can quickly undo accidental clock-outs within the allowed time window! 🎉
