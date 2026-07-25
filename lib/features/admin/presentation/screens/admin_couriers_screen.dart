import 'package:flutter/material.dart';
import 'package:smart_courier/core/widgets/empty_state_view.dart';
import 'package:smart_courier/l10n/app_localizations.dart';

class AdminCouriersScreen extends StatelessWidget {
  const AdminCouriersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.adminCouriersTab)),
      body: EmptyStateView(
        icon: Icons.groups_outlined,
        message: l10n.adminCouriersEmpty,
      ),
    );
  }
}
