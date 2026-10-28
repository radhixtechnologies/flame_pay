import '../../core/network/api_client.dart';
import '../../core/network/api_endpoints.dart';
import '../../core/network/api_response.dart';
import '../models/operator_model.dart';
import '../models/recharge_plan_model.dart';
import '../models/bill_fetch_model.dart';
import '../models/payment_result_model.dart';

class RechargeRepository {
  final ApiClient _client;

  RechargeRepository({ApiClient? client}) : _client = client ?? ApiClient.instance;

  Future<ApiResponse<Map<String, dynamic>>> checkOperator(String mobile) async {
    return await _client.post<Map<String, dynamic>>(
      ApiEndpoints.rechargeOperatorCheck,
      data: {'mobileNumber': mobile},
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  Future<ApiResponse<List<OperatorModel>>> getOperators(String type) async {
    return await _client.get<List<OperatorModel>>(
      ApiEndpoints.rechargeOperators,
      queryParameters: {'type': type},
      fromJson: (json) => (json as List<dynamic>)
          .map((e) => OperatorModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Future<ApiResponse<List<RechargePlanModel>>> getPlans(String operatorId, String circle) async {
    return await _client.get<List<RechargePlanModel>>(
      ApiEndpoints.rechargePlans,
      queryParameters: {'operatorId': operatorId, 'circle': circle},
      fromJson: (json) => (json as List<dynamic>)
          .map((e) => RechargePlanModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Future<ApiResponse<BillFetchModel>> fetchBill(String billerId, String consumerNumber) async {
    return await _client.post<BillFetchModel>(
      ApiEndpoints.fetchBill,
      data: {'billerId': billerId, 'consumerNumber': consumerNumber},
      fromJson: (json) => BillFetchModel.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<ApiResponse<PaymentResultModel>> processRecharge({
    required String mobileNumber,
    required String operatorId,
    required String circle,
    required double amount,
    required String planId,
    required String paymentMode,
  }) async {
    return await _client.post<PaymentResultModel>(
      ApiEndpoints.rechargePay,
      data: {
        'mobileNumber': mobileNumber,
        'operatorId': operatorId,
        'circle': circle,
        'amount': amount,
        'planId': planId,
        'paymentMode': paymentMode,
      },
      fromJson: (json) => PaymentResultModel.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<ApiResponse<PaymentResultModel>> processBillPayment({
    required String billerId,
    required String consumerNumber,
    required double amount,
    required String paymentMode,
    String? promoCode,
  }) async {
    return await _client.post<PaymentResultModel>(
      ApiEndpoints.payBill,
      data: {
        'billerId': billerId,
        'consumerNumber': consumerNumber,
        'amount': amount,
        'paymentMode': paymentMode,
        'promoCode': promoCode,
      },
      fromJson: (json) => PaymentResultModel.fromJson(json as Map<String, dynamic>),
    );
  }
}
