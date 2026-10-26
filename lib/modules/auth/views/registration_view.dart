import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/validators.dart';
import '../../../core/responsive/responsive_helper.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../../shared/widgets/blue_header_scaffold.dart';
import '../../../app/routes/app_routes.dart';
import '../controllers/registration_controller.dart';

class RegistrationView extends GetView<RegistrationController> {
  const RegistrationView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlueHeaderScaffold(
      title: 'Complete Profile',
      showBack: false,
      body: ResponsiveContainer(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: controller.registerFormKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Text(
                  'Create Your Account',
                  style: AppTypography.h1.copyWith(
                    color: AppColors.navyText,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Please enter your basic information to get started',
                  style: AppTypography.body.copyWith(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 24),

                // Full Name
                AppTextField(
                  label: 'Full Name (as per PAN)',
                  hint: 'Enter your full name',
                  controller: controller.nameController,
                  validator: Validators.validateName,
                  prefixIcon: const Icon(Icons.person_outline_rounded, color: AppColors.primaryBlue),
                ),
                const SizedBox(height: 18),

                // Email
                AppTextField(
                  label: 'Email Address',
                  hint: 'Enter your email',
                  controller: controller.emailController,
                  validator: Validators.validateEmail,
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: const Icon(Icons.mail_outline_rounded, color: AppColors.primaryBlue),
                ),
                const SizedBox(height: 18),

                // Referral Code (Optional)
                AppTextField(
                  label: 'Referral Code (Optional)',
                  hint: 'Have a referral code?',
                  controller: controller.referralController,
                  prefixIcon: const Icon(Icons.card_giftcard_rounded, color: AppColors.accentOrange),
                ),
                const SizedBox(height: 20),

                // Terms Checkbox
                Obx(() => Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Checkbox(
                          value: controller.agreeToTerms.value,
                          activeColor: AppColors.primaryBlue,
                          onChanged: (val) => controller.agreeToTerms.value = val ?? false,
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: Wrap(
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                Text(
                                  'I agree to FlamePay ',
                                  style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
                                ),
                                GestureDetector(
                                  onTap: () => Get.toNamed(AppRoutes.terms),
                                  child: Text(
                                    'Terms & Conditions',
                                    style: AppTypography.caption.copyWith(
                                      color: AppColors.primaryBlue,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                Text(
                                  ' and ',
                                  style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
                                ),
                                GestureDetector(
                                  onTap: () => Get.toNamed(AppRoutes.privacy),
                                  child: Text(
                                    'Privacy Policy',
                                    style: AppTypography.caption.copyWith(
                                      color: AppColors.primaryBlue,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    )),

                const SizedBox(height: 28),

                // Submit Button
                Obx(() => AppButton(
                      text: 'Create Account',
                      type: ButtonType.orangePrimary,
                      height: 54,
                      isLoading: controller.isRegistering.value,
                      onPressed: controller.registerAccount,
                    )),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
