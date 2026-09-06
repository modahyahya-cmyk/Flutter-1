import '../../config/app_config.dart';

class Validators {
  Validators._();

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) return 'Email is required';
    if (!AppConfig.isValidEmail(value.trim())) return 'Enter a valid email address';
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (!AppConfig.isValidPassword(value)) {
      return 'Password must be at least ${AppConfig.PASSWORD_MIN_LENGTH} chars '
          'with a mix of letters and numbers';
    }
    return null;
  }

  static String? required(String? value, [String field = 'This field']) {
    if (value == null || value.isEmpty) return '$field is required';
    return null;
  }

  static String? optionalPhone(String? value) {
    if (value == null || value.isEmpty) return null;
    if (value.length < 7) return 'Enter a valid phone number';
    return null;
  }
}
