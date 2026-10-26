import 'dart:math';
import '../../core/network/api_client.dart';
import '../../core/network/api_endpoints.dart';
import '../../core/network/api_response.dart';
import '../models/cibil_model.dart';
import '../models/credit_card_model.dart';
import '../models/loan_model.dart';
import '../models/insurance_model.dart';

class FinancialServicesRepository {
  final ApiClient _apiClient;

  FinancialServicesRepository({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient.instance;

  // CIBIL
  Future<ApiResponse<CibilScoreModel>> getCibilReport() async {
    return _apiClient.get<CibilScoreModel>(
      ApiEndpoints.cibilReport,
      fromJson: (json) => CibilScoreModel.fromJson(json as Map<String, dynamic>),
    );
  }

  // Credit Cards
  Future<ApiResponse<List<CreditCardModel>>> getCreditCards({String? category}) async {
    return _apiClient.get<List<CreditCardModel>>(
      ApiEndpoints.creditCardsList,
      queryParameters: category != null ? {'category': category} : null,
      fromJson: (json) => (json as List<dynamic>)
          .map((e) => CreditCardModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> applyForCreditCard({
    required String cardId,
    required String fullName,
    required String panNumber,
    required double monthlyIncome,
    required String employmentType,
  }) async {
    return _apiClient.post<Map<String, dynamic>>(
      ApiEndpoints.creditCardApply,
      data: {
        'card_id': cardId,
        'full_name': fullName,
        'pan_number': panNumber,
        'monthly_income': monthlyIncome,
        'employment_type': employmentType,
      },
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  // Loans
  Future<ApiResponse<LoanOfferModel>> getPersonalLoanOffer() async {
    return _apiClient.get<LoanOfferModel>(
      ApiEndpoints.loanTypes,
      fromJson: (json) => LoanOfferModel.fromJson(json as Map<String, dynamic>),
    );
  }

  LoanCalculationModel calculateEmi({
    required double loanAmount,
    required int tenureMonths,
    required double annualInterestRate,
  }) {
    // EMI = [P x R x (1+R)^N]/[(1+R)^N-1]
    final monthlyRate = (annualInterestRate / 12) / 100;
    final numerator = loanAmount * monthlyRate * pow(1 + monthlyRate, tenureMonths);
    final denominator = pow(1 + monthlyRate, tenureMonths) - 1;
    final emi = denominator == 0 ? 0.0 : numerator / denominator;
    final totalPayable = emi * tenureMonths;
    final totalInterest = totalPayable - loanAmount;
    final processingFee = loanAmount * 0.015;

    return LoanCalculationModel(
      loanAmount: loanAmount,
      tenureMonths: tenureMonths,
      interestRate: annualInterestRate,
      monthlyEmi: emi.roundToDouble(),
      totalInterest: totalInterest.roundToDouble(),
      totalPayable: totalPayable.roundToDouble(),
      processingFee: processingFee.roundToDouble(),
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> applyForLoan({
    required double amount,
    required int tenureMonths,
    required String purpose,
    required String panNumber,
    required String bankAccountNumber,
  }) async {
    return _apiClient.post<Map<String, dynamic>>(
      ApiEndpoints.loanApply,
      data: {
        'amount': amount,
        'tenure_months': tenureMonths,
        'purpose': purpose,
        'pan_number': panNumber,
        'bank_account_number': bankAccountNumber,
      },
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  // Insurance
  Future<ApiResponse<List<InsurancePlanModel>>> getInsurancePlans({
    InsuranceCategory? category,
  }) async {
    return _apiClient.get<List<InsurancePlanModel>>(
      ApiEndpoints.insurancePlans,
      queryParameters: category != null ? {'category': category.name} : null,
      fromJson: (json) => (json as List<dynamic>)
          .map((e) => InsurancePlanModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> buyInsurancePolicy({
    required String planId,
    required String insuredPersonName,
    required String age,
    required String phone,
    required double premiumAmount,
    required String paymentMode,
  }) async {
    return _apiClient.post<Map<String, dynamic>>(
      ApiEndpoints.insuranceApply,
      data: {
        'plan_id': planId,
        'insured_name': insuredPersonName,
        'age': age,
        'phone': phone,
        'premium_amount': premiumAmount,
        'payment_mode': paymentMode,
      },
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }
}
