import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:smart_courier/core/error/failure.dart';
import 'package:smart_courier/core/utils/result.dart';
import 'package:smart_courier/features/orders/data/constants/order_error_messages.dart';
import 'package:smart_courier/features/orders/domain/entities/address.dart';
import 'package:smart_courier/features/orders/domain/entities/create_order_input.dart';
import 'package:smart_courier/features/orders/domain/entities/order.dart';
import 'package:smart_courier/features/orders/domain/use_cases/create_order_use_case.dart';
import 'package:smart_courier/features/orders/presentation/bloc/order_form_bloc.dart';

class MockCreateOrderUseCase extends Mock implements CreateOrderUseCase {}

void main() {
  late CreateOrderUseCase createOrderUseCase;

  const pickup = Address(address: 'Pickup St', lat: 1, lng: 2);
  const dropoff = Address(address: 'Dropoff St', lat: 3, lng: 4);

  final order = Order(
    id: 'order-1',
    customerId: 'customer-1',
    status: OrderStatus.created,
    pickup: pickup,
    dropoff: dropoff,
    amount: 0,
    paymentStatus: PaymentStatus.pending,
    createdAt: DateTime.utc(2026, 1, 1),
  );

  setUpAll(() {
    registerFallbackValue(
      const CreateOrderInput(
        pickup: Address(address: 'fallback', lat: 0, lng: 0),
        dropoff: Address(address: 'fallback', lat: 0, lng: 0),
      ),
    );
  });

  setUp(() {
    createOrderUseCase = MockCreateOrderUseCase();
  });

  OrderFormBloc buildBloc() => OrderFormBloc(createOrderUseCase);

  blocTest<OrderFormBloc, OrderFormState>(
    'starts in initial state',
    build: buildBloc,
    verify: (bloc) => expect(bloc.state, const OrderFormInitial()),
  );

  blocTest<OrderFormBloc, OrderFormState>(
    'updates pickup address from map selection',
    build: buildBloc,
    act: (bloc) => bloc.add(const AddressPickupSelected(pickup)),
    expect: () => [
      const OrderFormEditing(pickup: pickup, pickupText: 'Pickup St'),
    ],
  );

  blocTest<OrderFormBloc, OrderFormState>(
    'updates dropoff address from map selection',
    build: buildBloc,
    act: (bloc) => bloc.add(const AddressDropoffSelected(dropoff)),
    expect: () => [
      const OrderFormEditing(dropoff: dropoff, dropoffText: 'Dropoff St'),
    ],
  );

  blocTest<OrderFormBloc, OrderFormState>(
    'updates note text',
    build: buildBloc,
    act: (bloc) => bloc.add(const NoteChanged('Handle with care')),
    expect: () => [const OrderFormEditing(note: 'Handle with care')],
  );

  blocTest<OrderFormBloc, OrderFormState>(
    'shows validation errors when submitting without addresses',
    build: buildBloc,
    act: (bloc) => bloc.add(const OrderSubmitted()),
    expect: () => [
      const OrderFormValidating(OrderFormEditing()),
      const OrderFormEditing(
        pickupError: OrderErrorMessages.pickupRequired,
        dropoffError: OrderErrorMessages.dropoffRequired,
      ),
    ],
  );

  blocTest<OrderFormBloc, OrderFormState>(
    'emits success when order is created',
    build: () {
      when(
        () => createOrderUseCase(
          input: any(named: 'input'),
        ),
      ).thenAnswer((_) async => Success(order));
      return buildBloc();
    },
    seed: () => const OrderFormEditing(
      pickup: pickup,
      dropoff: dropoff,
      pickupText: 'Pickup St',
      dropoffText: 'Dropoff St',
    ),
    act: (bloc) => bloc.add(const OrderSubmitted()),
    expect: () => [
      OrderFormValidating(
        const OrderFormEditing(
          pickup: pickup,
          dropoff: dropoff,
          pickupText: 'Pickup St',
          dropoffText: 'Dropoff St',
        ),
      ),
      OrderFormSubmitting(
        const OrderFormEditing(
          pickup: pickup,
          dropoff: dropoff,
          pickupText: 'Pickup St',
          dropoffText: 'Dropoff St',
        ),
      ),
      OrderFormSuccess(order),
    ],
  );

  blocTest<OrderFormBloc, OrderFormState>(
    'emits error when create order fails',
    build: () {
      when(
        () => createOrderUseCase(
          input: any(named: 'input'),
        ),
      ).thenAnswer((_) async => const ResultFailure(NetworkFailure()));
      return buildBloc();
    },
    seed: () => const OrderFormEditing(
      pickup: pickup,
      dropoff: dropoff,
      pickupText: 'Pickup St',
      dropoffText: 'Dropoff St',
    ),
    act: (bloc) => bloc.add(const OrderSubmitted()),
    expect: () => [
      OrderFormValidating(
        const OrderFormEditing(
          pickup: pickup,
          dropoff: dropoff,
          pickupText: 'Pickup St',
          dropoffText: 'Dropoff St',
        ),
      ),
      OrderFormSubmitting(
        const OrderFormEditing(
          pickup: pickup,
          dropoff: dropoff,
          pickupText: 'Pickup St',
          dropoffText: 'Dropoff St',
        ),
      ),
      isA<OrderFormError>(),
    ],
  );
}
