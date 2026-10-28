import 'package:flutter_test/flutter_test.dart';
import 'package:dio/dio.dart';
import 'package:flamepay/core/config/app_config.dart';
import 'package:flamepay/core/network/api_exception.dart';
import 'package:flamepay/core/network/api_response.dart';

void main() {
  group('AppConfig & API Base URL Tests', () {
    test('Base URL is configured to live endpoint', () {
      expect(AppConfig.baseUrl, equals('https://admin.flamepay.in/api/v1'));
      expect(AppConfig.useMock, isFalse);
    });
  });

  group('ApiErrorParser Tests', () {
    test('Parses standard FlamePay backend error {"success": false, "message": "Phone is required"}', () {
      final parsed = ApiErrorParser.parse({'success': false, 'message': 'Phone is required'}, 400);
      expect(parsed.message, equals('Phone is required'));
      expect(parsed.statusCode, equals(400));
    });

    test('Parses field-level validation errors map', () {
      final data = {
        'success': false,
        'message': 'Validation failed',
        'errors': {
          'phone': ['Phone number is already in use.'],
          'email': ['Please provide a valid corporate email.'],
        }
      };
      final parsed = ApiErrorParser.parse(data, 422);
      expect(parsed.message, contains('phone: Phone number is already in use.'));
      expect(parsed.message, contains('email: Please provide a valid corporate email.'));
      expect(parsed.fieldErrors, isNotNull);
      expect(parsed.fieldErrors!['phone'], isA<List>());
    });

    test('Parses express-validator format list of errors', () {
      final data = {
        'errors': [
          {'param': 'phone', 'msg': 'Must be 10 digits'},
          {'param': 'otp', 'msg': 'OTP must be 6 digits'},
        ]
      };
      final parsed = ApiErrorParser.parse(data, 400);
      expect(parsed.message, contains('phone: Must be 10 digits'));
      expect(parsed.message, contains('otp: OTP must be 6 digits'));
    });

    test('Parses HTML error page by stripping tags and extracting clean text', () {
      const html = '<!DOCTYPE html><html><head><title>Error</title></head><body><pre>Cannot POST /api/v1/auth/verify</pre></body></html>';
      final parsed = ApiErrorParser.parse(html, 404);
      expect(parsed.message, equals('Cannot POST /api/v1/auth/verify'));
    });

    test('mapDioException returns ValidationException with exact API message on 400/422', () {
      final dioException = DioException(
        requestOptions: RequestOptions(path: '/auth/send-otp'),
        response: Response(
          requestOptions: RequestOptions(path: '/auth/send-otp'),
          statusCode: 400,
          data: {'success': false, 'message': 'Phone is required'},
        ),
        type: DioExceptionType.badResponse,
      );

      final ex = mapDioException(dioException);
      expect(ex, isA<ValidationException>());
      expect(ex.message, equals('Phone is required'));
      expect(ex.toString(), equals('Phone is required'));
    });

    test('ApiResponse parses error and errors map correctly', () {
      final json = {
        'success': false,
        'message': 'Invalid credentials',
        'errors': {'code': 'INVALID_TOKEN'},
      };
      final res = ApiResponse<dynamic>.fromJson(json, null);
      expect(res.success, isFalse);
      expect(res.message, equals('Invalid credentials'));
      expect(res.errors?['code'], equals('INVALID_TOKEN'));
    });
  });
}
