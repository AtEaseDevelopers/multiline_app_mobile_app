# Quick Reference: Driver Reports Feature

## 🚀 Quick Start

### Access Reports
1. Open Driver Dashboard
2. Tap **"My Reports"** card (blue with assignment icon)
3. View list of monthly reports
4. Tap any report to view/download

## 📁 File Structure

```
lib/app/
├── data/
│   ├── models/
│   │   └── report_model.dart          # DriverReport, DriverReportsResponse
│   └── services/
│       └── report_service.dart        # API calls & download logic
├── modules/
│   └── reports/
│       ├── reports_page.dart          # List view
│       ├── reports_controller.dart    # List logic
│       ├── report_detail_page.dart    # PDF viewer + download
│       └── report_detail_controller.dart # Download logic
└── routes/
    ├── app_routes.dart                # Route constants
    └── app_pages.dart                 # Route definitions
```

## 🔄 Navigation Flow

```
┌─────────────────────────┐
│  Driver Dashboard       │
│  [My Reports Card]      │
└───────────┬─────────────┘
            │ Tap card
            ↓
┌─────────────────────────┐
│  Reports List Page      │
│  - October 2025 Report  │
│  - September 2025       │
│  - August 2025          │
└───────────┬─────────────┘
            │ Tap report
            ↓
┌─────────────────────────┐
│  Report Detail Page     │
│  [WebView PDF Viewer]   │
│  [Download Button]      │
└───────────┬─────────────┘
            │ Tap download
            ↓
┌─────────────────────────┐
│  Download Progress      │
│  [Progress Bar 75%]     │
└───────────┬─────────────┘
            │
            ↓
┌─────────────────────────┐
│  Success!               │
│  Saved to:              │
│  Download/AT-EASE Reports│
└─────────────────────────┘
```

## 🌐 API Endpoints

### List Reports
```
GET /api/drivers/4/reports
Authorization: Bearer {token}
```

### Download Report
```
GET /api/drivers/4/reports/driver_report_4_2025-10.pdf/download
Authorization: Bearer {token}
Accept: application/pdf
```

## 📱 Download Locations

**Android:**
```
/storage/emulated/0/Download/AT-EASE Reports/
```

**iOS:**
```
Documents/AT-EASE Reports/
```

## 🎨 UI Components

### Reports List Card
```
┌────────────────────────────────────┐
│ 📄  October 2025 Report      →    │
│     driver_report_4_2025-10.pdf    │
│     Oct 13, 2025                   │
└────────────────────────────────────┘
```

### Report Detail Page
```
┌────────────────────────────────────┐
│ ← October 2025 Report      [↓]    │ App Bar
├────────────────────────────────────┤
│                                    │
│     [PDF Content in WebView]       │
│                                    │
│                                    │
├────────────────────────────────────┤
│ ℹ️  driver_report_4_2025-10.pdf    │ Bottom Bar
│ ┌────────────────────────────────┐ │
│ │  Download to Device        [↓] │ │
│ └────────────────────────────────┘ │
└────────────────────────────────────┘
```

## 🔧 Key Functions

### ReportService
```dart
// Get reports list
final reports = await reportService.getDriverReports(driverId);

// Download report
final path = await reportService.downloadReport(
  driverId: 4,
  reportId: 1,
  fileName: 'driver_report_4_2025-10.pdf',
  downloadPath: '/path/to/save.pdf',
  onProgress: (received, total) {
    print('${(received / total * 100).toInt()}%');
  },
);
```

### Navigation
```dart
// From dashboard to reports list
Get.toNamed(AppRoutes.reports, arguments: driverId);

// From list to detail
Get.toNamed(AppRoutes.reportDetail, arguments: {
  'driverId': driverId,
  'report': report,
});
```

## ⚡ Features

### Reports List Page
- ✅ Professional card UI
- ✅ Pull-to-refresh
- ✅ Loading states
- ✅ Error handling
- ✅ Empty states
- ✅ Friendly date names

### Report Detail Page
- ✅ WebView PDF viewer
- ✅ Download button
- ✅ Progress tracking
- ✅ Permission handling
- ✅ Overwrite detection
- ✅ Success notifications

## 🐛 Common Issues & Solutions

### Issue: "Permission Denied"
**Solution:** App will automatically request storage permission on Android < 13

### Issue: "File already exists"
**Solution:** App shows confirmation dialog to overwrite or cancel

### Issue: "PDF not loading"
**Solution:** Check internet connection and authorization token

### Issue: "Download fails"
**Solution:** Check storage space and permissions

## 📊 State Management

### Reports List
```dart
isLoading.value = true;     // Show loading indicator
reports.value = [];         // List of reports
errorMessage.value = '';    // Error text if failed
```

### Download
```dart
isDownloading.value = true;      // Show downloading state
downloadProgress.value = 0.75;   // Progress 0.0 to 1.0
downloadedFilePath.value = '';   // Path when complete
```

## 🎯 Testing Commands

```bash
# Run the app
flutter run

# Build for release
flutter build apk --release        # Android
flutter build ios --release        # iOS

# Check dependencies
flutter pub get

# Analyze code
flutter analyze

# Format code
flutter format lib/
```

## 📝 Model Structure

### DriverReport
```dart
{
  id: 4,
  fileName: "driver_report_4_2025-10.pdf",
  formattedDate: "2025-10",
  friendlyName: "October 2025 Report",  // Computed
  createdAt: DateTime
}
```

### API Response
```json
{
  "data": [
    {
      "id": 4,
      "file_name": "driver_report_4_2025-10.pdf",
      "formatted_date": "2025-10",
      "created_at": "2025-10-13T00:00:00.000000Z"
    }
  ],
  "message": "Reports retrieved successfully",
  "status": true
}
```

## 🎨 Color Scheme
- Primary Color: `AppColors.brandBlue`
- PDF Icon Background: `brandBlue.withOpacity(0.1)`
- Success: `Colors.green`
- Error: `Colors.red`

## 📦 Dependencies Required

```yaml
webview_flutter: ^4.4.2      # PDF viewing
path_provider: ^2.1.1         # File paths
permission_handler: ^11.2.0   # Permissions (already installed)
http: ^1.2.0                  # Downloads (already installed)
```

## 🚀 Ready to Test!

Everything is implemented and wired up. Just:
1. Run `flutter run`
2. Login as a driver
3. Tap "My Reports" on dashboard
4. Enjoy viewing and downloading reports! 📄

---

**Status:** ✅ Complete - Ready for Testing
**Created:** October 20, 2025
