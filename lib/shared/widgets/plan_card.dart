import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/formatters.dart';
import '../../data/models/recharge_plan_model.dart';

class PlanCard extends StatelessWidget {
  final RechargePlanModel plan;
  final VoidCallback onSelect;

  const PlanCard({
    super.key,
    required this.plan,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: plan.isPopular ? AppColors.accentOrange : AppColors.border,
          width: plan.isPopular ? 1.5 : 1,
        ),
        boxShadow: const [AppColors.cardShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Popular banner if applicable
          if (plan.isPopular)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              decoration: const BoxDecoration(
                gradient: AppColors.orangeGradient,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  bottomRight: Radius.circular(12),
                ),
              ),
              child: Text(
                '★ POPULAR PACK',
                style: AppTypography.micro.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ),

          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Row: Amount & Select Button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: FittedBox(
                        alignment: Alignment.centerLeft,
                        fit: BoxFit.scaleDown,
                        child: Text(
                          Formatters.formatCurrency(plan.amount),
                          style: AppTypography.display.copyWith(
                            color: AppColors.navyText,
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: onSelect,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accentOrange,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                      ),
                      child: const Text('Select', style: TextStyle(fontWeight: FontWeight.w700)),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Key metrics row: Validity, Data, Calls
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.tintBlue,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      _MetricItem(label: 'Validity', value: plan.validity),
                      _VerticalDivider(),
                      _MetricItem(label: 'Data', value: plan.data),
                      _VerticalDivider(),
                      _MetricItem(label: 'Voice', value: plan.talktime),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                // Description
                Text(
                  plan.description,
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 12.5,
                    height: 1.4,
                  ),
                ),

                // OTT Benefits
                if (plan.ottBenefits.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: plan.ottBenefits.map((ott) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.flameYellow.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: AppColors.flameYellow.withValues(alpha: 0.6),
                          ),
                        ),
                        child: Text(
                          ott,
                          style: AppTypography.micro.copyWith(
                            color: const Color(0xFF8B5E00),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricItem extends StatelessWidget {
  final String label;
  final String value;
  const _MetricItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTypography.micro.copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: 2),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.caption.copyWith(
              color: AppColors.navyText,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _VerticalDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 24,
      color: AppColors.border,
      margin: const EdgeInsets.symmetric(horizontal: 8),
    );
  }
}
