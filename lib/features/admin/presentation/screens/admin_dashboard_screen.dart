import 'package:flutter/material.dart';
import 'package:smart_courier/core/widgets/empty_state_view.dart';
import 'package:smart_courier/l10n/app_localizations.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.adminDashboardTab)),
      body: EmptyStateView(
        icon: Icons.map_outlined,
        message: l10n.adminDashboardEmpty,
      ),
    );
  }
}
