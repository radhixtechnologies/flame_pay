import 'package:get/get.dart';
import '../../data/repositories/home_repository.dart';
import '../../data/repositories/wallet_repository.dart';
import 'home_controller.dart';
import 'all_services_controller.dart';
import 'home_shell_controller.dart';
import '../wallet/wallet_controller.dart';
import '../offers/offers_controller.dart';
import '../history/history_controller.dart';
import '../profile/profile_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeRepository>(() => HomeRepository(), fenix: true);
    Get.lazyPut<WalletRepository>(() => WalletRepository(), fenix: true);

    Get.lazyPut<HomeShellController>(() => HomeShellController(), fenix: true);
    Get.lazyPut<HomeController>(() => HomeController(), fenix: true);
    Get.lazyPut<AllServicesController>(() => AllServicesController(), fenix: true);
    Get.lazyPut<WalletController>(() => WalletController(), fenix: true);

    // Shell tab controllers
    Get.lazyPut<OffersController>(() => OffersController(), fenix: true);
    Get.lazyPut<HistoryController>(() => HistoryController(), fenix: true);
    Get.lazyPut<ProfileController>(() => ProfileController(), fenix: true);
  }
}
