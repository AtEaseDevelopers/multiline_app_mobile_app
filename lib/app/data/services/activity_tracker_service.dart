import '../models/activity_model.dart';
import 'activity_storage_service.dart';

/// Centralized Activity Tracker Service
/// Use this service to log all user activities throughout the app
class ActivityTrackerService {
  /// Track clock in activity
  static Future<void> trackClockIn({
    required String vehicleNumber,
    required String meterReading,
  }) async {
    final activity = ActivityItem.clockIn(
      vehicleNumber: vehicleNumber,
      meterReading: meterReading,
    );
    await ActivityStorageService.saveActivity(activity);
  }

  /// Track clock out activity
  static Future<void> trackClockOut({
    required String vehicleNumber,
    required String meterReading,
  }) async {
    final activity = ActivityItem.clockOut(
      vehicleNumber: vehicleNumber,
      meterReading: meterReading,
    );
    await ActivityStorageService.saveActivity(activity);
  }

  /// Track vehicle inspection activity
  static Future<void> trackInspection({
    required String vehicleNumber,
    required String status,
  }) async {
    final activity = ActivityItem.inspection(
      vehicleNumber: vehicleNumber,
      status: status,
    );
    await ActivityStorageService.saveActivity(activity);
  }

  /// Track daily checklist activity
  static Future<void> trackChecklist({
    required String vehicleNumber,
    required int completedItems,
    required int totalItems,
  }) async {
    final activity = ActivityItem.checklist(
      vehicleNumber: vehicleNumber,
      completedItems: completedItems,
      totalItems: totalItems,
    );
    await ActivityStorageService.saveActivity(activity);
  }

  /// Track incident report activity
  static Future<void> trackIncident({
    required String incidentType,
    required String location,
  }) async {
    final activity = ActivityItem.incident(
      incidentType: incidentType,
      location: location,
    );
    await ActivityStorageService.saveActivity(activity);
  }

  /// Track custom activity
  static Future<void> trackCustomActivity(ActivityItem activity) async {
    await ActivityStorageService.saveActivity(activity);
  }

  /// Get recent activities for display
  static Future<List<ActivityItem>> getRecentActivities({
    int limit = 10,
  }) async {
    final activities = await ActivityStorageService.getActivities();
    return activities.take(limit).toList();
  }

  /// Get today's activities
  static Future<List<ActivityItem>> getTodayActivities() async {
    return await ActivityStorageService.getTodayActivities();
  }

  /// Clear old activities
  static Future<void> clearOldActivities() async {
    await ActivityStorageService.clearOldActivities();
  }
}
