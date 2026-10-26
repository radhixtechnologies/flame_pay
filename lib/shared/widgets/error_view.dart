import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../lottie/app_lottie.dart';
import '../lottie/lottie_assets.dart';
import 'app_button.dart';

class ErrorView extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback? onRetry;
  final String? lottieAsset;

  const ErrorView({
    super.key,
    this.title = 'Something Went Wrong',
    this.message = 'We encountered an error while processing your request.',
    this.onRetry,
    this.lottieAsset,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AppLottie(
              assetPath: lottieAsset ?? LottieAssets.errorGeneric,
              width: 130,
              height: 130,
              repeat: false,
              fallbackIcon: Icons.error_outline_rounded,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: AppTypography.h2.copyWith(color: AppColors.navyText),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTypography.body.copyWith(color: AppColors.textSecondary),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              AppButton(
                text: 'Try Again',
                onPressed: onRetry,
                isFullWidth: false,
                height: 46,
                type: ButtonType.orangePrimary,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
