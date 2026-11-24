import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_cashfree_pg_sdk/api/cferrorresponse/cferrorresponse.dart';
import 'package:flutter_cashfree_pg_sdk/api/cfpayment/cfwebcheckoutpayment.dart';
import 'package:flutter_cashfree_pg_sdk/api/cfpaymentgateway/cfpaymentgatewayservice.dart';
import 'package:flutter_cashfree_pg_sdk/api/cfsession/cfsession.dart';
import 'package:flutter_cashfree_pg_sdk/utils/cfenums.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/validators.dart';
import '../../data/models/operator_model.dart';
import '../../data/models/recharge_plan_model.dart';
import '../../data/mock/mock_recharge_data.dart';
import '../../data/repositories/recharge_repository.dart';
import '../../shared/widgets/payment_success_view.dart';
import '../../shared/widgets/confirm_bottom_sheet.dart';
import '../home/home_controller.dart';

class RechargeController extends GetxController with GetSingleTickerProviderStateMixin {
  final RechargeRepository _repo = Get.find<RechargeRepository>();

  late TabController tabController;
  final RxInt selectedTab = 0.obs; // 0 = Mobile, 1 = DTH

  // Mobile Recharge States
  final mobileController = TextEditingController();
  final Rx<OperatorModel> selectedMobileOperator = MockRechargeData.mobileOperators.first.obs;
  final RxString selectedCircle = 'Delhi NCR'.obs;
  final RxList<RechargePlanModel> allPlans = <RechargePlanModel>[].obs;
  final RxString selectedCategory = 'Recommended'.obs;
  final RxBool isLoadingPlans = false.obs;

  // DTH Recharge States
  final dthSubscriberController = TextEditingController();
  final dthAmountController = TextEditingController();
  final Rx<OperatorModel> selectedDthOperator = MockRechargeData.dthOperators.first.obs;
  final RxBool isCheckingDthOperator = false.obs;
  final RxBool isFetchingDthInfo = false.obs;
  final Rxn<Map<String, dynamic>> dthAdvanceInfo = Rxn<Map<String, dynamic>>();
  final RxString detectedDthOperatorLabel = ''.obs;
  String _lastCheckedDth = '';

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
    dthSubscriberController.addListener(_onDthSubscriberChanged);
    if (mobileController.text.length == 10) {
      autoDetectOperator(mobileController.text);
    }
  }

  void _onDthSubscriberChanged() {
    final text = dthSubscriberController.text.trim();
    if (text != _lastCheckedDth) {
      dthAdvanceInfo.value = null;
      detectedDthOperatorLabel.value = '';
    }
    if (text.length >= 10 && text != _lastCheckedDth) {
      _lastCheckedDth = text;
      checkDthOperatorNow(silent: true);
    } else if (text.length < 10) {
      _lastCheckedDth = '';
    }
  }

  void _matchDthOperator(String rawOp, {String? displayName}) {
    final opLow = rawOp.toLowerCase().trim();
    final nameHint = (displayName ?? '').trim();
    if (opLow.isEmpty && nameHint.isEmpty) return;

    final combined = '$opLow ${nameHint.toLowerCase()}';
    for (final op in MockRechargeData.dthOperators) {
      final idLow = op.id.toLowerCase();
      final nameLow = op.name.toLowerCase();
      if (combined.contains(idLow) ||
          (opLow.isNotEmpty && nameLow.contains(opLow)) ||
          (combined.contains('tata') && idLow.contains('tata')) ||
          (combined.contains('sky') && idLow.contains('tata')) ||
          (combined.contains('airtel') && idLow.contains('airtel')) ||
          (combined.contains('dish') && idLow.contains('dish')) ||
          (combined.contains('sun') && idLow.contains('sun')) ||
          ((combined.contains('d2h') || combined.contains('videocon')) && idLow.contains('d2h'))) {
        selectedDthOperator.value = op;
        detectedDthOperatorLabel.value = nameHint.isNotEmpty ? nameHint : op.name;
        selectedDthOperator.refresh();
        return;
      }
    }
    detectedDthOperatorLabel.value = nameHint.isNotEmpty ? nameHint : rawOp;
  }

  Map<String, dynamic> _unwrapResult(Map<String, dynamic> rawData) {
    final inner = rawData['result'];
    if (inner is Map) {
      return Map<String, dynamic>.from(inner);
    }
    if (inner is List && inner.isNotEmpty && inner.first is Map) {
      return Map<String, dynamic>.from(inner.first as Map);
    }
    return rawData;
  }

  // Live DTH Operator Check (POST /api/v1/dth/operator-check)
  Future<bool> checkDthOperatorNow({bool silent = false}) async {
    final subId = dthSubscriberController.text.trim();
    if (subId.length < 6) {
      if (!silent) {
        Get.snackbar(
          'Subscriber ID Required',
          'Please enter a valid DTH Subscriber ID / Smart Card Number',
          backgroundColor: Colors.orange.shade100,
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(16),
        );
      }
      return false;
    }

    isCheckingDthOperator.value = true;
    try {
      final res = await _repo.checkDthOperator(subId);
      if (res.success && res.data != null) {
        final rawData = res.data!;
        final inner = _unwrapResult(rawData);
        final rawOp = (inner['operator'] ??
                inner['operatorCode'] ??
                inner['operator_code'] ??
                rawData['operator'] ??
                rawData['operatorCode'] ??
                '')
            .toString()
            .trim();
        final rawOpName = (inner['operator_name'] ??
                inner['operatorName'] ??
                rawData['operator_name'] ??
                rawData['operatorName'] ??
                rawOp)
            .toString()
            .trim();

        if (rawOp.isNotEmpty || rawOpName.isNotEmpty) {
          _matchDthOperator(rawOp, displayName: rawOpName);
          _lastCheckedDth = subId;
          // Immediately fetch DTH Advance Customer Info so screen updates automatically
          fetchDthAdvanceInfo(silentError: true);
          return true;
        }
      }
      if (!silent) {
        Get.snackbar(
          'Operator Not Found',
          res.message.isNotEmpty ? res.message : 'Could not detect DTH operator for $subId',
          backgroundColor: Colors.red.shade100,
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(16),
        );
      }
      return false;
    } finally {
      isCheckingDthOperator.value = false;
    }
  }

  // Live DTH Advance Information (POST /api/v1/dth/info)
  Future<void> fetchDthAdvanceInfo({bool silentError = false}) async {
    final subId = dthSubscriberController.text.trim();
    if (subId.length < 6) {
      if (!silentError) {
        Get.snackbar(
          'Subscriber ID Required',
          'Please enter a valid DTH Subscriber ID / Smart Card Number first',
          backgroundColor: Colors.orange.shade100,
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(16),
        );
      }
      return;
    }

    isFetchingDthInfo.value = true;
    try {
      // Auto-detect operator first if not yet checked for this subscriber ID
      if (detectedDthOperatorLabel.value.isEmpty && !isCheckingDthOperator.value) {
        final opRes = await _repo.checkDthOperator(subId);
        if (opRes.success && opRes.data != null) {
          final inner = _unwrapResult(opRes.data!);
          final rawOp = (inner['operator'] ?? inner['operatorCode'] ?? opRes.data!['operator'] ?? '').toString().trim();
          final rawOpName = (inner['operator_name'] ?? inner['operatorName'] ?? opRes.data!['operator_name'] ?? rawOp).toString().trim();
          if (rawOp.isNotEmpty || rawOpName.isNotEmpty) {
            _matchDthOperator(rawOp, displayName: rawOpName);
            _lastCheckedDth = subId;
          }
        }
      }

      final res = await _repo.getDthAdvanceInfo(
        subId,
        operator: selectedDthOperator.value.id,
      );

      if (res.success && res.data != null) {
        final rawData = res.data!;
        final rec = _unwrapResult(rawData);
        final normalized = <String, dynamic>{
          'customerName': (rawData['customerName'] ?? rec['customer_name'] ?? rec['customerName'] ?? rec['name'] ?? rec['CustomerName'] ?? '').toString().trim(),
          'balance': (rawData['balance'] ?? rec['balance'] ?? rec['account_balance'] ?? rec['Balance'] ?? rec['bal'] ?? '').toString().trim(),
          'monthlyRecharge': (rawData['monthlyRecharge'] ?? rec['monthly_recharge'] ?? rec['monthlyRecharge'] ?? rec['MonthlyRecharge'] ?? rec['monthly_pack'] ?? rec['recommended_amount'] ?? '').toString().trim(),
          'nextRechargeDate': (rawData['nextRechargeDate'] ?? rec['next_recharge_date'] ?? rec['nextRechargeDate'] ?? rec['NextRechargeDate'] ?? rec['expiry_date'] ?? rec['due_date'] ?? '').toString().trim(),
          'lastRechargeAmount': (rawData['lastRechargeAmount'] ?? rec['last_recharge_amount'] ?? rec['lastRechargeAmount'] ?? rec['LastRechargeAmount'] ?? '').toString().trim(),
          'lastRechargeDate': (rawData['lastRechargeDate'] ?? rec['last_recharge_date'] ?? rec['lastRechargeDate'] ?? rec['LastRechargeDate'] ?? '').toString().trim(),
          'planName': (rawData['planName'] ?? rec['plan_name'] ?? rec['planName'] ?? rec['planname'] ?? rec['active_plan'] ?? rec['package_name'] ?? '').toString().trim(),
          'status': (rawData['status'] ?? rec['status'] ?? rec['Status'] ?? rec['account_status'] ?? 'Active').toString().trim(),
          'rmn': (rawData['rmn'] ?? rec['rmn'] ?? rec['RMN'] ?? rec['registered_mobile'] ?? rec['mobile'] ?? '').toString().trim(),
          'operator': (rawData['operator'] ?? rec['operator'] ?? selectedDthOperator.value.name).toString().trim(),
        };

        dthAdvanceInfo.value = normalized;
        final monthly = normalized['monthlyRecharge'].toString().replaceAll(RegExp(r'[^0-9.]'), '');
        if (monthly.isNotEmpty && dthAmountController.text.trim().isEmpty) {
          final parsed = double.tryParse(monthly);
          if (parsed != null && parsed > 0) {
            dthAmountController.text = parsed.toStringAsFixed(0);
          }
        }
      } else {
        dthAdvanceInfo.value = null;
        if (!silentError) {
          Get.snackbar(
            'DTH Info Unavailable',
            res.message.isNotEmpty ? res.message : 'Could not fetch DTH customer info. Verify Subscriber ID & Operator.',
            backgroundColor: Colors.red.shade100,
            snackPosition: SnackPosition.BOTTOM,
            margin: const EdgeInsets.all(16),
            duration: const Duration(seconds: 4),
          );
        }
      }
    } finally {
      isFetchingDthInfo.value = false;
    }
  }

  
  String _lastCheckedMobile = '';
  void _onMobileChanged() {
    final text = mobileController.text.trim();
    if (text.length == 10 && text != _lastCheckedMobile) {
      _lastCheckedMobile = text;
      autoDetectOperator(text);
    } else if (text.length < 10) {
      allPlans.clear();
      _lastCheckedMobile = '';
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
      fetchPlans();
    }
  }

  Future<void> fetchPlans() async {
    final phone = mobileController.text.trim();
    if (phone.length < 10) {
      allPlans.clear();
      isLoadingPlans.value = false;
      return;
    }
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

  double get currentWalletBalance {
    if (Get.isRegistered<HomeController>()) {
      return Get.find<HomeController>().walletBalance.value;
    }
    return 0.0;
  }

  void onSelectPlan(RechargePlanModel plan) {
    final phone = mobileController.text.trim();
    final phoneErr = Validators.validateMobile(phone);
    if (phoneErr != null) {
      Get.snackbar('Validation', phoneErr, backgroundColor: Colors.orange.shade100);
      return;
    }

    final walletBal = currentWalletBalance;

    Get.bottomSheet(
      ConfirmBottomSheet(
        title: 'Confirm Mobile Recharge',
        amount: plan.amount,
        walletBalance: walletBal,
        details: {
          'Mobile Number': '+91 $phone',
          'Operator': selectedMobileOperator.value.name,
          'Circle': selectedCircle.value,
          'Validity': plan.validity,
          'Data': plan.data,
          'Voice': plan.talktime,
        },
        onConfirmPayment: (mode) {
          Get.back();
          selectedPaymentMode.value = mode;
          if (mode == 'Cashfree UPI') {
            _executeCashfreeRecharge(
              amount: plan.amount,
              mobile: phone,
              operator: selectedMobileOperator.value.name,
              circle: selectedCircle.value,
              planId: plan.id,
              serviceType: 'Mobile Recharge',
            );
          } else {
            _executeRecharge(plan);
          }
        },
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  Future<void> _executeCashfreeRecharge({
    required double amount,
    required String mobile,
    required String operator,
    required String circle,
    required String planId,
    required String serviceType,
  }) async {
    isProcessingPayment.value = true;
    try {
      // 1. Create Cashfree Order strictly restricted to UPI
      final orderRes = await _repo.createCashfreeOrder(
        amount: amount,
        mobile: mobile,
        operator: operator,
        circle: circle,
        planId: planId,
        serviceType: serviceType,
        purpose: 'recharge',
      );

      if (!orderRes.success || orderRes.data == null) {
        Get.snackbar(
          'Payment Initiation Failed',
          orderRes.message.isNotEmpty ? orderRes.message : 'Could not initiate Cashfree UPI payment',
          backgroundColor: Colors.red.shade100,
        );
        return;
      }

      final orderData = orderRes.data!;
      final orderId = (orderData['orderId'] ?? '').toString();
      final paymentSessionId = (orderData['paymentSessionId'] ?? '').toString();
      final checkoutUrl = (orderData['checkoutUrl'] ?? '').toString();
      final envString = (orderData['environment'] ?? 'PROD').toString().toUpperCase();

      if (orderId.isEmpty || paymentSessionId.isEmpty) {
        Get.snackbar('Error', 'Invalid Cashfree order generated', backgroundColor: Colors.red.shade100);
        return;
      }

      // If order is simulated, avoid passing invalid token to native SDK
      if (paymentSessionId.startsWith('session_sim_')) {
        final shouldSimulatePay = await Get.defaultDialog<bool>(
          title: 'Cashfree Test Mode',
          titleStyle: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryBlue),
          content: Padding(
            padding: const EdgeInsets.all(12),
            child: Text(
              'Simulate successful payment of ₹${amount.toStringAsFixed(2)} to test recharge flow?',
              textAlign: TextAlign.center,
            ),
          ),
          textConfirm: 'Confirm Test Payment',
          confirmTextColor: Colors.white,
          buttonColor: const Color(0xFFF97316),
          onConfirm: () => Get.back(result: true),
          textCancel: 'Cancel',
          onCancel: () => Get.back(result: false),
        );
        if (shouldSimulatePay == true) {
          _verifyPaymentAndExecuteRecharge(
            orderId: orderId,
            amount: amount,
            mobile: mobile,
            operator: operator,
            circle: circle,
            planId: planId,
            serviceType: serviceType,
          );
        }
        return;
      }

      // 2. Open Cashfree's Official Default Checkout Sheet
      final cfGateway = CFPaymentGatewayService();
      cfGateway.setCallback(
        (String verifiedOrderId) {
          // Cashfree Sheet completed successfully -> verify and execute recharge!
          _verifyPaymentAndExecuteRecharge(
            orderId: verifiedOrderId.isNotEmpty ? verifiedOrderId : orderId,
            amount: amount,
            mobile: mobile,
            operator: operator,
            circle: circle,
            planId: planId,
            serviceType: serviceType,
          );
        },
        (CFErrorResponse error, String failedOrderId) {
          final code = error.getCode() ?? '';
          final msg = error.getMessage() ?? '';
          debugPrint('[Cashfree SDK Error]: code=$code, msg=$msg');

          if (code == 'installer_package_not_approved' || msg.contains('not a trusted source') || code.contains('installer')) {
            // Sideloaded / Debug APK in production mode:
            // Seamlessly open Cashfree's official Web Checkout sheet so payment proceeds smoothly!
            _openWebCheckout(
              checkoutUrl: checkoutUrl,
              orderId: orderId,
              amount: amount,
              mobile: mobile,
              operator: operator,
              circle: circle,
              planId: planId,
              serviceType: serviceType,
            );
          } else {
            Get.snackbar(
              'Payment Notice',
              msg.isNotEmpty ? msg : 'Payment was cancelled.',
              backgroundColor: Colors.orange.shade100,
            );
          }
        },
      );

      try {
        final cfSession = CFSessionBuilder()
            .setEnvironment(envString == 'PROD' ? CFEnvironment.PRODUCTION : CFEnvironment.SANDBOX)
            .setOrderId(orderId)
            .setPaymentSessionId(paymentSessionId)
            .build();

        final cfPayment = CFWebCheckoutPaymentBuilder()
            .setSession(cfSession)
            .build();

        cfGateway.doPayment(cfPayment);
      } catch (sdkError) {
        // Fallback: If SDK throws or is unsupported, open Cashfree checkout sheet in In-App Browser View
        await _openWebCheckout(
          checkoutUrl: checkoutUrl,
          orderId: orderId,
          amount: amount,
          mobile: mobile,
          operator: operator,
          circle: circle,
          planId: planId,
          serviceType: serviceType,
        );
      }
    } catch (e) {
      Get.snackbar('Error', e.toString(), backgroundColor: Colors.red.shade100);
    } finally {
      isProcessingPayment.value = false;
    }
  }

  Future<void> _openWebCheckout({
    required String checkoutUrl,
    required String orderId,
    required double amount,
    required String mobile,
    required String operator,
    required String circle,
    required String planId,
    required String serviceType,
  }) async {
    if (checkoutUrl.isEmpty) {
      Get.snackbar('Error', 'Unable to open checkout URL.', backgroundColor: Colors.red.shade100);
      return;
    }
    try {
      final uri = Uri.parse(checkoutUrl);
      bool launched = false;
      try {
        launched = await launchUrl(uri, mode: LaunchMode.inAppBrowserView);
      } catch (_) {}
      if (!launched) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }

      final confirmed = await Get.defaultDialog<bool>(
        title: 'Payment Completed?',
        content: const Padding(
          padding: EdgeInsets.all(12),
          child: Text(
            'Did you complete the payment in the Cashfree checkout window?',
            textAlign: TextAlign.center,
          ),
        ),
        textConfirm: 'Yes, Confirm Recharge',
        confirmTextColor: Colors.white,
        buttonColor: Colors.green,
        onConfirm: () => Get.back(result: true),
        textCancel: 'Cancel',
        onCancel: () => Get.back(result: false),
      );

      if (confirmed == true) {
        _verifyPaymentAndExecuteRecharge(
          orderId: orderId,
          amount: amount,
          mobile: mobile,
          operator: operator,
          circle: circle,
          planId: planId,
          serviceType: serviceType,
        );
      }
    } catch (e) {
      debugPrint('[Cashfree Web Checkout Error]: $e');
    }
  }

  void _verifyPaymentAndExecuteRecharge({
    required String orderId,
    required double amount,
    required String mobile,
    required String operator,
    required String circle,
    required String planId,
    required String serviceType,
  }) {
    Get.showOverlay(
      asyncFunction: () async {
        try {
          final verifyRes = await _repo.verifyAndRechargeCashfree(
            orderId: orderId,
            amount: amount,
            mobile: mobile,
            operator: operator,
            circle: circle,
            planId: planId,
            serviceType: serviceType,
          );

          if (verifyRes.success && verifyRes.data != null) {
            if (Get.isRegistered<HomeController>()) {
              Get.find<HomeController>().fetchDashboardData();
            }
            Get.off(() => PaymentSuccessView(result: verifyRes.data!));
          } else {
            Get.snackbar(
              'Payment Status',
              verifyRes.message.isNotEmpty ? verifyRes.message : 'Recharge verification pending.',
              backgroundColor: Colors.orange.shade100,
              duration: const Duration(seconds: 4),
            );
          }
        } catch (e) {
          final errStr = e.toString().replaceAll('Exception: ', '');
          Get.snackbar(
            'Payment Notice',
            errStr.contains('not completed')
                ? 'Payment is not completed yet. Please complete the payment on Cashfree.'
                : errStr,
            backgroundColor: Colors.orange.shade100,
            duration: const Duration(seconds: 4),
          );
        }
      },
      loadingWidget: const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Verifying Cashfree UPI Payment...', style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 6),
                Text('Activating live recharge with operator...', style: TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
        ),
      ),
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
        if (Get.isRegistered<HomeController>()) {
          Get.find<HomeController>().fetchDashboardData();
        }
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
            textConfirm: 'Pay via UPI',
            confirmTextColor: Colors.white,
            buttonColor: const Color(0xFFF97316),
            onConfirm: () {
              Get.back();
              _executeCashfreeRecharge(
                amount: plan.amount,
                mobile: mobileController.text.trim(),
                operator: selectedMobileOperator.value.name,
                circle: selectedCircle.value,
                planId: plan.id,
                serviceType: 'Mobile Recharge',
              );
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

    final walletBal = currentWalletBalance;

    Get.bottomSheet(
      ConfirmBottomSheet(
        title: 'Confirm DTH Recharge',
        amount: amt,
        walletBalance: walletBal,
        details: {
          'Subscriber ID': subId,
          'Operator': selectedDthOperator.value.name,
          'Circle': 'All India',
        },
        onConfirmPayment: (mode) {
          Get.back();
          selectedPaymentMode.value = mode;
          if (mode == 'Cashfree UPI') {
            _executeCashfreeRecharge(
              amount: amt,
              mobile: subId,
              operator: selectedDthOperator.value.name,
              circle: 'All India',
              planId: 'dth_custom',
              serviceType: 'DTH Recharge',
            );
          } else {
            _executeDthDirectRecharge(subId, amt);
          }
        },
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  Future<void> _executeDthDirectRecharge(String subId, double amt) async {
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
        if (Get.isRegistered<HomeController>()) {
          Get.find<HomeController>().fetchDashboardData();
        }
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
