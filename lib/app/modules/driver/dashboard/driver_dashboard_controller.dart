import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/services/driver_service.dart';
import '../../../data/services/activity_storage_service.dart';
import '../../../data/models/dashboard_model.dart';
import '../../../data/models/activity_model.dart';
import '../../../data/models/api_response.dart';

class DriverDashboardController extends GetxController {
  final DriverService _driverService = DriverService();

  // Dashboard data
  final dashboardData = Rxn<DashboardData>();
  final isLoading = false.obs;
  final errorMessage = RxnString();

  // Recent activities
  final recentActivities = <ActivityItem>[].obs;
  final isLoadingActivities = false.obs;

  // Track if clock out reminder has been shown
  final _hasShownClockOutReminder = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadDashboardData();
    loadRecentActivities();
  }

  /// Load driver dashboard data from API
  Future<void> loadDashboardData() async {
    try {
      isLoading.value = true;
      errorMessage.value = null;

      final data = await _driverService.getDriverDashboard();
      dashboardData.value = data;

      // Don't reset the flag on refresh - only check once per app session
      // This prevents the reminder from showing after clock in/out operations
    } on ApiException catch (e) {
      errorMessage.value = e.message;
      Get.snackbar(
        'Error',
        e.message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } on NetworkException catch (e) {
      errorMessage.value = e.message;
      Get.snackbar(
        'Network Error',
        e.message,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      errorMessage.value = 'Failed to load dashboard data';
      Get.snackbar(
        'Error',
        'Failed to load dashboard data: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Refresh dashboard data
  Future<void> refreshDashboard() async {
    await loadDashboardData();
    await loadRecentActivities();
  }

  /// Load recent activities from local storage
  Future<void> loadRecentActivities() async {
    try {
      isLoadingActivities.value = true;
      final activities = await ActivityStorageService.getActivities();

      // Limit to most recent 5 activities
      recentActivities.value = activities.take(5).toList();
    } catch (e) {
      print('Error loading activities: $e');
      recentActivities.value = [];
    } finally {
      isLoadingActivities.value = false;
    }
  }

  /// Check if user forgot to clock out from previous shift
  /// Returns true if show_reminder is true
  bool get forgotToClockOut {
    return dashboardData.value?.showReminder ?? false;
  }

  /// Show alert if user needs to clock out first
  void checkClockOutReminder() {
    // Only show if not already shown in this session
    if (_hasShownClockOutReminder.value) {
      return;
    }

    if (forgotToClockOut) {
      _hasShownClockOutReminder.value = true; // Mark as shown

      // Navigate to urgent clock out page
      Get.offNamed(
        '/driver/urgent-clock-out',
        arguments: {
          'type': 'clockOut',
          'isMandatory': true,
          'lastClockInTime': dashboardData.value?.clockStatus.lastClockInTime,
        },
      );
    }
  }

  /// Check if user is clocked in before allowing access to features
  /// Returns true if allowed, false if needs to clock in first
  bool checkClockinRequired(String featureName) {
    final data = dashboardData.value;
    if (data == null) return false;

    // If not clocked in or clockin_id is null, require clock in
    if (clockinId == null || !data.isCurrentlyClockedIn) {
      Get.snackbar(
        'Clock In Required',
        'Please clock in first before accessing $featureName',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        icon: const Icon(Icons.access_time, color: Colors.white),
        duration: const Duration(seconds: 3),
        margin: const EdgeInsets.all(16),
      );
      return false;
    }
    return true;
  }

  /// Reset the clock out reminder flag (called after refresh)
  void resetClockOutReminderFlag() {
    _hasShownClockOutReminder.value = false;
  }

  /// Undo Clock Out - Call API to undo recent clock out
  Future<void> undoClockOut() async {
    try {
      // Show loading
      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      final userId = dashboardData.value?.userData.userId;
      if (userId == null) {
        Get.back(); // Close loading
        Get.snackbar(
          'Error',
          'User ID not found',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      // Call undo clock out API
      final response = await _driverService.undoClockOut(userId);

      // Close loading
      Get.back();

      if (response['status'] == true || response['status'] == 1) {
        // Show success message
        Get.snackbar(
          'Success',
          response['message'] ??
              'Clockout undone successfully. You are now clocked in again.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          icon: const Icon(Icons.check_circle, color: Colors.white),
          duration: const Duration(seconds: 3),
        );

        // Refresh dashboard to get updated status
        await refreshDashboard();
      } else {
        // Show error message
        Get.snackbar(
          'Error',
          response['message'] ?? 'Failed to undo clock out',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } on ApiException catch (e) {
      Get.back(); // Close loading if still open
      Get.snackbar(
        'Error',
        e.message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.back(); // Close loading if still open
      Get.snackbar(
        'Error',
        'Something went wrong: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  /// Start Rest Time
  Future<void> startRest(String? notes) async {
    try {
      // Show loading
      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      final clockInId = dashboardData.value?.userData.clockinId;
      if (clockInId == null) {
        Get.back(); // Close loading
        Get.snackbar(
          'Error',
          'Clock in ID not found',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      // Call start rest API
      final response = await _driverService.startRest(
        clockInId: clockInId,
        notes: notes,
      );

      // Close loading
      Get.back();

      // Check if response is successful (has rest_time data or status is true)
      if (response['status'] == true ||
          response['status'] == 1 ||
          response['rest_time'] != null) {
        // Refresh dashboard first to get updated status
        await refreshDashboard();

        // Then show success message
        Get.snackbar(
          'Success',
          response['message'] ?? 'Rest time started successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          icon: const Icon(Icons.check_circle, color: Colors.white),
          duration: const Duration(seconds: 3),
        );
      } else {
        // Show error message
        Get.snackbar(
          'Error',
          response['message'] ?? 'Failed to start rest time',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } on ApiException catch (e) {
      Get.back(); // Close loading if still open

      // Handle "You already have an active rest time" error
      if (e.message.toLowerCase().contains('already have an active rest')) {
        Get.snackbar(
          'Already on Rest',
          e.message,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          icon: const Icon(Icons.info, color: Colors.white),
          duration: const Duration(seconds: 3),
        );
      } else {
        Get.snackbar(
          'Error',
          e.message,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.back(); // Close loading if still open
      Get.snackbar(
        'Error',
        'Something went wrong: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  /// End Rest Time (Back to Work)
  Future<void> endRest() async {
    try {
      // Show loading
      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      final clockInId = dashboardData.value?.userData.clockinId;
      if (clockInId == null) {
        Get.back(); // Close loading
        Get.snackbar(
          'Error',
          'Clock in ID not found',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      // Call end rest API
      final response = await _driverService.endRest(clockInId: clockInId);

      // Close loading
      Get.back();

      // Check if response is successful (has rest_time data or status is true)
      if (response['status'] == true ||
          response['status'] == 1 ||
          response['rest_time'] != null) {
        // Refresh dashboard first to get updated status
        await refreshDashboard();

        // Then show success message
        Get.snackbar(
          'Success',
          response['message'] ?? 'Rest time ended successfully. Welcome back!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          icon: const Icon(Icons.check_circle, color: Colors.white),
          duration: const Duration(seconds: 3),
        );
      } else {
        // Show error message
        Get.snackbar(
          'Error',
          response['message'] ?? 'Failed to end rest time',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } on ApiException catch (e) {
      Get.back(); // Close loading if still open
      Get.snackbar(
        'Error',
        e.message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.back(); // Close loading if still open
      Get.snackbar(
        'Error',
        'Something went wrong: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // Getters for easy access to dashboard data
  String get userName => dashboardData.value?.userData.userName ?? 'Driver';
  String get companyName =>
      dashboardData.value?.userData.companyName ?? 'Not available';
  String get group => dashboardData.value?.userData.group ?? '-';
  String get lorryNo => dashboardData.value?.userData.lorryNo ?? 'Not assigned';
  String get odoMeter => dashboardData.value?.userData.odoMeter ?? '0';
  int? get clockinId => dashboardData.value?.userData.clockinId;

  // New clock status getters
  bool get isCurrentlyClockedIn =>
      dashboardData.value?.isCurrentlyClockedIn ?? false;
  bool get hasOldPendingClockOut =>
      dashboardData.value?.hasOldPendingClockOut ?? false;
  bool get canClockInToday => dashboardData.value?.canClockInToday ?? true;
  bool get showReminder => dashboardData.value?.showReminder ?? false;
  bool get hasActiveRest => dashboardData.value?.hasActiveRest ?? false;
  String? get lastClockInTime =>
      dashboardData.value?.clockStatus.lastClockInTime;
  String? get odometer => dashboardData.value?.clockStatus.odometer;
  String? get lastClockOutTime =>
      dashboardData.value?.clockStatus.lastClockOutTime;
  String? get clockOutOdometer =>
      dashboardData.value?.clockStatus.clockOutOdometer;

  // Button states based on new API conditions
  bool get shouldShowClockInButton =>
      dashboardData.value?.shouldShowClockInButton ?? true;
  bool get shouldEnableClockInButton =>
      dashboardData.value?.shouldEnableClockInButton ?? true;
  bool get shouldShowNormalClockOutButton =>
      dashboardData.value?.shouldShowNormalClockOutButton ?? false;
  bool get shouldShowUrgentClockOutButton =>
      dashboardData.value?.shouldShowUrgentClockOutButton ?? false;
}
