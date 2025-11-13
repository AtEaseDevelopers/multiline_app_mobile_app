import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/checklist_detail_model.dart';
import '../../../data/services/supervisor_service.dart';
import '../../../routes/app_routes.dart';
import '../dashboard/supervisor_dashboard_controller.dart';

class ChecklistDetailController extends GetxController {
  final SupervisorService _supervisorService = SupervisorService();

  // Observable state
  final Rxn<ChecklistDetail> checklistDetail = Rxn<ChecklistDetail>();
  final RxBool isLoading = false.obs;
  final RxBool isApproving = false.obs;
  final RxBool isRejecting = false.obs;
  final Rxn<String> errorMessage = Rxn<String>();

  // Text controllers for dialogs
  final TextEditingController notesController = TextEditingController();
  final TextEditingController rejectReasonController = TextEditingController();

  // Checklist ID from route arguments
  int? checklistId;

  @override
  void onInit() {
    super.onInit();
    // Get checklist ID from route arguments
    checklistId = Get.arguments as int?;
    if (checklistId != null) {
      loadChecklistDetails();
    } else {
      errorMessage.value = 'Invalid checklist ID';
    }
  }

  @override
  void onClose() {
    notesController.dispose();
    rejectReasonController.dispose();
    super.onClose();
  }

  /// Load checklist details from API
  Future<void> loadChecklistDetails() async {
    if (checklistId == null) return;

    try {
      isLoading.value = true;
      errorMessage.value = null;

      final details = await _supervisorService.getChecklistDetails(
        checklistId!,
      );
      checklistDetail.value = details;
    } catch (e) {
      errorMessage.value = 'An unexpected error occurred';
      Get.snackbar(
        'Error',
        'Failed to load checklist details',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Show approve dialog with optional notes
  void showApproveDialog() {
    notesController.clear();
    Get.dialog(
      AlertDialog(
        title: const Text('Approve Checklist'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Are you sure you want to approve this checklist?'),
            const SizedBox(height: 16),
            TextField(
              controller: notesController,
              decoration: const InputDecoration(
                labelText: 'Notes (Optional)',
                hintText: 'Add any notes...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Get.back();
              approveChecklist();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text('Approve'),
          ),
        ],
      ),
    );
  }

  /// Show reject dialog with required reason
  void showRejectDialog() {
    rejectReasonController.clear();
    Get.dialog(
      AlertDialog(
        title: const Text('Reject Checklist'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Please provide a reason for rejection:'),
            const SizedBox(height: 16),
            TextField(
              controller: rejectReasonController,
              decoration: const InputDecoration(
                labelText: 'Reason *',
                hintText: 'Enter rejection reason...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (rejectReasonController.text.trim().isEmpty) {
                Get.snackbar(
                  'Validation Error',
                  'Please provide a reason for rejection',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.orange,
                  colorText: Colors.white,
                  duration: const Duration(seconds: 2),
                );
                return;
              }
              Get.back();
              rejectChecklist();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Reject'),
          ),
        ],
      ),
    );
  }

  /// Approve the checklist
  Future<void> approveChecklist() async {
    if (checklistId == null) return;

    try {
      isApproving.value = true;

      final notes = notesController.text.trim();
      await _supervisorService.approveChecklist(
        checklistId!,
        notes: notes.isEmpty ? null : notes,
      );

      isApproving.value = false;

      // Show success message
      Get.snackbar(
        'Success',
        'Checklist approved successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
        margin: const EdgeInsets.all(16),
      );

      // Wait a bit for snackbar to appear
      await Future.delayed(const Duration(milliseconds: 500));

      // Navigate to supervisor dashboard and refresh
      Get.offAllNamed(AppRoutes.supervisorDashboard);

      try {
        final dashboardController = Get.find<SupervisorDashboardController>();
        await dashboardController.refreshDashboard();
      } catch (e) {
        // Dashboard controller not found
        print('Dashboard controller not found: $e');
      }
    } catch (e) {
      isApproving.value = false;
      Get.snackbar(
        'Error',
        'Failed to approve checklist: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
        margin: const EdgeInsets.all(16),
      );
    }
  }

  /// Reject the checklist
  Future<void> rejectChecklist() async {
    if (checklistId == null) return;

    final reason = rejectReasonController.text.trim();
    if (reason.isEmpty) {
      Get.snackbar(
        'Validation Error',
        'Please provide a reason for rejection',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
        margin: const EdgeInsets.all(16),
      );
      return;
    }

    try {
      isRejecting.value = true;

      await _supervisorService.rejectChecklist(checklistId!, reason: reason);

      isRejecting.value = false;

      // Show success message
      Get.snackbar(
        'Success',
        'Checklist rejected successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
        margin: const EdgeInsets.all(16),
      );

      // Wait a bit for snackbar to appear
      await Future.delayed(const Duration(milliseconds: 500));

      // Navigate to supervisor dashboard and refresh
      Get.offAllNamed(AppRoutes.supervisorDashboard);

      try {
        final dashboardController = Get.find<SupervisorDashboardController>();
        await dashboardController.refreshDashboard();
      } catch (e) {
        // Dashboard controller not found
        print('Dashboard controller not found: $e');
      }
    } catch (e) {
      isRejecting.value = false;
      Get.snackbar(
        'Error',
        'Failed to reject checklist: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
        margin: const EdgeInsets.all(16),
      );
    }
  }
}
