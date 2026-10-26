import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/responsive/responsive_helper.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../../shared/widgets/blue_header_scaffold.dart';
import '../controllers/send_money_controller.dart';

class SendMoneyView extends GetView<SendMoneyController> {
  const SendMoneyView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlueHeaderScaffold(
      title: 'Send Money',
      body: ResponsiveContainer(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Transfer Mode Switch (Mobile / UPI ID)
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF2F4F7),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Obx(() => Row(
                      children: controller.transferTypes.map((type) {
                        final isSelected = controller.selectedTransferType.value == type;
                        return Expanded(
                          child: GestureDetector(
                            onTap: () => controller.selectedTransferType.value = type,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: isSelected ? Colors.white : Colors.transparent,
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: isSelected ? const [AppColors.softBlueShadow] : null,
                              ),
                              child: Text(
                                type,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                  color: isSelected ? AppColors.primaryBlue : AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    )),
              ),

              const SizedBox(height: 20),

              // Input: Mobile or UPI
              Obx(() {
                final isMobile = controller.selectedTransferType.value == 'Mobile Number';
                return AppTextField(
                  label: isMobile ? 'Recipient Mobile Number' : 'Recipient UPI ID',
                  hint: isMobile ? 'Enter 10-digit mobile number' : 'e.g. name@okhdfcbank',
                  controller: controller.recipientController,
                  keyboardType: isMobile ? TextInputType.phone : TextInputType.emailAddress,
                  prefixIcon: Icon(
                    isMobile ? Icons.phone_android_rounded : Icons.alternate_email_rounded,
                    color: AppColors.primaryBlue,
                  ),
                );
              }),

              const SizedBox(height: 18),

              // Amount Input Field
              Text(
                'Amount to Transfer',
                style: AppTypography.caption.copyWith(fontWeight: FontWeight.bold, color: AppColors.navyText),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.primaryBlue, width: 1.5),
                  boxShadow: const [AppColors.softBlueShadow],
                ),
                child: Row(
                  children: [
                    Text(
                      '₹',
                      style: AppTypography.display.copyWith(
                        color: AppColors.primaryBlue,
                        fontWeight: FontWeight.w800,
                        fontSize: 28,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: controller.amountController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        style: AppTypography.h1.copyWith(
                          color: AppColors.navyText,
                          fontWeight: FontWeight.w800,
                          fontSize: 24,
                        ),
                        decoration: const InputDecoration(
                          hintText: '0',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Note (Optional)
              AppTextField(
                label: 'Add Note (Optional)',
                hint: 'e.g. Rent, Dinner, Chai',
                controller: controller.noteController,
                prefixIcon: const Icon(Icons.notes_rounded, color: AppColors.textSecondary),
              ),

              const SizedBox(height: 24),

              // Recent Contacts Quick Pick
              Text(
                'Recent Contacts',
                style: AppTypography.caption.copyWith(fontWeight: FontWeight.bold, color: AppColors.navyText),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 88,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: controller.recentContacts.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final contact = controller.recentContacts[index];
                    final name = contact['name'] ?? '';
                    final initials = name.split(' ').map((p) => p.isNotEmpty ? p[0] : '').take(2).join();

                    return GestureDetector(
                      onTap: () => controller.selectContact(contact),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              gradient: AppColors.blueGradient,
                              shape: BoxShape.circle,
                              boxShadow: const [AppColors.softBlueShadow],
                            ),
                            child: Center(
                              child: Text(
                                initials,
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          SizedBox(
                            width: 64,
                            child: Text(
                              name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.navyText),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 28),

              // Transfer Button
              Obx(() => AppButton(
                    text: 'Send Money Instantly',
                    type: ButtonType.orangePrimary,
                    height: 52,
                    isLoading: controller.isSending.value,
                    onPressed: controller.sendMoney,
                  )),

              const SizedBox(height: 14),

              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.shield_rounded, color: AppColors.success, size: 16),
                    SizedBox(width: 6),
                    Text(
                      '100% RBI Certified Secure Instant Settlement',
                      style: TextStyle(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
