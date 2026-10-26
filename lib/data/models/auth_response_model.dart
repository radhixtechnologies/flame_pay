import 'user_model.dart';

class AuthResponseModel {
  final String token;
  final String refreshToken;
  final bool isNewUser;
  final UserModel? user;

  const AuthResponseModel({
    required this.token,
    required this.refreshToken,
    this.isNewUser = false,
    this.user,
  });

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    return AuthResponseModel(
      token: json['token'] as String? ?? '',
      refreshToken: json['refreshToken'] as String? ?? '',
      isNewUser: json['isNewUser'] as bool? ?? false,
      user: json['user'] != null
          ? UserModel.fromJson(json['user'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'refreshToken': refreshToken,
      'isNewUser': isNewUser,
      'user': user?.toJson(),
    };
  }
}
