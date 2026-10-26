import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flamepay/main.dart';
import 'package:flamepay/core/services/storage_service.dart';
import 'package:flamepay/core/services/connectivity_service.dart';
import 'package:flamepay/core/services/auth_service.dart';
import 'package:flamepay/core/network/interceptors/mock_interceptor.dart';
import 'package:flamepay/shared/widgets/flame_logo.dart';
import 'package:flamepay/shared/widgets/promo_banner.dart';
import 'package:flamepay/data/repositories/home_repository.dart';
import 'package:flamepay/data/repositories/wallet_repository.dart';
import 'package:flamepay/app/routes/app_routes.dart';
import 'package:get/get.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    MockInterceptor.enableDelay = false;

    final messenger = TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

    messenger.setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/path_provider'),
      (MethodCall methodCall) async => '.',
    );

    messenger.setMockMethodCallHandler(
      const MethodChannel('dev.fluttercommunity.plus/connectivity'),
      (MethodCall methodCall) async => ['wifi'],
    );

    messenger.setMockMethodCallHandler(
      const MethodChannel('plugins.it_nomads.com/flutter_secure_storage'),
      (MethodCall methodCall) async => null,
    );
  });

  setUp(() async {
    Get.reset();
    final storage = await StorageService().init('phase2_test_box');
    await storage.setSeenOnboarding(true);
    await storage.setAuthToken('mock_token_123');
    Get.put<StorageService>(storage, permanent: true);

    final conn = await ConnectivityService().init();
    Get.put<ConnectivityService>(conn, permanent: true);

    final auth = await AuthService().init();
    auth.isAuthenticated.value = true;
    Get.put<AuthService>(auth, permanent: true);

    Get.lazyPut<HomeRepository>(() => HomeRepository());
    Get.lazyPut<WalletRepository>(() => WalletRepository());
  });

  testWidgets('FlamePay Home Screen renders wallet card and quick services', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const FlamePayApp(initialRoute: AppRoutes.home));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byType(FlameLogo), findsWidgets);
    expect(find.textContaining('Balance'), findsOneWidget);
    expect(find.text('Add Money'), findsWidgets);
    expect(find.text('Hello,'), findsOneWidget);

    expect(find.text('Quick Services'), findsOneWidget);
    expect(find.byType(PromoBanner), findsOneWidget);
    expect(find.text('Recent Transactions'), findsOneWidget);
  });

  testWidgets('FlamePay All Services screen renders with search bar', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const FlamePayApp(initialRoute: AppRoutes.allServices));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('All Services'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
    expect(find.text('Recharge & Bill Payments'), findsOneWidget);
    expect(find.text('Financial Services'), findsOneWidget);
    expect(find.text('Insurance'), findsOneWidget);
  });

  testWidgets('FlamePay Wallet screen renders balance, actions, and history', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const FlamePayApp(initialRoute: AppRoutes.wallet));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('FlamePay Wallet'), findsOneWidget);
    expect(find.text('Available Balance'), findsOneWidget);
    expect(find.text('Active'), findsOneWidget);
    expect(find.text('Add Money'), findsWidgets);
    expect(find.text('Wallet History'), findsOneWidget);
  });
}
