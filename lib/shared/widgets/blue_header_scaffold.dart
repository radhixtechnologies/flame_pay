import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/responsive/responsive_helper.dart';

class BlueHeaderScaffold extends StatelessWidget {
  final String title;
  final Widget body;
  final Widget? headerBottom;
  final List<Widget>? actions;
  final bool showBack;
  final VoidCallback? onBack;
  final double headerHeight;
  final bool resizeToAvoidBottomInset;
  final Widget? bottomNavigationBar;

  const BlueHeaderScaffold({
    super.key,
    required this.title,
    required this.body,
    this.headerBottom,
    this.actions,
    this.showBack = true,
    this.onBack,
    this.headerHeight = 130,
    this.resizeToAvoidBottomInset = true,
    this.bottomNavigationBar,
  });

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.paddingOf(context).top;
    final totalHeaderHeight = headerHeight + topPadding;

    return Scaffold(
      backgroundColor: AppColors.background,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      bottomNavigationBar: bottomNavigationBar,
      body: ResponsiveContainer(
        child: Stack(
          children: [
            // Blue Header Background
            Container(
              height: totalHeaderHeight + 28,
              decoration: const BoxDecoration(
                gradient: AppColors.headerGradient,
              ),
            ),

            // Main Scaffold Content
            Column(
              children: [
                // Top App Bar Area inside Blue Header
                SizedBox(height: topPadding),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                  child: Row(
                    children: [
                      if (showBack)
                        IconButton(
                          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
                          onPressed: onBack ?? () => Get.back(),
                        )
                      else
                        const SizedBox(width: 48),
                      Expanded(
                        child: Text(
                          title,
                          textAlign: TextAlign.center,
                          style: AppTypography.title.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ...?actions,
                          if (actions == null) const SizedBox(width: 48),
                        ],
                      ),
                    ],
                  ),
                ),

                ...?headerBottom != null ? [headerBottom!] : null,

                const SizedBox(height: 12),

                // Content Sheet with Rounded Top Corners (Radius 28)
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(28),
                        topRight: Radius.circular(28),
                      ),
                      boxShadow: [AppColors.softBlueShadow],
                    ),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(28),
                        topRight: Radius.circular(28),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: body,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
