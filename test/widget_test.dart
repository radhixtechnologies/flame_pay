import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flamepay/main.dart';
import 'package:flamepay/core/services/storage_service.dart';
import 'package:flamepay/core/services/connectivity_service.dart';
import 'package:flamepay/core/services/auth_service.dart';
import 'package:flamepay/app/routes/app_routes.dart';
import 'package:get/get.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
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
    final storage = await StorageService().init('widget_test_box');
    Get.put<StorageService>(storage, permanent: true);
    final conn = await ConnectivityService().init();
    Get.put<ConnectivityService>(conn, permanent: true);
    final auth = await AuthService().init();
    Get.put<AuthService>(auth, permanent: true);
  });

  testWidgets('FlamePay loads without overflow on compact 320x568', (tester) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const FlamePayApp());
    await tester.pump(const Duration(seconds: 3));
    expect(find.byType(FlamePayApp), findsOneWidget);
  });

  testWidgets('FlamePay renders OTP screen with Pinput without error', (tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const FlamePayApp());
    await tester.pump(const Duration(seconds: 3));

    // Navigate to OTP route
    Get.toNamed(AppRoutes.otp);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Verify OTP'), findsOneWidget);
    expect(find.text('Enter Verification Code'), findsOneWidget);
  });
}
