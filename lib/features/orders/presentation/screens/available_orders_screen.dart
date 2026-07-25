import 'package:flutter/material.dart';
import 'package:smart_courier/core/widgets/empty_state_view.dart';
import 'package:smart_courier/l10n/app_localizations.dart';

class AvailableOrdersScreen extends StatefulWidget {
  const AvailableOrdersScreen({super.key});

  @override
  State<AvailableOrdersScreen> createState() => _AvailableOrdersScreenState();
}

class _AvailableOrdersScreenState extends State<AvailableOrdersScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.availableOrdersTab)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              key: const Key('courier_available_search_field'),
              controller: _searchController,
              decoration: InputDecoration(labelText: l10n.courierSearchHint),
            ),
          ),
          Expanded(
            child: EmptyStateView(
              icon: Icons.list_alt_outlined,
              message: l10n.availableOrdersEmpty,
            ),
          ),
        ],
      ),
    );
  }
}
