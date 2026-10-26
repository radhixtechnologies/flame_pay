import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/models/offer_model.dart';
import '../offers_controller.dart';
import '../../../shared/widgets/state_view.dart';

class OffersView extends GetView<OffersController> {
  const OffersView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Offers & Rewards', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.primaryBlue,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Scratch & Win Card Carousel
            _buildScratchCardsSection(),

            const SizedBox(height: 16),

            // Category Selector Chips
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
                            onSelected: (_) => controller.onCategorySelected(cat),
                            selectedColor: AppColors.primaryBlue,
                            labelStyle: TextStyle(
                              color: isSelected ? Colors.white : AppColors.navyText,
                              fontWeight: FontWeight.bold,
                              fontSize: 12.5,
                            ),
                            backgroundColor: AppColors.tintBlue,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                          ),
                        );
                      }).toList(),
                    )),
              ),
            ),

            const SizedBox(height: 16),

            // Offers List
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Trending Deals & Coupons', style: AppTypography.title.copyWith(color: AppColors.navyText, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Obx(() {
                    if (controller.viewState.value == ViewState.loading) {
                      return const Center(child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator()));
                    }

                    if (controller.offers.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32.0),
                          child: Text('No active offers in this category', style: AppTypography.caption),
                        ),
                      );
                    }

                    return Column(
                      children: controller.offers.map((offer) => _buildOfferCard(offer)).toList(),
                    );
                  }),
                ],
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildScratchCardsSection() {
    return Container(
      decoration: const BoxDecoration(
        gradient: AppColors.blueGradient,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text('FlamePay Scratch & Win', style: AppTypography.title.copyWith(color: Colors.white, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text('4 CARDS', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text('Tap any card to reveal your instant cashback', style: TextStyle(color: Colors.white70, fontSize: 12.5)),
          const SizedBox(height: 14),

          // Horizontal Scratch Cards
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Obx(() => Row(
                  children: List.generate(controller.scratchRewards.length, (index) {
                    final isScratched = controller.scratchedStates[index];
                    final reward = controller.scratchRewards[index];

                    return GestureDetector(
                      onTap: () => controller.revealScratchCard(index),
                      child: Container(
                        width: 100,
                        height: 120,
                        margin: const EdgeInsets.only(right: 12),
                        decoration: BoxDecoration(
                          color: isScratched ? Colors.white : AppColors.accentOrange,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: const [AppColors.cardShadow],
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: Center(
                          child: isScratched
                              ? Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.stars_rounded, color: AppColors.accentOrange, size: 28),
                                    const SizedBox(height: 4),
                                    Text('₹$reward', style: AppTypography.bodyBold.copyWith(color: AppColors.navyText, fontSize: 16)),
                                    Text('Won!', style: AppTypography.micro.copyWith(color: AppColors.success, fontWeight: FontWeight.bold)),
                                  ],
                                )
                              : Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.redeem_rounded, color: Colors.white, size: 32),
                                    const SizedBox(height: 6),
                                    Text('TAP TO\nSCRATCH', textAlign: TextAlign.center, style: AppTypography.micro.copyWith(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 9.5)),
                                  ],
                                ),
                        ),
                      ),
                    );
                  }),
                )),
          ),
        ],
      ),
    );
  }

  Widget _buildOfferCard(OfferModel offer) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [AppColors.cardShadow],
        border: Border.all(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    offer.title,
                    style: AppTypography.bodyBold.copyWith(color: AppColors.navyText, fontSize: 15),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.tintOrange,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    offer.discount,
                    style: AppTypography.micro.copyWith(color: AppColors.accentOrange, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              offer.description,
              style: AppTypography.caption.copyWith(color: AppColors.textSecondary, height: 1.4),
            ),
            const SizedBox(height: 14),

            // Dashed Voucher Code Bar with Copy Button
            Container(
              padding: const EdgeInsets.fromLTRB(12, 6, 6, 6),
              decoration: BoxDecoration(
                color: AppColors.tintBlue,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.primaryBlue.withValues(alpha: 0.3)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.confirmation_number_outlined, size: 16, color: AppColors.primaryBlue),
                      const SizedBox(width: 6),
                      Text(
                        offer.code,
                        style: const TextStyle(
                          color: AppColors.primaryBlue,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.2,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  InkWell(
                    onTap: () => controller.copyCouponCode(offer.code),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.primaryBlue,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text('COPY', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
