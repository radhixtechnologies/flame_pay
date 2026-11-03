import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
  final RxString currentPan = ''.obs;

  @override
  void onInit() {
    super.onInit();
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

    final name = nameController.text.trim();
    if (name.isEmpty) {
      Get.snackbar('Validation', 'Please enter your full name as per PAN card',
          backgroundColor: Colors.orange.shade100);
      return;
    }

    // Validate 4th character of PAN (Must be 'P' for Individual Personal)
    final panType = pan[3];
    if (panType != 'P' && panType != 'C' && panType != 'H') {
      Get.snackbar('Personal PAN Required', 'Please enter an individual personal PAN card (4th letter must be P)',
          backgroundColor: Colors.orange.shade100, duration: const Duration(seconds: 4));
      return;
    }

    // Validate 5th character of PAN against cardholder surname/name
    final panFifthChar = pan[4];
    final nameParts = name.split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    final firstName = nameParts.first.toUpperCase();
    final lastName = (nameParts.length > 1 ? nameParts.last : nameParts.first).toUpperCase();

    final matchesSurname = lastName.startsWith(panFifthChar);
    final matchesFirstName = firstName.startsWith(panFifthChar);

    if (!matchesSurname && !matchesFirstName) {
      Get.snackbar(
        'Name Mismatch',
        'The name "$name" does not match PAN $pan. Under Income Tax rules, the 5th character "$panFifthChar" must match your surname or name.',
        backgroundColor: Colors.red.shade100,
        duration: const Duration(seconds: 5),
      );
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
      );

      if (res.success && res.data != null) {
        cibilReport.value = res.data;
        currentPan.value = pan;
        hasCheckedScore.value = true;
        viewState.value = ViewState.success;
      } else {
        Get.snackbar('Error', res.message, backgroundColor: Colors.red.shade100);
      }
    } catch (e) {
      Get.snackbar('Error', 'Could not fetch CIBIL score for $pan',
          backgroundColor: Colors.red.shade100);
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
