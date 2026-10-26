import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/cibil_model.dart';
import '../../data/repositories/financial_services_repository.dart';
import '../../shared/widgets/state_view.dart';

class CibilController extends GetxController {
  final FinancialServicesRepository _repo = Get.find<FinancialServicesRepository>();

  final Rx<ViewState> viewState = ViewState.loading.obs;
  final Rx<CibilScoreModel?> cibilReport = Rx<CibilScoreModel?>(null);

  @override
  void onInit() {
    super.onInit();
    fetchCibilReport();
  }

  Future<void> fetchCibilReport() async {
    viewState.value = ViewState.loading;
    try {
      final res = await _repo.getCibilReport();
      if (res.success && res.data != null) {
        cibilReport.value = res.data;
        viewState.value = ViewState.success;
      } else {
        viewState.value = ViewState.error;
      }
    } catch (_) {
      viewState.value = ViewState.error;
    }
  }

  void downloadReport() {
    Get.snackbar(
      'Download Started',
      'CIBIL Credit Health Report (PDF) is downloading...',
      backgroundColor: AppColors.tintGreen,
      icon: const Icon(Icons.download_done_rounded, color: AppColors.success),
      duration: const Duration(seconds: 3),
    );
  }

  void refreshScore() {
    Get.snackbar(
      'Score Up-to-Date',
      'Your CIBIL score is current as of ${cibilReport.value?.lastUpdated ?? "Today"}. Next refresh on ${cibilReport.value?.nextRefreshDate ?? "next month"}.',
      backgroundColor: AppColors.tintBlue,
      duration: const Duration(seconds: 3),
    );
  }
}
