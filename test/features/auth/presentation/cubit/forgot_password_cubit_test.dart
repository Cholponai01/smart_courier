import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:smart_courier/core/error/failure.dart';
import 'package:smart_courier/core/utils/result.dart';
import 'package:smart_courier/features/auth/domain/use_cases/send_password_reset_use_case.dart';
import 'package:smart_courier/features/auth/presentation/cubit/forgot_password_cubit.dart';

class MockSendPasswordResetUseCase extends Mock
    implements SendPasswordResetUseCase {}

void main() {
  late SendPasswordResetUseCase useCase;
  late ForgotPasswordCubit cubit;

  setUp(() {
    useCase = MockSendPasswordResetUseCase();
    cubit = ForgotPasswordCubit(useCase);
  });

  blocTest<ForgotPasswordCubit, ForgotPasswordState>(
    'emits submitted when password reset succeeds',
    build: () {
      when(
        () => useCase(email: any(named: 'email')),
      ).thenAnswer((_) async => const Success(Unit.value));
      return cubit;
    },
    act: (cubit) => cubit.submit(email: 'user@example.com'),
    expect: () => [
      const ForgotPasswordLoading(),
      const ForgotPasswordSubmitted(),
    ],
  );

  blocTest<ForgotPasswordCubit, ForgotPasswordState>(
    'emits error when password reset fails',
    build: () {
      when(
        () => useCase(email: any(named: 'email')),
      ).thenAnswer((_) async => const ResultFailure(NetworkFailure()));
      return cubit;
    },
    act: (cubit) => cubit.submit(email: 'user@example.com'),
    expect: () => [
      const ForgotPasswordLoading(),
      const ForgotPasswordError('Network error. Please try again.'),
    ],
  );
}
