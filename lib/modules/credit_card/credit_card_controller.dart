import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/credit_card_model.dart';
import '../../data/repositories/financial_services_repository.dart';
import '../../shared/widgets/state_view.dart';

class CreditCardController extends GetxController {
  final FinancialServicesRepository _repo = Get.find<FinancialServicesRepository>();

  final Rx<ViewState> viewState = ViewState.loading.obs;
  final RxList<CreditCardModel> cards = <CreditCardModel>[].obs;
  final RxString selectedCategory = 'All'.obs;
  final List<String> categories = ['All', 'Cashback', 'Rewards'];

  final RxBool isSubmitting = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchCards();
  }

  Future<void> fetchCards([String? cat]) async {
    viewState.value = ViewState.loading;
    try {
      final res = await _repo.getCreditCards(category: cat == 'All' ? null : cat);
      if (res.success && res.data != null) {
        cards.assignAll(res.data!);
        viewState.value = ViewState.success;
      } else {
        viewState.value = ViewState.error;
      }
    } catch (_) {
      viewState.value = ViewState.error;
    }
  }

  void onCategoryChanged(String category) {
    selectedCategory.value = category;
    fetchCards(category);
  }

  Future<void> applyForCard(CreditCardModel card, {
    required String name,
    required String pan,
    required double income,
    required String empType,
  }) async {
    isSubmitting.value = true;
    try {
      final res = await _repo.applyForCreditCard(
        cardId: card.id,
        fullName: name,
        panNumber: pan,
        monthlyIncome: income,
        employmentType: empType,
      );

      isSubmitting.value = false;

      if (res.success) {
        Get.back(); // Close modal
        Get.dialog(
          Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: const BoxDecoration(
                      color: AppColors.tintGreen,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 40),
                  ),
                  const SizedBox(height: 16),
                  const Text('Pre-Approved!', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.navyText)),
                  const SizedBox(height: 8),
                  Text('Congratulations! Your application for ${card.name} is approved in-principle.', textAlign: TextAlign.center, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.tintBlue,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text('Approved Limit: ₹1,50,000', style: TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.bold, fontSize: 15)),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      minimumSize: const Size(double.infinity, 44),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () => Get.back(),
                    child: const Text('Done', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          ),
        );
      }
    } catch (_) {
      isSubmitting.value = false;
      Get.snackbar('Error', 'Application could not be processed', backgroundColor: Colors.red.shade100);
    }
  }
}
