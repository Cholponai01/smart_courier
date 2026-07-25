import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:smart_courier/core/error/failure.dart';
import 'package:smart_courier/core/utils/result.dart';
import 'package:smart_courier/features/auth/domain/entities/user.dart';
import 'package:smart_courier/features/auth/domain/repositories/auth_repository.dart';
import 'package:smart_courier/features/auth/domain/use_cases/login_use_case.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late AuthRepository repository;
  late LoginUseCase useCase;

  const email = 'customer@example.com';
  const password = 'secure-password';
  const user = User(id: 'user-id', email: email, role: UserRole.customer);

  setUp(() {
    repository = MockAuthRepository();
    useCase = LoginUseCase(repository);
  });

  test('returns the authenticated user when credentials are valid', () async {
    when(
      () => repository.login(email: email, password: password),
    ).thenAnswer((_) async => Success(user));

    final result = await useCase(email: email, password: password);

    expect(result, isA<Success<User>>());
    expect((result as Success<User>).data, user);
    verify(() => repository.login(email: email, password: password)).called(1);
  });

  test('propagates a repository failure when login fails', () async {
    const failure = AuthFailure();
    when(
      () => repository.login(email: email, password: password),
    ).thenAnswer((_) async => const ResultFailure(failure));

    final result = await useCase(email: email, password: password);

    expect(result, isA<ResultFailure<User>>());
    expect((result as ResultFailure<User>).failure, failure);
  });
}
