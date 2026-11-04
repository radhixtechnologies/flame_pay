import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/services/auth_service.dart';
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
        title: const Text('FlamePay Instant Loans', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.primaryBlue,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            tooltip: 'Refresh Status',
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
            onPressed: () {
              controller.fetchLoanOffer();
              controller.fetchMyApplications();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildTopTabSwitcher(),
          Expanded(
            child: Obx(() {
              if (controller.selectedTab.value == 1) {
                return _buildApplicationsList(context);
              }

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
                    _buildHeaderBanner(offer),
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildCalculatorCard(context, offer, calc),
                          const SizedBox(height: 20),
                          _buildFeaturesCard(offer),
                          const SizedBox(height: 24),
                          AppButton(
                            text: 'Apply for ₹${controller.loanAmount.value.toInt()} (Submit to Admin)',
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
          ),
        ],
      ),
    );
  }

  Widget _buildTopTabSwitcher() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Obx(() => Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => controller.selectedTab.value = 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: controller.selectedTab.value == 0 ? AppColors.primaryBlue : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.calculate_outlined,
                          size: 16,
                          color: controller.selectedTab.value == 0 ? Colors.white : AppColors.textSecondary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Apply & Calculate',
                          style: TextStyle(
                            color: controller.selectedTab.value == 0 ? Colors.white : AppColors.navyText,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    controller.selectedTab.value = 1;
                    controller.fetchMyApplications();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: controller.selectedTab.value == 1 ? AppColors.primaryBlue : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.assignment_turned_in_outlined,
                          size: 16,
                          color: controller.selectedTab.value == 1 ? Colors.white : AppColors.textSecondary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'My Applications',
                          style: TextStyle(
                            color: controller.selectedTab.value == 1 ? Colors.white : AppColors.navyText,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                        if (controller.myApplications.isNotEmpty) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: controller.selectedTab.value == 1 ? Colors.white : AppColors.accentOrange,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '${controller.myApplications.length}',
                              style: TextStyle(
                                color: controller.selectedTab.value == 1 ? AppColors.primaryBlue : Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ],
          )),
    );
  }

  Widget _buildApplicationsList(BuildContext context) {
    if (controller.isLoadingApplications.value) {
      return const Center(child: CircularProgressIndicator());
    }

    if (controller.myApplications.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: const BoxDecoration(
                  color: AppColors.tintBlue,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.assignment_outlined, size: 40, color: AppColors.primaryBlue),
              ),
              const SizedBox(height: 16),
              const Text(
                'No Loan Applications Yet',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.navyText),
              ),
              const SizedBox(height: 8),
              const Text(
                'You have not submitted any loan applications yet.\nUse our instant EMI calculator to submit an application with KYC documents.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.add_circle_outline_rounded, color: Colors.white, size: 18),
                label: const Text('Apply for Loan Now', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                onPressed: () => controller.selectedTab.value = 0,
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async => await controller.fetchMyApplications(),
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: controller.myApplications.length,
        separatorBuilder: (_, __) => const SizedBox(height: 14),
        itemBuilder: (context, index) {
          final app = controller.myApplications[index];
          final id = app['id'] ?? 'LN_APP_${index + 1}';
          final amount = app['requestedAmount'] ?? app['amount'] ?? 0;
          final tenure = app['tenureMonths'] ?? app['tenure_months'] ?? 12;
          final purpose = app['purpose'] ?? 'Personal Loan';
          final status = (app['status'] ?? 'in_review').toString().toLowerCase();
          final disbursalStatus = app['disbursalStatus'] ?? app['disbursal_status'] ?? 'Pending Admin Verification & Sanction';
          final appliedAt = app['appliedAt'] ?? app['created_at'] ?? '';
          final userName = app['userName'] ?? 'FlamePay Member';
          final pan = app['pan'] ?? 'PAN';
          final bankAccount = app['bankAccountNumber'] ?? '---';
          final adminNotes = app['adminNotes'];

          Color statusColor = AppColors.accentOrange;
          Color statusBg = AppColors.tintOrange;
          String statusText = 'Pending Admin Sanction';
          IconData statusIcon = Icons.hourglass_top_rounded;

          if (status == 'disbursed') {
            statusColor = AppColors.success;
            statusBg = AppColors.tintGreen;
            statusText = 'Disbursed to Wallet / Bank';
            statusIcon = Icons.check_circle_rounded;
          } else if (status == 'approved' || status == 'sanctioned') {
            statusColor = AppColors.success;
            statusBg = AppColors.tintGreen;
            statusText = 'Approved & Sanctioned ✓';
            statusIcon = Icons.verified_rounded;
          } else if (status == 'rejected') {
            statusColor = AppColors.error;
            statusBg = AppColors.error.withValues(alpha: 0.1);
            statusText = 'Application Rejected';
            statusIcon = Icons.cancel_rounded;
          }

          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.border),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(id.toString(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.primaryBlue)),
                        if (appliedAt.toString().isNotEmpty)
                          Text(
                            appliedAt.toString().substring(0, appliedAt.toString().length > 10 ? 10 : appliedAt.toString().length),
                            style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                          ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: statusBg,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: statusColor.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(statusIcon, color: statusColor, size: 14),
                          const SizedBox(width: 4),
                          Text(statusText, style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ],
                ),
                const Divider(height: 20, color: AppColors.border),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Sanction Amount', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                        Text('₹${amount.toString()}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.navyText)),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text('Tenure & Purpose', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                        Text('${tenure.toString()}M • ${purpose.toString()}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.primaryBlue)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                // Timeline Stepper
                _buildTimelineStepper(status),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.tintBlue,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Applicant Name:', style: TextStyle(fontSize: 11.5, color: AppColors.textSecondary)),
                          Text(userName.toString(), style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.navyText, fontSize: 12)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('PAN & Bank A/C:', style: TextStyle(fontSize: 11.5, color: AppColors.textSecondary)),
                          Text('${pan.toString()} • ${bankAccount.toString()}', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.navyText, fontSize: 12)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Admin Disbursal Status:', style: TextStyle(fontSize: 11.5, color: AppColors.textSecondary)),
                          Flexible(
                            child: Text(
                              disbursalStatus.toString(),
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontWeight: FontWeight.bold, color: statusColor, fontSize: 11.5),
                            ),
                          ),
                        ],
                      ),
                      if (adminNotes != null && adminNotes.toString().isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Admin Remarks:', style: TextStyle(fontSize: 11.5, color: AppColors.textSecondary)),
                            Flexible(
                              child: Text(
                                adminNotes.toString(),
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.navyText, fontSize: 11),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTimelineStepper(String status) {
    bool isSubmitted = true;
    bool isReviewing = status == 'in_review' || status == 'interested';
    bool isSanctioned = status == 'approved' || status == 'sanctioned' || status == 'disbursed';
    bool isDisbursed = status == 'disbursed';
    bool isRejected = status == 'rejected';

    return Row(
      children: [
        _buildStepIndicator(
          title: 'KYC Sent',
          isDone: isSubmitted,
          isActive: false,
          isError: false,
        ),
        _buildStepLine(isDone: isSanctioned || isReviewing),
        _buildStepIndicator(
          title: isRejected ? 'Rejected' : 'Admin Review',
          isDone: isSanctioned,
          isActive: isReviewing,
          isError: isRejected,
        ),
        _buildStepLine(isDone: isDisbursed),
        _buildStepIndicator(
          title: 'Disbursed',
          isDone: isDisbursed,
          isActive: isSanctioned && !isDisbursed,
          isError: false,
        ),
      ],
    );
  }

  Widget _buildStepIndicator({
    required String title,
    required bool isDone,
    required bool isActive,
    required bool isError,
  }) {
    Color color = AppColors.border;
    IconData icon = Icons.circle_outlined;

    if (isError) {
      color = AppColors.error;
      icon = Icons.cancel;
    } else if (isDone) {
      color = AppColors.success;
      icon = Icons.check_circle_rounded;
    } else if (isActive) {
      color = AppColors.accentOrange;
      icon = Icons.timelapse_rounded;
    }

    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(height: 4),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: isDone || isActive ? AppColors.navyText : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepLine({required bool isDone}) {
    return Container(
      width: 24,
      height: 2,
      margin: const EdgeInsets.only(bottom: 14),
      color: isDone ? AppColors.success : AppColors.border,
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
            'Admin Sanction • Direct Bank / Wallet Disbursal',
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
    final authService = Get.isRegistered<AuthService>() ? Get.find<AuthService>() : null;
    final user = authService?.currentUser.value;

    final nameCtrl = TextEditingController(text: (user != null && user.name.isNotEmpty && user.name != 'User') ? user.name : '');
    final phoneCtrl = TextEditingController(text: (user != null && user.phone.isNotEmpty) ? user.phone : '');
    final panCtrl = TextEditingController(text: (user?.pan != null && user!.pan!.isNotEmpty) ? user.pan! : '');
    final aadhaarCtrl = TextEditingController(text: (user?.aadhaar != null && user!.aadhaar!.isNotEmpty) ? user.aadhaar! : '');
    final accountCtrl = TextEditingController();
    final ifscCtrl = TextEditingController();
    final companyCtrl = TextEditingController();
    final incomeCtrl = TextEditingController();
    String purpose = 'Personal Expense';
    String employmentType = 'Salaried';

    // 4 Mandatory Loan Approval Documents
    File? panFile;
    File? aadhaarFile;
    File? salarySlipFile;
    File? bankStatementFile;

    String panSub = 'Upload clear photo or PDF';
    String aadhaarSub = 'Upload Government ID proof';
    String salarySlipSub = 'Last 3 months salary slip or ITR';
    String bankStatementSub = 'Official bank PDF statement';

    bool panUploaded = false;
    bool aadhaarUploaded = false;
    bool salarySlipUploaded = false;
    bool bankStatementUploaded = false;

    Future<void> pickLoanDoc(String docType, StateSetter setSheetState) async {
      final picker = ImagePicker();
      Get.bottomSheet(
        Container(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 44, height: 4, decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 16),
              const Text('Upload Document', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppColors.navyText)),
              const SizedBox(height: 4),
              const Text('Select real document photo or PDF for loan underwriting', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              const SizedBox(height: 18),
              ListTile(
                leading: Container(
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(color: AppColors.tintBlue, shape: BoxShape.circle),
                  child: const Icon(Icons.camera_alt_rounded, color: AppColors.primaryBlue),
                ),
                title: const Text('Take Photo (Camera)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                subtitle: const Text('Capture clear photo with your phone camera', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                onTap: () async {
                  Get.back();
                  try {
                    final photo = await picker.pickImage(source: ImageSource.camera, imageQuality: 85);
                    if (photo != null) {
                      final f = File(photo.path);
                      final len = await f.length();
                      if (len < 20 * 1024) {
                        Get.snackbar(
                          'Documents Sahi Se Upload Karo',
                          'Photo bohot chhoti ya khali lag rahi hai (' + (len / 1024).toFixed(1) + ' KB). Kripya original document ki saaf photo upload karein.',
                          backgroundColor: AppColors.error.withValues(alpha: 0.15),
                          colorText: AppColors.error,
                          snackPosition: SnackPosition.BOTTOM,
                          margin: const EdgeInsets.all(16),
                        );
                        return;
                      }
                      setSheetState(() {
                        final sizeKb = (len / 1024).toFixed(1);
                        final name = photo.name;
                        if (docType == 'pan') {
                          panFile = f;
                          panUploaded = true;
                          panSub = name + ' (' + sizeKb + ' KB)';
                        } else if (docType == 'aadhaar') {
                          aadhaarFile = f;
                          aadhaarUploaded = true;
                          aadhaarSub = name + ' (' + sizeKb + ' KB)';
                        } else if (docType == 'salary') {
                          salarySlipFile = f;
                          salarySlipUploaded = true;
                          salarySlipSub = name + ' (' + sizeKb + ' KB)';
                        } else if (docType == 'bank') {
                          bankStatementFile = f;
                          bankStatementUploaded = true;
                          bankStatementSub = name + ' (' + sizeKb + ' KB)';
                        }
                      });
                    }
                  } catch (e) {
                    Get.snackbar('Notice', 'Could not open camera: ' + e.toString());
                  }
                },
              ),
              const Divider(height: 16),
              ListTile(
                leading: Container(
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(color: AppColors.tintOrange, shape: BoxShape.circle),
                  child: const Icon(Icons.photo_library_rounded, color: AppColors.accentOrange),
                ),
                title: const Text('Choose from Gallery', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                subtitle: const Text('Select clear image from gallery', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                onTap: () async {
                  Get.back();
                  try {
                    final photo = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
                    if (photo != null) {
                      final f = File(photo.path);
                      final len = await f.length();
                      if (len < 20 * 1024) {
                        Get.snackbar(
                          'Documents Sahi Se Upload Karo',
                          'Photo bohot chhoti ya invalid file lag rahi hai (' + (len / 1024).toFixed(1) + ' KB). Kripya original document ki saaf photo upload karein.',
                          backgroundColor: AppColors.error.withValues(alpha: 0.15),
                          colorText: AppColors.error,
                          snackPosition: SnackPosition.BOTTOM,
                          margin: const EdgeInsets.all(16),
                        );
                        return;
                      }
                      setSheetState(() {
                        final sizeKb = (len / 1024).toFixed(1);
                        final name = photo.name;
                        if (docType == 'pan') {
                          panFile = f;
                          panUploaded = true;
                          panSub = name + ' (' + sizeKb + ' KB)';
                        } else if (docType == 'aadhaar') {
                          aadhaarFile = f;
                          aadhaarUploaded = true;
                          aadhaarSub = name + ' (' + sizeKb + ' KB)';
                        } else if (docType == 'salary') {
                          salarySlipFile = f;
                          salarySlipUploaded = true;
                          salarySlipSub = name + ' (' + sizeKb + ' KB)';
                        } else if (docType == 'bank') {
                          bankStatementFile = f;
                          bankStatementUploaded = true;
                          bankStatementSub = name + ' (' + sizeKb + ' KB)';
                        }
                      });
                    }
                  } catch (e) {
                    Get.snackbar('Notice', 'Could not open gallery: ' + e.toString());
                  }
                },
              ),
              const Divider(height: 16),
              ListTile(
                leading: Container(
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(color: Color(0xFFF3E8FF), shape: BoxShape.circle),
                  child: const Icon(Icons.picture_as_pdf_rounded, color: Color(0xFF9333EA)),
                ),
                title: const Text('Pick PDF Document', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                subtitle: const Text('Select official PDF file', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                onTap: () async {
                  Get.back();
                  try {
                    final result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png']);
                    if (result != null && result.files.single.path != null) {
                      final f = File(result.files.single.path!);
                      final len = await f.length();
                      if (len < 10 * 1024) {
                        Get.snackbar(
                          'Documents Sahi Se Upload Karo',
                          'PDF file bohot chhoti ya empty lag rahi hai. Kripya valid PDF document upload karein.',
                          backgroundColor: AppColors.error.withValues(alpha: 0.15),
                          colorText: AppColors.error,
                          snackPosition: SnackPosition.BOTTOM,
                          margin: const EdgeInsets.all(16),
                        );
                        return;
                      }
                      setSheetState(() {
                        final sizeKb = (len / 1024).toFixed(1);
                        final name = result.files.single.name;
                        if (docType == 'pan') {
                          panFile = f;
                          panUploaded = true;
                          panSub = name + ' (' + sizeKb + ' KB)';
                        } else if (docType == 'aadhaar') {
                          aadhaarFile = f;
                          aadhaarUploaded = true;
                          aadhaarSub = name + ' (' + sizeKb + ' KB)';
                        } else if (docType == 'salary') {
                          salarySlipFile = f;
                          salarySlipUploaded = true;
                          salarySlipSub = name + ' (' + sizeKb + ' KB)';
                        } else if (docType == 'bank') {
                          bankStatementFile = f;
                          bankStatementUploaded = true;
                          bankStatementSub = name + ' (' + sizeKb + ' KB)';
                        }
                      });
                    }
                  } catch (e) {
                    Get.snackbar('Notice', 'Could not pick file: ' + e.toString());
                  }
                },
              ),
            ],
          ),
        ),
      );
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setSheetState) => Material(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(28),
            topRight: Radius.circular(28),
          ),
          clipBehavior: Clip.antiAlias,
          child: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.90,
            ),
            padding: EdgeInsets.fromLTRB(20, 16, 20, MediaQuery.of(context).viewInsets.bottom + 20),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 44,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.border,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Instant Loan Application & KYC',
                              style: AppTypography.title.copyWith(color: AppColors.navyText, fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Sanction: ' + formatCurrency(controller.loanAmount.value) + ' • Tenure: ' + controller.tenureMonths.value.toString() + ' Months',
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primaryBlue),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close_rounded, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Section 1: Personal Details
                  const Text('1. APPLICANT DETAILS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primaryBlue, letterSpacing: 0.5)),
                  const SizedBox(height: 8),

                  TextField(
                    controller: nameCtrl,
                    decoration: InputDecoration(
                      labelText: 'Full Name (as per PAN)',
                      hintText: 'Enter your full legal name',
                      prefixIcon: const Icon(Icons.person_rounded, color: AppColors.primaryBlue, size: 20),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 10),

                  TextField(
                    controller: phoneCtrl,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: 'Registered Mobile Number',
                      hintText: 'e.g. 9876543210',
                      prefixIcon: const Icon(Icons.phone_android_rounded, color: AppColors.primaryBlue, size: 20),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 10),

                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: panCtrl,
                          textCapitalization: TextCapitalization.characters,
                          decoration: InputDecoration(
                            labelText: 'PAN Card Number',
                            hintText: 'e.g. ABCDE1234F',
                            prefixIcon: const Icon(Icons.badge_rounded, color: AppColors.primaryBlue, size: 20),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: aadhaarCtrl,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Aadhaar Number',
                            hintText: '12 Digits',
                            prefixIcon: const Icon(Icons.fingerprint_rounded, color: AppColors.primaryBlue, size: 20),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Section 2: Banking & Employment
                  const Text('2. DISBURSAL BANK & EMPLOYMENT', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primaryBlue, letterSpacing: 0.5)),
                  const SizedBox(height: 8),

                  Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: TextField(
                          controller: accountCtrl,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Disbursal Bank A/C Number',
                            hintText: 'Enter bank account',
                            prefixIcon: const Icon(Icons.account_balance_rounded, color: AppColors.primaryBlue, size: 20),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        flex: 2,
                        child: TextField(
                          controller: ifscCtrl,
                          textCapitalization: TextCapitalization.characters,
                          decoration: InputDecoration(
                            labelText: 'Bank IFSC Code',
                            hintText: 'e.g. SBIN0001234',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: employmentType,
                          decoration: InputDecoration(
                            labelText: 'Employment Type',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          ),
                          items: ['Salaried', 'Self-Employed', 'Business Owner', 'Professional']
                              .map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontSize: 13))))
                              .toList(),
                          onChanged: (v) => setSheetState(() => employmentType = v ?? 'Salaried'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: incomeCtrl,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Monthly In-Hand Income',
                            hintText: 'e.g. 50000',
                            prefixIcon: const Icon(Icons.currency_rupee_rounded, color: AppColors.primaryBlue, size: 18),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  TextField(
                    controller: companyCtrl,
                    decoration: InputDecoration(
                      labelText: 'Company / Business Name',
                      hintText: 'Enter employer or business',
                      prefixIcon: const Icon(Icons.business_rounded, color: AppColors.primaryBlue, size: 20),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 10),

                  DropdownButtonFormField<String>(
                    value: purpose,
                    decoration: InputDecoration(
                      labelText: 'Loan Purpose',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                    items: ['Personal Expense', 'Home Renovation', 'Medical Emergency', 'Education', 'Debt Consolidation', 'Travel']
                        .map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontSize: 13))))
                        .toList(),
                    onChanged: (v) => setSheetState(() => purpose = v ?? 'Personal Expense'),
                  ),
                  const SizedBox(height: 18),

                  // Section 3: 4 Mandatory KYC & Income Documents
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('3. MANDATORY KYC & INCOME DOCUMENTS (4/4)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primaryBlue, letterSpacing: 0.5)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.tintGreen,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text('Required by Admin', style: TextStyle(fontSize: 10, color: AppColors.success, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Doc 1: PAN Card
                  _buildDocUploadCard(
                    title: 'PAN Card Document',
                    subtitle: panSub,
                    icon: Icons.badge_rounded,
                    isUploaded: panUploaded,
                    onTap: () => pickLoanDoc('pan', setSheetState),
                  ),
                  const SizedBox(height: 8),

                  // Doc 2: Aadhaar Card
                  _buildDocUploadCard(
                    title: 'Aadhaar Card (Front & Back)',
                    subtitle: aadhaarSub,
                    icon: Icons.credit_card_rounded,
                    isUploaded: aadhaarUploaded,
                    onTap: () => pickLoanDoc('aadhaar', setSheetState),
                  ),
                  const SizedBox(height: 8),

                  // Doc 3: Salary Slip
                  _buildDocUploadCard(
                    title: 'Salary Slip / Income Proof',
                    subtitle: salarySlipSub,
                    icon: Icons.receipt_long_rounded,
                    isUploaded: salarySlipUploaded,
                    onTap: () => pickLoanDoc('salary', setSheetState),
                  ),
                  const SizedBox(height: 8),

                  // Doc 4: Bank Statement
                  _buildDocUploadCard(
                    title: 'Bank Statement (Last 6 Months)',
                    subtitle: bankStatementSub,
                    icon: Icons.account_balance_rounded,
                    isUploaded: bankStatementUploaded,
                    onTap: () => pickLoanDoc('bank', setSheetState),
                  ),
                  const SizedBox(height: 20),

                  // Submit Button
                  Obx(() => AppButton(
                        text: 'Submit Application for Admin Sanction',
                        isLoading: controller.isSubmitting.value,
                        type: ButtonType.orangePrimary,
                        onPressed: () {
                          final pan = panCtrl.text.trim().toUpperCase();
                          final aadhaar = aadhaarCtrl.text.replaceAll(' ', '');
                          final account = accountCtrl.text.trim();

                          if (nameCtrl.text.trim().isEmpty) {
                            Get.snackbar('Validation', 'Please enter your Full Name', backgroundColor: Colors.orange.shade100);
                            return;
                          }
                          final panRegex = RegExp(r'^[A-Z]{5}[0-9]{4}[A-Z]{1}$');
                          if (!panRegex.hasMatch(pan)) {
                            Get.snackbar('Validation', 'Please enter a valid 10-character PAN Card number (e.g. ABCDE1234F)', backgroundColor: Colors.orange.shade100);
                            return;
                          }
                          if (aadhaar.length != 12 || !RegExp(r'^[0-9]{12}$').hasMatch(aadhaar)) {
                            Get.snackbar('Validation', 'Please enter a valid 12-digit Aadhaar number', backgroundColor: Colors.orange.shade100);
                            return;
                          }
                          if (account.length < 8) {
                            Get.snackbar('Validation', 'Please enter a valid Bank Account Number', backgroundColor: Colors.orange.shade100);
                            return;
                          }
                          if (!panUploaded || !aadhaarUploaded || !salarySlipUploaded || !bankStatementUploaded) {
                            Get.snackbar(
                              'Documents Sahi Se Upload Karo',
                              'Sabhi 4 zaroori documents (PAN, Aadhaar, Salary Slip, Bank Statement) attach karna anivarya hai.',
                              backgroundColor: Colors.orange.shade100,
                            );
                            return;
                          }

                          controller.applyForLoan(
                            purpose: purpose,
                            pan: pan,
                            bankAccount: account,
                            ifsc: ifscCtrl.text.trim().toUpperCase(),
                            employmentType: employmentType,
                            monthlyIncome: double.tryParse(incomeCtrl.text.trim()) ?? 50000.0,
                            companyName: companyCtrl.text.trim(),
                            aadhaar: aadhaar,
                            userName: nameCtrl.text.trim(),
                            userPhone: phoneCtrl.text.trim(),
                            userEmail: user?.email,
                            documents: {
                              'panCard': {'name': panFile != null ? panFile!.path.split(Platform.pathSeparator).last : 'PAN_' + pan + '.pdf', 'status': 'submitted', 'size': panSub},
                              'aadhaarCard': {'name': aadhaarFile != null ? aadhaarFile!.path.split(Platform.pathSeparator).last : 'AADHAAR_FRONT_BACK.pdf', 'status': 'submitted', 'size': aadhaarSub},
                              'salarySlip': {'name': salarySlipFile != null ? salarySlipFile!.path.split(Platform.pathSeparator).last : 'Salary_Slip.pdf', 'status': 'submitted', 'size': salarySlipSub},
                              'bankStatement': {'name': bankStatementFile != null ? bankStatementFile!.path.split(Platform.pathSeparator).last : 'Bank_Statement.pdf', 'status': 'submitted', 'size': bankStatementSub},
                            },
                          );
                        },
                      )),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

    Widget _buildDocUploadCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isUploaded,
    required VoidCallback onTap,
  }) {
    return Material(
      color: isUploaded ? AppColors.tintGreen.withValues(alpha: 0.3) : AppColors.surface,
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isUploaded ? AppColors.success.withValues(alpha: 0.4) : AppColors.border),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: isUploaded ? AppColors.tintGreen : AppColors.tintBlue,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: isUploaded ? AppColors.success : AppColors.primaryBlue, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppTypography.caption.copyWith(fontWeight: FontWeight.bold, color: AppColors.navyText, fontSize: 13)),
                    const SizedBox(height: 2),
                    Text(subtitle, style: TextStyle(fontSize: 11, color: isUploaded ? AppColors.success : AppColors.textSecondary)),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              isUploaded
                  ? const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check_circle_rounded, color: AppColors.success, size: 20),
                        SizedBox(width: 4),
                        Text('Attached', style: TextStyle(color: AppColors.success, fontSize: 11, fontWeight: FontWeight.bold)),
                      ],
                    )
                  : Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppColors.primaryBlue,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text('Upload', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
