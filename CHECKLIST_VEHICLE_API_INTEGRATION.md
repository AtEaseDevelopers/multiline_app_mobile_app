# Daily Checklist - Vehicle Dropdown API Integration

## Summary
Integrated the `/get-lorries` API to dynamically populate the vehicle dropdown in the Daily Checklist screen instead of using hardcoded values.

## Changes Made

### 1. Controller Updates (`daily_checklist_controller.dart`)

#### Added Imports
```dart
import '../../../data/models/vehicle_model.dart';
import '../../../data/services/driver_service.dart';
```

#### Added Properties
```dart
final DriverService _driverService = DriverService();
final isLoadingVehicles = false.obs;
final vehicles = <Vehicle>[].obs;
```

#### Added Method
```dart
Future<void> loadVehicles() async {
  try {
    isLoadingVehicles.value = true;
    final vehicleList = await _driverService.getLorries();
    vehicles.value = vehicleList;
  } catch (e) {
    Get.snackbar(
      'Error',
      'Failed to load vehicles: ${e.toString()}',
      snackPosition: SnackPosition.BOTTOM,
    );
  } finally {
    isLoadingVehicles.value = false;
  }
}
```

#### Updated onInit()
```dart
@override
void onInit() {
  super.onInit();
  loadChecklist();
  loadVehicles(); // Added this line
}
```

### 2. UI Updates (`daily_checklist_page.dart`)

Replaced hardcoded dropdown with dynamic vehicle list:

#### Before
```dart
items: const [
  DropdownMenuItem(
    value: 1,
    child: Text('Vehicle 1 - WXY 1234'),
  ),
  DropdownMenuItem(
    value: 2,
    child: Text('Vehicle 2 - ABC 5678'),
  ),
],
```

#### After
```dart
Obx(() {
  // Loading state
  if (controller.isLoadingVehicles.value) {
    return Container(
      padding: const EdgeInsets.all(16),
      alignment: Alignment.center,
      child: const CircularProgressIndicator(),
    );
  }

  // Empty state
  if (controller.vehicles.isEmpty) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange[300]!),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: Colors.orange[700]),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'No vehicles available',
              style: TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  // Dynamic dropdown with API data
  return DropdownButtonFormField<int>(
    value: controller.selectedVehicleId.value,
    decoration: InputDecoration(...),
    hint: const Text('Choose your vehicle'),
    items: controller.vehicles
        .map((vehicle) => DropdownMenuItem<int>(
              value: vehicle.id,
              child: Text(
                '${vehicle.registrationNumber} - ${vehicle.companyName}',
              ),
            ))
        .toList(),
    onChanged: (value) {
      if (value != null) {
        controller.setSelectedVehicle(value);
      }
    },
  );
})
```

## Features

### 1. **Dynamic Vehicle Loading**
- Vehicles are fetched from `/get-lorries` API on page load
- Uses existing `DriverService.getLorries()` method
- Returns list of `Vehicle` objects with:
  - `id` - Vehicle ID
  - `registrationNumber` - Vehicle registration number
  - `companyName` - Company name

### 2. **Loading State**
- Shows `CircularProgressIndicator` while vehicles are being fetched
- Prevents interaction until data is loaded

### 3. **Empty State**
- Displays informative message when no vehicles are available
- Orange warning box with icon
- Clear user feedback

### 4. **Error Handling**
- Shows snackbar if vehicle loading fails
- Graceful degradation - dropdown shows empty state

### 5. **Display Format**
- Dropdown items show: `Registration Number - Company Name`
- Example: `WXY 1234 - ABC Transport Ltd`

## API Integration

### Endpoint
```
POST /get-lorries
```

### Response Format
```json
{
  "status": true,
  "message": "Success",
  "vehicles": [
    {
      "id": 1,
      "registration_number": "WXY 1234",
      "company_name": "ABC Transport Ltd"
    },
    {
      "id": 2,
      "registration_number": "ABC 5678",
      "company_name": "XYZ Logistics"
    }
  ]
}
```

### Model Structure
```dart
class Vehicle {
  final int id;
  final String registrationNumber;
  final String companyName;
}

class VehiclesResponse {
  final List<Vehicle> vehicles;
}
```

## User Experience Flow

1. User opens Daily Checklist screen
2. Page loads checklist data AND vehicle list in parallel
3. While vehicles load:
   - Spinner shown in vehicle selection card
   - Rest of the page is functional
4. Once loaded:
   - Dropdown populated with real vehicles
   - User can select from available vehicles
5. If no vehicles:
   - Warning message displayed
   - User cannot proceed (validation prevents submission)

## Benefits

✅ **Dynamic Data** - No hardcoded vehicle lists
✅ **Real-time** - Always shows current available vehicles
✅ **Consistent** - Uses same API as Clock In and Inspection
✅ **User-friendly** - Clear loading and empty states
✅ **Validated** - Prevents submission without vehicle selection
✅ **Professional UI** - Matches the enhanced design pattern

## Testing Checklist

- [ ] Vehicles load successfully on page open
- [ ] Loading spinner shows during fetch
- [ ] Dropdown populated with API data
- [ ] Vehicle selection works correctly
- [ ] Selected vehicle ID saved in controller
- [ ] Submit includes correct vehicle_id
- [ ] Empty state shows when no vehicles
- [ ] Error state shows on API failure
- [ ] Dropdown displays registration + company name
- [ ] Works with existing validation logic

## Files Modified

1. `lib/app/modules/driver/checklist/daily_checklist_controller.dart`
   - Added vehicle loading logic
   - Added DriverService dependency
   - Added vehicles observable list

2. `lib/app/modules/driver/checklist/daily_checklist_page.dart`
   - Replaced hardcoded dropdown
   - Added loading/empty states
   - Dynamic item rendering

## Dependencies Used

- Existing `DriverService.getLorries()` method
- Existing `Vehicle` and `VehiclesResponse` models
- Existing `ApiConstants.getLorries` endpoint constant

No new dependencies or services created - reused existing infrastructure! 🚀
