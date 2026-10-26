import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

class PromoBanner extends StatelessWidget {
  final String title;
  final String highlight;
  final String subtitle;
  final VoidCallback? onTap;

  const PromoBanner({
    super.key,
    this.title = 'Get Up to',
    this.highlight = '₹1,000 Cashback',
    this.subtitle = 'on Bill Payments',
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 104),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0F2B66),
            Color(0xFF1548B8),
            Color(0xFF0A2B75),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [AppColors.softBlueShadow],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            child: Row(
              children: [
                // Text side
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        title,
                        style: AppTypography.caption.copyWith(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        highlight,
                        style: AppTypography.title.copyWith(
                          color: AppColors.flameYellow,
                          fontSize: 19,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: AppTypography.micro.copyWith(
                          color: Colors.white.withValues(alpha: 0.85),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

                // Graphic Side: Gift Box with gold coins
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      const Icon(
                        Icons.card_giftcard_rounded,
                        color: AppColors.accentOrange,
                        size: 42,
                      ),
                      Positioned(
                        right: 8,
                        top: 8,
                        child: Container(
                          width: 14,
                          height: 14,
                          decoration: const BoxDecoration(
                            color: AppColors.flameYellow,
                            shape: BoxShape.circle,
                          ),
                          child: const Center(
                            child: Text(
                              '₹',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF8B5E00),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
