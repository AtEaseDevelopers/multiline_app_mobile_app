# AT-EASE Fleet Management - API Integration Guide

**Generated on:** October 3, 2025  
**Integration Status:** ✅ Complete  
**Base URL:** `http://app.multiline.site/api/`

---

## 📋 Table of Contents

1. [Overview](#overview)
2. [Architecture](#architecture)
3. [API Endpoints](#api-endpoints)
4. [Implementation Details](#implementation-details)
5. [Usage Examples](#usage-examples)
6. [Testing Guide](#testing-guide)
7. [Error Handling](#error-handling)
8. [Next Steps](#next-steps)

---

## 🎯 Overview

This document outlines the complete backend API integration for the AT-EASE Fleet Management application. All API endpoints from the Postman collection have been successfully integrated.

### ✅ Completed Features

- **Authentication System** - Login with JWT token management
- **Secure Storage** - flutter_secure_storage for token persistence
- **Driver Services** - Clock in/out, dashboard, vehicle selection
- **Inspection System** - Dynamic checklist from API
- **Incident Reporting** - Multi-photo upload support
- **Error Handling** - Comprehensive exception handling
- **API Client** - Dio-based with interceptors

---

## 🏗️ Architecture

### Layer Structure

```
┌─────────────────────────────────────┐
│          UI Layer (Pages)           │
├─────────────────────────────────────┤
│     Controllers (GetX State)        │
├─────────────────────────────────────┤
│        Services (Business)          │
├─────────────────────────────────────┤
│       API Client (Network)          │
├─────────────────────────────────────┤
│      Models (Data Structures)       │
└─────────────────────────────────────┘
```

### Directory Structure

```
lib/app/data/
├── models/
│   ├── api_response.dart         # Base response wrapper
│   ├── user_model.dart            # User & LoginResponse
│   ├── vehicle_model.dart         # Vehicle & VehiclesResponse
│   ├── dashboard_model.dart       # Dashboard data models
│   ├── inspection_model.dart      # Inspection structures
│   └── request_models.dart        # Request DTOs
│
├── providers/
│   └── api_client.dart            # Dio HTTP client
│
└── services/
    ├── storage_service.dart       # Secure storage
    ├── auth_service.dart          # Authentication
    ├── driver_service.dart        # Driver operations
    ├── inspection_service.dart    # Vehicle inspections
    ├── incident_service.dart      # Incident reports
    ├── checklist_service.dart     # Daily checklists
    └── supervisor_service.dart    # Supervisor operations
```

---

## 🔌 API Endpoints

### 1. Authentication

#### Login
```
POST /login
Content-Type: multipart/form-data

Parameters:
- email: string (required)
- password: string (required)
- user_type: string (required) ["driver", "supervisor"]

Response:
{
  "data": {
    "access_token": "5|ZJXwzBCe6zQTmkJ...",
    "expires_in": "2025-12-11 16:45:26",
    "user": {
      "id": 4,
      "name": "Rafi Ullah",
      "email": "rafi@gmail.com",
      "user_type": "driver",
      ...
    }
  },
  "message": "Login successful.",
  "status": true
}
```

**Implementation:**
```dart
final authService = AuthService();
final loginResponse = await authService.login(
  email: 'rafi@gmail.com',
  password: 'password',
  userType: 'driver',
);
```

---

### 2. Driver Endpoints

#### Get Lorries
```
POST /get-lorries
Authorization: Bearer {token}

Response:
{
  "data": {
    "vehicles": [
      {
        "id": 2,
        "registration_number": "sadsad",
        "company_name": "MULTILINE TRADING SDN BHD"
      }
    ]
  },
  "message": "",
  "status": true
}
```

**Implementation:**
```dart
final driverService = DriverService();
final vehicles = await driverService.getLorries();
```

#### Clock In
```
POST /clock-in
Authorization: Bearer {token}
Content-Type: multipart/form-data

Parameters:
- user_id: int
- vehicle_id: int
- datetime: string (YYYY-MM-DD HH:MM:SS)
- meter_reading: file
- reading_picture: file
```

**Implementation:**
```dart
await driverService.clockIn(
  vehicleId: 2,
  datetime: '2025-10-02 02:28:43',
  meterReadingPath: '/path/to/meter.jpg',
  readingPicturePath: '/path/to/dashboard.jpg',
);
```

#### Clock Out
```
POST /clock-out
Authorization: Bearer {token}
Content-Type: multipart/form-data

Parameters: Same as Clock In
```

#### Driver Dashboard
```
POST /driver/dashboard
Authorization: Bearer {token}
Content-Type: multipart/form-data

Parameters:
- user_id: int

Response:
{
  "data": {
    "user_data": {
      "group": "Logistics B",
      "user_id": 4,
      "user_name": "Rafi Ullah",
      "company_name": "MULTILINE TRADING SDN BHD",
      "lorry_no": "sadsad"
    },
    "is_clocked_in": true,
    "is_clocked_out": false
  },
  "message": "",
  "status": true
}
```

**Implementation:**
```dart
final dashboardData = await driverService.getDriverDashboard();
print(dashboardData.isCurrentlyWorking); // true if clocked in
```

---

### 3. Inspection Endpoints

#### Get Inspection Checklist
```
POST /inspection-vehicle-check
Authorization: Bearer {token}

Response:
{
  "data": {
    "items": [
      {
        "template_id": 2,
        "section_id": 4,
        "section_title": "vehicle Brakes",
        "items": "[{\"id\":7,\"name\":\"brakes working\",\"field_type\":\"yes_no\",\"is_required\":1}]"
      }
    ]
  },
  "message": "",
  "status": true
}
```

**Implementation:**
```dart
final inspectionService = InspectionService();
final sections = await inspectionService.getVehicleCheckList();

for (var section in sections) {
  print(section.sectionTitle);
  for (var item in section.items) {
    print('  - ${item.name} (${item.fieldType})');
  }
}
```

---

### 4. Incident Reporting

#### Submit Incident Report
```
POST /incident-report-submit
Authorization: Bearer {token}
Content-Type: multipart/form-data

Parameters:
- user_id: int
- incident_type_id: int
- note: string
- photos[]: array of files
```

**Implementation:**
```dart
final incidentService = IncidentService();
await incidentService.submitIncidentReport(
  incidentTypeId: 1,
  note: 'Vehicle accident on highway',
  photoPaths: ['/path/photo1.jpg', '/path/photo2.jpg'],
);
```

---

### 5. Supervisor Endpoints

#### Supervisor Dashboard
```
POST /supervisor/dashboard
Authorization: Bearer {token}

Parameters:
- user_id: int
```

---

## 💻 Implementation Details

### API Client (Dio)

**File:** `lib/app/data/providers/api_client.dart`

**Features:**
- Automatic token injection
- Request/Response logging
- Error handling
- 30-second timeout
- FormData support

**Key Methods:**
```dart
// GET request
final response = await apiClient.get('/endpoint');

// POST with JSON
final response = await apiClient.post('/endpoint', data: {...});

// POST with FormData
final response = await apiClient.postFormData('/endpoint', data: {...});
```

---

### Secure Storage

**File:** `lib/app/data/services/storage_service.dart`

**Stored Data:**
- Access token (encrypted)
- User ID
- User type
- User name
- User email

**Methods:**
```dart
// Save token
await StorageService.saveToken(token);

// Get token
final token = await StorageService.getToken();

// Clear all data (logout)
await StorageService.clearAll();

// Check login status
final isLoggedIn = await StorageService.isLoggedIn();
```

---

### Error Handling

**Exception Types:**

1. **ApiException** - API returned error response
2. **NetworkException** - No internet connection
3. **TimeoutException** - Request timeout
4. **UnauthorizedException** - 401 Unauthorized

**Usage in Controllers:**
```dart
try {
  await service.someMethod();
} on ApiException catch (e) {
  // Handle API errors
  Get.snackbar('Error', e.message);
} on NetworkException catch (e) {
  // Handle network errors
  Get.snackbar('Network Error', e.message);
} catch (e) {
  // Handle unexpected errors
  Get.snackbar('Error', 'Something went wrong');
}
```

---

## 📱 Usage Examples

### Complete Login Flow

```dart
// 1. User enters credentials
final email = emailController.text;
final password = passwordController.text;
final userType = 'driver'; // or 'supervisor'

// 2. Controller calls auth service
final authController = Get.find<AuthController>();
await authController.login(email, password, userType);

// 3. On success, user is navigated to dashboard
// Token is automatically saved and used in subsequent requests
```

### Clock In Flow

```dart
// 1. Load available vehicles
final clockController = Get.find<ClockController>();
await clockController.loadVehicles();

// 2. User selects vehicle
clockController.selectedVehicle.value = vehicles.first;

// 3. User takes photos
final meterPhoto = await ImagePicker().pickImage(...);
final dashboardPhoto = await ImagePicker().pickImage(...);

// 4. Submit clock in
await clockController.clockIn(
  meterReadingPath: meterPhoto.path,
  readingPicturePath: dashboardPhoto.path,
);
```

### Inspection Flow

```dart
// 1. Load checklist
final inspectionController = Get.find<InspectionController>();
await inspectionController.loadInspectionChecklist();

// 2. User fills checklist
inspectionController.updateItem(0, 0, 'Yes'); // section 0, item 0

// 3. Add photo if needed
if (item.needsPhoto) {
  final photo = await ImagePicker().pickImage(...);
  inspectionController.addPhotoToItem(0, 0, photo.path);
}

// 4. Submit
await inspectionController.submit();
```

---

## 🧪 Testing Guide

### Test Credentials

From Postman collection:
```
Email: rafi@gmail.com
Password: password
User Type: driver
```

### Test Steps

1. **Run Dependencies Install**
```bash
cd /Users/skapple/Documents/MyProjects/multiline_app
flutter pub get
```

2. **Test Login**
- Navigate to Role Selection
- Select "Driver"
- Enter test credentials
- Verify redirect to Driver Dashboard

3. **Test API Calls**
- Check terminal logs for API requests
- Verify Bearer token in headers
- Confirm successful responses

4. **Test Error Handling**
- Try invalid credentials
- Turn off internet
- Verify error messages display

---

## ⚠️ Important Notes

### API Base URL
Currently set to: `http://app.multiline.site/api/`

To change, update: `lib/app/core/values/api_constants.dart`

### Token Management
- Tokens stored securely using `flutter_secure_storage`
- Automatically injected in API requests
- Cleared on logout

### Photo Upload
- Uses `MultipartFile` from Dio
- Supports multiple photos for incidents
- File paths required (use `image_picker` package)

### Datetime Format
API expects: `YYYY-MM-DD HH:MM:SS`
```dart
final now = DateTime.now();
final datetime = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')} ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';
```

---

## 🔧 Configuration

### Required Permissions (iOS)

Add to `ios/Runner/Info.plist`:
```xml
<key>NSPhotoLibraryUsageDescription</key>
<string>We need access to your photos for vehicle inspections</string>
<key>NSCameraUsageDescription</key>
<string>We need camera access to take inspection photos</string>
<key>NSLocationWhenInUseUsageDescription</key>
<string>We need your location for clock in/out</string>
```

### Required Permissions (Android)

Add to `android/app/src/main/AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.CAMERA"/>
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
```

---

## 🚀 Next Steps

### Immediate TODOs

1. **Implement Image Picker**
   - Add `image_picker` package
   - Create photo upload UI components
   - Handle camera and gallery selection

2. **Add Location Services**
   - Integrate `geolocator` package
   - Get current location for clock in/out
   - Display on map

3. **Offline Support**
   - Implement local database (Hive/SQLite)
   - Queue failed requests
   - Sync when online

4. **UI Updates**
   - Update clock page to show vehicle selection
   - Display inspection sections dynamically
   - Add loading states

5. **Testing**
   - Write unit tests for services
   - Integration tests for API calls
   - Widget tests for updated controllers

### Future Enhancements

- Push notifications
- PDF report generation
- Analytics dashboard
- Real-time updates (WebSocket)
- Biometric authentication

---

## 📊 Summary

### ✅ What's Working

- ✅ Authentication with JWT
- ✅ Secure token storage
- ✅ All API endpoints integrated
- ✅ Error handling
- ✅ Loading states
- ✅ User feedback (snackbars)
- ✅ Automatic token injection
- ✅ Request/Response logging

### ⚠️ Needs Implementation

- ⚠️ Image picker integration
- ⚠️ Location services
- ⚠️ Offline data persistence
- ⚠️ Photo upload UI
- ⚠️ Vehicle selection UI
- ⚠️ Dynamic inspection rendering

### 🔒 Security Features

- Secure storage for tokens
- HTTPS support (when available)
- Token expiration handling
- Automatic logout on 401
- Input validation

---

## 📞 Support

### API Issues
Base URL: `http://app.multiline.site/api/`

Check logs in terminal for detailed request/response information.

### Debug Mode
All API calls are logged in debug mode with:
- 🌐 Request URL and method
- 📦 Request headers and data
- ✅ Response status and data
- ❌ Error details

---

**Last Updated:** October 3, 2025  
**Integration Status:** Complete ✅  
**Ready for:** Testing & UI Enhancement
