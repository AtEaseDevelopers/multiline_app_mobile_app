import 'package:get/get.dart';
import '../modules/driver/clock/clock_controller.dart';

class ClockBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ClockController());
  }
}
