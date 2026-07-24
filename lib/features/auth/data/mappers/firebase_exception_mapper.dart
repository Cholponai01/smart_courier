import 'package:firebase_auth/firebase_auth.dart';
import 'package:smart_courier/core/error/failure.dart';
import 'package:smart_courier/features/auth/data/constants/auth_error_messages.dart';

abstract final class FirebaseExceptionMapper {
  static Failure fromAuthException(FirebaseAuthException exception) {
    return switch (exception.code) {
      'wrong-password' ||
      'invalid-credential' ||
      'user-not-found' ||
      'invalid-email' => const AuthFailure(
        AuthErrorMessages.incorrectCredentials,
      ),
      'email-already-in-use' => const ValidationFailure(
        AuthErrorMessages.emailAlreadyInUse,
      ),
      'weak-password' => const ValidationFailure(
        AuthErrorMessages.weakPassword,
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
