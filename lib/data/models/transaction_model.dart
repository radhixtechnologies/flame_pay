class TransactionModel {
  final String id;
  final String title;
  final String subtitle;
  final double amount;
  final DateTime timestamp;
  final String status; // success, failed, pending
  final String category; // recharge, bill, wallet, emi, insurance
  final String? operatorName;
  final String? mobile;

  const TransactionModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.timestamp,
    required this.status,
    required this.category,
    this.operatorName,
    this.mobile,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? 'Payment',
      subtitle: json['subtitle'] as String? ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      timestamp: json['timestamp'] != null
          ? DateTime.tryParse(json['timestamp'].toString()) ?? DateTime.now()
          : DateTime.now(),
      status: json['status'] as String? ?? 'success',
      category: json['category'] as String? ?? 'recharge',
      operatorName: json['operatorName'] as String?,
      mobile: json['mobile'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'subtitle': subtitle,
      'amount': amount,
      'timestamp': timestamp.toIso8601String(),
      'status': status,
      'category': category,
      'operatorName': operatorName,
      'mobile': mobile,
    };
  }
}
