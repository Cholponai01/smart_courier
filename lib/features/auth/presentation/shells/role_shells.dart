import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_courier/core/di/injection.dart';
import 'package:smart_courier/features/auth/domain/entities/user.dart';
import 'package:smart_courier/features/auth/presentation/cubit/resend_email_verification_cubit.dart';
import 'package:smart_courier/features/auth/presentation/widgets/email_verification_banner.dart';
import 'package:smart_courier/l10n/app_localizations.dart';

class CustomerShell extends StatefulWidget {
  const CustomerShell({
    required this.user,
    required this.navigationShell,
    super.key,
  });

  final User user;
  final StatefulNavigationShell navigationShell;

  @override
  State<CustomerShell> createState() => _CustomerShellState();
}

class _CustomerShellState extends State<CustomerShell> {
  var _verificationBannerDismissed = false;

  void _onDestinationSelected(int index) {
    widget.navigationShell.goBranch(
      index,
      initialLocation: index == widget.navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final showVerificationBanner =
        !widget.user.emailVerified && !_verificationBannerDismissed;

    return BlocProvider(
      create: (_) => sl<ResendEmailVerificationCubit>(),
      child: Scaffold(
        body: Column(
          children: [
            if (showVerificationBanner)
              EmailVerificationBanner(
                onDismiss: () {
                  setState(() => _verificationBannerDismissed = true);
                },
              ),
            Expanded(child: widget.navigationShell),
          ],
        ),
        bottomNavigationBar: NavigationBar(
          key: const Key('customer_bottom_nav'),
          selectedIndex: widget.navigationShell.currentIndex,
          onDestinationSelected: _onDestinationSelected,
          destinations: [
            NavigationDestination(
              icon: Semantics(
                label: l10n.homeTab,
                child: const Icon(Icons.home_outlined),
              ),
              selectedIcon: Icon(Icons.home, color: colorScheme.primary),
              label: l10n.homeTab,
            ),
            NavigationDestination(
              icon: Semantics(
                label: l10n.ordersTab,
                child: const Icon(Icons.receipt_long_outlined),
              ),
              selectedIcon: Icon(
                Icons.receipt_long,
                color: colorScheme.primary,
              ),
              label: l10n.ordersTab,
            ),
            NavigationDestination(
              icon: Semantics(
                label: l10n.newOrderTab,
                child: const Icon(Icons.add_circle_outline),
              ),
              selectedIcon: Icon(Icons.add_circle, color: colorScheme.primary),
              label: l10n.newOrderTab,
            ),
            NavigationDestination(
              icon: Semantics(
                label: l10n.profileTab,
                child: const Icon(Icons.person_outline),
              ),
              selectedIcon: Icon(Icons.person, color: colorScheme.primary),
              label: l10n.profileTab,
            ),
          ],
        ),
      ),
    );
  }
}

class CourierShell extends StatefulWidget {
  const CourierShell({
    required this.user,
    required this.navigationShell,
    super.key,
  });

  final User user;
  final StatefulNavigationShell navigationShell;

  @override
  State<CourierShell> createState() => _CourierShellState();
}

class _CourierShellState extends State<CourierShell> {
  var _verificationBannerDismissed = false;

  void _onDestinationSelected(int index) {
    widget.navigationShell.goBranch(
      index,
      initialLocation: index == widget.navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final showVerificationBanner =
        !widget.user.emailVerified && !_verificationBannerDismissed;

    return BlocProvider(
      create: (_) => sl<ResendEmailVerificationCubit>(),
      child: Scaffold(
        body: Column(
          children: [
            if (showVerificationBanner)
              EmailVerificationBanner(
                onDismiss: () {
                  setState(() => _verificationBannerDismissed = true);
                },
              ),
            Expanded(child: widget.navigationShell),
          ],
        ),
        bottomNavigationBar: NavigationBar(
          key: const Key('courier_bottom_nav'),
          selectedIndex: widget.navigationShell.currentIndex,
          onDestinationSelected: _onDestinationSelected,
          destinations: [
            NavigationDestination(
              icon: Semantics(
                label: l10n.availableOrdersTab,
                child: const Icon(Icons.list_alt_outlined),
              ),
              selectedIcon: Icon(Icons.list_alt, color: colorScheme.primary),
              label: l10n.availableOrdersTab,
            ),
            NavigationDestination(
              icon: Semantics(
                label: l10n.activeDeliveryTab,
                child: const Icon(Icons.local_shipping_outlined),
              ),
              selectedIcon: Icon(
                Icons.local_shipping,
                color: colorScheme.primary,
              ),
              label: l10n.activeDeliveryTab,
            ),
            NavigationDestination(
              icon: Semantics(
                label: l10n.earningsTab,
                child: const Icon(Icons.payments_outlined),
              ),
              selectedIcon: Icon(Icons.payments, color: colorScheme.primary),
              label: l10n.earningsTab,
            ),
            NavigationDestination(
              icon: Semantics(
                label: l10n.profileTab,
                child: const Icon(Icons.person_outline),
              ),
              selectedIcon: Icon(Icons.person, color: colorScheme.primary),
              label: l10n.profileTab,
            ),
          ],
        ),
      ),
    );
  }
}

class AdminShell extends StatefulWidget {
  const AdminShell({
    required this.user,
    required this.navigationShell,
    super.key,
  });

  final User user;
  final StatefulNavigationShell navigationShell;

  static const compactRailBreakpoint = 600.0;

  @override
  State<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShell> {
  var _verificationBannerDismissed = false;

  void _onDestinationSelected(int index) {
    widget.navigationShell.goBranch(
      index,
      initialLocation: index == widget.navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final showVerificationBanner =
        !widget.user.emailVerified && !_verificationBannerDismissed;

    return BlocProvider(
      create: (_) => sl<ResendEmailVerificationCubit>(),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final extended =
              constraints.maxWidth >= AdminShell.compactRailBreakpoint;

          return Scaffold(
            body: Column(
              children: [
                if (showVerificationBanner)
                  EmailVerificationBanner(
                    onDismiss: () {
                      setState(() => _verificationBannerDismissed = true);
                    },
                  ),
                Expanded(
                  child: Row(
                    children: [
                      NavigationRail(
                        key: const Key('admin_navigation_rail'),
                        extended: extended,
                        selectedIndex: widget.navigationShell.currentIndex,
                        onDestinationSelected: _onDestinationSelected,
                        labelType: extended
                            ? NavigationRailLabelType.none
                            : NavigationRailLabelType.all,
                        destinations: [
                          NavigationRailDestination(
                            icon: Semantics(
                              label: l10n.adminDashboardTab,
                              child: const Icon(Icons.dashboard_outlined),
                            ),
                            selectedIcon: Icon(
                              Icons.dashboard,
                              color: colorScheme.primary,
                            ),
                            label: Text(l10n.adminDashboardTab),
                          ),
                          NavigationRailDestination(
                            icon: Semantics(
                              label: l10n.adminOrdersTab,
                              child: const Icon(Icons.inventory_2_outlined),
                            ),
                            selectedIcon: Icon(
                              Icons.inventory_2,
                              color: colorScheme.primary,
                            ),
                            label: Text(l10n.adminOrdersTab),
                          ),
                          NavigationRailDestination(
                            icon: Semantics(
                              label: l10n.adminCouriersTab,
                              child: const Icon(Icons.groups_outlined),
                            ),
                            selectedIcon: Icon(
                              Icons.groups,
                              color: colorScheme.primary,
                            ),
                            label: Text(l10n.adminCouriersTab),
                          ),
                          NavigationRailDestination(
                            icon: Semantics(
                              label: l10n.profileTab,
                              child: const Icon(Icons.person_outline),
                            ),
                            selectedIcon: Icon(
                              Icons.person,
                              color: colorScheme.primary,
                            ),
                            label: Text(l10n.profileTab),
                          ),
                        ],
                      ),
                      const VerticalDivider(width: 1),
                      Expanded(child: widget.navigationShell),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
