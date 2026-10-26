class WalletModel {
  final double balance;
  final String currency;
  final double monthlyLimit;
  final double spentThisMonth;

  const WalletModel({
    required this.balance,
    this.currency = 'INR',
    this.monthlyLimit = 50000.0,
    this.spentThisMonth = 4280.0,
  });

  factory WalletModel.fromJson(Map<String, dynamic> json) {
    return WalletModel(
      balance: (json['balance'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency'] as String? ?? 'INR',
      monthlyLimit: (json['monthlyLimit'] as num?)?.toDouble() ?? 50000.0,
      spentThisMonth: (json['spentThisMonth'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'balance': balance,
      'currency': currency,
      'monthlyLimit': monthlyLimit,
      'spentThisMonth': spentThisMonth,
    };
  }
}
