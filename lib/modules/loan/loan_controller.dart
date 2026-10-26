import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/loan_model.dart';
import '../../data/repositories/financial_services_repository.dart';
import '../../shared/widgets/state_view.dart';
import '../home/home_controller.dart';

class LoanController extends GetxController {
  final FinancialServicesRepository _repo = Get.find<FinancialServicesRepository>();

  final Rx<ViewState> viewState = ViewState.loading.obs;
  final Rx<LoanOfferModel?> loanOffer = Rx<LoanOfferModel?>(null);

  final RxDouble loanAmount = 100000.0.obs;
  final RxInt tenureMonths = 12.obs;
  final Rx<LoanCalculationModel?> calculation = Rx<LoanCalculationModel?>(null);

  final RxBool isSubmitting = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchLoanOffer();
  }

  Future<void> fetchLoanOffer() async {
    viewState.value = ViewState.loading;
    try {
      final res = await _repo.getPersonalLoanOffer();
      if (res.success && res.data != null) {
        loanOffer.value = res.data;
        recalculate();
        viewState.value = ViewState.success;
      } else {
        viewState.value = ViewState.error;
      }
    } catch (_) {
      viewState.value = ViewState.error;
    }
  }

  void updateAmount(double val) {
    loanAmount.value = val;
    recalculate();
  }

  void updateTenure(int val) {
    tenureMonths.value = val;
    recalculate();
  }

  void recalculate() {
    final rate = loanOffer.value?.annualInterestRate ?? 10.49;
    calculation.value = _repo.calculateEmi(
      loanAmount: loanAmount.value,
      tenureMonths: tenureMonths.value,
      annualInterestRate: rate,
    );
  }

  Future<void> applyForLoan({
    required String purpose,
    required String pan,
    required String bankAccount,
  }) async {
    isSubmitting.value = true;
    try {
      final res = await _repo.applyForLoan(
        amount: loanAmount.value,
        tenureMonths: tenureMonths.value,
        purpose: purpose,
        panNumber: pan,
        bankAccountNumber: bankAccount,
      );

      isSubmitting.value = false;

      if (res.success && res.data != null) {
        // Update wallet balance in HomeController if registered
        if (Get.isRegistered<HomeController>()) {
          Get.find<HomeController>().walletBalance.value += loanAmount.value;
        }

        Get.back(); // close sheet
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
                  const Text('Loan Disbursed!', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.navyText)),
                  const SizedBox(height: 8),
                  Text(
                    '₹${loanAmount.value.toInt()} has been successfully transferred to your FlamePay Wallet.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.tintBlue,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Text('Loan A/C: ${res.data!['loan_account_id']}', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.navyText, fontSize: 13)),
                        const SizedBox(height: 4),
                        Text('Monthly EMI: ₹${calculation.value?.monthlyEmi.toInt() ?? 0}/mo', style: const TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.bold)),
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
                    child: const Text('Go to Wallet', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          ),
        );
      }
    } catch (_) {
      isSubmitting.value = false;
      Get.snackbar('Error', 'Failed to submit loan application', backgroundColor: Colors.red.shade100);
    }
  }
}
