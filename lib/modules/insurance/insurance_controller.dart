import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/insurance_model.dart';
import '../../data/repositories/financial_services_repository.dart';
import '../../shared/widgets/state_view.dart';

class InsuranceController extends GetxController {
  final FinancialServicesRepository _repo = Get.find<FinancialServicesRepository>();

  final Rx<ViewState> viewState = ViewState.loading.obs;
  final Rx<InsuranceCategory> selectedCategory = InsuranceCategory.health.obs;
  final RxList<InsurancePlanModel> plans = <InsurancePlanModel>[].obs;
  final RxBool isSubmitting = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchPlans();
  }

  Future<void> fetchPlans([InsuranceCategory? cat]) async {
    viewState.value = ViewState.loading;
    try {
      final res = await _repo.getInsurancePlans(category: cat ?? selectedCategory.value);
      if (res.success && res.data != null) {
        plans.assignAll(res.data!);
        viewState.value = ViewState.success;
      } else {
        viewState.value = ViewState.error;
      }
    } catch (_) {
      viewState.value = ViewState.error;
    }
  }

  void onCategoryChanged(InsuranceCategory category) {
    selectedCategory.value = category;
    fetchPlans(category);
  }

  Future<void> buyPolicy(InsurancePlanModel plan, {
    required String name,
    required String age,
    required String phone,
  }) async {
    isSubmitting.value = true;
    try {
      final res = await _repo.buyInsurancePolicy(
        planId: plan.id,
        insuredPersonName: name,
        age: age,
        phone: phone,
        premiumAmount: plan.yearlyPremium,
        paymentMode: 'FlamePay Wallet',
      );

      isSubmitting.value = false;

      if (res.success && res.data != null) {
        Get.back(); // close modal
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
                    child: const Icon(Icons.verified_rounded, color: AppColors.success, size: 40),
                  ),
                  const SizedBox(height: 16),
                  const Text('Policy Issued!', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.navyText)),
                  const SizedBox(height: 8),
                  Text('Your policy with ${plan.provider} is active immediately.', textAlign: TextAlign.center, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.tintBlue,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Text('Policy No: ${res.data!['policy_number']}', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.navyText, fontSize: 13)),
                        const SizedBox(height: 4),
                        Text('Sum Insured: ₹${plan.coverAmount >= 10000000 ? "${(plan.coverAmount / 10000000).toStringAsFixed(0)} Crore" : "${(plan.coverAmount / 100000).toStringAsFixed(0)} Lakhs"}', style: const TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.bold)),
                      ],
                    ),
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
      Get.snackbar('Error', 'Payment failed', backgroundColor: Colors.red.shade100);
    }
  }
}
