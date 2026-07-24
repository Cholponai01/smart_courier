import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:smart_courier/core/router/app_router.dart';
import 'package:smart_courier/core/router/app_routes.dart';
import 'package:smart_courier/core/theme/app_theme.dart';
import 'package:smart_courier/features/auth/domain/entities/user.dart';
import 'package:smart_courier/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:smart_courier/features/auth/presentation/screens/register_screen.dart';
import 'package:smart_courier/features/auth/presentation/shells/role_shells.dart';
import 'package:smart_courier/l10n/app_localizations.dart';
import '../../../../helpers/pump_localized_widget.dart';

class MockAuthBloc extends MockBloc<AuthEvent, AuthState> implements AuthBloc {}

void main() {
  late MockAuthBloc authBloc;

  setUpAll(() {
    registerFallbackValue(
      const RegisterRequested(
        email: 'fallback@example.com',
        password: 'fallback',
        name: 'Fallback',
        phone: '000',
      ),
    );
  });

  setUp(() {
    authBloc = MockAuthBloc();
  });

  Widget buildSubject() {
    return BlocProvider<AuthBloc>.value(
      value: authBloc,
      child: const RegisterScreen(),
    );
  }

  testWidgets('shows loading indicator while registration is in progress', (
    tester,
  ) async {
    whenListen(
      authBloc,
      const Stream<AuthState>.empty(),
      initialState: const AuthLoading(),
    );

    await pumpLocalizedWidget(tester, buildSubject());

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

    await pumpLocalizedWidget(tester, buildSubject());
    await tester.tap(find.byKey(const Key('register_submit_button')));
    await tester.pump();

    expect(find.text('Name is required'), findsOneWidget);
    expect(find.text('Phone is required'), findsOneWidget);
    expect(find.text('Email is required'), findsOneWidget);
    expect(find.text('Password is required'), findsOneWidget);
    verifyNever(() => authBloc.add(any()));
  });

  testWidgets('dispatches RegisterRequested when form is valid', (
    tester,
  ) async {
    whenListen(
      authBloc,
      const Stream<AuthState>.empty(),
      initialState: const Unauthenticated(),
    );

    await pumpLocalizedWidget(tester, buildSubject());
    await tester.enterText(
      find.byKey(const Key('register_name_field')),
      'Test User',
    );
    await tester.enterText(
      find.byKey(const Key('register_phone_field')),
      '+10000000000',
    );
    await tester.enterText(
      find.byKey(const Key('register_email_field')),
      'user@example.com',
    );
    await tester.enterText(
      find.byKey(const Key('register_password_field')),
      'password',
    );
    await tester.tap(find.byKey(const Key('register_submit_button')));
    await tester.pump();

    verify(
      () => authBloc.add(
        const RegisterRequested(
          email: 'user@example.com',
          password: 'password',
          name: 'Test User',
          phone: '+10000000000',
        ),
      ),
    ).called(1);
  });

  testWidgets('shows auth error message in a snackbar', (tester) async {
    whenListen(
      authBloc,
      Stream.fromIterable([
        const AuthError('An account with this email already exists'),
      ]),
      initialState: const Unauthenticated(),
    );

    await pumpLocalizedWidget(tester, buildSubject());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(
      find.text('An account with this email already exists'),
      findsOneWidget,
    );
  });

  testWidgets('redirects to customer shell when registration succeeds', (
    tester,
  ) async {
    const user = User(
      id: 'user-id',
      email: 'user@example.com',
      role: UserRole.customer,
    );
    final stateController = StreamController<AuthState>.broadcast();

    when(() => authBloc.stream).thenAnswer((_) => stateController.stream);
    when(() => authBloc.state).thenReturn(const Unauthenticated());

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
    router.go(AppRoutes.register);
    await tester.pumpAndSettle();

    expect(find.byType(RegisterScreen), findsOneWidget);

    when(() => authBloc.state).thenReturn(Authenticated(user));
    stateController.add(Authenticated(user));
    await tester.pumpAndSettle();

    expect(find.byType(RegisterScreen), findsNothing);
    expect(find.byType(CustomerShell), findsOneWidget);
    expect(router.state.matchedLocation, AppRoutes.customer);
  });
}
