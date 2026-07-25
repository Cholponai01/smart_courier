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

class EmailAlreadyInUseFailure extends Failure {
  const EmailAlreadyInUseFailure([
    super.message = 'An account with this email already exists',
  ]);
}

class TooManyRequestsFailure extends Failure {
  const TooManyRequestsFailure([
    super.message = 'Too many attempts. Please try again later.',
  ]);
}

class UnknownFailure extends Failure {
  const UnknownFailure([
    super.message = 'Something went wrong. Please try again.',
  ]);
}

class OrderAlreadyTakenFailure extends Failure {
  const OrderAlreadyTakenFailure([
    super.message = 'This order was just taken',
  ]);
}
