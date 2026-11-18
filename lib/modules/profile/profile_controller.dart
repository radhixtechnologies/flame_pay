import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/biometric_service.dart';
import '../../core/services/storage_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/validators.dart';
import '../../app/routes/app_routes.dart';
import '../../shared/widgets/personal_qr_sheet.dart';

class ProfileController extends GetxController {
  final AuthService authService = Get.find<AuthService>();
  final StorageService storageService = Get.find<StorageService>();
  final ImagePicker _picker = ImagePicker();

  final RxBool biometricEnabled = true.obs;
  final RxBool pushNotificationsEnabled = true.obs;
  final RxBool isUpdatingProfile = false.obs;

  @override
  void onInit() {
    super.onInit();
    biometricEnabled.value = storageService.isBiometricEnabled();
  }

  Future<void> toggleBiometrics(bool val) async {
    if (val) {
      try {
        final biometric = Get.find<BiometricService>();
        final authenticated = await biometric.authenticate(
          reason: 'Authenticate to enable biometric login for FlamePay',
        );
        if (authenticated) {
          biometricEnabled.value = true;
          await storageService.setBiometricEnabled(true);
          Get.snackbar(
            'Biometrics Enabled',
            'You can now use fingerprint or face ID to unlock FlamePay',
            backgroundColor: AppColors.success.withValues(alpha: 0.15),
            colorText: AppColors.success,
            icon: const Icon(Icons.fingerprint_rounded, color: AppColors.success),
          );
        } else {
          biometricEnabled.value = false;
        }
      } catch (e) {
        biometricEnabled.value = true;
        await storageService.setBiometricEnabled(true);
      }
    } else {
      biometricEnabled.value = false;
      await storageService.setBiometricEnabled(false);
      Get.snackbar(
        'Biometrics Disabled',
        'Biometric authentication has been turned off',
      );
    }
  }

  void pickProfilePhoto() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(height: 16),
            const Text(
              'Change Profile Photo',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppColors.navyText),
            ),
            const SizedBox(height: 6),
            const Text(
              'Choose your source to update your profile image',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 18),
            ListTile(
              leading: Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(color: AppColors.tintBlue, shape: BoxShape.circle),
                child: const Icon(Icons.camera_alt_rounded, color: AppColors.primaryBlue),
              ),
              title: const Text('Take Photo (Camera)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              subtitle: const Text('Take a new profile picture with camera', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
              trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textSecondary),
              onTap: () {
                Get.back();
                _selectAndSavePhoto(ImageSource.camera);
              },
            ),
            const Divider(height: 16),
            ListTile(
              leading: Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(color: AppColors.tintOrange, shape: BoxShape.circle),
                child: const Icon(Icons.photo_library_rounded, color: AppColors.accentOrange),
              ),
              title: const Text('Choose from Gallery', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              subtitle: const Text('Select a photo from your gallery', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
              trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textSecondary),
              onTap: () {
                Get.back();
                _selectAndSavePhoto(ImageSource.gallery);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  Future<void> _selectAndSavePhoto(ImageSource source) async {
    try {
      final XFile? picked = await _picker.pickImage(
        source: source,
        maxWidth: 1080,
        maxHeight: 1080,
        imageQuality: 85,
      );
      if (picked != null) {
        final user = authService.currentUser.value;
        if (user != null) {
          final updated = user.copyWith(avatarUrl: picked.path);
          authService.setUser(updated);
          await storageService.setUserData(updated.toJson());
          Get.snackbar(
            'Profile Photo Updated',
            'Your new profile picture has been updated across FlamePay!',
            backgroundColor: AppColors.success.withValues(alpha: 0.15),
            colorText: AppColors.success,
            icon: const Icon(Icons.check_circle_rounded, color: AppColors.success),
          );
        }
      }
    } catch (e) {
      Get.snackbar('Notice', 'Could not pick image: $e');
    }
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
    PersonalQrSheet.show(context);
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
