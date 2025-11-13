import '../models/api_response.dart';
import '../models/notification_model.dart';
import '../providers/api_client.dart';
import '../../core/values/api_constants.dart';

class NotificationService {
  final ApiClient _apiClient = ApiClient();

  /// Get all notifications
  Future<NotificationsResponse> getNotifications() async {
    try {
      // Use dio directly since the notifications API has a different response structure
      final response = await _apiClient.dio.get(ApiConstants.notifications);

      print('🔍 Response statusCode: ${response.statusCode}');
      print('🔍 Response data type: ${response.data.runtimeType}');
      print('🔍 Response data: ${response.data}');

      if (response.statusCode != 200 || response.data == null) {
        throw ApiException(
          message: 'Failed to load notifications',
          statusCode: response.statusCode,
        );
      }

      final result = NotificationsResponse.fromJson(
        response.data as Map<String, dynamic>,
      );
      print('✅ Parsed ${result.notifications.length} notifications');
      return result;
    } catch (e) {
      print('❌ Error loading notifications: $e');
      rethrow;
    }
  }

  /// Mark single notification as read
  Future<void> markAsRead(int notificationId) async {
    try {
      final response = await _apiClient.dio.post(
        '${ApiConstants.notificationMarkAsRead}/$notificationId/read',
      );

      if (response.statusCode != 200) {
        throw ApiException(
          message: 'Failed to mark notification as read',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Mark all notifications as read
  Future<void> markAllAsRead() async {
    try {
      final response = await _apiClient.dio.post(
        ApiConstants.notificationsReadAll,
      );

      if (response.statusCode != 200) {
        throw ApiException(
          message: 'Failed to mark all notifications as read',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Delete single notification
  Future<void> deleteNotification(int notificationId) async {
    try {
      final response = await _apiClient.dio.post(
        '${ApiConstants.notifications}/$notificationId',
      );

      if (response.statusCode != 200) {
        throw ApiException(
          message: 'Failed to delete notification',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      rethrow;
    }
  }
}
