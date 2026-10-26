import 'package:get/get.dart';
import 'offers_controller.dart';

class OffersBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<OffersController>(() => OffersController());
  }
}
