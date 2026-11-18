import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../core/network/api_client.dart';
import '../../core/network/api_endpoints.dart';
import '../../core/network/api_exception.dart';
import '../../core/services/auth_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import 'qr_scanner_sheet.dart';

class PersonalQrSheet extends StatefulWidget {
  static void show(BuildContext context) {
    Get.bottomSheet(
      const PersonalQrSheet(),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      ignoreSafeArea: false,
    );
  }

  const PersonalQrSheet({super.key});

  @override
  State<PersonalQrSheet> createState() => _PersonalQrSheetState();
}

class _PersonalQrSheetState extends State<PersonalQrSheet> {
  final _storage = GetStorage();
  final _vpaController = TextEditingController();
  final _amountController = TextEditingController();

  String _verifiedVpa = '';
  String _verifiedName = '';
  String _verifiedBank = '';
  String _requestAmount = '';
  bool _isVerifying = false;
  bool _isEditingVpa = false;
  String? _errorText;

  static const _quickHandles = [
    '@okaxis',
    '@okhdfcbank',
    '@oksbi',
    '@ybl',
    '@paytm',
    '@ibl',
  ];

  @override
  void initState() {
    super.initState();
    _loadSavedQr();
  }

  @override
  void dispose() {
    _vpaController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  String _storageKey(String suffix) {
    final uid = Get.isRegistered<AuthService>()
        ? (Get.find<AuthService>().currentUser.value?.id ?? 'default')
        : 'default';
    return 'fp_personal_qr_${uid}_$suffix';
  }

  Future<void> _loadSavedQr() async {
    final savedVpa = _storage.read<String>(_storageKey('vpa')) ?? '';
    final savedName = _storage.read<String>(_storageKey('name')) ?? '';
    final savedBank = _storage.read<String>(_storageKey('bank')) ?? '';

    if (savedVpa.isNotEmpty) {
      setState(() {
        _verifiedVpa = savedVpa;
        _verifiedName = savedName;
        _verifiedBank = savedBank;
        _vpaController.text = savedVpa;
        _isEditingVpa = false;
      });
    } else {
      setState(() => _isEditingVpa = true);
    }

    // Sync from backend in background if user already verified on another session
    try {
      final res = await ApiClient.instance.get<Map<String, dynamic>>(
        ApiEndpoints.userMyQr,
        fromJson: (json) => Map<String, dynamic>.from(json as Map),
      );
      if (mounted && res.success && res.data != null) {
        final remoteVpa = (res.data!['vpa'] ?? '').toString().trim();
        final remoteName = (res.data!['accountHolderName'] ?? '').toString().trim();
        if (remoteVpa.isNotEmpty && remoteVpa != _verifiedVpa) {
          _storage.write(_storageKey('vpa'), remoteVpa);
          _storage.write(_storageKey('name'), remoteName);
          setState(() {
            _verifiedVpa = remoteVpa;
            _verifiedName = remoteName;
            _vpaController.text = remoteVpa;
            _isEditingVpa = false;
          });
        }
      }
    } catch (_) {}
  }

  Future<void> _verifyAndSaveVpa() async {
    final rawVpa = _vpaController.text.trim().toLowerCase();
    if (rawVpa.isEmpty || !RegExp(r'^[a-z0-9._-]{2,}@[a-z0-9.-]{2,}$').hasMatch(rawVpa)) {
      setState(() => _errorText = 'Please enter a valid UPI ID (e.g. yourname@okaxis, 9876543210@ybl)');
      return;
    }

    setState(() {
      _isVerifying = true;
      _errorText = null;
    });

    try {
      final res = await ApiClient.instance.post<Map<String, dynamic>>(
        ApiEndpoints.upiVerify,
        data: {'vpa': rawVpa, 'upiId': rawVpa},
        fromJson: (json) => Map<String, dynamic>.from(json as Map),
      );

      if (res.success && res.data != null) {
        final data = res.data!;
        final vpa = (data['vpa'] ?? rawVpa).toString().trim().toLowerCase();
        final name = (data['accountHolderName'] ?? data['fullName'] ?? data['name'] ?? '').toString().trim();
        final bank = (data['bankName'] ?? '').toString().trim();

        final fallbackName = Get.isRegistered<AuthService>()
            ? (Get.find<AuthService>().currentUser.value?.name ?? 'FlamePay User')
            : 'FlamePay User';
        final finalName = name.isNotEmpty ? name : fallbackName;

        _storage.write(_storageKey('vpa'), vpa);
        _storage.write(_storageKey('name'), finalName);
        _storage.write(_storageKey('bank'), bank);

        if (mounted) {
          setState(() {
            _verifiedVpa = vpa;
            _verifiedName = finalName;
            _verifiedBank = bank;
            _isEditingVpa = false;
            _errorText = null;
          });
        }

        Get.snackbar(
          'Personal Receive QR Ready ✓',
          'NPCI Verified: $finalName ($vpa)',
          backgroundColor: AppColors.success.withValues(alpha: 0.15),
          colorText: AppColors.success,
          icon: const Icon(Icons.verified_rounded, color: AppColors.success),
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(16),
        );
      } else {
        setState(() => _errorText = res.message.isNotEmpty ? res.message : 'UPI ID verification failed. Please check your UPI ID.');
      }
    } on ApiException catch (e) {
      setState(() => _errorText = e.message);
    } catch (e) {
      setState(() => _errorText = 'Could not verify UPI ID: $e');
    } finally {
      if (mounted) setState(() => _isVerifying = false);
    }
  }

  String _buildUpiQrPayload() {
    final params = <String, String>{
      'pa': _verifiedVpa,
      'pn': _verifiedName.isNotEmpty ? _verifiedName : 'FlamePay User',
      'cu': 'INR',
      'tn': 'Payment via FlamePay',
    };
    final amt = double.tryParse(_requestAmount.trim());
    if (amt != null && amt > 0) {
      params['am'] = amt.toStringAsFixed(amt.truncateToDouble() == amt ? 0 : 2);
    }
    return Uri(scheme: 'upi', host: 'pay', queryParameters: params).toString();
  }

  void _openSetAmountDialog() {
    _amountController.text = _requestAmount;
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text('Set Request Amount', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
        content: TextField(
          controller: _amountController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          autofocus: true,
          decoration: InputDecoration(
            prefixText: '₹ ',
            hintText: 'Enter amount (e.g. 500)',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        actions: [
          if (_requestAmount.isNotEmpty)
            TextButton(
              onPressed: () {
                setState(() => _requestAmount = '');
                Get.back();
              },
              child: const Text('Clear Amount', style: TextStyle(color: AppColors.error)),
            ),
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              final v = _amountController.text.trim();
              final parsed = double.tryParse(v);
              if (v.isEmpty || (parsed != null && parsed > 0)) {
                setState(() => _requestAmount = v);
                Get.back();
              } else {
                Get.snackbar('Invalid Amount', 'Please enter a valid amount greater than 0');
              }
            },
            child: const Text('Apply to QR'),
          ),
        ],
      ),
    );
  }

  void _appendHandle(String handle) {
    final current = _vpaController.text.trim();
    final base = current.contains('@') ? current.split('@').first : current;
    _vpaController.text = '$base$handle';
    _vpaController.selection = TextSelection.fromPosition(TextPosition(offset: _vpaController.text.length));
  }

  @override
  Widget build(BuildContext context) {
    final hasQr = _verifiedVpa.isNotEmpty && !_isEditingVpa;

    return Container(
      constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.90),
      padding: EdgeInsets.fromLTRB(20, 14, 20, MediaQuery.viewInsetsOf(context).bottom + 22),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag Handle
            Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(height: 14),

            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primaryBlue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.qr_code_2_rounded, color: AppColors.primaryBlue, size: 22),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          hasQr ? 'My Receive Money QR' : 'Create Personal QR Scanner',
                          style: AppTypography.title.copyWith(color: AppColors.navyText, fontSize: 16.5),
                        ),
                        Text(
                          hasQr ? 'Scan from any UPI app or FlamePay' : 'Verify your real UPI ID via NPCI',
                          style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: AppColors.textSecondary),
                  onPressed: () => Get.back(),
                ),
              ],
            ),

            const SizedBox(height: 16),

            if (!hasQr) _buildSetupForm() else _buildLiveQrCard(context),
          ],
        ),
      ),
    );
  }

  Widget _buildSetupForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFF0F9FF),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.primaryBlue.withValues(alpha: 0.25)),
          ),
          child: const Row(
            children: [
              Icon(Icons.verified_user_rounded, color: AppColors.primaryBlue, size: 22),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Enter your active UPI ID (GPay, PhonePe, Paytm, BHIM). We will verify it live on NPCI and generate your personal scannable Receive Money QR.',
                  style: TextStyle(fontSize: 12, color: AppColors.navyText, height: 1.35),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        TextField(
          controller: _vpaController,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _verifyAndSaveVpa(),
          decoration: InputDecoration(
            labelText: 'Your UPI ID (VPA)',
            hintText: 'e.g. shivam@okaxis or 9876543210@ybl',
            prefixIcon: const Icon(Icons.alternate_email_rounded, color: AppColors.primaryBlue),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
            errorText: _errorText,
          ),
        ),

        const SizedBox(height: 10),
        const Text('Quick UPI Handles:', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
        const SizedBox(height: 6),
        Wrap(
          spacing: 8,
          runSpacing: 6,
          children: _quickHandles.map((h) {
            return InkWell(
              onTap: () => _appendHandle(h),
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.border),
                ),
                child: Text(h, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: AppColors.navyText)),
              ),
            );
          }).toList(),
        ),

        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            onPressed: _isVerifying ? null : _verifyAndSaveVpa,
            icon: _isVerifying
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Icon(Icons.verified_rounded, size: 20),
            label: Text(
              _isVerifying ? 'Verifying UPI ID with NPCI...' : 'Verify UPI & Create My QR',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ),
        ),

        if (_verifiedVpa.isNotEmpty) ...[
          const SizedBox(height: 10),
          Center(
            child: TextButton(
              onPressed: () => setState(() => _isEditingVpa = false),
              child: const Text('Back to My QR Code'),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildLiveQrCard(BuildContext context) {
    final qrPayload = _buildUpiQrPayload();

    return Column(
      children: [
        // Premium QR Card Container
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFF8FAFC), Color(0xFFEFF6FF)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: AppColors.primaryBlue.withValues(alpha: 0.25), width: 1.5),
            boxShadow: const [AppColors.softBlueShadow],
          ),
          child: Column(
            children: [
              // Verified User Name + NPCI Badge
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: Text(
                      _verifiedName.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.navyText,
                        letterSpacing: 0.5,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Icon(Icons.verified_rounded, color: AppColors.success, size: 19),
                ],
              ),
              if (_verifiedBank.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(
                  _verifiedBank,
                  style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
                ),
              ],

              if (_requestAmount.isNotEmpty) ...[
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.accentOrange.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Requesting ₹$_requestAmount',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.accentOrange),
                  ),
                ),
              ],

              const SizedBox(height: 14),

              // REAL SCANNABLE QR CODE (NPCI UPI Standard)
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.border, width: 1.5),
                ),
                child: QrImageView(
                  data: qrPayload,
                  version: QrVersions.auto,
                  size: 215,
                  gapless: false,
                  errorCorrectionLevel: QrErrorCorrectLevel.H,
                  eyeStyle: const QrEyeStyle(
                    eyeShape: QrEyeShape.square,
                    color: Color(0xFF0F172A),
                  ),
                  dataModuleStyle: const QrDataModuleStyle(
                    dataModuleShape: QrDataModuleShape.square,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ),

              const SizedBox(height: 14),

              // Copyable UPI ID Chip
              InkWell(
                onTap: () {
                  Clipboard.setData(ClipboardData(text: _verifiedVpa));
                  Get.snackbar(
                    'UPI ID Copied ✓',
                    '$_verifiedVpa copied to clipboard',
                    backgroundColor: AppColors.tintGreen,
                    colorText: AppColors.navyText,
                    snackPosition: SnackPosition.BOTTOM,
                    margin: const EdgeInsets.all(16),
                    duration: const Duration(seconds: 2),
                  );
                },
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.primaryBlue.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('UPI ID: ', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                      Text(
                        _verifiedVpa,
                        style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: AppColors.primaryBlue),
                      ),
                      const SizedBox(width: 6),
                      const Icon(Icons.copy_rounded, size: 15, color: AppColors.primaryBlue),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),
              const Text(
                'Scan with GPay • PhonePe • Paytm • BHIM • FlamePay',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Action Row: Set Amount + Change UPI ID
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primaryBlue,
                  side: const BorderSide(color: AppColors.primaryBlue),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.currency_rupee_rounded, size: 18),
                label: Text(
                  _requestAmount.isEmpty ? 'Set Amount' : '₹$_requestAmount',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                onPressed: _openSetAmountDialog,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.navyText,
                  side: const BorderSide(color: AppColors.border),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.edit_rounded, size: 17),
                label: const Text('Change UPI', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                onPressed: () => setState(() {
                  _vpaController.text = _verifiedVpa;
                  _isEditingVpa = true;
                  _errorText = null;
                }),
              ),
            ),
          ],
        ),

        const SizedBox(height: 10),

        // Quick switch to Live Camera Scanner (Scan & Pay)
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.navyText,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 13),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            icon: const Icon(Icons.qr_code_scanner_rounded, size: 19),
            label: const Text('Scan Someone\'s QR to Pay', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5)),
            onPressed: () {
              Get.back();
              QrScannerSheet.show(context);
            },
          ),
        ),
      ],
    );
  }
}
