import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth/error_codes.dart' as auth_error;

/// Service to handle biometric authentication
class BiometricService {
  final LocalAuthentication _localAuth = LocalAuthentication();

  /// Check if device supports biometric authentication
  Future<bool> isDeviceSupported() async {
    try {
      return await _localAuth.isDeviceSupported();
    } catch (e) {
      print('Error checking device support: $e');
      return false;
    }
  }

  /// Check if biometric authentication is available
  /// Returns true if device supports and has enrolled biometrics
  Future<bool> isBiometricAvailable() async {
    try {
      // First check if device hardware supports biometrics
      final isSupported = await isDeviceSupported();
      print('🔍 BiometricService - isDeviceSupported: $isSupported');
      if (!isSupported) {
        print('❌ Device does not support biometric authentication');
        return false;
      }

      // Check if we can check biometrics (may fail on some devices)
      final canCheckBiometrics = await _localAuth.canCheckBiometrics;
      print('🔍 BiometricService - canCheckBiometrics: $canCheckBiometrics');

      // Get available biometric types
      final availableBiometrics = await _localAuth.getAvailableBiometrics();
      print('🔍 BiometricService - availableBiometrics: $availableBiometrics');

      // More lenient check: If device is supported and has biometrics enrolled,
      // allow it even if canCheckBiometrics is false (some Android devices)
      if (availableBiometrics.isNotEmpty) {
        print('✅ Biometric is available with types: $availableBiometrics');
        return true;
      }

      // If no biometrics enrolled, return false
      print('⚠️ No biometrics enrolled on device');
      return false;
    } catch (e) {
      print('❌ Error checking biometric availability: $e');
      return false;
    }
  }

  /// Get list of available biometric types
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } catch (e) {
      print('Error getting available biometrics: $e');
      return [];
    }
  }

  /// Authenticate user with biometric
  /// Returns true if authentication successful
  Future<bool> authenticate({
    String reason = 'Please authenticate to login',
  }) async {
    try {
      final isAvailable = await isBiometricAvailable();
      if (!isAvailable) {
        throw Exception(
          'Biometric authentication is not available on this device',
        );
      }

      final authenticated = await _localAuth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          stickyAuth: true, // Keep auth dialog until user cancels or succeeds
          biometricOnly: true, // Don't allow device PIN as fallback
        ),
      );

      return authenticated;
    } on PlatformException catch (e) {
      print('Biometric authentication error: ${e.code} - ${e.message}');

      // Handle specific error codes
      if (e.code == auth_error.notAvailable) {
        throw Exception('Biometric authentication is not available');
      } else if (e.code == auth_error.notEnrolled) {
        throw Exception('No biometric credentials enrolled');
      } else if (e.code == auth_error.passcodeNotSet) {
        throw Exception('Device passcode not set');
      } else if (e.code == auth_error.lockedOut) {
        throw Exception('Too many attempts. Biometric authentication locked');
      } else if (e.code == auth_error.permanentlyLockedOut) {
        throw Exception('Biometric authentication permanently locked');
      }

      return false;
    } catch (e) {
      print('Unexpected authentication error: $e');
      rethrow;
    }
  }

  /// Authenticate with option to use device credentials (PIN/Pattern) as fallback
  Future<bool> authenticateWithDeviceCredentials({
    String reason = 'Please authenticate to login',
  }) async {
    try {
      final authenticated = await _localAuth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false, // Allow PIN/Pattern as fallback
        ),
      );

      return authenticated;
    } on PlatformException catch (e) {
      print('Authentication error: ${e.code} - ${e.message}');
      return false;
    } catch (e) {
      print('Unexpected authentication error: $e');
      return false;
    }
  }

  /// Authenticate for app lock (supports both biometric and device credentials)
  /// This is similar to WhatsApp's app lock behavior
  /// Also used for quick login with device lock
  Future<bool> authenticateForAppLock() async {
    try {
      print('🔐 Authenticating with device lock...');

      // Use device credentials (allows biometric OR PIN/pattern/password)
      final authenticated = await _localAuth.authenticate(
        localizedReason: 'Unlock to continue',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false, // Allow device PIN/pattern/password
          useErrorDialogs: true, // Show error dialogs
        ),
      );

      if (authenticated) {
        print('✅ Device lock authentication successful');
      } else {
        print('❌ Device lock authentication failed');
      }

      return authenticated;
    } on PlatformException catch (e) {
      print('❌ Device lock authentication error: ${e.code} - ${e.message}');

      // Handle cancellation gracefully
      if (e.code == 'NotAvailable' || e.code == 'PasscodeNotSet') {
        // If no security is set up, allow access
        print('⚠️ No device security set up, allowing access');
        return true;
      }

      return false;
    } catch (e) {
      print('❌ Unexpected device lock authentication error: $e');
      return false;
    }
  }

  /// Authenticate with device lock for quick login
  /// Shows custom message for login context
  Future<bool> authenticateForQuickLogin({String userName = ''}) async {
    try {
      print('🔐 Authenticating for quick login...');

      final message = userName.isNotEmpty
          ? 'Login as $userName'
          : 'Authenticate to login';

      // Use device credentials (allows biometric OR PIN/pattern/password)
      final authenticated = await _localAuth.authenticate(
        localizedReason: message,
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false, // Allow device PIN/pattern/password
          useErrorDialogs: true, // Show error dialogs
        ),
      );

      if (authenticated) {
        print('✅ Quick login authentication successful');
      } else {
        print('❌ Quick login authentication failed');
      }

      return authenticated;
    } on PlatformException catch (e) {
      print('❌ Quick login authentication error: ${e.code} - ${e.message}');
      return false;
    } catch (e) {
      print('❌ Unexpected quick login authentication error: $e');
      return false;
    }
  }

  /// Stop biometric authentication
  Future<void> stopAuthentication() async {
    try {
      await _localAuth.stopAuthentication();
    } catch (e) {
      print('Error stopping authentication: $e');
    }
  }

  /// Get user-friendly biometric type name
  String getBiometricTypeName(List<BiometricType> biometrics) {
    if (biometrics.isEmpty) return 'Biometric';

    if (biometrics.contains(BiometricType.face)) {
      return 'Face ID';
    } else if (biometrics.contains(BiometricType.fingerprint)) {
      return 'Fingerprint';
    } else if (biometrics.contains(BiometricType.iris)) {
      return 'Iris';
    } else if (biometrics.contains(BiometricType.strong)) {
      return 'Biometric';
    } else if (biometrics.contains(BiometricType.weak)) {
      return 'Biometric';
    }

    return 'Biometric';
  }
}
