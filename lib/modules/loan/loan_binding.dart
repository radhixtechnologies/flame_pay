import 'package:get/get.dart';
import '../../data/repositories/financial_services_repository.dart';
import 'loan_controller.dart';

class LoanBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<FinancialServicesRepository>()) {
      Get.lazyPut<FinancialServicesRepository>(() => FinancialServicesRepository());
    }
    Get.lazyPut<LoanController>(() => LoanController());
  }
}
