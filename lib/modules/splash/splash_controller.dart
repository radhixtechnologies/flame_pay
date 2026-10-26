import 'package:get/get.dart';
import '../../core/services/storage_service.dart';
import '../../core/services/auth_service.dart';
import '../../app/routes/app_routes.dart';

class SplashController extends GetxController {
  final activeDot = 0.obs;

  @override
  void onInit() {
    super.onInit();
    _startDotTimer();
    _navigateNext();
  }

  void _startDotTimer() async {
    for (int i = 0; i < 3; i++) {
      await Future.delayed(const Duration(milliseconds: 600));
      if (isClosed) return;
      activeDot.value = (activeDot.value + 1) % 3;
    }
  }

  void _navigateNext() async {
    await Future.delayed(const Duration(milliseconds: 2200));
    if (isClosed) return;

    final storage = Get.find<StorageService>();
    final auth = Get.find<AuthService>();

    if (!storage.hasSeenOnboarding()) {
      Get.offAllNamed(AppRoutes.onboarding);
    } else if (auth.isAuthenticated.value) {
      Get.offAllNamed(AppRoutes.home);
    } else {
      Get.offAllNamed(AppRoutes.login);
    }
  }
}
