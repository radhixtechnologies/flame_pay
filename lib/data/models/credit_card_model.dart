class CreditCardModel {
  final String id;
  final String name;
  final String bank;
  final String category; // 'Cashback', 'Rewards', 'Travel', 'Fuel'
  final String annualFee;
  final String joiningFee;
  final String rewardRate;
  final int minCibil;
  final double minIncome;
  final List<String> benefits;
  final List<String> gradientHex;
  final String cardNetwork; // 'VISA', 'Mastercard', 'RuPay'

  const CreditCardModel({
    required this.id,
    required this.name,
    required this.bank,
    required this.category,
    required this.annualFee,
    required this.joiningFee,
    required this.rewardRate,
    required this.minCibil,
    required this.minIncome,
    required this.benefits,
    required this.gradientHex,
    required this.cardNetwork,
  });

  factory CreditCardModel.fromJson(Map<String, dynamic> json) {
    return CreditCardModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      bank: json['bank'] ?? '',
      category: json['category'] ?? 'Cashback',
      annualFee: json['annual_fee'] ?? '₹500',
      joiningFee: json['joining_fee'] ?? '₹500',
      rewardRate: json['reward_rate'] ?? '5%',
      minCibil: json['min_cibil'] ?? 700,
      minIncome: (json['min_income'] as num?)?.toDouble() ?? 25000,
      benefits: (json['benefits'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      gradientHex: (json['gradient_hex'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? ['#0A2A66', '#1558D6'],
      cardNetwork: json['card_network'] ?? 'VISA',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'bank': bank,
    'category': category,
    'annual_fee': annualFee,
    'joining_fee': joiningFee,
    'reward_rate': rewardRate,
    'min_cibil': minCibil,
    'min_income': minIncome,
    'benefits': benefits,
    'gradient_hex': gradientHex,
    'card_network': cardNetwork,
  };
}
