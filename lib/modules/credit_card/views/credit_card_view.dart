import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/state_view.dart';
import '../../../data/models/credit_card_model.dart';
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
                      ElevatedButton(onPressed: () => controller.onCategoryChanged('All'), child: const Text('Reset Filter')),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: controller.cards.length,
                itemBuilder: (context, index) {
                  final card = controller.cards[index];
                  return _buildCardItem(context, card);
                },
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
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [AppColors.cardShadow],
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 3D Credit Card Render
          Container(
            height: 206,
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [startColor, endColor],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: startColor.withValues(alpha: 0.35),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      card.bank,
                      style: AppTypography.title.copyWith(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const Icon(Icons.contactless_rounded, color: Colors.white70, size: 24),
                  ],
                ),
                Row(
                  children: [
                    Container(
                      width: 34,
                      height: 26,
                      decoration: BoxDecoration(
                        color: Colors.amber.shade300,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Center(
                        child: Icon(Icons.memory_rounded, color: Colors.amber.shade900, size: 18),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        '••••  ••••  ••••  9842',
                        style: AppTypography.body.copyWith(
                          color: Colors.white,
                          letterSpacing: 1.5,
                          fontSize: 13.5,
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
                          Text('ROHIT KUMAR', style: AppTypography.caption.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                    Text(
                      card.cardNetwork,
                      style: AppTypography.title.copyWith(
                        color: Colors.white,
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        card.name,
                        style: AppTypography.title.copyWith(color: AppColors.navyText, fontSize: 17, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.tintOrange,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        card.rewardRate,
                        style: AppTypography.micro.copyWith(color: AppColors.accentOrange, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Annual Fee: ${card.annualFee}',
                  style: AppTypography.caption.copyWith(color: AppColors.textSecondary, fontSize: 12),
                ),
                const SizedBox(height: 12),

                // Benefits
                ...card.benefits.map((b) => Padding(
                      padding: const EdgeInsets.only(bottom: 6.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 16),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              b,
                              style: AppTypography.caption.copyWith(color: AppColors.navyText, fontSize: 12.5),
                            ),
                          ),
                        ],
                      ),
                    )),

                const SizedBox(height: 16),

                // Apply CTA Button
                AppButton(
                  text: 'Apply Now',
                  type: ButtonType.orangePrimary,
                  onPressed: () => _showApplyBottomSheet(context, card),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showApplyBottomSheet(BuildContext context, CreditCardModel card) {
    final nameCtrl = TextEditingController(text: 'Rohit Kumar');
    final panCtrl = TextEditingController(text: 'ABCDE1234F');
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
                    Text('Apply for ${card.name}', style: AppTypography.title.copyWith(color: AppColors.navyText)),
                    IconButton(icon: const Icon(Icons.close_rounded), onPressed: () => Get.back()),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: nameCtrl,
                  decoration: InputDecoration(
                    labelText: 'Full Name as per PAN',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: panCtrl,
                  textCapitalization: TextCapitalization.characters,
                  decoration: InputDecoration(
                    labelText: 'PAN Card Number',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: incomeCtrl,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Monthly Income (₹)',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: empType,
                  decoration: InputDecoration(
                    labelText: 'Employment Type',
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
                          name: nameCtrl.text,
                          pan: panCtrl.text,
                          income: double.tryParse(incomeCtrl.text) ?? 35000.0,
                          empType: empType,
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
}
