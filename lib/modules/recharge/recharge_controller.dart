import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/utils/validators.dart';
import '../../data/models/operator_model.dart';
import '../../data/models/recharge_plan_model.dart';
import '../../data/mock/mock_recharge_data.dart';
import '../../data/repositories/recharge_repository.dart';
import '../../shared/widgets/payment_success_view.dart';
import '../../shared/widgets/confirm_bottom_sheet.dart';

class RechargeController extends GetxController with GetSingleTickerProviderStateMixin {
  final RechargeRepository _repo = Get.find<RechargeRepository>();

  late TabController tabController;
  final RxInt selectedTab = 0.obs; // 0 = Mobile, 1 = DTH

  // Mobile Recharge States
  final mobileController = TextEditingController(text: '9876543210');
  final Rx<OperatorModel> selectedMobileOperator = MockRechargeData.mobileOperators.first.obs;
  final RxString selectedCircle = 'Delhi NCR'.obs;
  final RxList<RechargePlanModel> allPlans = <RechargePlanModel>[].obs;
  final RxString selectedCategory = 'Recommended'.obs;
  final RxBool isLoadingPlans = false.obs;

  // DTH Recharge States
  final dthSubscriberController = TextEditingController();
  final dthAmountController = TextEditingController(text: '350');
  final Rx<OperatorModel> selectedDthOperator = MockRechargeData.dthOperators.first.obs;

  // Payment states
  final RxBool isProcessingPayment = false.obs;
  final RxString selectedPaymentMode = 'FlamePay Wallet'.obs;

  final List<String> categories = [
    'Recommended',
    'Popular',
    'Truly Unlimited',
    'Data Only',
    'Annual',
  ];

  @override
  void onInit() {
    super.onInit();
    tabController = TabController(length: 2, vsync: this);
    tabController.addListener(() {
      selectedTab.value = tabController.index;
    });

    final args = Get.arguments;
    if (args is Map && args['isDth'] == true) {
      tabController.index = 1;
      selectedTab.value = 1;
    }

    mobileController.addListener(_onMobileChanged);
    if (mobileController.text.length == 10) {
      autoDetectOperator(mobileController.text);
    } else {
      fetchPlans();
    }
  }

  
  String _lastCheckedMobile = '';
  void _onMobileChanged() {
    final text = mobileController.text.trim();
    if (text.length == 10 && text != _lastCheckedMobile) {
      _lastCheckedMobile = text;
      autoDetectOperator(text);
    }
  }

  Future<void> autoDetectOperator(String phone) async {
    final clean = phone.replaceAll(RegExp(r'[^0-9]'), '');
    if (clean.length == 10) {
      try {
        final res = await _repo.checkOperator(clean);
        if (res.success && res.data != null) {
          final opName = (res.data!['operator'] as String? ?? '').toLowerCase();
          final cirName = (res.data!['circle'] as String? ?? '');

          // Auto-match Operator
          for (final op in MockRechargeData.mobileOperators) {
            if (opName.contains(op.id.toLowerCase()) || op.name.toLowerCase().contains(opName) || op.id.toLowerCase().contains(opName)) {
              selectedMobileOperator.value = op;
              break;
            }
          }

          // Auto-match Circle
          if (cirName.isNotEmpty) {
            selectedCircle.value = cirName;
          }

          fetchPlans();
          return;
        }
      } catch (_) {}
    }
    fetchPlans();
  }

  Future<void> fetchPlans() async {
    isLoadingPlans.value = true;
    try {
      final res = await _repo.getPlans(
        selectedMobileOperator.value.id,
        selectedCircle.value,
      );
      if (res.success && res.data != null) {
        allPlans.assignAll(res.data!);
      }
    } catch (_) {
      allPlans.assignAll(MockRechargeData.jioPlans);
    } finally {
      isLoadingPlans.value = false;
    }
  }

  List<RechargePlanModel> get filteredPlans {
    final cat = selectedCategory.value.toLowerCase();
    final list = allPlans.where((p) {
      final pCat = p.category.toLowerCase();
      if (cat == 'recommended') {
        return pCat.contains('recommended') || p.isPopular;
      }
      if (cat == 'popular') {
        return pCat.contains('popular');
      }
      if (cat.contains('unlimited')) {
        return pCat.contains('unlimited') || p.description.toLowerCase().contains('unlimited');
      }
      if (cat.contains('data')) {
        return pCat.contains('data');
      }
      if (cat.contains('annual')) {
        return pCat.contains('annual') || p.validity.contains('365') || p.validity.contains('336');
      }
      return pCat == cat;
    }).toList();

    return list.isNotEmpty ? list : allPlans;
  }

  
  void onSelectOperator(OperatorModel op) {
    if (selectedTab.value == 0) {
      selectedMobileOperator.value = op;
      fetchPlans();
    } else {
      selectedDthOperator.value = op;
    }
  }

  void onSelectCircle(String circle) {
    selectedCircle.value = circle;
    fetchPlans();
  }

  void onSelectPlan(RechargePlanModel plan) {
    final phone = mobileController.text.trim();
    final phoneErr = Validators.validateMobile(phone);
    if (phoneErr != null) {
      Get.snackbar('Validation', phoneErr, backgroundColor: Colors.orange.shade100);
      return;
    }

    Get.bottomSheet(
      ConfirmBottomSheet(
        title: 'Confirm Recharge',
        amount: plan.amount,
        walletBalance: 2580.0,
        details: {
          'Mobile Number': '+91 $phone',
          'Operator': selectedMobileOperator.value.name,
          'Circle': selectedCircle.value,
          'Validity': plan.validity,
          'Data': plan.data,
          'Voice': plan.talktime,
          'Payment Mode': selectedPaymentMode.value,
        },
        onConfirm: () {
          Get.back();
          _executeRecharge(plan);
        },
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  Future<void> _executeRecharge(RechargePlanModel plan) async {
    isProcessingPayment.value = true;
    try {
      final res = await _repo.processRecharge(
        mobileNumber: mobileController.text.trim(),
        operatorId: selectedMobileOperator.value.name,
        circle: selectedCircle.value,
        amount: plan.amount,
        planId: plan.id,
        paymentMode: selectedPaymentMode.value,
      );

      if (res.success && res.data != null) {
        Get.off(() => PaymentSuccessView(result: res.data!));
      } else {
        if (res.message.toLowerCase().contains('insufficient') || res.message.toLowerCase().contains('recharge your wallet')) {
          Get.defaultDialog(
            title: 'Low Wallet Balance',
            titleStyle: const TextStyle(fontWeight: FontWeight.bold, color: Colors.orange),
            content: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  const Icon(Icons.account_balance_wallet_outlined, size: 48, color: Colors.orange),
                  const SizedBox(height: 12),
                  Text(res.message, textAlign: TextAlign.center, style: const TextStyle(fontSize: 14)),
                ],
              ),
            ),
            textConfirm: 'Add Money to Wallet',
            confirmTextColor: Colors.white,
            buttonColor: const Color(0xFFF97316),
            onConfirm: () {
              Get.back();
              Get.toNamed('/wallet');
            },
            textCancel: 'Cancel',
          );
        } else {
          Get.snackbar('Error', res.message, backgroundColor: Colors.red.shade100);
        }
      }
    } catch (e) {
      Get.snackbar('Error', e.toString(), backgroundColor: Colors.red.shade100);
    } finally {
      isProcessingPayment.value = false;
    }
  }

  Future<void> payDth() async {
    final subId = dthSubscriberController.text.trim();
    if (subId.isEmpty) {
      Get.snackbar('Validation', 'Please enter Subscriber ID / Smart Card Number', backgroundColor: Colors.orange.shade100);
      return;
    }
    final amt = double.tryParse(dthAmountController.text.trim()) ?? 0.0;
    if (amt <= 0) {
      Get.snackbar('Validation', 'Please enter valid recharge amount', backgroundColor: Colors.orange.shade100);
      return;
    }

    isProcessingPayment.value = true;
    try {
      final res = await _repo.processRecharge(
        mobileNumber: subId,
        operatorId: selectedDthOperator.value.name,
        circle: 'All India',
        amount: amt,
        planId: 'dth_custom',
        paymentMode: selectedPaymentMode.value,
      );

      if (res.success && res.data != null) {
        Get.off(() => PaymentSuccessView(result: res.data!));
      } else {
        Get.snackbar('Error', res.message, backgroundColor: Colors.red.shade100);
      }
    } catch (e) {
      Get.snackbar('Error', e.toString(), backgroundColor: Colors.red.shade100);
    } finally {
      isProcessingPayment.value = false;
    }
  }

  @override
  void onClose() {
    mobileController.removeListener(_onMobileChanged);
    tabController.dispose();
    mobileController.dispose();
    dthSubscriberController.dispose();
    dthAmountController.dispose();
    super.onClose();
  }
}
