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

  testWidgets('uses compact NavigationRail when viewport width is below 600', (
    tester,
  ) async {
    const user = User(
      id: 'admin-id',
      email: 'admin@example.com',
      role: UserRole.admin,
      emailVerified: true,
    );

    whenListen(
      authBloc,
      const Stream<AuthState>.empty(),
      initialState: const Authenticated(user),
    );

    final router = createAppRouter(authBloc);
    addTearDown(() => tester.view.resetPhysicalSize());

    tester.view.physicalSize = const Size(500, 800);
    tester.view.devicePixelRatio = 1;

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
    router.go(AppRoutes.adminDashboard);
    await tester.pumpAndSettle();

    expect(find.byType(AdminShell), findsOneWidget);

    final rail = tester.widget<NavigationRail>(
      find.byKey(const Key('admin_navigation_rail')),
    );
    expect(rail.extended, isFalse);
    expect(rail.labelType, NavigationRailLabelType.all);
  });

  testWidgets(
    'uses extended NavigationRail when viewport width is at least 600',
    (tester) async {
      const user = User(
        id: 'admin-id',
        email: 'admin@example.com',
        role: UserRole.admin,
        emailVerified: true,
      );

      whenListen(
        authBloc,
        const Stream<AuthState>.empty(),
        initialState: const Authenticated(user),
      );

      final router = createAppRouter(authBloc);
      addTearDown(() => tester.view.resetPhysicalSize());

      tester.view.physicalSize = const Size(800, 800);
      tester.view.devicePixelRatio = 1;

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
      router.go(AppRoutes.adminDashboard);
      await tester.pumpAndSettle();

      final rail = tester.widget<NavigationRail>(
        find.byKey(const Key('admin_navigation_rail')),
      );
      expect(rail.extended, isTrue);
      expect(rail.labelType, NavigationRailLabelType.none);
    },
  );
}
