import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flamepay/main.dart';
import 'package:flamepay/core/services/storage_service.dart';
import 'package:flamepay/core/services/connectivity_service.dart';
import 'package:flamepay/core/services/auth_service.dart';
import 'package:flamepay/core/network/interceptors/mock_interceptor.dart';
import 'package:flamepay/data/repositories/recharge_repository.dart';
import 'package:flamepay/data/models/payment_result_model.dart';
import 'package:flamepay/shared/widgets/payment_success_view.dart';
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
    final storage = await StorageService().init('phase3_test_box');
    await storage.setSeenOnboarding(true);
    await storage.setAuthToken('mock_token_123');
    Get.put<StorageService>(storage, permanent: true);

    final conn = await ConnectivityService().init();
    Get.put<ConnectivityService>(conn, permanent: true);

    final auth = await AuthService().init();
    auth.isAuthenticated.value = true;
    Get.put<AuthService>(auth, permanent: true);

    Get.lazyPut<RechargeRepository>(() => RechargeRepository());
  });

  testWidgets('FlamePay RechargeView renders tabs, mobile input, operator and plans', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const FlamePayApp(initialRoute: AppRoutes.recharge));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    // Verify Title & Tabs
    expect(find.text('Mobile & DTH Recharge'), findsOneWidget);
    expect(find.text('Mobile Recharge'), findsOneWidget);
    expect(find.text('DTH Recharge'), findsOneWidget);

    // Verify Mobile input
    expect(find.text('Enter Mobile Number'), findsOneWidget);
    expect(find.text('+91'), findsOneWidget);
    expect(find.text('Jio Prepaid'), findsOneWidget);
    expect(find.text('Delhi NCR'), findsOneWidget);

    // Verify Plan Categories
    expect(find.text('Recommended'), findsOneWidget);
    expect(find.text('Popular'), findsOneWidget);
    expect(find.text('Truly Unlimited'), findsOneWidget);

    // Verify Plan Cards rendered
    expect(find.text('₹299.00'), findsOneWidget);
    expect(find.text('1.5 GB/Day'), findsWidgets);
    expect(find.text('Select'), findsWidgets);
  });

  testWidgets('FlamePay BillPaymentView renders category chips, biller and fetches bill', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const FlamePayApp(initialRoute: AppRoutes.billPayment));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Pay Utility Bills'), findsOneWidget);
    expect(find.text('Electricity'), findsOneWidget);
    expect(find.text('Water'), findsOneWidget);
    expect(find.text('Piped Gas'), findsOneWidget);

    // Verify Consumer Number & Fetch
    expect(find.text('Consumer Number / CA Number'), findsOneWidget);
    expect(find.text('Fetch Bill'), findsOneWidget);

    // Verify Fetched Bill details card
    expect(find.text('Tata Power Delhi Distribution (TPDDL)'), findsWidgets);
    expect(find.text('Rohit Kumar'), findsOneWidget);
    expect(find.text('05 Nov 2026'), findsOneWidget);
    expect(find.text('₹1,420.00'), findsOneWidget);

    // Verify Promo Code section & Pay CTA
    expect(find.text('Apply'), findsOneWidget);
    expect(find.text('Pay Bill ₹1,420.00'), findsOneWidget);
  });

  testWidgets('FlamePay PaymentSuccessView renders receipt and rewards', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    const mockResult = PaymentResultModel(
      transactionId: 'FP987654321',
      operatorRefNumber: 'OP123456789',
      amount: 299.00,
      timestamp: '2026-10-26T14:30:00Z',
      status: 'success',
      serviceType: 'Mobile Recharge',
      targetTitle: 'Jio Prepaid - 9876543210',
      paymentMode: 'FlamePay Wallet',
      cashbackEarned: 15.0,
    );

    await tester.pumpWidget(
      const GetMaterialApp(
        home: PaymentSuccessView(result: mockResult),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Payment Successful!'), findsOneWidget);
    expect(find.text('Jio Prepaid - 9876543210'), findsOneWidget);
    expect(find.text('₹299.00'), findsOneWidget);
    expect(find.text('You earned ₹15 Cashback!'), findsOneWidget);
    expect(find.text('FP987654321'), findsOneWidget);
    expect(find.text('OP123456789'), findsOneWidget);
    expect(find.text('Share Receipt'), findsOneWidget);
    expect(find.text('Download'), findsOneWidget);
    expect(find.text('Done'), findsOneWidget);
  });
}
