import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/services/storage_service.dart';
import '../../core/services/auth_service.dart';
import 'app_routes.dart';

class AuthMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    if (!Get.isRegistered<StorageService>()) return null;
    final storage = Get.find<StorageService>();

    // If first launch, show onboarding
    if (!storage.hasSeenOnboarding()) {
      if (route != AppRoutes.onboarding && route != AppRoutes.splash) {
        return const RouteSettings(name: AppRoutes.onboarding);
      }
      return null;
    }

    // Check authentication
    if (Get.isRegistered<AuthService>()) {
      final auth = Get.find<AuthService>();
      if (!auth.isAuthenticated.value) {
        final publicRoutes = [
          AppRoutes.splash,
          AppRoutes.onboarding,
          AppRoutes.login,
          AppRoutes.otp,
          AppRoutes.registration,
          AppRoutes.terms,
          AppRoutes.privacy,
        ];
        if (!publicRoutes.contains(route)) {
          return const RouteSettings(name: AppRoutes.login);
        }
      }
    }
    return null;
  }
}
