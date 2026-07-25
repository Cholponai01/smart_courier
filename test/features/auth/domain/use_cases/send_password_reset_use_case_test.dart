import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:smart_courier/core/utils/result.dart';
import 'package:smart_courier/features/auth/domain/repositories/auth_repository.dart';
import 'package:smart_courier/features/auth/domain/use_cases/send_password_reset_use_case.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late AuthRepository repository;
  late SendPasswordResetUseCase useCase;

  setUp(() {
    repository = MockAuthRepository();
    useCase = SendPasswordResetUseCase(repository);
  });

  test('returns success result from repository', () async {
    when(
      () => repository.sendPasswordResetEmail(email: 'user@example.com'),
    ).thenAnswer((_) async => const Success(Unit.value));

    final result = await useCase(email: 'user@example.com');

    expect(result, isA<Success<Unit>>());
    verify(
      () => repository.sendPasswordResetEmail(email: 'user@example.com'),
    ).called(1);
  });
}
