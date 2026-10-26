import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../app/routes/app_routes.dart';

class LoginController extends GetxController {
  final AuthRepository _repo = Get.find<AuthRepository>();

  final loginFormKey = GlobalKey<FormState>();
  final phoneController = TextEditingController(text: '9876543210');
  final nameController = TextEditingController();
  final isSendingOtp = false.obs;
  final isNewUser = false.obs;

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
        Get.toNamed(AppRoutes.otp, arguments: {
          'phone': phone,
          if (name.isNotEmpty) 'name': name,
          'isNewUser': isNewUser.value,
        });
      } else {
        Get.snackbar('Error', res.message, backgroundColor: Colors.red.shade100);
      }
    } catch (e) {
      Get.snackbar('Error', e.toString(), backgroundColor: Colors.red.shade100);
    } finally {
      isSendingOtp.value = false;
    }
  }

  @override
  void onClose() {
    phoneController.dispose();
    nameController.dispose();
    super.onClose();
  }
}
