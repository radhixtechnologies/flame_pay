import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/utils/validators.dart';
import '../../data/repositories/wallet_repository.dart';
import '../../data/models/transaction_model.dart';
import '../../shared/widgets/state_view.dart';
import '../home/home_controller.dart';

class WalletController extends GetxController {
  final WalletRepository _repo = Get.find<WalletRepository>();

  final Rx<ViewState> viewState = ViewState.loading.obs;
  final RxDouble balance = 2580.00.obs;
  final RxDouble monthlyLimit = 50000.00.obs;
  final RxDouble spentThisMonth = 4280.00.obs;

  final RxList<TransactionModel> transactions = <TransactionModel>[].obs;

  // Add Money Form
  final addAmountController = TextEditingController(text: '500');
  final utrController = TextEditingController();
  final RxMap<String, dynamic> bankDetails = <String, dynamic>{}.obs;
  final RxInt selectedQuickAmount = 500.obs;
  final RxString selectedPaymentMethod = 'UPI (Google Pay / PhonePe)'.obs;
  final RxBool isAddingMoney = false.obs;

  final List<int> quickAmounts = const [100, 500, 1000, 2000];
  final List<String> paymentMethods = const [
    'UPI (Google Pay / PhonePe)',
    'Debit / Credit Card',
    'Net Banking',
  ];

  @override
  void onInit() {
    super.onInit();
    fetchWalletData();
    fetchBankDetails();
  }

  Future<void> fetchWalletData() async {
    viewState.value = ViewState.loading;
    try {
      final res = await _repo.getWalletDetails();
      if (res.success && res.data != null) {
        balance.value = res.data!.balance;
        monthlyLimit.value = res.data!.monthlyLimit;
        spentThisMonth.value = res.data!.spentThisMonth;
      }

      final txnRes = await _repo.getWalletTransactions();
      if (txnRes.success && txnRes.data != null) {
        transactions.assignAll(txnRes.data!);
      }

      viewState.value = transactions.isEmpty ? ViewState.empty : ViewState.success;
    } catch (_) {
      viewState.value = ViewState.success;
    }
  }

  void selectQuickAmount(int amount) {
    selectedQuickAmount.value = amount;
    addAmountController.text = amount.toString();
  }

  Future<void> addMoney() async {
    final amtText = addAmountController.text.trim();
    final validationError = Validators.validateAmount(amtText, min: 10, max: 50000);
    if (validationError != null) {
      Get.snackbar('Validation', validationError, backgroundColor: Colors.orange.shade100);
      return;
    }

    final amt = double.parse(amtText);
    isAddingMoney.value = true;
    try {
      final res = await _repo.addMoney(
        amount: amt,
        paymentMethod: selectedPaymentMethod.value,
      );

      if (res.success) {
        balance.value += amt;
        // Update home dashboard balance too
        if (Get.isRegistered<HomeController>()) {
          Get.find<HomeController>().walletBalance.value = balance.value;
        }

        // Add new top-up record
        transactions.insert(
          0,
          TransactionModel(
            id: 'TXN${DateTime.now().millisecondsSinceEpoch}',
            title: 'Wallet Top-up',
            subtitle: '${selectedPaymentMethod.value} • Just now',
            amount: amt,
            timestamp: DateTime.now(),
            status: 'success',
            category: 'wallet',
          ),
        );

        Get.back();
        Get.snackbar(
          'Money Added!',
          '₹${amt.toStringAsFixed(0)} added to your FlamePay Wallet.',
          backgroundColor: Colors.green.shade100,
          duration: const Duration(seconds: 3),
        );
      } else {
        Get.snackbar('Error', res.message, backgroundColor: Colors.red.shade100);
      }
    } catch (e) {
      Get.snackbar('Error', e.toString(), backgroundColor: Colors.red.shade100);
    } finally {
      isAddingMoney.value = false;
    }
  }

  @override
  void onClose() {
    addAmountController.dispose();
    super.onClose();
  }

  Future<void> fetchBankDetails() async {
    try {
      final res = await _repo.getBankDetails();
      if (res.success && res.data != null) {
        bankDetails.assignAll(res.data!);
      }
    } catch (_) {}
  }

  Future<void> submitTopupRequest() async {
    final amtText = addAmountController.text.trim();
    final validationError = Validators.validateAmount(amtText, min: 10, max: 50000);
    if (validationError != null) {
      Get.snackbar('Validation', validationError, backgroundColor: Colors.orange.shade100);
      return;
    }

    final utr = utrController.text.trim();
    if (utr.isEmpty || utr.length < 8) {
      Get.snackbar('Validation', 'Please enter valid 12-digit UTR / Reference number after payment', backgroundColor: Colors.orange.shade100);
      return;
    }

    final amt = double.parse(amtText);
    isAddingMoney.value = true;
    try {
      final res = await _repo.requestTopup(
        amount: amt,
        utrNumber: utr,
        paymentMethod: selectedPaymentMethod.value,
      );

      if (res.success) {
        utrController.clear();
        Get.defaultDialog(
          title: 'Deposit Request Submitted',
          titleStyle: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
          content: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                const Icon(Icons.check_circle_outline, color: Colors.green, size: 54),
                const SizedBox(height: 12),
                Text(
                  'Deposit of ₹${amt.toStringAsFixed(0)} is submitted for Admin verification.\n\nOnce verified in SBI account (32823806111), your wallet will be credited.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
          textConfirm: 'OK',
          confirmTextColor: Colors.white,
          buttonColor: Colors.green,
          onConfirm: () {
            Get.back();
            fetchWalletData();
          },
        );
      } else {
        Get.snackbar('Error', res.message, backgroundColor: Colors.red.shade100);
      }
    } catch (e) {
      Get.snackbar('Error', e.toString(), backgroundColor: Colors.red.shade100);
    } finally {
      isAddingMoney.value = false;
    }
  }
}
