enum InsuranceCategory {
  health,
  termLife,
  motor,
  travel,
}

class InsurancePlanModel {
  final String id;
  final String title;
  final String provider;
  final InsuranceCategory category;
  final double coverAmount;
  final double monthlyPremium;
  final double yearlyPremium;
  final double claimRatioPercent;
  final int cashlessHospitalsCount;
  final List<String> keyFeatures;
  final String providerLogo;
  final bool isPopular;

  const InsurancePlanModel({
    required this.id,
    required this.title,
    required this.provider,
    required this.category,
    required this.coverAmount,
    required this.monthlyPremium,
    required this.yearlyPremium,
    required this.claimRatioPercent,
    required this.cashlessHospitalsCount,
    required this.keyFeatures,
    required this.providerLogo,
    this.isPopular = false,
  });

  factory InsurancePlanModel.fromJson(Map<String, dynamic> json) {
    final catStr = json['category'] as String? ?? 'health';
    final category = InsuranceCategory.values.firstWhere(
      (c) => c.name.toLowerCase() == catStr.toLowerCase(),
      orElse: () => InsuranceCategory.health,
    );

    return InsurancePlanModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      provider: json['provider'] ?? '',
      category: category,
      coverAmount: (json['cover_amount'] as num?)?.toDouble() ?? 500000.0,
      monthlyPremium: (json['monthly_premium'] as num?)?.toDouble() ?? 499.0,
      yearlyPremium: (json['yearly_premium'] as num?)?.toDouble() ?? 5499.0,
      claimRatioPercent: (json['claim_ratio_percent'] as num?)?.toDouble() ?? 98.2,
      cashlessHospitalsCount: json['cashless_hospitals_count'] ?? 10000,
      keyFeatures: (json['key_features'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      providerLogo: json['provider_logo'] ?? '',
      isPopular: json['is_popular'] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'provider': provider,
    'category': category.name,
    'cover_amount': coverAmount,
    'monthly_premium': monthlyPremium,
    'yearly_premium': yearlyPremium,
    'claim_ratio_percent': claimRatioPercent,
    'cashless_hospitals_count': cashlessHospitalsCount,
    'key_features': keyFeatures,
    'provider_logo': providerLogo,
    'is_popular': isPopular,
  };
}
