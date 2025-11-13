import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/checklist_model.dart';
import '../../../data/services/activity_tracker_service.dart';
import '../../../data/services/checklist_service.dart';
import '../dashboard/driver_dashboard_controller.dart';

class DailyChecklistController extends GetxController {
  final ChecklistService _checklistService = ChecklistService();

  // UI State
  final isLoading = false.obs;
  final isSubmitting = false.obs;
  final checklistResponse = Rxn<DailyChecklistResponse>();
  final errorMessage = RxnString();
  final sections = <ChecklistSection>[].obs;
  final selectAllEnabled = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadChecklist();
  }

  /// Toggle Select All - answers all Yes/No questions with "Yes"
  void toggleSelectAll() {
    selectAllEnabled.value = !selectAllEnabled.value;

    for (var section in sections) {
      for (var item in section.items) {
        if (item.isYesNo) {
          if (selectAllEnabled.value) {
            item.answer = 'Yes';
          } else {
            item.answer = null;
          }
        }
      }
    }
    sections.refresh();
  }

  /// Load daily checklist from API
  Future<void> loadChecklist() async {
    try {
      isLoading.value = true;
      errorMessage.value = null;

      final data = await _checklistService.getDailyChecklist();
      checklistResponse.value = data;
      sections.value = data.questions;
    } catch (e) {
      errorMessage.value = e.toString();
      Get.snackbar(
        'Error',
        'Failed to load checklist: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Update answer for a question
  void updateAnswer(
    int sectionIndex,
    int itemIndex,
    String answer, {
    String? remarks,
  }) {
    sections[sectionIndex].items[itemIndex].answer = answer;
    if (remarks != null) {
      sections[sectionIndex].items[itemIndex].remarks = remarks;
    }
    sections.refresh();
  }

  /// Validate if form can be submitted
  bool get canSubmit {
    if (checklistResponse.value == null) return false;

    // Check if all mandatory questions are answered
    for (var section in sections) {
      for (var item in section.items) {
        if (item.isMandatory && !item.isAnswered) {
          return false;
        }
      }
    }
    return true;
  }

  /// Get overall progress
  double get progress {
    return checklistResponse.value?.overallProgress ?? 0.0;
  }

  /// Submit daily checklist
  Future<void> submitChecklist() async {
    if (!canSubmit) {
      Get.snackbar(
        'Validation Error',
        'Please answer all mandatory questions',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      isSubmitting.value = true;
      errorMessage.value = null;

      // Get clockin_id from dashboard controller
      final dashboardController = Get.find<DriverDashboardController>();
      final clockinId = dashboardController.clockinId;

      await _checklistService.submitDailyChecklist(
        checklistTemplateId: checklistResponse.value!.template.id,
        sections: sections,
        clockinId: clockinId,
      );

      // Track activity (without vehicle info)
      final completedItems = sections.fold<int>(
        0,
        (sum, section) => sum + section.answeredItems,
      );
      final totalItems = sections.fold<int>(
        0,
        (sum, section) => sum + section.totalItems,
      );
      await ActivityTrackerService.trackChecklist(
        vehicleNumber: 'N/A', // No vehicle selection
        completedItems: completedItems,
        totalItems: totalItems,
      );

      // Show success message BEFORE navigation
      Get.snackbar(
        'Success',
        'Daily checklist submitted successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );

      // Wait for user to see the success message
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
    } catch (e) {
      errorMessage.value = e.toString();
      Get.snackbar(
        'Error',
        'Failed to submit checklist: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isSubmitting.value = false;
    }
  }

  /// Check if checklist is loaded
  bool get isChecklistLoaded => checklistResponse.value != null;
}
