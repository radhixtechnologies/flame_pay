import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../data/models/operator_model.dart';

class OperatorSelectorSheet extends StatefulWidget {
  final List<OperatorModel> operators;
  final OperatorModel? selectedOperator;
  final Function(OperatorModel) onSelect;
  final String title;

  const OperatorSelectorSheet({
    super.key,
    required this.operators,
    this.selectedOperator,
    required this.onSelect,
    this.title = 'Select Operator',
  });

  static Future<OperatorModel?> show({
    required BuildContext context,
    required List<OperatorModel> operators,
    OperatorModel? selectedOperator,
    String title = 'Select Operator',
  }) {
    return showModalBottomSheet<OperatorModel>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => OperatorSelectorSheet(
        operators: operators,
        selectedOperator: selectedOperator,
        title: title,
        onSelect: (op) => Get.back(result: op),
      ),
    );
  }

  @override
  State<OperatorSelectorSheet> createState() => _OperatorSelectorSheetState();
}

class _OperatorSelectorSheetState extends State<OperatorSelectorSheet> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final filtered = widget.operators.where((op) {
      return op.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (op.code?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);
    }).toList();

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.75,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 44,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.title,
                  style: AppTypography.title.copyWith(
                    color: AppColors.navyText,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: AppColors.textSecondary),
                  onPressed: () => Get.back(),
                ),
              ],
            ),
          ),

          // Search Box
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: TextField(
                onChanged: (val) => setState(() => _searchQuery = val),
                decoration: InputDecoration(
                  hintText: 'Search ${widget.title}...',
                  prefixIcon: const Icon(Icons.search, color: AppColors.textMuted, size: 20),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 11),
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),
          const Divider(height: 1, color: AppColors.border),

          // List of operators
          Flexible(
            child: filtered.isEmpty
                ? const Padding(
                    padding: EdgeInsets.all(32.0),
                    child: Center(child: Text('No results found', style: TextStyle(color: AppColors.textSecondary))),
                  )
                : ListView.separated(
                    shrinkWrap: true,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    itemCount: filtered.length,
                    separatorBuilder: (_, _) => const Divider(height: 1, color: AppColors.border),
                    itemBuilder: (context, index) {
                      final op = filtered[index];
                      final isSelected = widget.selectedOperator?.id == op.id;
                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(vertical: 4),
                        leading: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: AppColors.tintBlue,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: Icon(
                              op.type == 'dth'
                                  ? Icons.tv_rounded
                                  : op.type == 'electricity'
                                      ? Icons.bolt_rounded
                                      : op.type == 'water'
                                          ? Icons.water_drop_rounded
                                          : op.type == 'gas'
                                              ? Icons.local_fire_department_rounded
                                              : op.type == 'broadband'
                                                  ? Icons.wifi_rounded
                                                  : op.type == 'emi'
                                                      ? Icons.account_balance_rounded
                                                      : Icons.sim_card_rounded,
                              color: AppColors.primaryBlue,
                              size: 22,
                            ),
                          ),
                        ),
                        title: Text(
                          op.name,
                          style: AppTypography.bodyBold.copyWith(
                            color: isSelected ? AppColors.primaryBlue : AppColors.navyText,
                          ),
                        ),
                        trailing: isSelected
                            ? const Icon(Icons.check_circle_rounded, color: AppColors.primaryBlue)
                            : const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
                        onTap: () => widget.onSelect(op),
                      );
                    },
                  ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
