import '../../../data/models/cibil_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/state_view.dart';
import '../cibil_controller.dart';

class CibilView extends GetView<CibilController> {
  const CibilView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Credit Health & CIBIL', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.primaryBlue,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: controller.refreshScore,
            tooltip: 'Refresh Score',
          ),
          IconButton(
            icon: const Icon(Icons.download_rounded),
            onPressed: controller.downloadReport,
            tooltip: 'Download Report',
          ),
        ],
      ),
      body: Obx(() {
        if (!controller.hasCheckedScore.value || controller.cibilReport.value == null) {
          return _buildPanInputForm(context);
        }

        final report = controller.cibilReport.value!;
        return _buildReportView(context, report);
      }),
    );
  }

  Widget _buildPanInputForm(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Trust Banner
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primaryBlue.withValues(alpha: 0.08),
                  AppColors.accentOrange.withValues(alpha: 0.08),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.primaryBlue.withValues(alpha: 0.2)),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: const BoxDecoration(
                        color: AppColors.primaryBlue,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.verified_user_rounded, color: Colors.white, size: 24),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Check Free Credit Score',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.navyText,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'Instant bureau report • Zero impact on score',
                            style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                // Bureau Badges
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildBureauPill('CIBIL'),
                      const Text('•', style: TextStyle(color: AppColors.textSecondary)),
                      _buildBureauPill('EXPERIAN'),
                      const Text('•', style: TextStyle(color: AppColors.textSecondary)),
                      _buildBureauPill('CRIF HIGHMARK'),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // PAN Details Input Card
          Container(
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
                const Text(
                  'Enter Your Details',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.navyText,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Details are verified directly with credit bureaus',
                  style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
                ),

                const SizedBox(height: 20),

                // PAN Number Input
                const Text(
                  'PAN Card Number',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.navyText,
                  ),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: controller.panController,
                  textCapitalization: TextCapitalization.characters,
                  maxLength: 10,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2.0,
                    fontSize: 16,
                  ),
                  decoration: InputDecoration(
                    hintText: 'ABCDE1234F',
                    hintStyle: TextStyle(
                      color: Colors.grey.shade400,
                      letterSpacing: 1.5,
                      fontWeight: FontWeight.normal,
                    ),
                    counterText: '',
                    prefixIcon: const Icon(Icons.credit_card_rounded, color: AppColors.primaryBlue),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.primaryBlue, width: 2),
                    ),
                    filled: true,
                    fillColor: AppColors.background,
                  ),
                ),

                const SizedBox(height: 16),

                // Full Name Input
                const Text(
                  'Full Name (as per PAN Card)',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.navyText,
                  ),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: controller.nameController,
                  textCapitalization: TextCapitalization.words,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                  decoration: InputDecoration(
                    hintText: 'e.g. Rahul Sharma',
                    hintStyle: TextStyle(color: Colors.grey.shade400, fontWeight: FontWeight.normal),
                    prefixIcon: const Icon(Icons.person_outline_rounded, color: AppColors.primaryBlue),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.primaryBlue, width: 2),
                    ),
                    filled: true,
                    fillColor: AppColors.background,
                  ),
                ),

                const SizedBox(height: 16),

                // Date of Birth Input
                const Text(
                  'Date of Birth',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.navyText,
                  ),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: controller.dobController,
                  readOnly: true,
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime(1995, 1, 1),
                      firstDate: DateTime(1940),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) {
                      controller.dobController.text =
                          "${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}";
                    }
                  },
                  decoration: InputDecoration(
                    hintText: 'DD/MM/YYYY',
                    hintStyle: TextStyle(color: Colors.grey.shade400),
                    prefixIcon: const Icon(Icons.calendar_month_outlined, color: AppColors.primaryBlue),
                    suffixIcon: const Icon(Icons.arrow_drop_down_rounded, color: AppColors.textSecondary),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.primaryBlue, width: 2),
                    ),
                    filled: true,
                    fillColor: AppColors.background,
                  ),
                ),

                const SizedBox(height: 18),

                // Consent Checkbox
                Obx(() => Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 24,
                          height: 24,
                          child: Checkbox(
                            value: controller.agreedToConsent.value,
                            activeColor: AppColors.primaryBlue,
                            onChanged: (val) => controller.agreedToConsent.value = val ?? false,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: GestureDetector(
                            onTap: () =>
                                controller.agreedToConsent.value = !controller.agreedToConsent.value,
                            child: Text(
                              'I authorize FlamePay to retrieve my credit score and report from credit bureaus (CIBIL/Experian/CRIF) for credit assessment.',
                              style: AppTypography.caption.copyWith(
                                color: AppColors.navyText,
                                fontSize: 11.5,
                                height: 1.35,
                              ),
                            ),
                          ),
                        ),
                      ],
                    )),

                const SizedBox(height: 22),

                // Fetch Score Button
                Obx(() => AppButton(
                      text: 'Check Free Credit Score',
                      type: ButtonType.orangePrimary,
                      isLoading: controller.isChecking.value,
                      icon: const Icon(Icons.speed_rounded, color: Colors.white, size: 20),
                      onPressed: controller.checkScoreForPan,
                    )),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Trust Features Grid
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                _buildTrustItem(
                  Icons.shield_outlined,
                  'Safe & Secure (Soft Enquiry)',
                  'Checking credit score will NOT decrease your score.',
                ),
                const Divider(height: 20, color: AppColors.border),
                _buildTrustItem(
                  Icons.bar_chart_rounded,
                  'Personalized Health Report',
                  'Get individual scores, factors, and improvement tips for your PAN.',
                ),
                const Divider(height: 20, color: AppColors.border),
                _buildTrustItem(
                  Icons.lock_outline_rounded,
                  '256-bit Bank Grade Encryption',
                  'Your PAN Card data is strictly encrypted and protected.',
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildBureauPill(String name) {
    return Text(
      name,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w800,
        color: AppColors.navyText,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildTrustItem(IconData icon, String title, String subtitle) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.tintBlue,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.primaryBlue, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppColors.navyText,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: AppTypography.caption.copyWith(color: AppColors.textSecondary, fontSize: 11.5),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildReportView(BuildContext context, CibilScoreModel report) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Arc & Score Gauge
          _buildScoreHeader(report),

          const SizedBox(height: 16),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Download & Refresh Quick Bar
                _buildReportMetaBar(report),

                const SizedBox(height: 16),

                // Button to Check Another PAN
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                    side: const BorderSide(color: AppColors.primaryBlue),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: controller.resetToInputForm,
                  icon: const Icon(Icons.switch_account_outlined, color: AppColors.primaryBlue),
                  label: const Text(
                    'Check Score for Another PAN Card',
                    style: TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.bold),
                  ),
                ),

                const SizedBox(height: 24),

                // Section Title: Factors Affecting Score
                Text(
                  'Credit Factors Breakdown',
                  style: AppTypography.title.copyWith(color: AppColors.navyText, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  '5 key factors tracked by credit bureaus',
                  style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
                ),

                const SizedBox(height: 14),

                // List of Factors
                ...report.factors.map((factor) => _buildFactorCard(factor)),

                const SizedBox(height: 24),

                // Score Improvement Tips
                _buildTipsSection(report.tips),

                const SizedBox(height: 24),

                // Download Full Report CTA
                AppButton(
                  text: 'Download Official CIBIL Report',
                  type: ButtonType.blueSecondary,
                  icon: const Icon(Icons.file_download_outlined, color: Colors.white, size: 20),
                  onPressed: controller.downloadReport,
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreHeader(CibilScoreModel report) {
    return Container(
      decoration: const BoxDecoration(
        gradient: AppColors.blueGradient,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 28),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.verified_user_rounded, color: Colors.white, size: 13),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          controller.currentPan.value.isNotEmpty
                              ? 'PAN: ${controller.currentPan.value}'
                              : 'ID: ${report.reportId}',
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.micro.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Updated: ${report.lastUpdated}',
                  style: AppTypography.micro.copyWith(color: Colors.white),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Circular Score Meter
          Container(
            width: 170,
            height: 170,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.1),
              border: Border.all(color: Colors.white.withValues(alpha: 0.25), width: 8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${report.score}',
                    style: AppTypography.display.copyWith(
                      color: Colors.white,
                      fontSize: 44,
                      fontWeight: FontWeight.w900,
                      height: 1.0,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.success,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      report.rating.toUpperCase(),
                      style: AppTypography.micro.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Out of 900',
                    style: AppTypography.micro.copyWith(color: Colors.white.withValues(alpha: 0.7)),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          Text(
            'High chance of instant approval on loans & cards',
            textAlign: TextAlign.center,
            style: AppTypography.caption.copyWith(color: Colors.white.withValues(alpha: 0.9), fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildReportMetaBar(CibilScoreModel report) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [AppColors.cardShadow],
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: const BoxDecoration(
                    color: AppColors.tintBlue,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.event_repeat_rounded, color: AppColors.primaryBlue, size: 18),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Next Free Refresh', style: AppTypography.micro.copyWith(color: AppColors.textSecondary)),
                      Text(report.nextRefreshDate, style: AppTypography.bodyBold.copyWith(fontSize: 12.5)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          TextButton.icon(
            onPressed: controller.refreshScore,
            icon: const Icon(Icons.refresh_rounded, size: 16, color: AppColors.primaryBlue),
            label: const Text('Check Now', style: TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildFactorCard(CibilFactorModel factor) {
    Color statusColor;
    switch (factor.status.toLowerCase()) {
      case 'excellent':
        statusColor = AppColors.success;
        break;
      case 'good':
        statusColor = AppColors.primaryBlue;
        break;
      case 'average':
        statusColor = AppColors.accentOrange;
        break;
      default:
        statusColor = AppColors.flameRed;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  factor.title,
                  style: AppTypography.bodyBold.copyWith(color: AppColors.navyText),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  factor.status,
                  style: AppTypography.micro.copyWith(color: statusColor, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  factor.value,
                  style: AppTypography.caption.copyWith(color: AppColors.navyText, fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Impact: ${factor.impact}',
                style: AppTypography.micro.copyWith(color: AppColors.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: factor.scorePercent,
              backgroundColor: AppColors.border,
              valueColor: AlwaysStoppedAnimation<Color>(statusColor),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTipsSection(List<String> tips) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.tintBlue,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.primaryBlue.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.tips_and_updates_rounded, color: AppColors.primaryBlue, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Tips to Boost Your CIBIL Score',
                  style: AppTypography.title.copyWith(color: AppColors.navyText, fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...tips.map((tip) => Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        tip,
                        style: AppTypography.caption.copyWith(color: AppColors.navyText, height: 1.4),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}
