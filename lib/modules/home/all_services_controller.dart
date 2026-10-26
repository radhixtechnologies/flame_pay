import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/utils/debouncer.dart';
import '../../data/models/service_item_model.dart';
import '../../data/mock/mock_home_data.dart';
import '../../shared/widgets/state_view.dart';

class AllServicesController extends GetxController {
  final searchController = TextEditingController();
  final debouncer = Debouncer(milliseconds: 250);

  final Rx<ViewState> viewState = ViewState.success.obs;
  final RxString searchQuery = ''.obs;

  final RxList<ServiceItemModel> rechargeAndBills = <ServiceItemModel>[].obs;
  final RxList<ServiceItemModel> insuranceServices = <ServiceItemModel>[].obs;
  final RxList<ServiceItemModel> financialServices = <ServiceItemModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    _filterServices('');
  }

  void onSearchChanged(String query) {
    debouncer.run(() {
      searchQuery.value = query.trim();
      _filterServices(searchQuery.value);
    });
  }

  void clearSearch() {
    searchController.clear();
    searchQuery.value = '';
    _filterServices('');
  }

  void _filterServices(String query) {
    final all = MockHomeData.allServices;
    if (query.isEmpty) {
      rechargeAndBills.assignAll(
        all.where((s) => s.category == ServiceCategory.rechargeAndBills),
      );
      insuranceServices.assignAll(
        all.where((s) => s.category == ServiceCategory.insurance),
      );
      financialServices.assignAll(
        all.where((s) => s.category == ServiceCategory.financialServices),
      );
      viewState.value = ViewState.success;
      return;
    }

    final lower = query.toLowerCase();
    final filtered = all.where((s) =>
        s.title.toLowerCase().replaceAll('\n', ' ').contains(lower)).toList();

    rechargeAndBills.assignAll(
      filtered.where((s) => s.category == ServiceCategory.rechargeAndBills),
    );
    insuranceServices.assignAll(
      filtered.where((s) => s.category == ServiceCategory.insurance),
    );
    financialServices.assignAll(
      filtered.where((s) => s.category == ServiceCategory.financialServices),
    );

    if (rechargeAndBills.isEmpty && insuranceServices.isEmpty && financialServices.isEmpty) {
      viewState.value = ViewState.empty;
    } else {
      viewState.value = ViewState.success;
    }
  }

  @override
  void onClose() {
    searchController.dispose();
    debouncer.dispose();
    super.onClose();
  }
}
