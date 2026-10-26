import 'package:intl/intl.dart';

class Formatters {
  Formatters._();

  static final _currencyFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 2,
  );

  static final _currencyFormatNoDecimals = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 0,
  );

  static String formatCurrency(num amount) => _currencyFormat.format(amount);
  static String formatCurrencyCompact(num amount) => _currencyFormatNoDecimals.format(amount);

  static String formatDate(DateTime date) => DateFormat('dd MMM yyyy').format(date);
  static String formatDateTime(DateTime date) => DateFormat('dd MMM yyyy, hh:mm a').format(date);

  static String maskPhone(String phone) {
    final clean = phone.replaceAll(RegExp(r'[^0-9]'), '');
    if (clean.length < 10) return phone;
    final last10 = clean.substring(clean.length - 10);
    return '+91 ${last10.substring(0, 2)}*** ***${last10.substring(7)}';
  }

  static String maskAadhaar(String aadhaar) {
    final clean = aadhaar.replaceAll(RegExp(r'\s+'), '');
    if (clean.length != 12) return aadhaar;
    return '•••• •••• ${clean.substring(8)}';
  }

  static String maskPan(String pan) {
    final clean = pan.trim().toUpperCase();
    if (clean.length != 10) return pan;
    return '${clean.substring(0, 5)}****${clean.substring(9)}';
  }
}
