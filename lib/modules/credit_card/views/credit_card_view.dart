import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/models/credit_card_model.dart';
import '../../../data/models/user_model.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/state_view.dart';
import '../credit_card_controller.dart';

class CreditCardView extends GetView<CreditCardController> {
  const CreditCardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Credit Cards', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.primaryBlue,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category Selector Chips Bar
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Obx(() => Row(
                    children: controller.categories.map((cat) {
                      final isSelected = controller.selectedCategory.value == cat;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: ChoiceChip(
                          label: Text(cat),
                          selected: isSelected,
                          onSelected: (_) => controller.onCategoryChanged(cat),
                          selectedColor: AppColors.primaryBlue,
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : AppColors.navyText,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                          backgroundColor: AppColors.tintBlue,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        ),
                      );
                    }).toList(),
                  )),
            ),
          ),

          // Cards List
          Expanded(
            child: Obx(() {
              if (controller.viewState.value == ViewState.loading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.viewState.value == ViewState.error || controller.cards.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.credit_card_off_rounded, size: 48, color: AppColors.textMuted),
                      const SizedBox(height: 12),
                      Text('No Credit Cards Found', style: AppTypography.title),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () => controller.onCategoryChanged('All'),
                        child: const Text('Reset Filter'),
                      ),
                    ],
                  ),
                );
              }

              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Active Applications Tracker Card (if user has applied to any cards)
                  if (controller.appliedApplications.isNotEmpty) ...[
                    _buildActiveApplicationsSection(context),
                    const SizedBox(height: 12),
                  ],

                  // All Credit Cards List
                  ...controller.cards.map((card) => _buildCardItem(context, card)),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildCardItem(BuildContext context, CreditCardModel card) {
    Color startColor = AppColors.primaryBlue;
    Color endColor = AppColors.navyText;
    if (card.gradientHex.length >= 2) {
      startColor = Color(int.parse(card.gradientHex[0].replaceFirst('#', '0xFF')));
      endColor = Color(int.parse(card.gradientHex[1].replaceFirst('#', '0xFF')));
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [AppColors.cardShadow],
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Visual Card Area (Real Card Art or 3D Gradient Render)
          _buildCardVisual(card, startColor, endColor),

          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Bank Name & Category Tag
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      card.bank.toUpperCase(),
                      style: AppTypography.micro.copyWith(
                        color: AppColors.textSecondary,
                        letterSpacing: 1.1,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.tintBlue,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        card.category,
                        style: const TextStyle(
                          color: AppColors.primaryBlue,
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),

                // Card Title & Rewards Badge
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        card.name,
                        style: AppTypography.title.copyWith(
                          color: AppColors.navyText,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (card.earnUpTo != null && card.earnUpTo!.isNotEmpty)
                      Container(
                        margin: const EdgeInsets.only(left: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.tintOrange,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.accentOrange.withValues(alpha: 0.3)),
                        ),
                        child: Text(
                          card.earnUpTo!,
                          style: AppTypography.micro.copyWith(
                            color: AppColors.accentOrange,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),

                // Fees Overview Bar
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _feeItem('Joining Fee', card.joiningFee),
                      Container(width: 1, height: 24, color: AppColors.border),
                      _feeItem('Annual Fee', card.annualFee),
                      Container(width: 1, height: 24, color: AppColors.border),
                      _feeItem('Network', card.cardNetwork),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Key Features / Benefits
                if (card.benefits.isNotEmpty) ...[
                  Text(
                    'Key Benefits',
                    style: AppTypography.caption.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.navyText,
                    ),
                  ),
                  const SizedBox(height: 6),
                  ...card.benefits.take(3).map((b) => Padding(
                        padding: const EdgeInsets.only(bottom: 5.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 15),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                b,
                                style: AppTypography.caption.copyWith(
                                  color: AppColors.navyText,
                                  fontSize: 12,
                                  height: 1.3,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )),
                  const SizedBox(height: 8),
                ],

                // Eligibility Highlights (if present)
                if (card.eligibilityCriteria != null && card.eligibilityCriteria!.isNotEmpty) ...[
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.verified_outlined, size: 14, color: AppColors.primaryBlue),
                            const SizedBox(width: 6),
                            Text(
                              'Eligibility Criteria',
                              style: AppTypography.micro.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryBlue,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        ...card.eligibilityCriteria!.take(2).map((e) => Padding(
                              padding: const EdgeInsets.only(bottom: 2.0),
                              child: Text(
                                '• $e',
                                style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                              ),
                            )),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                ],

                // CTA Button (Deduplication aware: Shows active application if already applied)
                Obx(() {
                  final isApplied = card.productId != null && controller.appliedProductIds.contains(card.productId);
                  if (isApplied) {
                    final leadId = controller.productLeadIds[card.productId] ?? '';
                    return Column(
                      children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                          decoration: BoxDecoration(
                            color: AppColors.tintGreen,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 16),
                              const SizedBox(width: 6),
                              Text(
                                leadId.isNotEmpty ? 'Application Registered (Ref #$leadId)' : 'Application Under Review',
                                style: const TextStyle(color: AppColors.success, fontWeight: FontWeight.bold, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        AppButton(
                          text: 'Open Bank Portal',
                          type: ButtonType.blueSecondary,
                          onPressed: () {
                            controller.applyForCard(
                              card,
                              name: '',
                              pan: '',
                              income: 0,
                              empType: '',
                            );
                          },
                        ),
                      ],
                    );
                  }

                  return AppButton(
                    text: 'Apply Now',
                    type: ButtonType.orangePrimary,
                    onPressed: () => _showApplyBottomSheet(context, card),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _feeItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.navyText)),
      ],
    );
  }

  Widget _buildActiveApplicationsSection(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primaryBlue.withValues(alpha: 0.25)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.tintBlue,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.history_edu_rounded, color: AppColors.primaryBlue, size: 20),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Your Active Applications',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.navyText),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.tintOrange,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Obx(() => Text(
                      '${controller.appliedApplications.length} Active',
                      style: const TextStyle(color: AppColors.accentOrange, fontSize: 11, fontWeight: FontWeight.bold),
                    )),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Obx(() => Column(
                children: controller.appliedApplications.map((app) {
                  final cardName = app['cardName']?.toString() ?? 'Credit Card';
                  final bankName = app['bankName']?.toString() ?? 'Partner Bank';
                  final leadId = app['leadId']?.toString() ?? '';
                  final redirectUrl = app['redirectUrl']?.toString() ?? '';

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
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
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    cardName,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.navyText),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    bankName,
                                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.tintGreen,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: const [
                                  Icon(Icons.hourglass_top_rounded, color: AppColors.success, size: 13),
                                  SizedBox(width: 4),
                                  Text('Under Review', style: TextStyle(color: AppColors.success, fontSize: 11, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),

                        // Progress Stepper (4 stages)
                        Row(
                          children: [
                            _buildProgressStep(title: 'Submitted', isDone: true, isActive: false),
                            _buildStepLine(isDone: true),
                            _buildProgressStep(title: 'Pre-Approved', isDone: true, isActive: false),
                            _buildStepLine(isDone: false),
                            _buildProgressStep(title: 'Bank KYC', isDone: false, isActive: true),
                            _buildStepLine(isDone: false),
                            _buildProgressStep(title: 'Dispatch', isDone: false, isActive: false),
                          ],
                        ),

                        if (leadId.isNotEmpty) ...[
                          const SizedBox(height: 10),
                          Text(
                            'Application Reference ID: #$leadId',
                            style: const TextStyle(fontSize: 11, color: AppColors.textMuted, fontWeight: FontWeight.w600),
                          ),
                        ],

                        if (redirectUrl.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.accentOrange,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              icon: const Icon(Icons.open_in_new_rounded, size: 16),
                              label: const Text('Complete Bank KYC', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold)),
                              onPressed: () async {
                                try {
                                  final uri = Uri.parse(redirectUrl);
                                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                                } catch (_) {
                                  Get.snackbar('Notice', 'Opening portal: $redirectUrl');
                                }
                              },
                            ),
                          ),
                        ],
                      ],
                    ),
                  );
                }).toList(),
              )),
        ],
      ),
    );
  }

  Widget _buildProgressStep({required String title, required bool isDone, required bool isActive}) {
    Color bg = const Color(0xFFE2E8F0);
    Color fg = AppColors.textSecondary;
    IconData icon = Icons.circle;

    if (isDone) {
      bg = AppColors.success;
      fg = Colors.white;
      icon = Icons.check_rounded;
    } else if (isActive) {
      bg = AppColors.accentOrange;
      fg = Colors.white;
      icon = Icons.sync_rounded;
    }

    return Expanded(
      child: Column(
        children: [
          CircleAvatar(
            radius: 10,
            backgroundColor: bg,
            child: Icon(icon, size: 12, color: fg),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 9.5,
              fontWeight: (isDone || isActive) ? FontWeight.bold : FontWeight.normal,
              color: isActive ? AppColors.accentOrange : (isDone ? AppColors.navyText : AppColors.textMuted),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepLine({required bool isDone}) {
    return Container(
      width: 14,
      height: 2,
      margin: const EdgeInsets.only(bottom: 14),
      color: isDone ? AppColors.success : const Color(0xFFE2E8F0),
    );
  }

  Widget _buildCardVisual(CreditCardModel card, Color startColor, Color endColor) {
    final isApplied = card.productId != null && controller.appliedProductIds.contains(card.productId);

    return Container(
      height: 205,
      margin: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [startColor, endColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: startColor.withValues(alpha: 0.35),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // Network Card Art or High-End 3D Card Fallback
          if (card.imageUrl != null && card.imageUrl!.isNotEmpty)
            Positioned.fill(
              child: Image.network(
                card.imageUrl!,
                fit: BoxFit.contain,
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return _buildGradient3DCard(card, startColor, endColor);
                },
                errorBuilder: (_, __, ___) => _buildGradient3DCard(card, startColor, endColor),
              ),
            )
          else
            _buildGradient3DCard(card, startColor, endColor),

          // Top Left: Earn Up To Golden Badge
          if (card.earnUpTo != null && card.earnUpTo!.isNotEmpty)
            Positioned(
              top: 10,
              left: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 6,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.stars_rounded, color: Colors.white, size: 13),
                    const SizedBox(width: 4),
                    Text(
                      card.earnUpTo!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 10.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Top Right: Applied Badge or Verified Bank Tag
          Positioned(
            top: 10,
            right: 10,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
              decoration: BoxDecoration(
                color: isApplied ? AppColors.success : Colors.black.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white30, width: 0.8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(isApplied ? Icons.check_circle_rounded : Icons.verified_rounded, color: Colors.white, size: 12),
                  const SizedBox(width: 4),
                  Text(
                    isApplied ? 'Applied' : 'Bank Partner',
                    style: const TextStyle(color: Colors.white, fontSize: 10.5, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGradient3DCard(CreditCardModel card, Color startColor, Color endColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [startColor, endColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  card.bank,
                  style: AppTypography.title.copyWith(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const Icon(Icons.contactless_rounded, color: Colors.white70, size: 24),
            ],
          ),
          Row(
            children: [
              Container(
                width: 36,
                height: 28,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.amber.shade200, Colors.amber.shade600],
                  ),
                  borderRadius: BorderRadius.circular(6),
                  boxShadow: const [
                    BoxShadow(color: Colors.black26, blurRadius: 4),
                  ],
                ),
                child: Center(
                  child: Icon(Icons.memory_rounded, color: Colors.amber.shade900, size: 20),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '••••  ••••  ••••  ${(card.productId != null) ? card.productId.toString().padLeft(4, '0') : '9842'}',
                  style: AppTypography.body.copyWith(
                    color: Colors.white,
                    letterSpacing: 2,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('CARD HOLDER', style: AppTypography.micro.copyWith(color: Colors.white60, fontSize: 9)),
                    Text('FLAMEPAY MEMBER', style: AppTypography.caption.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  card.cardNetwork,
                  style: AppTypography.caption.copyWith(
                    color: Colors.white,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.1,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showApplyBottomSheet(BuildContext context, CreditCardModel card) {
    UserModel? user;
    try {
      user = Get.find<AuthService>().currentUser.value;
    } catch (_) {}

    final initialPan = controller.verifiedPan.value.isNotEmpty ? controller.verifiedPan.value : (user?.pan ?? 'ABCDE1234F');
    final initialName = controller.verifiedName.value.isNotEmpty ? controller.verifiedName.value : (user?.name ?? 'Rohit Kumar');

    final nameCtrl = TextEditingController(text: initialName);
    final phoneCtrl = TextEditingController(text: (user?.phone ?? '9876543210').replaceAll(RegExp(r'[^0-9]'), ''));
    final emailCtrl = TextEditingController(text: user?.email ?? 'rohit.kumar@flamepay.in');
    final panCtrl = TextEditingController(text: initialPan);
    final pincodeCtrl = TextEditingController(text: '110001');
    final incomeCtrl = TextEditingController(text: '45000');
    String empType = 'Salaried';

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
                    Expanded(
                      child: Text(
                        'Apply for ${card.name}',
                        style: AppTypography.title.copyWith(color: AppColors.navyText, fontSize: 16),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(icon: const Icon(Icons.close_rounded), onPressed: () => Get.back()),
                  ],
                ),
                const SizedBox(height: 12),

                // Government PAN Verification Card / Uploader
                _buildPanVerificationSection(context, nameCtrl, panCtrl, setSheetState),
                const SizedBox(height: 12),

                TextField(
                  controller: nameCtrl,
                  decoration: InputDecoration(
                    labelText: 'Full Name as per PAN',
                    prefixIcon: const Icon(Icons.person_outline, size: 20),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: phoneCtrl,
                        keyboardType: TextInputType.phone,
                        maxLength: 10,
                        decoration: InputDecoration(
                          counterText: '',
                          labelText: 'Mobile Number',
                          prefixIcon: const Icon(Icons.phone_outlined, size: 20),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: pincodeCtrl,
                        keyboardType: TextInputType.number,
                        maxLength: 6,
                        decoration: InputDecoration(
                          counterText: '',
                          labelText: 'Pincode',
                          prefixIcon: const Icon(Icons.pin_drop_outlined, size: 20),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Email Address',
                    prefixIcon: const Icon(Icons.email_outlined, size: 20),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: panCtrl,
                        textCapitalization: TextCapitalization.characters,
                        maxLength: 10,
                        decoration: InputDecoration(
                          counterText: '',
                          labelText: 'PAN Card Number',
                          prefixIcon: const Icon(Icons.badge_outlined, size: 20),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: incomeCtrl,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Monthly Income (₹)',
                          prefixIcon: const Icon(Icons.currency_rupee, size: 20),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: empType,
                  decoration: InputDecoration(
                    labelText: 'Employment Type',
                    prefixIcon: const Icon(Icons.work_outline, size: 20),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  items: ['Salaried', 'Self-Employed', 'Business']
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (v) => setSheetState(() => empType = v ?? 'Salaried'),
                ),
                const SizedBox(height: 20),
                Obx(() => AppButton(
                      text: 'Submit Application',
                      isLoading: controller.isSubmitting.value,
                      type: ButtonType.orangePrimary,
                      onPressed: () {
                        controller.applyForCard(
                          card,
                          name: nameCtrl.text.trim(),
                          pan: panCtrl.text.trim().toUpperCase(),
                          income: double.tryParse(incomeCtrl.text) ?? 35000.0,
                          empType: empType,
                          phone: phoneCtrl.text.trim(),
                          email: emailCtrl.text.trim(),
                          pincode: pincodeCtrl.text.trim(),
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

  // Government PAN Card Verification Section
  Widget _buildPanVerificationSection(
    BuildContext context,
    TextEditingController nameCtrl,
    TextEditingController panCtrl,
    StateSetter setSheetState,
  ) {
    return Obx(() {
      final isVerified = controller.isPanVerified.value;
      final panNumber = controller.verifiedPan.value.isNotEmpty ? controller.verifiedPan.value : panCtrl.text;
      final cardholderName = controller.verifiedName.value.isNotEmpty ? controller.verifiedName.value : nameCtrl.text;

      if (isVerified && panNumber.isNotEmpty) {
        // Official Government of India e-PAN Card Card
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
            border: Border.all(color: Colors.amber.shade400, width: 1.2),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.account_balance_rounded, size: 14, color: Color(0xFF0F2027)),
                      ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'आयकर विभाग / INCOME TAX DEPT.',
                            style: TextStyle(color: Colors.white70, fontSize: 8.5, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                          ),
                          Text(
                            'GOVERNMENT OF INDIA',
                            style: TextStyle(color: Colors.white, fontSize: 9.5, fontWeight: FontWeight.w900, letterSpacing: 1),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFF059669),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.verified_rounded, color: Colors.white, size: 12),
                        SizedBox(width: 4),
                        Text(
                          'NSDL VERIFIED',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 9.5),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Text(
                'PERMANENT ACCOUNT NUMBER (PAN)',
                style: TextStyle(color: Colors.amber, fontSize: 8.5, letterSpacing: 1, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 2),
              Text(
                panNumber,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                  fontFamily: 'monospace',
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('NAME / नाम', style: TextStyle(color: Colors.white60, fontSize: 8)),
                        Text(
                          cardholderName.isNotEmpty ? cardholderName : 'ROHIT KUMAR',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  TextButton.icon(
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    icon: const Icon(Icons.refresh_rounded, size: 14, color: Colors.amber),
                    label: const Text('Change', style: TextStyle(color: Colors.amber, fontSize: 11)),
                    onPressed: () => _openPanVerificationSheet(context, nameCtrl, panCtrl, setSheetState),
                  ),
                ],
              ),
            ],
          ),
        );
      }

      // Not Verified: Prompt upload / verify
      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFF0FDF4),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF86EFAC)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                Icon(Icons.shield_outlined, color: Color(0xFF16A34A), size: 18),
                SizedBox(width: 6),
                Text(
                  'Government PAN Verification Required',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5, color: Color(0xFF15803D)),
                ),
              ],
            ),
            const SizedBox(height: 4),
            const Text(
              'Upload your PAN card photo or verify with Income Tax Department records.',
              style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      side: const BorderSide(color: Color(0xFF16A34A)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    icon: const Icon(Icons.camera_alt_outlined, size: 15, color: Color(0xFF16A34A)),
                    label: const Text('Upload Photo', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Color(0xFF16A34A))),
                    onPressed: () => _openPanPhotoPicker(context, nameCtrl, panCtrl, setSheetState),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF16A34A),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      elevation: 0,
                    ),
                    icon: const Icon(Icons.verified_outlined, size: 15, color: Colors.white),
                    label: const Text('Verify Number', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Colors.white)),
                    onPressed: () => _openPanVerificationSheet(context, nameCtrl, panCtrl, setSheetState),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  void _openPanPhotoPicker(
    BuildContext context,
    TextEditingController nameCtrl,
    TextEditingController panCtrl,
    StateSetter setSheetState,
  ) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Upload PAN Card Photo', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.navyText)),
            const SizedBox(height: 4),
            const Text('Capture clear photo of your PAN card for instant verification', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            const SizedBox(height: 16),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(color: AppColors.tintBlue, shape: BoxShape.circle),
                child: const Icon(Icons.camera_alt_rounded, color: AppColors.primaryBlue),
              ),
              title: const Text('Take Photo (Camera)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              onTap: () async {
                Get.back();
                await controller.pickPanPhoto(ImageSource.camera, currentName: nameCtrl.text, currentPan: panCtrl.text);
                if (controller.isPanVerified.value) {
                  panCtrl.text = controller.verifiedPan.value;
                  nameCtrl.text = controller.verifiedName.value;
                  setSheetState(() {});
                }
              },
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(color: AppColors.tintOrange, shape: BoxShape.circle),
                child: const Icon(Icons.photo_library_rounded, color: AppColors.accentOrange),
              ),
              title: const Text('Choose from Gallery', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              onTap: () async {
                Get.back();
                await controller.pickPanPhoto(ImageSource.gallery, currentName: nameCtrl.text, currentPan: panCtrl.text);
                if (controller.isPanVerified.value) {
                  panCtrl.text = controller.verifiedPan.value;
                  nameCtrl.text = controller.verifiedName.value;
                  setSheetState(() {});
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _openPanVerificationSheet(
    BuildContext context,
    TextEditingController nameCtrl,
    TextEditingController panCtrl,
    StateSetter setSheetState,
  ) {
    final tempPanCtrl = TextEditingController(text: panCtrl.text);
    final tempNameCtrl = TextEditingController(text: nameCtrl.text);

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.verified_user_rounded, color: Color(0xFF16A34A)),
                      SizedBox(width: 8),
                      Text('PAN Card Verification', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppColors.navyText)),
                    ],
                  ),
                  IconButton(icon: const Icon(Icons.close), onPressed: () => Get.back()),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'Enter your 10-digit PAN card number to verify directly with Income Tax Central records.',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: tempPanCtrl,
                textCapitalization: TextCapitalization.characters,
                maxLength: 10,
                decoration: InputDecoration(
                  counterText: '',
                  labelText: 'PAN Card Number (e.g. ABCDE1234F)',
                  prefixIcon: const Icon(Icons.badge_outlined),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: tempNameCtrl,
                decoration: InputDecoration(
                  labelText: 'Name as per PAN',
                  prefixIcon: const Icon(Icons.person_outline),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 20),
              Obx(() => AppButton(
                    text: 'Verify with Income Tax Dept',
                    isLoading: controller.isVerifyingPan.value,
                    type: ButtonType.blueSecondary,
                    onPressed: () async {
                      final ok = await controller.verifyPanCard(
                        pan: tempPanCtrl.text.trim().toUpperCase(),
                        name: tempNameCtrl.text.trim(),
                      );
                      if (ok) {
                        panCtrl.text = controller.verifiedPan.value;
                        nameCtrl.text = controller.verifiedName.value;
                        setSheetState(() {});
                        Get.back();
                      }
                    },
                  )),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }
}
