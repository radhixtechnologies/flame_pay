import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flamepay/main.dart';
import 'package:flamepay/core/services/storage_service.dart';
import 'package:flamepay/core/services/connectivity_service.dart';
import 'package:flamepay/core/services/auth_service.dart';
import 'package:flamepay/core/network/interceptors/mock_interceptor.dart';
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
    final storage = await StorageService().init('phase5_test_box');
    await storage.setSeenOnboarding(true);
    await storage.setAuthToken('mock_token_123');
    Get.put<StorageService>(storage, permanent: true);

    final conn = await ConnectivityService().init();
    Get.put<ConnectivityService>(conn, permanent: true);

    final auth = await AuthService().init();
    auth.isAuthenticated.value = true;
    Get.put<AuthService>(auth, permanent: true);
  });

  testWidgets('FlamePay History Screen renders transactions, search and filter chips', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const FlamePayApp(initialRoute: AppRoutes.history));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Transaction History'), findsOneWidget);
    expect(find.text('All'), findsWidgets);
    expect(find.text('Recharge'), findsWidgets);
    expect(find.text('Bill'), findsWidgets);
    expect(find.text('Wallet'), findsWidgets);
    expect(find.text('Jio 5G Unlimited Recharge'), findsOneWidget);

    // Filter by Bill
    await tester.tap(find.text('Bill').first);
    await tester.pump();
    expect(find.text('Tata Power Electricity Bill'), findsOneWidget);
  });

  testWidgets('FlamePay Offers Screen renders offers with promo codes and copy button', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const FlamePayApp(initialRoute: AppRoutes.offers));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Offers & Rewards'), findsOneWidget);
    expect(find.text('POWER50'), findsOneWidget);
    expect(find.text('FLAME15'), findsOneWidget);
    expect(find.text('Flat ₹50 Bill Cashback'), findsOneWidget);

    // Tap Copy Button
    await tester.tap(find.text('COPY').first);
    await tester.pump();
  });

  testWidgets('FlamePay Notifications Screen renders alerts and mark all read', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const FlamePayApp(initialRoute: AppRoutes.notifications));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Notifications'), findsOneWidget);
    expect(find.text('Payment Successful'), findsOneWidget);
    expect(find.text('Electricity Bill Due Soon'), findsOneWidget);

    // Tap Mark all as read
    final markReadBtn = find.text('Mark all as read');
    expect(markReadBtn, findsOneWidget);
    await tester.tap(markReadBtn);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
  });

  testWidgets('FlamePay Profile Screen renders user details, actions and toggles', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const FlamePayApp(initialRoute: AppRoutes.profile));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('My Profile'), findsOneWidget);
    expect(find.text('Rahul Sharma'), findsOneWidget);
    expect(find.text('+91 98765 43210'), findsOneWidget);
    expect(find.text('KYC Verification'), findsOneWidget);
    expect(find.text('Biometric Authentication'), findsOneWidget);
    expect(find.text('Help & 24x7 Support'), findsOneWidget);
    expect(find.text('Log Out'), findsOneWidget);

    // Toggle biometrics switch
    final switchFinder = find.byType(Switch);
    expect(switchFinder, findsOneWidget);
    await tester.tap(switchFinder);
    await tester.pump();
  });

  testWidgets('FlamePay KYC Screen renders stepper and personal details form', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const FlamePayApp(initialRoute: AppRoutes.kyc));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('KYC Verification'), findsOneWidget);
    expect(find.text('Identity Details'), findsOneWidget);
    expect(find.text('Full Name (as on Aadhaar)'), findsOneWidget);
    expect(find.text('PAN Card Number (10 Alphanumeric)'), findsOneWidget);
    expect(find.text('Aadhaar Number (12 Digits)'), findsOneWidget);
    expect(find.text('Continue to Uploads'), findsOneWidget);

    // Tap continue to go to uploads step
    await tester.tap(find.text('Continue to Uploads'));
    await tester.pump();
    expect(find.text('Document Photos'), findsOneWidget);
    expect(find.text('Aadhaar Card (Front)'), findsOneWidget);
  });

  testWidgets('FlamePay Support Screen renders quick actions, FAQs and live chat', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const FlamePayApp(initialRoute: AppRoutes.support));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Help & 24x7 Support'), findsOneWidget);
    expect(find.text('Live Chat'), findsOneWidget);
    expect(find.text('Toll-Free'), findsOneWidget);
    expect(find.text('New Ticket'), findsOneWidget);
    expect(find.text('Frequently Asked Questions'), findsOneWidget);
    expect(find.text('How do I add money to my FlamePay Wallet?'), findsOneWidget);

    // Tap FAQ to expand
    final faqFinder = find.text('How do I add money to my FlamePay Wallet?');
    expect(faqFinder, findsOneWidget);
    await tester.tap(faqFinder);
    await tester.pump();
    expect(find.textContaining('Go to Wallet > Add Money'), findsOneWidget);
  });

  testWidgets('FlamePay HomeShellView bottom navigation seamlessly switches all 4 tabs', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const FlamePayApp(initialRoute: AppRoutes.home));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Initially Tab 0 (Home)
    expect(find.byType(FlameLogo), findsWidgets);
    expect(find.text('Offers'), findsWidgets);
    expect(find.text('History'), findsWidgets);
    expect(find.text('Profile'), findsWidgets);

    // Switch to Tab 1 (Offers)
    await tester.tap(find.text('Offers').first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.text('Offers & Rewards'), findsOneWidget);

    // Switch to Tab 2 (History)
    await tester.tap(find.text('History').first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.text('Transaction History'), findsOneWidget);

    // Switch to Tab 3 (Profile)
    await tester.tap(find.text('Profile').first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.text('My Profile'), findsOneWidget);

    // Switch back to Tab 0 (Home)
    await tester.tap(find.text('Home').first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.text('Quick Services'), findsOneWidget);
  });
}
