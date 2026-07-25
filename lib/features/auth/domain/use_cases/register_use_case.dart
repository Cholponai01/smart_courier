import 'package:smart_courier/core/utils/result.dart';
import 'package:smart_courier/features/auth/domain/entities/user.dart';
import 'package:smart_courier/features/auth/domain/repositories/auth_repository.dart';

class RegisterUseCase {
  const RegisterUseCase(this._repository);

  final AuthRepository _repository;

  Future<Result<User>> call({
    required String email,
    required String password,
    required String name,
    required String phone,
  }) {
    return _repository.register(
      email: email,
      password: password,
      name: name,
      phone: phone,
    );
  }
}
