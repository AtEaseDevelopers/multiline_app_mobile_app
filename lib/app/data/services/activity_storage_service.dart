import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/activity_model.dart';

/// Activity Storage Service - Manages local storage of user activities
class ActivityStorageService {
  static const String _activitiesKey = 'user_activities';
  static const int _maxActivitiesPerDay = 50; // Limit activities per day
  static const int _daysToKeep = 7; // Keep activities for 7 days

  /// Save activity to local storage
  static Future<void> saveActivity(ActivityItem activity) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final activities = await getActivities();

      // Add new activity at the beginning
      activities.insert(0, activity);

      // Clean old activities (keep only last 7 days)
      final cleanedActivities = _cleanOldActivities(activities);

      // Limit to max activities
      final limitedActivities = cleanedActivities
          .take(_maxActivitiesPerDay * _daysToKeep)
          .toList();

      // Convert to JSON
      final jsonList = limitedActivities.map((a) => a.toJson()).toList();

      // Save to storage
      await prefs.setString(_activitiesKey, json.encode(jsonList));
    } catch (e) {
      print('Error saving activity: $e');
    }
  }

  /// Get all activities from storage
  static Future<List<ActivityItem>> getActivities() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_activitiesKey);

      if (jsonString == null || jsonString.isEmpty) {
        return [];
      }

      final jsonList = json.decode(jsonString) as List;
      final activities = jsonList
          .map((json) => ActivityItem.fromJson(json as Map<String, dynamic>))
          .toList();

      // Return cleaned activities
      return _cleanOldActivities(activities);
    } catch (e) {
      print('Error loading activities: $e');
      return [];
    }
  }

  /// Get today's activities
  static Future<List<ActivityItem>> getTodayActivities() async {
    final activities = await getActivities();
    return activities.where((activity) => activity.isToday).toList();
  }

  /// Get activities for specific date
  static Future<List<ActivityItem>> getActivitiesForDate(DateTime date) async {
    final activities = await getActivities();
    return activities.where((activity) {
      return activity.timestamp.year == date.year &&
          activity.timestamp.month == date.month &&
          activity.timestamp.day == date.day;
    }).toList();
  }

  /// Get activities by type
  static Future<List<ActivityItem>> getActivitiesByType(
    ActivityType type,
  ) async {
    final activities = await getActivities();
    return activities.where((activity) => activity.type == type).toList();
  }

  /// Clear all activities
  static Future<void> clearAllActivities() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_activitiesKey);
    } catch (e) {
      print('Error clearing activities: $e');
    }
  }

  /// Clear activities older than specified days
  static Future<void> clearOldActivities({int days = 7}) async {
    try {
      final activities = await getActivities();
      final cutoffDate = DateTime.now().subtract(Duration(days: days));

      final recentActivities = activities.where((activity) {
        return activity.timestamp.isAfter(cutoffDate);
      }).toList();

      final prefs = await SharedPreferences.getInstance();
      final jsonList = recentActivities.map((a) => a.toJson()).toList();
      await prefs.setString(_activitiesKey, json.encode(jsonList));
    } catch (e) {
      print('Error clearing old activities: $e');
    }
  }

  /// Get activity count for today
  static Future<int> getTodayActivityCount() async {
    final todayActivities = await getTodayActivities();
    return todayActivities.length;
  }

  /// Get activity count by type for today
  static Future<Map<ActivityType, int>> getTodayActivityCountByType() async {
    final todayActivities = await getTodayActivities();
    final countMap = <ActivityType, int>{};

    for (var activity in todayActivities) {
      countMap[activity.type] = (countMap[activity.type] ?? 0) + 1;
    }

    return countMap;
  }

  /// Private helper to clean old activities
  static List<ActivityItem> _cleanOldActivities(List<ActivityItem> activities) {
    final cutoffDate = DateTime.now().subtract(Duration(days: _daysToKeep));
    return activities.where((activity) {
      return activity.timestamp.isAfter(cutoffDate);
    }).toList();
  }

  /// Get statistics for dashboard
  static Future<Map<String, dynamic>> getActivityStats() async {
    final activities = await getActivities();
    final todayActivities = await getTodayActivities();

    return {
      'totalActivities': activities.length,
      'todayActivities': todayActivities.length,
      'lastActivityTime': activities.isNotEmpty
          ? activities.first.timestamp
          : null,
      'activityTypes': await getTodayActivityCountByType(),
    };
  }
}
