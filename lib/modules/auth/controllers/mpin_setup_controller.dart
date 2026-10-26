import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/services/auth_service.dart';
import '../../../app/routes/app_routes.dart';

class MpinSetupController extends GetxController {
  final StorageService _storage = Get.find<StorageService>();
  final AuthService _authService = Get.find<AuthService>();

  final mpinController = TextEditingController();
  final confirmMpinController = TextEditingController();
  final enableBiometric = true.obs;
  final isSettingMpin = false.obs;

  Future<void> setMpin() async {
    final mpin = mpinController.text.trim();
    final confirm = confirmMpinController.text.trim();

    if (mpin.length != 4) {
      Get.snackbar('Validation', 'MPIN must be 4 digits', backgroundColor: Colors.orange.shade100);
      return;
    }
    if (mpin != confirm) {
      Get.snackbar('Validation', 'MPINs do not match', backgroundColor: Colors.orange.shade100);
      return;
    }
    if (isSettingMpin.value) return;

    isSettingMpin.value = true;
    try {
      await _storage.setMpin(mpin);
      await _storage.setBiometricEnabled(enableBiometric.value);
      _authService.hasMpin.value = true;
      _authService.isAuthenticated.value = true;
      Get.snackbar('Success', 'MPIN created successfully', backgroundColor: Colors.green.shade100);
      Get.offAllNamed(AppRoutes.home);
    } catch (e) {
      Get.snackbar('Error', e.toString(), backgroundColor: Colors.red.shade100);
    } finally {
      isSettingMpin.value = false;
    }
  }

  void skipMpin() {
    _authService.isAuthenticated.value = true;
    Get.offAllNamed(AppRoutes.home);
  }

  @override
  void onClose() {
    mpinController.dispose();
    confirmMpinController.dispose();
    super.onClose();
  }
}
