import 'package:equatable/equatable.dart';
import 'package:smart_courier/features/orders/domain/entities/address.dart';

class CreateOrderInput extends Equatable {
  const CreateOrderInput({
    required this.pickup,
    required this.dropoff,
    this.note,
  });

  final Address pickup;
  final Address dropoff;
  final String? note;

  @override
  List<Object?> get props => [pickup, dropoff, note];
}
