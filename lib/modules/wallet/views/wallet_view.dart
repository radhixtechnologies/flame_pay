import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/widgets/blue_header_scaffold.dart';
import '../../../shared/widgets/section_header.dart';
import '../../../shared/widgets/recent_transaction_tile.dart';
import '../../../shared/widgets/empty_view.dart';
import '../wallet_controller.dart';
import 'add_money_view.dart';

class WalletView extends GetView<WalletController> {
  const WalletView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlueHeaderScaffold(
      title: 'FlamePay Wallet',
      body: RefreshIndicator(
        onRefresh: controller.fetchWalletData,
        color: AppColors.primaryBlue,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Main Wallet Balance Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: AppColors.headerGradient,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [AppColors.softBlueShadow],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            'Available Balance',
                            style: AppTypography.caption.copyWith(
                              color: Colors.white.withValues(alpha: 0.85),
                              fontSize: 13,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 7,
                                height: 7,
                                decoration: const BoxDecoration(
                                  color: AppColors.flameYellow,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Active',
                                style: AppTypography.micro.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Obx(() => Text(
                          Formatters.formatCurrency(controller.balance.value),
                          style: AppTypography.display.copyWith(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.w800,
                          ),
                        )),
                    const SizedBox(height: 18),
                    const Divider(color: Colors.white24),
                    const SizedBox(height: 8),
                    // Quick Action Buttons inside Card
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.accentOrange,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            icon: const Icon(Icons.add_rounded, size: 20),
                            label: const Text('Add Money', style: TextStyle(fontWeight: FontWeight.w700)),
                            onPressed: () => Get.to(() => const AddMoneyView()),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white,
                              side: const BorderSide(color: Colors.white, width: 1.5),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            icon: const Icon(Icons.account_balance_rounded, size: 18),
                            label: const Text('Withdraw', style: TextStyle(fontWeight: FontWeight.w600)),
                            onPressed: () {
                              Get.snackbar(
                                'Withdraw to Bank',
                                'Bank transfer initiated for verified accounts',
                                backgroundColor: AppColors.tintBlue,
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Wallet Stats: Monthly Limit & Spent
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                  boxShadow: const [AppColors.cardShadow],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Monthly Limit', style: AppTypography.caption),
                          const SizedBox(height: 4),
                          Obx(() => Text(
                                Formatters.formatCurrency(controller.monthlyLimit.value),
                                style: AppTypography.bodyBold,
                              )),
                        ],
                      ),
                    ),
                    Container(width: 1, height: 36, color: AppColors.border),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Spent this Month', style: AppTypography.caption),
                          const SizedBox(height: 4),
                          Obx(() => Text(
                                Formatters.formatCurrency(controller.spentThisMonth.value),
                                style: AppTypography.bodyBold.copyWith(color: AppColors.accentOrange),
                              )),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Wallet History Header
              const SectionHeader(title: 'Wallet History'),
              const SizedBox(height: 8),

              Obx(() {
                if (controller.transactions.isEmpty) {
                  return const EmptyView(
                    title: 'No Wallet Transactions',
                    message: 'Your wallet top-ups and spendings will show up here.',
                  );
                }

                return Column(
                  children: controller.transactions
                      .map((txn) => RecentTransactionTile(transaction: txn))
                      .toList(),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
