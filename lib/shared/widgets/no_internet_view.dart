import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../lottie/app_lottie.dart';
import '../lottie/lottie_assets.dart';
import 'app_button.dart';

class NoInternetView extends StatelessWidget {
  final VoidCallback? onRetry;

  const NoInternetView({super.key, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const AppLottie(
              assetPath: LottieAssets.noInternet,
              width: 140,
              height: 140,
              repeat: true,
              fallbackIcon: Icons.wifi_off_rounded,
            ),
            const SizedBox(height: 16),
            Text(
              'No Internet Connection',
              textAlign: TextAlign.center,
              style: AppTypography.h2.copyWith(color: AppColors.navyText),
            ),
            const SizedBox(height: 8),
            Text(
              'Please check your Wi-Fi or mobile data and try again.',
              textAlign: TextAlign.center,
              style: AppTypography.body.copyWith(color: AppColors.textSecondary),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              AppButton(
                text: 'Retry Connection',
                onPressed: onRetry,
                isFullWidth: false,
                height: 46,
                type: ButtonType.blueSecondary,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
