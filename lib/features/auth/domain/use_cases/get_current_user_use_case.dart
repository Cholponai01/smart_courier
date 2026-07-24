import 'package:smart_courier/features/auth/domain/entities/user.dart';
import 'package:smart_courier/features/auth/domain/repositories/auth_repository.dart';

class GetCurrentUserUseCase {
  const GetCurrentUserUseCase(this._repository);

  final AuthRepository _repository;

  Future<User?> call() {
    return _repository.getCurrentUser();
  }
}
