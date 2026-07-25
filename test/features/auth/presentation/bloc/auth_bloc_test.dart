import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:smart_courier/core/error/failure.dart';
import 'package:smart_courier/core/utils/result.dart';
import 'package:smart_courier/features/auth/domain/entities/user.dart';
import 'package:smart_courier/features/auth/domain/use_cases/get_current_user_use_case.dart';
import 'package:smart_courier/features/auth/domain/use_cases/login_use_case.dart';
import 'package:smart_courier/features/auth/domain/use_cases/logout_use_case.dart';
import 'package:smart_courier/features/auth/domain/use_cases/register_use_case.dart';
import 'package:smart_courier/features/auth/presentation/bloc/auth_bloc.dart';

class MockLoginUseCase extends Mock implements LoginUseCase {}

class MockRegisterUseCase extends Mock implements RegisterUseCase {}

class MockLogoutUseCase extends Mock implements LogoutUseCase {}

class MockGetCurrentUserUseCase extends Mock implements GetCurrentUserUseCase {}

void main() {
  late LoginUseCase loginUseCase;
  late RegisterUseCase registerUseCase;
  late LogoutUseCase logoutUseCase;
  late GetCurrentUserUseCase getCurrentUserUseCase;

  const email = 'user@example.com';
  const password = 'password';
  const name = 'Test User';
  const phone = '+10000000000';
  const user = User(id: 'user-id', email: email, role: UserRole.customer);

  setUp(() {
    loginUseCase = MockLoginUseCase();
    registerUseCase = MockRegisterUseCase();
    logoutUseCase = MockLogoutUseCase();
    getCurrentUserUseCase = MockGetCurrentUserUseCase();
  });

  AuthBloc buildBloc() {
    return AuthBloc(
      loginUseCase: loginUseCase,
      registerUseCase: registerUseCase,
      logoutUseCase: logoutUseCase,
      getCurrentUserUseCase: getCurrentUserUseCase,
    );
  }

  blocTest<AuthBloc, AuthState>(
    'emits Authenticated when session check finds a user',
    build: () {
      when(
        () => getCurrentUserUseCase(),
      ).thenAnswer((_) async => const Success(user));
      return buildBloc();
    },
    act: (bloc) => bloc.add(const AuthCheckRequested()),
    expect: () => [const AuthChecking(), Authenticated(user)],
  );

  blocTest<AuthBloc, AuthState>(
    'emits Unauthenticated when session check finds no user',
    build: () {
      when(
        () => getCurrentUserUseCase(),
      ).thenAnswer((_) async => const Success(null));
      return buildBloc();
    },
    act: (bloc) => bloc.add(const AuthCheckRequested()),
    expect: () => [const AuthChecking(), const Unauthenticated()],
  );

  blocTest<AuthBloc, AuthState>(
    'emits AuthError when session check fails',
    build: () {
      when(
        () => getCurrentUserUseCase(),
      ).thenAnswer((_) async => const ResultFailure(UnknownFailure()));
      return buildBloc();
    },
    act: (bloc) => bloc.add(const AuthCheckRequested()),
    expect: () => [
      const AuthChecking(),
      const AuthError('Something went wrong. Please try again.'),
    ],
  );

  blocTest<AuthBloc, AuthState>(
    'emits Authenticated when login succeeds',
    build: () {
      when(
        () => loginUseCase(email: email, password: password),
      ).thenAnswer((_) async => const Success(user));
      return buildBloc();
    },
    act: (bloc) =>
        bloc.add(const LoginRequested(email: email, password: password)),
    expect: () => [const AuthLoading(), Authenticated(user)],
  );

  blocTest<AuthBloc, AuthState>(
    'emits AuthError when login fails',
    build: () {
      when(
        () => loginUseCase(email: email, password: password),
      ).thenAnswer((_) async => const ResultFailure(AuthFailure()));
      return buildBloc();
    },
    act: (bloc) =>
        bloc.add(const LoginRequested(email: email, password: password)),
    expect: () => [
      const AuthLoading(),
      const AuthError('Incorrect email or password'),
    ],
  );

  blocTest<AuthBloc, AuthState>(
    'emits Authenticated when registration succeeds',
    build: () {
      when(
        () => registerUseCase(
          email: email,
          password: password,
          name: name,
          phone: phone,
        ),
      ).thenAnswer((_) async => const Success(user));
      return buildBloc();
    },
    act: (bloc) => bloc.add(
      const RegisterRequested(
        email: email,
        password: password,
        name: name,
        phone: phone,
      ),
    ),
    expect: () => [const AuthLoading(), Authenticated(user)],
  );

  blocTest<AuthBloc, AuthState>(
    'emits AuthError when registration fails',
    build: () {
      when(
        () => registerUseCase(
          email: email,
          password: password,
          name: name,
          phone: phone,
        ),
      ).thenAnswer(
        (_) async => const ResultFailure(
          ValidationFailure('An account with this email already exists'),
        ),
      );
      return buildBloc();
    },
    act: (bloc) => bloc.add(
      const RegisterRequested(
        email: email,
        password: password,
        name: name,
        phone: phone,
      ),
    ),
    expect: () => [
      const AuthLoading(),
      const AuthError('An account with this email already exists'),
    ],
  );

  blocTest<AuthBloc, AuthState>(
    'emits Unauthenticated when logout succeeds',
    build: () {
      when(
        () => logoutUseCase(),
      ).thenAnswer((_) async => const Success(Unit.value));
      return buildBloc();
    },
    act: (bloc) => bloc.add(const LogoutRequested()),
    expect: () => [const AuthLoading(), const Unauthenticated()],
  );

  blocTest<AuthBloc, AuthState>(
    'emits AuthError when logout fails',
    build: () {
      when(
        () => logoutUseCase(),
      ).thenAnswer((_) async => const ResultFailure(UnknownFailure()));
      return buildBloc();
    },
    act: (bloc) => bloc.add(const LogoutRequested()),
    expect: () => [
      const AuthLoading(),
      const AuthError('Something went wrong. Please try again.'),
    ],
  );
}
