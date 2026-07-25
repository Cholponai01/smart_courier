import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:smart_courier/core/utils/result.dart';
import 'package:smart_courier/features/auth/domain/use_cases/send_email_verification_use_case.dart';
import 'package:smart_courier/features/auth/presentation/cubit/resend_email_verification_cubit.dart';

class MockSendEmailVerificationUseCase extends Mock
    implements SendEmailVerificationUseCase {}

void main() {
  late SendEmailVerificationUseCase useCase;
  late ResendEmailVerificationCubit cubit;

  setUp(() {
    useCase = MockSendEmailVerificationUseCase();
    cubit = ResendEmailVerificationCubit(useCase);
  });

  blocTest<ResendEmailVerificationCubit, ResendEmailVerificationState>(
    'emits sent when verification email succeeds',
    build: () {
      when(() => useCase()).thenAnswer((_) async => const Success(Unit.value));
      return cubit;
    },
    act: (cubit) => cubit.resend(),
    expect: () => [
      const ResendEmailVerificationLoading(),
      const ResendEmailVerificationSent(),
    ],
  );
}
