import 'package:get/get.dart';
import '../modules/dashboard/dashboard_controller.dart';
import '../modules/driver/clock/clock_controller.dart';
import '../modules/driver/dashboard/driver_dashboard_controller.dart';

class DashboardBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => DashboardController());
    Get.lazyPut(() => DriverDashboardController());
    Get.lazyPut(() => ClockController());
  }
}
