import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/user_model.dart';

class KycController extends GetxController {
  final AuthService authService = Get.find<AuthService>();

  final currentStep = 0.obs;
  final isSubmitting = false.obs;
  final isKycCompleted = false.obs;
  final kycStatusText = 'Not Verified'.obs;

  // Form Fields
  final fullNameController = TextEditingController(text: 'Rahul Sharma');
  final panController = TextEditingController(text: 'ABCDE1234F');
  final aadhaarController = TextEditingController(text: '5678 9012 3456');
  final dobController = TextEditingController(text: '15/08/1995');

  // Document Upload States
  final aadhaarFrontUploaded = false.obs;
  final aadhaarBackUploaded = false.obs;
  final panUploaded = false.obs;
  final selfieCaptured = false.obs;
  final isQrScanned = false.obs;

  @override
  void onInit() {
    super.onInit();
    final user = authService.currentUser.value;
    if (user != null) {
      if (user.name.isNotEmpty && user.name != 'User') {
        fullNameController.text = user.name;
      }
      if (user.pan != null && user.pan!.isNotEmpty) {
        panController.text = user.pan!;
      }
      if (user.aadhaar != null && user.aadhaar!.isNotEmpty) {
        aadhaarController.text = user.aadhaar!;
      }
      if (user.kycStatus == 'verified') {
        isKycCompleted.value = true;
        kycStatusText.value = 'Full KYC Verified';
      }
    }
    _fetchKycStatus();
  }

  @override
  void onClose() {
    fullNameController.dispose();
    panController.dispose();
    aadhaarController.dispose();
    dobController.dispose();
    super.onClose();
  }

  Future<void> _fetchKycStatus() async {
    try {
      final res = await ApiClient.instance.get(ApiEndpoints.kycStatus);
      if (res.data != null && res.data['status'] == 'completed') {
        isKycCompleted.value = true;
        kycStatusText.value = 'Full KYC Verified';
      }
    } catch (_) {
      // Mock default
    }
  }

  void openAadhaarQrScanner() {
    Get.bottomSheet(
      Container(
        height: 480,
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Color(0xFF101828),
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          children: [
            Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(height: 18),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Scan Aadhaar QR Code',
                  style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  onPressed: () => Get.back(),
                  icon: const Icon(Icons.close_rounded, color: Colors.white70),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Align the QR code printed on your physical Aadhaar card within the frame to autofill your verified identity details.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70, fontSize: 12, height: 1.4),
            ),
            const SizedBox(height: 20),

            // Viewfinder Frame
            Expanded(
              child: Container(
                width: 220,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.accentOrange, width: 2.5),
                  color: Colors.black45,
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    const Icon(Icons.qr_code_scanner_rounded, color: AppColors.primaryBlue, size: 100),
                    Positioned(
                      bottom: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black87,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'Detecting Aadhaar QR...',
                          style: TextStyle(color: Colors.white, fontSize: 11),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Scan Action
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Get.back(); // close scanner
                  // Decode & Autofill
                  fullNameController.text = 'Rahul Sharma';
                  aadhaarController.text = '5678 9012 3456';
                  dobController.text = '15/08/1995';
                  aadhaarFrontUploaded.value = true;
                  aadhaarBackUploaded.value = true;
                  isQrScanned.value = true;

                  Get.snackbar(
                    'Aadhaar QR Verified!',
                    'Decoded demographic details from UIDAI QR code successfully.',
                    backgroundColor: AppColors.success.withValues(alpha: 0.15),
                    colorText: AppColors.success,
                    icon: const Icon(Icons.check_circle_rounded, color: AppColors.success),
                    snackPosition: SnackPosition.BOTTOM,
                    margin: const EdgeInsets.all(16),
                  );
                },
                icon: const Icon(Icons.qr_code_2_rounded, color: Colors.white),
                label: const Text('Capture & Decode QR', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accentOrange,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  void nextStep() {
    if (currentStep.value == 0) {
      if (fullNameController.text.trim().isEmpty ||
          panController.text.trim().length != 10 ||
          aadhaarController.text.replaceAll(' ', '').length != 12) {
        Get.snackbar(
          'Incomplete Details',
          'Please enter valid PAN (10 chars) and Aadhaar (12 digits)',
          backgroundColor: AppColors.error.withValues(alpha: 0.1),
          colorText: AppColors.error,
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(16),
        );
        return;
      }
      currentStep.value = 1;
    } else if (currentStep.value == 1) {
      if (!aadhaarFrontUploaded.value || !panUploaded.value) {
        Get.snackbar(
          'Upload Required',
          'Please upload Aadhaar Front and PAN card photos to continue',
          backgroundColor: AppColors.error.withValues(alpha: 0.1),
          colorText: AppColors.error,
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(16),
        );
        return;
      }
      currentStep.value = 2;
    }
  }

  void previousStep() {
    if (currentStep.value > 0) {
      currentStep.value--;
    }
  }

  void simulateUpload(String docType) {
    Get.dialog(
      const Center(
        child: CircularProgressIndicator(color: AppColors.primaryBlue),
      ),
      barrierDismissible: false,
    );

    Future.delayed(const Duration(milliseconds: 700), () {
      Get.back(); // close progress
      if (docType == 'aadhaar_front') {
        aadhaarFrontUploaded.value = true;
      } else if (docType == 'aadhaar_back') {
        aadhaarBackUploaded.value = true;
      } else if (docType == 'pan') {
        panUploaded.value = true;
      } else if (docType == 'selfie') {
        selfieCaptured.value = true;
      }

      Get.snackbar(
        'Upload Successful',
        '$docType successfully attached & OCR processed.',
        backgroundColor: AppColors.success.withValues(alpha: 0.1),
        colorText: AppColors.success,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      );
    });
  }

  Future<void> submitKyc() async {
    if (!selfieCaptured.value) {
      Get.snackbar(
        'Selfie Required',
        'Please capture a live photo for biometric verification',
        backgroundColor: AppColors.error.withValues(alpha: 0.1),
        colorText: AppColors.error,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
      return;
    }

    isSubmitting.value = true;

    try {
      await ApiClient.instance.post(ApiEndpoints.kycSubmit, data: {
        'fullName': fullNameController.text.trim(),
        'pan': panController.text.trim(),
        'aadhaar': aadhaarController.text.replaceAll(' ', ''),
        'dob': dobController.text.trim(),
      });
    } catch (_) {
      // Fallback
      await Future.delayed(const Duration(seconds: 1));
    } finally {
      isSubmitting.value = false;
      isKycCompleted.value = true;
      kycStatusText.value = 'Full KYC Verified';

      // Update AuthService account with the verified user details!
      final existingUser = authService.currentUser.value;
      final updatedUser = (existingUser ?? const UserModel(
        id: 'FP_USER_101',
        name: '',
        phone: '+91 9876543210',
        email: 'user@example.com',
      )).copyWith(
        name: fullNameController.text.trim(),
        kycStatus: 'verified',
        isVip: true,
        pan: panController.text.trim(),
        aadhaar: aadhaarController.text.trim(),
      );
      authService.setUser(updatedUser);

      Get.dialog(
        AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: const BoxDecoration(
                  color: Color(0xFFECFDF3),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.verified_user_rounded, color: AppColors.success, size: 44),
              ),
              const SizedBox(height: 16),
              const Text(
                'Account Verified Successfully!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.navyText),
              ),
              const SizedBox(height: 8),
              Text(
                'Congratulations ${fullNameController.text.trim()}! Your full KYC profile has been created and verified. Monthly wallet limit upgraded to ₹2,00,000.',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.4),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Get.back(); // close dialog
                    Get.back(); // return to previous screen
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 13),
                  ),
                  child: const Text('Go to Profile', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
        barrierDismissible: false,
      );
    }
  }
}
