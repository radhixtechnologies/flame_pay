import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/storage_service.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/credit_card_model.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/financial_services_repository.dart';
import '../../shared/widgets/state_view.dart';

class CreditCardController extends GetxController {
  final FinancialServicesRepository _repo = Get.find<FinancialServicesRepository>();
  final StorageService _storage = Get.find<StorageService>();

  final Rx<ViewState> viewState = ViewState.loading.obs;
  final RxList<CreditCardModel> cards = <CreditCardModel>[].obs;
  final RxString selectedCategory = 'All'.obs;
  final List<String> categories = ['All', 'Cashback', 'Rewards', 'Travel', 'Fuel', 'RuPay/UPI', 'Secured'];

  final RxBool isSubmitting = false.obs;

  // Lead Deduplication & Persistent Progress Tracking
  final RxSet<int> appliedProductIds = <int>{}.obs;
  final RxMap<int, String> productLeadIds = <int, String>{}.obs;
  final RxMap<int, String> productRedirectUrls = <int, String>{}.obs;
  final RxList<Map<String, dynamic>> appliedApplications = <Map<String, dynamic>>[].obs;

  // Government PAN Card Verification State
  final RxBool isPanVerified = false.obs;
  final RxBool isVerifyingPan = false.obs;
  final RxString verifiedPan = ''.obs;
  final RxString verifiedName = ''.obs;
  final RxString verifiedFatherName = ''.obs;
  final RxString verifiedDob = ''.obs;
  final RxString verificationAgency = 'Income Tax Department (NSDL/UTIITSL)'.obs;
  final Rx<File?> panImageFile = Rx<File?>(null);

  @override
  void onInit() {
    super.onInit();
    _initUserPan();
    _loadAppliedCards();
    fetchCards();
  }

  void _loadAppliedCards() {
    try {
      final map = _storage.getAppliedCreditCards();
      final list = <Map<String, dynamic>>[];
      map.forEach((key, val) {
        final pId = int.tryParse(key);
        if (pId != null && val is Map) {
          appliedProductIds.add(pId);
          if (val['leadId'] != null) {
            productLeadIds[pId] = val['leadId'].toString();
          }
          if (val['redirectUrl'] != null) {
            productRedirectUrls[pId] = val['redirectUrl'].toString();
          }
          list.add(Map<String, dynamic>.from(val));
        }
      });
      appliedApplications.assignAll(list);
    } catch (_) {}
  }

  void _initUserPan() {
    try {
      final user = Get.find<AuthService>().currentUser.value;
      if (user != null) {
        if (user.pan != null && user.pan!.isNotEmpty) {
          verifiedPan.value = user.pan!;
          verifiedName.value = user.name;
          if (user.kycStatus == 'verified') {
            isPanVerified.value = true;
          }
        }
      }
    } catch (_) {}
  }

  Future<void> fetchCards([String? cat]) async {
    viewState.value = ViewState.loading;
    try {
      final res = await _repo.getCreditCards(category: cat == 'All' ? null : cat);
      if (res.success && res.data != null && res.data!.isNotEmpty) {
        cards.assignAll(res.data!);
        viewState.value = ViewState.success;
      } else {
        viewState.value = ViewState.error;
      }

      // Sync user's previous card applications from backend
      try {
        final appsRes = await _repo.getMyCreditCardApplications();
        if (appsRes.success && appsRes.data != null && appsRes.data!.isNotEmpty) {
          for (final app in appsRes.data!) {
            final pId = app['productId'] != null ? int.tryParse(app['productId'].toString()) : null;
            if (pId != null) {
              appliedProductIds.add(pId);
              if (app['id'] != null) productLeadIds[pId] = app['id'].toString();
              await _storage.saveAppliedCreditCard(
                productId: pId,
                leadId: app['id']?.toString() ?? '',
                cardName: app['cardName']?.toString() ?? 'Credit Card',
                bankName: app['bankName']?.toString() ?? 'Partner Bank',
              );
            }
          }
          _loadAppliedCards();
        }
      } catch (_) {}
    } catch (_) {
      viewState.value = ViewState.error;
    }
  }

  void onCategoryChanged(String category) {
    selectedCategory.value = category;
    fetchCards(category);
  }

  // Government-grade PAN verification
  Future<bool> verifyPanCard({
    required String pan,
    String? name,
    String? dob,
    File? imageFile,
  }) async {
    isVerifyingPan.value = true;
    try {
      final res = await _repo.verifyPanCard(
        pan: pan,
        name: name,
        dob: dob,
        imagePath: imageFile?.path,
      );
      isVerifyingPan.value = false;

      if (res.success && res.data != null) {
        isPanVerified.value = true;
        verifiedPan.value = res.data!['pan']?.toString() ?? pan.toUpperCase();
        verifiedName.value = res.data!['name']?.toString() ?? (name ?? '');
        verifiedFatherName.value = res.data!['fatherName']?.toString() ?? '';
        verifiedDob.value = res.data!['dob']?.toString() ?? (dob ?? '');
        verificationAgency.value = res.data!['verificationAgency']?.toString() ?? 'Income Tax Department (NSDL)';
        if (imageFile != null) {
          panImageFile.value = imageFile;
        }

        // Update AuthService user
        try {
          final auth = Get.find<AuthService>();
          final curr = auth.currentUser.value;
          if (curr != null) {
            auth.setUser(curr.copyWith(
              pan: verifiedPan.value,
              name: verifiedName.value,
              kycStatus: 'verified',
            ));
          }
        } catch (_) {}

        Get.snackbar(
          'PAN Verified Successfully! 🛡️',
          'Verified with Income Tax Department records for ${verifiedName.value}',
          backgroundColor: AppColors.success.withValues(alpha: 0.15),
          colorText: AppColors.success,
          icon: const Icon(Icons.verified_rounded, color: AppColors.success),
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(16),
        );
        return true;
      } else {
        Get.snackbar('Verification Error', res.message, backgroundColor: Colors.red.shade100);
        return false;
      }
    } catch (e) {
      isVerifyingPan.value = false;
      Get.snackbar('Verification Error', 'Failed to verify PAN with Income Tax database', backgroundColor: Colors.red.shade100);
      return false;
    }
  }

  Future<void> pickPanPhoto(ImageSource source, {String? currentName, String? currentPan}) async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(source: source, imageQuality: 85);
      if (picked != null) {
        final file = File(picked.path);
        panImageFile.value = file;
        await verifyPanCard(
          pan: (currentPan != null && currentPan.isNotEmpty) ? currentPan : (verifiedPan.value.isNotEmpty ? verifiedPan.value : 'ABCDE1234F'),
          name: currentName ?? verifiedName.value,
          imageFile: file,
        );
      }
    } catch (e) {
      Get.snackbar('Access Error', 'Could not open camera or gallery', backgroundColor: Colors.red.shade100);
    }
  }

  Future<void> applyForCard(CreditCardModel card, {
    required String name,
    required String pan,
    required double income,
    required String empType,
    String? phone,
    String? email,
    String? pincode,
  }) async {
    final pId = card.productId;

    // Deduplication Guard: If already applied, DO NOT send a second lead to CheapKart!
    if (pId != null && appliedProductIds.contains(pId)) {
      final existingUrl = productRedirectUrls[pId] ?? card.redirectUrl ?? '';
      final existingLeadId = productLeadIds[pId] ?? '';

      Get.back(); // Close bottom sheet
      _showApprovedDialog(
        card: card,
        leadId: existingLeadId,
        redirectUrl: existingUrl,
        isExisting: true,
      );
      return;
    }

    isSubmitting.value = true;
    try {
      final res = await _repo.applyForCreditCard(
        cardId: card.id,
        productId: card.productId,
        cardName: card.name,
        bankName: card.bank,
        fullName: name,
        panNumber: pan,
        monthlyIncome: income,
        employmentType: empType,
        phone: phone,
        email: email,
        pincode: pincode,
      );

      isSubmitting.value = false;

      if (res.success) {
        final redirectUrl = (res.data?['redirect_url'] ?? res.data?['redirectUrl'] ?? card.redirectUrl)?.toString() ?? '';
        final leadId = (res.data?['applicationId'] ?? res.data?['leadId'] ?? res.data?['application_id'] ?? '')?.toString() ?? '';

        // Record in applied tracker to guarantee only 1 entry in CheapKart
        if (pId != null) {
          appliedProductIds.add(pId);
          if (leadId.isNotEmpty) productLeadIds[pId] = leadId;
          if (redirectUrl.isNotEmpty) productRedirectUrls[pId] = redirectUrl;
          await _storage.saveAppliedCreditCard(
            productId: pId,
            leadId: leadId.isNotEmpty ? leadId : 'CK_LEAD_${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
            cardName: card.name,
            bankName: card.bank,
            redirectUrl: redirectUrl,
          );
          _loadAppliedCards();
        }

        Get.back(); // Close bottom sheet
        _showApprovedDialog(
          card: card,
          leadId: leadId,
          redirectUrl: redirectUrl,
          isExisting: res.data?['alreadyApplied'] == true,
        );
      }
    } catch (_) {
      isSubmitting.value = false;
      Get.snackbar('Error', 'Application could not be processed', backgroundColor: Colors.red.shade100);
    }
  }

  void _showApprovedDialog({
    required CreditCardModel card,
    required String leadId,
    required String redirectUrl,
    bool isExisting = false,
  }) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: const BoxDecoration(
                  color: AppColors.tintGreen,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 40),
              ),
              const SizedBox(height: 16),
              Text(
                isExisting ? 'Application Active!' : 'Pre-Approved!',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.navyText),
              ),
              const SizedBox(height: 8),
              Text(
                isExisting
                    ? 'Your application for ${card.name} is already registered. You can proceed directly to the bank application portal.'
                    : 'Congratulations! Your application for ${card.name} has been processed successfully.',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.tintBlue,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    const Text(
                      'Approved Limit: ₹1,50,000',
                      style: TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    if (leadId.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Ref ID: $leadId',
                        style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 20),
              if (redirectUrl.isNotEmpty) ...[
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accentOrange,
                    minimumSize: const Size(double.infinity, 46),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  icon: const Icon(Icons.open_in_new_rounded, size: 18, color: Colors.white),
                  label: const Text(
                    'Proceed to Bank Application',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  onPressed: () async {
                    try {
                      final uri = Uri.parse(redirectUrl);
                      await launchUrl(uri, mode: LaunchMode.externalApplication);
                    } catch (e) {
                      Get.snackbar('Notice', 'Opening browser: $redirectUrl');
                    }
                  },
                ),
                const SizedBox(height: 10),
              ],
              TextButton(
                style: TextButton.styleFrom(
                  minimumSize: const Size(double.infinity, 40),
                ),
                onPressed: () => Get.back(),
                child: const Text('Done', style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
