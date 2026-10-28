class AppConfig {
  AppConfig._();

  /// Toggle between Mock Mode and Real API.
  /// Set to false when connecting to the real backend.
  static bool useMock = false;

  /// Test helpers to preview empty or error states
  static bool simulateEmptyList = false;
  static bool simulateError = false;

  /// Base URL for live backend
  static const String baseUrl = 'https://admin.flamepay.in/api/v1';

  /// Network timeouts
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  /// Brand Identity
  static const String appName = 'FlamePay';
  static const String appTagline = 'FAST • SECURE • SIMPLE';
  static const String logoTagline = 'Ignite Your Payments.';
  static const String splashFooter = 'Your Financial Super App';
}
