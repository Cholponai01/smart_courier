import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:smart_courier/core/utils/result.dart';
import 'package:smart_courier/features/auth/domain/use_cases/send_password_reset_use_case.dart';

part 'forgot_password_state.dart';

class ForgotPasswordCubit extends Cubit<ForgotPasswordState> {
  ForgotPasswordCubit(this._sendPasswordResetUseCase)
    : super(const ForgotPasswordInitial());

  final SendPasswordResetUseCase _sendPasswordResetUseCase;

  Future<void> submit({required String email}) async {
    emit(const ForgotPasswordLoading());
    final result = await _sendPasswordResetUseCase(email: email);
    switch (result) {
      case Success():
        emit(const ForgotPasswordSubmitted());
      case ResultFailure(:final failure):
        emit(ForgotPasswordError(failure.message));
    }
  }
}
