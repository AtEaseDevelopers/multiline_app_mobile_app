import 'package:get/get.dart';
import '../modules/driver/inspection/inspection_controller.dart';

class InspectionBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => InspectionController());
  }
}
