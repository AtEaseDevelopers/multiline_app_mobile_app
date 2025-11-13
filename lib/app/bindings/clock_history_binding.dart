import 'package:get/get.dart';
import '../modules/driver/clock_history/clock_history_controller.dart';

class ClockHistoryBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ClockHistoryController());
  }
}
