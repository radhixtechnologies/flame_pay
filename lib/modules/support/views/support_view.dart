import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/blue_header_scaffold.dart';
import '../support_controller.dart';

class SupportView extends GetView<SupportController> {
  const SupportView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlueHeaderScaffold(
      title: 'Help & 24x7 Support',
      
      body: Column(
        children: [
          _buildSearchHeader(),
          _buildCategoryChips(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildQuickContactRow(),
                  const SizedBox(height: 20),
                  Text('Frequently Asked Questions', style: AppTypography.title),
                  const SizedBox(height: 10),
                  _buildFaqList(),
                  const SizedBox(height: 24),
                  _buildStillNeedHelpCard(),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchHeader() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: TextField(
        onChanged: (val) => controller.searchQuery.value = val,
        decoration: InputDecoration(
          hintText: 'Search queries (e.g. refund, KYC, limits)...',
          prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primaryBlue),
          filled: true,
          fillColor: const Color(0xFFF9FAFB),
          contentPadding: const EdgeInsets.symmetric(vertical: 10),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE4E7EC)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE4E7EC)),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryChips() {
    return Container(
      color: Colors.white,
      height: 48,
      child: Obx(() => ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: controller.categories.length,
            itemBuilder: (context, index) {
              final cat = controller.categories[index];
              final isSelected = controller.selectedCategory.value == cat;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                child: ChoiceChip(
                  label: Text(cat),
                  selected: isSelected,
                  onSelected: (_) => controller.selectCategory(cat),
                  selectedColor: AppColors.primaryBlue,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : AppColors.navyText,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    fontSize: 12,
                  ),
                  backgroundColor: const Color(0xFFF2F4F7),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  showCheckmark: false,
                ),
              );
            },
          )),
    );
  }

  Widget _buildQuickContactRow() {
    return Row(
      children: [
        _buildContactTile(
          icon: Icons.chat_bubble_outline_rounded,
          iconColor: AppColors.primaryBlue,
          title: 'Live Chat',
          subtitle: 'Instant AI bot',
          onTap: controller.openLiveChat,
        ),
        const SizedBox(width: 10),
        _buildContactTile(
          icon: Icons.phone_in_talk_outlined,
          iconColor: AppColors.accentOrange,
          title: 'Toll-Free',
          subtitle: '1800-FLAME-PAY',
          onTap: () {
            Get.snackbar('Calling FlamePay Support', 'Dialing 1800-352-63729 (Toll-Free)', snackPosition: SnackPosition.BOTTOM);
          },
        ),
        const SizedBox(width: 10),
        _buildContactTile(
          icon: Icons.confirmation_number_outlined,
          iconColor: AppColors.success,
          title: 'New Ticket',
          subtitle: 'Raise dispute',
          onTap: controller.openTicketSheet,
        ),
      ],
    );
  }

  Widget _buildContactTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE4E7EC)),
          ),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              const SizedBox(height: 8),
              Text(title, style: AppTypography.bodyBold.copyWith(fontSize: 12)),
              const SizedBox(height: 2),
              Text(subtitle, style: AppTypography.micro.copyWith(color: AppColors.textSecondary), textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFaqList() {
    return Obx(() {
      final faqs = controller.filteredFaqs;
      if (faqs.isEmpty) {
        return Container(
          padding: const EdgeInsets.all(24),
          alignment: Alignment.center,
          child: Column(
            children: [
              const Icon(Icons.search_off_rounded, size: 48, color: Colors.grey),
              const SizedBox(height: 8),
              Text('No matching questions found', style: AppTypography.caption),
            ],
          ),
        );
      }

      return ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: faqs.length,
        separatorBuilder: (context, index) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final faq = faqs[index];
          final isExpanded = controller.expandedIndex.value == index;

          return Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE4E7EC)),
              ),
              child: Theme(
              data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                initiallyExpanded: isExpanded,
                onExpansionChanged: (val) => controller.toggleFaq(index),
                title: Text(
                  faq.question,
                  style: AppTypography.bodyBold.copyWith(fontSize: 13, color: AppColors.navyText),
                ),
                childrenPadding: const EdgeInsets.only(left: 16, right: 16, bottom: 14),
                children: [
                  Text(
                    faq.answer,
                    style: AppTypography.caption.copyWith(fontSize: 12, height: 1.45, color: const Color(0xFF475467)),
                  ),
                ],
              ),
            ),
          ),
        );
        },
      );
    });
  }

  Widget _buildStillNeedHelpCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryBlue.withValues(alpha: 0.08),
            AppColors.accentOrange.withValues(alpha: 0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primaryBlue.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.help_center_rounded, color: AppColors.primaryBlue, size: 36),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Still need personalized help?', style: AppTypography.bodyBold),
                const SizedBox(height: 2),
                Text('Our dispute desk is available 24 hours a day, 7 days a week.', style: AppTypography.caption),
              ],
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: controller.openTicketSheet,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Contact', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
          ),
        ],
      ),
    );
  }
}
