import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/responsive/responsive_helper.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/otp_input.dart';
import '../../../shared/widgets/blue_header_scaffold.dart';
import '../../../shared/lottie/app_lottie.dart';
import '../../../shared/lottie/lottie_assets.dart';
import '../controllers/otp_controller.dart';

class OtpView extends GetView<OtpController> {
  const OtpView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlueHeaderScaffold(
      title: 'Verify OTP',
      body: ResponsiveContainer(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 12),

              // Title & Subtitle
              Text(
                'Enter Verification Code',
                style: AppTypography.h1.copyWith(
                  color: AppColors.navyText,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),

              Wrap(
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    'Sent to +91 ${controller.phone} ',
                    style: AppTypography.body.copyWith(color: AppColors.textSecondary),
                  ),
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: Text(
                      'Edit',
                      style: AppTypography.bodyBold.copyWith(
                        color: AppColors.primaryBlue,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.tintBlue,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Mock OTP: 123456',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.primaryBlue,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // 6-digit OTP Input
              OtpInput(
                controller: controller.otpController,
                onCompleted: (val) => controller.verifyOtp(),
              ),

              const SizedBox(height: 28),

              // Resend Timer
              Obx(() {
                final seconds = controller.resendSeconds.value;
                if (seconds > 0) {
                  return Text(
                    'Resend OTP in 00:${seconds.toString().padLeft(2, '0')}',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  );
                } else {
                  return TextButton(
                    onPressed: controller.resendOtp,
                    child: Text(
                      'Resend OTP',
                      style: AppTypography.bodyBold.copyWith(color: AppColors.accentOrange),
                    ),
                  );
                }
              }),

              const SizedBox(height: 28),

              // Verify Button
              Obx(() {
                if (controller.isOtpSuccess.value) {
                  return const Center(
                    child: AppLottie(
                      assetPath: LottieAssets.successTick,
                      width: 90,
                      height: 90,
                      repeat: false,
                      fallbackIcon: Icons.check_circle_rounded,
                    ),
                  );
                }

                return AppButton(
                  text: 'Verify & Continue',
                  type: ButtonType.orangePrimary,
                  height: 54,
                  isLoading: controller.isVerifyingOtp.value,
                  onPressed: controller.verifyOtp,
                );
              }),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
