import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:smart_courier/core/error/failure.dart';
import 'package:smart_courier/core/utils/result.dart';
import 'package:smart_courier/features/orders/domain/entities/address.dart';
import 'package:smart_courier/features/orders/domain/entities/create_order_input.dart';
import 'package:smart_courier/features/orders/domain/entities/order.dart';
import 'package:smart_courier/features/orders/domain/repositories/order_repository.dart';
import 'package:smart_courier/features/orders/domain/use_cases/create_order_use_case.dart';

class MockOrderRepository extends Mock implements OrderRepository {}

void main() {
  late MockOrderRepository repository;
  late CreateOrderUseCase useCase;

  const input = CreateOrderInput(
    pickup: Address(address: 'Pickup St', lat: 1, lng: 2),
    dropoff: Address(address: 'Dropoff St', lat: 3, lng: 4),
    note: 'Fragile',
  );

  final order = Order(
    id: 'order-1',
    customerId: 'customer-1',
    status: OrderStatus.created,
    pickup: input.pickup,
    dropoff: input.dropoff,
    note: 'Fragile',
    amount: 0,
    paymentStatus: PaymentStatus.pending,
    createdAt: DateTime.utc(2026, 1, 1),
  );

  setUp(() {
    repository = MockOrderRepository();
    useCase = CreateOrderUseCase(repository);
  });

  test('returns created order when repository succeeds', () async {
    when(
      () => repository.createOrder(input: input),
    ).thenAnswer((_) async => Success(order));

    final result = await useCase(input: input);

    expect(result, isA<Success<Order>>());
    expect((result as Success<Order>).data.id, 'order-1');
    verify(() => repository.createOrder(input: input)).called(1);
  });

  test('propagates repository failure', () async {
    when(
      () => repository.createOrder(input: input),
    ).thenAnswer((_) async => const ResultFailure(UnknownFailure()));

    final result = await useCase(input: input);

    expect(result, isA<ResultFailure<Order>>());
  });
}
