import 'package:smart_courier/features/auth/domain/entities/user.dart';

abstract interface class AuthRepository {
  /// Creates an account whose initial role is [UserRole.customer].
  Future<User> register({
    required String email,
    required String password,
    required String name,
    required String phone,
  });

  Future<User> login({required String email, required String password});

  Future<void> logout();

  Future<User?> getCurrentUser();
}
