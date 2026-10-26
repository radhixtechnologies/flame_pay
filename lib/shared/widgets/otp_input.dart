import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

class OtpInput extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String>? onCompleted;
  final ValueChanged<String>? onChanged;
  final FocusNode? focusNode;

  const OtpInput({
    super.key,
    required this.controller,
    this.onCompleted,
    this.onChanged,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Available width for 6 boxes + 5 gaps
        final totalWidth = constraints.maxWidth;
        // Target box width: 46 on normal screens, down to 38 on compact screens
        final boxWidth = ((totalWidth - 40) / 6).clamp(38.0, 48.0);
        final boxHeight = (boxWidth * 1.15).clamp(46.0, 56.0);

        final defaultPinTheme = PinTheme(
          width: boxWidth,
          height: boxHeight,
          textStyle: AppTypography.h2.copyWith(
            color: AppColors.navyText,
            fontWeight: FontWeight.w700,
            fontSize: boxWidth * 0.45,
          ),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border, width: 1.5),
            boxShadow: const [AppColors.cardShadow],
          ),
        );

        final focusedPinTheme = defaultPinTheme.copyWith(
          decoration: defaultPinTheme.decoration!.copyWith(
            border: Border.all(color: AppColors.primaryBlue, width: 2),
          ),
        );

        final submittedPinTheme = defaultPinTheme.copyWith(
          decoration: defaultPinTheme.decoration!.copyWith(
            border: Border.all(color: AppColors.primaryBlue, width: 1.5),
            color: AppColors.tintBlue.withValues(alpha: 0.3),
          ),
        );

        return Material(
          color: Colors.transparent,
          child: Pinput(
            length: 6,
            controller: controller,
            focusNode: focusNode,
            defaultPinTheme: defaultPinTheme,
            focusedPinTheme: focusedPinTheme,
            submittedPinTheme: submittedPinTheme,
            showCursor: true,
            onCompleted: onCompleted,
            onChanged: onChanged,
          ),
        );
      },
    );
  }
}
