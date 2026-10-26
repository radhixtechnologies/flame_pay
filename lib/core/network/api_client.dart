import 'package:dio/dio.dart';
import '../config/app_config.dart';
import 'api_response.dart';
import 'api_exception.dart';
import 'interceptors/auth_interceptor.dart';
import 'interceptors/logging_interceptor.dart';
import 'interceptors/retry_interceptor.dart';
import 'interceptors/mock_interceptor.dart';

class ApiClient {
  static ApiClient? _instance;
  late final Dio _dio;

  ApiClient._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.baseUrl,
        connectTimeout: AppConfig.connectTimeout,
        receiveTimeout: AppConfig.receiveTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Register interceptors in order
    _dio.interceptors.addAll([
      MockInterceptor(),
      AuthInterceptor(_dio),
      RetryInterceptor(_dio),
      LoggingInterceptor(),
    ]);
  }

  static ApiClient get instance {
    _instance ??= ApiClient._internal();
    return _instance!;
  }

  Dio get dio => _dio;

  Future<ApiResponse<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    T Function(dynamic json)? fromJson,
  }) async {
    try {
      final response = await _dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
      );
      return ApiResponse<T>.fromJson(response.data as Map<String, dynamic>, fromJson);
    } on DioException catch (e) {
      throw mapDioException(e);
    } catch (e) {
      throw UnknownException(e.toString());
    }
  }

  Future<ApiResponse<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    T Function(dynamic json)? fromJson,
  }) async {
    try {
      final response = await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return ApiResponse<T>.fromJson(response.data as Map<String, dynamic>, fromJson);
    } on DioException catch (e) {
      throw mapDioException(e);
    } catch (e) {
      throw UnknownException(e.toString());
    }
  }

  Future<ApiResponse<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    T Function(dynamic json)? fromJson,
  }) async {
    try {
      final response = await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return ApiResponse<T>.fromJson(response.data as Map<String, dynamic>, fromJson);
    } on DioException catch (e) {
      throw mapDioException(e);
    } catch (e) {
      throw UnknownException(e.toString());
    }
  }

  Future<ApiResponse<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    T Function(dynamic json)? fromJson,
  }) async {
    try {
      final response = await _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return ApiResponse<T>.fromJson(response.data as Map<String, dynamic>, fromJson);
    } on DioException catch (e) {
      throw mapDioException(e);
    } catch (e) {
      throw UnknownException(e.toString());
    }
  }

  Future<ApiResponse<T>> uploadMultipart<T>(
    String path, {
    required FormData formData,
    ProgressCallback? onSendProgress,
    T Function(dynamic json)? fromJson,
  }) async {
    try {
      final response = await _dio.post(
        path,
        data: formData,
        onSendProgress: onSendProgress,
        options: Options(headers: {'Content-Type': 'multipart/form-data'}),
      );
      return ApiResponse<T>.fromJson(response.data as Map<String, dynamic>, fromJson);
    } on DioException catch (e) {
      throw mapDioException(e);
    } catch (e) {
      throw UnknownException(e.toString());
    }
  }
}
