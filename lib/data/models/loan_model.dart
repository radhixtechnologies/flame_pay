class LoanOfferModel {
  final String id;
  final String title;
  final double minAmount;
  final double maxAmount;
  final double annualInterestRate;
  final int minTenureMonths;
  final int maxTenureMonths;
  final double processingFeePercent;
  final List<String> highlights;

  const LoanOfferModel({
    required this.id,
    required this.title,
    required this.minAmount,
    required this.maxAmount,
    required this.annualInterestRate,
    required this.minTenureMonths,
    required this.maxTenureMonths,
    required this.processingFeePercent,
    required this.highlights,
  });

  factory LoanOfferModel.fromJson(Map<String, dynamic> json) {
    return LoanOfferModel(
      id: json['id'] ?? '',
      title: json['title'] ?? 'Instant Personal Loan',
      minAmount: (json['min_amount'] as num?)?.toDouble() ?? 10000.0,
      maxAmount: (json['max_amount'] as num?)?.toDouble() ?? 500000.0,
      annualInterestRate: (json['annual_interest_rate'] as num?)?.toDouble() ?? 10.49,
      minTenureMonths: json['min_tenure_months'] ?? 3,
      maxTenureMonths: json['max_tenure_months'] ?? 36,
      processingFeePercent: (json['processing_fee_percent'] as num?)?.toDouble() ?? 1.5,
      highlights: (json['highlights'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'min_amount': minAmount,
    'max_amount': maxAmount,
    'annual_interest_rate': annualInterestRate,
    'min_tenure_months': minTenureMonths,
    'max_tenure_months': maxTenureMonths,
    'processing_fee_percent': processingFeePercent,
    'highlights': highlights,
  };
}

class LoanCalculationModel {
  final double loanAmount;
  final int tenureMonths;
  final double interestRate;
  final double monthlyEmi;
  final double totalInterest;
  final double totalPayable;
  final double processingFee;

  const LoanCalculationModel({
    required this.loanAmount,
    required this.tenureMonths,
    required this.interestRate,
    required this.monthlyEmi,
    required this.totalInterest,
    required this.totalPayable,
    required this.processingFee,
  });

  factory LoanCalculationModel.fromJson(Map<String, dynamic> json) {
    return LoanCalculationModel(
      loanAmount: (json['loan_amount'] as num?)?.toDouble() ?? 100000.0,
      tenureMonths: json['tenure_months'] ?? 12,
      interestRate: (json['interest_rate'] as num?)?.toDouble() ?? 10.49,
      monthlyEmi: (json['monthly_emi'] as num?)?.toDouble() ?? 8815.0,
      totalInterest: (json['total_interest'] as num?)?.toDouble() ?? 5780.0,
      totalPayable: (json['total_payable'] as num?)?.toDouble() ?? 105780.0,
      processingFee: (json['processing_fee'] as num?)?.toDouble() ?? 1500.0,
    );
  }

  Map<String, dynamic> toJson() => {
    'loan_amount': loanAmount,
    'tenure_months': tenureMonths,
    'interest_rate': interestRate,
    'monthly_emi': monthlyEmi,
    'total_interest': totalInterest,
    'total_payable': totalPayable,
    'processing_fee': processingFee,
  };
}
