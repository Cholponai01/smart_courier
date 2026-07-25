import 'package:smart_courier/core/utils/result.dart';
import 'package:smart_courier/features/orders/domain/entities/order.dart';
import 'package:smart_courier/features/orders/domain/repositories/order_repository.dart';

class WatchCustomerOrdersUseCase {
  const WatchCustomerOrdersUseCase(this._repository);

  final OrderRepository _repository;

  Stream<Result<List<Order>>> call({required String customerId}) {
    return _repository.watchCustomerOrders(customerId: customerId);
  }
}
