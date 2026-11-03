import '../../core/network/api_client.dart';
import '../../core/network/api_endpoints.dart';
import '../../core/network/api_response.dart';
import '../models/transaction_model.dart';
import '../models/offer_model.dart';
import '../models/wallet_model.dart';

class HomeRepository {
  final ApiClient _apiClient;

  HomeRepository({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient.instance;

  Future<ApiResponse<WalletModel>> getWalletBalance() async {
    return await _apiClient.get<WalletModel>(
      ApiEndpoints.walletBalance,
      fromJson: (json) => WalletModel.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<ApiResponse<List<TransactionModel>>> getRecentTransactions() async {
    return await _apiClient.get<List<TransactionModel>>(
      ApiEndpoints.transactionsHistory,
      queryParameters: {'limit': 5},
      fromJson: (json) {
        if (json is List) {
          return json.map((item) => TransactionModel.fromJson(item as Map<String, dynamic>)).toList();
        }
        return <TransactionModel>[];
      },
    );
  }

  Future<ApiResponse<List<OfferModel>>> getOffers() async {
    return await _apiClient.get<List<OfferModel>>(
      ApiEndpoints.offersList,
      fromJson: (json) {
        if (json is List) {
          return json.map((item) => OfferModel.fromJson(item as Map<String, dynamic>)).toList();
        }
        return <OfferModel>[];
      },
    );
  }
}
