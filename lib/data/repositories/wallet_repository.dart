import '../../core/network/api_client.dart';
import '../../core/network/api_endpoints.dart';
import '../../core/network/api_response.dart';
import '../models/wallet_model.dart';
import '../models/transaction_model.dart';

import '../models/payment_result_model.dart';

class WalletRepository {
  final ApiClient _apiClient;

  WalletRepository({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient.instance;

  Future<ApiResponse<WalletModel>> getWalletDetails() async {
    return await _apiClient.get<WalletModel>(
      ApiEndpoints.walletBalance,
      fromJson: (json) => WalletModel.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> addMoney({
    required double amount,
    required String paymentMethod,
  }) async {
    return await _apiClient.post<Map<String, dynamic>>(
      ApiEndpoints.walletAddMoney,
      data: {
        'amount': amount,
        'paymentMethod': paymentMethod,
      },
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }


  Future<ApiResponse<PaymentResultModel>> transferMoney({
    required String recipient,
    required double amount,
    String? note,
  }) async {
    return await _apiClient.post<PaymentResultModel>(
      ApiEndpoints.walletTransfer,
      data: {
        'recipient': recipient,
        'amount': amount,
        if (note != null && note.isNotEmpty) 'note': note,
      },
      fromJson: (json) => PaymentResultModel.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<ApiResponse<List<TransactionModel>>> getWalletTransactions() async {
    return await _apiClient.get<List<TransactionModel>>(
      ApiEndpoints.walletTransactions,
      fromJson: (json) => (json as List<dynamic>)
          .map((item) => TransactionModel.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}
