import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/services/inspection_service.dart';
import '../../../data/services/activity_tracker_service.dart';
import '../../../data/models/inspection_model.dart';
import '../../../data/models/api_response.dart';
import '../dashboard/driver_dashboard_controller.dart';

class InspectionController extends GetxController {
  final InspectionService _inspectionService = InspectionService();

  final progress = 0.0.obs;
  final sections = <InspectionSection>[].obs;
  final canSubmit = false.obs;
  final isLoading = false.obs;
  final isSaving = false.obs;
  final selectAllEnabled = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadInspectionChecklist();
  }

  /// Toggle Select All - marks all Yes/No and Good/Bad questions with positive answer
  void toggleSelectAll() {
    selectAllEnabled.value = !selectAllEnabled.value;

    for (var section in sections) {
      for (var item in section.items) {
        if (selectAllEnabled.value) {
          // Set positive answers
          if (item.isYesNo) {
            item.value = 'Yes';
          } else if (item.isGoodBad) {
            item.value = 'Good';
          }
          // Text fields are not affected
        } else {
          // Clear only Yes/No and Good/Bad answers
          if (item.isYesNo || item.isGoodBad) {
            item.value = null;
          }
        }
      }
    }
    sections.refresh();
    _recompute();
  }

  /// Load inspection checklist from API
  Future<void> loadInspectionChecklist() async {
    try {
      isLoading.value = true;
      final checklistSections = await _inspectionService.getVehicleCheckList();
      sections.value = checklistSections;
      _recompute();
    } on ApiException catch (e) {
      Get.snackbar('Error', e.message, snackPosition: SnackPosition.BOTTOM);
    } on NetworkException catch (e) {
      Get.snackbar(
        'Network Error',
        e.message,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load inspection checklist',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Update item value
  void updateItem(int sectionIndex, int itemIndex, String value) {
    if (sectionIndex < 0 || sectionIndex >= sections.length) return;
    if (itemIndex < 0 || itemIndex >= sections[sectionIndex].items.length)
      return;

    sections[sectionIndex].items[itemIndex].value = value;
    sections.refresh();
    _recompute();
  }

  /// Add photo to item
  void addPhotoToItem(int sectionIndex, int itemIndex, String photoPath) {
    if (sectionIndex < 0 || sectionIndex >= sections.length) return;
    if (itemIndex < 0 || itemIndex >= sections[sectionIndex].items.length)
      return;

    sections[sectionIndex].items[itemIndex].photoPath = photoPath;
    sections.refresh();
  }

  /// Recompute progress
  void _recompute() {
    if (sections.isEmpty) {
      progress.value = 0.0;
      canSubmit.value = false;
      return;
    }

    int totalItems = 0;
    int answeredItems = 0;

    for (var section in sections) {
      totalItems += section.items.length;
      answeredItems += section.items.where((item) => item.isAnswered).length;
    }

    progress.value = totalItems == 0 ? 0 : answeredItems / totalItems;
    canSubmit.value = progress.value >= 1.0;
  }

  /// Submit inspection
  Future<void> submit() async {
    if (!canSubmit.value) {
      Get.snackbar(
        'Incomplete',
        'Please complete all inspection items',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      isLoading.value = true;

      // Get clockin_id from dashboard controller
      int? clockinId;
      try {
        final dashboardController = Get.find<DriverDashboardController>();
        clockinId = dashboardController.clockinId;
      } catch (e) {
        // Dashboard controller might not be available
      }

      await _inspectionService.submitInspection(
        sections: sections,
        clockinId: clockinId,
      );

      // Track activity
      await ActivityTrackerService.trackInspection(
        vehicleNumber: 'N/A',
        status: 'Completed',
      );

      // Show success message BEFORE navigation
      Get.snackbar(
        'Success',
        'Inspection submitted successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );

      // Wait a moment for user to see the message
      await Future.delayed(const Duration(milliseconds: 1500));

      // Refresh dashboard data before navigation
      try {
        final dashboardController = Get.find<DriverDashboardController>();
        await dashboardController.refreshDashboard();
      } catch (e) {
        // Dashboard controller might not be available
        print('Dashboard refresh error: $e');
      }

      // Clear all previous screens and go to dashboard
      Get.offAllNamed('/driver/dashboard');
    } on ApiException catch (e) {
      Get.snackbar(
        'Submission Failed',
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
        'Failed to submit inspection',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
