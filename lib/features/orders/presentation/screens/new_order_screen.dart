import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_courier/core/di/injection.dart';
import 'package:smart_courier/core/map/map_pick_result.dart';
import 'package:smart_courier/core/map/map_picker_controller.dart';
import 'package:smart_courier/core/router/app_routes.dart';
import 'package:smart_courier/features/orders/domain/entities/address.dart';
import 'package:smart_courier/features/orders/presentation/bloc/order_form_bloc.dart';
import 'package:smart_courier/features/orders/presentation/widgets/map_unavailable_view.dart';
import 'package:smart_courier/l10n/app_localizations.dart';
import 'package:smart_courier/widgets/app_text_field.dart';
import 'package:smart_courier/widgets/loading_button.dart';

class NewOrderScreen extends StatelessWidget {
  const NewOrderScreen({super.key, this.bloc});

  final OrderFormBloc? bloc;

  @override
  Widget build(BuildContext context) {
    if (bloc != null) {
      return BlocProvider.value(value: bloc!, child: const _NewOrderView());
    }

    return BlocProvider(
      create: (_) => sl<OrderFormBloc>(),
      child: const _NewOrderView(),
    );
  }
}

class _NewOrderView extends StatefulWidget {
  const _NewOrderView();

  @override
  State<_NewOrderView> createState() => _NewOrderViewState();
}

class _NewOrderViewState extends State<_NewOrderView> {
  final _pickupController = TextEditingController();
  final _dropoffController = TextEditingController();
  final _noteController = TextEditingController();

  @override
  void dispose() {
    _pickupController.dispose();
    _dropoffController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final mapPicker = sl<MapPickerController>();

    return Scaffold(
      appBar: AppBar(title: Text(l10n.newOrderTab)),
      body: BlocConsumer<OrderFormBloc, OrderFormState>(
        listener: (context, state) {
          if (state is OrderFormSuccess) {
            context.go(
              AppRoutes.customerOrdersWithHighlight(state.order.id),
            );
          }
          if (state is OrderFormError) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        builder: (context, state) {
          final editing = _resolveEditing(state);
          final isSubmitting = state is OrderFormSubmitting;
          final canSubmit = editing.canSubmit && !isSubmitting;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                l10n.newOrderPickupSection,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              if (!mapPicker.isAvailable)
                MapUnavailableView(message: l10n.mapUnavailable)
              else
                mapPicker.buildMapSection(
                  target: MapPickTarget.pickup,
                  addressHint: l10n.pickFromMapPickup,
                  onLocationPicked: (result) {
                    _pickupController.text = result.address;
                    context.read<OrderFormBloc>().add(
                      AddressPickupSelected(_toAddress(result)),
                    );
                  },
                ),
              const SizedBox(height: 8),
              _AddressField(
                fieldKey: const Key('new_order_pickup_field'),
                controller: _pickupController,
                labelText: l10n.pickupAddressLabel,
                errorText: editing.pickupError,
                onChanged: (value) => context.read<OrderFormBloc>().add(
                  PickupAddressTextChanged(value),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                l10n.newOrderDropoffSection,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              if (mapPicker.isAvailable)
                mapPicker.buildMapSection(
                  target: MapPickTarget.dropoff,
                  addressHint: l10n.pickFromMapDropoff,
                  onLocationPicked: (result) {
                    _dropoffController.text = result.address;
                    context.read<OrderFormBloc>().add(
                      AddressDropoffSelected(_toAddress(result)),
                    );
                  },
                ),
              const SizedBox(height: 8),
              _AddressField(
                fieldKey: const Key('new_order_dropoff_field'),
                controller: _dropoffController,
                labelText: l10n.dropoffAddressLabel,
                errorText: editing.dropoffError,
                onChanged: (value) => context.read<OrderFormBloc>().add(
                  DropoffAddressTextChanged(value),
                ),
              ),
              const SizedBox(height: 16),
              AppTextField(
                fieldKey: const Key('new_order_note_field'),
                controller: _noteController,
                labelText: l10n.orderNoteLabel,
                onChanged: (value) => context.read<OrderFormBloc>().add(
                  NoteChanged(value),
                ),
              ),
              const SizedBox(height: 24),
              LoadingButton(
                buttonKey: const Key('new_order_submit_button'),
                label: l10n.createOrderButton,
                isLoading: isSubmitting,
                onPressed: canSubmit
                    ? () => context.read<OrderFormBloc>().add(
                        const OrderSubmitted(),
                      )
                    : null,
              ),
            ],
          );
        },
      ),
    );
  }

  OrderFormEditing _resolveEditing(OrderFormState state) {
    return switch (state) {
      OrderFormEditing() => state,
      OrderFormValidating(:final previous) => previous,
      OrderFormSubmitting(:final previous) => previous,
      OrderFormError(:final previous) => previous,
      OrderFormSuccess() => const OrderFormEditing(),
      OrderFormInitial() => const OrderFormEditing(),
    };
  }

  Address _toAddress(MapPickResult result) {
    return Address(
      address: result.address,
      lat: result.lat,
      lng: result.lng,
    );
  }
}

class _AddressField extends StatelessWidget {
  const _AddressField({
    required this.controller,
    required this.labelText,
    required this.onChanged,
    this.fieldKey,
    this.errorText,
  });

  final TextEditingController controller;
  final String labelText;
  final ValueChanged<String> onChanged;
  final Key? fieldKey;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return TextFormField(
      key: fieldKey,
      controller: controller,
      onChanged: onChanged,
      style: theme.textTheme.bodyLarge,
      decoration: InputDecoration(
        labelText: labelText,
        errorText: errorText,
      ),
    );
  }
}
