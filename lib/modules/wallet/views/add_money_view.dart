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

  void _copy(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    Get.snackbar(
      'Copied to Clipboard',
      '$label: $text',
      backgroundColor: Colors.green.shade100,
      colorText: Colors.green.shade900,
      duration: const Duration(seconds: 2),
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlueHeaderScaffold(
      title: 'Add Money to Wallet',
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Enter Amount to Add',
              style: AppTypography.title.copyWith(color: AppColors.navyText),
            ),
            const SizedBox(height: 10),

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

            const SizedBox(height: 12),

            // Quick Chips (+₹100, +₹500, +₹1,000, +₹2,000)
            Wrap(
              spacing: 8,
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

            const SizedBox(height: 24),

            // Official Bank & UPI Transfer Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue.shade900, const Color(0xFF1E3A8A)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.shade900.withValues(alpha: 0.25),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.account_balance, color: Colors.amber, size: 22),
                      const SizedBox(width: 8),
                      Text(
                        'Direct Bank & UPI Deposit Account',
                        style: AppTypography.bodyBold.copyWith(color: Colors.white),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Transfer money to this account via GPay, PhonePe, Paytm, or NetBanking:',
                    style: TextStyle(color: Colors.blue.shade100, fontSize: 12),
                  ),
                  const Divider(color: Colors.white24, height: 20),

                  // Account Details Rows
                  _buildDetailRow('Beneficiary Name', 'SHIVAM SHIVAM', false),
                  const SizedBox(height: 8),
                  _buildDetailRow('Bank Name', 'State Bank of India (SBI)', false),
                  const SizedBox(height: 8),
                  _buildDetailRow('Account Number', '32823806111', true),
                  const SizedBox(height: 8),
                  _buildDetailRow('IFSC Code', 'SBIN0013209', true),
                  const SizedBox(height: 8),
                  _buildDetailRow('UPI ID', '32823806111@sbi', true),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // UTR Number Input
            Text(
              'Enter 12-Digit UTR / Reference No.',
              style: AppTypography.title.copyWith(color: AppColors.navyText),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: TextField(
                controller: controller.utrController,
                keyboardType: TextInputType.text,
                decoration: const InputDecoration(
                  hintText: 'e.g. 428192837192 (from UPI app)',
                  hintStyle: TextStyle(color: Colors.grey, fontSize: 13),
                  border: InputBorder.none,
                  prefixIcon: Icon(Icons.receipt_long, color: AppColors.primaryBlue),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Submit Button
            Obx(() => AppButton(
                  text: 'Submit Deposit Request for Approval',
                  type: ButtonType.orangePrimary,
                  height: 52,
                  isLoading: controller.isAddingMoney.value,
                  onPressed: controller.submitTopupRequest,
                )),

            const SizedBox(height: 12),

            // Instant Simulated Top-up (For Development Testing)
            Center(
              child: TextButton.icon(
                onPressed: controller.addMoney,
                icon: const Icon(Icons.bolt, color: Colors.green),
                label: const Text(
                  'Instant Add Money (Development Sandbox)',
                  style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, bool copyable) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(color: Colors.blue.shade200, fontSize: 11),
            ),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        if (copyable)
          IconButton(
            icon: const Icon(Icons.copy, color: Colors.amber, size: 18),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: () => _copy(value, label),
            tooltip: 'Copy $label',
          ),
      ],
    );
  }
}
