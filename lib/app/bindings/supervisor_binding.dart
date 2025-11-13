import 'package:get/get.dart';
import '../modules/supervisor/dashboard/supervisor_dashboard_controller.dart';

class SupervisorBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => SupervisorDashboardController());
  }
}
