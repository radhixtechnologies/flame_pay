import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (kDebugMode) {
      debugPrint('--> ${options.method.toUpperCase()} ${options.baseUrl}${options.path}');
      final sanitizedHeaders = Map<String, dynamic>.from(options.headers);
      if (sanitizedHeaders.containsKey('Authorization')) {
        sanitizedHeaders['Authorization'] = 'Bearer [MASKED]';
      }
      debugPrint('Headers: $sanitizedHeaders');
      if (options.data != null) {
        debugPrint('Body: ${_maskSensitive(options.data)}');
      }
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (kDebugMode) {
      debugPrint('<-- ${response.statusCode} ${response.requestOptions.path}');
      debugPrint('Response: ${response.data}');
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (kDebugMode) {
      debugPrint('┌───────────────────── [API ERROR RESPONSE] ─────────────────────');
      debugPrint('│ Endpoint: ${err.requestOptions.method.toUpperCase()} ${err.requestOptions.baseUrl}${err.requestOptions.path}');
      debugPrint('│ Status Code: ${err.response?.statusCode ?? "No status"}');
      debugPrint('│ Dio Message: ${err.message}');
      if (err.requestOptions.data != null) {
        debugPrint('│ Sent Body: ${_maskSensitive(err.requestOptions.data)}');
      }
      debugPrint('│ API Error Response: ${err.response?.data}');
      debugPrint('└───────────────────────────────────────────────────────────────');
    }
    handler.next(err);
  }

  dynamic _maskSensitive(dynamic data) {
    if (data is Map) {
      final copy = Map<String, dynamic>.from(data);
      for (final key in ['password', 'mpin', 'otp', 'aadhaar', 'pan']) {
        if (copy.containsKey(key)) {
          copy[key] = '***MASKED***';
        }
      }
      return copy;
    }
    return data;
  }
}
