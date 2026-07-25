import 'package:smart_courier/core/utils/result.dart';
import 'package:smart_courier/features/auth/domain/repositories/auth_repository.dart';

class SendEmailVerificationUseCase {
  const SendEmailVerificationUseCase(this._repository);

  final AuthRepository _repository;

  Future<Result<Unit>> call() {
    return _repository.sendEmailVerification();
  }
}
