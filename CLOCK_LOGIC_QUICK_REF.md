# Clock In/Out Logic - Quick Reference 🚦

## API Response Flags

```json
{
  "is_clocked_in": true/false,
  "is_clocked_out": true/false
}
```

---

## 🎯 Quick Decision Tree

```
┌─────────────────────────────────────────────────────────┐
│           WHAT TO SHOW USER?                            │
└─────────────────────────────────────────────────────────┘

is_clocked_in = TRUE
is_clocked_out = FALSE
    ↓
    🚨 ALERT! "You forgot to clock out!"
    → Block Clock In
    → Show "Clock Out" button
    → No vehicle selection needed


is_clocked_in = FALSE  
is_clocked_out = TRUE
    ↓
    ✅ Normal morning state
    → Show "Clock In" button
    → Must select vehicle
    → Show vehicle details after selection


is_clocked_in = TRUE
is_clocked_out = TRUE
    ↓
    🤔 Invalid state (shouldn't happen)
    → Show error or default to clock in


is_clocked_in = FALSE
is_clocked_out = FALSE  
    ↓
    🤔 Invalid state (shouldn't happen)
    → Show error or default to clock in
```

---

## 📊 Truth Table

| is_clocked_in | is_clocked_out | State | Action | Vehicle Selection |
|---------------|----------------|-------|--------|-------------------|
| `false` | `true` | ✅ Ready to work | Show "Clock In" | YES (required) |
| `true` | `false` | 🔥 Working / Forgot | Show "Clock Out" | NO (already assigned) |
| `false` | `false` | ❌ Invalid | Error / Default | - |
| `true` | `true` | ❌ Invalid | Error / Default | - |

---

## 🚨 Alert Conditions

### When to show alert?

```dart
if (is_clocked_in == true && is_clocked_out == false) {
  // Two possible scenarios:
  
  // Scenario A: User is currently working (normal)
  // → Show "Clock Out" button (no alert)
  
  // Scenario B: User forgot to clock out yesterday
  // → Show alert on app launch
  // → Show alert when clicking "Clock In"
  
  // Detection: Check time since last clock in
  // If > 12 hours → Forgot to clock out
}
```

**Current Implementation:**
- Shows alert immediately when dashboard loads
- Blocks "Clock In" button
- Forces user to clock out first

---

## 🔄 User Journey Examples

### Example 1: Normal Day

```
7:00 AM - Open App
  ↓
API: is_clocked_in=false, is_clocked_out=true
  ↓
Dashboard: "Clock In" button (green) ✅
  ↓
Click "Clock In"
  ↓
Select Vehicle: "BCD1234"
  ↓
Vehicle Details Card Shows
  ↓
Enter Meter: 12345.5 km
  ↓
Take Photo
  ↓
Submit → Clocked In ✅

---

5:00 PM - End Shift
  ↓
Dashboard: "Clock Out" button (red) ✅
  ↓
Click "Clock Out"
  ↓
NO Vehicle Selection (already assigned)
  ↓
Enter Final Meter: 12545.5 km
  ↓
Take Dashboard Photo
  ↓
Submit → Clocked Out ✅
```

---

### Example 2: Forgot to Clock Out

```
Yesterday 7:00 AM - Clock In
  ↓
API: is_clocked_in=true, is_clocked_out=false
  ↓
Working all day...
  ↓
5:00 PM - FORGET TO CLOCK OUT ❌
  ↓
Close app, go home

---

Next Day 7:00 AM - Open App
  ↓
API: is_clocked_in=true, is_clocked_out=false
  ↓
🚨 ALERT APPEARS!
"You haven't clocked out from your previous shift!"
  ↓
Options:
  [Later] → Dismisses but blocks clock in
  [Clock Out Now] → Go to clock out page
  ↓
Click "Clock Out Now"
  ↓
NO Vehicle Selection
  ↓
Enter Yesterday's Final Meter: 12545.5 km
  ↓
Take Dashboard Photo
  ↓
Submit → Clocked Out ✅
  ↓
API: is_clocked_in=false, is_clocked_out=true
  ↓
Now can clock in for today ✅
```

---

## 🎨 Visual States

### Dashboard Card - Normal Clock In

```
┌──────────────────────────────────────┐
│ 📊 Today's Status                    │
│ Hi, John 👋                          │
│                                      │
│ ┌──────────────────────────────────┐ │
│ │ Company: AT EASE Logistics       │ │
│ │ Group: Driver                    │ │
│ │ Vehicle: BCD1234                 │ │
│ │                                  │ │
│ │ 🟢 Not Clocked In                │ │
│ │                                  │ │
│ │              [🕐 Clock In]       │ │
│ │                                  │ │
│ │ Work Hours: 0h 0m                │ │
│ └──────────────────────────────────┘ │
└──────────────────────────────────────┘
```

---

### Dashboard Card - Forgot to Clock Out

```
┌──────────────────────────────────────┐
│ 📊 Today's Status                    │
│ Hi, John 👋                          │
│                                      │
│ ┌──────────────────────────────────┐ │
│ │ Company: AT EASE Logistics       │ │
│ │ Group: Driver                    │ │
│ │ Vehicle: BCD1234                 │ │
│ │                                  │ │
│ │ 🔴 Clocked In                    │ │
│ │                                  │ │
│ │ ┌──────────────────────────────┐ │ │
│ │ │ ⚠️ You haven't clocked out   │ │ │
│ │ │    from your previous shift! │ │ │
│ │ └──────────────────────────────┘ │ │
│ │                                  │ │
│ │              [🕐 Clock Out]      │ │
│ │                                  │ │
│ │ Work Hours: 0h 0m                │ │
│ └──────────────────────────────────┘ │
└──────────────────────────────────────┘
```

---

### Alert Dialog

```
┌────────────────────────────────────────┐
│ ⚠️ Clock Out Reminder                  │
├────────────────────────────────────────┤
│                                        │
│ You haven't clocked out from your      │
│ previous shift!                        │
│                                        │
│ Please clock out first before          │
│ starting a new shift.                  │
│                                        │
│                                        │
│         [Later]  [⏰ Clock Out Now]    │
│                                        │
└────────────────────────────────────────┘
```

---

## 🔧 Code Snippets

### Check Forgot to Clock Out

```dart
bool get forgotToClockOut {
  return !isClockedOut && isClockedIn;
}
```

### Show Alert

```dart
if (forgotToClockOut) {
  Get.dialog(
    AlertDialog(
      title: Text('Clock Out Reminder'),
      content: Text('You haven\'t clocked out...'),
      actions: [
        TextButton('Later'),
        ElevatedButton('Clock Out Now'),
      ],
    ),
    barrierDismissible: false,
  );
}
```

### Button Logic

```dart
onPressed: () {
  if (forgotToClockOut && !canClockOut) {
    checkClockOutReminder();
    return; // Block navigation
  }

  if (canClockOut) {
    Get.toNamed('/driver/clock-out');
  } else if (canClockIn) {
    Get.toNamed('/driver/clock-in');
  }
}
```

---

## ✅ Checklist for Testing

- [ ] Test with `is_clocked_in: false, is_clocked_out: true` → Should show "Clock In"
- [ ] Test with `is_clocked_in: true, is_clocked_out: false` → Should show alert + "Clock Out"
- [ ] Alert should appear on dashboard load
- [ ] Alert should block "Clock In" button
- [ ] "Clock Out Now" should navigate to clock out page
- [ ] After clock out, alert should disappear
- [ ] Vehicle selection should appear for clock in
- [ ] Vehicle selection should NOT appear for clock out
- [ ] Decimal meter reading should work (12345.5)
- [ ] " km" should auto-append on submit

---

**Last Updated:** 3 October 2025  
**Status:** ✅ Complete
