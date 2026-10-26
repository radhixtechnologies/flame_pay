import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/responsive/responsive_helper.dart';
import '../../../shared/widgets/flame_logo.dart';
import '../../../shared/widgets/wallet_card.dart';
import '../../../shared/widgets/promo_banner.dart';
import '../../../shared/widgets/section_header.dart';
import '../../../shared/widgets/service_grid.dart';
import '../../../shared/widgets/recent_transaction_tile.dart';
import '../../../shared/widgets/state_view.dart';
import '../../../app/routes/app_routes.dart';
import '../home_controller.dart';
import '../../wallet/views/add_money_view.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.paddingOf(context).top;

    return ResponsiveContainer(
      child: RefreshIndicator(
        onRefresh: controller.fetchDashboardData,
        color: AppColors.primaryBlue,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Blue Header (with Logo, Bell with Dot, User Greeting & Wallet Card)
              Stack(
                children: [
                  // Blue Gradient Curved Header Background
                  Container(
                    width: double.infinity,
                    height: 195 + topPadding,
                    decoration: const BoxDecoration(
                      gradient: AppColors.headerGradient,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(28),
                        bottomRight: Radius.circular(28),
                      ),
                    ),
                  ),

                  // Header Foreground: Logo, User Greeting & Wallet Card completely hit-testable
                  Padding(
                    padding: EdgeInsets.only(
                      top: topPadding + 8,
                      left: 20,
                      right: 20,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header Row: Logo & Bell
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const FlameLogo(
                              style: LogoStyle.fullClean,
                              size: 38,
                            ),
                            // Bell with red unread notification dot
                            Stack(
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.15),
                                    shape: BoxShape.circle,
                                  ),
                                  child: IconButton(
                                    icon: const Icon(Icons.notifications_none_rounded, color: Colors.white, size: 22),
                                    onPressed: () => Get.toNamed(AppRoutes.notifications),
                                  ),
                                ),
                                Positioned(
                                  right: 8,
                                  top: 8,
                                  child: Container(
                                    width: 9,
                                    height: 9,
                                    decoration: const BoxDecoration(
                                      color: AppColors.flameRed,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // User Greeting: "Hello, Rohit Kumar" with Avatar
                        Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2),
                                color: AppColors.tintBlue,
                              ),
                              child: const Center(
                                child: Icon(Icons.person, color: AppColors.primaryBlue, size: 26),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Hello,',
                                  style: AppTypography.caption.copyWith(
                                    color: Colors.white.withValues(alpha: 0.8),
                                    fontSize: 12,
                                  ),
                                ),
                                Obx(() {
                                  final name = controller.authService.currentUser.value?.name ?? 'Rohit Kumar';
                                  return Text(
                                    name,
                                    style: AppTypography.title.copyWith(
                                      color: Colors.white,
                                      fontSize: 16.5,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  );
                                }),
                              ],
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Wallet Card inside natural layout (100% responsive and clickable)
                        Obx(() => WalletCard(
                              balance: controller.walletBalance.value,
                              onAddMoney: () => Get.to(() => const AddMoneyView()),
                              onTap: () => Get.toNamed(AppRoutes.wallet),
                            )),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              // Content Body
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Promo Cashback Banner
                    const PromoBanner(),

                    const SizedBox(height: 20),

                    // Quick Services Grid (4x2)
                    SectionHeader(
                      title: 'Quick Services',
                      actionLabel: 'View All',
                      onAction: () => Get.toNamed(AppRoutes.allServices),
                    ),
                    const SizedBox(height: 6),
                    ServiceGrid(
                      services: controller.quickServices,
                      crossAxisCount: ResponsiveHelper.serviceGridColumns(context),
                      onServiceTap: controller.onServiceSelected,
                    ),

                    const SizedBox(height: 20),

                    // Recent Transactions
                    SectionHeader(
                      title: 'Recent Transactions',
                      actionLabel: 'View All',
                      onAction: () => Get.toNamed(AppRoutes.history),
                    ),
                    const SizedBox(height: 6),

                    Obx(() {
                      if (controller.viewState.value == ViewState.loading) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(24.0),
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }

                      if (controller.recentTransactions.isEmpty) {
                        return Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Center(
                            child: Column(
                              children: [
                                const Icon(Icons.receipt_long_outlined, size: 48, color: AppColors.textMuted),
                                const SizedBox(height: 8),
                                Text('No recent transactions', style: AppTypography.bodyBold),
                                Text('Your transactions will appear here', style: AppTypography.caption),
                              ],
                            ),
                          ),
                        );
                      }

                      return Column(
                        children: controller.recentTransactions.map((txn) {
                          return RecentTransactionTile(
                            transaction: txn,
                            onTap: () {
                              Get.snackbar(
                                'Transaction Detail',
                                '${txn.title} - ${txn.status.toUpperCase()}',
                                duration: const Duration(seconds: 2),
                              );
                            },
                          );
                        }).toList(),
                      );
                    }),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
