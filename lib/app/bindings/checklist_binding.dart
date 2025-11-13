import 'package:get/get.dart';
import '../modules/driver/checklist/daily_checklist_controller.dart';

class ChecklistBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => DailyChecklistController());
  }
}
