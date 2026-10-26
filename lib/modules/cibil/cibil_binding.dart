import 'package:get/get.dart';
import '../../data/repositories/financial_services_repository.dart';
import 'cibil_controller.dart';

class CibilBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<FinancialServicesRepository>()) {
      Get.lazyPut<FinancialServicesRepository>(() => FinancialServicesRepository());
    }
    Get.lazyPut<CibilController>(() => CibilController());
  }
}
