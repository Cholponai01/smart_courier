import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:smart_courier/core/router/app_router.dart';
import 'package:smart_courier/core/router/app_routes.dart';
import 'package:smart_courier/core/theme/app_theme.dart';
import 'package:smart_courier/core/utils/result.dart';
import 'package:smart_courier/features/auth/domain/use_cases/send_password_reset_use_case.dart';
import 'package:smart_courier/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:smart_courier/features/auth/presentation/cubit/forgot_password_cubit.dart';
import 'package:smart_courier/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:smart_courier/features/auth/presentation/screens/login_screen.dart';
import 'package:smart_courier/l10n/app_localizations.dart';
import '../../../../helpers/pump_localized_widget.dart';

class MockAuthBloc extends MockBloc<AuthEvent, AuthState> implements AuthBloc {}

class MockSendPasswordResetUseCase extends Mock
    implements SendPasswordResetUseCase {}

void main() {
  late MockAuthBloc authBloc;
  late MockSendPasswordResetUseCase sendPasswordResetUseCase;
  final sl = GetIt.instance;

  setUp(() {
    authBloc = MockAuthBloc();
    sendPasswordResetUseCase = MockSendPasswordResetUseCase();

    if (sl.isRegistered<ForgotPasswordCubit>()) {
      sl.unregister<ForgotPasswordCubit>();
    }
    sl.registerFactory<ForgotPasswordCubit>(
      () => ForgotPasswordCubit(sendPasswordResetUseCase),
    );
  });

  tearDown(() {
    if (sl.isRegistered<ForgotPasswordCubit>()) {
      sl.unregister<ForgotPasswordCubit>();
    }
  });

  testWidgets('navigates to forgot password screen from login', (tester) async {
    whenListen(
      authBloc,
      const Stream<AuthState>.empty(),
      initialState: const Unauthenticated(),
    );

    final router = createAppRouter(authBloc);

    await tester.pumpWidget(
      BlocProvider<AuthBloc>.value(
        value: authBloc,
        child: MaterialApp.router(
          theme: AppTheme.lightTheme,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          routerConfig: router,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('login_forgot_password_link')));
    await tester.pumpAndSettle();

    expect(find.byType(ForgotPasswordScreen), findsOneWidget);
    expect(router.state.matchedLocation, AppRoutes.forgotPassword);
  });

  testWidgets('shows success view after reset link is sent', (tester) async {
    when(
      () => sendPasswordResetUseCase(email: any(named: 'email')),
    ).thenAnswer((_) async => const Success(Unit.value));

    await pumpLocalizedWidget(tester, const ForgotPasswordScreen());
    await tester.enterText(
      find.byKey(const Key('forgot_password_email_field')),
      'user@example.com',
    );
    await tester.tap(find.byKey(const Key('forgot_password_submit_button')));
    await tester.pumpAndSettle();

    expect(find.text('Check your email'), findsOneWidget);
    expect(
      find.text(
        'If an account exists for this email, a reset link has been sent.',
      ),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('forgot_password_submit_button')),
      findsNothing,
    );
    expect(
      find.byKey(const Key('forgot_password_back_to_sign_in_button')),
      findsOneWidget,
    );
  });

  testWidgets('navigates to login when app resumes after reset link sent', (
    tester,
  ) async {
    final binding = TestWidgetsFlutterBinding.ensureInitialized();

    when(
      () => sendPasswordResetUseCase(email: any(named: 'email')),
    ).thenAnswer((_) async => const Success(Unit.value));
    whenListen(
      authBloc,
      const Stream<AuthState>.empty(),
      initialState: const Unauthenticated(),
    );

    final router = createAppRouter(authBloc);

    await tester.pumpWidget(
      BlocProvider<AuthBloc>.value(
        value: authBloc,
        child: MaterialApp.router(
          theme: AppTheme.lightTheme,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          routerConfig: router,
        ),
      ),
    );
    router.go(AppRoutes.forgotPassword);
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const Key('forgot_password_email_field')),
      'user@example.com',
    );
    await tester.tap(find.byKey(const Key('forgot_password_submit_button')));
    await tester.pumpAndSettle();

    binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpAndSettle();

    expect(find.byType(LoginScreen), findsOneWidget);
    expect(router.state.uri.queryParameters['passwordReset'], '1');
    expect(
      find.text(
        'If you updated your password, sign in with your new password.',
      ),
      findsOneWidget,
    );
  });
}
