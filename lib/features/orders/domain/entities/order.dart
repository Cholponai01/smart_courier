import 'package:equatable/equatable.dart';
import 'package:smart_courier/features/orders/domain/entities/address.dart';

enum OrderStatus {
  created,
  accepted,
  pickedUp,
  delivered,
  completed,
  cancelled,
}

enum PaymentStatus { pending, captured, failed }

class Order extends Equatable {
  const Order({
    required this.id,
    required this.customerId,
    required this.status,
    required this.pickup,
    required this.dropoff,
    required this.amount,
    required this.paymentStatus,
    required this.createdAt,
    this.courierId,
    this.note,
    this.acceptedAt,
    this.pickedUpAt,
    this.deliveredAt,
  });

  final String id;
  final String customerId;
  final String? courierId;
  final OrderStatus status;
  final Address pickup;
  final Address dropoff;
  final String? note;
  final double amount;
  final PaymentStatus paymentStatus;
  final DateTime createdAt;
  final DateTime? acceptedAt;
  final DateTime? pickedUpAt;
  final DateTime? deliveredAt;

  @override
  List<Object?> get props => [
    id,
    customerId,
    courierId,
    status,
    pickup,
    dropoff,
    note,
    amount,
    paymentStatus,
    createdAt,
    acceptedAt,
    pickedUpAt,
    deliveredAt,
  ];
}
