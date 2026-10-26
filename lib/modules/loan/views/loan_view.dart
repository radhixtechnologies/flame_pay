import '../../../data/models/loan_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/state_view.dart';
import '../loan_controller.dart';

class LoanView extends GetView<LoanController> {
  const LoanView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Instant Personal Loan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.primaryBlue,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Obx(() {
        if (controller.viewState.value == ViewState.loading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.viewState.value == ViewState.error || controller.loanOffer.value == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline_rounded, size: 48, color: AppColors.error),
                const SizedBox(height: 12),
                Text('Unable to Load Loan Offers', style: AppTypography.title),
                const SizedBox(height: 12),
                ElevatedButton(onPressed: controller.fetchLoanOffer, child: const Text('Retry')),
              ],
            ),
          );
        }

        final offer = controller.loanOffer.value!;
        final calc = controller.calculation.value;

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Pre-Approved Banner
              _buildHeaderBanner(offer),

              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // EMI Calculator Card
                    _buildCalculatorCard(context, offer, calc),

                    const SizedBox(height: 20),

                    // Key Features List
                    _buildFeaturesCard(offer),

                    const SizedBox(height: 24),

                    // Apply CTA Button
                    AppButton(
                      text: 'Apply for ₹${controller.loanAmount.value.toInt()}',
                      type: ButtonType.orangePrimary,
                      onPressed: () => _showLoanApplicationSheet(context),
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildHeaderBanner(LoanOfferModel offer) {
    return Container(
      decoration: const BoxDecoration(
        gradient: AppColors.blueGradient,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text('PRE-APPROVED OFFER', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
              ),
              const Flexible(child: Text('Interest from 10.49% p.a.', overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.white70, fontSize: 12))),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Instant Cash Up to ₹${offer.maxAmount.toInt()}',
            style: AppTypography.display.copyWith(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 4),
          const Text(
            'Zero paperwork • Funds in FlamePay wallet in 2 minutes',
            style: TextStyle(color: Colors.white70, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildCalculatorCard(BuildContext context, LoanOfferModel offer, LoanCalculationModel? calc) {
    final quickAmounts = [25000.0, 50000.0, 100000.0, 200000.0, 500000.0];
    final quickTenures = [6, 12, 18, 24, 36];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [AppColors.cardShadow],
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: Text('Loan Amount', style: AppTypography.bodyBold.copyWith(color: AppColors.navyText))),
              Obx(() => Text(
                    Formatters.formatCurrency(controller.loanAmount.value),
                    style: AppTypography.h1.copyWith(color: AppColors.primaryBlue, fontSize: 22, fontWeight: FontWeight.w800),
                  )),
            ],
          ),
          const SizedBox(height: 8),

          // Amount Slider
          Obx(() => SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: AppColors.primaryBlue,
                  thumbColor: AppColors.accentOrange,
                  overlayColor: AppColors.accentOrange.withValues(alpha: 0.2),
                ),
                child: Slider(
                  value: controller.loanAmount.value,
                  min: offer.minAmount,
                  max: offer.maxAmount,
                  divisions: 49,
                  onChanged: controller.updateAmount,
                ),
              )),

          // Quick Amount Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: quickAmounts.map((amt) {
                return Obx(() {
                  final isSelected = controller.loanAmount.value == amt;
                  return Padding(
                    padding: const EdgeInsets.only(right: 6.0),
                    child: ChoiceChip(
                      label: Text(amt >= 100000 ? '₹${(amt / 100000).toStringAsFixed(0)} Lakh' : '₹${(amt / 1000).toStringAsFixed(0)}k'),
                      selected: isSelected,
                      selectedColor: AppColors.primaryBlue,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : AppColors.navyText,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                      ),
                      backgroundColor: AppColors.tintBlue,
                      onSelected: (_) => controller.updateAmount(amt),
                    ),
                  );
                });
              }).toList(),
            ),
          ),

          const Divider(height: 32, color: AppColors.border),

          // Tenure Slider
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: Text('Repayment Tenure', style: AppTypography.bodyBold.copyWith(color: AppColors.navyText))),
              Obx(() => Text(
                    '${controller.tenureMonths.value} Months',
                    style: AppTypography.title.copyWith(color: AppColors.primaryBlue, fontWeight: FontWeight.bold),
                  )),
            ],
          ),
          const SizedBox(height: 8),

          Obx(() => SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: AppColors.primaryBlue,
                  thumbColor: AppColors.accentOrange,
                ),
                child: Slider(
                  value: controller.tenureMonths.value.toDouble(),
                  min: offer.minTenureMonths.toDouble(),
                  max: offer.maxTenureMonths.toDouble(),
                  divisions: 11,
                  onChanged: (v) => controller.updateTenure(v.toInt()),
                ),
              )),

          // Quick Tenure Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: quickTenures.map((m) {
                return Obx(() {
                  final isSelected = controller.tenureMonths.value == m;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ChoiceChip(
                      label: Text('${m}M'),
                      selected: isSelected,
                      selectedColor: AppColors.primaryBlue,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : AppColors.navyText,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                      backgroundColor: AppColors.tintBlue,
                      onSelected: (_) => controller.updateTenure(m),
                    ),
                  );
                });
              }).toList(),
            ),
          ),

          const SizedBox(height: 24),

          // EMI Summary Box
          if (calc != null)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.tintBlue, Colors.blue.shade50],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.primaryBlue.withValues(alpha: 0.3)),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Monthly EMI', style: AppTypography.caption.copyWith(color: AppColors.textSecondary)),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerLeft,
                              child: Text(
                                Formatters.formatCurrency(calc.monthlyEmi),
                                style: AppTypography.display.copyWith(color: AppColors.primaryBlue, fontSize: 26, fontWeight: FontWeight.w900),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: AppColors.success,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text('Low Interest', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  const Divider(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(child: Text('Principal Amount', style: AppTypography.caption)),
                      Text(Formatters.formatCurrency(calc.loanAmount), style: AppTypography.caption.copyWith(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(child: Text('Total Interest', style: AppTypography.caption)),
                      Text(Formatters.formatCurrency(calc.totalInterest), style: AppTypography.caption.copyWith(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(child: Text('Processing Fee (1.5%)', style: AppTypography.caption)),
                      Text(Formatters.formatCurrency(calc.processingFee), style: AppTypography.caption.copyWith(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFeaturesCard(LoanOfferModel offer) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Why Choose FlamePay Loan?', style: AppTypography.title.copyWith(color: AppColors.navyText, fontSize: 15, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          ...offer.highlights.map((h) => Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 18),
                    const SizedBox(width: 8),
                    Expanded(child: Text(h, style: AppTypography.body.copyWith(fontSize: 13, color: AppColors.navyText))),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  void _showLoanApplicationSheet(BuildContext context) {
    final panCtrl = TextEditingController(text: 'ABCDE1234F');
    final accountCtrl = TextEditingController(text: '918237461928');
    String purpose = 'Personal Expense';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setSheetState) => Container(
          padding: EdgeInsets.fromLTRB(24, 20, 24, MediaQuery.of(context).viewInsets.bottom + 24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(28),
              topRight: Radius.circular(28),
            ),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Instant Loan Application', style: AppTypography.title.copyWith(color: AppColors.navyText)),
                    IconButton(icon: const Icon(Icons.close_rounded), onPressed: () => Get.back()),
                  ],
                ),
                const SizedBox(height: 12),
                Text('Sanction Amount: ₹${controller.loanAmount.value.toInt()} (Tenure: ${controller.tenureMonths.value}M)', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryBlue)),
                const SizedBox(height: 16),
                TextField(
                  controller: panCtrl,
                  textCapitalization: TextCapitalization.characters,
                  decoration: InputDecoration(
                    labelText: 'PAN Card Number',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: accountCtrl,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Bank Account Number (for auto-debit)',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: purpose,
                  decoration: InputDecoration(
                    labelText: 'Loan Purpose',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  items: ['Personal Expense', 'Medical Emergency', 'Home Renovation', 'Education', 'Debt Consolidation']
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (v) => setSheetState(() => purpose = v ?? 'Personal Expense'),
                ),
                const SizedBox(height: 20),
                Obx(() => AppButton(
                      text: 'Confirm & Disburse Now',
                      isLoading: controller.isSubmitting.value,
                      type: ButtonType.orangePrimary,
                      onPressed: () {
                        controller.applyForLoan(
                          purpose: purpose,
                          pan: panCtrl.text,
                          bankAccount: accountCtrl.text,
                        );
                      },
                    )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
