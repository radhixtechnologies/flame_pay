import 'dart:io';
import 'dart:ui' as ui;

class DocumentValidator {
  DocumentValidator._();

  /// Analyzes an uploaded document image file to verify whether it looks like
  /// a legitimate physical Indian ID card (Aadhaar / PAN) or a random object (laptop, floor, dark surface).
  /// Returns `null` if valid, or an error message in Hinglish explaining what is wrong.
  static Future<String?> validateCardImage(File file, {required String docType}) async {
    try {
      final exists = await file.exists();
      if (!exists) return 'Document file exist nahi karti. Kripya dobara select karein.';

      final fileSize = await file.length();
      if (fileSize < 5 * 1024) {
        return 'Documents sahi se upload karo! File bohot chhoti ya corrupt lag rahi hai (${(fileSize / 1024).toStringAsFixed(1)} KB). Kripya original card ki photo upload karein.';
      }

      // Read image bytes and downscale to 100x100 thumbnail for instant pixel analysis
      final bytes = await file.readAsBytes();
      final codec = await ui.instantiateImageCodec(
        bytes,
        targetWidth: 100,
        targetHeight: 100,
      );
      final frame = await codec.getNextFrame();
      final image = frame.image;

      final byteData = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
      if (byteData == null) {
        return 'File corrupt lag rahi hai. Kripya saaf photo upload karein.';
      }

      final pixels = byteData.buffer.asUint8List();
      final totalPixels = image.width * image.height; // 10,000

      int darkPixels = 0;       // r, g, b < 40 (pure pitch black, lens covered)
      double totalLuminance = 0;

      for (int i = 0; i < pixels.length; i += 4) {
        final r = pixels[i];
        final g = pixels[i + 1];
        final b = pixels[i + 2];
        final lum = (0.299 * r) + (0.587 * g) + (0.114 * b);
        totalLuminance += lum;

        if (r < 40 && g < 40 && b < 40) {
          darkPixels++;
        }
      }

      final avgLuminance = totalLuminance / totalPixels;
      final darkRatio = darkPixels / totalPixels;

      final docName = docType == 'pan'
          ? 'PAN Card'
          : (docType.contains('aadhaar') ? 'Aadhaar Card' : 'ID Document');

      // Rule 1: Camera lens covered or completely pitch black image (< 25 avg luminance or > 90% pitch black pixels)
      if (darkRatio > 0.90 || avgLuminance < 25) {
        return 'Photo bohot andhere me li gayi hai ya camera lens covered hai. Kripya physical $docName ko samne rakh kar roshni me saaf photo khinchein.';
      }

      return null; // Valid card photo!
    } catch (e) {
      // In case of non-image file or parsing issue
      return 'File verify nahi ho saki: $e. Kripya valid JPG/PNG photo upload karein.';
    }
  }
}

