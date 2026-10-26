import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'app/bindings/initial_binding.dart';
import 'app/routes/app_pages.dart';
import 'core/services/storage_service.dart';
import 'core/services/connectivity_service.dart';
import 'core/services/auth_service.dart';
import 'core/theme/app_theme.dart';
import 'core/config/app_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock orientation to portrait for optimal fintech UI
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  // Initialize Global Permanent Services
  final storageService = await StorageService().init();
  Get.put<StorageService>(storageService, permanent: true);

  final connectivityService = await ConnectivityService().init();
  Get.put<ConnectivityService>(connectivityService, permanent: true);

  final authService = await AuthService().init();
  Get.put<AuthService>(authService, permanent: true);

  runApp(const FlamePayApp());
}

class FlamePayApp extends StatelessWidget {
  final String? initialRoute;
  const FlamePayApp({super.key, this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: AppConfig.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialBinding: InitialBinding(),
      initialRoute: initialRoute ?? AppPages.initial,
      getPages: AppPages.pages,
      builder: (context, child) {
        // Clamp text scale factor between 0.9 and 1.2 to survive extreme OS font settings
        final mediaQuery = MediaQuery.of(context);
        final clampedScale = mediaQuery.textScaler.clamp(
          minScaleFactor: 0.9,
          maxScaleFactor: 1.2,
        );

        return MediaQuery(
          data: mediaQuery.copyWith(textScaler: clampedScale),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}
