import 'package:dio/dio.dart';

sealed class ApiException implements Exception {
  final String message;
  final int? statusCode;

  const ApiException(this.message, [this.statusCode]);

  @override
  String toString() => message;
}

class NoInternetException extends ApiException {
  const NoInternetException([String message = 'No internet connection. Please check your network.'])
      : super(message, 0);
}

class TimeoutException extends ApiException {
  const TimeoutException([String message = 'Connection timed out. Please try again.'])
      : super(message, 408);
}

class UnauthorizedException extends ApiException {
  const UnauthorizedException([String message = 'Session expired. Please login again.'])
      : super(message, 401);
}

class ServerException extends ApiException {
  const ServerException([String message = 'Internal server error. Please try again later.', int? code])
      : super(message, code ?? 500);
}

class ValidationException extends ApiException {
  final Map<String, dynamic>? errors;
  const ValidationException(String message, {this.errors, int? code})
      : super(message, code ?? 422);
}

class UnknownException extends ApiException {
  const UnknownException([String message = 'An unexpected error occurred. Please try again.'])
      : super(message, -1);
}

ApiException mapDioException(DioException error) {
  switch (error.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
      return const TimeoutException();
    case DioExceptionType.connectionError:
      return const NoInternetException();
    case DioExceptionType.badResponse:
      final statusCode = error.response?.statusCode;
      final data = error.response?.data;
      String message = 'Something went wrong';
      if (data is Map && data['message'] != null) {
        message = data['message'].toString();
      }

      if (statusCode == 401) {
        return UnauthorizedException(message);
      } else if (statusCode == 422 || statusCode == 400) {
        return ValidationException(
          message,
          errors: data is Map<String, dynamic> ? data['errors'] as Map<String, dynamic>? : null,
          code: statusCode,
        );
      } else if (statusCode != null && statusCode >= 500) {
        return ServerException(message, statusCode);
      }
      return ServerException(message, statusCode);
    case DioExceptionType.cancel:
      return const UnknownException('Request was cancelled');
    default:
      return const UnknownException();
  }
}
