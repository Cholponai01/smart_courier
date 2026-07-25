import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:smart_courier/core/error/failure.dart';
import 'package:smart_courier/core/utils/result.dart';
import 'package:smart_courier/features/auth/domain/entities/user.dart';
import 'package:smart_courier/features/auth/domain/repositories/auth_repository.dart';
import 'package:smart_courier/features/auth/domain/use_cases/get_current_user_use_case.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late AuthRepository repository;
  late GetCurrentUserUseCase useCase;

  setUp(() {
    repository = MockAuthRepository();
    useCase = GetCurrentUserUseCase(repository);
  });

  test('returns the current user when a session exists', () async {
    const user = User(
      id: 'user-id',
      email: 'courier@example.com',
      role: UserRole.courier,
    );
    when(
      () => repository.getCurrentUser(),
    ).thenAnswer((_) async => const Success(user));

    final result = await useCase();

    expect(result, isA<Success<User?>>());
    expect((result as Success<User?>).data, user);
    verify(() => repository.getCurrentUser()).called(1);
  });

  test('returns null when no authenticated session exists', () async {
    when(
      () => repository.getCurrentUser(),
    ).thenAnswer((_) async => const Success(null));

    final result = await useCase();

    expect(result, isA<Success<User?>>());
    expect((result as Success<User?>).data, isNull);
  });

  test('propagates a repository failure when session lookup fails', () async {
    const failure = UnknownFailure();
    when(
      () => repository.getCurrentUser(),
    ).thenAnswer((_) async => const ResultFailure(failure));

    final result = await useCase();

    expect(result, isA<ResultFailure<User?>>());
    expect((result as ResultFailure<User?>).failure, failure);
  });
}
