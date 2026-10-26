import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/responsive/responsive_helper.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/blue_header_scaffold.dart';
import '../controllers/mpin_setup_controller.dart';

class MpinSetupView extends GetView<MpinSetupController> {
  const MpinSetupView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlueHeaderScaffold(
      title: 'Security PIN',
      showBack: false,
      actions: [
        TextButton(
          onPressed: controller.skipMpin,
          child: Text(
            'Skip',
            style: AppTypography.caption.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
      body: ResponsiveContainer(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 72,
                height: 72,
                decoration: const BoxDecoration(
                  color: AppColors.tintOrange,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(Icons.lock_outline_rounded, color: AppColors.accentOrange, size: 36),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Set 4-Digit MPIN',
                style: AppTypography.h1.copyWith(
                  color: AppColors.navyText,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Set a quick access MPIN for fast and secure payments',
                textAlign: TextAlign.center,
                style: AppTypography.body.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 32),

              // Enter MPIN
              _buildPinBox(
                label: 'Enter 4-Digit MPIN',
                controller: controller.mpinController,
              ),

              const SizedBox(height: 24),

              // Confirm MPIN
              _buildPinBox(
                label: 'Confirm 4-Digit MPIN',
                controller: controller.confirmMpinController,
              ),

              const SizedBox(height: 28),

              // Biometric toggle
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.tintBlue,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.fingerprint_rounded, color: AppColors.primaryBlue, size: 28),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Enable Biometrics', style: AppTypography.bodyBold),
                          Text('Use fingerprint or Face ID for fast login',
                              style: AppTypography.micro.copyWith(color: AppColors.textSecondary)),
                        ],
                      ),
                    ),
                    Obx(() => Switch(
                          value: controller.enableBiometric.value,
                          activeThumbColor: AppColors.primaryBlue,
                          onChanged: (val) => controller.enableBiometric.value = val,
                        )),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              Obx(() => AppButton(
                    text: 'Set MPIN & Proceed',
                    type: ButtonType.orangePrimary,
                    height: 54,
                    isLoading: controller.isSettingMpin.value,
                    onPressed: controller.setMpin,
                  )),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPinBox({
    required String label,
    required TextEditingController controller,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTypography.caption.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: true,
          obscuringCharacter: '•',
          textAlign: TextAlign.center,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(4),
          ],
          style: AppTypography.h1.copyWith(
            letterSpacing: 24.0,
            color: AppColors.navyText,
          ),
          decoration: InputDecoration(
            hintText: '••••',
            hintStyle: AppTypography.h1.copyWith(letterSpacing: 24.0, color: AppColors.textMuted),
          ),
        ),
      ],
    );
  }
}
