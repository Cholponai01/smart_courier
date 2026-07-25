import 'package:intl_phone_field/phone_number.dart';

abstract final class AuthValidators {
  static final RegExp emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
  static final RegExp passwordDigitRegex = RegExp(r'\d');

  static String? validateRequired(String? value, String errorMessage) {
    if (value == null || value.trim().isEmpty) {
      return errorMessage;
    }
    return null;
  }

  static String? validateEmail(
    String? value, {
    required String requiredMessage,
    required String invalidMessage,
  }) {
    final requiredError = validateRequired(value, requiredMessage);
    if (requiredError != null) {
      return requiredError;
    }

    if (!emailRegex.hasMatch(value!.trim())) {
      return invalidMessage;
    }

    return null;
  }

  static String? validateRegisterPassword(
    String? value, {
    required String requiredMessage,
    required String weakMessage,
  }) {
    final requiredError = validateRequired(value, requiredMessage);
    if (requiredError != null) {
      return requiredError;
    }

    final password = value!;
    if (password.length < 8 || !passwordDigitRegex.hasMatch(password)) {
      return weakMessage;
    }

    return null;
  }

  static String? validateConfirmPassword(
    String? value, {
    required String password,
    required String requiredMessage,
    required String mismatchMessage,
  }) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) {
      return requiredMessage;
    }

    if (trimmed != password) {
      return mismatchMessage;
    }

    return null;
  }

  /// Confirm-password check while typing — waits until the user has entered
  /// as many characters as the password before showing a mismatch.
  static String? validateConfirmPasswordLive(
    String? value, {
    required String password,
    required String mismatchMessage,
  }) {
    final confirm = value ?? '';
    if (confirm.isEmpty || password.isEmpty) {
      return null;
    }

    if (confirm.length < password.length) {
      return null;
    }

    if (confirm != password) {
      return mismatchMessage;
    }

    return null;
  }

  /// Used while the user is typing — never calls [PhoneNumber.isValidNumber]
  /// for partial input (it throws [NumberTooShortException]).
  static String? validateIntlPhoneLenient(
    PhoneNumber? phone, {
    required String requiredMessage,
  }) {
    if (phone == null || phone.number.trim().isEmpty) {
      return requiredMessage;
    }
    return null;
  }

  /// Full E.164 validation — safe to call on submit.
  static String? validateIntlPhoneStrict(
    PhoneNumber? phone, {
    required String requiredMessage,
    required String invalidMessage,
  }) {
    if (phone == null || phone.number.trim().isEmpty) {
      return requiredMessage;
    }

    try {
      return phone.isValidNumber() ? null : invalidMessage;
    } catch (_) {
      return invalidMessage;
    }
  }
}
