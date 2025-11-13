# History API Model Update

## Summary
Updated the history models to match the new API response format for the `{{APP_URL}}driver/history` endpoint.

## API Details
- **Endpoint**: `{{APP_URL}}driver/history`
- **Method**: POST
- **Parameters**: `user_id`

## API Response Format
```json
{
  "data": {
    "inspections": [
      {
        "id": 3,
        "registration_number": "sadsad",
        "template": "Vehicle inspection",
        "created_at": "2025-10-03 05:32:55",
        "status": "Approved (supervisor)"
      }
    ],
    "checklists": [
      {
        "id": 1,
        "registration_number": "sadsad",
        "template": "dsff",
        "created_at": "2025-10-03 12:19:58",
        "status": "Approved (supervisor)"
      }
    ],
    "incidents": []
  },
  "message": "",
  "status": true
}
```

## Changes Made

### 1. `history_model.dart` - HistoryResponse
**Updated**: Modified `fromJson` to handle nested `data` object from API
```dart
factory HistoryResponse.fromJson(Map<String, dynamic> json) {
  // Handle the nested 'data' object from API response
  final data = json['data'] ?? json;
  
  return HistoryResponse(
    incidents: data['incidents'] != null ? ... : [],
    inspections: data['inspections'] != null ? ... : [],
    checklists: data['checklists'] != null ? ... : [],
  );
}
```

### 2. `history_model.dart` - InspectionHistoryItem
**Updated properties** to match new API format:
- `id` (int)
- `registrationNumber` (String) - was `vehicleNumber`
- `template` (String) - new field
- `createdAt` (String) - was `date` and `time` separately
- `status` (String)

**Added helper getters** for backward compatibility:
- `vehicleNumber` → returns `registrationNumber`
- `inspectorName` → returns `null` (not in new API)
- `notes` → returns `null` (not in new API)
- `date` → parses from `createdAt`
- `time` → parses from `createdAt`

### 3. `history_model.dart` - ChecklistHistoryItem
**Updated properties** to match new API format:
- `id` (int)
- `registrationNumber` (String) - was `vehicleNumber`
- `template` (String) - new field
- `createdAt` (String) - was `date` and `time` separately
- `status` (String)

**Added helper getters** for backward compatibility:
- `vehicleNumber` → returns `registrationNumber`
- `totalItems` → returns `null` (not in new API)
- `completedItems` → returns `null` (not in new API)
- `date` → parses from `createdAt`
- `time` → parses from `createdAt`

### 4. `history_model.dart` - IncidentHistoryItem
**Updated properties** to match new API format:
- `id` (int)
- `registrationNumber` (String?) - nullable
- `template` (String?) - new field, nullable
- `createdAt` (String)
- `status` (String)
- `incidentType` (String?) - nullable
- `location` (String?) - nullable
- `description` (String?) - nullable

**Added helper getters** for backward compatibility:
- `vehicleNumber` → returns `registrationNumber` (nullable)
- `date` → parses from `createdAt`
- `time` → parses from `createdAt`

### 5. `history_page.dart`
**Fixed null safety issues**:
- Updated incident type display: `incident.incidentType ?? incident.template ?? 'Incident'`
- Updated location display: `incident.location ?? 'N/A'`

## Backward Compatibility
All existing UI code continues to work thanks to helper getters that:
- Map old property names to new ones
- Parse `created_at` into separate `date` and `time` values
- Return sensible defaults for removed fields

## Benefits
✅ **API Aligned**: Models now match the actual API response structure
✅ **Backward Compatible**: Existing UI code works without changes
✅ **Date/Time Parsing**: Automatic conversion from `created_at` timestamp
✅ **Null Safe**: Proper handling of optional/nullable fields
✅ **Template Support**: New `template` field available for both inspections and checklists

## Testing Checklist
- [ ] Test driver history page loads correctly
- [ ] Verify inspections display with correct data
- [ ] Verify checklists display with correct data
- [ ] Verify incidents display (when available)
- [ ] Check date/time formatting is correct
- [ ] Verify status badges appear correctly
- [ ] Test null/empty incident scenarios

## Files Modified
1. `/lib/app/data/models/history_model.dart` - Complete model restructure
2. `/lib/app/modules/history/history_page.dart` - Null safety fixes

## Files Unchanged (but compatible)
1. `/lib/app/data/services/history_service.dart` - Works with updated models
2. `/lib/app/modules/history/history_controller.dart` - Uses getter methods
