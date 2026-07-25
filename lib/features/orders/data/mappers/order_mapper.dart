import 'package:smart_courier/features/orders/data/models/address_dto.dart';
import 'package:smart_courier/features/orders/data/models/order_dto.dart';
import 'package:smart_courier/features/orders/domain/entities/address.dart';
import 'package:smart_courier/features/orders/domain/entities/create_order_input.dart';
import 'package:smart_courier/features/orders/domain/entities/order.dart';

abstract final class OrderMapper {
  static Address toAddress(AddressDto dto) {
    return Address(address: dto.address, lat: dto.lat, lng: dto.lng);
  }

  static AddressDto toAddressDto(Address address) {
    return AddressDto(
      address: address.address.trim(),
      lat: address.lat,
      lng: address.lng,
    );
  }

  static Order toEntity(OrderDto dto) {
    return Order(
      id: dto.id,
      customerId: dto.customerId,
      courierId: dto.courierId,
      status: _parseStatus(dto.status),
      pickup: toAddress(dto.pickup),
      dropoff: toAddress(dto.dropoff),
      note: dto.note,
      amount: dto.amount,
      paymentStatus: _parsePaymentStatus(dto.paymentStatus),
      createdAt: dto.createdAt,
      acceptedAt: dto.acceptedAt,
      pickedUpAt: dto.pickedUpAt,
      deliveredAt: dto.deliveredAt,
    );
  }

  static OrderDto fromCreateInput({
    required String id,
    required String customerId,
    required CreateOrderInput input,
    required DateTime createdAt,
  }) {
    return OrderDto(
      id: id,
      customerId: customerId,
      status: 'created',
      pickup: toAddressDto(input.pickup),
      dropoff: toAddressDto(input.dropoff),
      note: _normalizeNote(input.note),
      amount: 0,
      paymentStatus: 'pending',
      createdAt: createdAt,
    );
  }

  static String? _normalizeNote(String? note) {
    final trimmed = note?.trim();
    if (trimmed == null || trimmed.isEmpty) {
      return null;
    }
    return trimmed;
  }

  static OrderStatus _parseStatus(String value) {
    return switch (value) {
      'accepted' => OrderStatus.accepted,
      'picked_up' => OrderStatus.pickedUp,
      'delivered' => OrderStatus.delivered,
      'completed' => OrderStatus.completed,
      'cancelled' => OrderStatus.cancelled,
      _ => OrderStatus.created,
    };
  }

  static PaymentStatus _parsePaymentStatus(String value) {
    return switch (value) {
      'captured' => PaymentStatus.captured,
      'failed' => PaymentStatus.failed,
      _ => PaymentStatus.pending,
    };
  }
}
