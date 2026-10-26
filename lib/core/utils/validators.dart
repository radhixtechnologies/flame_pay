class Validators {
  Validators._();

  static String? validateMobile(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Mobile number is required';
    }
    final clean = value.replaceAll(RegExp(r'\s+'), '');
    if (!RegExp(r'^[6-9]\d{9}$').hasMatch(clean)) {
      return 'Enter a valid 10-digit mobile number';
    }
    return null;
  }

  static String? validateOtp(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'OTP is required';
    }
    if (value.trim().length != 6 || !RegExp(r'^\d{6}$').hasMatch(value)) {
      return 'Enter a valid 6-digit OTP';
    }
    return null;
  }

  static String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Full name is required';
    }
    if (value.trim().length < 3) {
      return 'Name must be at least 3 characters';
    }
    if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value.trim())) {
      return 'Name should contain letters and spaces only';
    }
    return null;
  }

  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email address is required';
    }
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Enter a valid email address';
    }
    return null;
  }

  static String? validatePan(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'PAN number is required';
    }
    final upper = value.trim().toUpperCase();
    if (!RegExp(r'^[A-Z]{5}[0-9]{4}[A-Z]$').hasMatch(upper)) {
      return 'Enter a valid PAN (e.g. ABCDE1234F)';
    }
    return null;
  }

  static String? validateMpin(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'MPIN is required';
    }
    if (value.trim().length != 4 || !RegExp(r'^\d{4}$').hasMatch(value)) {
      return 'MPIN must be 4 digits';
    }
    return null;
  }

  static String? validatePincode(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Pincode is required';
    }
    if (!RegExp(r'^\d{6}$').hasMatch(value.trim())) {
      return 'Enter a valid 6-digit pincode';
    }
    return null;
  }

  static String? validateAmount(
    String? value, {
    double min = 10,
    double max = 10000,
    double? maxBalance,
  }) {
    if (value == null || value.trim().isEmpty) {
      return 'Amount is required';
    }
    final amt = double.tryParse(value.trim());
    if (amt == null || amt <= 0) {
      return 'Enter a valid amount';
    }
    if (amt < min) {
      return 'Minimum amount is ₹${min.toInt()}';
    }
    if (amt > max) {
      return 'Maximum amount is ₹${max.toInt()}';
    }
    if (maxBalance != null && amt > maxBalance) {
      return 'Amount exceeds wallet balance (₹${maxBalance.toStringAsFixed(2)})';
    }
    return null;
  }

  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }
}
