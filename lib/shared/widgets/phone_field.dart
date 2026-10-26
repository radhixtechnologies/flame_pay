import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

class PhoneField extends StatelessWidget {
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;
  final FocusNode? focusNode;
  final VoidCallback? onContactPick;

  const PhoneField({
    super.key,
    this.controller,
    this.validator,
    this.onChanged,
    this.focusNode,
    this.onContactPick,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      keyboardType: TextInputType.phone,
      textInputAction: TextInputAction.done,
      style: AppTypography.bodyBold.copyWith(
        fontSize: 16,
        letterSpacing: 1.0,
      ),
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(10),
      ],
      validator: validator,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: 'Enter Mobile Number',
        prefixIcon: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.phone_android_rounded, color: AppColors.primaryBlue, size: 20),
              const SizedBox(width: 8),
              Text(
                '+91',
                style: AppTypography.bodyBold.copyWith(
                  color: AppColors.navyText,
                  fontSize: 15,
                ),
              ),
              const SizedBox(width: 8),
              Container(width: 1.5, height: 22, color: AppColors.border),
              const SizedBox(width: 8),
            ],
          ),
        ),
        suffixIcon: onContactPick != null
            ? IconButton(
                icon: const Icon(Icons.contacts_rounded, color: AppColors.primaryBlue),
                onPressed: onContactPick,
              )
            : null,
      ),
    );
  }
}
