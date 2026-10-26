class PaymentResultModel {
  final String transactionId;
  final String operatorRefNumber;
  final double amount;
  final String timestamp;
  final String status; // 'success', 'pending', 'failed'
  final String serviceType; // 'Mobile Recharge', 'DTH Recharge', 'Electricity Bill', etc.
  final String targetTitle; // e.g. 'Jio Prepaid - 9876543210' or 'Tata Power'
  final String paymentMode; // 'FlamePay Wallet', 'UPI', 'Debit Card'
  final double cashbackEarned;

  const PaymentResultModel({
    required this.transactionId,
    required this.operatorRefNumber,
    required this.amount,
    required this.timestamp,
    required this.status,
    required this.serviceType,
    required this.targetTitle,
    required this.paymentMode,
    this.cashbackEarned = 0.0,
  });

  factory PaymentResultModel.fromJson(Map<String, dynamic> json) {
    return PaymentResultModel(
      transactionId: json['transactionId'] as String,
      operatorRefNumber: json['operatorRefNumber'] as String,
      amount: (json['amount'] as num).toDouble(),
      timestamp: json['timestamp'] as String,
      status: json['status'] as String,
      serviceType: json['serviceType'] as String,
      targetTitle: json['targetTitle'] as String,
      paymentMode: json['paymentMode'] as String,
      cashbackEarned: (json['cashbackEarned'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() => {
        'transactionId': transactionId,
        'operatorRefNumber': operatorRefNumber,
        'amount': amount,
        'timestamp': timestamp,
        'status': status,
        'serviceType': serviceType,
        'targetTitle': targetTitle,
        'paymentMode': paymentMode,
        'cashbackEarned': cashbackEarned,
      };
}
