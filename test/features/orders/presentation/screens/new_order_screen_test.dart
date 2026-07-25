import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_courier/core/di/injection.dart';
import 'package:smart_courier/core/map/map_pick_result.dart';
import 'package:smart_courier/core/map/map_picker_controller.dart';
import 'package:smart_courier/features/orders/domain/entities/address.dart';
import 'package:smart_courier/features/orders/presentation/bloc/order_form_bloc.dart';
import 'package:smart_courier/features/orders/presentation/screens/new_order_screen.dart';
import 'package:smart_courier/l10n/app_localizations.dart';

import '../../../../helpers/pump_localized_widget.dart';

class MockOrderFormBloc extends MockBloc<OrderFormEvent, OrderFormState>
    implements OrderFormBloc {}

class FakeMapPickerController implements MapPickerController {
  @override
  bool get isAvailable => false;

  @override
  Widget buildMapSection({
    required MapPickTarget target,
    required String addressHint,
    required ValueChanged<MapPickResult> onLocationPicked,
  }) {
    return const SizedBox.shrink();
  }
}

void main() {
  late MockOrderFormBloc orderFormBloc;

  const pickup = Address(address: 'Pickup St', lat: 1, lng: 2);
  const dropoff = Address(address: 'Dropoff St', lat: 3, lng: 4);

  const editingWithAddresses = OrderFormEditing(
    pickup: pickup,
    dropoff: dropoff,
    pickupText: 'Pickup St',
    dropoffText: 'Dropoff St',
  );

  setUp(() {
    orderFormBloc = MockOrderFormBloc();
    if (sl.isRegistered<MapPickerController>()) {
      sl.unregister<MapPickerController>();
    }
    sl.registerLazySingleton<MapPickerController>(
      () => FakeMapPickerController(),
    );
  });

  tearDown(() {
    if (sl.isRegistered<MapPickerController>()) {
      sl.unregister<MapPickerController>();
    }
  });

  Future<void> pumpScreen(WidgetTester tester) {
    return pumpLocalizedWidget(
      tester,
      NewOrderScreen(bloc: orderFormBloc),
    );
  }

  testWidgets('shows map unavailable fallback and disables submit without addresses', (
    tester,
  ) async {
    whenListen(
      orderFormBloc,
      const Stream<OrderFormState>.empty(),
      initialState: const OrderFormInitial(),
    );

    await pumpScreen(tester);

    final l10n = AppLocalizations.of(
      tester.element(find.byType(NewOrderScreen)),
    )!;

    expect(find.text(l10n.mapUnavailable), findsOneWidget);

    final submitButton = tester.widget<FilledButton>(
      find.byKey(const Key('new_order_submit_button')),
    );
    expect(submitButton.onPressed, isNull);
  });

  testWidgets('shows loading indicator while order is submitting', (
    tester,
  ) async {
    whenListen(
      orderFormBloc,
      const Stream<OrderFormState>.empty(),
      initialState: OrderFormSubmitting(editingWithAddresses),
    );

    await pumpScreen(tester);

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('shows snackbar when submission fails', (tester) async {
    whenListen(
      orderFormBloc,
      Stream.fromIterable([
        OrderFormError(
          message: 'Network error',
          previous: editingWithAddresses,
        ),
      ]),
      initialState: editingWithAddresses,
    );

    await pumpScreen(tester);
    await tester.pump();

    expect(find.text('Network error'), findsOneWidget);
  });

  testWidgets('enables submit when both addresses are present', (tester) async {
    whenListen(
      orderFormBloc,
      const Stream<OrderFormState>.empty(),
      initialState: editingWithAddresses,
    );

    await pumpScreen(tester);

    final submitButton = tester.widget<FilledButton>(
      find.byKey(const Key('new_order_submit_button')),
    );
    expect(submitButton.onPressed, isNotNull);
  });
}
