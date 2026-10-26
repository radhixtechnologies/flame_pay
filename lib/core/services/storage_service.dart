import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class StorageService extends GetxService {
  late final GetStorage _prefs;
  late final FlutterSecureStorage _secureStorage;

  static const String _keySeenOnboarding = 'seen_onboarding';
  static const String _keyToken = 'auth_token';
  static const String _keyRefreshToken = 'refresh_token';
  static const String _keyMpin = 'user_mpin';
  static const String _keyBiometric = 'biometric_enabled';
  static const String _keyUser = 'user_data';

  Future<StorageService> init([String container = 'FlamePayStorage']) async {
    await GetStorage.init(container);
    _prefs = GetStorage(container);
    _secureStorage = const FlutterSecureStorage();
    return this;
  }

  // Onboarding
  bool hasSeenOnboarding() => _prefs.read<bool>(_keySeenOnboarding) ?? false;
  Future<void> setSeenOnboarding(bool value) => _prefs.write(_keySeenOnboarding, value);

  // Auth Tokens (Secure)
  Future<String?> getAuthToken() => _secureStorage.read(key: _keyToken);
  Future<void> setAuthToken(String token) => _secureStorage.write(key: _keyToken, value: token);

  Future<String?> getRefreshToken() => _secureStorage.read(key: _keyRefreshToken);
  Future<void> setRefreshToken(String token) => _secureStorage.write(key: _keyRefreshToken, value: token);

  // MPIN (Secure)
  Future<String?> getMpin() => _secureStorage.read(key: _keyMpin);
  Future<void> setMpin(String mpin) => _secureStorage.write(key: _keyMpin, value: mpin);

  // Biometric
  bool isBiometricEnabled() => _prefs.read<bool>(_keyBiometric) ?? false;
  Future<void> setBiometricEnabled(bool value) => _prefs.write(_keyBiometric, value);

  // User Profile
  Map<String, dynamic>? getUserData() {
    final str = _prefs.read<String>(_keyUser);
    if (str == null) return null;
    try {
      return jsonDecode(str) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  Future<void> setUserData(Map<String, dynamic> data) =>
      _prefs.write(_keyUser, jsonEncode(data));

  // Clear Session
  Future<void> clearAuth() async {
    await _secureStorage.delete(key: _keyToken);
    await _secureStorage.delete(key: _keyRefreshToken);
    await _secureStorage.delete(key: _keyMpin);
    await _prefs.remove(_keyUser);
  }
}
