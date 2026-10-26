import 'package:get/get.dart';
import '../../data/repositories/recharge_repository.dart';
import 'recharge_controller.dart';

class RechargeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<RechargeRepository>(() => RechargeRepository());
    Get.lazyPut<RechargeController>(() => RechargeController());
  }
}
