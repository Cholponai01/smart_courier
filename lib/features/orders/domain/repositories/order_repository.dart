import 'package:smart_courier/core/utils/result.dart';
import 'package:smart_courier/features/orders/domain/entities/create_order_input.dart';
import 'package:smart_courier/features/orders/domain/entities/order.dart';

abstract class OrderRepository {
  Future<Result<Order>> createOrder({required CreateOrderInput input});

  Stream<Result<Order>> watchOrder({required String orderId});

  Stream<Result<List<Order>>> watchCustomerOrders({
    required String customerId,
  });

  Stream<Result<List<Order>>> watchOpenOrders();

  Future<Result<Order>> acceptOrder({
    required String orderId,
    required String courierId,
  });
}
