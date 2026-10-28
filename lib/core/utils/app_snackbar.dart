import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../theme/app_colors.dart';
import '../network/api_exception.dart';

class AppSnackbar {
  AppSnackbar._();

  /// Displays an error snackbar with clear API/validation details.
  static void showError(dynamic error, {String title = 'Error'}) {
    String message = 'An unexpected error occurred';

    if (error is ApiException) {
      message = error.message;
    } else if (error is String) {
      message = error;
    } else if (error != null) {
      message = error.toString();
    }

    // Clean common prefixes
    if (message.startsWith('Exception: ')) {
      message = message.substring(11).trim();
    }

    if (Get.isSnackbarOpen) {
      Get.closeCurrentSnackbar();
    }

    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: AppColors.error,
      colorText: Colors.white,
      icon: const Icon(Icons.error_outline_rounded, color: Colors.white, size: 26),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      borderRadius: 12,
      duration: const Duration(seconds: 4),
      isDismissible: true,
      forwardAnimationCurve: Curves.easeOutBack,
      boxShadows: [
        BoxShadow(
          color: AppColors.error.withValues(alpha: 0.3),
          blurRadius: 16,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  /// Displays a success snackbar.
  static void showSuccess(String message, {String title = 'Success'}) {
    if (Get.isSnackbarOpen) {
      Get.closeCurrentSnackbar();
    }

    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: AppColors.success,
      colorText: Colors.white,
      icon: const Icon(Icons.check_circle_outline_rounded, color: Colors.white, size: 26),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      borderRadius: 12,
      duration: const Duration(seconds: 3),
      isDismissible: true,
      forwardAnimationCurve: Curves.easeOutBack,
      boxShadows: [
        BoxShadow(
          color: AppColors.success.withValues(alpha: 0.25),
          blurRadius: 16,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  /// Displays an informational or validation warning snackbar.
  static void showWarning(String message, {String title = 'Validation'}) {
    if (Get.isSnackbarOpen) {
      Get.closeCurrentSnackbar();
    }

    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: AppColors.warning,
      colorText: Colors.white,
      icon: const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 26),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      borderRadius: 12,
      duration: const Duration(seconds: 3),
      isDismissible: true,
      forwardAnimationCurve: Curves.easeOutBack,
      boxShadows: [
        BoxShadow(
          color: AppColors.warning.withValues(alpha: 0.25),
          blurRadius: 16,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }
}
