import 'package:get/get.dart';
import '../../data/repositories/wallet_repository.dart';
import 'wallet_controller.dart';
import 'controllers/send_money_controller.dart';

class WalletBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<WalletRepository>(() => WalletRepository(), fenix: true);
    Get.lazyPut<WalletController>(() => WalletController(), fenix: true);
    Get.lazyPut<SendMoneyController>(() => SendMoneyController(), fenix: true);
  }
}
