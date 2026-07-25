import 'package:smart_courier/core/utils/result.dart';
import 'package:smart_courier/features/auth/domain/entities/user.dart';

abstract interface class AuthRepository {
  /// Creates an account whose initial role is [UserRole.customer].
  Future<Result<User>> register({
    required String email,
    required String password,
    required String name,
    required String phone,
  });

  Future<Result<User>> login({required String email, required String password});

  Future<Result<Unit>> logout();

  Future<Result<User?>> getCurrentUser();

  Future<Result<Unit>> sendPasswordResetEmail({required String email});

  Future<Result<Unit>> sendEmailVerification();
}
