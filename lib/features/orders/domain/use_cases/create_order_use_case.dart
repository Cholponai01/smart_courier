import 'package:smart_courier/core/utils/result.dart';
import 'package:smart_courier/features/orders/domain/entities/create_order_input.dart';
import 'package:smart_courier/features/orders/domain/entities/order.dart';
import 'package:smart_courier/features/orders/domain/repositories/order_repository.dart';

class CreateOrderUseCase {
  const CreateOrderUseCase(this._repository);

  final OrderRepository _repository;

  Future<Result<Order>> call({required CreateOrderInput input}) {
    return _repository.createOrder(input: input);
  }
}
