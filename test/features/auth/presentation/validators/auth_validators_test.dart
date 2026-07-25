import 'package:flutter_test/flutter_test.dart';
import 'package:smart_courier/features/auth/presentation/validators/auth_validators.dart';

void main() {
  group('validateEmail', () {
    test('returns required message when empty', () {
      expect(
        AuthValidators.validateEmail(
          '',
          requiredMessage: 'Email is required',
          invalidMessage: 'Invalid email',
        ),
        'Email is required',
      );
    });

    test('returns invalid message for malformed email', () {
      expect(
        AuthValidators.validateEmail(
          'not-an-email',
          requiredMessage: 'Email is required',
          invalidMessage: 'Invalid email',
        ),
        'Invalid email',
      );
    });

    test('returns null for valid email', () {
      expect(
        AuthValidators.validateEmail(
          'user@example.com',
          requiredMessage: 'Email is required',
          invalidMessage: 'Invalid email',
        ),
        isNull,
      );
    });
  });

  group('validateRegisterPassword', () {
    test('returns weak message when password has no digit', () {
      expect(
        AuthValidators.validateRegisterPassword(
          'password',
          requiredMessage: 'Required',
          weakMessage: 'Weak password',
        ),
        'Weak password',
      );
    });

    test('returns null for valid password', () {
      expect(
        AuthValidators.validateRegisterPassword(
          'password1',
          requiredMessage: 'Required',
          weakMessage: 'Weak password',
        ),
        isNull,
      );
    });
  });

  group('validateConfirmPasswordLive', () {
    test('returns mismatch when full confirm does not match password', () {
      expect(
        AuthValidators.validateConfirmPasswordLive(
          'password2',
          password: 'password1',
          mismatchMessage: 'Mismatch',
        ),
        'Mismatch',
      );
    });

    test('returns null while confirm is shorter than password', () {
      expect(
        AuthValidators.validateConfirmPasswordLive(
          'pass',
          password: 'password1',
          mismatchMessage: 'Mismatch',
        ),
        isNull,
      );
    });

    test('returns null while confirm is still empty', () {
      expect(
        AuthValidators.validateConfirmPasswordLive(
          '',
          password: 'password1',
          mismatchMessage: 'Mismatch',
        ),
        isNull,
      );
    });
  });

  group('validateIntlPhoneLenient', () {
    test('returns required message when phone is empty', () {
      expect(
        AuthValidators.validateIntlPhoneLenient(
          null,
          requiredMessage: 'Phone required',
        ),
        'Phone required',
      );
    });
  });
}
