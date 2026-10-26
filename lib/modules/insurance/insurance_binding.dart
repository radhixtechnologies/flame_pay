import 'package:get/get.dart';
import '../../data/repositories/financial_services_repository.dart';
import 'insurance_controller.dart';

class InsuranceBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<FinancialServicesRepository>()) {
      Get.lazyPut<FinancialServicesRepository>(() => FinancialServicesRepository());
    }
    Get.lazyPut<InsuranceController>(() => InsuranceController());
  }
}
