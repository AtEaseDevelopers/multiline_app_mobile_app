import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/utils/helpers.dart';
import '../../../data/services/driver_service.dart';
import '../../../data/services/activity_tracker_service.dart';
import '../../../data/models/vehicle_model.dart';
import '../../../data/models/api_response.dart';
import '../dashboard/driver_dashboard_controller.dart';

class ClockController extends GetxController {
  final DriverService _driverService = DriverService();

  final isClockedIn = false.obs;
  final workHours = '00:00'.obs;
  final currentLocation = Rxn<GeoPos>();
  final isLoading = false.obs;
  final vehicles = <Vehicle>[].obs;
  final selectedVehicle = Rxn<Vehicle>();

  // Image paths for clock in/out
  final meterReadingPhotoPath = RxnString();
  final readingPicturePath = RxnString();

  @override
  void onInit() {
    super.onInit();
    loadVehicles();
    clearImages(); // Clear images when controller initializes
  }

  /// Clear image paths
  void clearImages() {
    meterReadingPhotoPath.value = null;
    readingPicturePath.value = null;
  }

  /// Load available vehicles
  Future<void> loadVehicles() async {
    try {
      isLoading.value = true;
      final vehicleList = await _driverService.getLorries();
      vehicles.value = vehicleList;

      if (vehicleList.isNotEmpty) {
        selectedVehicle.value = vehicleList.first;
      }
    } on ApiException catch (e) {
      Get.snackbar('Error', e.message, snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load vehicles',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Clock In
  Future<void> clockIn({
    required String meterReading,
    required String readingPicturePath,
  }) async {
    try {
      if (selectedVehicle.value == null) {
        Get.snackbar(
          'Error',
          'Please select a vehicle',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      isLoading.value = true;

      final now = DateTime.now();
      final datetime =
          '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')} ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';

      await _driverService.clockIn(
        vehicleId: selectedVehicle.value!.id,
        datetime: datetime,
        meterReading: meterReading,
        readingPicturePath: readingPicturePath,
      );

      isClockedIn.value = true;
      workHours.value = '00:01';

      // Track clock in activity
      await ActivityTrackerService.trackClockIn(
        vehicleNumber: selectedVehicle.value!.registrationNumber,
        meterReading: meterReading,
      );

      // Show success toast
      Get.snackbar(
        'Success',
        'Clocked in successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );

      // Wait for user to see the success message
      await Future.delayed(const Duration(milliseconds: 1500));

      // Refresh dashboard data before navigation
      try {
        final dashboardController = Get.find<DriverDashboardController>();
        await dashboardController.refreshDashboard();
        // Reset the clock out reminder flag since user just clocked in
        dashboardController.resetClockOutReminderFlag();
      } catch (e) {
        // Dashboard controller might not be available
      }

      // Clear all previous screens and go to dashboard
      Get.offAllNamed('/driver/dashboard');
    } on ApiException catch (e) {
      Get.snackbar(
        'Clock In Failed',
        e.message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
      );
    } on NetworkException catch (e) {
      Get.snackbar(
        'Network Error',
        e.message,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to clock in',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Clock Out
  Future<void> clockOut({
    required String meterReading,
    required String readingPicturePath,
  }) async {
    try {
      isLoading.value = true;

      final now = DateTime.now();
      final datetime =
          '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')} ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';

      await _driverService.clockOut(
        datetime: datetime,
        meterReading: meterReading,
        readingPicturePath: readingPicturePath,
      );

      isClockedIn.value = false;
      workHours.value = '00:00';

      // Track clock out activity (without vehicle info)
      await ActivityTrackerService.trackClockOut(
        vehicleNumber: 'N/A',
        meterReading: meterReading,
      );

      // Show success toast
      Get.snackbar(
        'Success',
        'Clocked out successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );

      // Wait for user to see the success message
      await Future.delayed(const Duration(milliseconds: 1500));

      // Refresh dashboard data before navigation
      try {
        final dashboardController = Get.find<DriverDashboardController>();
        await dashboardController.refreshDashboard();
      } catch (e) {
        // Dashboard controller might not be available
      }

      // Clear all previous screens and go to dashboard
      Get.offAllNamed('/driver/dashboard');
    } on ApiException catch (e) {
      Get.snackbar(
        'Clock Out Failed',
        e.message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
      );
    } on NetworkException catch (e) {
      Get.snackbar(
        'Network Error',
        e.message,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to clock out',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void startWorkTimer() {
    // TODO: Implement work timer
  }
}
