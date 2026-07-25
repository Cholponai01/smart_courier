import 'package:smart_courier/core/utils/result.dart';
import 'package:smart_courier/features/auth/domain/repositories/auth_repository.dart';

class SendPasswordResetUseCase {
  const SendPasswordResetUseCase(this._repository);

  final AuthRepository _repository;

  Future<Result<Unit>> call({required String email}) {
    return _repository.sendPasswordResetEmail(email: email);
  }
}
