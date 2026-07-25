import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_courier/core/router/app_router.dart';
import 'package:smart_courier/core/router/app_routes.dart';
import 'package:smart_courier/core/theme/app_theme.dart';
import 'package:smart_courier/features/auth/domain/entities/user.dart';
import 'package:smart_courier/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:smart_courier/features/auth/presentation/shells/role_shells.dart';
import 'package:smart_courier/l10n/app_localizations.dart';

class MockAuthBloc extends MockBloc<AuthEvent, AuthState> implements AuthBloc {}

void main() {
  late MockAuthBloc authBloc;

  setUp(() {
    authBloc = MockAuthBloc();
  });

  testWidgets('preserves tab form state when switching courier tabs', (
    tester,
  ) async {
    const user = User(
      id: 'courier-id',
      email: 'courier@example.com',
      role: UserRole.courier,
      emailVerified: true,
    );

    whenListen(
      authBloc,
      const Stream<AuthState>.empty(),
      initialState: const Authenticated(user),
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
    router.go(AppRoutes.courierAvailable);
    await tester.pumpAndSettle();

    expect(find.byType(CourierShell), findsOneWidget);

    await tester.enterText(
      find.byKey(const Key('courier_available_search_field')),
      'downtown',
    );

    await tester.tap(find.text('Active'));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const Key('courier_active_note_field')),
      'call on arrival',
    );

    await tester.tap(find.text('Orders'));
    await tester.pumpAndSettle();
    expect(find.text('downtown'), findsOneWidget);

    await tester.tap(find.text('Active'));
    await tester.pumpAndSettle();
    expect(find.text('call on arrival'), findsOneWidget);
  });
}
