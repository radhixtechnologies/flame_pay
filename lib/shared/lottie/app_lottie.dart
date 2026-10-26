import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../../core/theme/app_colors.dart';

class AppLottie extends StatelessWidget {
  final String assetPath;
  final double? width;
  final double? height;
  final bool repeat;
  final BoxFit fit;
  final Widget? fallback;
  final IconData? fallbackIcon;

  const AppLottie({
    super.key,
    required this.assetPath,
    this.width,
    this.height,
    this.repeat = true,
    this.fit = BoxFit.contain,
    this.fallback,
    this.fallbackIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Lottie.asset(
      assetPath,
      width: width,
      height: height,
      repeat: repeat,
      fit: fit,
      errorBuilder: (context, error, stackTrace) {
        if (fallback != null) return fallback!;
        return SizedBox(
          width: width ?? 80,
          height: height ?? 80,
          child: Center(
            child: Icon(
              fallbackIcon ?? _getDefaultFallbackIcon(assetPath),
              size: (width != null) ? width! * 0.5 : 44,
              color: _getDefaultFallbackColor(assetPath),
            ),
          ),
        );
      },
    );
  }

  IconData _getDefaultFallbackIcon(String path) {
    if (path.contains('success')) return Icons.check_circle_rounded;
    if (path.contains('failed')) return Icons.cancel_rounded;
    if (path.contains('pending')) return Icons.access_time_rounded;
    if (path.contains('internet')) return Icons.wifi_off_rounded;
    if (path.contains('search')) return Icons.search_off_rounded;
    if (path.contains('notification')) return Icons.notifications_off_outlined;
    if (path.contains('loading') || path.contains('processing')) return Icons.hourglass_top_rounded;
    return Icons.inbox_rounded;
  }

  Color _getDefaultFallbackColor(String path) {
    if (path.contains('success')) return AppColors.success;
    if (path.contains('failed')) return AppColors.error;
    if (path.contains('pending')) return AppColors.warning;
    return AppColors.primaryBlue;
  }
}
