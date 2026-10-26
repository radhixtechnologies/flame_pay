import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../core/network/api_client.dart';
import '../../core/network/api_endpoints.dart';
import '../../data/models/offer_model.dart';
import '../../shared/widgets/state_view.dart';
import '../../core/theme/app_colors.dart';

class OffersController extends GetxController {
  final ApiClient _apiClient = ApiClient.instance;

  final Rx<ViewState> viewState = ViewState.loading.obs;
  final RxList<OfferModel> offers = <OfferModel>[].obs;
  final RxString selectedCategory = 'All'.obs;
  final List<String> categories = ['All', 'Bills', 'Recharge', 'Loans', 'Cards'];

  final RxList<int> scratchRewards = <int>[50, 100, 25, 75].obs;
  final RxList<bool> scratchedStates = <bool>[false, false, false, false].obs;

  @override
  void onInit() {
    super.onInit();
    fetchOffers();
  }

  Future<void> fetchOffers() async {
    viewState.value = ViewState.loading;
    try {
      final res = await _apiClient.get<List<OfferModel>>(
        ApiEndpoints.offersList,
        queryParameters: selectedCategory.value != 'All' ? {'category': selectedCategory.value} : null,
        fromJson: (json) => (json as List<dynamic>)
            .map((e) => OfferModel.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

      if (res.success && res.data != null) {
        offers.assignAll(res.data!);
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
    fetchOffers();
  }

  void copyCouponCode(String code) {
    Clipboard.setData(ClipboardData(text: code));
  }

  void revealScratchCard(int index) {
    if (!scratchedStates[index]) {
      scratchedStates[index] = true;
      final amount = scratchRewards[index];
      Get.dialog(
        Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.celebration_rounded, color: AppColors.accentOrange, size: 50),
                const SizedBox(height: 12),
                const Text('Congratulations!', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.navyText)),
                const SizedBox(height: 8),
                Text('You won ₹$amount Cashback in your FlamePay Wallet!', textAlign: TextAlign.center, style: const TextStyle(fontSize: 14, color: AppColors.textSecondary)),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    minimumSize: const Size(double.infinity, 44),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () => Get.back(),
                  child: const Text('Claim Reward', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ),
      );
    }
  }
}
