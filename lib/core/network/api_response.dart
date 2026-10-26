class ApiResponse<T> {
  final bool success;
  final String message;
  final T? data;
  final int? statusCode;

  ApiResponse({
    required this.success,
    required this.message,
    this.data,
    this.statusCode,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic json)? fromJsonT,
  ) {
    return ApiResponse<T>(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      data: json['data'] != null && fromJsonT != null
          ? fromJsonT(json['data'])
          : json['data'] as T?,
      statusCode: json['statusCode'] as int?,
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

  factory ApiResponse.error(String message, {int? statusCode, T? data}) {
    return ApiResponse<T>(
      success: false,
      message: message,
      statusCode: statusCode,
      data: data,
    );
  }
}
