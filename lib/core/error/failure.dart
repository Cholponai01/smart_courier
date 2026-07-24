sealed class Failure implements Exception {
  const Failure(this.message);

  final String message;
}

class AuthFailure extends Failure {
  const AuthFailure([super.message = 'Incorrect email or password']);
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'Network error. Please try again.']);
}

class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

class UnknownFailure extends Failure {
  const UnknownFailure([
    super.message = 'Something went wrong. Please try again.',
  ]);
}
