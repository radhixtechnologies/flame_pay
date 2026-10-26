import '../models/notification_model.dart';
import '../models/transaction_model.dart';
import '../models/offer_model.dart';
import '../models/faq_model.dart';

class MockPhase5Data {
  MockPhase5Data._();

  static final List<TransactionModel> extendedTransactions = [
    TransactionModel(
      id: 'FP2026102601',
      title: 'Jio 5G Unlimited Recharge',
      subtitle: '+91 9876543210 • Mobile Recharge',
      amount: 349.00,
      timestamp: DateTime.now().subtract(const Duration(minutes: 45)),
      status: 'success',
      category: 'recharge',
      operatorName: 'Jio',
      mobile: '+91 9876543210',
    ),
    TransactionModel(
      id: 'FP2026102502',
      title: 'Tata Power Electricity Bill',
      subtitle: 'Consumer #1002345678 • Electricity',
      amount: 1420.00,
      timestamp: DateTime.now().subtract(const Duration(hours: 18)),
      status: 'success',
      category: 'bill',
    ),
    TransactionModel(
      id: 'FP2026102403',
      title: 'FlamePay Wallet Top-up',
      subtitle: 'HDFC Bank Netbanking • Wallet',
      amount: 2000.00,
      timestamp: DateTime.now().subtract(const Duration(days: 2)),
      status: 'success',
      category: 'wallet',
    ),
    TransactionModel(
      id: 'FP2026102204',
      title: 'Airtel Digital TV DTH',
      subtitle: 'Smart Card #301928374 • DTH',
      amount: 450.00,
      timestamp: DateTime.now().subtract(const Duration(days: 4)),
      status: 'success',
      category: 'recharge',
      operatorName: 'airtel',
    ),
    TransactionModel(
      id: 'FP2026102005',
      title: 'Indraprastha Gas Piped',
      subtitle: 'CRN #918273645 • Piped Gas',
      amount: 860.00,
      timestamp: DateTime.now().subtract(const Duration(days: 6)),
      status: 'success',
      category: 'bill',
    ),
    TransactionModel(
      id: 'FP2026101806',
      title: 'Cashback Received',
      subtitle: 'Electricity Bill Reward • FlamePay Cash',
      amount: 50.00,
      timestamp: DateTime.now().subtract(const Duration(days: 8)),
      status: 'success',
      category: 'wallet',
    ),
    TransactionModel(
      id: 'FP2026101507',
      title: 'FASTag Toll Top-up',
      subtitle: 'MH02EK9921 • FASTag',
      amount: 500.00,
      timestamp: DateTime.now().subtract(const Duration(days: 11)),
      status: 'success',
      category: 'recharge',
    ),
  ];

  static const List<OfferModel> extendedOffers = [
    OfferModel(
      id: 'OFF_POWER50',
      title: 'Flat ₹50 Bill Cashback',
      description: 'Pay your electricity or piped gas bill above ₹800 and get instant ₹50 cashback in wallet.',
      code: 'POWER50',
      discount: '₹50 OFF',
      category: 'Bills',
      bannerColor: '#0F4CC9',
    ),
    OfferModel(
      id: 'OFF_RECHARGE15',
      title: '15% Off Mobile Recharge',
      description: 'Valid on all Airtel, Jio, and Vi prepaid recharges of ₹299 or above.',
      code: 'FLAME15',
      discount: '15% OFF',
      category: 'Recharge',
      bannerColor: '#FF6B00',
    ),
    OfferModel(
      id: 'OFF_LOANZERO',
      title: 'Zero Processing Fee on Loans',
      description: 'Get pre-approved instant personal loans with 100% processing fee waiver.',
      code: 'ZEROFEE',
      discount: '100% WAIVER',
      category: 'Loans',
      bannerColor: '#12B76A',
    ),
    OfferModel(
      id: 'OFF_HEALTH20',
      title: '20% Off Care Health Insurance',
      description: 'Get comprehensive family health cover starting @ ₹480/month with zero copayment.',
      code: 'HEALTH20',
      discount: '20% OFF',
      category: 'Insurance',
      bannerColor: '#7C3AED',
    ),
    OfferModel(
      id: 'OFF_CARD500',
      title: '₹500 Welcome Voucher on Credit Card',
      description: 'Apply for HDFC Millennia or SBI SimplyCLICK card and receive ₹500 Amazon Gift Card.',
      code: 'CARD500',
      discount: '₹500 GIFT',
      category: 'Cards',
      bannerColor: '#E5383B',
    ),
  ];

  static final List<NotificationModel> notifications = [
    NotificationModel(
      id: 'NOTIF_1',
      title: 'Payment Successful',
      message: '₹349 paid for Jio Prepaid recharge (+91 9876543210). Cashback of ₹15 credited.',
      timestamp: DateTime.now().subtract(const Duration(minutes: 42)),
      isRead: false,
      category: 'transaction',
    ),
    NotificationModel(
      id: 'NOTIF_2',
      title: 'Electricity Bill Due Soon',
      message: 'Tata Power bill of ₹1,420 is due on 05 Nov 2026. Pay now to avoid late fees.',
      timestamp: DateTime.now().subtract(const Duration(hours: 5)),
      isRead: false,
      category: 'transaction',
    ),
    NotificationModel(
      id: 'NOTIF_3',
      title: 'Exclusive Offer For You!',
      message: 'Use code FLAME15 to get up to ₹50 cashback on your next mobile recharge.',
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
      isRead: true,
      category: 'offer',
    ),
    NotificationModel(
      id: 'NOTIF_4',
      title: 'CIBIL Score Updated',
      message: 'Your monthly CIBIL score is 785 (Excellent). Check your detailed report now.',
      timestamp: DateTime.now().subtract(const Duration(days: 3)),
      isRead: true,
      category: 'security',
    ),
  ];

  static const List<FaqItemModel> faqs = [
    FaqItemModel(
      category: 'Wallet & Payments',
      question: 'How do I add money to my FlamePay Wallet?',
      answer: 'Go to Wallet > Add Money, enter the desired amount, and pay using UPI, Debit Card, Credit Card, or Netbanking. Money is credited instantly.',
    ),
    FaqItemModel(
      category: 'Wallet & Payments',
      question: 'Are there any charges for wallet transactions?',
      answer: 'No, all wallet peer-to-peer transfers, bill payments, and recharges are 100% free with zero convenience fees.',
    ),
    FaqItemModel(
      category: 'Recharge & Bills',
      question: 'What if my recharge or bill payment fails?',
      answer: 'If money was deducted, our automated refund system initiates an instant refund to your FlamePay Wallet within 5 minutes.',
    ),
    FaqItemModel(
      category: 'KYC & Security',
      question: 'Why do I need to complete full KYC?',
      answer: 'As per RBI guidelines, completing full KYC increases your monthly wallet limit from ₹10,000 to ₹2,00,000 and unlocks personal loan features.',
    ),
    FaqItemModel(
      category: 'KYC & Security',
      question: 'How secure is FlamePay?',
      answer: 'FlamePay uses 256-bit bank-grade TLS encryption, PCI-DSS Level 1 compliance, and mandatory 6-digit MPIN or Biometrics for all financial transactions.',
    ),
  ];
}
