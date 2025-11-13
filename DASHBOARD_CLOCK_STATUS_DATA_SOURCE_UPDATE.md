# Dashboard Clock Status Data Source Update

## Overview
Updated the dashboard to use `last_clock_in_time` and `odometer` values from the `clock_status` object in the API response, instead of using values from `user_data`.

## API Response Structure

```json
{
  "data": {
    "user_data": {
      "group": null,
      "user_id": 4,
      "user_name": "Rafi Ullah",
      "odo_meter": "20 km",  // ❌ Old source (not used anymore)
      "company_name": "MULTILINE TRADING SDN BHD",
      "lorry_no": "JKA 1",
      "clockin_id": 20
    },
    "clock_status": {
      "is_currently_clocked_in": true,
      "has_old_pending_clock_out": false,
      "can_clock_in_today": false,
      "show_reminder": false,
      "last_clock_in_time": "2025-10-09T04:04:44.000000Z", // ✅ New source
      "odometer": "20 km"  // ✅ New source
    }
  },
  "message": "",
  "status": true
}
```

## Changes Made

### 1. **Dashboard Model** (`lib/app/data/models/dashboard_model.dart`)

#### Added `odometer` field to `ClockStatus` class:

```dart
class ClockStatus {
  final bool isCurrentlyClockedIn;
  final bool hasOldPendingClockOut;
  final bool canClockInToday;
  final bool showReminder;
  final String? lastClockInTime;
  final String? odometer;  // ✅ New field added

  ClockStatus({
    required this.isCurrentlyClockedIn,
    required this.hasOldPendingClockOut,
    required this.canClockInToday,
    required this.showReminder,
    this.lastClockInTime,
    this.odometer,  // ✅ New parameter
  });

  factory ClockStatus.fromJson(Map<String, dynamic> json) {
    return ClockStatus(
      isCurrentlyClockedIn: json['is_currently_clocked_in'] as bool? ?? false,
      hasOldPendingClockOut: json['has_old_pending_clock_out'] as bool? ?? false,
      canClockInToday: json['can_clock_in_today'] as bool? ?? true,
      showReminder: json['show_reminder'] as bool? ?? false,
      lastClockInTime: json['last_clock_in_time'] as String?,
      odometer: json['odometer'] as String?,  // ✅ Parse from clock_status
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'is_currently_clocked_in': isCurrentlyClockedIn,
      'has_old_pending_clock_out': hasOldPendingClockOut,
      'can_clock_in_today': canClockInToday,
      'show_reminder': showReminder,
      'last_clock_in_time': lastClockInTime,
      'odometer': odometer,  // ✅ Serialize odometer
    };
  }
}
```

**Reason:** The API now provides odometer reading in `clock_status` instead of `user_data`. This is more accurate as it represents the current active clock session's odometer reading.

---

### 2. **Dashboard Controller** (`lib/app/modules/driver/dashboard/driver_dashboard_controller.dart`)

#### Added `odometer` getter:

```dart
// New clock status getters
bool get isCurrentlyClockedIn =>
    dashboardData.value?.isCurrentlyClockedIn ?? false;
bool get hasOldPendingClockOut =>
    dashboardData.value?.hasOldPendingClockOut ?? false;
bool get canClockInToday => dashboardData.value?.canClockInToday ?? true;
bool get showReminder => dashboardData.value?.showReminder ?? false;
String? get lastClockInTime =>
    dashboardData.value?.clockStatus.lastClockInTime;
String? get odometer => dashboardData.value?.clockStatus.odometer;  // ✅ New getter
```

**Reason:** Provides easy access to the odometer value from `clock_status` throughout the dashboard.

---

### 3. **Dashboard Page** (`lib/app/modules/driver/dashboard/driver_dashboard_page.dart`)

#### Updated odometer display:

**Before:**
```dart
Text(
  data.userData.odoMeter ?? 'N/A',  // ❌ From user_data
  style: const TextStyle(
    color: Colors.white,
    fontSize: 16,
    fontWeight: FontWeight.bold,
  ),
),
```

**After:**
```dart
Text(
  controller.odometer ?? 'N/A',  // ✅ From clock_status
  style: const TextStyle(
    color: Colors.white,
    fontSize: 16,
    fontWeight: FontWeight.bold,
  ),
),
```

**Clock-in time display remains the same:**
```dart
Text(
  _formatClockInTime(controller.lastClockInTime),  // ✅ Already using clock_status
  style: const TextStyle(
    color: Colors.white,
    fontSize: 14,
    fontWeight: FontWeight.bold,
  ),
),
```

---

## Data Flow

### Before (Incorrect):
```
API Response
  └─ data.user_data.odo_meter → Dashboard Card ❌
  └─ data.clock_status.last_clock_in_time → Dashboard Card ✅
```

### After (Correct):
```
API Response
  └─ data.clock_status.odometer → Dashboard Card ✅
  └─ data.clock_status.last_clock_in_time → Dashboard Card ✅
```

---

## Benefits

### ✅ **Consistency**
Both odometer and clock-in time now come from the same source (`clock_status`)

### ✅ **Accuracy**
- `clock_status.odometer` represents the **current active session** odometer
- `clock_status.last_clock_in_time` represents the **current active session** clock-in time
- Both values are in sync and related to the same clock-in event

### ✅ **Data Integrity**
- `user_data.odo_meter` might be outdated or represent a different value
- `clock_status` values are guaranteed to be current and session-specific

---

## Display Behavior

The dashboard card will show:

### When User is Clocked In (`is_currently_clocked_in: true`):
```
┌─────────────────────────────────┐
│  🚚 Clocked In (Green Card)     │
│                                 │
│  ⚡ Odometer Reading:    20 km  │
│  ────────────────────────────   │
│  🕐 Clocked In At: 12:04 09/10  │
└─────────────────────────────────┘
```

### When User is Not Clocked In:
```
┌─────────────────────────────────┐
│  🚚 Not Clocked In (Red Card)   │
│  (No odometer/time shown)       │
└─────────────────────────────────┘
```

### When User is Clocked Out:
```
┌─────────────────────────────────┐
│  🚚 Clocked Out (Yellow Card)   │
│  (No odometer/time shown)       │
└─────────────────────────────────┘
```

---

## API Integration

### Request
```
POST /api/driver/dashboard
```

### Response
```json
{
  "data": {
    "user_data": {
      "user_id": 4,
      "user_name": "Rafi Ullah",
      "odo_meter": "20 km",
      "company_name": "MULTILINE TRADING SDN BHD",
      "lorry_no": "JKA 1",
      "clockin_id": 20
    },
    "clock_status": {
      "is_currently_clocked_in": true,
      "has_old_pending_clock_out": false,
      "can_clock_in_today": false,
      "show_reminder": false,
      "last_clock_in_time": "2025-10-09T04:04:44.000000Z",
      "odometer": "20 km"
    }
  },
  "message": "",
  "status": true
}
```

### Data Mapping
| API Field | Model Field | Display |
|-----------|-------------|---------|
| `clock_status.odometer` | `ClockStatus.odometer` | "20 km" |
| `clock_status.last_clock_in_time` | `ClockStatus.lastClockInTime` | "12:04 09/10" (formatted) |

---

## Testing Checklist

- [ ] Dashboard shows correct odometer from `clock_status`
- [ ] Dashboard shows correct clock-in time from `clock_status`
- [ ] Odometer displays "N/A" when null
- [ ] Clock-in time formats correctly (ISO → HH:MM DD/MM)
- [ ] Values update after clock-in
- [ ] Values update after dashboard refresh
- [ ] Both values disappear when clocked out
- [ ] Both values reappear when clocked in again

---

## Files Modified

1. **lib/app/data/models/dashboard_model.dart**
   - Added `odometer` field to `ClockStatus` class
   - Updated `fromJson()` to parse `odometer` from API
   - Updated `toJson()` to serialize `odometer`

2. **lib/app/modules/driver/dashboard/driver_dashboard_controller.dart**
   - Added `odometer` getter to access `clock_status.odometer`

3. **lib/app/modules/driver/dashboard/driver_dashboard_page.dart**
   - Changed odometer source from `data.userData.odoMeter` to `controller.odometer`

---

## Summary

The dashboard now correctly retrieves both **odometer** and **clock-in time** from the `clock_status` object in the API response, ensuring that both values represent the current active clock session and are always in sync.

**Before:** Mixed sources (user_data + clock_status) ❌  
**After:** Single source (clock_status) ✅
