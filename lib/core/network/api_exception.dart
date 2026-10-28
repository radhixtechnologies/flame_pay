import 'package:dio/dio.dart';

sealed class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final Map<String, dynamic>? errors;

  const ApiException(this.message, [this.statusCode, this.errors]);

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
  const ValidationException(String message, {Map<String, dynamic>? errors, int? code})
      : super(message, code ?? 422, errors);

  /// Helper to get the first validation error message for a specific field
  String? getFieldError(String fieldName) {
    if (errors == null) return null;
    final val = errors![fieldName];
    if (val is List && val.isNotEmpty) return val.first.toString();
    if (val is String) return val;
    return val?.toString();
  }
}

class UnknownException extends ApiException {
  const UnknownException([String message = 'An unexpected error occurred. Please try again.'])
      : super(message, -1);
}

/// Helper container for parsed API errors
class ParsedApiError {
  final String message;
  final Map<String, dynamic>? fieldErrors;
  final int? statusCode;

  const ParsedApiError({
    required this.message,
    this.fieldErrors,
    this.statusCode,
  });
}

/// Parses error responses from any API backend structure (JSON, Map, List, or HTML)
class ApiErrorParser {
  ApiErrorParser._();

  static ParsedApiError parse(dynamic data, int? statusCode) {
    if (data == null) {
      return ParsedApiError(
        message: _defaultStatusMessage(statusCode),
        statusCode: statusCode,
      );
    }

    // 1. If response is a String (could be plain text or HTML error page like <pre>Bad Request</pre>)
    if (data is String) {
      final cleanText = _cleanStringOrHtml(data);
      final finalMsg = cleanText.isNotEmpty ? cleanText : _defaultStatusMessage(statusCode);
      return ParsedApiError(message: finalMsg, statusCode: statusCode);
    }

    // 2. If response is a Map
    if (data is Map) {
      final map = Map<String, dynamic>.from(data);

      // Check primary message in common backend keys
      String? primaryMessage;
      if (map['message'] != null && map['message'].toString().trim().isNotEmpty) {
        primaryMessage = map['message'].toString().trim();
      } else if (map['error'] != null) {
        if (map['error'] is Map) {
          final errorMap = map['error'] as Map;
          primaryMessage = errorMap['message']?.toString() ?? errorMap.toString();
        } else {
          primaryMessage = map['error'].toString().trim();
        }
      } else if (map['msg'] != null && map['msg'].toString().trim().isNotEmpty) {
        primaryMessage = map['msg'].toString().trim();
      } else if (map['detail'] != null && map['detail'].toString().trim().isNotEmpty) {
        primaryMessage = map['detail'].toString().trim();
      }

      // Check for nested errors (field-wise validations)
      Map<String, dynamic>? fieldErrors;
      final rawErrors = map['errors'];
      if (rawErrors is Map) {
        fieldErrors = Map<String, dynamic>.from(rawErrors);
      } else if (rawErrors is List && rawErrors.isNotEmpty) {
        // e.g. [{"msg": "...", "param": "phone"}] or ["Invalid phone", "Invalid email"]
        final listMessages = <String>[];
        for (var item in rawErrors) {
          if (item is Map) {
            final param = item['param'] ?? item['field'] ?? item['path'];
            final msg = item['msg'] ?? item['message'];
            if (param != null && msg != null) {
              listMessages.add('$param: $msg');
            } else if (msg != null) {
              listMessages.add(msg.toString());
            } else {
              listMessages.add(item.toString());
            }
          } else {
            listMessages.add(item.toString());
          }
        }
        if (listMessages.isNotEmpty) {
          final joined = listMessages.join('\n');
          primaryMessage = (primaryMessage != null && primaryMessage.isNotEmpty && !primaryMessage.contains(joined))
              ? '$primaryMessage\n$joined'
              : joined;
        }
      }

      // If fieldErrors exists (e.g. {"phone": ["Phone is required"], "email": "Invalid email"})
      if (fieldErrors != null && fieldErrors.isNotEmpty) {
        final errorLines = <String>[];
        fieldErrors.forEach((field, err) {
          if (err is List) {
            for (var e in err) {
              errorLines.add('$field: $e');
            }
          } else {
            errorLines.add('$field: $err');
          }
        });

        if (errorLines.isNotEmpty) {
          final formattedFieldErrors = errorLines.join('\n');
          if (primaryMessage == null || primaryMessage.isEmpty || primaryMessage.toLowerCase() == 'validation error') {
            primaryMessage = formattedFieldErrors;
          } else {
            if (!primaryMessage.contains(errorLines.first)) {
              primaryMessage = '$primaryMessage\n$formattedFieldErrors';
            }
          }
        }
      }

      return ParsedApiError(
        message: (primaryMessage != null && primaryMessage.isNotEmpty)
            ? primaryMessage
            : _defaultStatusMessage(statusCode),
        fieldErrors: fieldErrors,
        statusCode: statusCode,
      );
    }

    return ParsedApiError(
      message: _defaultStatusMessage(statusCode),
      statusCode: statusCode,
    );
  }

  static String _cleanStringOrHtml(String input) {
    var text = input.trim();
    if (text.isEmpty) return '';

    // If HTML:
    if (text.startsWith('<') || text.contains('</') || text.contains('<!DOCTYPE')) {
      // Try to extract content inside <pre>...</pre>
      final preMatch = RegExp(r'<pre>(.*?)</pre>', dotAll: true, caseSensitive: false).firstMatch(text);
      if (preMatch != null && preMatch.group(1) != null) {
        text = preMatch.group(1)!.trim();
      } else {
        // Try to extract content inside <title>...</title>
        final titleMatch = RegExp(r'<title>(.*?)</title>', dotAll: true, caseSensitive: false).firstMatch(text);
        if (titleMatch != null && titleMatch.group(1) != null) {
          text = titleMatch.group(1)!.trim();
        } else {
          // Strip all HTML tags
          text = text.replaceAll(RegExp(r'<[^>]*>'), ' ').replaceAll(RegExp(r'\s+'), ' ').trim();
        }
      }
    }
    return text;
  }

  static String _defaultStatusMessage(int? statusCode) {
    switch (statusCode) {
      case 400:
        return 'Bad request. Please verify your input.';
      case 401:
        return 'Session expired or unauthorized. Please login again.';
      case 403:
        return 'Access forbidden. You do not have permission.';
      case 404:
        return 'API endpoint not found (404).';
      case 408:
        return 'Request timeout. Please check your network and try again.';
      case 422:
        return 'Validation failed. Please check the entered data.';
      case 429:
        return 'Too many requests. Please wait a moment and try again.';
      case 500:
        return 'Internal server error (500). Please try again later.';
      case 502:
        return 'Bad gateway (502). Server is currently unreachable.';
      case 503:
        return 'Service unavailable (503). Server is undergoing maintenance.';
      default:
        return statusCode != null
            ? 'Request failed with status $statusCode'
            : 'An unexpected error occurred. Please try again.';
    }
  }
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
      final parsed = ApiErrorParser.parse(data, statusCode);

      if (statusCode == 401) {
        return UnauthorizedException(parsed.message);
      } else if (statusCode == 422 || statusCode == 400) {
        return ValidationException(
          parsed.message,
          errors: parsed.fieldErrors,
          code: statusCode,
        );
      } else if (statusCode != null && statusCode >= 500) {
        return ServerException(parsed.message, statusCode);
      }
      return ServerException(parsed.message, statusCode);
    case DioExceptionType.cancel:
      return const UnknownException('Request was cancelled');
    default:
      if (error.message != null && error.message!.isNotEmpty) {
        return UnknownException(error.message!);
      }
      return const UnknownException();
  }
}
