import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/formatters.dart';
import '../../data/models/bill_fetch_model.dart';

class BillDetailsCard extends StatelessWidget {
  final BillFetchModel bill;

  const BillDetailsCard({super.key, required this.bill});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
        boxShadow: const [AppColors.softBlueShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with Biller info
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: AppColors.tintBlue,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Icon(Icons.receipt_long_rounded, color: AppColors.primaryBlue, size: 24),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        bill.billerName,
                        style: AppTypography.bodyBold.copyWith(color: AppColors.navyText),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Consumer ID: ${bill.consumerNumber}',
                        style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Consumer & Bill breakdown
          Padding(
            padding: const EdgeInsets.all(18.0),
            child: Column(
              children: [
                _DetailRow(label: 'Consumer Name', value: bill.consumerName),
                const SizedBox(height: 10),
                _DetailRow(label: 'Bill Number', value: bill.billNumber),
                const SizedBox(height: 10),
                _DetailRow(label: 'Bill Date', value: bill.billDate),
                const SizedBox(height: 10),
                _DetailRow(
                  label: 'Due Date',
                  value: bill.dueDate,
                  valueColor: AppColors.flameRed,
                  isBold: true,
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12.0),
                  child: Divider(color: AppColors.border),
                ),

                // Total Payable Amount
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Total Bill Amount', style: AppTypography.caption),
                          if (bill.lateFee > 0)
                            Text(
                              '+ Late fee ₹${bill.lateFee.toStringAsFixed(0)} after due date',
                              style: AppTypography.micro.copyWith(color: AppColors.textMuted),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        Formatters.formatCurrency(bill.billAmount),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.display.copyWith(
                          color: AppColors.navyText,
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final bool isBold;

  const _DetailRow({
    required this.label,
    required this.value,
    this.valueColor,
    this.isBold = false,
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
          child: Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.caption.copyWith(
              color: valueColor ?? AppColors.navyText,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
