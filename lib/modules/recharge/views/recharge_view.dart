import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/blue_header_scaffold.dart';
import '../../../shared/widgets/plan_card.dart';
import '../../../shared/widgets/operator_selector_sheet.dart';
import '../../../data/mock/mock_recharge_data.dart';
import '../recharge_controller.dart';

class RechargeView extends GetView<RechargeController> {
  const RechargeView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlueHeaderScaffold(
      title: 'Mobile & DTH Recharge',
      headerHeight: 140,
      headerBottom: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Container(
          height: 48,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(14),
          ),
          child: TabBar(
            controller: controller.tabController,
            indicator: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [AppColors.cardShadow],
            ),
            indicatorSize: TabBarIndicatorSize.tab,
            labelColor: AppColors.primaryBlue,
            unselectedLabelColor: Colors.white,
            labelStyle: AppTypography.button.copyWith(fontWeight: FontWeight.bold),
            tabs: const [
              Tab(text: 'Mobile Recharge'),
              Tab(text: 'DTH Recharge'),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: controller.tabController,
        children: [
          _MobileRechargeTab(controller: controller),
          _DthRechargeTab(controller: controller),
        ],
      ),
    );
  }
}

class _MobileRechargeTab extends StatelessWidget {
  final RechargeController controller;
  const _MobileRechargeTab({required this.controller});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Mobile Number Box with Contact Picker
          Text('Enter Mobile Number', style: AppTypography.caption.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
              boxShadow: const [AppColors.cardShadow],
            ),
            child: Row(
              children: [
                Text(
                  '+91',
                  style: AppTypography.bodyBold.copyWith(color: AppColors.navyText),
                ),
                const SizedBox(width: 8),
                Container(width: 1, height: 24, color: AppColors.border),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: controller.mobileController,
                    keyboardType: TextInputType.phone,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(10),
                    ],
                    style: AppTypography.title.copyWith(color: AppColors.navyText, fontSize: 16),
                    decoration: const InputDecoration(
                      hintText: '98765 43210',
                      border: InputBorder.none,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.contacts_rounded, color: AppColors.primaryBlue),
                  onPressed: () {
                    Get.snackbar('Contacts', 'Contact book simulation ready');
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // Operator & Circle Selector Pills
          Obx(() => Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        OperatorSelectorSheet.show(
                          context: context,
                          operators: MockRechargeData.mobileOperators,
                          selectedOperator: controller.selectedMobileOperator.value,
                          title: 'Select Mobile Operator',
                        ).then((op) {
                          if (op != null) controller.onSelectOperator(op);
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                controller.selectedMobileOperator.value.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTypography.caption.copyWith(fontWeight: FontWeight.bold, color: AppColors.navyText),
                              ),
                            ),
                            const Icon(Icons.arrow_drop_down, color: AppColors.textSecondary),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        Get.bottomSheet(
                          _CircleSelectorSheet(
                            selectedCircle: controller.selectedCircle.value,
                            onSelect: (c) {
                              controller.onSelectCircle(c);
                              Get.back();
                            },
                          ),
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                controller.selectedCircle.value,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTypography.caption.copyWith(fontWeight: FontWeight.bold, color: AppColors.navyText),
                              ),
                            ),
                            const Icon(Icons.arrow_drop_down, color: AppColors.textSecondary),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              )),

          const SizedBox(height: 22),

          // Plan Categories Horizontal Tabs
          Text('Select Recharge Plan', style: AppTypography.title.copyWith(color: AppColors.navyText, fontSize: 17)),
          const SizedBox(height: 12),

          SizedBox(
            height: 38,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: controller.categories.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final cat = controller.categories[index];
                return Obx(() {
                  final isSelected = controller.selectedCategory.value == cat;
                  return ChoiceChip(
                    label: Text(cat),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) controller.selectedCategory.value = cat;
                    },
                    selectedColor: AppColors.primaryBlue,
                    backgroundColor: Colors.white,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : AppColors.navyText,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      fontSize: 13,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        color: isSelected ? AppColors.primaryBlue : AppColors.border,
                      ),
                    ),
                  );
                });
              },
            ),
          ),

          const SizedBox(height: 16),

          // Plans List
          Obx(() {
            if (controller.isLoadingPlans.value) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(40.0),
                  child: CircularProgressIndicator(),
                ),
              );
            }

            final plans = controller.filteredPlans;
            if (plans.isEmpty) {
              return const Padding(
                padding: EdgeInsets.all(32.0),
                child: Center(
                  child: Text('No plans available in this category', style: TextStyle(color: AppColors.textSecondary)),
                ),
              );
            }

            return Column(
              children: plans.map((plan) {
                return PlanCard(
                  plan: plan,
                  onSelect: () => controller.onSelectPlan(plan),
                );
              }).toList(),
            );
          }),
        ],
      ),
    );
  }
}

class _DthRechargeTab extends StatelessWidget {
  final RechargeController controller;
  const _DthRechargeTab({required this.controller});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Select DTH Operator
          Text('Select DTH Provider', style: AppTypography.caption.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Obx(() => InkWell(
                onTap: () {
                  OperatorSelectorSheet.show(
                    context: context,
                    operators: MockRechargeData.dthOperators,
                    selectedOperator: controller.selectedDthOperator.value,
                    title: 'Select DTH Provider',
                  ).then((op) {
                    if (op != null) controller.onSelectOperator(op);
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.tv_rounded, color: AppColors.primaryBlue, size: 24),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          controller.selectedDthOperator.value.name,
                          style: AppTypography.bodyBold.copyWith(color: AppColors.navyText),
                        ),
                      ),
                      const Icon(Icons.arrow_drop_down, color: AppColors.textSecondary),
                    ],
                  ),
                ),
              )),

          const SizedBox(height: 18),

          // Subscriber ID Box
          Text('Subscriber ID / Smart Card Number', style: AppTypography.caption.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: TextField(
              controller: controller.dthSubscriberController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                hintText: 'e.g. 1023456789',
                border: InputBorder.none,
              ),
            ),
          ),

          const SizedBox(height: 18),

          // Amount Box
          Text('Recharge Amount (₹)', style: AppTypography.caption.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: TextField(
              controller: controller.dthAmountController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              style: AppTypography.h1.copyWith(color: AppColors.navyText, fontSize: 22),
              decoration: const InputDecoration(
                prefixText: '₹ ',
                hintText: '0',
                border: InputBorder.none,
              ),
            ),
          ),

          const SizedBox(height: 14),

          // Quick DTH Amount Chips
          Wrap(
            spacing: 8,
            children: [200, 350, 500, 1000].map((amt) {
              return ActionChip(
                label: Text('+ ₹$amt'),
                onPressed: () => controller.dthAmountController.text = amt.toString(),
                backgroundColor: AppColors.tintBlue,
                labelStyle: const TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.bold),
              );
            }).toList(),
          ),

          const SizedBox(height: 32),

          Obx(() => ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accentOrange,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 54),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: controller.isProcessingPayment.value ? null : controller.payDth,
                child: controller.isProcessingPayment.value
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Proceed to Recharge', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              )),
        ],
      ),
    );
  }
}

class _CircleSelectorSheet extends StatelessWidget {
  final String selectedCircle;
  final Function(String) onSelect;

  const _CircleSelectorSheet({required this.selectedCircle, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.7),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(topLeft: Radius.circular(28), topRight: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(width: 44, height: 4, decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(4))),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('Select Telecom Circle', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.navyText)),
          ),
          const Divider(height: 1, color: AppColors.border),
          Flexible(
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: MockRechargeData.circles.length,
              separatorBuilder: (_, _) => const Divider(height: 1, color: AppColors.border),
              itemBuilder: (context, index) {
                final circle = MockRechargeData.circles[index];
                final isSelected = circle == selectedCircle;
                return ListTile(
                  title: Text(circle, style: TextStyle(color: isSelected ? AppColors.primaryBlue : AppColors.navyText, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
                  trailing: isSelected ? const Icon(Icons.check, color: AppColors.primaryBlue) : null,
                  onTap: () => onSelect(circle),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
