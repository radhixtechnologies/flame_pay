class RechargePlanModel {
  final String id;
  final double amount;
  final String validity;
  final String data;
  final String talktime;
  final String description;
  final String category; // 'Recommended', 'Popular', 'Truly Unlimited', 'Data Only', 'Annual', 'OTT'
  final List<String> ottBenefits;
  final bool isPopular;

  const RechargePlanModel({
    required this.id,
    required this.amount,
    required this.validity,
    required this.data,
    required this.talktime,
    required this.description,
    required this.category,
    this.ottBenefits = const [],
    this.isPopular = false,
  });

  factory RechargePlanModel.fromJson(Map<String, dynamic> json) {
    return RechargePlanModel(
      id: json['id'] as String,
      amount: (json['amount'] as num).toDouble(),
      validity: json['validity'] as String,
      data: json['data'] as String,
      talktime: json['talktime'] as String,
      description: json['description'] as String,
      category: json['category'] as String,
      ottBenefits: (json['ottBenefits'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      isPopular: json['isPopular'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'amount': amount,
        'validity': validity,
        'data': data,
        'talktime': talktime,
        'description': description,
        'category': category,
        'ottBenefits': ottBenefits,
        'isPopular': isPopular,
      };
}
