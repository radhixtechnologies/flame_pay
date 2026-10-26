import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/recent_transaction_tile.dart';
import '../history_controller.dart';
import '../../../shared/widgets/state_view.dart';

class HistoryView extends GetView<HistoryController> {
  const HistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Transaction History', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.primaryBlue,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          // Search & Filter Header
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: Column(
              children: [
                // Search Input
                TextField(
                  controller: controller.searchController,
                  onChanged: controller.onSearchChanged,
                  decoration: InputDecoration(
                    hintText: 'Search by merchant, biller, or ID...',
                    prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textSecondary),
                    filled: true,
                    fillColor: AppColors.background,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                // Filter Chips
                SingleChildScrollView(
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
                                fontSize: 12,
                              ),
                              backgroundColor: AppColors.tintBlue,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                            ),
                          );
                        }).toList(),
                      )),
                ),
              ],
            ),
          ),

          // Transactions List
          Expanded(
            child: Obx(() {
              if (controller.viewState.value == ViewState.loading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.filteredTransactions.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.receipt_long_outlined, size: 56, color: AppColors.textMuted),
                      const SizedBox(height: 12),
                      Text('No Transactions Found', style: AppTypography.title.copyWith(color: AppColors.navyText)),
                      const SizedBox(height: 4),
                      Text('Try changing your search or filter', style: AppTypography.caption),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: controller.filteredTransactions.length,
                itemBuilder: (context, index) {
                  final txn = controller.filteredTransactions[index];
                  return RecentTransactionTile(
                    transaction: txn,
                    onTap: () => controller.showTransactionReceipt(context, txn),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}
