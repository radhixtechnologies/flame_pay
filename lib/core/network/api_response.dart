class ApiResponse<T> {
  final bool success;
  final String message;
  final T? data;
  final int? statusCode;
  final Map<String, dynamic>? errors;

  ApiResponse({
    required this.success,
    required this.message,
    this.data,
    this.statusCode,
    this.errors,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic json)? fromJsonT, {
    int? statusCode,
  }) {
    final bool isSuccess = json['success'] as bool? ??
        (json['status'] == true || json['status'] == 'success' || json['status'] == 200);

    String msg = '';
    if (json['message'] != null && json['message'].toString().trim().isNotEmpty) {
      msg = json['message'].toString().trim();
    } else if (json['error'] != null) {
      if (json['error'] is Map) {
        msg = (json['error']['message'] ?? json['error']).toString();
      } else {
        msg = json['error'].toString().trim();
      }
    } else if (json['msg'] != null) {
      msg = json['msg'].toString().trim();
    } else if (json['detail'] != null) {
      msg = json['detail'].toString().trim();
    }

    Map<String, dynamic>? errs;
    if (json['errors'] is Map) {
      errs = Map<String, dynamic>.from(json['errors'] as Map);
    }

    return ApiResponse<T>(
      success: isSuccess,
      message: msg,
      data: json['data'] != null && fromJsonT != null
          ? fromJsonT(json['data'])
          : json['data'] as T?,
      statusCode: statusCode ?? json['statusCode'] as int?,
      errors: errs,
    );
  }

  factory ApiResponse.success(T data, {String message = 'Success', int statusCode = 200}) {
    return ApiResponse<T>(
      success: true,
      message: message,
      data: data,
      statusCode: statusCode,
    );
  }

  factory ApiResponse.error(String message, {int? statusCode, T? data, Map<String, dynamic>? errors}) {
    return ApiResponse<T>(
      success: false,
      message: message,
      statusCode: statusCode,
      data: data,
      errors: errors,
    );
  }
}
