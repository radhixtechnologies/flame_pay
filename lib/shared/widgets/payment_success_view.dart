import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/formatters.dart';
import '../../data/models/payment_result_model.dart';
import '../../app/routes/app_routes.dart';
import 'app_button.dart';

class PaymentSuccessView extends StatelessWidget {
  final PaymentResultModel result;

  const PaymentSuccessView({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            children: [
              const SizedBox(height: 20),

              // Success Icon Ring
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.success.withValues(alpha: 0.12),
                ),
                child: Center(
                  child: Container(
                    width: 68,
                    height: 68,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [Color(0xFF22C55E), Color(0xFF16A34A)],
                      ),
                    ),
                    child: const Icon(Icons.check_rounded, color: Colors.white, size: 40),
                  ),
                ),
              ),

              const SizedBox(height: 18),

              Text(
                'Payment Successful!',
                style: AppTypography.h1.copyWith(
                  color: AppColors.navyText,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 6),
              Text(
                result.targetTitle,
                textAlign: TextAlign.center,
                style: AppTypography.body.copyWith(color: AppColors.textSecondary),
              ),

              const SizedBox(height: 14),

              // Amount
              Text(
                Formatters.formatCurrency(result.amount),
                style: AppTypography.display.copyWith(
                  color: AppColors.navyText,
                  fontSize: 34,
                  fontWeight: FontWeight.w800,
                ),
              ),

              const SizedBox(height: 16),

              // Cashback Badge
              if (result.cashbackEarned > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF3C7),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFF59E0B)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.stars_rounded, color: Color(0xFFD97706), size: 20),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          'You earned ₹${result.cashbackEarned.toStringAsFixed(0)} Cashback!',
                          style: AppTypography.caption.copyWith(
                            color: const Color(0xFF92400E),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 24),

              // Receipt Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.border),
                  boxShadow: const [AppColors.cardShadow],
                ),
                child: Column(
                  children: [
                    _ReceiptRow(
                      label: 'Transaction ID',
                      value: result.transactionId,
                      canCopy: true,
                    ),
                    const Divider(height: 20, color: AppColors.border),
                    _ReceiptRow(
                      label: 'Operator Ref No',
                      value: result.operatorRefNumber,
                    ),
                    const Divider(height: 20, color: AppColors.border),
                    _ReceiptRow(
                      label: 'Service Type',
                      value: result.serviceType,
                    ),
                    const Divider(height: 20, color: AppColors.border),
                    _ReceiptRow(
                      label: 'Payment Mode',
                      value: result.paymentMode,
                    ),
                    const Divider(height: 20, color: AppColors.border),
                    _ReceiptRow(
                      label: 'Date & Time',
                      value: Formatters.formatDateTime(DateTime.tryParse(result.timestamp) ?? DateTime.now()),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primaryBlue,
                        side: const BorderSide(color: AppColors.primaryBlue, width: 1.5),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      icon: const Icon(Icons.share_outlined, size: 18),
                      label: const Text('Share Receipt', style: TextStyle(fontWeight: FontWeight.bold)),
                      onPressed: () {
                        Get.snackbar('Share', 'Receipt copied to clipboard', backgroundColor: Colors.green.shade100);
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.navyText,
                        side: const BorderSide(color: AppColors.border, width: 1.5),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      icon: const Icon(Icons.download_rounded, size: 18),
                      label: const Text('Download', style: TextStyle(fontWeight: FontWeight.bold)),
                      onPressed: () {
                        Get.snackbar('Download', 'Receipt downloaded to storage', backgroundColor: Colors.green.shade100);
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              AppButton(
                text: 'Done',
                type: ButtonType.orangePrimary,
                height: 52,
                onPressed: () => Get.offAllNamed(AppRoutes.home),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReceiptRow extends StatelessWidget {
  final String label;
  final String value;
  final bool canCopy;

  const _ReceiptRow({
    required this.label,
    required this.value,
    this.canCopy = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(label, style: AppTypography.caption.copyWith(color: AppColors.textSecondary)),
        const SizedBox(width: 12),
        Flexible(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.caption.copyWith(
                    color: AppColors.navyText,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (canCopy) ...[
                const SizedBox(width: 6),
                GestureDetector(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: value));
                    Get.snackbar('Copied', 'Transaction ID copied', duration: const Duration(seconds: 1));
                  },
                  child: const Icon(Icons.copy_rounded, size: 15, color: AppColors.primaryBlue),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
