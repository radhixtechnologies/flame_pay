import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/formatters.dart';
import '../../data/models/transaction_model.dart';

class RecentTransactionTile extends StatelessWidget {
  final TransactionModel transaction;
  final VoidCallback? onTap;

  const RecentTransactionTile({
    super.key,
    required this.transaction,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSuccess = transaction.status.toLowerCase() == 'success';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 1),
        boxShadow: const [AppColors.cardShadow],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(14.0),
            child: Row(
              children: [
                // Operator / Category Icon Badge
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: _getCategoryColor(transaction.category),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(
                      _getCategoryIcon(transaction.category),
                      color: _getCategoryIconColor(transaction.category),
                      size: 22,
                    ),
                  ),
                ),
                const SizedBox(width: 14),

                // Title & Subtitle
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        transaction.title,
                        style: AppTypography.bodyBold.copyWith(
                          color: AppColors.navyText,
                          fontSize: 14.5,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        transaction.subtitle,
                        style: AppTypography.caption.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 11.5,
                        ),
                      ),
                    ],
                  ),
                ),

                // Amount & Status Chip
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      Formatters.formatCurrency(transaction.amount),
                      style: AppTypography.bodyBold.copyWith(
                        color: AppColors.navyText,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
                      decoration: BoxDecoration(
                        color: isSuccess ? AppColors.tintGreen : AppColors.tintOrange,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        isSuccess ? 'Successful' : 'Processing',
                        style: AppTypography.micro.copyWith(
                          color: isSuccess ? AppColors.success : AppColors.warning,
                          fontWeight: FontWeight.w700,
                          fontSize: 10.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'recharge':
        return AppColors.tintBlue;
      case 'bill':
        return AppColors.tintOrange;
      case 'wallet':
        return AppColors.tintGreen;
      case 'insurance':
        return AppColors.tintRed;
      default:
        return AppColors.tintBlue;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'recharge':
        return Icons.phone_android_rounded;
      case 'bill':
        return Icons.receipt_long_rounded;
      case 'wallet':
        return Icons.account_balance_wallet_rounded;
      case 'insurance':
        return Icons.shield_rounded;
      default:
        return Icons.payment_rounded;
    }
  }

  Color _getCategoryIconColor(String category) {
    switch (category.toLowerCase()) {
      case 'recharge':
        return AppColors.primaryBlue;
      case 'bill':
        return AppColors.accentOrange;
      case 'wallet':
        return AppColors.success;
      case 'insurance':
        return AppColors.error;
      default:
        return AppColors.primaryBlue;
    }
  }
}
