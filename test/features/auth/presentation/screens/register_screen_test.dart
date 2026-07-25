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

Future<void> _enterPhoneNumber(WidgetTester tester, String number) async {
  await tester.enterText(
    find.descendant(
      of: find.byKey(const Key('register_phone_field')),
      matching: find.byType(TextFormField),
    ),
    number,
  );
}

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
    await tester.pumpAndSettle();

    expect(find.text('Name is required'), findsOneWidget);
    expect(find.textContaining('Phone'), findsOneWidget);
    expect(find.text('Email is required'), findsOneWidget);
    expect(find.text('Password is required'), findsOneWidget);
    expect(find.text('Please confirm your password'), findsOneWidget);
    verifyNever(() => authBloc.add(any()));
  });

  testWidgets('shows weak password validation message', (tester) async {
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
    await _enterPhoneNumber(tester, '5551234567');
    await tester.enterText(
      find.byKey(const Key('register_email_field')),
      'user@example.com',
    );
    await tester.enterText(
      find.byKey(const Key('register_password_field')),
      'password',
    );
    await tester.enterText(
      find.byKey(const Key('register_confirm_password_field')),
      'password',
    );
    await tester.tap(find.byKey(const Key('register_submit_button')));
    await tester.pump();

    expect(
      find.text(
        'Password must be at least 8 characters and contain at least 1 digit',
      ),
      findsOneWidget,
    );
    verifyNever(() => authBloc.add(any()));
  });

  testWidgets('shows password mismatch only after full confirm is entered', (
    tester,
  ) async {
    whenListen(
      authBloc,
      const Stream<AuthState>.empty(),
      initialState: const Unauthenticated(),
    );

    await pumpLocalizedWidget(tester, buildSubject());
    await tester.enterText(
      find.byKey(const Key('register_password_field')),
      'password1',
    );

    final confirmField = find.byKey(
      const Key('register_confirm_password_field'),
    );
    await tester.enterText(confirmField, 'pass');
    await tester.pump();
    expect(find.text('Passwords do not match'), findsNothing);

    await tester.enterText(confirmField, 'password2');
    await tester.pump();
    expect(find.text('Passwords do not match'), findsOneWidget);
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
    await _enterPhoneNumber(tester, '5551234567');
    await tester.enterText(
      find.byKey(const Key('register_email_field')),
      'user@example.com',
    );
    await tester.enterText(
      find.byKey(const Key('register_password_field')),
      'password1',
    );
    await tester.enterText(
      find.byKey(const Key('register_confirm_password_field')),
      'password1',
    );
    await tester.tap(find.byKey(const Key('register_submit_button')));
    await tester.pump();

    verify(
      () => authBloc.add(
        const RegisterRequested(
          email: 'user@example.com',
          password: 'password1',
          name: 'Test User',
          phone: '+15551234567',
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
      emailVerified: true,
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
    expect(router.state.matchedLocation, AppRoutes.customerHome);
  });
}
