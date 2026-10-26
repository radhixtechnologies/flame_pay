import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/state_view.dart';
import '../../../data/models/insurance_model.dart';
import '../insurance_controller.dart';

class InsuranceView extends GetView<InsuranceController> {
  const InsuranceView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Insurance Plans', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.primaryBlue,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          // Category Tabs Bar
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Obx(() => Row(
                    children: [
                      _buildCatTab(InsuranceCategory.health, 'Health', Icons.favorite_rounded),
                      _buildCatTab(InsuranceCategory.termLife, 'Term Life', Icons.shield_rounded),
                      _buildCatTab(InsuranceCategory.motor, 'Motor (Car/Bike)', Icons.directions_car_rounded),
                      _buildCatTab(InsuranceCategory.travel, 'Travel', Icons.flight_takeoff_rounded),
                    ],
                  )),
            ),
          ),

          // Plans List
          Expanded(
            child: Obx(() {
              if (controller.viewState.value == ViewState.loading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.viewState.value == ViewState.error || controller.plans.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.shield_outlined, size: 48, color: AppColors.textMuted),
                      const SizedBox(height: 12),
                      Text('No Plans Found', style: AppTypography.title),
                      const SizedBox(height: 12),
                      ElevatedButton(onPressed: controller.fetchPlans, child: const Text('Refresh')),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: controller.plans.length,
                itemBuilder: (context, index) {
                  final plan = controller.plans[index];
                  return _buildPlanCard(context, plan);
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildCatTab(InsuranceCategory cat, String title, IconData icon) {
    final isSelected = controller.selectedCategory.value == cat;
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: ChoiceChip(
        avatar: Icon(icon, size: 16, color: isSelected ? Colors.white : AppColors.primaryBlue),
        label: Text(title),
        selected: isSelected,
        onSelected: (_) => controller.onCategoryChanged(cat),
        selectedColor: AppColors.primaryBlue,
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : AppColors.navyText,
          fontWeight: FontWeight.w600,
          fontSize: 12.5,
        ),
        backgroundColor: AppColors.tintBlue,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }

  Widget _buildPlanCard(BuildContext context, InsurancePlanModel plan) {
    final coverText = plan.coverAmount >= 10000000
        ? '₹${(plan.coverAmount / 10000000).toStringAsFixed(0)} Crore Cover'
        : '₹${(plan.coverAmount / 100000).toStringAsFixed(0)} Lakhs Cover';

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [AppColors.cardShadow],
        border: Border.all(color: plan.isPopular ? AppColors.accentOrange : AppColors.border, width: plan.isPopular ? 1.5 : 1),
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
                    Text(plan.provider, style: AppTypography.micro.copyWith(color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
                    Text(plan.title, style: AppTypography.title.copyWith(color: AppColors.navyText, fontSize: 16, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              if (plan.isPopular)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.tintOrange,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text('MOST CHOSEN', style: TextStyle(color: AppColors.accentOrange, fontSize: 9.5, fontWeight: FontWeight.bold)),
                ),
            ],
          ),

          const SizedBox(height: 12),

          // Cover Amount & Price Row
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.tintBlue,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Sum Insured', style: AppTypography.micro.copyWith(color: AppColors.textSecondary)),
                      Text(coverText, style: AppTypography.bodyBold.copyWith(color: AppColors.primaryBlue, fontSize: 15)),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('Starting from', style: AppTypography.micro.copyWith(color: AppColors.textSecondary)),
                    Text('₹${plan.monthlyPremium.toInt()} / mo', style: AppTypography.bodyBold.copyWith(color: AppColors.navyText, fontSize: 16)),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Key Metrics (Claim Ratio & Cashless Hospitals)
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              _buildMetricBadge(Icons.verified_rounded, '${plan.claimRatioPercent}% Claim Ratio', AppColors.success),
              if (plan.cashlessHospitalsCount > 0)
                _buildMetricBadge(Icons.local_hospital_rounded, '${plan.cashlessHospitalsCount}+ Hospitals', AppColors.primaryBlue),
            ],
          ),

          const SizedBox(height: 12),

          // Features
          ...plan.keyFeatures.map((f) => Padding(
                padding: const EdgeInsets.only(bottom: 6.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.check_rounded, color: AppColors.success, size: 16),
                    const SizedBox(width: 6),
                    Expanded(child: Text(f, style: AppTypography.caption.copyWith(color: AppColors.navyText, fontSize: 12))),
                  ],
                ),
              )),

          const SizedBox(height: 16),

          // Buy Policy CTA
          AppButton(
            text: 'Buy Policy (₹${Formatters.formatCurrency(plan.yearlyPremium)}/yr)',
            type: ButtonType.orangePrimary,
            onPressed: () => _showBuyPolicySheet(context, plan),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricBadge(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 4),
          Text(text, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  void _showBuyPolicySheet(BuildContext context, InsurancePlanModel plan) {
    final nameCtrl = TextEditingController(text: 'Rohit Kumar');
    final ageCtrl = TextEditingController(text: '28');
    final phoneCtrl = TextEditingController(text: '9876543210');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
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
                  Text('Instant Policy Issuance', style: AppTypography.title.copyWith(color: AppColors.navyText)),
                  IconButton(icon: const Icon(Icons.close_rounded), onPressed: () => Get.back()),
                ],
              ),
              const SizedBox(height: 6),
              Text('${plan.title} - ${plan.provider}', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryBlue, fontSize: 13)),
              const SizedBox(height: 16),
              TextField(
                controller: nameCtrl,
                decoration: InputDecoration(
                  labelText: 'Primary Insured Person Name',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: ageCtrl,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Age',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: phoneCtrl,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: 'Mobile Number',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.tintBlue,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total Premium Payable', style: TextStyle(fontWeight: FontWeight.w600)),
                    Text(Formatters.formatCurrency(plan.yearlyPremium), style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryBlue, fontSize: 16)),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Obx(() => AppButton(
                    text: 'Pay & Issue Policy',
                    isLoading: controller.isSubmitting.value,
                    type: ButtonType.orangePrimary,
                    onPressed: () {
                      controller.buyPolicy(
                        plan,
                        name: nameCtrl.text,
                        age: ageCtrl.text,
                        phone: phoneCtrl.text,
                      );
                    },
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
