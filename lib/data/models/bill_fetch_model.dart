class BillFetchModel {
  final String billerId;
  final String billerName;
  final String consumerNumber;
  final String consumerName;
  final double billAmount;
  final String dueDate;
  final double lateFee;
  final String billDate;
  final String billNumber;
  final String category;

  const BillFetchModel({
    required this.billerId,
    required this.billerName,
    required this.consumerNumber,
    required this.consumerName,
    required this.billAmount,
    required this.dueDate,
    this.lateFee = 0.0,
    required this.billDate,
    required this.billNumber,
    required this.category,
  });

  factory BillFetchModel.fromJson(Map<String, dynamic> json) {
    return BillFetchModel(
      billerId: json['billerId']?.toString() ?? '',
      billerName: json['billerName']?.toString() ?? 'Utility Biller',
      consumerNumber: json['consumerNumber']?.toString() ?? '',
      consumerName: json['consumerName']?.toString() ?? 'Consumer',
      billAmount: (json['billAmount'] is num)
          ? (json['billAmount'] as num).toDouble()
          : (double.tryParse(json['billAmount']?.toString() ?? '0') ?? 0.0),
      dueDate: json['dueDate']?.toString() ?? 'Due Soon',
      lateFee: (json['lateFee'] is num)
          ? (json['lateFee'] as num).toDouble()
          : (double.tryParse(json['lateFee']?.toString() ?? '0') ?? 0.0),
      billDate: json['billDate']?.toString() ?? 'Recent',
      billNumber: json['billNumber']?.toString() ?? '',
      category: json['category']?.toString() ?? 'utility',
    );
  }

  Map<String, dynamic> toJson() => {
        'billerId': billerId,
        'billerName': billerName,
        'consumerNumber': consumerNumber,
        'consumerName': consumerName,
        'billAmount': billAmount,
        'dueDate': dueDate,
        'lateFee': lateFee,
        'billDate': billDate,
        'billNumber': billNumber,
        'category': category,
      };
}
