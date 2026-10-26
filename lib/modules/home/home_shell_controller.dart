import 'package:get/get.dart';
import '../../shared/widgets/qr_scanner_sheet.dart';

class HomeShellController extends GetxController {
  final RxInt selectedIndex = 0.obs;

  void changeTab(int index) {
    selectedIndex.value = index;
  }

  void openQrScanner() {
    Get.bottomSheet(
      const QrScannerSheet(),
      isScrollControlled: true,
    );
  }
}
