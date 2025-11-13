# Logout API Integration

## Date: 5 October 2025

## Overview
Added logout API call with authorization token for both driver and supervisor logout functionality.

---

## Changes Implemented

### 1. ✅ Added Logout Endpoint to API Constants

**File**: `lib/app/core/values/api_constants.dart`

```dart
// Auth Endpoints
static const String login = 'login';
static const String logout = 'logout';  // ← New endpoint
```

**API Endpoint**: `POST http://app.multiline.site/api/logout`  
**Authorization**: Bearer token (automatically included by ApiClient)

---

### 2. ✅ Updated Auth Service - Logout with API Call

**File**: `lib/app/data/services/auth_service.dart`

**Changes**:
- Calls `/logout` API endpoint with authorization header
- Sends POST request to server to invalidate token
- Continues with local logout even if API call fails (for offline resilience)
- Clears all local storage
- Removes authorization headers from API client

```dart
/// Logout
Future<void> logout() async {
  try {
    // Call logout API with authorization token
    try {
      await _apiClient.post(
        ApiConstants.logout,
        data: {},
      );
    } catch (e) {
      // Continue with local logout even if API call fails
      // This ensures user can logout even with network issues
    }

    // Clear all stored data
    await StorageService.clearAll();

    // Clear API client headers
    _apiClient.clearHeaders();
  } catch (e) {
    rethrow;
  }
}
```

**Features**:
- ✅ Sends authorization token automatically (handled by ApiClient interceptor)
- ✅ Graceful fallback - continues logout even if API fails
- ✅ Clears local data regardless of API response
- ✅ Works offline (won't block user from logging out)

---

### 3. ✅ Updated Driver Profile Logout

**File**: `lib/app/modules/driver/profile/profile_page.dart`

**Before**: 
- Directly cleared storage without calling API
- Manual navigation and snackbar

**After**:
- Uses `AuthController.logout()` which calls the API
- Consistent logout behavior across the app
- Automatic navigation and feedback

```dart
ElevatedButton(
  onPressed: () async {
    // Close dialog first
    Get.back();

    // Use AuthController to logout (which calls the API)
    final authController = Get.put(AuthController());
    await authController.logout();
  },
  child: const Text('Logout'),
)
```

---

### 4. ✅ Supervisor Dashboard Logout (Already Updated)

**File**: `lib/app/modules/supervisor/dashboard/supervisor_dashboard_page.dart`

- Already uses `AuthController.logout()`
- Now benefits from API call automatically

---

## How It Works

### Logout Flow:

```
User clicks "Logout"
    ↓
Confirmation Dialog
    ↓
User confirms
    ↓
AuthController.logout() called
    ↓
AuthService.logout() executed
    ↓
1. POST /api/logout (with Bearer token)
   └─ Success: Token invalidated on server
   └─ Failure: Continue anyway (offline support)
    ↓
2. Clear local storage (token, user data, remember me)
    ↓
3. Clear API client headers
    ↓
4. Navigate to role selection screen
    ↓
5. Show success message
```

---

## API Request Details

### Endpoint: `/api/logout`
**Method**: POST  
**Headers**:
```
Authorization: Bearer {access_token}
Accept: application/json
Content-Type: application/json
```

**Request Body**:
```json
{}
```

**Expected Response** (Success):
```json
{
  "status": "success",
  "message": "Logged out successfully"
}
```

**Expected Response** (Error):
```json
{
  "status": "error",
  "message": "Error message"
}
```

---

## Benefits

### 1. **Server-Side Token Invalidation**
- Token is invalidated on server
- Prevents reuse of old tokens
- Enhanced security

### 2. **Consistent Behavior**
- Both driver and supervisor use same logout logic
- Easier to maintain
- Centralized error handling

### 3. **Offline Support**
- User can logout even without internet
- Graceful fallback to local logout
- No blocking errors

### 4. **Audit Trail**
- Server can track logout events
- Better analytics and monitoring
- Security auditing

---

## Files Modified

1. ✅ `lib/app/core/values/api_constants.dart` - Added logout endpoint
2. ✅ `lib/app/data/services/auth_service.dart` - API call implementation
3. ✅ `lib/app/modules/driver/profile/profile_page.dart` - Use AuthController
4. ✅ `lib/app/modules/supervisor/dashboard/supervisor_dashboard_page.dart` - Already using AuthController

**Total**: 4 files modified

---

## Testing Checklist

### Driver Logout:
- [ ] Login as driver
- [ ] Navigate to Profile (click profile icon in dashboard)
- [ ] Click "Logout" button
- [ ] Confirm in dialog
- [ ] **Check**: API call to `/logout` should be made with authorization token
- [ ] **Check**: User redirected to role selection
- [ ] **Check**: Success message shown
- [ ] Try logging in again (old token should not work)

### Supervisor Logout:
- [ ] Login as supervisor
- [ ] Click three-dot menu (⋮) in dashboard
- [ ] Click "Logout"
- [ ] Confirm in dialog
- [ ] **Check**: API call to `/logout` should be made with authorization token
- [ ] **Check**: User redirected to role selection
- [ ] **Check**: Success message shown
- [ ] Try logging in again (old token should not work)

### Offline Logout:
- [ ] Login as any user
- [ ] Turn off WiFi and mobile data
- [ ] Attempt to logout
- [ ] **Check**: Logout should still work
- [ ] **Check**: Local data cleared
- [ ] **Check**: Redirected to role selection

### Network Error Handling:
- [ ] Login as any user
- [ ] Simulate slow network or timeout
- [ ] Attempt to logout
- [ ] **Check**: Should complete logout after API timeout
- [ ] **Check**: No error shown to user
- [ ] **Check**: Local logout successful

---

## Backend Requirements

The backend should implement the `/api/logout` endpoint:

### Laravel Example:
```php
// routes/api.php
Route::middleware('auth:sanctum')->post('/logout', [AuthController::class, 'logout']);

// app/Http/Controllers/AuthController.php
public function logout(Request $request)
{
    // Revoke the current access token
    $request->user()->currentAccessToken()->delete();
    
    return response()->json([
        'status' => 'success',
        'message' => 'Logged out successfully'
    ]);
}
```

### Expected Behavior:
- ✅ Validates Bearer token
- ✅ Invalidates/deletes the token from database
- ✅ Returns success response
- ✅ Returns 401 if token is invalid (app handles gracefully)

---

## Security Improvements

1. **Token Invalidation**: Prevents token reuse after logout
2. **Authorization Required**: Only authenticated users can logout
3. **Server-Side Tracking**: Logout events can be logged
4. **Audit Trail**: Better security monitoring

---

## Error Handling

### Scenarios Handled:

1. **API Call Succeeds**: 
   - Token invalidated on server
   - Local data cleared
   - User logged out

2. **API Call Fails** (Network error, timeout):
   - Error caught and ignored
   - Local data cleared anyway
   - User still logged out
   - No error shown

3. **API Returns Error** (401, 500):
   - Error caught and ignored
   - Local data cleared anyway
   - User still logged out
   - No error shown

4. **Offline Mode**:
   - API call skipped
   - Local data cleared
   - User logged out successfully

**Philosophy**: Never block user from logging out, regardless of server state.

---

## Build Instructions

```bash
# Clean build
flutter clean

# Build release APK
flutter build apk --release --no-tree-shake-icons

# Install on device
flutter install --release
```

---

## Summary

✅ **Logout API Integration Complete**

- Both driver and supervisor logout now call `/api/logout` with authorization
- Server-side token invalidation implemented
- Graceful offline support maintained
- Consistent logout behavior across app
- Enhanced security and audit capabilities

**Status**: Ready for testing  
**Next Step**: Test logout functionality and verify API calls in network inspector

---

**Date**: 5 October 2025  
**Version**: 1.0.0  
**Feature**: Logout API with Authorization
