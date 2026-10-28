import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/services/auth_service.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../app/routes/app_routes.dart';
import '../../../core/utils/app_snackbar.dart';

class RegistrationController extends GetxController {
  final AuthRepository _repo = Get.find<AuthRepository>();
  final AuthService _authService = Get.find<AuthService>();

  final registerFormKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final emailController = TextEditingController(text: 'rohit.kumar@example.com');
  final referralController = TextEditingController();
  final agreeToTerms = true.obs;
  final isRegistering = false.obs;

  late final String phone;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    phone = (args is Map && args['phone'] != null) ? args['phone'].toString() : '9876543210';
    if (args is Map && args['name'] != null && args['name'].toString().isNotEmpty) {
      nameController.text = args['name'].toString();
    }
  }

  Future<void> registerAccount() async {
    if (!registerFormKey.currentState!.validate()) return;
    if (!agreeToTerms.value) {
      AppSnackbar.showWarning('Please agree to Terms & Conditions');
      return;
    }
    if (isRegistering.value) return;

    isRegistering.value = true;
    try {
      final res = await _repo.register(
        name: nameController.text.trim(),
        email: emailController.text.trim(),
        phone: phone,
        referralCode: referralController.text.trim(),
      );
      if (res.success && res.data != null) {
        if (res.data!.user != null) {
          _authService.setUser(res.data!.user!);
        }
        Get.offAllNamed(AppRoutes.mpinSetup);
      } else {
        AppSnackbar.showError(res.message, title: 'API Error');
      }
    } catch (e) {
      AppSnackbar.showError(e, title: 'API Error');
    } finally {
      isRegistering.value = false;
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    referralController.dispose();
    super.onClose();
  }
}
