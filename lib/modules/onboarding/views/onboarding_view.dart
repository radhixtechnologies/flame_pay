import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/responsive/responsive_helper.dart';
import '../../../shared/widgets/app_button.dart';
import '../onboarding_controller.dart';

class OnboardingView extends GetView<OnboardingController> {
  const OnboardingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: controller.completeOnboarding,
            child: Text(
              'Skip',
              style: AppTypography.title.copyWith(
                color: AppColors.primaryBlue,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: ResponsiveContainer(
        child: SafeArea(
          child: Column(
            children: [
              // Swipeable PageView with 3 slides
              Expanded(
                child: PageView.builder(
                  controller: controller.pageController,
                  onPageChanged: controller.onPageChanged,
                  itemCount: controller.slides.length,
                  itemBuilder: (context, index) {
                    final slide = controller.slides[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(height: 8),

                          // Dynamic Headline with Orange Gradient Highlight
                          RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                              style: AppTypography.display.copyWith(
                                color: AppColors.navyText,
                                fontSize: 26,
                                fontWeight: FontWeight.w800,
                                height: 1.25,
                              ),
                              children: [
                                TextSpan(text: slide.titlePrefix),
                                WidgetSpan(
                                  child: ShaderMask(
                                    shaderCallback: (bounds) =>
                                        AppColors.orangeGradient.createShader(bounds),
                                    child: Text(
                                      slide.titleHighlight,
                                      style: AppTypography.display.copyWith(
                                        fontSize: 26,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.white,
                                        height: 1.25,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 12),

                          // Subtitle
                          Text(
                            slide.subtitle,
                            textAlign: TextAlign.center,
                            style: AppTypography.body.copyWith(
                              color: AppColors.textSecondary,
                              fontSize: 13.5,
                              height: 1.45,
                            ),
                          ),

                          const Spacer(),

                          // 3D Illustration asset
                          Expanded(
                            flex: 12,
                            child: Center(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(24),
                                child: Image.asset(
                                  slide.imagePath,
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) =>
                                      _buildFallbackIllustration(index),
                                ),
                              ),
                            ),
                          ),

                          const Spacer(),
                        ],
                      ),
                    );
                  },
                ),
              ),

              // Smooth Page Indicator & Action Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                child: Column(
                  children: [
                    // Dynamic Smooth Page Indicator connected to PageController
                    SmoothPageIndicator(
                      controller: controller.pageController,
                      count: controller.slides.length,
                      effect: const ExpandingDotsEffect(
                        activeDotColor: AppColors.primaryBlue,
                        dotColor: Color(0xFFD6E3F8),
                        dotHeight: 8,
                        dotWidth: 8,
                        expansionFactor: 3.5,
                        spacing: 6,
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Action Button (Next or Get Started)
                    Obx(() {
                      final isLastPage =
                          controller.currentPage.value == controller.slides.length - 1;
                      return AppButton(
                        text: isLastPage ? 'Get Started  →' : 'Next  →',
                        type: isLastPage ? ButtonType.orangePrimary : ButtonType.blueSecondary,
                        height: 54,
                        onPressed: controller.nextPage,
                      );
                    }),

                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFallbackIllustration(int index) {
    final icons = [
      Icons.shield_outlined,
      Icons.receipt_long_rounded,
      Icons.credit_card_rounded,
    ];
    return Container(
      width: 260,
      height: 260,
      decoration: const BoxDecoration(
        color: AppColors.tintBlue,
        shape: BoxShape.circle,
        boxShadow: [AppColors.softBlueShadow],
      ),
      child: Center(
        child: Icon(
          icons[index % icons.length],
          size: 110,
          color: AppColors.primaryBlue,
        ),
      ),
    );
  }
}
