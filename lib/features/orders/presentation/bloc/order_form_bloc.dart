import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:smart_courier/core/utils/result.dart';
import 'package:smart_courier/features/orders/data/constants/order_error_messages.dart';
import 'package:smart_courier/features/orders/domain/entities/address.dart';
import 'package:smart_courier/features/orders/domain/entities/create_order_input.dart';
import 'package:smart_courier/features/orders/domain/entities/order.dart';
import 'package:smart_courier/features/orders/domain/use_cases/create_order_use_case.dart';

part 'order_form_event.dart';
part 'order_form_state.dart';

class OrderFormBloc extends Bloc<OrderFormEvent, OrderFormState> {
  OrderFormBloc(this._createOrderUseCase) : super(const OrderFormInitial()) {
    on<AddressPickupSelected>(_onPickupSelected);
    on<AddressDropoffSelected>(_onDropoffSelected);
    on<PickupAddressTextChanged>(_onPickupTextChanged);
    on<DropoffAddressTextChanged>(_onDropoffTextChanged);
    on<NoteChanged>(_onNoteChanged);
    on<OrderSubmitted>(_onSubmitted);
  }

  final CreateOrderUseCase _createOrderUseCase;

  OrderFormEditing get _editing {
    final current = state;
    if (current is OrderFormEditing) {
      return current;
    }
    if (current is OrderFormValidating) {
      return current.previous;
    }
    if (current is OrderFormSubmitting) {
      return current.previous;
    }
    if (current is OrderFormError) {
      return current.previous;
    }
    return const OrderFormEditing();
  }

  void _onPickupSelected(
    AddressPickupSelected event,
    Emitter<OrderFormState> emit,
  ) {
    emit(
      _editing.copyWith(
        pickup: event.address,
        pickupText: event.address.address,
        clearPickupError: true,
      ),
    );
  }

  void _onDropoffSelected(
    AddressDropoffSelected event,
    Emitter<OrderFormState> emit,
  ) {
    emit(
      _editing.copyWith(
        dropoff: event.address,
        dropoffText: event.address.address,
        clearDropoffError: true,
      ),
    );
  }

  void _onPickupTextChanged(
    PickupAddressTextChanged event,
    Emitter<OrderFormState> emit,
  ) {
    emit(
      _editing.copyWith(
        pickupText: event.value,
        pickup: Address(
          address: event.value,
          lat: _editing.pickup?.lat ?? 0,
          lng: _editing.pickup?.lng ?? 0,
        ),
        clearPickupError: true,
      ),
    );
  }

  void _onDropoffTextChanged(
    DropoffAddressTextChanged event,
    Emitter<OrderFormState> emit,
  ) {
    emit(
      _editing.copyWith(
        dropoffText: event.value,
        dropoff: Address(
          address: event.value,
          lat: _editing.dropoff?.lat ?? 0,
          lng: _editing.dropoff?.lng ?? 0,
        ),
        clearDropoffError: true,
      ),
    );
  }

  void _onNoteChanged(NoteChanged event, Emitter<OrderFormState> emit) {
    emit(_editing.copyWith(note: event.value));
  }

  Future<void> _onSubmitted(
    OrderSubmitted event,
    Emitter<OrderFormState> emit,
  ) async {
    final editing = _editing;
    emit(OrderFormValidating(editing));

    final pickupAddress = editing.resolvedPickup.address;
    final dropoffAddress = editing.resolvedDropoff.address;

    if (pickupAddress.isEmpty || dropoffAddress.isEmpty) {
      emit(
        OrderFormEditing(
          pickup: editing.pickup,
          dropoff: editing.dropoff,
          pickupText: editing.pickupText,
          dropoffText: editing.dropoffText,
          note: editing.note,
          pickupError: pickupAddress.isEmpty
              ? OrderErrorMessages.pickupRequired
              : null,
          dropoffError: dropoffAddress.isEmpty
              ? OrderErrorMessages.dropoffRequired
              : null,
        ),
      );
      return;
    }

    emit(OrderFormSubmitting(editing));

    final result = await _createOrderUseCase(
      input: CreateOrderInput(
        pickup: editing.resolvedPickup,
        dropoff: editing.resolvedDropoff,
        note: editing.note.trim().isEmpty ? null : editing.note.trim(),
      ),
    );

    switch (result) {
      case Success(:final data):
        emit(OrderFormSuccess(data));
      case ResultFailure(:final failure):
        emit(OrderFormError(message: failure.message, previous: editing));
    }
  }
}
