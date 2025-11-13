import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/services/auth_service.dart';
import '../../data/services/storage_service.dart';
import '../../data/services/biometric_service.dart';
import '../../data/services/app_lock_service.dart';
import '../../data/models/user_model.dart' as user_model;
import '../../data/models/api_response.dart';
import '../../routes/app_routes.dart';

class AuthController extends GetxController {
  final AuthService _authService = AuthService();
  final BiometricService _biometricService = BiometricService();

  final isLoading = false.obs;
  final currentUser = Rxn<user_model.User>();
  final userRole = ''.obs; // 'driver' or 'supervisor'
  final errorMessage = ''.obs;
  final isBiometricAvailable = false.obs;
  final isBiometricEnabled = false.obs;

  @override
  void onInit() {
    super.onInit();
    checkAuthStatus();
    checkBiometricAvailability();
  }

  /// Check if biometric authentication is available on device
  Future<void> checkBiometricAvailability() async {
    try {
      isBiometricAvailable.value = await _biometricService
          .isBiometricAvailable();
      isBiometricEnabled.value = await StorageService.getBiometricEnabled();
    } catch (e) {
      print('Error checking biometric availability: $e');
      isBiometricAvailable.value = false;
      isBiometricEnabled.value = false;
    }
  }

  /// Check if biometric is enabled for a specific role
  Future<bool> isBiometricEnabledForRole(String role) async {
    try {
      final credentials = await StorageService.getBiometricCredentials();
      if (credentials == null) return false;
      return credentials['userType'] == role;
    } catch (e) {
      print('Error checking biometric for role: $e');
      return false;
    }
  }

  /// Login with email, password, and user type
  Future<void> login(
    String email,
    String password,
    String userType, {
    bool rememberMe = false,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final loginResponse = await _authService.login(
        email: email,
        password: password,
        userType: userType,
      );

      currentUser.value = loginResponse.user;
      userRole.value = loginResponse.user.userType;

      // Save remember me preference and credentials if enabled
      if (rememberMe) {
        await StorageService.saveRememberMeCredentials(
          email: email,
          password: password,
          userType: userType,
        );
      } else {
        await StorageService.saveRememberMe(false);
      }

      // Navigate to appropriate dashboard
      if (loginResponse.user.isDriver) {
        Get.offAllNamed(AppRoutes.driverDashboard);
      } else if (loginResponse.user.isSupervisor) {
        Get.offAllNamed(AppRoutes.supervisorDashboard);
      }

      Get.snackbar(
        'Success',
        'Welcome back, ${loginResponse.user.name}! (${loginResponse.user.preferredIdentifier})',
        snackPosition: SnackPosition.BOTTOM,
      );
    } on ApiException catch (e) {
      errorMessage.value = e.message;

      // Determine the title based on error content
      String title = 'Login Failed';
      if (e.message.toLowerCase().contains('server') &&
          (e.message.toLowerCase().contains('storage') ||
              e.message.toLowerCase().contains('space'))) {
        title = 'Server Error';
      }

      Get.snackbar(
        title,
        e.message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
        duration: const Duration(seconds: 5),
      );
    } on NetworkException catch (e) {
      errorMessage.value = e.message;
      Get.snackbar(
        'Network Error',
        e.message,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 4),
      );
    } catch (e) {
      errorMessage.value = 'An unexpected error occurred';
      Get.snackbar(
        'Error',
        'An unexpected error occurred. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Logout
  Future<void> logout() async {
    try {
      isLoading.value = true;
      await _authService.logout();
      // DON'T clear remember me - it's preserved in auth_service.logout()
      // DON'T clear biometric data on logout - keep it enabled
      // await StorageService.clearBiometricData();
      currentUser.value = null;
      userRole.value = '';
      // Keep isBiometricEnabled as is - don't reset
      Get.offAllNamed(AppRoutes.roleSelection);

      Get.snackbar(
        'Logged Out',
        'You have been logged out successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to logout',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Login with biometric authentication
  Future<void> loginWithBiometric() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      // Check if biometric is enabled
      final biometricEnabled = await StorageService.getBiometricEnabled();
      if (!biometricEnabled) {
        throw Exception('Biometric login is not enabled');
      }

      // Authenticate with biometric
      final authenticated = await _biometricService.authenticate(
        reason: 'Authenticate to login to AT-EASE Fleet Management',
      );

      if (!authenticated) {
        throw Exception('Biometric authentication failed');
      }

      // Get saved credentials
      final credentials = await StorageService.getBiometricCredentials();
      if (credentials == null) {
        throw Exception('No saved credentials found');
      }

      // Login with saved credentials
      final loginResponse = await _authService.login(
        email: credentials['email']!, // stored identifier (may be email or ID)
        password: credentials['password']!,
        userType: credentials['userType']!,
      );

      currentUser.value = loginResponse.user;
      userRole.value = loginResponse.user.userType;

      // Navigate to appropriate dashboard
      if (loginResponse.user.isDriver) {
        Get.offAllNamed(AppRoutes.driverDashboard);
      } else if (loginResponse.user.isSupervisor) {
        Get.offAllNamed(AppRoutes.supervisorDashboard);
      }

      Get.snackbar(
        'Success',
        'Welcome back, ${loginResponse.user.name}! (${loginResponse.user.preferredIdentifier})',
        snackPosition: SnackPosition.BOTTOM,
      );
    } on ApiException catch (e) {
      errorMessage.value = e.message;
      Get.snackbar(
        'Login Failed',
        e.message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
        duration: const Duration(seconds: 5),
      );
    } on NetworkException catch (e) {
      errorMessage.value = e.message;
      Get.snackbar(
        'Network Error',
        e.message,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 4),
      );
    } catch (e) {
      errorMessage.value = e.toString();
      Get.snackbar(
        'Authentication Failed',
        e.toString().replaceAll('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Login with device lock (fingerprint/PIN/password/pattern)
  /// This allows quick login using any device security method
  Future<void> loginWithDeviceLock() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      print('🔐 Starting device lock login...');

      // Check if biometric/device lock is enabled
      final lockEnabled = await StorageService.getBiometricEnabled();
      if (!lockEnabled) {
        throw Exception('Device lock login is not enabled');
      }

      // Get saved user info for display
      final credentials = await StorageService.getBiometricCredentials();
      if (credentials == null) {
        throw Exception('No saved credentials found');
      }

      final userName = credentials['userName'] ?? 'User';

      // Authenticate with device lock (fingerprint/face/PIN/password/pattern)
      final authenticated = await _biometricService.authenticateForQuickLogin(
        userName: userName,
      );

      if (!authenticated) {
        throw Exception('Device lock authentication cancelled');
      }

      // Mark session as unlocked so app lock won't reappear during this session
      await AppLockService.clearBackgroundTime();

      print('✅ Device lock authentication successful, logging in...');

      // Login with saved credentials
      final loginResponse = await _authService.login(
        email: credentials['email']!, // stored identifier (may be email or ID)
        password: credentials['password']!,
        userType: credentials['userType']!,
      );

      currentUser.value = loginResponse.user;
      userRole.value = loginResponse.user.userType;

      print('✅ Login successful, navigating to dashboard...');

      // Navigate to appropriate dashboard
      if (loginResponse.user.isDriver) {
        Get.offAllNamed(AppRoutes.driverDashboard);
      } else if (loginResponse.user.isSupervisor) {
        Get.offAllNamed(AppRoutes.supervisorDashboard);
      }

      Get.snackbar(
        'Welcome Back!',
        'Logged in as ${loginResponse.user.name}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
    } on ApiException catch (e) {
      errorMessage.value = e.message;
      Get.snackbar(
        'Login Failed',
        e.message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
        duration: const Duration(seconds: 5),
      );
    } on NetworkException catch (e) {
      errorMessage.value = e.message;
      Get.snackbar(
        'Network Error',
        e.message,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 4),
      );
    } catch (e) {
      errorMessage.value = e.toString();
      print('❌ Device lock login error: $e');
      Get.snackbar(
        'Authentication Cancelled',
        e.toString().replaceAll('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Enable biometric authentication for current user
  Future<void> enableBiometric({
    required String email, // identifier used at login field (email/ID/phone)
    required String password,
    required String userType,
  }) async {
    try {
      // Check if biometric is available
      final available = await _biometricService.isBiometricAvailable();
      if (!available) {
        throw Exception(
          'Biometric authentication is not available on this device',
        );
      }

      // Authenticate with biometric to enable
      final authenticated = await _biometricService.authenticate(
        reason: 'Authenticate to enable biometric login',
      );

      if (!authenticated) {
        throw Exception('Biometric authentication failed');
      }

      // Save credentials securely
      await StorageService.saveBiometricCredentials(
        email: email, // store whatever identifier user typed
        password: password,
        userType: userType,
      );

      isBiometricEnabled.value = true;

      Get.snackbar(
        'Success',
        'Biometric login enabled successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString().replaceAll('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
      );
    }
  }

  /// Disable biometric authentication
  Future<void> disableBiometric() async {
    try {
      await StorageService.clearBiometricData();
      isBiometricEnabled.value = false;

      Get.snackbar(
        'Success',
        'Biometric login disabled',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to disable biometric login',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  /// Check authentication status
  Future<void> checkAuthStatus() async {
    try {
      final isLoggedIn = await _authService.isLoggedIn();

      if (isLoggedIn) {
        // Get user data from storage
        final userId = await _authService.getUserId();
        final userName = await _authService.getUserName();
        final userEmail = await _authService.getUserEmail();
        final userType = await _authService.getUserType();

        if (userId != null && userName != null && userEmail != null) {
          // Create a partial User object from stored data
          // Note: Full user object would require API call
          userRole.value = userType ?? '';
        }
      }
    } catch (e) {
      // If error, treat as logged out
      currentUser.value = null;
    }
  }

  /// Get current user ID
  Future<int?> getUserId() async {
    return await _authService.getUserId();
  }

  /// Get current user type
  Future<String?> getUserType() async {
    return await _authService.getUserType();
  }
}
