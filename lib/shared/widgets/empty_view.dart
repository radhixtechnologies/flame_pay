import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../lottie/app_lottie.dart';
import '../lottie/lottie_assets.dart';
import 'app_button.dart';

class EmptyView extends StatelessWidget {
  final String title;
  final String message;
  final String? lottieAsset;
  final String? actionLabel;
  final VoidCallback? onAction;

  const EmptyView({
    super.key,
    required this.title,
    required this.message,
    this.lottieAsset,
    this.actionLabel,
    this.onAction,
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
              assetPath: lottieAsset ?? LottieAssets.emptyBox,
              width: 140,
              height: 140,
              repeat: true,
              fallbackIcon: Icons.inbox_rounded,
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
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 20),
              AppButton(
                text: actionLabel!,
                onPressed: onAction,
                isFullWidth: false,
                height: 44,
                type: ButtonType.blueSecondary,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
