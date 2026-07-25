import 'package:flutter/material.dart';
import 'package:smart_courier/core/widgets/empty_state_view.dart';
import 'package:smart_courier/l10n/app_localizations.dart';

class ActiveDeliveryScreen extends StatefulWidget {
  const ActiveDeliveryScreen({super.key});

  @override
  State<ActiveDeliveryScreen> createState() => _ActiveDeliveryScreenState();
}

class _ActiveDeliveryScreenState extends State<ActiveDeliveryScreen> {
  final _noteController = TextEditingController();

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.activeDeliveryTab)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              key: const Key('courier_active_note_field'),
              controller: _noteController,
              decoration: InputDecoration(
                labelText: l10n.activeDeliveryNoteHint,
              ),
            ),
          ),
          Expanded(
            child: EmptyStateView(
              icon: Icons.local_shipping_outlined,
              message: l10n.activeDeliveryEmpty,
            ),
          ),
        ],
      ),
    );
  }
}
