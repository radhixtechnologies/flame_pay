import 'package:get/get.dart';
import 'package:local_auth/local_auth.dart';
import '../../data/models/user_model.dart';
import '../../app/routes/app_routes.dart';
import 'storage_service.dart';

class AuthService extends GetxService {
  final Rx<UserModel?> currentUser = Rx<UserModel?>(null);
  final RxBool isAuthenticated = false.obs;
  final RxBool hasMpin = false.obs;
  final LocalAuthentication _localAuth = LocalAuthentication();

  StorageService get _storage => Get.find<StorageService>();

  Future<AuthService> init() async {
    final token = await _storage.getAuthToken();
    final mpin = await _storage.getMpin();
    hasMpin.value = mpin != null && mpin.isNotEmpty;

    if (token != null && token.isNotEmpty) {
      final userData = _storage.getUserData();
      if (userData != null) {
        currentUser.value = UserModel.fromJson(userData);
        isAuthenticated.value = true;
      } else {
        currentUser.value = const UserModel(
          id: 'FP_USER_101',
          name: 'Rohit Kumar',
          phone: '+91 9876543210',
          email: 'rohit.kumar@example.com',
          isVip: true,
          kycStatus: 'verified',
          walletBalance: 2580.00,
          cibilScore: 780,
        );
        isAuthenticated.value = true;
      }
    }
    return this;
  }

  void setUser(UserModel user) {
    currentUser.value = user;
    isAuthenticated.value = true;
    _storage.setUserData(user.toJson());
  }

  Future<void> logout() async {
    await _storage.clearAuth();
    currentUser.value = null;
    isAuthenticated.value = false;
    hasMpin.value = false;
    Get.offAllNamed(AppRoutes.login);
  }

  Future<bool> authenticateBiometric() async {
    try {
      final canAuth = await _localAuth.canCheckBiometrics || await _localAuth.isDeviceSupported();
      if (!canAuth) return false;
      return await _localAuth.authenticate(
        localizedReason: 'Authenticate to access FlamePay',
      );
    } catch (_) {
      return false;
    }
  }
}
