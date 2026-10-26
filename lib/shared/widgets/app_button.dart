import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

enum ButtonType {
  orangePrimary,
  blueSecondary,
  outline,
  text,
}

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonType type;
  final bool isLoading;
  final bool isFullWidth;
  final double height;
  final Widget? icon;
  final double borderRadius;

  const AppButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.type = ButtonType.orangePrimary,
    this.isLoading = false,
    this.isFullWidth = true,
    this.height = 54,
    this.icon,
    this.borderRadius = 14,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null && !isLoading;

    Widget content = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isLoading) ...[
          const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2.2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
          const SizedBox(width: 12),
        ] else if (icon != null) ...[
          icon!,
          const SizedBox(width: 8),
        ],
        Flexible(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.button.copyWith(
              color: _getTextColor(enabled),
            ),
          ),
        ),
      ],
    );

    Decoration decoration;
    if (!enabled) {
      decoration = BoxDecoration(
        color: AppColors.border,
        borderRadius: BorderRadius.circular(borderRadius),
      );
    } else {
      switch (type) {
        case ButtonType.orangePrimary:
          decoration = BoxDecoration(
            gradient: AppColors.orangeGradient,
            borderRadius: BorderRadius.circular(borderRadius),
            boxShadow: const [AppColors.buttonShadow],
          );
          break;
        case ButtonType.blueSecondary:
          decoration = BoxDecoration(
            gradient: AppColors.blueGradient,
            borderRadius: BorderRadius.circular(borderRadius),
            boxShadow: const [AppColors.cardShadow],
          );
          break;
        case ButtonType.outline:
          decoration = BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(color: AppColors.primaryBlue, width: 1.5),
          );
          break;
        case ButtonType.text:
          decoration = BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(borderRadius),
          );
          break;
      }
    }

    Widget button = Container(
      height: height,
      width: isFullWidth ? double.infinity : null,
      decoration: decoration,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(borderRadius),
          onTap: enabled ? onPressed : null,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Center(child: content),
          ),
        ),
      ),
    );

    return button;
  }

  Color _getTextColor(bool enabled) {
    if (!enabled) return AppColors.textMuted;
    switch (type) {
      case ButtonType.orangePrimary:
      case ButtonType.blueSecondary:
        return Colors.white;
      case ButtonType.outline:
      case ButtonType.text:
        return AppColors.primaryBlue;
    }
  }
}
