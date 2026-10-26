import 'dart:math';
import 'package:dio/dio.dart';
import '../../config/app_config.dart';
import '../api_endpoints.dart';
import '../../../data/mock/mock_home_data.dart';
import '../../../data/mock/mock_recharge_data.dart';
import '../../../data/mock/mock_phase4_data.dart';
import '../../../data/mock/mock_phase5_data.dart';

class MockInterceptor extends Interceptor {
  final _random = Random();
  static double currentWalletBalance = 2580.00;
String currentUserName = "Rohit Kumar";
String currentUserEmail = "rohit.kumar@example.com";
  static bool enableDelay = true;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    if (!AppConfig.useMock) {
      return handler.next(options);
    }

    if (enableDelay) {
      final delay = 600 + _random.nextInt(600);
      await Future.delayed(Duration(milliseconds: delay));
    }

    if (AppConfig.simulateError) {
      return handler.reject(
        DioException(
          requestOptions: options,
          response: Response(
            requestOptions: options,
            statusCode: 500,
            data: {'success': false, 'message': 'Simulated Server Error'},
          ),
          type: DioExceptionType.badResponse,
        ),
      );
    }

    final path = options.path;
    final data = options.data is Map<String, dynamic> ? options.data as Map<String, dynamic> : <String, dynamic>{};

    Map<String, dynamic>? responseData;

    // AUTH (Phase 1)
    
    
    // PHASE 5: HISTORY, OFFERS, NOTIFICATIONS, KYC
    if (path == ApiEndpoints.transactionsHistory) {
      final category = options.queryParameters['category'] as String?;
      final query = (options.queryParameters['query'] as String?)?.toLowerCase();

      var list = MockPhase5Data.extendedTransactions;
      if (category != null && category.isNotEmpty && category != 'All') {
        list = list.where((t) => t.category.toLowerCase() == category.toLowerCase()).toList();
      }
      if (query != null && query.isNotEmpty) {
        list = list.where((t) => t.title.toLowerCase().contains(query) || t.subtitle.toLowerCase().contains(query)).toList();
      }

      responseData = {
        'success': true,
        'message': 'Transactions fetched successfully',
        'data': list.map((t) => t.toJson()).toList(),
      };
    } else if (path == ApiEndpoints.offersList) {
      final category = options.queryParameters['category'] as String?;
      var list = MockPhase5Data.extendedOffers;
      if (category != null && category.isNotEmpty && category != 'All') {
        list = list.where((o) => o.category.toLowerCase() == category.toLowerCase()).toList();
      }
      responseData = {
        'success': true,
        'message': 'Offers fetched successfully',
        'data': list.map((o) => o.toJson()).toList(),
      };
    } else if (path == ApiEndpoints.notificationsList) {
      responseData = {
        'success': true,
        'message': 'Notifications fetched successfully',
        'data': MockPhase5Data.notifications.map((n) => n.toJson()).toList(),
      };
    } else if (path == ApiEndpoints.notificationsReadAll) {
      responseData = {
        'success': true,
        'message': 'All notifications marked as read',
      };
    } else if (path == ApiEndpoints.kycStatus) {
      responseData = {
        'success': true,
        'data': {
          'status': 'verified',
          'aadhaar_verified': true,
          'pan_verified': true,
          'monthly_limit': 200000.0,
        },
      };
    } else if (path == ApiEndpoints.kycSubmit) {
      responseData = {
        'success': true,
        'message': 'KYC verification submitted and approved successfully',
        'data': {
          'status': 'verified',
          'monthly_limit': 200000.0,
        },
      };
    } else 
    // FINANCIAL SERVICES (Phase 4)
    if (path == ApiEndpoints.cibilReport || path == ApiEndpoints.cibilScore) {
      responseData = {
        'success': true,
        'message': 'CIBIL report fetched successfully',
        'data': MockPhase4Data.cibilReport.toJson(),
      };
    } else if (path == ApiEndpoints.creditCardsList) {
      final category = options.queryParameters['category'] as String?;
      var cards = MockPhase4Data.creditCards;
      if (category != null && category.isNotEmpty && category != 'All') {
        cards = cards.where((c) => c.category.toLowerCase() == category.toLowerCase()).toList();
      }
      responseData = {
        'success': true,
        'message': 'Credit cards fetched successfully',
        'data': cards.map((c) => c.toJson()).toList(),
      };
    } else if (path == ApiEndpoints.creditCardApply) {
      final cardId = data['card_id'] ?? 'card_1';
      final pan = data['pan_number'] ?? 'ABCDE1234F';
      responseData = {
        'success': true,
        'message': 'Credit card application submitted successfully',
        'data': {
          'application_id': 'CC-APPLY-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
          'card_id': cardId,
          'pan_number': pan,
          'status': 'Approved (Instant in-principle)',
          'credit_limit': 150000.0,
          'timestamp': DateTime.now().toIso8601String(),
        },
      };
    } else if (path == ApiEndpoints.loanTypes) {
      responseData = {
        'success': true,
        'message': 'Loan offers fetched successfully',
        'data': MockPhase4Data.personalLoanOffer.toJson(),
      };
    } else if (path == ApiEndpoints.loanApply) {
      final amount = (data['amount'] as num?)?.toDouble() ?? 50000.0;
      responseData = {
        'success': true,
        'message': 'Loan approved and sanctioned successfully',
        'data': {
          'loan_account_id': 'FP-LN-${DateTime.now().millisecondsSinceEpoch.toString().substring(6)}',
          'sanctioned_amount': amount,
          'disbursal_status': 'Disbursed to FlamePay Wallet',
          'utr_number': 'UTR-${DateTime.now().millisecondsSinceEpoch}',
          'timestamp': DateTime.now().toIso8601String(),
        },
      };
    } else if (path == ApiEndpoints.insurancePlans) {
      final category = options.queryParameters['category'] as String?;
      var plans = MockPhase4Data.insurancePlans;
      if (category != null && category.isNotEmpty && category != 'all') {
        plans = plans.where((p) => p.category.name.toLowerCase() == category.toLowerCase()).toList();
      }
      responseData = {
        'success': true,
        'message': 'Insurance plans fetched successfully',
        'data': plans.map((p) => p.toJson()).toList(),
      };
    } else if (path == ApiEndpoints.insuranceApply) {
      final premium = (data['premium_amount'] as num?)?.toDouble() ?? 499.0;
      responseData = {
        'success': true,
        'message': 'Policy issued successfully',
        'data': {
          'policy_number': 'FP-POL-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}',
          'insured_name': data['insured_name'] ?? 'Rohit Kumar',
          'premium_paid': premium,
          'status': 'Active',
          'valid_till': '26 Oct 2027',
          'certificate_url': 'https://flamepay.com/policy/download',
          'timestamp': DateTime.now().toIso8601String(),
        },
      };
    } else if (path == ApiEndpoints.sendOtp) {
      final phone = data['phone'] ?? '9876543210';
      responseData = {
        'success': true,
        'message': 'OTP sent successfully to +91 $phone',
        'data': {'otp': '123456'},
      };
    } else if (path == ApiEndpoints.verifyOtp) {
      final phone = data['phone'] ?? '9876543210';
      final otp = data['otp'] ?? '';
      if (otp == '123456' || otp.isNotEmpty) {
        responseData = {
          'success': true,
          'message': 'OTP verified successfully',
          'data': {
            'token': 'mock_jwt_token_fp_user_101',
            'refreshToken': 'mock_refresh_token_fp_user_101',
            'isNewUser': false,
            'user': {
              'id': 'FP_USER_101',
              'name': currentUserName,
              'phone': '+91 $phone',
              'email': currentUserEmail,
              'isVip': true,
              'kycStatus': 'verified',
              'walletBalance': currentWalletBalance,
              'cibilScore': 780,
            },
          },
        };
      } else {
        return handler.reject(
          DioException(
            requestOptions: options,
            response: Response(
              requestOptions: options,
              statusCode: 400,
              data: {'success': false, 'message': 'Invalid OTP entered'},
            ),
            type: DioExceptionType.badResponse,
          ),
        );
      }
    } else if (path == ApiEndpoints.register) {
      currentUserName = (data['name'] != null && data['name'].toString().trim().isNotEmpty)
          ? data['name'].toString().trim()
          : 'New FlamePay User';
      currentUserEmail = (data['email'] != null && data['email'].toString().trim().isNotEmpty)
          ? data['email'].toString().trim()
          : 'new.user@example.com';
      responseData = {
        'success': true,
        'message': 'Registration successful',
        'data': {
          'token': 'mock_jwt_token_new_user',
          'refreshToken': 'mock_refresh_token_new_user',
          'user': {
            'id': 'FP_USER_102',
            'name': currentUserName,
            'phone': data['phone'] ?? '+91 9876543210',
            'email': currentUserEmail,
            'isVip': false,
            'kycStatus': 'pending',
            'walletBalance': 0.0,
            'cibilScore': 750,
          },
        },
      };
    } else if (path == ApiEndpoints.setMpin) {
      responseData = {
        'success': true,
        'message': 'MPIN created successfully',
      };
    } else if (path == ApiEndpoints.verifyMpin) {
      responseData = {
        'success': true,
        'message': 'MPIN verified',
      };
    } else if (path == ApiEndpoints.userProfile) {
      responseData = {
        'success': true,
        'data': {
          'id': 'FP_USER_101',
          'name': 'Rohit Kumar',
          'phone': '+91 9876543210',
          'email': 'rohit.kumar@example.com',
          'isVip': true,
          'kycStatus': 'verified',
          'walletBalance': currentWalletBalance,
          'cibilScore': 780,
        },
      };
    }

    // HOME & DASHBOARD (Phase 2)
    else if (path == '/home/dashboard') {
      responseData = {
        'success': true,
        'data': {
          'walletBalance': currentWalletBalance,
          'recentTransactions': MockHomeData.mockRecentTransactions,
          'offers': MockHomeData.mockOffers,
        },
      };
    } else if (path == '/services/all') {
      responseData = {
        'success': true,
        'data': MockHomeData.allServices.map((s) => {'id': s.id, 'title': s.title, 'route': s.route}).toList(),
      };
    } else if (path == ApiEndpoints.walletBalance) {
      responseData = {
        'success': true,
        'data': {'balance': currentWalletBalance},
      };
    } else if (path == ApiEndpoints.walletTransactions) {
      responseData = {
        'success': true,
        'data': MockHomeData.mockRecentTransactions,
      };
    
      } else if (path == ApiEndpoints.userUpdateProfile) {
        if (data['name'] != null && data['name'].toString().trim().isNotEmpty) {
          currentUserName = data['name'].toString().trim();
        }
        if (data['email'] != null && data['email'].toString().trim().isNotEmpty) {
          currentUserEmail = data['email'].toString().trim();
        }
        responseData = {
          'success': true,
          'message': 'Profile updated successfully',
          'data': {
            'id': 'FP_USER_101',
            'name': currentUserName,
            'phone': '+91 9876543210',
            'email': currentUserEmail,
            'isVip': true,
            'kycStatus': 'verified',
            'walletBalance': currentWalletBalance,
            'cibilScore': 780,
          },
        };
      } else if (path == ApiEndpoints.walletTransfer) {
        final amount = (data['amount'] as num?)?.toDouble() ?? 100.0;
        final recipient = data['recipient'] ?? 'Mobile / UPI';
        if (currentWalletBalance >= amount) {
          currentWalletBalance -= amount;
        }
        final txnId = 'FP${DateTime.now().millisecondsSinceEpoch}';
        responseData = {
          'success': true,
          'message': 'Transfer successful',
          'data': {
            'transactionId': txnId,
            'operatorRefNumber': 'TXN${10000000 + _random.nextInt(90000000)}',
            'amount': amount,
            'timestamp': DateTime.now().toIso8601String(),
            'status': 'success',
            'serviceType': 'Money Transfer',
            'targetTitle': recipient,
            'paymentMode': 'FlamePay Wallet',
            'cashbackEarned': 5.0,
            'newBalance': currentWalletBalance,
          },
        };
      } else if (path == ApiEndpoints.walletAddMoney) {
      final amt = (data['amount'] as num?)?.toDouble() ?? 500.0;
      currentWalletBalance += amt;
      responseData = {
        'success': true,
        'message': 'Money added successfully',
        'data': {
          'newBalance': currentWalletBalance,
          'transactionId': 'TXN_ADD_${DateTime.now().millisecondsSinceEpoch}',
        },
      };
    }

    // RECHARGE & BILLS (Phase 3)
    else if (path == ApiEndpoints.rechargeOperators) {
      final type = options.queryParameters['type'] ?? 'mobile';
      final list = type == 'dth'
          ? MockRechargeData.dthOperators
          : MockRechargeData.mobileOperators;
      responseData = {
        'success': true,
        'data': list.map((e) => e.toJson()).toList(),
      };
    } else if (path == ApiEndpoints.rechargePlans) {
      responseData = {
        'success': true,
        'data': MockRechargeData.jioPlans.map((e) => e.toJson()).toList(),
      };
    } else if (path == ApiEndpoints.fetchBill) {
      final billerId = data['billerId'] ?? 'tata_power_delhi';
      final consumerNum = data['consumerNumber'] ?? '1002345678';
      final biller = MockRechargeData.billers.firstWhere(
        (b) => b.id == billerId,
        orElse: () => MockRechargeData.billers.first,
      );
      responseData = {
        'success': true,
        'data': {
          'billerId': biller.id,
          'billerName': biller.name,
          'consumerNumber': consumerNum,
          'consumerName': 'Rohit Kumar',
          'billAmount': 1420.00,
          'dueDate': '05 Nov 2026',
          'lateFee': 50.00,
          'billDate': '15 Oct 2026',
          'billNumber': 'BILL/2026/98712',
          'category': biller.type,
        },
      };
    } else if (path == ApiEndpoints.rechargePay) {
      final amount = (data['amount'] as num?)?.toDouble() ?? 299.0;
      final mode = data['paymentMode'] ?? 'FlamePay Wallet';
      final mobile = data['mobileNumber'] ?? '+91 9876543210';
      final operatorId = data['operatorId'] ?? 'Jio';

      if (mode == 'FlamePay Wallet' && currentWalletBalance >= amount) {
        currentWalletBalance -= amount;
      }

      final txnId = 'FP${DateTime.now().millisecondsSinceEpoch}';
      final refNum = 'OP${100000000 + _random.nextInt(900000000)}';

      responseData = {
        'success': true,
        'data': {
          'transactionId': txnId,
          'operatorRefNumber': refNum,
          'amount': amount,
          'timestamp': DateTime.now().toIso8601String(),
          'status': 'success',
          'serviceType': 'Mobile Recharge',
          'targetTitle': '$operatorId Prepaid - $mobile',
          'paymentMode': mode,
          'cashbackEarned': 15.0,
        },
      };
    } else if (path == ApiEndpoints.payBill) {
      final amount = (data['amount'] as num?)?.toDouble() ?? 1420.0;
      final mode = data['paymentMode'] ?? 'FlamePay Wallet';
      final billerId = data['billerId'] ?? 'Tata Power';
      final consumerNum = data['consumerNumber'] ?? '1002345678';

      if (mode == 'FlamePay Wallet' && currentWalletBalance >= amount) {
        currentWalletBalance -= amount;
      }

      final txnId = 'FP${DateTime.now().millisecondsSinceEpoch}';
      final refNum = 'BILL${10000000 + _random.nextInt(90000000)}';

      responseData = {
        'success': true,
        'data': {
          'transactionId': txnId,
          'operatorRefNumber': refNum,
          'amount': amount,
          'timestamp': DateTime.now().toIso8601String(),
          'status': 'success',
          'serviceType': 'Utility Bill Payment',
          'targetTitle': '$billerId ($consumerNum)',
          'paymentMode': mode,
          'cashbackEarned': 50.0,
        },
      };
    }

    if (responseData != null) {
      return handler.resolve(
        Response(
          requestOptions: options,
          statusCode: 200,
          data: responseData,
        ),
      );
    }

    return handler.next(options);
  }
}
