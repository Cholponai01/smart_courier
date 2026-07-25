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

import '../../../../helpers/register_shell_test_dependencies.dart';

class MockAuthBloc extends MockBloc<AuthEvent, AuthState> implements AuthBloc {}

void main() {
  late MockAuthBloc authBloc;

  setUpAll(registerShellTestFallbackValues);

  setUp(() {
    authBloc = MockAuthBloc();
    registerShellTestDependencies();
  });

  testWidgets('preserves tab form state when switching customer tabs', (
    tester,
  ) async {
    const user = User(
      id: 'user-id',
      email: 'user@example.com',
      role: UserRole.customer,
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
    router.go(AppRoutes.customerHome);
    await tester.pumpAndSettle();

    expect(find.byType(CustomerShell), findsOneWidget);

    await tester.tap(find.text('Orders'));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const Key('customer_orders_filter_field')),
      'filter text',
    );

    await tester.tap(find.text('Home'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Orders'));
    await tester.pumpAndSettle();
    expect(find.text('filter text'), findsOneWidget);
  });
}
