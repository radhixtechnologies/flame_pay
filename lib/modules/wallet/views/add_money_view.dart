import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/blue_header_scaffold.dart';
import '../../../shared/widgets/app_button.dart';
import '../wallet_controller.dart';

class AddMoneyView extends GetView<WalletController> {
  const AddMoneyView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlueHeaderScaffold(
      title: 'Add Money to Wallet',
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Enter Amount',
              style: AppTypography.title.copyWith(color: AppColors.navyText),
            ),
            const SizedBox(height: 12),

            // Big Amount Input Box
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.primaryBlue, width: 2),
                boxShadow: const [AppColors.cardShadow],
              ),
              child: Row(
                children: [
                  Text(
                    '₹',
                    style: AppTypography.display.copyWith(
                      color: AppColors.primaryBlue,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: controller.addAmountController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      style: AppTypography.display.copyWith(
                        color: AppColors.navyText,
                        fontWeight: FontWeight.w800,
                      ),
                      decoration: const InputDecoration(
                        hintText: '0',
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Quick Chips (+₹100, +₹500, +₹1,000, +₹2,000)
            Wrap(
              spacing: 10,
              children: controller.quickAmounts.map((amt) {
                return Obx(() {
                  final isSelected = controller.selectedQuickAmount.value == amt;
                  return ChoiceChip(
                    label: Text('+ ₹$amt'),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) controller.selectQuickAmount(amt);
                    },
                    selectedColor: AppColors.primaryBlue,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : AppColors.navyText,
                      fontWeight: FontWeight.w600,
                    ),
                    backgroundColor: AppColors.tintBlue,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  );
                });
              }).toList(),
            ),

            const SizedBox(height: 28),

            // Payment Methods
            Text(
              'Select Payment Mode',
              style: AppTypography.title.copyWith(color: AppColors.navyText),
            ),
            const SizedBox(height: 12),

            Obx(() => Column(
                  children: controller.paymentMethods.map((method) {
                    final isSelected = controller.selectedPaymentMethod.value == method;
                    return InkWell(
                      onTap: () => controller.selectedPaymentMethod.value = method,
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.primaryBlue.withValues(alpha: 0.04) : Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isSelected ? AppColors.primaryBlue : AppColors.border,
                            width: isSelected ? 1.8 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                              color: isSelected ? AppColors.primaryBlue : AppColors.textMuted,
                            ),
                            const SizedBox(width: 14),
                            Expanded(child: Text(method, style: AppTypography.bodyBold)),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                )),

            const SizedBox(height: 32),

            Obx(() => AppButton(
                  text: 'Proceed to Add Money',
                  type: ButtonType.orangePrimary,
                  height: 54,
                  isLoading: controller.isAddingMoney.value,
                  onPressed: controller.addMoney,
                )),
          ],
        ),
      ),
    );
  }
}
