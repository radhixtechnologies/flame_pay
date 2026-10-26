import 'package:get/get.dart';
import '../../data/repositories/recharge_repository.dart';
import 'bill_payment_controller.dart';

class BillPaymentBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<RechargeRepository>(() => RechargeRepository());
    Get.lazyPut<BillPaymentController>(() => BillPaymentController());
  }
}
