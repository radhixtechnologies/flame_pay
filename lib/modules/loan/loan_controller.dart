import '../../core/services/auth_service.dart';
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
    String? ifsc,
    String? employmentType,
    double? monthlyIncome,
    String? companyName,
    String? aadhaar,
    String? userName,
    String? userPhone,
    String? userEmail,
    Map<String, dynamic>? documents,
  }) async {
    isSubmitting.value = true;
    try {
      final auth = Get.isRegistered<AuthService>() ? Get.find<AuthService>() : null;
      final user = auth?.currentUser.value;
      final finalName = userName ?? user?.name ?? 'FlamePay Member';
      final finalPhone = userPhone ?? user?.phone ?? '+91 9876543210';
      final finalEmail = userEmail ?? user?.email ?? 'member@flamepay.in';

      final res = await _repo.applyForLoan(
        amount: loanAmount.value,
        tenureMonths: tenureMonths.value,
        purpose: purpose,
        panNumber: pan,
        bankAccountNumber: bankAccount,
        ifscCode: ifsc,
        employmentType: employmentType,
        monthlyIncome: monthlyIncome,
        companyName: companyName,
        userName: finalName,
        userPhone: finalPhone,
        userEmail: finalEmail,
        aadhaarNumber: aadhaar ?? user?.aadhaar,
        documents: documents,
      );

      isSubmitting.value = false;

      if (res.success && res.data != null) {
        if (Get.isRegistered<HomeController>()) {
          Get.find<HomeController>().walletBalance.value += loanAmount.value;
        }

        Get.back(); // close sheet
        final lead = res.data!['lead'] as Map<String, dynamic>?;
        final applicantName = res.data!['applicantName'] ?? lead?['userName'] ?? finalName;
        final loanId = res.data!['applicationId'] ?? res.data!['loan_account_id'] ?? lead?['id'] ?? 'LN_LEAD_101';

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
                  const Text('Loan Approved & Disbursed!', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.navyText)),
                  const SizedBox(height: 8),
                  Text(
                    '₹${loanAmount.value.toInt()} has been successfully sanctioned for $applicantName.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.primaryBlue),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.tintBlue,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.primaryBlue.withValues(alpha: 0.2)),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Applicant Name:', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                            Text(applicantName.toString(), style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.navyText, fontSize: 13)),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Loan A/C No:', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                            Text(loanId.toString(), style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryBlue, fontSize: 13)),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Monthly EMI:', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                            Text('₹${calculation.value?.monthlyEmi.toInt() ?? 0}/month', style: const TextStyle(color: AppColors.accentOrange, fontWeight: FontWeight.bold, fontSize: 13)),
                          ],
                        ),
                        const SizedBox(height: 6),
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('KYC Documents:', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                            Text('4/4 Approved ✓', style: TextStyle(color: AppColors.success, fontWeight: FontWeight.bold, fontSize: 13)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      minimumSize: const Size(double.infinity, 46),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () => Get.back(),
                    child: const Text('Done / View Wallet', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
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
