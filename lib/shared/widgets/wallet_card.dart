import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/formatters.dart';
import '../../app/routes/app_routes.dart';
import 'qr_scanner_sheet.dart';

class WalletCard extends StatelessWidget {
  final double balance;
  final VoidCallback? onAddMoney;
  final VoidCallback? onTap;

  const WalletCard({
    super.key,
    required this.balance,
    this.onAddMoney,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [AppColors.softBlueShadow],
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Top Row: Balance Info & Add Money CTA
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            child: Text(
                              'FlamePay Balance',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.caption.copyWith(
                                color: AppColors.textSecondary,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          GestureDetector(
                            onTap: onTap ?? () => Get.toNamed(AppRoutes.wallet),
                            child: const Icon(Icons.arrow_forward_ios_rounded, size: 11, color: AppColors.primaryBlue),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          Formatters.formatCurrency(balance),
                          style: AppTypography.h1.copyWith(
                            color: AppColors.navyText,
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // Add Money Button
                Container(
                  height: 36,
                  decoration: BoxDecoration(
                    gradient: AppColors.blueGradient,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: const [AppColors.cardShadow],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(10),
                      onTap: onAddMoney ?? () => Get.toNamed('/wallet/add-money'),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.add_rounded, color: Colors.white, size: 16),
                            SizedBox(width: 4),
                            Text(
                              'Add Money',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1, color: AppColors.border),

          // Bottom 4 Quick Action Buttons: Pay, Add Money, Send, Passbook
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            child: Row(
              children: [
                Expanded(
                  child: _QuickActionBtn(
                    icon: Icons.qr_code_scanner_rounded,
                    label: 'Pay',
                    onTap: () => QrScannerSheet.show(context),
                  ),
                ),
                Expanded(
                  child: _QuickActionBtn(
                    icon: Icons.add_circle_outline_rounded,
                    label: 'Add Money',
                    onTap: onAddMoney ?? () => Get.toNamed('/wallet/add-money'),
                  ),
                ),
                Expanded(
                  child: _QuickActionBtn(
                    icon: Icons.send_rounded,
                    label: 'Send',
                    onTap: () => Get.toNamed(AppRoutes.sendMoney),
                  ),
                ),
                Expanded(
                  child: _QuickActionBtn(
                    icon: Icons.receipt_long_rounded,
                    label: 'Passbook',
                    onTap: () => Get.toNamed(AppRoutes.wallet),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickActionBtn({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: const BoxDecoration(
                color: AppColors.tintBlue,
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
              child: Center(
                child: Icon(icon, color: AppColors.primaryBlue, size: 19),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: AppTypography.micro.copyWith(
                color: AppColors.navyText,
                fontWeight: FontWeight.w600,
                fontSize: 10.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
