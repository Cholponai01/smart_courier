import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:smart_courier/core/error/failure.dart';
import 'package:smart_courier/features/auth/data/constants/auth_error_messages.dart';
import 'package:smart_courier/features/auth/data/mappers/firebase_exception_mapper.dart';

void main() {
  test('maps invalid login credentials to AuthFailure', () {
    final failure = FirebaseExceptionMapper.fromAuthException(
      FirebaseAuthException(code: 'wrong-password'),
    );

    expect(failure, isA<AuthFailure>());
    expect(failure.message, AuthErrorMessages.incorrectCredentials);
  });

  test('maps register invalid-email to ValidationFailure', () {
    final failure = FirebaseExceptionMapper.fromAuthException(
      FirebaseAuthException(code: 'invalid-email'),
      context: AuthExceptionContext.register,
    );

    expect(failure, isA<ValidationFailure>());
    expect(failure.message, AuthErrorMessages.invalidEmailFormat);
  });

  test('maps email-already-in-use to EmailAlreadyInUseFailure', () {
    final failure = FirebaseExceptionMapper.fromAuthException(
      FirebaseAuthException(code: 'email-already-in-use'),
      context: AuthExceptionContext.register,
    );

    expect(failure, isA<EmailAlreadyInUseFailure>());
    expect(failure.message, AuthErrorMessages.emailAlreadyInUse);
  });

  test('maps too-many-requests to TooManyRequestsFailure', () {
    final failure = FirebaseExceptionMapper.fromAuthException(
      FirebaseAuthException(code: 'too-many-requests'),
    );

    expect(failure, isA<TooManyRequestsFailure>());
    expect(failure.message, AuthErrorMessages.tooManyRequests);
  });

  test('maps operation-not-allowed to a user-friendly message', () {
    final failure = FirebaseExceptionMapper.fromAuthException(
      FirebaseAuthException(code: 'operation-not-allowed'),
    );

    expect(failure, isA<UnknownFailure>());
    expect(failure.message, AuthErrorMessages.signInUnavailable);
  });

  test('sanitizes pigeon platform messages', () {
    final failure = FirebaseExceptionMapper.fromAuthException(
      FirebaseAuthException(
        code: 'unknown',
        message:
            'dev.flutter.pigeon.firebase_auth_platform_interface.'
            'FirebaseAuthHostApi.signInWithEmailAndPassword',
      ),
    );

    expect(failure, isA<UnknownFailure>());
    expect(failure.message, 'Something went wrong. Please try again.');
    expect(failure.message, isNot(contains('pigeon')));
  });
}
