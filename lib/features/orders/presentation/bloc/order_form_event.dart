part of 'order_form_bloc.dart';

sealed class OrderFormEvent extends Equatable {
  const OrderFormEvent();

  @override
  List<Object?> get props => [];
}

final class AddressPickupSelected extends OrderFormEvent {
  const AddressPickupSelected(this.address);

  final Address address;

  @override
  List<Object?> get props => [address];
}

final class AddressDropoffSelected extends OrderFormEvent {
  const AddressDropoffSelected(this.address);

  final Address address;

  @override
  List<Object?> get props => [address];
}

final class PickupAddressTextChanged extends OrderFormEvent {
  const PickupAddressTextChanged(this.value);

  final String value;

  @override
  List<Object?> get props => [value];
}

final class DropoffAddressTextChanged extends OrderFormEvent {
  const DropoffAddressTextChanged(this.value);

  final String value;

  @override
  List<Object?> get props => [value];
}

final class NoteChanged extends OrderFormEvent {
  const NoteChanged(this.value);

  final String value;

  @override
  List<Object?> get props => [value];
}

final class OrderSubmitted extends OrderFormEvent {
  const OrderSubmitted();
}
