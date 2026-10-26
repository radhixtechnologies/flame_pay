import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/notification_model.dart';
import '../notifications_controller.dart';
import '../../../shared/widgets/state_view.dart';

class NotificationsView extends GetView<NotificationsController> {
  const NotificationsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Notifications', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.primaryBlue,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          Obx(() {
            if (controller.unreadCount > 0) {
              return TextButton(
                onPressed: controller.markAllAsRead,
                child: const Text('Mark all as read', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
              );
            }
            return const SizedBox.shrink();
          }),
        ],
      ),
      body: Column(
        children: [
          // Filter Chips
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: controller.categories.map((cat) {
                return Obx(() {
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
                        fontSize: 12,
                      ),
                      backgroundColor: AppColors.tintBlue,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                    ),
                  );
                });
              }).toList(),
              ),
            ),
          ),

          // Notifications List
          Expanded(
            child: Obx(() {
              if (controller.viewState.value == ViewState.loading) {
                return const Center(child: CircularProgressIndicator());
              }

              final list = controller.filteredList;

              if (list.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.notifications_none_rounded, size: 56, color: AppColors.textMuted),
                      const SizedBox(height: 12),
                      Text('No Notifications', style: AppTypography.title.copyWith(color: AppColors.navyText)),
                      const SizedBox(height: 4),
                      Text('You are all caught up!', style: AppTypography.caption),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: list.length,
                itemBuilder: (context, index) {
                  final notif = list[index];
                  return _buildNotificationTile(notif);
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationTile(NotificationModel notif) {
    IconData icon;
    Color iconColor;
    Color tintColor;

    switch (notif.category) {
      case 'offer':
        icon = Icons.local_offer_rounded;
        iconColor = AppColors.accentOrange;
        tintColor = AppColors.tintOrange;
        break;
      case 'security':
        icon = Icons.shield_rounded;
        iconColor = Color(0xFF7C3AED);
        tintColor = Color(0xFFF1EAFE);
        break;
      default:
        icon = Icons.receipt_long_rounded;
        iconColor = AppColors.primaryBlue;
        tintColor = AppColors.tintBlue;
    }

    return Dismissible(
      key: Key(notif.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => controller.dismissNotification(notif.id),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppColors.flameRed,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_outline_rounded, color: Colors.white),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: notif.isRead ? Colors.white : const Color(0xFFF4F7FF),
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [AppColors.cardShadow],
          border: Border.all(color: notif.isRead ? AppColors.border : AppColors.primaryBlue.withValues(alpha: 0.3)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: tintColor,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          notif.title,
                          style: AppTypography.bodyBold.copyWith(
                            color: AppColors.navyText,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      if (!notif.isRead)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.primaryBlue,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notif.message,
                    style: AppTypography.caption.copyWith(color: AppColors.textSecondary, height: 1.35),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    Formatters.formatDateTime(notif.timestamp),
                    style: AppTypography.micro.copyWith(color: AppColors.textMuted),
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
