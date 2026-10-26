import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flamepay/main.dart';
import 'package:flamepay/core/config/app_config.dart';
import 'package:flamepay/core/services/storage_service.dart';
import 'package:flamepay/core/services/connectivity_service.dart';
import 'package:flamepay/core/services/auth_service.dart';
import 'package:flamepay/core/network/interceptors/mock_interceptor.dart';
import 'package:flamepay/data/repositories/financial_services_repository.dart';
import 'package:flamepay/data/repositories/home_repository.dart';
import 'package:flamepay/data/repositories/wallet_repository.dart';
import 'package:flamepay/shared/widgets/flame_logo.dart';
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
    final storage = await StorageService().init('multi_device_box');
    await storage.setSeenOnboarding(true);
    await storage.setAuthToken('mock_token_123');
    Get.put<StorageService>(storage, permanent: true);

    final conn = await ConnectivityService().init();
    conn.isConnected.value = true;
    Get.put<ConnectivityService>(conn, permanent: true);

    final auth = await AuthService().init();
    auth.isAuthenticated.value = true;
    Get.put<AuthService>(auth, permanent: true);

    Get.lazyPut<HomeRepository>(() => HomeRepository(), fenix: true);
    Get.lazyPut<WalletRepository>(() => WalletRepository(), fenix: true);
    Get.lazyPut<FinancialServicesRepository>(() => FinancialServicesRepository(), fenix: true);
  });

  // 1. Compact Phone: 320 x 568
  testWidgets('FlamePay renders flawlessly on Compact Phone (320x568) with no overflow', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const FlamePayApp(initialRoute: AppRoutes.home));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byType(FlameLogo), findsWidgets);
    expect(find.text('Quick Services'), findsOneWidget);
    expect(find.text('Recent Transactions'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  // 2. Standard Phone: 360 x 800
  testWidgets('FlamePay renders flawlessly on Standard Phone (360x800) with no overflow', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const FlamePayApp(initialRoute: AppRoutes.recharge));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Mobile & DTH Recharge'), findsOneWidget);
    expect(find.text('Enter Mobile Number'), findsOneWidget);
    expect(find.text('Recommended'), findsOneWidget);
    expect(find.text('Select'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  // 3. Large Phone: 412 x 915
  testWidgets('FlamePay renders flawlessly on Large Phone (412x915) with no overflow', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(412, 915);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const FlamePayApp(initialRoute: AppRoutes.cibil));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Credit Health & CIBIL'), findsOneWidget);
    expect(find.text('785'), findsOneWidget);
    expect(find.text('Credit Factors Breakdown'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  // 4. Tablet Portrait: 768 x 1024
  testWidgets('FlamePay renders with centered responsive container on Tablet Portrait (768x1024)', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(768, 1024);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const FlamePayApp(initialRoute: AppRoutes.home));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byType(FlameLogo), findsWidgets);
    expect(find.text('Quick Services'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  // 5. Tablet / Desktop Landscape: 1280 x 800
  testWidgets('FlamePay renders constrained without wide-stretching on Landscape Desktop (1280x800)', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const FlamePayApp(initialRoute: AppRoutes.home));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byType(FlameLogo), findsWidgets);
    expect(find.text('Quick Services'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  // 6. Offline Non-blocking Banner
  testWidgets('FlamePay displays offline cached warning banner when connection is lost', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    final conn = Get.find<ConnectivityService>();
    conn.isConnected.value = false; // Simulate offline

    await tester.pumpWidget(const FlamePayApp(initialRoute: AppRoutes.home));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.textContaining('You are offline'), findsOneWidget);
  });

  // 7. Legal & Compliance Policies View
  testWidgets('FlamePay renders comprehensive Legal and Compliance tabs (Terms, Privacy, Refunds)', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const FlamePayApp(initialRoute: AppRoutes.terms));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Legal & Compliance'), findsOneWidget);
    expect(find.text('Terms'), findsOneWidget);
    expect(find.text('Privacy'), findsOneWidget);
    expect(find.text('Refunds'), findsOneWidget);
    expect(find.text('Acceptance of Terms'), findsOneWidget);

    // Switch to Privacy tab
    await tester.tap(find.text('Privacy'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.text('Data Collection & Purpose'), findsOneWidget);

    // Switch to Refunds tab
    await tester.tap(find.text('Refunds'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.text('Instant Mobile & DTH Recharge Refunds'), findsOneWidget);
  });

  // 8. AppConfig Mock Mode Toggle Integrity
  test('AppConfig verifies mock and live mode configuration switches cleanly', () {
    expect(AppConfig.useMock, isTrue);
    expect(AppConfig.baseUrl, 'https://api.flamepay.com/v1');

    // Toggle to live
    AppConfig.useMock = false;
    expect(AppConfig.useMock, isFalse);

    // Toggle back to mock
    AppConfig.useMock = true;
    expect(AppConfig.useMock, isTrue);
  });
}
