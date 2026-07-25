import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:smart_courier/core/utils/result.dart';
import 'package:smart_courier/features/auth/domain/use_cases/send_email_verification_use_case.dart';

part 'resend_email_verification_state.dart';

class ResendEmailVerificationCubit extends Cubit<ResendEmailVerificationState> {
  ResendEmailVerificationCubit(this._sendEmailVerificationUseCase)
    : super(const ResendEmailVerificationInitial());

  final SendEmailVerificationUseCase _sendEmailVerificationUseCase;

  Future<void> resend() async {
    emit(const ResendEmailVerificationLoading());
    final result = await _sendEmailVerificationUseCase();
    switch (result) {
      case Success():
        emit(const ResendEmailVerificationSent());
      case ResultFailure(:final failure):
        emit(ResendEmailVerificationError(failure.message));
    }
  }
}
