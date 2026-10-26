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
      billerId: json['billerId'] as String,
      billerName: json['billerName'] as String,
      consumerNumber: json['consumerNumber'] as String,
      consumerName: json['consumerName'] as String,
      billAmount: (json['billAmount'] as num).toDouble(),
      dueDate: json['dueDate'] as String,
      lateFee: (json['lateFee'] as num?)?.toDouble() ?? 0.0,
      billDate: json['billDate'] as String,
      billNumber: json['billNumber'] as String,
      category: json['category'] as String,
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
