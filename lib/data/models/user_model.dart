class UserModel {
  final String id;
  final String name;
  final String phone;
  final String email;
  final bool isVip;
  final String kycStatus;
  final double walletBalance;
  final int cibilScore;
  final String? avatarUrl;
  final String? pan;
  final String? aadhaar;

  const UserModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    this.isVip = false,
    this.kycStatus = 'pending',
    this.walletBalance = 0.0,
    this.cibilScore = 750,
    this.avatarUrl,
    this.pan,
    this.aadhaar,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String? ?? 'FP_USER_0',
      name: json['name'] as String? ?? 'User',
      phone: json['phone'] as String? ?? '',
      email: json['email'] as String? ?? '',
      isVip: json['isVip'] as bool? ?? false,
      kycStatus: json['kycStatus'] as String? ?? 'pending',
      walletBalance: (json['walletBalance'] as num?)?.toDouble() ?? 0.0,
      cibilScore: (json['cibilScore'] as num?)?.toInt() ?? 750,
      avatarUrl: json['avatarUrl'] as String?,
      pan: json['pan'] as String?,
      aadhaar: json['aadhaar'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'email': email,
      'isVip': isVip,
      'kycStatus': kycStatus,
      'walletBalance': walletBalance,
      'cibilScore': cibilScore,
      'avatarUrl': avatarUrl,
      'pan': pan,
      'aadhaar': aadhaar,
    };
  }

  UserModel copyWith({
    String? id,
    String? name,
    String? phone,
    String? email,
    bool? isVip,
    String? kycStatus,
    double? walletBalance,
    int? cibilScore,
    String? avatarUrl,
    String? pan,
    String? aadhaar,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      isVip: isVip ?? this.isVip,
      kycStatus: kycStatus ?? this.kycStatus,
      walletBalance: walletBalance ?? this.walletBalance,
      cibilScore: cibilScore ?? this.cibilScore,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      pan: pan ?? this.pan,
      aadhaar: aadhaar ?? this.aadhaar,
    );
  }
}
