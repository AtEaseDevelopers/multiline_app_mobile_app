import 'package:get/get.dart';
import '../modules/driver/incident/incident_controller.dart';

class IncidentBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => IncidentController());
  }
}
