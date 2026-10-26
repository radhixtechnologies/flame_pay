import 'package:dio/dio.dart';

class RetryInterceptor extends Interceptor {
  final Dio dio;
  final int maxRetries;

  RetryInterceptor(this.dio, {this.maxRetries = 2});

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final request = err.requestOptions;
    // Only retry idempotent GET requests on timeouts or connection errors
    if (request.method.toUpperCase() == 'GET' &&
        (err.type == DioExceptionType.connectionTimeout ||
            err.type == DioExceptionType.receiveTimeout ||
            err.type == DioExceptionType.connectionError)) {
      int retryCount = (request.extra['retry_count'] as int?) ?? 0;
      if (retryCount < maxRetries) {
        retryCount++;
        request.extra['retry_count'] = retryCount;
        try {
          await Future.delayed(Duration(milliseconds: 500 * retryCount));
          final response = await dio.fetch(request);
          return handler.resolve(response);
        } catch (_) {
          // If retry fails, continue to next handler
        }
      }
    }
    return handler.next(err);
  }
}
