import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/services/auth_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/validators.dart';
import '../../app/routes/app_routes.dart';

class ProfileController extends GetxController {
  final AuthService authService = Get.find<AuthService>();

  final RxBool biometricEnabled = true.obs;
  final RxBool pushNotificationsEnabled = true.obs;
  final RxBool isUpdatingProfile = false.obs;

  void toggleBiometrics(bool val) {
    biometricEnabled.value = val;
  }

  void showEditProfileDialog(BuildContext context) {
    final user = authService.currentUser.value;
    final nameCtrl = TextEditingController(text: user?.name ?? '');
    final emailCtrl = TextEditingController(text: user?.email ?? '');
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(28),
              topRight: Radius.circular(28),
            ),
          ),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Edit Personal Details',
                      style: AppTypography.title.copyWith(color: AppColors.navyText, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Get.back(),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Name field
                TextFormField(
                  controller: nameCtrl,
                  decoration: InputDecoration(
                    labelText: 'Full Name',
                    prefixIcon: const Icon(Icons.person_rounded, color: AppColors.primaryBlue),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  validator: Validators.validateName,
                ),
                const SizedBox(height: 16),

                // Email field
                TextFormField(
                  controller: emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Email Address',
                    prefixIcon: const Icon(Icons.mail_rounded, color: AppColors.primaryBlue),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  validator: Validators.validateEmail,
                ),
                const SizedBox(height: 12),

                // Phone (Read only)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF2F4F7),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.phone_rounded, color: AppColors.textSecondary, size: 20),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Registered Phone Number', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                          Text(user?.phone ?? '+91 9876543210', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.navyText)),
                        ],
                      ),
                      const Spacer(),
                      const Icon(Icons.lock_rounded, size: 16, color: AppColors.textMuted),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Save Changes Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    onPressed: () {
                      if (!formKey.currentState!.validate()) return;
                      final newName = nameCtrl.text.trim();
                      final newEmail = emailCtrl.text.trim();

                      if (user != null) {
                        final updated = user.copyWith(
                          name: newName,
                          email: newEmail,
                        );
                        authService.setUser(updated);
                      }
                      Get.back(); // close modal
                      Get.snackbar(
                        'Profile Updated',
                        'Your profile details have been saved successfully.',
                        backgroundColor: AppColors.tintGreen,
                        colorText: AppColors.navyText,
                      );
                    },
                    child: const Text(
                      'Save Changes',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void showQrCodeModal(BuildContext context) {
    final user = authService.currentUser.value;
    final name = (user != null && user.name.isNotEmpty) ? user.name : 'Rohit Kumar';
    final phone = user?.phone ?? '+91 9876543210';
    final upiId = '${phone.replaceAll("+91 ", "").replaceAll(" ", "")}@flamepay';

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(28),
            topRight: Radius.circular(28),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('My FlamePay QR', style: AppTypography.title.copyWith(color: AppColors.navyText)),
                IconButton(icon: const Icon(Icons.close_rounded), onPressed: () => Get.back()),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border, width: 2),
                boxShadow: const [AppColors.softBlueShadow],
              ),
              child: const Icon(
                Icons.qr_code_2_rounded,
                size: 180,
                color: AppColors.primaryBlue,
              ),
            ),
            const SizedBox(height: 14),
            Text(name, style: AppTypography.title.copyWith(color: AppColors.navyText, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text('UPI ID: $upiId', style: AppTypography.caption.copyWith(color: AppColors.primaryBlue, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            const Text('Scan using any UPI app to receive money into your FlamePay Wallet.', textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void logout([BuildContext? context]) {
    if (context != null) {
      confirmLogout(context);
    } else {
      authService.logout();
      Get.offAllNamed(AppRoutes.login);
    }
  }

  void confirmLogout(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(28),
            topRight: Radius.circular(28),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.flameRed.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.logout_rounded, color: AppColors.flameRed, size: 28),
            ),
            const SizedBox(height: 14),
            const Text('Log Out of FlamePay?', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.navyText)),
            const SizedBox(height: 6),
            const Text('Are you sure you want to log out of your account on this device?', textAlign: TextAlign.center, style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: () => Get.back(),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.flameRed,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: () {
                      Get.back();
                      authService.logout();
                      Get.offAllNamed(AppRoutes.login);
                    },
                    child: const Text('Log Out', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
