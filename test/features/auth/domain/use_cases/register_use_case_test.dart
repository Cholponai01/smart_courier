import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:smart_courier/features/auth/domain/entities/user.dart';
import 'package:smart_courier/features/auth/domain/repositories/auth_repository.dart';
import 'package:smart_courier/features/auth/domain/use_cases/register_use_case.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late AuthRepository repository;
  late RegisterUseCase useCase;

  const email = 'customer@example.com';
  const password = 'secure-password';
  const name = 'Customer User';
  const phone = '+10000000000';
  const user = User(id: 'user-id', email: email, role: UserRole.customer);

  setUp(() {
    repository = MockAuthRepository();
    useCase = RegisterUseCase(repository);
  });

  test('returns a customer when registration succeeds', () async {
    when(
      () => repository.register(
        email: email,
        password: password,
        name: name,
        phone: phone,
      ),
    ).thenAnswer((_) async => user);

    final result = await useCase(
      email: email,
      password: password,
      name: name,
      phone: phone,
    );

    expect(result, user);
    expect(result.role, UserRole.customer);
    verify(
      () => repository.register(
        email: email,
        password: password,
        name: name,
        phone: phone,
      ),
    ).called(1);
  });

  test('propagates a repository failure when registration fails', () async {
    final failure = Exception('registration failed');
    when(
      () => repository.register(
        email: email,
        password: password,
        name: name,
        phone: phone,
      ),
    ).thenThrow(failure);

    expect(
      () => useCase(email: email, password: password, name: name, phone: phone),
      throwsA(same(failure)),
    );
  });
}
