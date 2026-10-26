import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flamepay/main.dart';
import 'package:flamepay/core/services/storage_service.dart';
import 'package:flamepay/core/services/connectivity_service.dart';
import 'package:flamepay/core/services/auth_service.dart';
import 'package:flamepay/core/network/interceptors/mock_interceptor.dart';
import 'package:flamepay/data/repositories/financial_services_repository.dart';
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
    final storage = await StorageService().init('phase4_test_box');
    await storage.setSeenOnboarding(true);
    await storage.setAuthToken('mock_token_123');
    Get.put<StorageService>(storage, permanent: true);

    final conn = await ConnectivityService().init();
    Get.put<ConnectivityService>(conn, permanent: true);

    final auth = await AuthService().init();
    auth.isAuthenticated.value = true;
    Get.put<AuthService>(auth, permanent: true);

    Get.lazyPut<FinancialServicesRepository>(() => FinancialServicesRepository());
  });

  testWidgets('FlamePay CIBIL Screen renders score meter and factors', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const FlamePayApp(initialRoute: AppRoutes.cibil));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Credit Health & CIBIL'), findsOneWidget);
    expect(find.text('785'), findsOneWidget);
    expect(find.text('EXCELLENT'), findsOneWidget);
    expect(find.text('Credit Factors Breakdown'), findsOneWidget);
    expect(find.text('Payment History'), findsOneWidget);
    expect(find.text('Credit Utilization'), findsOneWidget);
    expect(find.text('Download Official CIBIL Report'), findsOneWidget);
  });

  testWidgets('FlamePay Credit Cards Screen renders filter chips and card items', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const FlamePayApp(initialRoute: AppRoutes.creditCard));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Credit Cards'), findsOneWidget);
    expect(find.text('All'), findsOneWidget);
    expect(find.text('Cashback'), findsOneWidget);
    expect(find.text('Rewards'), findsOneWidget);

    expect(find.text('Millennia Credit Card'), findsOneWidget);
    expect(find.text('HDFC Bank'), findsOneWidget);
    expect(find.textContaining('Apply Now'), findsWidgets);
  });

  testWidgets('FlamePay Loan Screen renders calculator and handles amount changes', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const FlamePayApp(initialRoute: AppRoutes.loan));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Instant Personal Loan'), findsOneWidget);
    expect(find.text('Loan Amount'), findsOneWidget);
    expect(find.text('Repayment Tenure'), findsOneWidget);
    expect(find.text('Monthly EMI'), findsOneWidget);
    expect(find.text('Why Choose FlamePay Loan?'), findsOneWidget);
    expect(find.textContaining('Apply for'), findsOneWidget);
  });

  testWidgets('FlamePay Insurance Screen renders category tabs and plan cards', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const FlamePayApp(initialRoute: AppRoutes.insurance));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Insurance Plans'), findsOneWidget);
    expect(find.text('Health'), findsOneWidget);
    expect(find.text('Term Life'), findsOneWidget);
    expect(find.text('Motor (Car/Bike)'), findsOneWidget);
    expect(find.text('Travel'), findsOneWidget);

    expect(find.text('Care Supreme Health Shield'), findsOneWidget);
    expect(find.text('Care Health Insurance'), findsOneWidget);
    expect(find.textContaining('Buy Policy'), findsWidgets);
  });
}
