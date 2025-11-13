# Network Error Fix - Login Page

## Problem
When clicking the login button on a real Android device, the app shows "Network Error" even though WiFi and mobile data are enabled.

## Root Cause
The API is using **HTTP** (`http://app.multiline.site/api/`) instead of **HTTPS**. Starting from Android 9 (API level 28), cleartext (HTTP) traffic is **blocked by default** for security reasons. This prevents the app from making HTTP requests to the server.

## Solution Applied

### 1. Network Security Configuration
Created a new file to allow HTTP traffic for the specific domain:

**File**: `android/app/src/main/res/xml/network_security_config.xml`
```xml
<?xml version="1.0" encoding="utf-8"?>
<network-security-config>
    <!-- Allow cleartext traffic for specific domain -->
    <domain-config cleartextTrafficPermitted="true">
        <domain includeSubdomains="true">app.multiline.site</domain>
    </domain-config>
    
    <!-- For development/testing, allow all cleartext traffic -->
    <base-config cleartextTrafficPermitted="true">
        <trust-anchors>
            <certificates src="system" />
        </trust-anchors>
    </base-config>
</network-security-config>
```

### 2. Android Manifest Updates
Updated `android/app/src/main/AndroidManifest.xml` with:

1. **Added Internet Permissions** (explicit):
```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
```

2. **Enabled Cleartext Traffic** in application tag:
```xml
<application
    android:label="multiline_app"
    android:name="${applicationName}"
    android:icon="@mipmap/ic_launcher"
    android:networkSecurityConfig="@xml/network_security_config"
    android:usesCleartextTraffic="true">
```

### 3. Improved Error Messages
Enhanced the API client error handling to provide more specific error messages for network issues, including cleartext traffic errors.

## Testing
After building and installing the new APK:
1. Open the app on your Android device
2. Navigate to the login page
3. Enter credentials and click login
4. The app should now successfully connect to the HTTP API

## Important Notes

### Security Considerations
- **HTTP is not secure** - data is transmitted in plain text
- This fix is acceptable for **development/testing** environments
- **For production**, the backend should use **HTTPS** instead

### Recommended Long-term Solution
1. Update the backend server to support HTTPS
2. Get a valid SSL certificate for `app.multiline.site`
3. Update `lib/app/core/values/api_constants.dart`:
   ```dart
   static const String baseUrl = 'https://app.multiline.site/api/';
   ```
4. Remove cleartext traffic permissions from AndroidManifest.xml

## Build Instructions
```bash
# Clean build cache
flutter clean

# Build release APK (use --no-tree-shake-icons to avoid IconData errors)
flutter build apk --release --no-tree-shake-icons

# Install on connected device
flutter install --release
```

## Files Modified
1. ✅ `android/app/src/main/res/xml/network_security_config.xml` (created)
2. ✅ `android/app/src/main/AndroidManifest.xml` (updated)
3. ✅ `lib/app/data/providers/api_client.dart` (improved error handling)

## Troubleshooting
If the issue persists:
1. Ensure you've uninstalled the old app version
2. Install the new APK
3. Check Logcat for detailed error messages
4. Verify the server at `http://app.multiline.site/api/` is accessible from your device's browser

---
**Date**: 5 October 2025
**Status**: ✅ Fixed and Ready for Testing
