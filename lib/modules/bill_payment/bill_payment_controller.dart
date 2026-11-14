import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/models/operator_model.dart';
import '../../data/models/bill_fetch_model.dart';
import '../../data/mock/mock_recharge_data.dart';
import '../../data/repositories/recharge_repository.dart';
import '../../shared/widgets/payment_success_view.dart';

class BillPaymentController extends GetxController {
  final RechargeRepository _repo = Get.find<RechargeRepository>();

  final consumerNumberController = TextEditingController();
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
    {'id': 'mobile_postpaid', 'name': 'Postpaid Mobile', 'icon': Icons.phone_android_rounded},
    {'id': 'loan_emi', 'name': 'Loan / EMI', 'icon': Icons.account_balance_rounded},
    {'id': 'insurance_premium', 'name': 'Insurance', 'icon': Icons.health_and_safety_rounded},
    {'id': 'gas_cylinder', 'name': 'Gas Cylinder', 'icon': Icons.propane_tank_rounded},
    {'id': 'subscription', 'name': 'Subscription', 'icon': Icons.subscriptions_rounded},
    {'id': 'rental', 'name': 'Rental', 'icon': Icons.home_work_rounded},
    {'id': 'municipal_tax', 'name': 'Municipal Tax', 'icon': Icons.account_balance_rounded},
    {'id': 'education', 'name': 'Education Fees', 'icon': Icons.school_rounded},
    {'id': 'hospital', 'name': 'Hospital', 'icon': Icons.local_hospital_rounded},
    {'id': 'cable_tv', 'name': 'Cable TV', 'icon': Icons.tv_rounded},
    {'id': 'water', 'name': 'Water', 'icon': Icons.water_drop_rounded},
    {'id': 'gas', 'name': 'Piped Gas', 'icon': Icons.local_fire_department_rounded},
    {'id': 'broadband', 'name': 'Broadband', 'icon': Icons.wifi_rounded},
  ];

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is Map && args['category'] != null) {
      String cat = args['category'].toString();
      if (cat == 'emi') cat = 'loan_emi';
      if (cat == 'gas_bill') cat = 'gas';
      if (cat == 'water_bill') cat = 'water';
      if (cat == 'broadband_bill') cat = 'broadband';
      if (cat == 'electricity_bill') cat = 'electricity';
      selectedCategory.value = cat;
    }
    updateBillerForCategory();
  }

  void onSelectCategory(String catId) {
    selectedCategory.value = catId;
    updateBillerForCategory();
    fetchedBill.value = null;
  }

  void updateBillerForCategory() {
    final list = billersForCategory;
    if (list.isNotEmpty) {
      selectedBiller.value = list.first;
    }
  }

  List<OperatorModel> get billersForCategory {
    final cat = selectedCategory.value;
    return MockRechargeData.billers.where((b) {
      if (cat == 'loan_emi' || cat == 'emi') {
        return b.type == 'loan_emi' || b.type == 'emi';
      }
      return b.type == cat;
    }).toList();
  }

  String get consumerFieldLabel {
    switch (selectedCategory.value) {
      case 'mobile_postpaid':
        return 'Postpaid Mobile Number';
      case 'loan_emi':
      case 'emi':
        return 'Loan Account Number';
      case 'insurance_premium':
        return 'Policy Number';
      case 'gas_cylinder':
        return 'LPG ID / Consumer Number';
      case 'subscription':
        return 'Registered Mobile / Subscriber ID';
      case 'rental':
        return 'Agreement / Landlord Account / UPI';
      case 'municipal_tax':
        return 'Property Assessment / Khata Number';
      case 'education':
        return 'Student Roll / Enrollment Number';
      case 'hospital':
        return 'Patient UHID / Registration Number';
      case 'cable_tv':
        return 'Smart Card / Set-Top Box ID';
      case 'water':
        return 'Water Consumer ID / K-Number';
      case 'gas':
        return 'BP Number / Consumer Number';
      case 'broadband':
        return 'Broadband Account / User ID';
      default:
        return 'Consumer Number / CA Number';
    }
  }

  String get consumerFieldHint {
    switch (selectedCategory.value) {
      case 'mobile_postpaid':
        return 'Enter 10-digit Postpaid Mobile Number';
      case 'loan_emi':
      case 'emi':
        return 'Enter Loan Account / Agreement ID';
      case 'insurance_premium':
        return 'Enter Policy Number (e.g. 098765432)';
      case 'gas_cylinder':
        return 'Enter 17-digit LPG ID or Consumer No.';
      case 'subscription':
        return 'Enter Registered Mobile / Email';
      case 'rental':
        return 'Enter Landlord Account or UPI ID';
      case 'municipal_tax':
        return 'Enter Property Assessment Number';
      case 'education':
        return 'Enter Student Roll / Enrollment Number';
      case 'hospital':
        return 'Enter Patient UHID or Bill Number';
      case 'cable_tv':
        return 'Enter Set-Top Box Smart Card Number';
      case 'water':
        return 'Enter Water Connection Number';
      case 'gas':
        return 'Enter Piped Gas Consumer Number';
      case 'broadband':
        return 'Enter Broadband Account Number';
      default:
        return 'Enter 10-digit Consumer Number';
    }
  }

  String get billerSelectorTitle {
    switch (selectedCategory.value) {
      case 'mobile_postpaid':
        return 'Select Postpaid Operator';
      case 'loan_emi':
      case 'emi':
        return 'Select Loan Provider / Bank';
      case 'insurance_premium':
        return 'Select Insurance Company';
      case 'gas_cylinder':
        return 'Select Gas Cylinder Provider';
      case 'subscription':
        return 'Select Subscription Service';
      case 'rental':
        return 'Select Rent Category';
      case 'municipal_tax':
        return 'Select Municipal Corporation';
      case 'education':
        return 'Select Institution / School';
      case 'hospital':
        return 'Select Hospital / Healthcare';
      case 'cable_tv':
        return 'Select Cable TV Operator';
      case 'water':
        return 'Select Water Board';
      case 'gas':
        return 'Select Piped Gas Supplier';
      case 'broadband':
        return 'Select Broadband Provider';
      default:
        return 'Select Electricity Board / Biller';
    }
  }

  Future<void> fetchBill() async {
    final consumerNum = consumerNumberController.text.trim();
    if (consumerNum.isEmpty) {
      Get.snackbar('Validation', 'Please enter $consumerFieldLabel', backgroundColor: Colors.orange.shade100);
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
