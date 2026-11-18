class CreditCardModel {
  final String id;
  final int? productId;
  final String name;
  final String bank;
  final String category; // 'Cashback', 'Rewards', 'Travel', 'Fuel', 'RuPay/UPI', 'Secured'
  final String annualFee;
  final String joiningFee;
  final String rewardRate;
  final String? earnUpTo;
  final String? imageUrl;
  final int minCibil;
  final double minIncome;
  final List<String> benefits;
  final List<String>? eligibilityCriteria;
  final List<String> gradientHex;
  final String cardNetwork; // 'VISA', 'Mastercard', 'RuPay'
  final String? redirectUrl;

  const CreditCardModel({
    required this.id,
    this.productId,
    required this.name,
    required this.bank,
    required this.category,
    required this.annualFee,
    required this.joiningFee,
    required this.rewardRate,
    this.earnUpTo,
    this.imageUrl,
    required this.minCibil,
    required this.minIncome,
    required this.benefits,
    this.eligibilityCriteria,
    required this.gradientHex,
    required this.cardNetwork,
    this.redirectUrl,
  });

  factory CreditCardModel.fromJson(Map<String, dynamic> json) {
    return CreditCardModel(
      id: json['id'] ?? '',
      productId: json['productId'] as int?,
      name: json['name'] ?? '',
      bank: json['bank'] ?? '',
      category: json['category'] ?? 'Cashback',
      annualFee: json['annual_fee'] ?? '₹500',
      joiningFee: json['joining_fee'] ?? '₹500',
      rewardRate: json['reward_rate'] ?? '5%',
      earnUpTo: json['earn_up_to'] as String?,
      imageUrl: json['image_url'] as String?,
      minCibil: json['min_cibil'] ?? 700,
      minIncome: (json['min_income'] as num?)?.toDouble() ?? 25000,
      benefits: (json['benefits'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      eligibilityCriteria: (json['eligibility_criteria'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      gradientHex: (json['gradient_hex'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? ['#0A2A66', '#1558D6'],
      cardNetwork: json['card_network'] ?? 'VISA',
      redirectUrl: json['redirect_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'productId': productId,
    'name': name,
    'bank': bank,
    'category': category,
    'annual_fee': annualFee,
    'joining_fee': joiningFee,
    'reward_rate': rewardRate,
    'earn_up_to': earnUpTo,
    'image_url': imageUrl,
    'min_cibil': minCibil,
    'min_income': minIncome,
    'benefits': benefits,
    'eligibility_criteria': eligibilityCriteria,
    'gradient_hex': gradientHex,
    'card_network': cardNetwork,
    'redirect_url': redirectUrl,
  };
}
