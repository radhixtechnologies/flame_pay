import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/formatters.dart';
import 'app_button.dart';

class ConfirmBottomSheet extends StatefulWidget {
  final String title;
  final double amount;
  final double walletBalance;
  final Map<String, String> details;
  final VoidCallback? onConfirm;
  final Function(String paymentMode)? onConfirmPayment;
  final bool isLoading;

  const ConfirmBottomSheet({
    super.key,
    required this.title,
    required this.amount,
    required this.walletBalance,
    required this.details,
    this.onConfirm,
    this.onConfirmPayment,
    this.isLoading = false,
  });

  @override
  State<ConfirmBottomSheet> createState() => _ConfirmBottomSheetState();
}

class _ConfirmBottomSheetState extends State<ConfirmBottomSheet> {
  late String _selectedMode;

  @override
  void initState() {
    super.initState();
    // If wallet balance is insufficient, auto-select UPI (Cashfree)
    final hasEnoughBalance = widget.walletBalance >= widget.amount;
    _selectedMode = hasEnoughBalance ? 'FlamePay Wallet' : 'Cashfree UPI';
  }

  @override
  Widget build(BuildContext context) {
    final hasEnoughBalance = widget.walletBalance >= widget.amount;
    final shortfall = (widget.amount - widget.walletBalance).clamp(0.0, double.infinity);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(widget.title, style: AppTypography.title.copyWith(color: AppColors.navyText)),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Get.back(),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Center(
              child: Text(
                Formatters.formatCurrency(widget.amount),
                style: AppTypography.display.copyWith(
                  color: AppColors.navyText,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(height: 14),
            const Divider(color: AppColors.border),
            const SizedBox(height: 8),

            ...widget.details.entries.map((e) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(e.key, style: AppTypography.body.copyWith(color: AppColors.textSecondary, fontSize: 13)),
                      Text(e.value, style: AppTypography.bodyBold.copyWith(color: AppColors.textPrimary, fontSize: 13)),
                    ],
                  ),
                )),

            const SizedBox(height: 12),
            const Divider(color: AppColors.border),
            const SizedBox(height: 12),

            // Select Payment Mode Header
            Text(
              'Select Payment Mode',
              style: AppTypography.caption.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.navyText,
                letterSpacing: 0.3,
              ),
            ),
            const SizedBox(height: 10),

            // Mode 1: FlamePay Wallet
            InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: hasEnoughBalance
                  ? () {
                      setState(() {
                        _selectedMode = 'FlamePay Wallet';
                      });
                    }
                  : null,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _selectedMode == 'FlamePay Wallet'
                      ? AppColors.primaryBlue.withValues(alpha: 0.08)
                      : (hasEnoughBalance ? Colors.white : Colors.grey.shade100),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: _selectedMode == 'FlamePay Wallet'
                        ? AppColors.primaryBlue
                        : AppColors.border,
                    width: _selectedMode == 'FlamePay Wallet' ? 1.8 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: hasEnoughBalance
                            ? AppColors.primaryBlue.withValues(alpha: 0.12)
                            : Colors.grey.shade200,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.account_balance_wallet_rounded,
                        color: hasEnoughBalance ? AppColors.primaryBlue : Colors.grey.shade500,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'FlamePay Wallet',
                                style: AppTypography.bodyBold.copyWith(
                                  color: hasEnoughBalance ? AppColors.navyText : Colors.grey.shade600,
                                ),
                              ),
                              const SizedBox(width: 6),
                              if (!hasEnoughBalance)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.red.shade50,
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(color: Colors.red.shade200),
                                  ),
                                  child: Text(
                                    'Low Balance',
                                    style: TextStyle(
                                      color: Colors.red.shade700,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            hasEnoughBalance
                                ? 'Available: ${Formatters.formatCurrency(widget.walletBalance)}'
                                : 'Balance: ${Formatters.formatCurrency(widget.walletBalance)} (Shortfall: ${Formatters.formatCurrency(shortfall)})',
                            style: TextStyle(
                              color: hasEnoughBalance ? AppColors.textSecondary : Colors.red.shade600,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Radio<String>(
                      value: 'FlamePay Wallet',
                      groupValue: _selectedMode,
                      activeColor: AppColors.primaryBlue,
                      onChanged: hasEnoughBalance
                          ? (val) {
                              if (val != null) setState(() => _selectedMode = val);
                            }
                          : null,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 10),

            // Mode 2: UPI Payment (Cashfree Gateway - Only UPI Enabled)
            InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () {
                setState(() {
                  _selectedMode = 'Cashfree UPI';
                });
              },
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _selectedMode == 'Cashfree UPI'
                      ? const Color(0xFFF97316).withValues(alpha: 0.08)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: _selectedMode == 'Cashfree UPI'
                        ? const Color(0xFFF97316)
                        : AppColors.border,
                    width: _selectedMode == 'Cashfree UPI' ? 1.8 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF97316).withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.bolt_rounded,
                        color: Color(0xFFF97316),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'Pay via UPI',
                                style: AppTypography.bodyBold.copyWith(color: AppColors.navyText),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.green.shade50,
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(color: Colors.green.shade200),
                                ),
                                child: Text(
                                  'Only UPI • Instant',
                                  style: TextStyle(
                                    color: Colors.green.shade800,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'GPay, PhonePe, Paytm, BHIM & UPI Apps',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Radio<String>(
                      value: 'Cashfree UPI',
                      groupValue: _selectedMode,
                      activeColor: const Color(0xFFF97316),
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedMode = val);
                      },
                    ),
                  ],
                ),
              ),
            ),

            if (!hasEnoughBalance) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.amber.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline_rounded, size: 16, color: Colors.amber.shade900),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Wallet balance is low. Pay directly from your UPI app via Cashfree.',
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: Colors.amber.shade900,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 22),
            AppButton(
              text: _selectedMode == 'Cashfree UPI'
                  ? 'Pay ${Formatters.formatCurrency(widget.amount)} via UPI'
                  : 'Pay ${Formatters.formatCurrency(widget.amount)} via Wallet',
              isLoading: widget.isLoading,
              onPressed: () {
                if (widget.onConfirmPayment != null) {
                  widget.onConfirmPayment!(_selectedMode);
                } else if (widget.onConfirm != null) {
                  widget.onConfirm!();
                }
              },
              type: ButtonType.orangePrimary,
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
