import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/network/api_client.dart';
import '../../core/network/api_endpoints.dart';
import '../../core/network/api_exception.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/cibil_model.dart';
import '../../data/repositories/financial_services_repository.dart';
import '../../shared/widgets/state_view.dart';

class CibilController extends GetxController {
  final FinancialServicesRepository _repo = Get.find<FinancialServicesRepository>();

  final Rx<ViewState> viewState = ViewState.success.obs;
  final Rx<CibilScoreModel?> cibilReport = Rx<CibilScoreModel?>(null);

  final panController = TextEditingController();
  final nameController = TextEditingController();
  final dobController = TextEditingController();

  final RxBool hasCheckedScore = false.obs;
  final RxBool isChecking = false.obs;
  final RxBool agreedToConsent = true.obs;
  final RxString selectedGender = 'male'.obs;
  final RxString currentPan = ''.obs;

  // NSDL Live PAN Verification States (Exactly like KYC)
  final isPanVerified = false.obs;
  final isVerifyingPan = false.obs;
  final panVerifiedData = Rxn<Map<String, dynamic>>();
  String _lastVerifiedPan = '';

  @override
  void onInit() {
    super.onInit();
    panController.addListener(() {
      final text = panController.text;
      if (text != text.toUpperCase()) {
        final selection = panController.selection;
        panController.value = panController.value.copyWith(
          text: text.toUpperCase(),
          selection: selection,
        );
      }
      if (isPanVerified.value && text.trim().toUpperCase() != _lastVerifiedPan) {
        isPanVerified.value = false;
        panVerifiedData.value = null;
      }
    });
  }

  /// Step 1: Verify PAN with Income Tax Department (NSDL) exactly like KYC
  Future<bool> verifyPanWithNsdl() async {
    final pan = panController.text.trim().toUpperCase();
    final panRegex = RegExp(r'^[A-Z]{5}[0-9]{4}[A-Z]{1}$');
    if (!panRegex.hasMatch(pan)) {
      Get.snackbar(
        'Sahi PAN Enter Karein',
        'PAN card number galat hai! 10 characters ka format (e.g. ABCDE1234F) hona chahiye.',
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
      return false;
    }

    isVerifyingPan.value = true;
    try {
      final res = await ApiClient.instance.post<Map<String, dynamic>>(
        ApiEndpoints.panVerify,
        data: {
          'pan': pan,
          'panNumber': pan,
          'fullName': nameController.text.trim(),
          'name': nameController.text.trim(),
          'dob': dobController.text.trim(),
        },
        fromJson: (json) => Map<String, dynamic>.from(json as Map),
      );

      if (res.success && res.data != null) {
        final data = res.data!;
        panVerifiedData.value = data;
        isPanVerified.value = true;
        _lastVerifiedPan = pan;

        final isLive = data['isLiveVerified'] == true || data['isGovernmentVerified'] == true;
        final officialName = (data['fullName'] ?? data['name'] ?? '').toString().trim();
        if (isLive && officialName.isNotEmpty && officialName != 'PAN CARD HOLDER' && officialName != 'VERIFIED PAN HOLDER') {
          nameController.text = officialName;
        }
        final officialDob = (data['dob'] ?? '').toString().trim();
        if (isLive && officialDob.isNotEmpty && dobController.text.isEmpty) {
          dobController.text = officialDob;
        }

        final statusDesc = (data['status'] ?? 'EXISTING AND VALID').toString();

        Get.snackbar(
          'PAN Verified (NSDL) ✓',
          'PAN: $pan • $statusDesc',
          backgroundColor: Colors.green.shade100,
          colorText: Colors.green.shade900,
          icon: const Icon(Icons.verified_rounded, color: Colors.green),
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(16),
        );
        return true;
      } else {
        isPanVerified.value = false;
        Get.snackbar(
          'PAN Verification Failed',
          res.message.isNotEmpty ? res.message : 'Income Tax Department (NSDL) could not verify this PAN card.',
          backgroundColor: Colors.red.shade100,
          colorText: Colors.red.shade900,
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 4),
        );
        return false;
      }
    } on ApiException catch (e) {
      isPanVerified.value = false;
      Get.snackbar(
        'PAN Verification Failed',
        e.message,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 4),
      );
      return false;
    } catch (e) {
      isPanVerified.value = false;
      Get.snackbar(
        'PAN Verification Error',
        'Could not reach NSDL PAN verification service: $e',
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
      return false;
    } finally {
      isVerifyingPan.value = false;
    }
  }

  Future<void> checkScoreForPan() async {
    final pan = panController.text.trim().toUpperCase();
    if (pan.isEmpty) {
      Get.snackbar('Validation', 'Please enter your 10-character PAN Card number',
          backgroundColor: Colors.orange.shade100);
      return;
    }
    if (!RegExp(r'^[A-Z]{5}[0-9]{4}[A-Z]{1}$').hasMatch(pan)) {
      Get.snackbar('Invalid PAN', 'Enter a valid 10-digit PAN format (e.g. ABCDE1234F)',
          backgroundColor: Colors.orange.shade100);
      return;
    }

    // Step 1: Jaise KYC me hota hai, pehle PAN NSDL verify karo
    if (!isPanVerified.value) {
      final panOk = await verifyPanWithNsdl();
      if (!panOk) {
        return; // Stop right here! CIBIL will NOT be checked if PAN is invalid
      }
    }

    final name = nameController.text.trim();
    if (name.isEmpty) {
      Get.snackbar('Validation', 'Please enter your full name as per PAN card',
          backgroundColor: Colors.orange.shade100);
      return;
    }

    // Validate Date of Birth
    final dobStr = dobController.text.trim();
    if (dobStr.isNotEmpty) {
      try {
        DateTime? birthDate;
        if (dobStr.contains('/')) {
          final p = dobStr.split('/');
          if (p.length == 3) {
            birthDate = DateTime(int.parse(p[2]), int.parse(p[1]), int.parse(p[0]));
          }
        }
        if (birthDate != null) {
          final now = DateTime.now();
          if (birthDate.isAfter(now)) {
            Get.snackbar('Invalid DOB', 'Date of Birth cannot be in the future',
                backgroundColor: Colors.red.shade100);
            return;
          }
          final age = now.year - birthDate.year - ((now.month < birthDate.month || (now.month == birthDate.month && now.day < birthDate.day)) ? 1 : 0);
          if (age < 18) {
            Get.snackbar('Age Restriction', 'Must be at least 18 years old to check credit score',
                backgroundColor: Colors.red.shade100);
            return;
          }
        }
      } catch (_) {}
    }

    if (!agreedToConsent.value) {
      Get.snackbar('Consent Required', 'Please accept the credit bureau authorization',
          backgroundColor: Colors.orange.shade100);
      return;
    }

    isChecking.value = true;
    try {
      final res = await _repo.checkCibilScore(
        pan: pan,
        fullName: name,
        dob: dobController.text.trim(),
        gender: selectedGender.value,
      );

      if (res.success && res.data != null) {
        cibilReport.value = res.data;
        currentPan.value = pan;
        hasCheckedScore.value = true;
        viewState.value = ViewState.success;
        Get.snackbar(
          'PAN Verified & CIBIL Fetched',
          'PAN $pan verified with Income Tax records. Score: ${res.data!.score} (${res.data!.rating})',
          backgroundColor: Colors.green.shade100,
          colorText: Colors.green.shade900,
          duration: const Duration(seconds: 4),
          icon: const Icon(Icons.verified_rounded, color: Colors.green),
        );
      } else {
        Get.snackbar(
          'PAN Verification Failed',
          res.message.isNotEmpty ? res.message : 'Invalid PAN card or details. Verification failed.',
          backgroundColor: Colors.red.shade100,
          colorText: Colors.red.shade900,
          duration: const Duration(seconds: 5),
          icon: const Icon(Icons.error_outline_rounded, color: Colors.red),
        );
      }
    } catch (e) {
      Get.snackbar(
        'Verification Error',
        'Could not verify PAN or fetch CIBIL score for $pan: $e',
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
        duration: const Duration(seconds: 5),
      );
    } finally {
      isChecking.value = false;
    }
  }

  void resetToInputForm() {
    hasCheckedScore.value = false;
    panController.clear();
  }

  Future<void> fetchCibilReport() async {
    viewState.value = ViewState.loading;
    try {
      final res = await _repo.getCibilReport();
      if (res.success && res.data != null) {
        cibilReport.value = res.data;
        hasCheckedScore.value = true;
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
      'CIBIL Credit Health Report (PDF) is downloading for ${currentPan.value.isNotEmpty ? currentPan.value : "your profile"}...',
      backgroundColor: AppColors.tintGreen,
      icon: const Icon(Icons.download_done_rounded, color: AppColors.success),
      duration: const Duration(seconds: 3),
    );
  }

  void refreshScore() {
    if (currentPan.value.isNotEmpty) {
      checkScoreForPan();
    } else {
      Get.snackbar(
        'Score Up-to-Date',
        'Your CIBIL score is current as of ${cibilReport.value?.lastUpdated ?? "Today"}.',
        backgroundColor: AppColors.tintBlue,
        duration: const Duration(seconds: 3),
      );
    }
  }

  @override
  void onClose() {
    panController.dispose();
    nameController.dispose();
    dobController.dispose();
    super.onClose();
  }
}
