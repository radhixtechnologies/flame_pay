import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/validators.dart';
import '../../../core/responsive/responsive_helper.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../../shared/widgets/phone_field.dart';
import '../../../shared/widgets/flame_logo.dart';
import '../../../app/routes/app_routes.dart';
import '../controllers/login_controller.dart';

class LoginView extends GetView<LoginController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: ResponsiveContainer(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Form(
              key: controller.loginFormKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 32),

                  // FlamePay Logo + Tagline (FAST • SECURE • SIMPLE)
                  const FlameLogo(
                    style: LogoStyle.fullClean,
                    size: 58,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'FAST • SECURE • SIMPLE',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 2.8,
                      color: AppColors.navyText.withValues(alpha: 0.8),
                    ),
                  ),

                  const SizedBox(height: 48),

                  // "Login to Continue" Headline
                  Text(
                    'Login to Continue',
                    style: AppTypography.h1.copyWith(
                      color: AppColors.navyText,
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Name Field (Enter Name on Sign Up / Login)
                  Obx(() {
                    if (!controller.isNewUser.value) return const SizedBox.shrink();
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppTextField(
                          label: 'Your Full Name',
                          hint: 'Enter your name (e.g. Rahul Sharma)',
                          controller: controller.nameController,
                          prefixIcon: const Icon(Icons.person_outline_rounded, color: AppColors.primaryBlue),
                        ),
                        const SizedBox(height: 16),
                      ],
                    );
                  }),

                  // Mobile Input Field with +91 Prefix
                  PhoneField(
                    controller: controller.phoneController,
                    validator: Validators.validateMobile,
                  ),

                  const SizedBox(height: 12),

                  // Toggle: Existing Account vs New User
                  Obx(() => Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            controller.isNewUser.value ? 'Already have an account? ' : 'New to FlamePay? ',
                            style: AppTypography.caption,
                          ),
                          GestureDetector(
                            onTap: () => controller.toggleNewUser(!controller.isNewUser.value),
                            child: Text(
                              controller.isNewUser.value ? 'Sign In' : 'Create New Account',
                              style: AppTypography.caption.copyWith(
                                color: AppColors.primaryBlue,
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ],
                      )),

                  const SizedBox(height: 24),

                  // ORANGE GRADIENT PRIMARY BUTTON: "Send OTP"
                  Obx(() => AppButton(
                        text: 'Send OTP',
                        type: ButtonType.orangePrimary,
                        height: 54,
                        isLoading: controller.isSendingOtp.value,
                        onPressed: controller.sendOtp,
                      )),

                  const SizedBox(height: 28),

                  // OR Divider
                  Row(
                    children: [
                      const Expanded(child: Divider(color: AppColors.border, thickness: 1)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text(
                          'OR',
                          style: AppTypography.caption.copyWith(
                            color: AppColors.textMuted,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const Expanded(child: Divider(color: AppColors.border, thickness: 1)),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Continue with Google
                  _buildSocialButton(
                    label: 'Continue with Google',
                    icon: _buildGoogleIcon(),
                    onPressed: () {
                      Get.snackbar('Google Sign-In', 'Google authentication connected',
                          backgroundColor: AppColors.tintBlue);
                    },
                  ),

                  const SizedBox(height: 14),

                  // Continue with Apple
                  _buildSocialButton(
                    label: 'Continue with Apple',
                    icon: const Icon(Icons.apple, color: Colors.black, size: 24),
                    onPressed: () {
                      Get.snackbar('Apple Sign-In', 'Apple authentication connected',
                          backgroundColor: AppColors.tintBlue);
                    },
                  ),

                  const SizedBox(height: 48),

                  // Terms & Privacy footer
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: AppTypography.micro.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 11.5,
                          height: 1.5,
                        ),
                        children: [
                          const TextSpan(text: 'By continuing, you agree to our\n'),
                          WidgetSpan(
                            child: GestureDetector(
                              onTap: () => Get.toNamed(AppRoutes.terms),
                              child: Text(
                                'Terms & Conditions',
                                style: AppTypography.micro.copyWith(
                                  color: AppColors.primaryBlue,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 11.5,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ),
                          const TextSpan(text: ' and '),
                          WidgetSpan(
                            child: GestureDetector(
                              onTap: () => Get.toNamed(AppRoutes.privacy),
                              child: Text(
                                'Privacy Policy.',
                                style: AppTypography.micro.copyWith(
                                  color: AppColors.primaryBlue,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 11.5,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSocialButton({
    required String label,
    required Widget icon,
    required VoidCallback onPressed,
  }) {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border, width: 1.2),
        boxShadow: const [AppColors.cardShadow],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onPressed,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                icon,
                const SizedBox(width: 12),
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.bodyBold.copyWith(
                      color: AppColors.textPrimary,
                      fontSize: 14.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGoogleIcon() {
    return Container(
      width: 22,
      height: 22,
      decoration: const BoxDecoration(shape: BoxShape.circle),
      child: Center(
        child: Text(
          'G',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF4285F4),
          ),
        ),
      ),
    );
  }
}
