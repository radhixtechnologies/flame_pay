import '../../core/network/api_client.dart';
import '../../core/network/api_endpoints.dart';
import '../../core/network/api_response.dart';
import '../models/auth_response_model.dart';
import '../models/user_model.dart';

class AuthRepository {
  final ApiClient _apiClient;

  AuthRepository({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient.instance;

  Future<ApiResponse<Map<String, dynamic>>> sendOtp(String phone) async {
    return await _apiClient.post<Map<String, dynamic>>(
      ApiEndpoints.sendOtp,
      data: {'phone': phone},
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  Future<ApiResponse<AuthResponseModel>> verifyOtp(String phone, String otp) async {
    return await _apiClient.post<AuthResponseModel>(
      ApiEndpoints.verifyOtp,
      data: {'phone': phone, 'otp': otp},
      fromJson: (json) => AuthResponseModel.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<ApiResponse<AuthResponseModel>> register({
    required String name,
    required String email,
    required String phone,
    String? referralCode,
  }) async {
    return await _apiClient.post<AuthResponseModel>(
      ApiEndpoints.register,
      data: {
        'name': name,
        'email': email,
        'phone': phone,
        if (referralCode != null && referralCode.isNotEmpty) 'referralCode': referralCode,
      },
      fromJson: (json) => AuthResponseModel.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<ApiResponse<bool>> setMpin(String mpin) async {
    return await _apiClient.post<bool>(
      ApiEndpoints.setMpin,
      data: {'mpin': mpin},
      fromJson: (json) => true,
    );
  }

  Future<ApiResponse<bool>> verifyMpin(String mpin) async {
    return await _apiClient.post<bool>(
      ApiEndpoints.verifyMpin,
      data: {'mpin': mpin},
      fromJson: (json) => true,
    );
  }

  Future<ApiResponse<UserModel>> getUserProfile() async {
    return await _apiClient.get<UserModel>(
      ApiEndpoints.userProfile,
      fromJson: (json) => UserModel.fromJson(json as Map<String, dynamic>),
    );
  }
}
