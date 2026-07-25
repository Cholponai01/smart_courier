import 'package:cloud_firestore/cloud_firestore.dart' hide Order;
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:smart_courier/core/error/failure.dart';
import 'package:smart_courier/core/logging/app_logger.dart';
import 'package:smart_courier/core/utils/result.dart';
import 'package:smart_courier/features/orders/data/constants/order_error_messages.dart';
import 'package:smart_courier/features/orders/data/constants/order_firestore_fields.dart';
import 'package:smart_courier/features/orders/data/mappers/order_mapper.dart';
import 'package:smart_courier/features/orders/data/models/order_dto.dart';
import 'package:smart_courier/features/orders/domain/entities/create_order_input.dart';
import 'package:smart_courier/features/orders/domain/entities/order.dart';
import 'package:smart_courier/features/orders/domain/repositories/order_repository.dart';

class OrderRepositoryImpl implements OrderRepository {
  OrderRepositoryImpl({
    required firebase_auth.FirebaseAuth firebaseAuth,
    required FirebaseFirestore firestore,
  }) : _firebaseAuth = firebaseAuth,
       _firestore = firestore;

  static const _logTag = 'OrderRepository';

  final firebase_auth.FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _ordersCollection =>
      _firestore.collection(OrderFirestoreFields.collection);

  @override
  Future<Result<Order>> createOrder({required CreateOrderInput input}) async {
    try {
      final authUser = _firebaseAuth.currentUser;
      if (authUser == null) {
        return const ResultFailure(
          AuthFailure(OrderErrorMessages.notAuthenticated),
        );
      }

      if (input.pickup.address.trim().isEmpty) {
        return const ResultFailure(
          ValidationFailure(OrderErrorMessages.pickupRequired),
        );
      }

      if (input.dropoff.address.trim().isEmpty) {
        return const ResultFailure(
          ValidationFailure(OrderErrorMessages.dropoffRequired),
        );
      }

      final customerId = authUser.uid;
      final docRef = _ordersCollection.doc();
      final dto = OrderMapper.fromCreateInput(
        id: docRef.id,
        customerId: customerId,
        input: input,
        createdAt: DateTime.now().toUtc(),
      );

      final payload = dto.toFirestoreCreate(customerId: customerId)
        ..[OrderFirestoreFields.createdAt] = FieldValue.serverTimestamp();

      AppLogger.debug('createOrder → orders/${docRef.id}', tag: _logTag);
      await docRef.set(payload);

      final snapshot = await docRef.get();
      final data = snapshot.data();
      if (data == null) {
        return const ResultFailure(UnknownFailure());
      }

      final order = OrderMapper.toEntity(
        OrderDto.fromFirestore(id: docRef.id, data: data),
      );
      AppLogger.debug('createOrder ← success id=${order.id}', tag: _logTag);
      return Success(order);
    } on FirebaseException catch (error) {
      AppLogger.error(
        'createOrder ✕ Firestore [${error.code}]',
        tag: _logTag,
        error: error,
      );
      return ResultFailure(_mapFirebaseException(error));
    } catch (error, stackTrace) {
      AppLogger.error(
        'createOrder ✕ unexpected',
        tag: _logTag,
        error: error,
        stackTrace: stackTrace,
      );
      return const ResultFailure(UnknownFailure());
    }
  }

  @override
  Stream<Result<Order>> watchOrder({required String orderId}) {
    return _ordersCollection.doc(orderId).snapshots().map((snapshot) {
      try {
        final data = snapshot.data();
        if (data == null) {
          return const ResultFailure<Order>(UnknownFailure());
        }
        return Success(
          OrderMapper.toEntity(
            OrderDto.fromFirestore(id: snapshot.id, data: data),
          ),
        );
      } catch (error, stackTrace) {
        AppLogger.error(
          'watchOrder ✕ mapping',
          tag: _logTag,
          error: error,
          stackTrace: stackTrace,
        );
        return const ResultFailure<Order>(UnknownFailure());
      }
    });
  }

  @override
  Stream<Result<List<Order>>> watchCustomerOrders({
    required String customerId,
  }) {
    return _ordersCollection
        .where(OrderFirestoreFields.customerId, isEqualTo: customerId)
        .orderBy(OrderFirestoreFields.createdAt, descending: true)
        .snapshots()
        .map(_mapOrderListSnapshot);
  }

  @override
  Stream<Result<List<Order>>> watchOpenOrders() {
    return _ordersCollection
        .where(OrderFirestoreFields.status, isEqualTo: 'created')
        .orderBy(OrderFirestoreFields.createdAt, descending: true)
        .snapshots()
        .map(_mapOrderListSnapshot);
  }

  @override
  Future<Result<Order>> acceptOrder({
    required String orderId,
    required String courierId,
  }) async {
    try {
      final authUser = _firebaseAuth.currentUser;
      if (authUser == null || authUser.uid != courierId) {
        return const ResultFailure(AuthFailure());
      }

      final docRef = _ordersCollection.doc(orderId);
      await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(docRef);
        final data = snapshot.data();
        if (data == null) {
          throw const OrderAlreadyTakenFailure();
        }

        if (data[OrderFirestoreFields.status] != 'created') {
          throw const OrderAlreadyTakenFailure();
        }

        transaction.update(docRef, {
          OrderFirestoreFields.status: 'accepted',
          OrderFirestoreFields.courierId: courierId,
          OrderFirestoreFields.acceptedAt: FieldValue.serverTimestamp(),
        });
      });

      final snapshot = await docRef.get();
      final data = snapshot.data();
      if (data == null) {
        return const ResultFailure(UnknownFailure());
      }

      return Success(
        OrderMapper.toEntity(
          OrderDto.fromFirestore(id: orderId, data: data),
        ),
      );
    } on OrderAlreadyTakenFailure catch (failure) {
      return ResultFailure(failure);
    } on FirebaseException catch (error) {
      AppLogger.error(
        'acceptOrder ✕ Firestore [${error.code}]',
        tag: _logTag,
        error: error,
      );
      return ResultFailure(_mapFirebaseException(error));
    } catch (error, stackTrace) {
      AppLogger.error(
        'acceptOrder ✕ unexpected',
        tag: _logTag,
        error: error,
        stackTrace: stackTrace,
      );
      return const ResultFailure(UnknownFailure());
    }
  }

  Result<List<Order>> _mapOrderListSnapshot(
    QuerySnapshot<Map<String, dynamic>> snapshot,
  ) {
    try {
      final orders = snapshot.docs
          .map(
            (doc) => OrderMapper.toEntity(
              OrderDto.fromFirestore(id: doc.id, data: doc.data()),
            ),
          )
          .toList(growable: false);
      return Success(orders);
    } catch (error, stackTrace) {
      AppLogger.error(
        'watchOrders ✕ mapping',
        tag: _logTag,
        error: error,
        stackTrace: stackTrace,
      );
      return const ResultFailure(UnknownFailure());
    }
  }

  Failure _mapFirebaseException(FirebaseException error) {
    if (error.code == 'unavailable' || error.code == 'network-request-failed') {
      return const NetworkFailure();
    }
    return UnknownFailure(error.message ?? 'Something went wrong.');
  }
}
