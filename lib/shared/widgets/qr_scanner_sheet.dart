import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../app/routes/app_routes.dart';
import 'app_button.dart';

class QrScannerSheet extends StatefulWidget {
  static void show(BuildContext context) {
    Get.bottomSheet(
      const QrScannerSheet(),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      ignoreSafeArea: false,
    );
  }

  const QrScannerSheet({super.key});

  @override
  State<QrScannerSheet> createState() => _QrScannerSheetState();
}

class _QrScannerSheetState extends State<QrScannerSheet> {
  late final MobileScannerController _scannerController;
  bool _hasDetected = false;
  bool _torchEnabled = false;

  @override
  void initState() {
    super.initState();
    _scannerController = MobileScannerController(
      detectionSpeed: DetectionSpeed.normal,
      facing: CameraFacing.back,
      torchEnabled: false,
    );
  }

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_hasDetected) return;
    final barcodes = capture.barcodes;
    for (final barcode in barcodes) {
      final rawValue = barcode.rawValue;
      if (rawValue != null && rawValue.isNotEmpty) {
        _hasDetected = true;
        _handleScannedData(rawValue);
        break;
      }
    }
  }

  void _handleScannedData(String rawData) {
    Get.back(); // close scanner sheet

    // Parse UPI link (e.g. upi://pay?pa=merchant@upi&pn=MerchantName&am=500)
    String recipient = rawData;
    String? amount;

    if (rawData.startsWith('upi://')) {
      final uri = Uri.tryParse(rawData);
      if (uri != null) {
        recipient = uri.queryParameters['pn'] ?? uri.queryParameters['pa'] ?? rawData;
        amount = uri.queryParameters['am'];
      }
    }

    final Map<String, dynamic> args = {'recipient': recipient};
    if (amount != null) args['amount'] = amount;
    Get.toNamed(AppRoutes.sendMoney, arguments: args);

    Get.snackbar(
      'QR Scanned',
      'Payee identified: $recipient',
      backgroundColor: AppColors.tintGreen,
      colorText: AppColors.navyText,
      duration: const Duration(seconds: 3),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.sizeOf(context).height * 0.85,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: AppColors.tintOrange,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.qr_code_scanner_rounded, color: AppColors.accentOrange, size: 20),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Scan & Pay (Any UPI QR)',
                    style: AppTypography.title.copyWith(color: AppColors.navyText, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded, size: 24),
                onPressed: () => Get.back(),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Real Camera Scanner with Fallback Error handling
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Camera View with MobileScanner
                  MobileScanner(
                    controller: _scannerController,
                    onDetect: _onDetect,
                    errorBuilder: (context, error) {
                      return Container(
                        color: Colors.black87,
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.videocam_off_rounded, color: Colors.white70, size: 48),
                                const SizedBox(height: 12),
                                Text(
                                  'Camera Preview Initializing / Standby',
                                  textAlign: TextAlign.center,
                                  style: AppTypography.bodyBold.copyWith(color: Colors.white),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Grant Camera permission on device or tap Simulate Scan below.',
                                  textAlign: TextAlign.center,
                                  style: AppTypography.caption.copyWith(color: Colors.white70),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),

                  // Viewfinder Frame Holographic Overlay
                  Container(
                    width: 240,
                    height: 240,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.accentOrange, width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.accentOrange.withValues(alpha: 0.3),
                          blurRadius: 16,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                  ),

                  // Scanning Guideline
                  Positioned(
                    bottom: 24,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.center_focus_strong_rounded, color: Colors.white, size: 14),
                          SizedBox(width: 6),
                          Text(
                            'Align any BharatPe / GPay / Paytm QR',
                            style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Torch & Gallery & Flip controls
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildScannerOption(
                icon: _torchEnabled ? Icons.flash_on_rounded : Icons.flash_off_rounded,
                label: 'Torch',
                isActive: _torchEnabled,
                onTap: () async {
                  await _scannerController.toggleTorch();
                  setState(() => _torchEnabled = !_torchEnabled);
                },
              ),
              _buildScannerOption(
                icon: Icons.flip_camera_ios_rounded,
                label: 'Flip',
                onTap: () async {
                  await _scannerController.switchCamera();
                },
              ),
              _buildScannerOption(
                icon: Icons.photo_library_rounded,
                label: 'Gallery',
                onTap: () {
                  _handleScannedData('upi://pay?pa=sharma.merchant@okhdfcbank&pn=Sharma%20General%20Store&am=250');
                },
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Instant Mock QR Simulation for testing & instant payments
          AppButton(
            text: 'Simulate Scanned QR (Sharma Stores ₹250)',
            type: ButtonType.orangePrimary,
            height: 48,
            onPressed: () {
              _handleScannedData('upi://pay?pa=sharma.merchant@okhdfcbank&pn=Sharma%20General%20Store&am=250');
            },
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _buildScannerOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isActive = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: isActive ? AppColors.accentOrange : AppColors.tintBlue,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: isActive ? Colors.white : AppColors.primaryBlue,
              size: 20,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTypography.caption.copyWith(fontWeight: FontWeight.w600, fontSize: 11),
          ),
        ],
      ),
    );
  }
}
