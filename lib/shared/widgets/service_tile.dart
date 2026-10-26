import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../data/models/service_item_model.dart';

class ServiceTile extends StatelessWidget {
  final ServiceItemModel service;
  final VoidCallback onTap;

  const ServiceTile({
    super.key,
    required this.service,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2.0, vertical: 2.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Icon Box with tinted background
              Flexible(
                flex: 3,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: service.tintColor,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: const [AppColors.cardShadow],
                    ),
                    child: Center(
                      child: Icon(
                        service.icon,
                        color: service.iconColor,
                        size: 24,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              // 2-line centered label
              Flexible(
                flex: 2,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    service.title,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.micro.copyWith(
                      color: AppColors.navyText,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      height: 1.2,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
