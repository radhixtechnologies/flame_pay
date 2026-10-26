import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/services/storage_service.dart';
import '../../app/routes/app_routes.dart';

class OnboardingItem {
  final String titlePrefix;
  final String titleHighlight;
  final String subtitle;
  final String imagePath;

  const OnboardingItem({
    required this.titlePrefix,
    required this.titleHighlight,
    required this.subtitle,
    required this.imagePath,
  });
}

class OnboardingController extends GetxController {
  final pageController = PageController();
  final currentPage = 0.obs;

  final storage = Get.find<StorageService>();

  final List<OnboardingItem> slides = const [
    OnboardingItem(
      titlePrefix: 'All Your Financial Needs\n',
      titleHighlight: 'In One App',
      subtitle:
          'Recharge, Pay Bills, Buy Insurance, Check CIBIL, Apply for Credit Card and Loans — Anytime, Anywhere.',
      imagePath: 'assets/images/onboarding_illustration.png',
    ),
    OnboardingItem(
      titlePrefix: 'Instant Recharges &\n',
      titleHighlight: 'Bill Payments',
      subtitle:
          'Electricity, Mobile, DTH, Gas, Broadband & FASTag payments in seconds with up to ₹1,000 cashback.',
      imagePath: 'assets/images/onboarding_bills.jpg',
    ),
    OnboardingItem(
      titlePrefix: 'Instant Loans, Cards\n',
      titleHighlight: '& Free CIBIL',
      subtitle:
          'Track your credit score, get pre-approved loans up to ₹25 Lakhs, and protect your family with top insurance.',
      imagePath: 'assets/images/onboarding_loans.jpg',
    ),
  ];

  void onPageChanged(int index) {
    currentPage.value = index;
  }

  void nextPage() {
    if (currentPage.value < slides.length - 1) {
      pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    } else {
      completeOnboarding();
    }
  }

  Future<void> completeOnboarding() async {
    await storage.setSeenOnboarding(true);
    Get.offAllNamed(AppRoutes.login);
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }
}
