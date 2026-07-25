part of 'resend_email_verification_cubit.dart';

sealed class ResendEmailVerificationState extends Equatable {
  const ResendEmailVerificationState();

  @override
  List<Object?> get props => [];
}

final class ResendEmailVerificationInitial
    extends ResendEmailVerificationState {
  const ResendEmailVerificationInitial();
}

final class ResendEmailVerificationLoading
    extends ResendEmailVerificationState {
  const ResendEmailVerificationLoading();
}

final class ResendEmailVerificationSent extends ResendEmailVerificationState {
  const ResendEmailVerificationSent();
}

final class ResendEmailVerificationError extends ResendEmailVerificationState {
  const ResendEmailVerificationError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
