import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../../shared/widgets/blue_header_scaffold.dart';
import '../kyc_controller.dart';

class KycView extends GetView<KycController> {
  const KycView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlueHeaderScaffold(
      title: 'KYC Verification',
      
      body: Obx(() {
        if (controller.isKycCompleted.value) {
          return _buildVerifiedBanner(context);
        }

        return Column(
          children: [
            _buildStepper(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(
                  children: [
                    if (controller.currentStep.value == 0) _buildStep1Details(),
                    if (controller.currentStep.value == 1) _buildStep2Documents(),
                    if (controller.currentStep.value == 2) _buildStep3Selfie(),
                    const SizedBox(height: 20),
                    _buildBenefitsCard(),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildVerifiedBanner(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryBlue.withValues(alpha: 0.08),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  width: 76,
                  height: 76,
                  decoration: const BoxDecoration(
                    color: Color(0xFFECFDF3),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.verified_user_rounded, color: AppColors.success, size: 44),
                ),
                const SizedBox(height: 16),
                Text('Full KYC Verified', style: AppTypography.h2),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Tier 2 Account • High Limit',
                    style: AppTypography.caption.copyWith(color: AppColors.success, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 20),
                const Divider(),
                const SizedBox(height: 12),
                _buildInfoRow('Name as per Aadhaar', controller.fullNameController.text),
                _buildInfoRow('PAN Number', controller.panController.text),
                _buildInfoRow('Monthly Wallet Limit', '₹2,00,000'),
                _buildInfoRow('Bank P2P Transfers', 'Unlimited & Free'),
                _buildInfoRow('Verification Date', '26 Oct 2026'),
              ],
            ),
          ),
          const SizedBox(height: 24),
          AppButton(
            text: 'Back to Profile',
            onPressed: () => Get.back(),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTypography.caption),
          Text(value, style: AppTypography.bodyBold.copyWith(fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildStepper() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Obx(() {
        final step = controller.currentStep.value;
        return Row(
          children: [
            _buildStepCircle(0, 'Details', step),
            _buildStepConnector(step > 0),
            _buildStepCircle(1, 'Documents', step),
            _buildStepConnector(step > 1),
            _buildStepCircle(2, 'Selfie', step),
          ],
        );
      }),
    );
  }

  Widget _buildStepCircle(int stepIndex, String title, int currentStep) {
    final isDone = currentStep > stepIndex;
    final isActive = currentStep == stepIndex;

    Color bg = const Color(0xFFF2F4F7);
    Color textColor = AppColors.textSecondary;
    if (isDone) {
      bg = AppColors.success;
    } else if (isActive) {
      bg = AppColors.primaryBlue;
      textColor = AppColors.primaryBlue;
    }

    return Expanded(
      child: Column(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: bg,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: isDone
                  ? const Icon(Icons.check, color: Colors.white, size: 18)
                  : Text(
                      '${stepIndex + 1}',
                      style: TextStyle(
                        color: isActive ? Colors.white : AppColors.textSecondary,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: AppTypography.micro.copyWith(
              color: textColor,
              fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepConnector(bool isActive) {
    return Container(
      width: 32,
      height: 2,
      margin: const EdgeInsets.only(bottom: 16),
      color: isActive ? AppColors.success : const Color(0xFFE4E7EC),
    );
  }

  Widget _buildStep1Details() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Identity Details', style: AppTypography.title),
          const SizedBox(height: 4),
          Text('Information must strictly match your official government IDs', style: AppTypography.caption),
          const SizedBox(height: 14),

          // Fast-track Aadhaar QR scan banner
          InkWell(
            onTap: controller.openAadhaarQrScanner,
            borderRadius: BorderRadius.circular(14),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primaryBlue.withValues(alpha: 0.08),
                    AppColors.accentOrange.withValues(alpha: 0.12),
                  ],
                ),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.primaryBlue.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlue,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.qr_code_scanner_rounded, color: Colors.white, size: 24),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Scan Aadhaar QR Code', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.navyText)),
                        SizedBox(height: 2),
                        Text('Instantly decode & autofill your details', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.primaryBlue),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),
          AppTextField(
            label: 'Full Name (as on Aadhaar)',
            controller: controller.fullNameController,
            prefixIcon: const Icon(Icons.person_outline_rounded, color: AppColors.primaryBlue, size: 20),
          ),
          const SizedBox(height: 14),
          AppTextField(
            label: 'PAN Card Number (10 Alphanumeric)',
            controller: controller.panController,
            
            prefixIcon: const Icon(Icons.badge_outlined, color: AppColors.primaryBlue, size: 20),
          ),
          const SizedBox(height: 14),
          AppTextField(
            label: 'Aadhaar Number (12 Digits)',
            controller: controller.aadhaarController,
            keyboardType: TextInputType.number,
            prefixIcon: const Icon(Icons.fingerprint_rounded, color: AppColors.primaryBlue, size: 20),
          ),
          const SizedBox(height: 14),
          AppTextField(
            label: 'Date of Birth (DD/MM/YYYY)',
            controller: controller.dobController,
            prefixIcon: const Icon(Icons.calendar_today_outlined, color: AppColors.primaryBlue, size: 20),
          ),
          const SizedBox(height: 20),
          AppButton(
            text: 'Continue to Uploads',
            onPressed: controller.nextStep,
          ),
        ],
      ),
    );
  }

  Widget _buildStep2Documents() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Document Photos', style: AppTypography.title),
          const SizedBox(height: 4),
          Text('Ensure photos are clearly lit and text is readable', style: AppTypography.caption),
          const SizedBox(height: 16),
          Obx(() => _buildUploadCard(
                title: 'Aadhaar Card (Front)',
                subtitle: 'Front side with photo and address',
                isUploaded: controller.aadhaarFrontUploaded.value,
                onTap: () => controller.simulateUpload('aadhaar_front'),
              )),
          const SizedBox(height: 12),
          Obx(() => _buildUploadCard(
                title: 'Aadhaar Card (Back)',
                subtitle: 'Back side with QR code and address',
                isUploaded: controller.aadhaarBackUploaded.value,
                onTap: () => controller.simulateUpload('aadhaar_back'),
              )),
          const SizedBox(height: 12),
          Obx(() => _buildUploadCard(
                title: 'PAN Card (Front)',
                subtitle: 'Front photo with signature clearly visible',
                isUploaded: controller.panUploaded.value,
                onTap: () => controller.simulateUpload('pan'),
              )),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: controller.previousStep,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    side: const BorderSide(color: AppColors.border),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Back', style: TextStyle(color: AppColors.navyText, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: AppButton(
                  text: 'Continue to Selfie',
                  onPressed: controller.nextStep,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUploadCard({
    required String title,
    required String subtitle,
    required bool isUploaded,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isUploaded ? const Color(0xFFF6FEF9) : const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isUploaded ? AppColors.success : const Color(0xFFE4E7EC),
            width: isUploaded ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isUploaded ? const Color(0xFFD1FADF) : Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                isUploaded ? Icons.check_circle_rounded : Icons.cloud_upload_outlined,
                color: isUploaded ? AppColors.success : AppColors.primaryBlue,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTypography.bodyBold.copyWith(fontSize: 13)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: AppTypography.micro.copyWith(color: AppColors.textSecondary)),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: isUploaded ? AppColors.success : AppColors.primaryBlue,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                isUploaded ? 'Replace' : 'Upload',
                style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep3Selfie() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Live Selfie Verification', style: AppTypography.title),
          const SizedBox(height: 4),
          Text('Take a clear selfie without glasses, masks, or caps', style: AppTypography.caption),
          const SizedBox(height: 20),
          Center(
            child: Obx(() {
              final done = controller.selfieCaptured.value;
              return Column(
                children: [
                  Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: done ? const Color(0xFFD1FADF) : const Color(0xFFF2F4F7),
                      border: Border.all(
                        color: done ? AppColors.success : AppColors.primaryBlue,
                        width: 3,
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        done ? Icons.face_retouching_natural_rounded : Icons.camera_alt_outlined,
                        size: 54,
                        color: done ? AppColors.success : AppColors.primaryBlue,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    done ? 'Selfie Matched & Verified!' : 'Align face in the center',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: done ? AppColors.success : AppColors.navyText,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => controller.simulateUpload('selfie'),
                    icon: Icon(done ? Icons.refresh : Icons.camera_alt, size: 18),
                    label: Text(done ? 'Retake Photo' : 'Capture Live Photo'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: done ? Colors.grey.shade700 : AppColors.primaryBlue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ],
              );
            }),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: controller.previousStep,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    side: const BorderSide(color: AppColors.border),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Back', style: TextStyle(color: AppColors.navyText, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: Obx(() => AppButton(
                      text: 'Submit Full KYC',
                      isLoading: controller.isSubmitting.value,
                      onPressed: controller.submitKyc,
                    )),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.shield_outlined, color: AppColors.primaryBlue, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text('Why Complete Full KYC?', style: AppTypography.bodyBold),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _buildBenefitRow('Wallet limit increased from ₹10k to ₹2,00,000/month'),
          _buildBenefitRow('Direct wallet-to-bank instant zero fee transfers'),
          _buildBenefitRow('Unlock pre-approved Personal Loans & Credit Cards'),
          _buildBenefitRow('100% RBI & UIDAI Compliant 256-bit AES encryption'),
        ],
      ),
    );
  }

  Widget _buildBenefitRow(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text, style: AppTypography.caption.copyWith(fontSize: 12, height: 1.3)),
          ),
        ],
      ),
    );
  }
}
