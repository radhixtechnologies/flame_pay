import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../app/routes/app_routes.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/biometric_service.dart';
import '../../../core/services/storage_service.dart';
import '../../../data/models/user_model.dart';
import '../../../core/utils/app_snackbar.dart';

class LoginController extends GetxController {
  final AuthRepository _repo = Get.find<AuthRepository>();
  final StorageService _storage = Get.find<StorageService>();

  final loginFormKey = GlobalKey<FormState>();
  final phoneController = TextEditingController();
  final nameController = TextEditingController();
  final isSendingOtp = false.obs;
  final isNewUser = false.obs;
  final canBiometricLogin = false.obs;

  @override
  void onInit() {
    super.onInit();
    canBiometricLogin.value = _storage.isBiometricEnabled();
  }

  Future<void> loginWithBiometrics() async {
    try {
      final biometric = Get.find<BiometricService>();
      final ok = await biometric.authenticate(
        reason: 'Authenticate with fingerprint or Face ID to login to FlamePay',
      );
      if (ok) {
        final userData = _storage.getUserData();
        if (userData != null) {
          final user = UserModel.fromJson(userData);
          Get.find<AuthService>().setUser(user);
        }
        Get.offAllNamed(AppRoutes.home);
        AppSnackbar.showSuccess('Biometric authentication verified');
      }
    } catch (_) {}
  }

  void toggleNewUser(bool val) {
    isNewUser.value = val;
  }

  Future<void> sendOtp() async {
    if (!loginFormKey.currentState!.validate()) return;
    if (isSendingOtp.value) return;

    isSendingOtp.value = true;
    try {
      final phone = phoneController.text.trim();
      final name = nameController.text.trim();
      final res = await _repo.sendOtp(phone);
      if (res.success) {
        if (res.message.isNotEmpty) {
          AppSnackbar.showSuccess(res.message);
        }
        Get.toNamed(AppRoutes.otp, arguments: {
          'phone': phone,
          if (name.isNotEmpty) 'name': name,
          'isNewUser': isNewUser.value,
        });
      } else {
        AppSnackbar.showError(res.message, title: 'API Error');
      }
    } catch (e) {
      AppSnackbar.showError(e, title: 'API Error');
    } finally {
      isSendingOtp.value = false;
    }
  }
}
