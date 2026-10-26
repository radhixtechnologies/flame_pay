import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/utils/validators.dart';
import '../../../data/models/payment_result_model.dart';
import '../../../data/repositories/wallet_repository.dart';
import '../../home/home_controller.dart';
import '../wallet_controller.dart';
import '../../../shared/widgets/payment_success_view.dart';

class SendMoneyController extends GetxController {
  final WalletRepository _repo = Get.find<WalletRepository>();
  final AuthService _auth = Get.find<AuthService>();

  final recipientController = TextEditingController();
  final amountController = TextEditingController();
  final noteController = TextEditingController();

  final RxString selectedTransferType = 'Mobile Number'.obs; // 'Mobile Number' or 'UPI ID'
  final RxBool isSending = false.obs;

  final List<String> transferTypes = const ['Mobile Number', 'UPI ID'];

  // Recent contacts for instant selection
  final List<Map<String, String>> recentContacts = const [
    {'name': 'Pooja Verma', 'phone': '9876543211', 'upi': 'pooja@okhdfc'},
    {'name': 'Amit Sharma', 'phone': '9123456780', 'upi': 'amit@paytm'},
    {'name': 'Vikram Singh', 'phone': '9988776655', 'upi': 'vikram@icici'},
    {'name': 'Sneha Patel', 'phone': '9811223344', 'upi': 'sneha@oksbi'},
  ];

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is Map) {
      if (args['recipient'] != null) {
        recipientController.text = args['recipient'].toString();
      }
      if (args['amount'] != null) {
        amountController.text = args['amount'].toString();
      }
    }
  }

  void selectContact(Map<String, String> contact) {
    if (selectedTransferType.value == 'Mobile Number') {
      recipientController.text = contact['phone'] ?? '';
    } else {
      recipientController.text = contact['upi'] ?? '';
    }
  }

  Future<void> sendMoney() async {
    final recipient = recipientController.text.trim();
    if (recipient.isEmpty) {
      Get.snackbar(
        'Validation',
        selectedTransferType.value == 'Mobile Number'
            ? 'Please enter recipient 10-digit mobile number'
            : 'Please enter valid UPI ID (e.g. name@upi)',
        backgroundColor: Colors.orange.shade100,
      );
      return;
    }

    if (selectedTransferType.value == 'Mobile Number') {
      final clean = recipient.replaceAll(RegExp(r'\s+'), '');
      if (!RegExp(r'^[6-9]\d{9}$').hasMatch(clean)) {
        Get.snackbar('Validation', 'Enter a valid 10-digit mobile number (starts with 6-9)',
            backgroundColor: Colors.orange.shade100);
        return;
      }
    }

    final amtStr = amountController.text.trim();
    final currentBal = _auth.currentUser.value?.walletBalance ?? 2580.00;
    final amtError = Validators.validateAmount(amtStr, min: 1, max: 100000, maxBalance: currentBal);
    if (amtError != null) {
      Get.snackbar('Validation', amtError, backgroundColor: Colors.orange.shade100);
      return;
    }

    final double amount = double.parse(amtStr);
    if (isSending.value) return;

    isSending.value = true;
    try {
      final res = await _repo.transferMoney(
        recipient: recipient,
        amount: amount,
        note: noteController.text.trim(),
      );

      if (res.success && res.data != null) {
        // Update user wallet balance locally
        final user = _auth.currentUser.value;
        if (user != null) {
          final newBal = (user.walletBalance - amount).clamp(0.0, double.infinity);
          _auth.setUser(user.copyWith(walletBalance: newBal));
        }

        // Refresh wallet controller if registered
        if (Get.isRegistered<WalletController>()) {
          Get.find<WalletController>().fetchWalletData();
        }
        if (Get.isRegistered<HomeController>()) {
          Get.find<HomeController>().fetchDashboardData();
        }

        Get.off(() => PaymentSuccessView(
              result: res.data ??
                  PaymentResultModel(
                    transactionId: 'TXN${DateTime.now().millisecondsSinceEpoch}',
                    operatorRefNumber: 'REF${DateTime.now().millisecondsSinceEpoch}',
                    amount: amount,
                    timestamp: DateTime.now().toIso8601String(),
                    status: 'success',
                    serviceType: 'Money Transfer',
                    targetTitle: 'Transfer to $recipient',
                    paymentMode: 'FlamePay Wallet',
                    cashbackEarned: 5.0,
                  ),
            ));
      } else {
        Get.snackbar('Transfer Failed', res.message, backgroundColor: Colors.red.shade100);
      }
    } catch (e) {
      Get.snackbar('Error', e.toString(), backgroundColor: Colors.red.shade100);
    } finally {
      isSending.value = false;
    }
  }

  @override
  void onClose() {
    recipientController.dispose();
    amountController.dispose();
    noteController.dispose();
    super.onClose();
  }
}
