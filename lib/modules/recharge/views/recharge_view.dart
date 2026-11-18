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
          // Subscriber ID Box with Live DTH Operator Check
          Text('Subscriber ID / Smart Card Number', style: AppTypography.caption.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Obx(() {
            final isDetecting = controller.isCheckingDthOperator.value;
            return Container(
              padding: const EdgeInsets.only(left: 14, right: 8, top: 4, bottom: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
                boxShadow: const [AppColors.cardShadow],
              ),
              child: Row(
                children: [
                  const Icon(Icons.credit_card_rounded, color: AppColors.primaryBlue, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: controller.dthSubscriberController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      style: AppTypography.title.copyWith(color: AppColors.navyText, fontSize: 16),
                      decoration: const InputDecoration(
                        hintText: 'e.g. 3012345678',
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  isDetecting
                      ? const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          child: SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primaryBlue),
                          ),
                        )
                      : InkWell(
                          onTap: () => controller.checkDthOperatorNow(),
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: AppColors.tintBlue,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.radar_rounded, size: 15, color: AppColors.primaryBlue),
                                SizedBox(width: 4),
                                Text(
                                  'Detect',
                                  style: TextStyle(
                                    color: AppColors.primaryBlue,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                ],
              ),
            );
          }),

          const SizedBox(height: 16),

          // DTH Provider Selector (Smoothly updates in place on Operator Check)
          Text('DTH Provider', style: AppTypography.caption.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Obx(() {
            final op = controller.selectedDthOperator.value;
            final detected = controller.detectedDthOperatorLabel.value;
            final isDetected = detected.isNotEmpty;
            return InkWell(
              onTap: () {
                OperatorSelectorSheet.show(
                  context: context,
                  operators: MockRechargeData.dthOperators,
                  selectedOperator: op,
                  title: 'Select DTH Provider',
                ).then((picked) {
                  if (picked != null) controller.onSelectOperator(picked);
                });
              },
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDetected ? AppColors.primaryBlue.withValues(alpha: 0.45) : AppColors.border,
                  ),
                  boxShadow: const [AppColors.cardShadow],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.tintBlue,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.tv_rounded, color: AppColors.primaryBlue, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 280),
                        transitionBuilder: (child, anim) => FadeTransition(
                          opacity: anim,
                          child: SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0, 0.15),
                              end: Offset.zero,
                            ).animate(anim),
                            child: child,
                          ),
                        ),
                        child: Column(
                          key: ValueKey('${op.id}_$detected'),
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              op.name,
                              style: AppTypography.bodyBold.copyWith(color: AppColors.navyText, fontSize: 15),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              isDetected ? detected : 'Tap to choose provider',
                              style: TextStyle(
                                fontSize: 11.5,
                                color: isDetected ? AppColors.primaryBlue : AppColors.textSecondary,
                                fontWeight: isDetected ? FontWeight.w600 : FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (isDetected)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        margin: const EdgeInsets.only(right: 4),
                        decoration: BoxDecoration(
                          color: AppColors.tintBlue,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Auto',
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryBlue,
                          ),
                        ),
                      ),
                    const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textSecondary),
                  ],
                ),
              ),
            );
          }),

          const SizedBox(height: 16),

          // Live DTH Advance Information Section (Matches FlamePay PlanCard White/Blue/Orange UI)
          Obx(() {
            final isFetching = controller.isFetchingDthInfo.value;
            final info = controller.dthAdvanceInfo.value;

            return AnimatedSwitcher(
              duration: const Duration(milliseconds: 280),
              child: isFetching
                  ? Container(
                      key: const ValueKey('dth_info_loading'),
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: AppColors.border),
                        boxShadow: const [AppColors.cardShadow],
                      ),
                      child: const Row(
                        children: [
                          SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primaryBlue),
                          ),
                          SizedBox(width: 12),
                          Text(
                            'Fetching DTH customer info & balance...',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.navyText,
                            ),
                          ),
                        ],
                      ),
                    )
                  : info != null
                      ? _buildDthInfoCard(info)
                      : SizedBox(
                          key: const ValueKey('dth_info_button'),
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.primaryBlue,
                              backgroundColor: Colors.white,
                              side: const BorderSide(color: AppColors.border),
                              padding: const EdgeInsets.symmetric(vertical: 13),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            ),
                            onPressed: () => controller.fetchDthAdvanceInfo(),
                            icon: const Icon(Icons.account_balance_wallet_outlined, size: 18),
                            label: const Text(
                              'Fetch Customer Info & Balance',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
                            ),
                          ),
                        ),
            );
          }),

          const SizedBox(height: 18),

          // Amount Box
          Text('Recharge Amount (₹)', style: AppTypography.caption.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
              boxShadow: const [AppColors.cardShadow],
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

  Widget _buildDthInfoCard(Map<String, dynamic> info) {
    final custName = (info['customerName'] ?? '').toString().trim();
    final balance = (info['balance'] ?? '').toString().trim();
    final monthly = (info['monthlyRecharge'] ?? '').toString().trim();
    final nextDate = (info['nextRechargeDate'] ?? '').toString().trim();
    final lastAmt = (info['lastRechargeAmount'] ?? '').toString().trim();
    final lastDate = (info['lastRechargeDate'] ?? '').toString().trim();
    final planName = (info['planName'] ?? '').toString().trim();
    final status = (info['status'] ?? 'Active').toString().trim();
    final rmn = (info['rmn'] ?? '').toString().trim();
    final subId = controller.dthSubscriberController.text.trim();
    final opName = controller.selectedDthOperator.value.name;

    final stats = <Widget>[
      if (balance.isNotEmpty) _dthStatPill('Current Balance', '₹$balance'),
      if (monthly.isNotEmpty) _dthStatPill('Monthly Pack', '₹$monthly'),
      if (nextDate.isNotEmpty) _dthStatPill('Next Recharge', nextDate),
      if (lastAmt.isNotEmpty)
        _dthStatPill('Last Recharge', '₹$lastAmt${lastDate.isNotEmpty ? ' ($lastDate)' : ''}'),
      if (rmn.isNotEmpty) _dthStatPill('Reg. Mobile', rmn),
    ];

    return Container(
      key: ValueKey('dth_info_card_${subId}_$custName'),
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
        boxShadow: const [AppColors.cardShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.tintBlue,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.person_outline_rounded, color: AppColors.primaryBlue, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      custName.isNotEmpty ? custName : 'DTH Account Details',
                      style: AppTypography.bodyBold.copyWith(color: AppColors.navyText, fontSize: 15),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$opName • $subId',
                      style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.tintBlue,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  status,
                  style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: AppColors.primaryBlue),
                ),
              ),
              const SizedBox(width: 4),
              InkWell(
                onTap: () => controller.fetchDthAdvanceInfo(),
                borderRadius: BorderRadius.circular(8),
                child: const Padding(
                  padding: EdgeInsets.all(4),
                  child: Icon(Icons.refresh_rounded, size: 18, color: AppColors.primaryBlue),
                ),
              ),
            ],
          ),
          if (stats.isNotEmpty) ...[
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border.withValues(alpha: 0.7)),
              ),
              child: Wrap(
                spacing: 20,
                runSpacing: 12,
                children: stats,
              ),
            ),
          ],
          if (planName.isNotEmpty) ...[
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.subscriptions_outlined, size: 15, color: AppColors.primaryBlue),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Active Plan: $planName',
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ],
          if (monthly.isNotEmpty) ...[
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                InkWell(
                  onTap: () {
                    final clean = monthly.replaceAll(RegExp(r'[^0-9.]'), '');
                    final parsed = double.tryParse(clean);
                    if (parsed != null && parsed > 0) {
                      controller.dthAmountController.text = parsed.toStringAsFixed(0);
                    }
                  },
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.accentOrange,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      'Fill ₹$monthly',
                      style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _dthStatPill(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.navyText)),
      ],
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
