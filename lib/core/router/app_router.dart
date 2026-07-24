import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_courier/core/router/app_routes.dart';
import 'package:smart_courier/core/router/go_router_refresh_stream.dart';
import 'package:smart_courier/features/auth/domain/entities/user.dart';
import 'package:smart_courier/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:smart_courier/features/auth/presentation/screens/login_screen.dart';
import 'package:smart_courier/features/auth/presentation/screens/register_screen.dart';
import 'package:smart_courier/features/auth/presentation/shells/role_shells.dart';

GoRouter createAppRouter(AuthBloc authBloc) {
  return GoRouter(
    initialLocation: AppRoutes.login,
    refreshListenable: GoRouterRefreshStream(authBloc.stream),
    redirect: (context, state) => _redirect(authBloc.state, state),
    routes: [
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: AppRoutes.customer,
        builder: (context, state) =>
            _buildRoleShell(context, UserRole.customer),
      ),
      GoRoute(
        path: AppRoutes.courier,
        builder: (context, state) => _buildRoleShell(context, UserRole.courier),
      ),
      GoRoute(
        path: AppRoutes.admin,
        builder: (context, state) => _buildRoleShell(context, UserRole.admin),
      ),
    ],
  );
}

String? _redirect(AuthState authState, GoRouterState routerState) {
  final location = routerState.matchedLocation;
  final isAuthRoute =
      location == AppRoutes.login || location == AppRoutes.register;

  if (authState is AuthInitial) {
    return null;
  }

  if (authState is Authenticated) {
    final home = _homeRouteForRole(authState.user.role);
    if (location != home) {
      return home;
    }
    return null;
  }

  if (isAuthRoute) {
    return null;
  }

  return AppRoutes.login;
}

String _homeRouteForRole(UserRole role) {
  return switch (role) {
    UserRole.customer => AppRoutes.customer,
    UserRole.courier => AppRoutes.courier,
    UserRole.admin => AppRoutes.admin,
  };
}

Widget _buildRoleShell(BuildContext context, UserRole expectedRole) {
  final authState = context.read<AuthBloc>().state;
  if (authState is! Authenticated || authState.user.role != expectedRole) {
    return const SizedBox.shrink();
  }

  return switch (expectedRole) {
    UserRole.customer => CustomerShell(user: authState.user),
    UserRole.courier => CourierShell(user: authState.user),
    UserRole.admin => AdminShell(user: authState.user),
  };
}
