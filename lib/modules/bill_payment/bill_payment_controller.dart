import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/models/operator_model.dart';
import '../../data/models/bill_fetch_model.dart';
import '../../data/mock/mock_recharge_data.dart';
import '../../data/repositories/recharge_repository.dart';
import '../../shared/widgets/payment_success_view.dart';

class BillPaymentController extends GetxController {
  final RechargeRepository _repo = Get.find<RechargeRepository>();

  final consumerNumberController = TextEditingController(text: '1002345678');
  final promoCodeController = TextEditingController();

  final RxString selectedCategory = 'electricity'.obs;
  final Rx<OperatorModel> selectedBiller = MockRechargeData.billers.first.obs;

  final Rx<BillFetchModel?> fetchedBill = Rx<BillFetchModel?>(null);
  final RxBool isFetchingBill = false.obs;
  final RxBool isPayingBill = false.obs;

  final RxString selectedPaymentMode = 'FlamePay Wallet'.obs;
  final RxString appliedPromo = ''.obs;
  final RxDouble discountAmount = 0.0.obs;

  final List<Map<String, dynamic>> categories = [
    {'id': 'electricity', 'name': 'Electricity', 'icon': Icons.bolt_rounded},
    {'id': 'water', 'name': 'Water', 'icon': Icons.water_drop_rounded},
    {'id': 'gas', 'name': 'Piped Gas', 'icon': Icons.local_fire_department_rounded},
    {'id': 'broadband', 'name': 'Broadband', 'icon': Icons.wifi_rounded},
    {'id': 'emi', 'name': 'Loan / EMI', 'icon': Icons.account_balance_rounded},
  ];

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is Map && args['category'] != null) {
      selectedCategory.value = args['category'].toString();
    }
    updateBillerForCategory();
    fetchBill();
  }

  void onSelectCategory(String catId) {
    selectedCategory.value = catId;
    updateBillerForCategory();
    fetchedBill.value = null;
  }

  void updateBillerForCategory() {
    final list = MockRechargeData.billers.where((b) => b.type == selectedCategory.value).toList();
    if (list.isNotEmpty) {
      selectedBiller.value = list.first;
    }
  }

  List<OperatorModel> get billersForCategory {
    return MockRechargeData.billers.where((b) => b.type == selectedCategory.value).toList();
  }

  Future<void> fetchBill() async {
    final consumerNum = consumerNumberController.text.trim();
    if (consumerNum.isEmpty) {
      Get.snackbar('Validation', 'Please enter Consumer Number', backgroundColor: Colors.orange.shade100);
      return;
    }

    isFetchingBill.value = true;
    try {
      final res = await _repo.fetchBill(selectedBiller.value.id, consumerNum);
      if (res.success && res.data != null) {
        fetchedBill.value = res.data;
      } else {
        Get.snackbar('Error', res.message, backgroundColor: Colors.red.shade100);
      }
    } catch (e) {
      Get.snackbar('Error', e.toString(), backgroundColor: Colors.red.shade100);
    } finally {
      isFetchingBill.value = false;
    }
  }

  void applyPromo(String code) {
    if (code.toUpperCase() == 'POW50') {
      appliedPromo.value = 'POW50';
      discountAmount.value = 50.0;
      Get.snackbar('Success', 'Promo POW50 applied! ₹50 Discount', backgroundColor: Colors.green.shade100);
    } else {
      Get.snackbar('Invalid Promo', 'Please enter a valid coupon code', backgroundColor: Colors.orange.shade100);
    }
  }

  void removePromo() {
    appliedPromo.value = '';
    discountAmount.value = 0.0;
  }

  double get finalPayableAmount {
    if (fetchedBill.value == null) return 0.0;
    final total = fetchedBill.value!.billAmount - discountAmount.value;
    return total > 0 ? total : 0.0;
  }

  Future<void> payBill() async {
    if (fetchedBill.value == null) return;

    isPayingBill.value = true;
    try {
      final res = await _repo.processBillPayment(
        billerId: selectedBiller.value.name,
        consumerNumber: consumerNumberController.text.trim(),
        amount: finalPayableAmount,
        paymentMode: selectedPaymentMode.value,
        promoCode: appliedPromo.value.isNotEmpty ? appliedPromo.value : null,
      );

      if (res.success && res.data != null) {
        Get.off(() => PaymentSuccessView(result: res.data!));
      } else {
        Get.snackbar('Error', res.message, backgroundColor: Colors.red.shade100);
      }
    } catch (e) {
      Get.snackbar('Error', e.toString(), backgroundColor: Colors.red.shade100);
    } finally {
      isPayingBill.value = false;
    }
  }

  @override
  void onClose() {
    consumerNumberController.dispose();
    promoCodeController.dispose();
    super.onClose();
  }
}
