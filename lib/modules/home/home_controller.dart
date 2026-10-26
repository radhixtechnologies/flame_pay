import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../shared/widgets/state_view.dart';
import '../../data/models/transaction_model.dart';
import '../../data/models/offer_model.dart';
import '../../data/models/service_item_model.dart';
import '../../data/mock/mock_home_data.dart';
import '../../data/repositories/home_repository.dart';
import '../../core/services/auth_service.dart';
import '../../app/routes/app_routes.dart';

class HomeController extends GetxController {
  final HomeRepository _repo = Get.find<HomeRepository>();
  final AuthService authService = Get.find<AuthService>();

  final Rx<ViewState> viewState = ViewState.loading.obs;
  final RxDouble walletBalance = 2580.0.obs;
  final RxList<TransactionModel> recentTransactions = <TransactionModel>[].obs;
  final RxList<OfferModel> offers = <OfferModel>[].obs;

  // 8 Quick Services for 4x2 Home Grid
  final List<ServiceItemModel> quickServices = [
    MockHomeData.allServices.firstWhere((s) => s.id == 'mobile_recharge'),
    MockHomeData.allServices.firstWhere((s) => s.id == 'electricity_bill'),
    MockHomeData.allServices.firstWhere((s) => s.id == 'health_insurance'),
    MockHomeData.allServices.firstWhere((s) => s.id == 'cibil_score'),
    MockHomeData.allServices.firstWhere((s) => s.id == 'credit_card'),
    MockHomeData.allServices.firstWhere((s) => s.id == 'loan_apply'),
    MockHomeData.allServices.firstWhere((s) => s.id == 'dth_recharge'),
    ServiceItemModel(
      id: 'more_services',
      title: 'More\nServices',
      icon: Icons.grid_view_rounded,
      tintColor: const Color(0xFFF1EAFE),
      iconColor: const Color(0xFF7C3AED),
      route: AppRoutes.allServices,
      category: ServiceCategory.rechargeAndBills,
    ),
  ];

  @override
  void onInit() {
    super.onInit();
    fetchDashboardData();
  }

  Future<void> fetchDashboardData() async {
    viewState.value = ViewState.loading;
    try {
      final balanceRes = await _repo.getWalletBalance();
      if (balanceRes.success && balanceRes.data != null) {
        walletBalance.value = balanceRes.data!.balance;
      }

      final txnRes = await _repo.getRecentTransactions();
      if (txnRes.success && txnRes.data != null) {
        recentTransactions.assignAll(txnRes.data!);
      }

      final offersRes = await _repo.getOffers();
      if (offersRes.success && offersRes.data != null) {
        offers.assignAll(offersRes.data!);
      }

      viewState.value = ViewState.success;
    } catch (_) {
      viewState.value = ViewState.success; // fallback to cached mock data
    }
  }

  void onServiceSelected(ServiceItemModel service) {
    if (service.id == 'dth_recharge') {
      Get.toNamed(AppRoutes.recharge, arguments: {'isDth': true});
    } else {
      Get.toNamed(service.route);
    }
  }
}
