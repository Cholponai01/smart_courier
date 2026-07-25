import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:smart_courier/features/orders/data/constants/order_firestore_fields.dart';
import 'package:smart_courier/features/orders/data/models/address_dto.dart';

class OrderDto extends Equatable {
  const OrderDto({
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
  final String status;
  final AddressDto pickup;
  final AddressDto dropoff;
  final String? note;
  final double amount;
  final String paymentStatus;
  final DateTime createdAt;
  final DateTime? acceptedAt;
  final DateTime? pickedUpAt;
  final DateTime? deliveredAt;

  Map<String, dynamic> toFirestoreCreate({required String customerId}) {
    return {
      OrderFirestoreFields.customerId: customerId,
      OrderFirestoreFields.courierId: null,
      OrderFirestoreFields.status: 'created',
      OrderFirestoreFields.pickup: pickup.toFirestore(),
      OrderFirestoreFields.dropoff: dropoff.toFirestore(),
      OrderFirestoreFields.note: note,
      OrderFirestoreFields.amount: amount,
      OrderFirestoreFields.paymentStatus: 'pending',
      OrderFirestoreFields.createdAt: createdAt,
      OrderFirestoreFields.acceptedAt: null,
      OrderFirestoreFields.pickedUpAt: null,
      OrderFirestoreFields.deliveredAt: null,
    };
  }

  factory OrderDto.fromFirestore({
    required String id,
    required Map<String, dynamic> data,
  }) {
    return OrderDto(
      id: id,
      customerId: data[OrderFirestoreFields.customerId] as String? ?? '',
      courierId: data[OrderFirestoreFields.courierId] as String?,
      status: data[OrderFirestoreFields.status] as String? ?? 'created',
      pickup: AddressDto.fromFirestore(
        Map<String, dynamic>.from(
          data[OrderFirestoreFields.pickup] as Map? ?? {},
        ),
      ),
      dropoff: AddressDto.fromFirestore(
        Map<String, dynamic>.from(
          data[OrderFirestoreFields.dropoff] as Map? ?? {},
        ),
      ),
      note: data[OrderFirestoreFields.note] as String?,
      amount: (data[OrderFirestoreFields.amount] as num?)?.toDouble() ?? 0,
      paymentStatus:
          data[OrderFirestoreFields.paymentStatus] as String? ?? 'pending',
      createdAt: _readTimestamp(data[OrderFirestoreFields.createdAt]),
      acceptedAt: _readOptionalTimestamp(data[OrderFirestoreFields.acceptedAt]),
      pickedUpAt: _readOptionalTimestamp(data[OrderFirestoreFields.pickedUpAt]),
      deliveredAt: _readOptionalTimestamp(
        data[OrderFirestoreFields.deliveredAt],
      ),
    );
  }

  static DateTime _readTimestamp(Object? value) {
    if (value is Timestamp) {
      return value.toDate().toUtc();
    }
    if (value is DateTime) {
      return value.toUtc();
    }
    return DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);
  }

  static DateTime? _readOptionalTimestamp(Object? value) {
    if (value == null) {
      return null;
    }
    return _readTimestamp(value);
  }

  @override
  List<Object?> get props => [id, customerId, courierId, status];
}
