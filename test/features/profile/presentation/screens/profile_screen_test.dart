import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:smart_courier/features/auth/domain/entities/user.dart';
import 'package:smart_courier/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:smart_courier/features/profile/presentation/screens/profile_screen.dart';
import '../../../../helpers/pump_localized_widget.dart';

class MockAuthBloc extends MockBloc<AuthEvent, AuthState> implements AuthBloc {}

void main() {
  late MockAuthBloc authBloc;

  const user = User(
    id: 'user-id',
    email: 'user@example.com',
    role: UserRole.customer,
    emailVerified: true,
  );

  setUpAll(() {
    registerFallbackValue(const LogoutRequested());
  });

  setUp(() {
    authBloc = MockAuthBloc();
  });

  testWidgets('dispatches LogoutRequested when logout button is tapped', (
    tester,
  ) async {
    whenListen(
      authBloc,
      const Stream<AuthState>.empty(),
      initialState: const Authenticated(user),
    );

    await pumpLocalizedWidget(
      tester,
      BlocProvider<AuthBloc>.value(
        value: authBloc,
        child: const ProfileScreen(user: user),
      ),
    );

    await tester.tap(find.byKey(const Key('profile_logout_button')));
    await tester.pump();

    verify(() => authBloc.add(const LogoutRequested())).called(1);
  });
}
