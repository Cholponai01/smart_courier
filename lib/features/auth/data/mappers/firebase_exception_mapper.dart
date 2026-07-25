import 'package:firebase_auth/firebase_auth.dart';
import 'package:smart_courier/core/error/failure.dart';
import 'package:smart_courier/features/auth/data/constants/auth_error_messages.dart';

enum AuthExceptionContext { login, register, passwordReset }

abstract final class FirebaseExceptionMapper {
  static Failure fromAuthException(
    FirebaseAuthException exception, {
    AuthExceptionContext context = AuthExceptionContext.login,
  }) {
    return switch (exception.code) {
      'wrong-password' || 'invalid-credential' || 'user-not-found' =>
        const AuthFailure(AuthErrorMessages.incorrectCredentials),
      'invalid-email' => _mapInvalidEmail(context),
      'email-already-in-use' => const EmailAlreadyInUseFailure(
        AuthErrorMessages.emailAlreadyInUse,
      ),
      'weak-password' => const ValidationFailure(
        AuthErrorMessages.weakPassword,
      ),
      'too-many-requests' => const TooManyRequestsFailure(
        AuthErrorMessages.tooManyRequests,
      ),
      'network-request-failed' => const NetworkFailure(),
      'operation-not-allowed' => const UnknownFailure(
        AuthErrorMessages.signInUnavailable,
      ),
      'internal-error' => const UnknownFailure(),
      _ => _mapUnknownAuthException(exception),
    };
  }

  static Failure fromFirebaseException(FirebaseException exception) {
    if (exception.code == 'unavailable' ||
        exception.code == 'network-request-failed') {
      return const NetworkFailure();
    }

    if (_isTechnicalMessage(exception.message)) {
      return const UnknownFailure();
    }

    return UnknownFailure(exception.message ?? 'Request failed');
  }

  static Failure _mapInvalidEmail(AuthExceptionContext context) {
    return switch (context) {
      AuthExceptionContext.register || AuthExceptionContext.passwordReset =>
        const ValidationFailure(AuthErrorMessages.invalidEmailFormat),
      AuthExceptionContext.login => const AuthFailure(
        AuthErrorMessages.incorrectCredentials,
      ),
    };
  }

  static Failure _mapUnknownAuthException(FirebaseAuthException exception) {
    if (_isTechnicalMessage(exception.message)) {
      return const UnknownFailure();
    }

    return const UnknownFailure();
  }

  static bool _isTechnicalMessage(String? message) {
    if (message == null || message.trim().isEmpty) {
      return true;
    }

    final normalized = message.toLowerCase();

    return normalized.contains('pigeon') ||
        normalized.contains('firebaseauthhostapi') ||
        normalized.contains('platformexception') ||
        normalized.contains('channel-error');
  }
}
