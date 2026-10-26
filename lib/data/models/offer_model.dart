class OfferModel {
  final String id;
  final String title;
  final String description;
  final String code;
  final String discount;
  final String category;
  final String? bannerColor;

  const OfferModel({
    required this.id,
    required this.title,
    required this.description,
    required this.code,
    required this.discount,
    required this.category,
    this.bannerColor,
  });

  factory OfferModel.fromJson(Map<String, dynamic> json) {
    return OfferModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      code: json['code'] as String? ?? '',
      discount: json['discount'] as String? ?? '',
      category: json['category'] as String? ?? '',
      bannerColor: json['bannerColor'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'code': code,
      'discount': discount,
      'category': category,
      'bannerColor': bannerColor,
    };
  }
}
