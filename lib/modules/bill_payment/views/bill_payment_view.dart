import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/widgets/blue_header_scaffold.dart';
import '../../../shared/widgets/bill_details_card.dart';
import '../../../shared/widgets/operator_selector_sheet.dart';
import '../bill_payment_controller.dart';

class BillPaymentView extends GetView<BillPaymentController> {
  const BillPaymentView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlueHeaderScaffold(
      title: 'Pay Utility Bills',
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Category Chips Row
            SizedBox(
              height: 40,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: controller.categories.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final cat = controller.categories[index];
                  final catId = cat['id'] as String;
                  return Obx(() {
                    final isSelected = controller.selectedCategory.value == catId;
                    return ChoiceChip(
                      avatar: Icon(cat['icon'] as IconData, size: 16, color: isSelected ? Colors.white : AppColors.primaryBlue),
                      label: Text(cat['name'] as String),
                      selected: isSelected,
                      onSelected: (selected) {
                        if (selected) controller.onSelectCategory(catId);
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

            const SizedBox(height: 20),

            // Select Biller
            Text('Select Electricity Board / Biller', style: AppTypography.caption.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Obx(() => InkWell(
                  onTap: () {
                    OperatorSelectorSheet.show(
                      context: context,
                      operators: controller.billersForCategory,
                      selectedOperator: controller.selectedBiller.value,
                      title: 'Select Biller',
                    ).then((op) {
                      if (op != null) {
                        controller.selectedBiller.value = op;
                        controller.fetchBill();
                      }
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.border),
                      boxShadow: const [AppColors.cardShadow],
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.account_balance_rounded, color: AppColors.primaryBlue),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            controller.selectedBiller.value.name,
                            style: AppTypography.bodyBold.copyWith(color: AppColors.navyText),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const Icon(Icons.arrow_drop_down, color: AppColors.textSecondary),
                      ],
                    ),
                  ),
                )),

            const SizedBox(height: 18),

            // Consumer Number Field
            Text('Consumer Number / CA Number', style: AppTypography.caption.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
                boxShadow: const [AppColors.cardShadow],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: controller.consumerNumberController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        hintText: 'Enter 10-digit Consumer Number',
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: controller.fetchBill,
                    child: const Text('Fetch Bill', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Fetched Bill Details or Loading
            Obx(() {
              if (controller.isFetchingBill.value) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              final bill = controller.fetchedBill.value;
              if (bill == null) {
                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: const Center(
                    child: Text('Enter consumer number & tap "Fetch Bill"', style: TextStyle(color: AppColors.textSecondary)),
                  ),
                );
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  BillDetailsCard(bill: bill),

                  const SizedBox(height: 20),

                  // Promo Code Input Box
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.local_offer_outlined, color: AppColors.accentOrange),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: controller.promoCodeController,
                            textCapitalization: TextCapitalization.characters,
                            decoration: const InputDecoration(
                              hintText: 'Apply Promo (e.g. POW50)',
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () => controller.applyPromo(controller.promoCodeController.text.trim()),
                          child: const Text('Apply', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryBlue)),
                        ),
                      ],
                    ),
                  ),

                  // Applied Promo Indicator
                  if (controller.appliedPromo.value.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.check_circle, color: AppColors.success, size: 16),
                        const SizedBox(width: 6),
                        Text('Promo ${controller.appliedPromo.value} applied (-₹50.00)',
                            style: const TextStyle(color: AppColors.success, fontWeight: FontWeight.bold, fontSize: 13)),
                        const Spacer(),
                        GestureDetector(
                          onTap: controller.removePromo,
                          child: const Text('Remove', style: TextStyle(color: Colors.red, fontSize: 12, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ],

                  const SizedBox(height: 28),

                  // Pay Bill CTA Button
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accentOrange,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 54),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      elevation: 2,
                    ),
                    onPressed: controller.isPayingBill.value ? null : controller.payBill,
                    child: controller.isPayingBill.value
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                            'Pay Bill ${Formatters.formatCurrency(controller.finalPayableAmount)}',
                            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                          ),
                  ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }
}
