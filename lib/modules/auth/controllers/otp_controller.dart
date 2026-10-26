import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/utils/validators.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/services/auth_service.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../app/routes/app_routes.dart';

class OtpController extends GetxController {
  final AuthRepository _repo = Get.find<AuthRepository>();
  final StorageService _storage = Get.find<StorageService>();
  final AuthService _authService = Get.find<AuthService>();

  final otpController = TextEditingController();
  final isVerifyingOtp = false.obs;
  final resendSeconds = 30.obs;
  Timer? _resendTimer;
  final isOtpSuccess = false.obs;

  late final String phone;
  String? customName;
  bool isExplicitNewUser = false;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    phone = (args is Map && args['phone'] != null) ? args['phone'].toString() : '9876543210';
    if (args is Map) {
      customName = args['name']?.toString();
      isExplicitNewUser = args['isNewUser'] == true;
    }
    startResendTimer();
  }

  void startResendTimer() {
    _resendTimer?.cancel();
    resendSeconds.value = 30;
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (resendSeconds.value > 0) {
        resendSeconds.value--;
      } else {
        timer.cancel();
      }
    });
  }

  Future<void> resendOtp() async {
    if (resendSeconds.value > 0) return;
    try {
      final res = await _repo.sendOtp(phone);
      if (res.success) {
        startResendTimer();
        Get.snackbar('Success', 'New OTP sent to +91 $phone', backgroundColor: Colors.green.shade100);
      }
    } catch (e) {
      Get.snackbar('Error', e.toString(), backgroundColor: Colors.red.shade100);
    }
  }

  Future<void> verifyOtp() async {
    final otp = otpController.text.trim();
    final otpError = Validators.validateOtp(otp);
    if (otpError != null) {
      Get.snackbar('Validation', otpError, backgroundColor: Colors.orange.shade100);
      return;
    }
    if (isVerifyingOtp.value) return;

    isVerifyingOtp.value = true;
    try {
      final res = await _repo.verifyOtp(phone, otp);
      if (res.success && res.data != null) {
        isOtpSuccess.value = true;
        await _storage.setAuthToken(res.data!.token);
        await _storage.setRefreshToken(res.data!.refreshToken);

        if (res.data!.user != null) {
          final userToSet = (customName != null && customName!.trim().isNotEmpty)
              ? res.data!.user!.copyWith(name: customName!.trim())
              : res.data!.user!;
          _authService.setUser(userToSet);
        }

        await Future.delayed(const Duration(milliseconds: 700));

        if (res.data!.isNewUser || isExplicitNewUser) {
          Get.offAllNamed(AppRoutes.registration, arguments: {'phone': phone, if (customName != null) 'name': customName});
        } else {
          final hasMpin = await _storage.getMpin();
          if (hasMpin == null || hasMpin.isEmpty) {
            Get.offAllNamed(AppRoutes.mpinSetup);
          } else {
            Get.offAllNamed(AppRoutes.home);
          }
        }
      } else {
        Get.snackbar('Error', res.message, backgroundColor: Colors.red.shade100);
      }
    } catch (e) {
      Get.snackbar('Error', e.toString(), backgroundColor: Colors.red.shade100);
    } finally {
      isVerifyingOtp.value = false;
    }
  }

  @override
  void onClose() {
    _resendTimer?.cancel();
    otpController.dispose();
    super.onClose();
  }
}
