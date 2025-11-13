import 'package:get/get.dart';
import '../../data/models/dashboard_model.dart';
import '../../data/services/driver_service.dart';

class DashboardController extends GetxController {
  final DriverService _driverService = DriverService();

  final tabIndex = 0.obs;
  final isLoading = false.obs;
  final dashboardData = Rxn<DashboardData>();
  final errorMessage = RxnString();

  @override
  void onInit() {
    super.onInit();
    loadDashboardData();
  }

  void changeTab(int i) => tabIndex.value = i;

  /// Load Dashboard Data from API
  Future<void> loadDashboardData() async {
    try {
      isLoading.value = true;
      errorMessage.value = null;

      final data = await _driverService.getDriverDashboard();
      dashboardData.value = data;
    } catch (e) {
      errorMessage.value = e.toString();
      Get.snackbar(
        'Error',
        'Failed to load dashboard data: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Refresh Dashboard Data
  Future<void> refresh() async {
    await loadDashboardData();
  }

  /// Check if driver is clocked in
  bool get isClockedIn => dashboardData.value?.isCurrentlyClockedIn ?? false;

  /// Get current vehicle info
  String get vehicleInfo {
    if (dashboardData.value == null) return 'No vehicle assigned';
    return dashboardData.value!.userData.lorryNo ?? 'No vehicle assigned';
  }
}
