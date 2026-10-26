import 'package:dio/dio.dart';
import 'package:get/get.dart' as getx;
import '../../services/storage_service.dart';
import '../../services/auth_service.dart';
import '../api_endpoints.dart';

class AuthInterceptor extends Interceptor {
  final Dio dio;

  AuthInterceptor(this.dio);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    // Skip token for auth endpoints
    final publicEndpoints = [
      ApiEndpoints.sendOtp,
      ApiEndpoints.verifyOtp,
      ApiEndpoints.register,
      ApiEndpoints.refreshToken,
    ];

    if (!publicEndpoints.contains(options.path)) {
      if (getx.Get.isRegistered<StorageService>()) {
        final token = await getx.Get.find<StorageService>().getAuthToken();
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
      }
    }
    return handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // 401 triggers single token refresh
    if (err.response?.statusCode == 401) {
      final requestOptions = err.requestOptions;

      // Avoid infinite loop if refresh token call itself failed
      if (requestOptions.path == ApiEndpoints.refreshToken) {
        if (getx.Get.isRegistered<AuthService>()) {
          await getx.Get.find<AuthService>().logout();
        }
        return handler.next(err);
      }

      try {
        final storage = getx.Get.find<StorageService>();
        final refreshToken = await storage.getRefreshToken();

        if (refreshToken != null && refreshToken.isNotEmpty) {
          final refreshResponse = await dio.post(
            ApiEndpoints.refreshToken,
            data: {'refreshToken': refreshToken},
          );

          if (refreshResponse.statusCode == 200 && refreshResponse.data != null) {
            final newToken = refreshResponse.data['data']?['token'] as String?;
            final newRefreshToken = refreshResponse.data['data']?['refreshToken'] as String?;

            if (newToken != null) {
              await storage.setAuthToken(newToken);
              if (newRefreshToken != null) {
                await storage.setRefreshToken(newRefreshToken);
              }

              // Retry original request with new token
              requestOptions.headers['Authorization'] = 'Bearer $newToken';
              final response = await dio.fetch(requestOptions);
              return handler.resolve(response);
            }
          }
        }
      } catch (_) {
        // Refresh failed, logout
        if (getx.Get.isRegistered<AuthService>()) {
          await getx.Get.find<AuthService>().logout();
        }
      }
    }
    return handler.next(err);
  }
}
