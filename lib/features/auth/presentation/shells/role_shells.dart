import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_courier/features/auth/domain/entities/user.dart';
import 'package:smart_courier/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:smart_courier/l10n/app_localizations.dart';

class CustomerShell extends StatelessWidget {
  const CustomerShell({required this.user, super.key});

  final User user;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return _RoleShellScaffold(
      title: l10n.customerHome,
      subtitle: l10n.signedInAs(user.email),
      roleLabel: 'customer',
      logoutTooltip: l10n.logout,
    );
  }
}

class CourierShell extends StatelessWidget {
  const CourierShell({required this.user, super.key});

  final User user;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return _RoleShellScaffold(
      title: l10n.courierHome,
      subtitle: l10n.signedInAs(user.email),
      roleLabel: 'courier',
      logoutTooltip: l10n.logout,
    );
  }
}

class AdminShell extends StatelessWidget {
  const AdminShell({required this.user, super.key});

  final User user;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return _RoleShellScaffold(
      title: l10n.adminHome,
      subtitle: l10n.signedInAs(user.email),
      roleLabel: 'admin',
      logoutTooltip: l10n.logout,
    );
  }
}

class _RoleShellScaffold extends StatelessWidget {
  const _RoleShellScaffold({
    required this.title,
    required this.subtitle,
    required this.roleLabel,
    required this.logoutTooltip,
  });

  final String title;
  final String subtitle;
  final String roleLabel;
  final String logoutTooltip;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(title, style: textTheme.titleMedium),
        actions: [
          IconButton(
            key: Key('${roleLabel}_logout_button'),
            tooltip: logoutTooltip,
            onPressed: () {
              context.read<AuthBloc>().add(const LogoutRequested());
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Center(child: Text(subtitle, style: textTheme.bodyLarge)),
    );
  }
}
