import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:smart_courier/features/auth/domain/repositories/auth_repository.dart';
import 'package:smart_courier/features/auth/domain/use_cases/logout_use_case.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late AuthRepository repository;
  late LogoutUseCase useCase;

  setUp(() {
    repository = MockAuthRepository();
    useCase = LogoutUseCase(repository);
  });

  test('completes when the repository clears the session', () async {
    when(() => repository.logout()).thenAnswer((_) async {});

    await useCase();

    verify(() => repository.logout()).called(1);
  });

  test('propagates a repository failure when logout fails', () async {
    final failure = Exception('logout failed');
    when(() => repository.logout()).thenThrow(failure);

    expect(() => useCase(), throwsA(same(failure)));
  });
}
