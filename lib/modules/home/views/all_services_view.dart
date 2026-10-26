import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/responsive/responsive_helper.dart';
import '../../../shared/widgets/blue_header_scaffold.dart';
import '../../../shared/widgets/section_header.dart';
import '../../../shared/widgets/service_grid.dart';
import '../../../shared/widgets/state_view.dart';
import '../../../shared/widgets/empty_view.dart';
import '../../../shared/lottie/lottie_assets.dart';
import '../all_services_controller.dart';

class AllServicesView extends GetView<AllServicesController> {
  const AllServicesView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlueHeaderScaffold(
      title: 'All Services',
      headerHeight: 140,
      headerBottom: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Container(
          height: 46,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: const [AppColors.cardShadow],
          ),
          child: TextField(
            controller: controller.searchController,
            onChanged: controller.onSearchChanged,
            style: AppTypography.body.copyWith(fontSize: 14),
            decoration: InputDecoration(
              hintText: 'Search services...',
              hintStyle: AppTypography.body.copyWith(color: AppColors.textMuted, fontSize: 13.5),
              prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primaryBlue, size: 22),
              suffixIcon: Obx(() => controller.searchQuery.value.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.close_rounded, size: 18),
                      onPressed: controller.clearSearch,
                    )
                  : const SizedBox.shrink()),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ),
      body: Obx(() {
        if (controller.viewState.value == ViewState.empty) {
          return EmptyView(
            title: 'No Services Found',
            message: 'No service matching "${controller.searchQuery.value}"',
            lottieAsset: LottieAssets.noSearchResult,
            actionLabel: 'Clear Search',
            onAction: controller.clearSearch,
          );
        }

        final columns = ResponsiveHelper.serviceGridColumns(context);

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Recharge & Bill Payments Section
              if (controller.rechargeAndBills.isNotEmpty) ...[
                const SectionHeader(title: 'Recharge & Bill Payments', actionLabel: 'View All'),
                const SizedBox(height: 6),
                ServiceGrid(
                  services: controller.rechargeAndBills,
                  crossAxisCount: columns,
                  onServiceTap: (s) => Get.toNamed(s.route),
                ),
                const SizedBox(height: 20),
              ],

              // Insurance Section
              if (controller.insuranceServices.isNotEmpty) ...[
                const SectionHeader(title: 'Insurance', actionLabel: 'View All'),
                const SizedBox(height: 6),
                ServiceGrid(
                  services: controller.insuranceServices,
                  crossAxisCount: columns,
                  onServiceTap: (s) => Get.toNamed(s.route),
                ),
                const SizedBox(height: 20),
              ],

              // Financial Services Section
              if (controller.financialServices.isNotEmpty) ...[
                const SectionHeader(title: 'Financial Services', actionLabel: 'View All'),
                const SizedBox(height: 6),
                ServiceGrid(
                  services: controller.financialServices,
                  crossAxisCount: columns,
                  onServiceTap: (s) => Get.toNamed(s.route),
                ),
                const SizedBox(height: 24),
              ],
            ],
          ),
        );
      }),
    );
  }
}
