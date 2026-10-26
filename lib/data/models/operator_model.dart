class OperatorModel {
  final String id;
  final String name;
  final String type; // 'mobile', 'dth', 'electricity', 'water', 'gas', 'broadband', 'emi'
  final String? circle;
  final String? code;
  final String? icon;

  const OperatorModel({
    required this.id,
    required this.name,
    required this.type,
    this.circle,
    this.code,
    this.icon,
  });

  factory OperatorModel.fromJson(Map<String, dynamic> json) {
    return OperatorModel(
      id: json['id'] as String,
      name: json['name'] as String,
      type: json['type'] as String,
      circle: json['circle'] as String?,
      code: json['code'] as String?,
      icon: json['icon'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'type': type,
        'circle': circle,
        'code': code,
        'icon': icon,
      };
}
