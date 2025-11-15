import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class StorageService {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );

  // Keys
  static const String _tokenKey = 'access_token';
  static const String _userIdKey = 'user_id';
  static const String _userTypeKey = 'user_type';
  static const String _userNameKey = 'user_name';
  static const String _userEmailKey = 'user_email';
  static const String _rememberMeKey = 'remember_me';
  static const String _rememberMeEmailKey = 'remember_me_email';
  static const String _rememberMePasswordKey = 'remember_me_password';
  static const String _rememberMeUserTypeKey = 'remember_me_user_type';
  static const String _biometricEnabledKey = 'biometric_enabled';
  static const String _biometricEmailKey =
      'biometric_email'; // stores generic identifier (email/ID/phone)
  static const String _biometricPasswordKey = 'biometric_password';
  static const String _biometricUserTypeKey = 'biometric_user_type';
  static const String _localeKey = 'app_locale';

  // Token Management
  static Future<void> saveToken(String token) async {
    try {
      await _storage.write(key: _tokenKey, value: token);
    } catch (e) {
      print('Error saving token: $e');
      rethrow;
    }
  }

  static Future<String?> getToken() async {
    try {
      return await _storage.read(key: _tokenKey);
    } catch (e) {
      print('Error reading token: $e');
      return null;
    }
  }

  static Future<void> deleteToken() async {
    try {
      await _storage.delete(key: _tokenKey);
    } catch (e) {
      print('Error deleting token: $e');
    }
  }

  // User Data Management
  static Future<void> saveUserId(int userId) async {
    try {
      await _storage.write(key: _userIdKey, value: userId.toString());
    } catch (e) {
      print('Error saving user ID: $e');
      rethrow;
    }
  }

  static Future<int?> getUserId() async {
    try {
      final id = await _storage.read(key: _userIdKey);
      return id != null ? int.tryParse(id) : null;
    } catch (e) {
      print('Error reading user ID: $e');
      return null;
    }
  }

  static Future<void> saveUserType(String userType) async {
    try {
      await _storage.write(key: _userTypeKey, value: userType);
    } catch (e) {
      print('Error saving user type: $e');
      rethrow;
    }
  }

  static Future<String?> getUserType() async {
    try {
      return await _storage.read(key: _userTypeKey);
    } catch (e) {
      print('Error reading user type: $e');
      return null;
    }
  }

  static Future<void> saveUserName(String name) async {
    try {
      await _storage.write(key: _userNameKey, value: name);
    } catch (e) {
      print('Error saving user name: $e');
      rethrow;
    }
  }

  static Future<String?> getUserName() async {
    try {
      return await _storage.read(key: _userNameKey);
    } catch (e) {
      print('Error reading user name: $e');
      return null;
    }
  }

  static Future<void> saveUserEmail(String email) async {
    try {
      await _storage.write(key: _userEmailKey, value: email);
    } catch (e) {
      print('Error saving user email: $e');
      rethrow;
    }
  }

  static Future<String?> getUserEmail() async {
    try {
      return await _storage.read(key: _userEmailKey);
    } catch (e) {
      print('Error reading user email: $e');
      return null;
    }
  }

  // Clear All Data
  static Future<void> clearAll() async {
    try {
      await _storage.deleteAll();
    } catch (e) {
      print('Error clearing all data: $e');
    }
  }

  // Check if user is logged in
  static Future<bool> isLoggedIn() async {
    try {
      final token = await getToken();
      return token != null && token.isNotEmpty;
    } catch (e) {
      print('Error checking login status: $e');
      return false;
    }
  }

  // Remember Me Management
  static Future<void> saveRememberMe(bool rememberMe) async {
    try {
      await _storage.write(key: _rememberMeKey, value: rememberMe.toString());
    } catch (e) {
      print('Error saving remember me: $e');
      rethrow;
    }
  }

  static Future<bool> getRememberMe() async {
    try {
      final rememberMe = await _storage.read(key: _rememberMeKey);
      return rememberMe == 'true';
    } catch (e) {
      print('Error reading remember me: $e');
      return false;
    }
  }

  static Future<void> clearRememberMe() async {
    try {
      await _storage.delete(key: _rememberMeKey);
      await _storage.delete(key: _rememberMeEmailKey);
      await _storage.delete(key: _rememberMePasswordKey);
      await _storage.delete(key: _rememberMeUserTypeKey);
    } catch (e) {
      print('Error clearing remember me: $e');
    }
  }

  // Remember Me Credentials Management
  static Future<void> saveRememberMeCredentials({
    required String email,
    required String password,
    required String userType,
  }) async {
    try {
      await _storage.write(key: _rememberMeEmailKey, value: email);
      await _storage.write(key: _rememberMePasswordKey, value: password);
      await _storage.write(key: _rememberMeUserTypeKey, value: userType);
      await saveRememberMe(true);
    } catch (e) {
      print('Error saving remember me credentials: $e');
      rethrow;
    }
  }

  static Future<Map<String, String>?> getRememberMeCredentials() async {
    try {
      final email = await _storage.read(key: _rememberMeEmailKey);
      final password = await _storage.read(key: _rememberMePasswordKey);
      final userType = await _storage.read(key: _rememberMeUserTypeKey);

      if (email != null && password != null && userType != null) {
        return {'email': email, 'password': password, 'userType': userType};
      }
      return null;
    } catch (e) {
      print('Error reading remember me credentials: $e');
      return null;
    }
  }

  // Biometric Authentication Management
  static Future<void> saveBiometricEnabled(bool enabled) async {
    try {
      await _storage.write(
        key: _biometricEnabledKey,
        value: enabled.toString(),
      );
    } catch (e) {
      print('Error saving biometric enabled: $e');
      rethrow;
    }
  }

  static Future<bool> getBiometricEnabled() async {
    try {
      final enabled = await _storage.read(key: _biometricEnabledKey);
      return enabled == 'true';
    } catch (e) {
      print('Error reading biometric enabled: $e');
      return false;
    }
  }

  static Future<void> saveBiometricCredentials({
    required String email, // generic identifier used in login field
    required String password,
    required String userType,
  }) async {
    try {
      await _storage.write(key: _biometricEmailKey, value: email);
      await _storage.write(key: _biometricPasswordKey, value: password);
      await _storage.write(key: _biometricUserTypeKey, value: userType);
      await saveBiometricEnabled(true);
    } catch (e) {
      print('Error saving biometric credentials: $e');
      rethrow;
    }
  }

  static Future<Map<String, String>?> getBiometricCredentials() async {
    try {
      final email = await _storage.read(key: _biometricEmailKey);
      final password = await _storage.read(key: _biometricPasswordKey);
      final userType = await _storage.read(key: _biometricUserTypeKey);

      if (email != null && password != null && userType != null) {
        return {'email': email, 'password': password, 'userType': userType};
      }
      return null;
    } catch (e) {
      print('Error reading biometric credentials: $e');
      return null;
    }
  }

  static Future<void> clearBiometricData() async {
    try {
      await _storage.delete(key: _biometricEnabledKey);
      await _storage.delete(key: _biometricEmailKey);
      await _storage.delete(key: _biometricPasswordKey);
      await _storage.delete(key: _biometricUserTypeKey);
    } catch (e) {
      print('Error clearing biometric data: $e');
    }
  }

  // Locale Management
  static Future<void> saveLocale(
    String languageCode,
    String countryCode,
  ) async {
    try {
      await _storage.write(
        key: _localeKey,
        value: '${languageCode}_$countryCode',
      );
    } catch (e) {
      print('Error saving locale: $e');
    }
  }

  static Future<String?> getLocale() async {
    try {
      return await _storage.read(key: _localeKey);
    } catch (e) {
      print('Error reading locale: $e');
      return null;
    }
  }
}
