import 'package:get/get.dart';
import '../../data/repositories/financial_services_repository.dart';
import 'credit_card_controller.dart';

class CreditCardBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<FinancialServicesRepository>()) {
      Get.lazyPut<FinancialServicesRepository>(() => FinancialServicesRepository());
    }
    Get.lazyPut<CreditCardController>(() => CreditCardController());
  }
}
