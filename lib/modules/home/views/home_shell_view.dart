import '../../../core/services/connectivity_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/responsive/responsive_helper.dart';
import '../home_shell_controller.dart';
import 'home_view.dart';
import '../../offers/views/offers_view.dart';
import '../../history/views/history_view.dart';
import '../../profile/views/profile_view.dart';

class HomeShellView extends GetView<HomeShellController> {
  const HomeShellView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // Offline Non-blocking Banner
          Obx(() {
            final isConnected = Get.find<ConnectivityService>().isConnected.value;
            if (!isConnected) {
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: const Color(0xFFFEF0C7),
                child: const Row(
                  children: [
                    Icon(Icons.wifi_off_rounded, color: Color(0xFFB54708), size: 18),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'You are offline. Showing cached wallet balance & transactions.',
                        style: TextStyle(color: Color(0xFFB54708), fontSize: 11.5, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              );
            }
            return const SizedBox.shrink();
          }),
          Expanded(
            child: Obx(() => IndexedStack(
                  index: controller.selectedIndex.value,
                  children: const [
                    HomeView(),
                    OffersView(),
                    HistoryView(),
                    ProfileView(),
                  ],
                )),
          ),
        ],
      ),
      bottomNavigationBar: ResponsiveContainer(
        child: _buildBottomBar(),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      height: 74,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x140F4CC9),
            blurRadius: 16,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          // 4 Tab Items Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildTabItem(index: 0, icon: Icons.home_rounded, label: 'Home'),
              _buildTabItem(index: 1, icon: Icons.local_offer_outlined, label: 'Offers'),
              const SizedBox(width: 56), // Center space for raised QR button
              _buildTabItem(index: 2, icon: Icons.receipt_long_outlined, label: 'History'),
              _buildTabItem(index: 3, icon: Icons.person_outline_rounded, label: 'Profile'),
            ],
          ),

          // Center Raised Circular Orange Scan Button with Glow
          Positioned(
            top: -20,
            child: GestureDetector(
              onTap: controller.openQrScanner,
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  gradient: AppColors.orangeGradient,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.accentOrange.withValues(alpha: 0.45),
                      blurRadius: 18,
                      offset: const Offset(0, 6),
                    ),
                  ],
                  border: Border.all(color: Colors.white, width: 3.5),
                ),
                child: const Center(
                  child: Icon(
                    Icons.qr_code_scanner_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabItem({
    required int index,
    required IconData icon,
    required String label,
  }) {
    return Obx(() {
      final isSelected = controller.selectedIndex.value == index;
      final color = isSelected ? AppColors.primaryBlue : AppColors.textSecondary;

      return InkWell(
        onTap: () => controller.changeTab(index),
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        child: SizedBox(
          width: 62,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(height: 3),
              Text(
                label,
                style: AppTypography.micro.copyWith(
                  color: color,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
