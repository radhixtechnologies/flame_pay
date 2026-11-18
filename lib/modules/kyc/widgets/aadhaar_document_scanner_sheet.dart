import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/theme/app_colors.dart';

class AadhaarScanData {
  final String name;
  final String aadhaarNumber;
  final String dob;
  final String gender;
  final String address;
  final String pincode;
  final String rawData;
  final bool isQrDecoded;
  final File? cardImageFile;

  const AadhaarScanData({
    required this.name,
    required this.aadhaarNumber,
    required this.dob,
    this.gender = '',
    this.address = '',
    this.pincode = '',
    this.rawData = '',
    this.isQrDecoded = true,
    this.cardImageFile,
  });
}

class AadhaarDocumentScannerSheet extends StatefulWidget {
  final Function(AadhaarScanData data) onScanned;

  const AadhaarDocumentScannerSheet({
    super.key,
    required this.onScanned,
  });

  static void show(BuildContext context, {required Function(AadhaarScanData) onScanned}) {
    Get.bottomSheet(
      AadhaarDocumentScannerSheet(onScanned: onScanned),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      ignoreSafeArea: false,
    );
  }

  /// Parses all variants of UIDAI Aadhaar QR codes:
  /// 1. UIDAI Secure QR v2 (gzip compressed byte array / BigInt)
  /// 2. UIDAI XML format (<PrintLetterBarcodeData .../>)
  /// 3. JSON encoded UIDAI format
  /// 4. Plain text / regex format
  static AadhaarScanData? parseAadhaarData(String raw, Uint8List? rawBytes, {File? cardFile}) {
    // 1. Try UIDAI Secure QR from rawBytes first
    if (rawBytes != null && rawBytes.isNotEmpty) {
      final secureData = decodeUidaiSecureQrBytes(rawBytes, cardFile: cardFile);
      if (secureData != null) {
        return secureData;
      }
    }

    // 2. Try UIDAI Secure QR from BigInt decimal string
    if (raw.length > 30) {
      final secureData = decodeUidaiBigIntString(raw, cardFile: cardFile);
      if (secureData != null) {
        return secureData;
      }
    }

    String name = '';
    String uid = '';
    String dob = '';
    String gender = '';
    String address = '';
    String pincode = '';

    // 3. UIDAI XML Format (<PrintLetterBarcodeData ... />)
    if (raw.contains('PrintLetterBarcodeData') || (raw.contains('uid=') && raw.contains('name='))) {
      uid = extractAttr(raw, 'uid');
      name = extractAttr(raw, 'name');
      dob = extractAttr(raw, 'dob');
      final yob = extractAttr(raw, 'yob');
      if (dob.isEmpty && yob.isNotEmpty) dob = '01/01/$yob';

      final g = extractAttr(raw, 'gender').toUpperCase();
      if (g == 'M' || g == 'MALE') gender = 'Male';
      else if (g == 'F' || g == 'FEMALE') gender = 'Female';
      else if (g == 'T') gender = 'Transgender';

      final co = extractAttr(raw, 'co');
      final house = extractAttr(raw, 'house');
      final street = extractAttr(raw, 'street');
      final loc = extractAttr(raw, 'loc');
      final vtc = extractAttr(raw, 'vtc');
      final dist = extractAttr(raw, 'dist');
      final state = extractAttr(raw, 'state');
      pincode = extractAttr(raw, 'pc');

      final parts = [co, house, street, loc, vtc, dist, state].where((s) => s.isNotEmpty).toList();
      address = parts.join(', ');
    } else {
      // 4. JSON Format
      try {
        if (raw.startsWith('{') && raw.endsWith('}')) {
          final map = jsonDecode(raw);
          if (map is Map) {
            name = (map['name'] ?? map['fullName'] ?? '').toString();
            uid = (map['uid'] ?? map['aadhaar'] ?? map['aadhaarNumber'] ?? '').toString();
            dob = (map['dob'] ?? map['dateOfBirth'] ?? '').toString();
            gender = (map['gender'] ?? '').toString();
            pincode = (map['pincode'] ?? map['pc'] ?? '').toString();
            address = (map['address'] ?? '').toString();
          }
        }
      } catch (_) {}

      // 5. Fallback Regex for UIDAI text QR
      if (uid.isEmpty) {
        final uidRegex = RegExp(r'\b[2-9]{1}[0-9]{3}\s?[0-9]{4}\s?[0-9]{4}\b');
        final uidMatch = uidRegex.firstMatch(raw);
        if (uidMatch != null) {
          uid = uidMatch.group(0)!.replaceAll(' ', '');
        }
      }

      if (dob.isEmpty) {
        final dobRegex = RegExp(r'\b(0[1-9]|[12][0-9]|3[01])[-/.](0[1-9]|1[012])[-/.](19|20)\d\d\b');
        final dobMatch = dobRegex.firstMatch(raw);
        if (dobMatch != null) {
          dob = dobMatch.group(0)!;
        }
      }

      if (pincode.isEmpty) {
        final pinRegex = RegExp(r'\b[1-9][0-9]{5}\b');
        final pinMatch = pinRegex.firstMatch(raw);
        if (pinMatch != null) {
          pincode = pinMatch.group(0)!;
        }
      }

      if (name.isEmpty) {
        final nameMatch = RegExp(r'(?:Name|NAME)\s*[:=]\s*([A-Za-z\s]+)').firstMatch(raw);
        if (nameMatch != null && nameMatch.groupCount >= 1) {
          name = nameMatch.group(1)!.trim();
        }
      }

      if (gender.isEmpty) {
        if (raw.contains('Male') || raw.contains('MALE')) gender = 'Male';
        else if (raw.contains('Female') || raw.contains('FEMALE')) gender = 'Female';
      }
    }

    // Format Aadhaar: 1234 5678 9012
    String formattedAadhaar = uid;
    final cleanUid = uid.replaceAll(' ', '');
    if (cleanUid.length == 12) {
      formattedAadhaar = '${cleanUid.substring(0, 4)} ${cleanUid.substring(4, 8)} ${cleanUid.substring(8, 12)}';
    }

    // If completely empty string or garbage less than 8 chars
    if (name.isEmpty && formattedAadhaar.isEmpty && raw.length < 8) {
      return null;
    }

    return AadhaarScanData(
      name: name,
      aadhaarNumber: formattedAadhaar,
      dob: dob,
      gender: gender,
      address: address,
      pincode: pincode,
      rawData: raw,
      isQrDecoded: true,
      cardImageFile: cardFile,
    );
  }

  /// Decodes UIDAI Secure QR v2 compressed bytes
  static AadhaarScanData? decodeUidaiSecureQrBytes(List<int> bytes, {File? cardFile}) {
    try {
      var clean = bytes;
      while (clean.isNotEmpty && clean[0] == 0) {
        clean = clean.sublist(1);
      }
      if (clean.isEmpty) return null;

      List<int> decompressed;
      int gzipIdx = -1;
      for (int i = 0; i < clean.length - 1; i++) {
        if (clean[i] == 0x1f && clean[i + 1] == 0x8b) {
          gzipIdx = i;
          break;
        }
      }

      if (gzipIdx >= 0) {
        decompressed = gzip.decode(clean.sublist(gzipIdx));
      } else {
        try {
          decompressed = zlib.decode(clean);
        } catch (_) {
          decompressed = clean;
        }
      }

      // UIDAI Secure QR fields are separated by 255 (0xFF)
      final fields = <String>[];
      final currentField = <int>[];
      for (int i = 0; i < decompressed.length; i++) {
        final b = decompressed[i];
        if (b == 255) {
          fields.add(utf8.decode(currentField, allowMalformed: true));
          currentField.clear();
          if (fields.length >= 16) break; // Remaining bytes are photo and signature
        } else {
          currentField.add(b);
        }
      }

      if (fields.length >= 3) {
        final refId = fields.length > 1 ? fields[1] : '';
        final name = fields.length > 2 ? fields[2].trim() : '';
        final dob = fields.length > 3 ? fields[3].trim() : '';
        var gender = fields.length > 4 ? fields[4].trim() : '';
        if (gender == 'M') gender = 'Male';
        if (gender == 'F') gender = 'Female';
        if (gender == 'T') gender = 'Transgender';

        final co = fields.length > 5 ? fields[5].trim() : '';
        final dist = fields.length > 6 ? fields[6].trim() : '';
        final landmark = fields.length > 7 ? fields[7].trim() : '';
        final house = fields.length > 8 ? fields[8].trim() : '';
        final loc = fields.length > 9 ? fields[9].trim() : '';
        final pincode = fields.length > 10 ? fields[10].trim() : '';
        final po = fields.length > 11 ? fields[11].trim() : '';
        final state = fields.length > 12 ? fields[12].trim() : '';
        final street = fields.length > 13 ? fields[13].trim() : '';
        final subdist = fields.length > 14 ? fields[14].trim() : '';
        final vtc = fields.length > 15 ? fields[15].trim() : '';

        final addrParts = [co, house, street, landmark, loc, vtc, po, subdist, dist, state, pincode]
            .where((s) => s.isNotEmpty)
            .toList();

        String formattedUid = '';
        if (refId.length >= 4) {
          final last4 = refId.substring(0, 4);
          formattedUid = 'XXXX XXXX $last4';
        }

        return AadhaarScanData(
          name: name,
          aadhaarNumber: formattedUid,
          dob: dob,
          gender: gender,
          address: addrParts.join(', '),
          pincode: pincode,
          rawData: 'UIDAI_SECURE_QR_V2',
          isQrDecoded: true,
          cardImageFile: cardFile,
        );
      }
    } catch (_) {}
    return null;
  }

  /// Converts BigInt decimal string to bytes and decodes Secure QR
  static AadhaarScanData? decodeUidaiBigIntString(String raw, {File? cardFile}) {
    try {
      final cleanDigits = raw.replaceAll(RegExp(r'\s+'), '');
      if (cleanDigits.length < 30 || !RegExp(r'^\d+$').hasMatch(cleanDigits)) return null;

      final bigInt = BigInt.parse(cleanDigits);
      var hex = bigInt.toRadixString(16);
      if (hex.length % 2 != 0) hex = '0$hex';
      final len = hex.length ~/ 2;
      final bytes = Uint8List(len);
      for (int i = 0; i < len; i++) {
        bytes[i] = int.parse(hex.substring(i * 2, i * 2 + 2), radix: 16);
      }
      return decodeUidaiSecureQrBytes(bytes, cardFile: cardFile);
    } catch (_) {
      return null;
    }
  }

  static String extractAttr(String raw, String attr) {
    final regex = RegExp('$attr="([^"]*)"', caseSensitive: false);
    final match = regex.firstMatch(raw);
    if (match != null && match.groupCount >= 1) {
      return match.group(1)?.trim() ?? '';
    }
    final regexSingle = RegExp("$attr='([^']*)'", caseSensitive: false);
    final matchSingle = regexSingle.firstMatch(raw);
    if (matchSingle != null && matchSingle.groupCount >= 1) {
      return matchSingle.group(1)?.trim() ?? '';
    }
    return '';
  }

  @override
  State<AadhaarDocumentScannerSheet> createState() => _AadhaarDocumentScannerSheetState();
}

class _AadhaarDocumentScannerSheetState extends State<AadhaarDocumentScannerSheet>
    with SingleTickerProviderStateMixin {
  late final MobileScannerController _scannerController;
  late final AnimationController _animController;
  late final Animation<double> _scanAnimation;

  bool _hasDetected = false;
  bool _torchEnabled = false;
  bool _isAnalyzing = false;

  @override
  void initState() {
    super.initState();
    _scannerController = MobileScannerController(
      detectionSpeed: DetectionSpeed.normal,
      facing: CameraFacing.back,
      torchEnabled: false,
    );

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    _scanAnimation = Tween<double>(begin: 0.1, end: 0.9).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    _scannerController.stop();
    _scannerController.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_hasDetected) return;
    final barcodes = capture.barcodes;
    for (final barcode in barcodes) {
      final rawValue = barcode.rawValue;
      final Uint8List? rawBytes = barcode.rawBytes;

      if ((rawValue != null && rawValue.trim().isNotEmpty) || (rawBytes != null && rawBytes.isNotEmpty)) {
        final parsed = AadhaarDocumentScannerSheet.parseAadhaarData(rawValue?.trim() ?? '', rawBytes);
        if (parsed != null) {
          _hasDetected = true;
          _scannerController.stop();
          Get.back(); // close camera sheet
          widget.onScanned(parsed);
          break;
        }
      }
    }
  }

  Future<void> _pickImageAndScan() async {
    if (_isAnalyzing) return;
    setState(() => _isAnalyzing = true);
    try {
      final picker = ImagePicker();
      final XFile? picked = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1600,
        maxHeight: 1600,
        imageQuality: 92,
      );
      if (picked != null) {
        final file = File(picked.path);
        BarcodeCapture? capture;
        try {
          capture = await _scannerController.analyzeImage(picked.path);
        } catch (_) {}

        if (capture != null && capture.barcodes.isNotEmpty) {
          for (final barcode in capture.barcodes) {
            final rawValue = barcode.rawValue;
            final Uint8List? rawBytes = barcode.rawBytes;
            if ((rawValue != null && rawValue.trim().isNotEmpty) || (rawBytes != null && rawBytes.isNotEmpty)) {
              final parsed = AadhaarDocumentScannerSheet.parseAadhaarData(rawValue?.trim() ?? '', rawBytes, cardFile: file);
              if (parsed != null) {
                _hasDetected = true;
                _scannerController.stop();
                Get.back();
                widget.onScanned(parsed);
                return;
              }
            }
          }
        }

        // Failsafe: When an Aadhaar card image is picked from gallery,
        // attach the real card photo so user can verify & autofill details immediately
        final curUser = Get.find<AuthService>().currentUser.value;
        final name = (curUser != null && curUser.name.isNotEmpty && curUser.name != 'User') ? curUser.name : '';
        final aadhaar = (curUser != null && curUser.aadhaar != null && curUser.aadhaar!.isNotEmpty) ? curUser.aadhaar! : '';

        final scanResult = AadhaarScanData(
          name: name,
          aadhaarNumber: aadhaar,
          dob: '',
          gender: '',
          address: '',
          pincode: '',
          rawData: 'ATTACHED_IMAGE_${picked.name}',
          isQrDecoded: false,
          cardImageFile: file,
        );

        _hasDetected = true;
        _scannerController.stop();
        Get.back();
        widget.onScanned(scanResult);
      }
    } catch (e) {
      Get.snackbar('Notice', 'Could not open image: $e', colorText: Colors.white);
    } finally {
      if (mounted) setState(() => _isAnalyzing = false);
    }
  }



  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return Container(
      height: size.height * 0.90,
      decoration: const BoxDecoration(
        color: Color(0xFF0F172A),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
      ),
      child: Column(
        children: [
          // Drag Handle
          const SizedBox(height: 12),
          Container(
            width: 44,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 14),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primaryBlue.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.qr_code_scanner_rounded, color: AppColors.accentOrange, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Aadhaar QR Scanner',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16.5,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Point camera at physical Aadhaar QR',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                IconButton(
                  onPressed: () => Get.back(),
                  icon: const Icon(Icons.close_rounded, color: Colors.white70),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // Camera Viewfinder Box
          Expanded(
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Live Camera Stream
                Positioned.fill(
                  child: MobileScanner(
                    controller: _scannerController,
                    onDetect: _onDetect,
                  ),
                ),

                // Dark Overlay with Cutout Viewfinder
                Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.45),
                  ),
                ),

                // Viewfinder Target Frame
                Center(
                  child: Container(
                    width: size.width * 0.78,
                    height: size.width * 0.78,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.accentOrange,
                        width: 2.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.accentOrange.withValues(alpha: 0.25),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        // Corner Guides
                        Positioned(
                          top: -2,
                          left: -2,
                          child: Container(
                            width: 24,
                            height: 24,
                            decoration: const BoxDecoration(
                              border: Border(
                                top: BorderSide(color: Colors.white, width: 4),
                                left: BorderSide(color: Colors.white, width: 4),
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          top: -2,
                          right: -2,
                          child: Container(
                            width: 24,
                            height: 24,
                            decoration: const BoxDecoration(
                              border: Border(
                                top: BorderSide(color: Colors.white, width: 4),
                                right: BorderSide(color: Colors.white, width: 4),
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: -2,
                          left: -2,
                          child: Container(
                            width: 24,
                            height: 24,
                            decoration: const BoxDecoration(
                              border: Border(
                                bottom: BorderSide(color: Colors.white, width: 4),
                                left: BorderSide(color: Colors.white, width: 4),
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: -2,
                          right: -2,
                          child: Container(
                            width: 24,
                            height: 24,
                            decoration: const BoxDecoration(
                              border: Border(
                                bottom: BorderSide(color: Colors.white, width: 4),
                                right: BorderSide(color: Colors.white, width: 4),
                              ),
                            ),
                          ),
                        ),

                        // Animated Laser Scan Line
                        AnimatedBuilder(
                          animation: _scanAnimation,
                          builder: (context, child) {
                            return Align(
                              alignment: Alignment(0, (_scanAnimation.value * 2) - 1),
                              child: Container(
                                width: double.infinity,
                                height: 3,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Colors.transparent,
                                      AppColors.accentOrange,
                                      Colors.white,
                                      AppColors.accentOrange,
                                      Colors.transparent,
                                    ],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.accentOrange.withValues(alpha: 0.8),
                                      blurRadius: 8,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                // Instruction Pill
                Positioned(
                  bottom: 24,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.black87,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.crop_free_rounded, color: AppColors.accentOrange, size: 16),
                        SizedBox(width: 8),
                        Text(
                          'Hold card steady inside target box',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Controls (Torch & Camera Switch)
                Positioned(
                  top: 16,
                  right: 20,
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.black54,
                        radius: 20,
                        child: IconButton(
                          icon: Icon(
                            _torchEnabled ? Icons.flash_on_rounded : Icons.flash_off_rounded,
                            color: _torchEnabled ? Colors.amber : Colors.white,
                            size: 18,
                          ),
                          onPressed: () {
                            setState(() {
                              _torchEnabled = !_torchEnabled;
                            });
                            _scannerController.toggleTorch();
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      CircleAvatar(
                        backgroundColor: Colors.black54,
                        radius: 20,
                        child: IconButton(
                          icon: const Icon(Icons.flip_camera_ios_rounded, color: Colors.white, size: 18),
                          onPressed: () => _scannerController.switchCamera(),
                        ),
                      ),
                    ],
                  ),
                ),

                if (_isAnalyzing)
                  Container(
                    color: Colors.black54,
                    child: const Center(
                      child: CircularProgressIndicator(color: AppColors.accentOrange),
                    ),
                  ),
              ],
            ),
          ),

          // Bottom Action Bar: Gallery Option + Live Auto-Scan Indicator
          Container(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
            decoration: const BoxDecoration(
              color: Color(0xFF1E293B),
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white30),
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: const Icon(Icons.photo_library_rounded, color: Colors.white, size: 18),
                    label: const Text(
                      'From Gallery',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    onPressed: _pickImageAndScan,
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.black38,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.success.withValues(alpha: 0.35)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 9,
                        height: 9,
                        decoration: const BoxDecoration(
                          color: AppColors.success,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Live Auto-Scan',
                        style: TextStyle(
                          color: AppColors.success,
                          fontWeight: FontWeight.bold,
                          fontSize: 12.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
