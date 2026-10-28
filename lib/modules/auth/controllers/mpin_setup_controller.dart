import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/services/auth_service.dart';
import '../../../app/routes/app_routes.dart';

import '../../../core/utils/app_snackbar.dart';
import '../../../data/repositories/auth_repository.dart';

class MpinSetupController extends GetxController {
  final StorageService _storage = Get.find<StorageService>();
  final AuthService _authService = Get.find<AuthService>();
  final AuthRepository _repo = Get.isRegistered<AuthRepository>()
      ? Get.find<AuthRepository>()
      : AuthRepository();

  final mpinController = TextEditingController();
  final confirmMpinController = TextEditingController();
  final enableBiometric = true.obs;
  final isSettingMpin = false.obs;

  Future<void> setMpin() async {
    final mpin = mpinController.text.trim();
    final confirm = confirmMpinController.text.trim();

    if (mpin.length != 4) {
      AppSnackbar.showWarning('MPIN must be 4 digits');
      return;
    }
    if (mpin != confirm) {
      AppSnackbar.showWarning('MPINs do not match');
      return;
    }
    if (isSettingMpin.value) return;

    isSettingMpin.value = true;
    try {
      await _storage.setMpin(mpin);
      await _storage.setBiometricEnabled(enableBiometric.value);
      try {
        await _repo.setMpin(mpin);
      } catch (err) {
        debugPrint('Backend setMpin notice: $err');
      }
      _authService.hasMpin.value = true;
      _authService.isAuthenticated.value = true;
      AppSnackbar.showSuccess('MPIN created successfully');
      Get.offAllNamed(AppRoutes.home);
    } catch (e) {
      AppSnackbar.showError(e, title: 'API Error');
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
