# Incident Detail Page Debug Guide

## Current Issue
Data loads successfully from API but incident detail page doesn't open.

## Debug Logging Added

### What You'll See in Console

When you tap an incident card, you should see detailed console output like this:

```
🔍 Loading incident details for ID: 2
🔍 IncidentDetailResponse.fromJson called with:
  JSON keys: [data, message, status]
  data is null: false
  data keys: [details]
  details is null: false
  details keys: [id, registration_number, incident_type, created_at, remarks, photos, company_name]
  Creating IncidentDetail from details...
  ✅ IncidentDetail created successfully
  - ID: 2
  - Incident Type: 123
  - Photos count: 1
🔍 Incident Detail Response:
  - incident is null: false
  - ID: 2
  - Incident Type: 123
  - Photos count: 1
  - Has remarks: true
  ✅ Navigating to incident detail page...
  ✅ Navigation completed
```

## Expected vs Problem Scenarios

### ✅ SUCCESS Scenario (Should see this):
```
🔍 IncidentDetailResponse.fromJson called with:
  JSON keys: [data, message, status]
  data is null: false
  data keys: [details]
  details is null: false
  details keys: [id, registration_number, ...]
  Creating IncidentDetail from details...
  ✅ IncidentDetail created successfully  ← Good!
  - ID: 2
  - Incident Type: 123
  - Photos count: 1
🔍 Incident Detail Response:
  - incident is null: false              ← Good!
  ✅ Navigating to incident detail page... ← Should navigate
  ✅ Navigation completed
```
**Result**: Detail page should open

### ❌ PROBLEM Scenario (If this happens):
```
🔍 IncidentDetailResponse.fromJson called with:
  JSON keys: [data, message, status]
  data is null: false
  data keys: [details]
  details is null: false
  details keys: [id, registration_number, ...]
  Creating IncidentDetail from details...
  [ERROR HERE - Check for exceptions]
```
**OR**
```
🔍 Incident Detail Response:
  - incident is null: true               ← Problem!
  ⚠️ Incident is null - showing error message
```
**Result**: Shows error message, doesn't navigate

## What to Check

### 1. Check Parsing Success
Look for this line:
```
✅ IncidentDetail created successfully
```

If you DON'T see this, there's an error in `IncidentDetail.fromJson`.

### 2. Check incident Null Status
Look for:
```
- incident is null: false
```

If it says `true`, the parsing failed silently.

### 3. Check Navigation
Look for:
```
✅ Navigating to incident detail page...
✅ Navigation completed
```

If you see "Navigating" but NOT "completed", there's a navigation/route issue.

## Possible Issues & Solutions

### Issue 1: Parsing Fails
**Symptoms**:
- Don't see "✅ IncidentDetail created successfully"
- See error in console during parsing

**Cause**: Field mismatch or type error in JSON parsing

**Solution**: Check the console error and update `IncidentDetail.fromJson`

### Issue 2: incident is null
**Symptoms**:
```
- incident is null: true
⚠️ Incident is null - showing error message
```

**Cause**: Details object is not being parsed correctly

**Solution**: The parsing logic needs adjustment

### Issue 3: Navigation Doesn't Complete
**Symptoms**:
```
✅ Navigating to incident detail page...
[No "Navigation completed" message]
[Possible error about route or widget]
```

**Cause**: Route not registered or IncidentDetailPage has errors

**Solutions**:
1. Check route is registered in `app_pages.dart`
2. Check `IncidentDetailPage` widget can render
3. Check if arguments are being passed correctly

### Issue 4: Route Not Found
**Symptoms**:
```
Error: No route defined for '/history/incident-detail'
```

**Solution**: Ensure route is registered in `app_pages.dart`:
```dart
GetPage(
  name: AppRoutes.historyIncidentDetail,  // '/history/incident-detail'
  page: () => const IncidentDetailPage(),
  transition: Transition.rightToLeft,
),
```

## Testing Steps

1. **Open the app** in debug mode with console visible
2. **Navigate to History page**
3. **Tap an incident card**
4. **Watch console output** - it should show all the debug prints
5. **Take note** of any errors or unexpected values
6. **Share the console output** if it still doesn't work

## Known Data from Your Log

You already confirmed this data loads correctly:
```json
{
  "data": {
    "details": {
      "id": 2,
      "registration_number": "sadsad",
      "incident_type": "123",
      "created_at": "2025-10-04 12:25:38",
      "remarks": "ddhkhgdjghdhjgdjfhgdjfvgdjfgadjfhgajfgajhkfgajfgjfghjgj",
      "photos": ["http://app.multiline.site/uploads/..."],
      "company_name": "MULTILINE TRADING SDN BHD"
    }
  }
}
```

So the API is working correctly. The issue must be in:
1. ✅ JSON parsing (should work now with debug logging)
2. ✅ Null checking (enhanced with debug)
3. ❓ Navigation or page rendering

## Expected Full Console Output

When everything works, you should see:

```
🔍 Loading incident details for ID: 2
🔍 IncidentDetailResponse.fromJson called with:
  JSON keys: [data, message, status]
  data is null: false
  data keys: [details]
  details is null: false
  details keys: [id, registration_number, incident_type, created_at, remarks, photos, company_name]
  Creating IncidentDetail from details...
  ✅ IncidentDetail created successfully
  - ID: 2
  - Incident Type: 123
  - Photos count: 1
🔍 Incident Detail Response:
  - incident is null: false
  - ID: 2
  - Incident Type: 123
  - Photos count: 1
  - Has remarks: true
  ✅ Navigating to incident detail page...
  ✅ Navigation completed
```

Then the incident detail page should open showing:
- Header with "123" as incident type
- Vehicle: sadsad
- Company: MULTILINE TRADING SDN BHD
- Date & time
- Remarks section with the long text
- Photos grid with 1 photo

---

**Please test now and share the complete console output!** 🔍
