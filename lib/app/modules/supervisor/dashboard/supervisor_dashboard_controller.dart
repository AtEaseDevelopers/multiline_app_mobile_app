import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/services/supervisor_service.dart';
import '../../../data/models/api_response.dart';
import '../../../data/models/supervisor_dashboard_model.dart';

class SupervisorDashboardController extends GetxController {
  final SupervisorService _supervisorService = SupervisorService();

  // Dashboard data
  final isLoading = false.obs;
  final errorMessage = RxnString();

  // Dashboard data from API
  final dashboardData = Rxn<SupervisorDashboardData>();

  @override
  void onInit() {
    super.onInit();
    loadDashboardData();
  }

  /// Load supervisor dashboard data from API
  Future<void> loadDashboardData() async {
    try {
      isLoading.value = true;
      errorMessage.value = null;

      final data = await _supervisorService.getSupervisorDashboard();
      dashboardData.value = data;
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
      errorMessage.value = 'Failed to load dashboard data';
      Get.snackbar(
        'Error',
        'Failed to load dashboard data',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Refresh dashboard data
  Future<void> refreshDashboard() async {
    await loadDashboardData();
  }

  // Getters with fallback values
  List<DashboardInspection> get inspections =>
      dashboardData.value?.inspections ?? [];
  List<DashboardChecklist> get checklists =>
      dashboardData.value?.checklists ?? [];
  int get inspectionsCount => inspections.length;
  int get checklistsCount => checklists.length;
}
