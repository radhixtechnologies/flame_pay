class ApiEndpoints {
  ApiEndpoints._();

  // Auth
  static const String sendOtp = '/auth/send-otp';
  static const String verifyOtp = '/auth/verify-otp';
  static const String register = '/auth/register';
  static const String refreshToken = '/auth/refresh-token';
  static const String logout = '/auth/logout';
  static const String setMpin = '/auth/set-mpin';
  static const String verifyMpin = '/auth/verify-mpin';

  // User
  static const String userProfile = '/user/profile';
  static const String userUpdateProfile = '/user/profile/update';
  static const String kycStatus = '/user/kyc-status';
  static const String kycSubmit = '/user/kyc-submit';

  // Recharge & Bills
  static const String rechargePlans = '/recharge/plans';
  static const String rechargeRecent = '/recharge/recent';
  static const String rechargeOperators = '/recharge/operators';
  static const String rechargePay = '/recharge/pay';

  static const String billCategories = '/bills/categories';
  static const String billers = '/bills/billers';
  static const String fetchBill = '/bills/fetch';
  static const String payBill = '/bills/pay';

  // Financial Services
  static const String insuranceCategories = '/insurance/categories';
  static const String insurancePlans = '/insurance/plans';
  static const String insuranceApply = '/insurance/apply';

  static const String cibilScore = '/cibil/score';
  static const String cibilReport = '/cibil/report';
  static const String cibilFactors = '/cibil/factors';
  static const String cibilCheck = '/cibil/check';

  static const String creditCardCategories = '/credit-cards/categories';
  static const String creditCardsList = '/credit-cards/list';
  static const String creditCardApply = '/credit-cards/apply';

  static const String loanTypes = '/loans/types';
  static const String calculateEmi = '/loans/calculate-emi';
  static const String loanApply = '/loans/apply';
  static const String loanHistory = '/loans/history';

  // Wallet
  static const String walletBalance = '/wallet/balance';
  static const String walletAddMoney = '/wallet/add-money';
  static const String walletWithdraw = '/wallet/withdraw';
  static const String walletTransactions = '/wallet/transactions';
  static const String walletTransfer = '/wallet/transfer';

  // History & Notifications
  static const String transactionsHistory = '/transactions/history';
  static const String transactionDetail = '/transactions/detail';
  static const String notificationsList = '/notifications/list';
  static const String notificationsReadAll = '/notifications/read-all';
  static const String offersList = '/offers/list';
}
