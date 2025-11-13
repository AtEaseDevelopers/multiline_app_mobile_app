import '../models/api_response.dart';
import '../models/user_model.dart';
import '../providers/api_client.dart';
import '../services/storage_service.dart';
import '../../core/values/api_constants.dart';

class AuthService {
  final ApiClient _apiClient = ApiClient();

  /// Login with flexible identifier (email, custom ID, phone) plus password and user type
  /// The backend currently expects the field name 'email', so we always send it
  /// even if it's actually an ID or phone string.
  Future<LoginResponse> login({
    required String email, // acts as generic identifier
    required String password,
    required String userType,
  }) async {
    try {
      final response = await _apiClient.postFormData<LoginResponse>(
        ApiConstants.login,
        data: {'email': email, 'password': password, 'user_type': userType},
        fromJson: (data) => LoginResponse.fromJson(data),
      );

      if (response.isSuccess && response.data != null) {
        final loginData = response.data!;

        // Save token and user data to secure storage
        await StorageService.saveToken(loginData.accessToken);
        await StorageService.saveUserId(loginData.user.id);
        await StorageService.saveUserType(loginData.user.userType);
        await StorageService.saveUserName(loginData.user.name);
        if (loginData.user.email != null) {
          await StorageService.saveUserEmail(loginData.user.email!);
        }

        return loginData;
      } else {
        throw ApiException(
          message: response.message.isEmpty ? 'Login failed' : response.message,
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Logout
  Future<void> logout() async {
    try {
      // Save remember me state and credentials before clearing
      final rememberMe = await StorageService.getRememberMe();
      final rememberMeCredentials = rememberMe
          ? await StorageService.getRememberMeCredentials()
          : null;

      // Call logout API with authorization token
      try {
        await _apiClient.post(ApiConstants.logout, data: {});
      } catch (e) {
        // Continue with local logout even if API call fails
        // This ensures user can logout even with network issues
      }

      // Clear all stored data
      await StorageService.clearAll();

      // Restore remember me state and credentials if they were enabled
      if (rememberMe && rememberMeCredentials != null) {
        await StorageService.saveRememberMeCredentials(
          email: rememberMeCredentials['email']!,
          password: rememberMeCredentials['password']!,
          userType: rememberMeCredentials['userType']!,
        );
      }

      // Clear API client headers
      _apiClient.clearHeaders();
    } catch (e) {
      rethrow;
    }
  }

  /// Check if user is logged in
  Future<bool> isLoggedIn() async {
    return await StorageService.isLoggedIn();
  }

  /// Get current user type
  Future<String?> getUserType() async {
    return await StorageService.getUserType();
  }

  /// Get current user ID
  Future<int?> getUserId() async {
    return await StorageService.getUserId();
  }

  /// Get current user name
  Future<String?> getUserName() async {
    return await StorageService.getUserName();
  }

  /// Get current user email
  Future<String?> getUserEmail() async {
    return await StorageService.getUserEmail();
  }
}
