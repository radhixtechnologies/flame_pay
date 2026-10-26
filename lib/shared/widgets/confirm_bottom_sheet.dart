import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/formatters.dart';
import 'app_button.dart';

class ConfirmBottomSheet extends StatelessWidget {
  final String title;
  final double amount;
  final double walletBalance;
  final Map<String, String> details;
  final VoidCallback onConfirm;
  final bool isLoading;

  const ConfirmBottomSheet({
    super.key,
    required this.title,
    required this.amount,
    required this.walletBalance,
    required this.details,
    required this.onConfirm,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final hasEnoughBalance = walletBalance >= amount;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: AppTypography.title.copyWith(color: AppColors.navyText)),
              IconButton(
                icon: const Icon(Icons.close_rounded),
                onPressed: () => Get.back(),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              Formatters.formatCurrency(amount),
              style: AppTypography.display.copyWith(
                color: AppColors.navyText,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Divider(color: AppColors.border),
          const SizedBox(height: 12),
          ...details.entries.map((e) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(e.key, style: AppTypography.body.copyWith(color: AppColors.textSecondary)),
                    Text(e.value, style: AppTypography.bodyBold.copyWith(color: AppColors.textPrimary)),
                  ],
                ),
              )),
          const SizedBox(height: 12),
          const Divider(color: AppColors.border),
          const SizedBox(height: 12),
          // Wallet balance check
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: hasEnoughBalance ? AppColors.tintGreen : AppColors.tintRed,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Wallet Balance: ${Formatters.formatCurrency(walletBalance)}',
                  style: AppTypography.caption.copyWith(
                    color: hasEnoughBalance ? AppColors.success : AppColors.error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (!hasEnoughBalance)
                  Text(
                    'Low Balance',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.error,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          AppButton(
            text: hasEnoughBalance ? 'Pay Now' : 'Add Money & Pay',
            isLoading: isLoading,
            onPressed: onConfirm,
            type: ButtonType.orangePrimary,
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
