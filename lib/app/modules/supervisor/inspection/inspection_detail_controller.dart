import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/api_response.dart';
import '../../../data/models/inspection_detail_model.dart';
import '../../../data/services/supervisor_service.dart';
import '../../../routes/app_routes.dart';
import '../dashboard/supervisor_dashboard_controller.dart';

class InspectionDetailController extends GetxController {
  final SupervisorService _supervisorService = SupervisorService();

  final isLoading = false.obs;
  final isApproving = false.obs;
  final isRejecting = false.obs;
  final errorMessage = RxnString();
  final inspectionDetail = Rxn<InspectionDetail>();

  final TextEditingController notesController = TextEditingController();
  final TextEditingController rejectReasonController = TextEditingController();

  int? inspectionId;

  @override
  void onInit() {
    super.onInit();
    inspectionId = Get.arguments as int?;
    if (inspectionId != null) {
      loadInspectionDetails();
    } else {
      errorMessage.value = 'Invalid inspection ID';
    }
  }

  @override
  void onClose() {
    notesController.dispose();
    rejectReasonController.dispose();
    super.onClose();
  }

  /// Load inspection details from API
  Future<void> loadInspectionDetails() async {
    try {
      isLoading.value = true;
      errorMessage.value = null;

      final detail = await _supervisorService.getInspectionDetails(
        inspectionId!,
      );
      inspectionDetail.value = detail;
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
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
    } catch (e) {
      errorMessage.value = 'Failed to load inspection details';
      Get.snackbar(
        'Error',
        'Failed to load inspection details',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Approve inspection
  Future<void> approveInspection() async {
    try {
      isApproving.value = true;

      await _supervisorService.approveInspection(
        inspectionId!,
        notes: notesController.text.trim().isEmpty
            ? null
            : notesController.text.trim(),
      );

      isApproving.value = false;

      // Show success message
      Get.snackbar(
        'Success',
        'Inspection approved successfully',
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
    } on ApiException catch (e) {
      isApproving.value = false;
      Get.snackbar(
        'Error',
        e.message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
        margin: const EdgeInsets.all(16),
      );
    } on NetworkException catch (e) {
      isApproving.value = false;
      Get.snackbar(
        'Network Error',
        e.message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
        margin: const EdgeInsets.all(16),
      );
    } catch (e) {
      isApproving.value = false;
      Get.snackbar(
        'Error',
        'Failed to approve inspection: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
        margin: const EdgeInsets.all(16),
      );
    }
  }

  /// Reject inspection
  Future<void> rejectInspection() async {
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

      await _supervisorService.rejectInspection(inspectionId!, reason: reason);

      isRejecting.value = false;

      // Show success message
      Get.snackbar(
        'Success',
        'Inspection rejected successfully',
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
    } on ApiException catch (e) {
      isRejecting.value = false;
      Get.snackbar(
        'Error',
        e.message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
        margin: const EdgeInsets.all(16),
      );
    } on NetworkException catch (e) {
      isRejecting.value = false;
      Get.snackbar(
        'Network Error',
        e.message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
        margin: const EdgeInsets.all(16),
      );
    } catch (e) {
      isRejecting.value = false;
      Get.snackbar(
        'Error',
        'Failed to reject inspection: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
        margin: const EdgeInsets.all(16),
      );
    }
  }

  /// Show approve dialog
  void showApproveDialog() {
    notesController.clear();

    Get.dialog(
      AlertDialog(
        title: const Text('Approve Inspection'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Add optional notes for this approval:'),
            const SizedBox(height: 16),
            TextField(
              controller: notesController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Enter notes (optional)',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Get.back();
              approveInspection();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('Approve'),
          ),
        ],
      ),
    );
  }

  /// Show reject dialog
  void showRejectDialog() {
    rejectReasonController.clear();

    Get.dialog(
      AlertDialog(
        title: const Text('Reject Inspection'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Please provide a reason for rejection:'),
            const SizedBox(height: 16),
            TextField(
              controller: rejectReasonController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Enter rejection reason *',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Get.back();
              rejectInspection();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Reject'),
          ),
        ],
      ),
    );
  }
}
