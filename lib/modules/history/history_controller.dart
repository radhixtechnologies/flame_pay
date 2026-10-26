import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/network/api_client.dart';
import '../../core/network/api_endpoints.dart';
import '../../data/models/transaction_model.dart';
import '../../shared/widgets/state_view.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/formatters.dart';

class HistoryController extends GetxController {
  final ApiClient _apiClient = ApiClient.instance;

  final Rx<ViewState> viewState = ViewState.loading.obs;
  final RxList<TransactionModel> allTransactions = <TransactionModel>[].obs;
  final RxList<TransactionModel> filteredTransactions = <TransactionModel>[].obs;

  final RxString selectedCategory = 'All'.obs;
  final List<String> categories = ['All', 'Recharge', 'Bill', 'Wallet'];
  final TextEditingController searchController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    fetchHistory();
  }

  Future<void> fetchHistory() async {
    viewState.value = ViewState.loading;
    try {
      final res = await _apiClient.get<List<TransactionModel>>(
        ApiEndpoints.transactionsHistory,
        fromJson: (json) => (json as List<dynamic>)
            .map((e) => TransactionModel.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

      if (res.success && res.data != null) {
        allTransactions.assignAll(res.data!);
        applyFilter();
        viewState.value = ViewState.success;
      } else {
        viewState.value = ViewState.error;
      }
    } catch (_) {
      viewState.value = ViewState.error;
    }
  }

  void onCategorySelected(String cat) {
    selectedCategory.value = cat;
    applyFilter();
  }

  void onSearchChanged(String query) {
    applyFilter();
  }

  void applyFilter() {
    final cat = selectedCategory.value;
    final query = searchController.text.trim().toLowerCase();

    var list = allTransactions.toList();
    if (cat != 'All') {
      list = list.where((t) => t.category.toLowerCase() == cat.toLowerCase()).toList();
    }
    if (query.isNotEmpty) {
      list = list.where((t) =>
          t.title.toLowerCase().contains(query) ||
          t.subtitle.toLowerCase().contains(query) ||
          t.id.toLowerCase().contains(query)).toList();
    }
    filteredTransactions.assignAll(list);
  }

  void showTransactionReceipt(BuildContext context, TransactionModel txn) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
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
            Container(
              width: 56,
              height: 56,
              decoration: const BoxDecoration(
                color: AppColors.tintGreen,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 36),
            ),
            const SizedBox(height: 12),
            Text('Payment Successful', style: AppTypography.title.copyWith(color: AppColors.navyText, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(Formatters.formatCurrency(txn.amount), style: AppTypography.display.copyWith(color: AppColors.primaryBlue, fontSize: 30, fontWeight: FontWeight.w900)),
            const SizedBox(height: 16),
            const Divider(color: AppColors.border),
            const SizedBox(height: 12),

            _buildReceiptRow('Transaction ID', txn.id),
            _buildReceiptRow('Paid To / For', txn.title),
            _buildReceiptRow('Category', txn.category.toUpperCase()),
            _buildReceiptRow('Date & Time', Formatters.formatDateTime(txn.timestamp)),
            _buildReceiptRow('Payment Method', 'FlamePay Wallet'),
            _buildReceiptRow('Status', txn.status.toUpperCase(), isSuccess: true),

            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.primaryBlue),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: () {
                      Get.back();
                      Get.snackbar('Receipt Saved', 'Receipt downloaded to device storage', backgroundColor: AppColors.tintBlue);
                    },
                    icon: const Icon(Icons.download_rounded, size: 18, color: AppColors.primaryBlue),
                    label: const Text('Download', style: TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: () {
                      Get.back();
                      Get.snackbar('Share', 'Transaction receipt link shared', backgroundColor: AppColors.tintGreen);
                    },
                    icon: const Icon(Icons.share_rounded, size: 18, color: Colors.white),
                    label: const Text('Share', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _buildReceiptRow(String label, String value, {bool isSuccess = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTypography.caption.copyWith(color: AppColors.textSecondary)),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.caption.copyWith(
                color: isSuccess ? AppColors.success : AppColors.navyText,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
