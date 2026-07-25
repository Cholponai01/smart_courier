import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:smart_courier/core/splash/splash_screen.dart';
import 'package:smart_courier/features/auth/presentation/bloc/auth_bloc.dart';
import '../../helpers/pump_localized_widget.dart';

class MockAuthBloc extends MockBloc<AuthEvent, AuthState> implements AuthBloc {}

void main() {
  late MockAuthBloc authBloc;

  setUp(() {
    authBloc = MockAuthBloc();
  });

  testWidgets('shows connection fallback after auth check timeout', (
    tester,
  ) async {
    whenListen(
      authBloc,
      const Stream<AuthState>.empty(),
      initialState: const AuthChecking(),
    );

    await pumpLocalizedWidget(
      tester,
      BlocProvider<AuthBloc>.value(
        value: authBloc,
        child: const SplashScreen(),
      ),
    );

    await tester.pump(SplashScreen.authCheckTimeout);

    expect(find.text('Connection problem'), findsOneWidget);
    expect(find.byKey(const Key('splash_retry_button')), findsOneWidget);
  });

  testWidgets('dispatches AuthCheckRequested when retry is tapped', (
    tester,
  ) async {
    whenListen(
      authBloc,
      const Stream<AuthState>.empty(),
      initialState: const AuthChecking(),
    );

    await pumpLocalizedWidget(
      tester,
      BlocProvider<AuthBloc>.value(
        value: authBloc,
        child: const SplashScreen(),
      ),
    );
    await tester.pump(SplashScreen.authCheckTimeout);
    await tester.tap(find.byKey(const Key('splash_retry_button')));
    await tester.pump();

    verify(() => authBloc.add(const AuthCheckRequested())).called(1);
  });
}
