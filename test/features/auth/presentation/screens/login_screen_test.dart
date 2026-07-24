import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:smart_courier/core/router/app_routes.dart';
import 'package:smart_courier/core/router/app_router.dart';
import 'package:smart_courier/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:smart_courier/features/auth/presentation/screens/login_screen.dart';
import 'package:smart_courier/features/auth/presentation/screens/register_screen.dart';
import 'package:smart_courier/l10n/app_localizations.dart';
import 'package:smart_courier/core/theme/app_theme.dart';
import '../../../../helpers/pump_localized_widget.dart';

class MockAuthBloc extends MockBloc<AuthEvent, AuthState> implements AuthBloc {}

void main() {
  late MockAuthBloc authBloc;

  setUpAll(() {
    registerFallbackValue(
      const LoginRequested(email: 'fallback@example.com', password: 'fallback'),
    );
  });

  setUp(() {
    authBloc = MockAuthBloc();
  });

  Widget buildSubject(Widget child) {
    return BlocProvider<AuthBloc>.value(value: authBloc, child: child);
  }

  testWidgets('shows loading indicator while auth is in progress', (
    tester,
  ) async {
    whenListen(
      authBloc,
      const Stream<AuthState>.empty(),
      initialState: const AuthLoading(),
    );

    await pumpLocalizedWidget(tester, buildSubject(const LoginScreen()));

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('shows inline validation when required fields are empty', (
    tester,
  ) async {
    whenListen(
      authBloc,
      const Stream<AuthState>.empty(),
      initialState: const Unauthenticated(),
    );

    await pumpLocalizedWidget(tester, buildSubject(const LoginScreen()));
    await tester.tap(find.byKey(const Key('login_submit_button')));
    await tester.pump();

    expect(find.text('Email is required'), findsOneWidget);
    expect(find.text('Password is required'), findsOneWidget);
    verifyNever(() => authBloc.add(any()));
  });

  testWidgets('dispatches LoginRequested when form is valid', (tester) async {
    whenListen(
      authBloc,
      const Stream<AuthState>.empty(),
      initialState: const Unauthenticated(),
    );

    await pumpLocalizedWidget(tester, buildSubject(const LoginScreen()));
    await tester.enterText(
      find.byKey(const Key('login_email_field')),
      'user@example.com',
    );
    await tester.enterText(
      find.byKey(const Key('login_password_field')),
      'password',
    );
    await tester.tap(find.byKey(const Key('login_submit_button')));
    await tester.pump();

    verify(
      () => authBloc.add(
        const LoginRequested(email: 'user@example.com', password: 'password'),
      ),
    ).called(1);
  });

  testWidgets('shows auth error message in a snackbar', (tester) async {
    whenListen(
      authBloc,
      Stream.fromIterable([const AuthError('Incorrect email or password')]),
      initialState: const Unauthenticated(),
    );

    await pumpLocalizedWidget(tester, buildSubject(const LoginScreen()));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Incorrect email or password'), findsOneWidget);
  });

  testWidgets('navigates to register screen via go_router', (tester) async {
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

    expect(find.byType(LoginScreen), findsOneWidget);

    await tester.tap(find.byKey(const Key('login_register_link')));
    await tester.pumpAndSettle();

    expect(find.byType(RegisterScreen), findsOneWidget);
    expect(router.state.matchedLocation, AppRoutes.register);
  });
}
