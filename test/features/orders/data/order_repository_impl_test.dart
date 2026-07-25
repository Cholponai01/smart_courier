import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_courier/core/utils/result.dart';
import 'package:smart_courier/features/orders/data/constants/order_firestore_fields.dart';
import 'package:smart_courier/features/orders/data/mappers/order_mapper.dart';
import 'package:smart_courier/features/orders/data/models/address_dto.dart';
import 'package:smart_courier/features/orders/data/models/order_dto.dart';
import 'package:smart_courier/features/orders/data/repositories/order_repository_impl.dart';
import 'package:smart_courier/features/orders/domain/entities/address.dart';
import 'package:smart_courier/features/orders/domain/entities/create_order_input.dart';
import 'package:smart_courier/features/orders/domain/entities/order.dart';

void main() {
  group('OrderMapper', () {
    test('maps DTO to entity with snake_case status values', () {
      final dto = OrderDto(
        id: 'order-1',
        customerId: 'customer-1',
        status: 'picked_up',
        pickup: const AddressDto(address: 'A', lat: 1, lng: 2),
        dropoff: const AddressDto(address: 'B', lat: 3, lng: 4),
        amount: 10,
        paymentStatus: 'pending',
        createdAt: DateTime.utc(2026, 1, 1),
      );

      final entity = OrderMapper.toEntity(dto);

      expect(entity.status, OrderStatus.pickedUp);
      expect(entity.pickup.address, 'A');
    });

    test('maps create input to DTO with customer id from auth context', () {
      const input = CreateOrderInput(
        pickup: Address(address: 'Pickup', lat: 1, lng: 2),
        dropoff: Address(address: 'Dropoff', lat: 3, lng: 4),
      );

      final dto = OrderMapper.fromCreateInput(
        id: 'generated-id',
        customerId: 'auth-user-id',
        input: input,
        createdAt: DateTime.utc(2026, 1, 2),
      );

      expect(dto.customerId, 'auth-user-id');
      expect(dto.status, 'created');
      expect(dto.pickup.address, 'Pickup');
    });
  });

  group('OrderRepositoryImpl.createOrder customerId', () {
    test('writes auth uid as customerId regardless of spoofed input', () async {
      final auth = MockFirebaseAuth(
        signedIn: true,
        mockUser: MockUser(uid: 'real-customer-id'),
      );
      final firestore = FakeFirebaseFirestore();
      final repository = OrderRepositoryImpl(
        firebaseAuth: auth,
        firestore: firestore,
      );

      const input = CreateOrderInput(
        pickup: Address(address: 'Pickup', lat: 1, lng: 2),
        dropoff: Address(address: 'Dropoff', lat: 3, lng: 4),
      );

      final result = await repository.createOrder(input: input);

      expect(result, isA<Success<Order>>());
      final docs = await firestore
          .collection(OrderFirestoreFields.collection)
          .get();
      expect(
        docs.docs.single.data()[OrderFirestoreFields.customerId],
        'real-customer-id',
      );
    });
  });
}
