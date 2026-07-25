import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_courier/core/router/app_routes.dart';
import 'package:smart_courier/core/router/go_router_refresh_stream.dart';
import 'package:smart_courier/core/splash/splash_screen.dart';
import 'package:smart_courier/features/admin/presentation/screens/admin_couriers_screen.dart';
import 'package:smart_courier/features/admin/presentation/screens/admin_dashboard_screen.dart';
import 'package:smart_courier/features/admin/presentation/screens/admin_orders_screen.dart';
import 'package:smart_courier/features/auth/domain/entities/user.dart';
import 'package:smart_courier/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:smart_courier/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:smart_courier/features/auth/presentation/screens/login_screen.dart';
import 'package:smart_courier/features/auth/presentation/screens/register_screen.dart';
import 'package:smart_courier/features/auth/presentation/shells/role_shells.dart';
import 'package:smart_courier/features/orders/presentation/screens/active_delivery_screen.dart';
import 'package:smart_courier/features/orders/presentation/screens/available_orders_screen.dart';
import 'package:smart_courier/features/orders/presentation/screens/customer_home_screen.dart';
import 'package:smart_courier/features/orders/presentation/screens/customer_orders_screen.dart';
import 'package:smart_courier/features/orders/presentation/screens/earnings_screen.dart';
import 'package:smart_courier/features/orders/presentation/screens/new_order_screen.dart';
import 'package:smart_courier/features/profile/presentation/screens/profile_screen.dart';

GoRouter createAppRouter(AuthBloc authBloc) {
  return GoRouter(
    initialLocation: AppRoutes.splash,
    refreshListenable: GoRouterRefreshStream(authBloc.stream),
    redirect: (context, state) => _redirect(authBloc.state, state),
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      _customerShellRoute(authBloc),
      _courierShellRoute(authBloc),
      _adminShellRoute(authBloc),
    ],
  );
}

StatefulShellRoute _customerShellRoute(AuthBloc authBloc) {
  return StatefulShellRoute.indexedStack(
    builder: (context, state, navigationShell) {
      final authState = authBloc.state;
      if (authState is! Authenticated) {
        return const SizedBox.shrink();
      }
      return CustomerShell(
        user: authState.user,
        navigationShell: navigationShell,
      );
    },
    branches: [
      StatefulShellBranch(
        routes: [
          GoRoute(
            path: AppRoutes.customerHome,
            builder: (context, state) => const CustomerHomeScreen(),
          ),
        ],
      ),
      StatefulShellBranch(
        routes: [
          GoRoute(
            path: AppRoutes.customerOrders,
            builder: (context, state) => const CustomerOrdersScreen(),
          ),
        ],
      ),
      StatefulShellBranch(
        routes: [
          GoRoute(
            path: AppRoutes.customerNewOrder,
            builder: (context, state) => const NewOrderScreen(),
          ),
        ],
      ),
      StatefulShellBranch(
        routes: [
          GoRoute(
            path: AppRoutes.customerProfile,
            builder: (context, state) {
              final user = _authenticatedUser(authBloc);
              if (user == null) {
                return const SizedBox.shrink();
              }
              return ProfileScreen(user: user);
            },
          ),
        ],
      ),
    ],
  );
}

StatefulShellRoute _courierShellRoute(AuthBloc authBloc) {
  return StatefulShellRoute.indexedStack(
    builder: (context, state, navigationShell) {
      final authState = authBloc.state;
      if (authState is! Authenticated) {
        return const SizedBox.shrink();
      }
      return CourierShell(
        user: authState.user,
        navigationShell: navigationShell,
      );
    },
    branches: [
      StatefulShellBranch(
        routes: [
          GoRoute(
            path: AppRoutes.courierAvailable,
            builder: (context, state) => const AvailableOrdersScreen(),
          ),
        ],
      ),
      StatefulShellBranch(
        routes: [
          GoRoute(
            path: AppRoutes.courierActive,
            builder: (context, state) => const ActiveDeliveryScreen(),
          ),
        ],
      ),
      StatefulShellBranch(
        routes: [
          GoRoute(
            path: AppRoutes.courierEarnings,
            builder: (context, state) => const EarningsScreen(),
          ),
        ],
      ),
      StatefulShellBranch(
        routes: [
          GoRoute(
            path: AppRoutes.courierProfile,
            builder: (context, state) {
              final user = _authenticatedUser(authBloc);
              if (user == null) {
                return const SizedBox.shrink();
              }
              return ProfileScreen(user: user);
            },
          ),
        ],
      ),
    ],
  );
}

StatefulShellRoute _adminShellRoute(AuthBloc authBloc) {
  return StatefulShellRoute.indexedStack(
    builder: (context, state, navigationShell) {
      final authState = authBloc.state;
      if (authState is! Authenticated) {
        return const SizedBox.shrink();
      }
      return AdminShell(user: authState.user, navigationShell: navigationShell);
    },
    branches: [
      StatefulShellBranch(
        routes: [
          GoRoute(
            path: AppRoutes.adminDashboard,
            builder: (context, state) => const AdminDashboardScreen(),
          ),
        ],
      ),
      StatefulShellBranch(
        routes: [
          GoRoute(
            path: AppRoutes.adminOrders,
            builder: (context, state) => const AdminOrdersScreen(),
          ),
        ],
      ),
      StatefulShellBranch(
        routes: [
          GoRoute(
            path: AppRoutes.adminCouriers,
            builder: (context, state) => const AdminCouriersScreen(),
          ),
        ],
      ),
      StatefulShellBranch(
        routes: [
          GoRoute(
            path: AppRoutes.adminProfile,
            builder: (context, state) {
              final user = _authenticatedUser(authBloc);
              if (user == null) {
                return const SizedBox.shrink();
              }
              return ProfileScreen(user: user);
            },
          ),
        ],
      ),
    ],
  );
}

User? _authenticatedUser(AuthBloc authBloc) {
  final state = authBloc.state;
  if (state is Authenticated) {
    return state.user;
  }
  return null;
}

String? _redirect(AuthState authState, GoRouterState routerState) {
  final location = routerState.matchedLocation;
  final isSplash = location == AppRoutes.splash;
  final isAuthRoute = _isAuthRoute(location);

  if (authState is AuthInitial || authState is AuthChecking) {
    return isSplash ? null : AppRoutes.splash;
  }

  if (authState is Authenticated) {
    final home = _homeRouteForRole(authState.user.role);
    if (isSplash ||
        isAuthRoute ||
        !_isRoleShellRoute(location, authState.user.role)) {
      return home;
    }
    return null;
  }

  if (isAuthRoute) {
    return null;
  }

  if (isSplash) {
    return AppRoutes.login;
  }

  return AppRoutes.login;
}

bool _isAuthRoute(String location) {
  return location == AppRoutes.login ||
      location == AppRoutes.register ||
      location == AppRoutes.forgotPassword;
}

bool _isRoleShellRoute(String location, UserRole role) {
  return switch (role) {
    UserRole.customer => location.startsWith('/customer/'),
    UserRole.courier => location.startsWith('/courier/'),
    UserRole.admin => location.startsWith('/admin/'),
  };
}

String _homeRouteForRole(UserRole role) {
  return switch (role) {
    UserRole.customer => AppRoutes.customerHome,
    UserRole.courier => AppRoutes.courierAvailable,
    UserRole.admin => AppRoutes.adminDashboard,
  };
}
