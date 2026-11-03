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
    final authService = Get.isRegistered<AuthService>() ? Get.find<AuthService>() : null;
    final user = authService?.currentUser.value;
    final defaultName = (user != null && user.name.isNotEmpty && user.name != 'User') ? user.name : 'FlamePay Member';

    final nameCtrl = TextEditingController(text: defaultName);
    final phoneCtrl = TextEditingController(text: (user != null && user.phone.isNotEmpty) ? user.phone : '+91 9876543210');
    final panCtrl = TextEditingController(text: (user?.pan != null && user!.pan!.isNotEmpty) ? user.pan! : 'RRQPS8997J');
    final aadhaarCtrl = TextEditingController(text: (user?.aadhaar != null && user!.aadhaar!.isNotEmpty) ? user.aadhaar! : '5678 9012 3456');
    final accountCtrl = TextEditingController(text: '32823806111');
    final ifscCtrl = TextEditingController(text: 'HDFC0001234');
    final companyCtrl = TextEditingController(text: 'Corporate Private Limited');
    final incomeCtrl = TextEditingController(text: '85000');
    String purpose = 'Personal Expense';
    String employmentType = 'Salaried';

    // 4 Mandatory Loan Approval Documents
    bool panUploaded = true;
    bool aadhaarUploaded = true;
    bool salarySlipUploaded = true;
    bool bankStatementUploaded = true;

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
                              'Sanction: ₹${controller.loanAmount.value.toInt()} • Tenure: ${controller.tenureMonths.value} Months',
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primaryBlue),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded, color: AppColors.textSecondary),
                        onPressed: () => Get.back(),
                      ),
                    ],
                  ),
                  const Divider(height: 20, color: AppColors.border),

                  // Section 1: Applicant Profile
                  const Text('1. APPLICANT DETAILS (AUTHENTICATED USER)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primaryBlue, letterSpacing: 0.5)),
                  const SizedBox(height: 10),
                  TextField(
                    controller: nameCtrl,
                    decoration: InputDecoration(
                      labelText: 'Full Name as per PAN',
                      prefixIcon: const Icon(Icons.person_rounded, size: 20, color: AppColors.primaryBlue),
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
                      prefixIcon: const Icon(Icons.phone_android_rounded, size: 20, color: AppColors.primaryBlue),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Section 2: Identity & Bank
                  const Text('2. IDENTITY & BANK DISBURSAL', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primaryBlue, letterSpacing: 0.5)),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: panCtrl,
                          textCapitalization: TextCapitalization.characters,
                          decoration: InputDecoration(
                            labelText: 'PAN Number',
                            prefixIcon: const Icon(Icons.badge_rounded, size: 20, color: AppColors.primaryBlue),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: aadhaarCtrl,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Aadhaar Number',
                            prefixIcon: const Icon(Icons.credit_card_rounded, size: 20, color: AppColors.primaryBlue),
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
                        flex: 3,
                        child: TextField(
                          controller: accountCtrl,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Bank Account Number',
                            prefixIcon: const Icon(Icons.account_balance_rounded, size: 20, color: AppColors.primaryBlue),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 2,
                        child: TextField(
                          controller: ifscCtrl,
                          textCapitalization: TextCapitalization.characters,
                          decoration: InputDecoration(
                            labelText: 'IFSC Code',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Section 3: Income & Purpose
                  const Text('3. INCOME & PURPOSE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primaryBlue, letterSpacing: 0.5)),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: employmentType,
                          decoration: InputDecoration(
                            labelText: 'Employment',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          ),
                          items: ['Salaried', 'Self-Employed', 'Business']
                              .map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontSize: 13))))
                              .toList(),
                          onChanged: (v) => setSheetState(() => employmentType = v ?? 'Salaried'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: incomeCtrl,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Monthly Income (₹)',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    initialValue: purpose,
                    decoration: InputDecoration(
                      labelText: 'Loan Purpose',
                      prefixIcon: const Icon(Icons.wallet_rounded, size: 20, color: AppColors.primaryBlue),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                    items: ['Personal Expense', 'Medical Emergency', 'Home Renovation', 'Education', 'Debt Consolidation', 'Business Expansion']
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (v) => setSheetState(() => purpose = v ?? 'Personal Expense'),
                  ),
                  const SizedBox(height: 16),

                  // Section 4: Mandatory Document Uploads
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('4. MANDATORY DOCUMENTS (FOR APPROVAL)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primaryBlue, letterSpacing: 0.5)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.tintGreen,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text('4/4 Ready ✓', style: TextStyle(color: AppColors.success, fontSize: 11, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Doc 1: PAN Card
                  _buildDocUploadCard(
                    title: 'PAN Card Document',
                    subtitle: panUploaded ? 'PAN_${panCtrl.text.trim().toUpperCase()}.pdf (1.4 MB)' : 'Upload clear photo or PDF',
                    icon: Icons.badge_rounded,
                    isUploaded: panUploaded,
                    onTap: () => setSheetState(() => panUploaded = !panUploaded),
                  ),
                  const SizedBox(height: 8),

                  // Doc 2: Aadhaar Card
                  _buildDocUploadCard(
                    title: 'Aadhaar Card (Front & Back)',
                    subtitle: aadhaarUploaded ? 'AADHAAR_DOCUMENT_VERIFIED.pdf (2.1 MB)' : 'Upload Government ID proof',
                    icon: Icons.credit_card_rounded,
                    isUploaded: aadhaarUploaded,
                    onTap: () => setSheetState(() => aadhaarUploaded = !aadhaarUploaded),
                  ),
                  const SizedBox(height: 8),

                  // Doc 3: Salary Slip
                  _buildDocUploadCard(
                    title: 'Salary Slip / Income Proof',
                    subtitle: salarySlipUploaded ? 'Salary_Slip_Last_3Months.pdf (1.8 MB)' : 'Last 3 months salary slip or ITR',
                    icon: Icons.receipt_long_rounded,
                    isUploaded: salarySlipUploaded,
                    onTap: () => setSheetState(() => salarySlipUploaded = !salarySlipUploaded),
                  ),
                  const SizedBox(height: 8),

                  // Doc 4: Bank Statement
                  _buildDocUploadCard(
                    title: 'Bank Statement (Last 6 Months)',
                    subtitle: bankStatementUploaded ? 'Bank_Statement_6Months.pdf (3.2 MB)' : 'Official bank PDF statement',
                    icon: Icons.account_balance_rounded,
                    isUploaded: bankStatementUploaded,
                    onTap: () => setSheetState(() => bankStatementUploaded = !bankStatementUploaded),
                  ),
                  const SizedBox(height: 20),

                  // Submit Button
                  Obx(() => AppButton(
                        text: 'Confirm & Disburse Now',
                        isLoading: controller.isSubmitting.value,
                        type: ButtonType.orangePrimary,
                        onPressed: () {
                          if (panCtrl.text.trim().length != 10) {
                            Get.snackbar('Validation', 'Please enter a valid 10-character PAN Card number', backgroundColor: Colors.orange.shade100);
                            return;
                          }
                          if (accountCtrl.text.trim().length < 9) {
                            Get.snackbar('Validation', 'Please enter a valid Bank Account Number', backgroundColor: Colors.orange.shade100);
                            return;
                          }
                          if (!panUploaded || !aadhaarUploaded || !salarySlipUploaded || !bankStatementUploaded) {
                            Get.snackbar('Documents Missing', 'All 4 mandatory documents must be attached for instant approval.', backgroundColor: Colors.orange.shade100);
                            return;
                          }

                          controller.applyForLoan(
                            purpose: purpose,
                            pan: panCtrl.text.trim().toUpperCase(),
                            bankAccount: accountCtrl.text.trim(),
                            ifsc: ifscCtrl.text.trim().toUpperCase(),
                            employmentType: employmentType,
                            monthlyIncome: double.tryParse(incomeCtrl.text.trim()) ?? 85000.0,
                            companyName: companyCtrl.text.trim(),
                            aadhaar: aadhaarCtrl.text.trim(),
                            userName: nameCtrl.text.trim(),
                            userPhone: phoneCtrl.text.trim(),
                            userEmail: user?.email,
                            documents: {
                              'panCard': {'name': 'PAN_${panCtrl.text.trim().toUpperCase()}.pdf', 'status': 'verified', 'size': '1.4 MB'},
                              'aadhaarCard': {'name': 'AADHAAR_DOCUMENT_FRONT_BACK.pdf', 'status': 'verified', 'size': '2.1 MB'},
                              'salarySlip': {'name': 'Salary_Slip_Last_3Months.pdf', 'status': 'verified', 'size': '1.8 MB'},
                              'bankStatement': {'name': 'Bank_Statement_Last_6Months.pdf', 'status': 'verified', 'size': '3.2 MB'},
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
