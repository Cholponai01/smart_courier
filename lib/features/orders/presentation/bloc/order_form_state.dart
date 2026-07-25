part of 'order_form_bloc.dart';

sealed class OrderFormState extends Equatable {
  const OrderFormState();

  @override
  List<Object?> get props => [];
}

final class OrderFormInitial extends OrderFormState {
  const OrderFormInitial();
}

final class OrderFormEditing extends OrderFormState {
  const OrderFormEditing({
    this.pickup,
    this.dropoff,
    this.pickupText = '',
    this.dropoffText = '',
    this.note = '',
    this.pickupError,
    this.dropoffError,
  });

  final Address? pickup;
  final Address? dropoff;
  final String pickupText;
  final String dropoffText;
  final String note;
  final String? pickupError;
  final String? dropoffError;

  bool get canSubmit =>
      _resolvedPickupAddress.isNotEmpty && _resolvedDropoffAddress.isNotEmpty;

  String get _resolvedPickupAddress =>
      pickup?.address.trim().isNotEmpty == true
          ? pickup!.address.trim()
          : pickupText.trim();

  String get _resolvedDropoffAddress =>
      dropoff?.address.trim().isNotEmpty == true
          ? dropoff!.address.trim()
          : dropoffText.trim();

  Address get resolvedPickup => Address(
    address: _resolvedPickupAddress,
    lat: pickup?.lat ?? 0,
    lng: pickup?.lng ?? 0,
  );

  Address get resolvedDropoff => Address(
    address: _resolvedDropoffAddress,
    lat: dropoff?.lat ?? 0,
    lng: dropoff?.lng ?? 0,
  );

  OrderFormEditing copyWith({
    Address? pickup,
    Address? dropoff,
    String? pickupText,
    String? dropoffText,
    String? note,
    String? pickupError,
    String? dropoffError,
    bool clearPickupError = false,
    bool clearDropoffError = false,
  }) {
    return OrderFormEditing(
      pickup: pickup ?? this.pickup,
      dropoff: dropoff ?? this.dropoff,
      pickupText: pickupText ?? this.pickupText,
      dropoffText: dropoffText ?? this.dropoffText,
      note: note ?? this.note,
      pickupError: clearPickupError ? null : pickupError ?? this.pickupError,
      dropoffError: clearDropoffError ? null : dropoffError ?? this.dropoffError,
    );
  }

  @override
  List<Object?> get props => [
    pickup,
    dropoff,
    pickupText,
    dropoffText,
    note,
    pickupError,
    dropoffError,
  ];
}

final class OrderFormValidating extends OrderFormState {
  const OrderFormValidating(this.previous);

  final OrderFormEditing previous;

  @override
  List<Object?> get props => [previous];
}

final class OrderFormSubmitting extends OrderFormState {
  const OrderFormSubmitting(this.previous);

  final OrderFormEditing previous;

  @override
  List<Object?> get props => [previous];
}

final class OrderFormSuccess extends OrderFormState {
  const OrderFormSuccess(this.order);

  final Order order;

  @override
  List<Object?> get props => [order];
}

final class OrderFormError extends OrderFormState {
  const OrderFormError({
    required this.message,
    required this.previous,
  });

  final String message;
  final OrderFormEditing previous;

  @override
  List<Object?> get props => [message, previous];
}
