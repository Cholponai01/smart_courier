import 'package:flutter/material.dart';
import 'package:mocktail/mocktail.dart';
import 'package:smart_courier/core/di/injection.dart';
import 'package:smart_courier/core/error/failure.dart';
import 'package:smart_courier/core/map/map_pick_result.dart';
import 'package:smart_courier/core/map/map_picker_controller.dart';
import 'package:smart_courier/core/utils/result.dart';
import 'package:smart_courier/features/auth/domain/use_cases/send_email_verification_use_case.dart';
import 'package:smart_courier/features/auth/presentation/cubit/resend_email_verification_cubit.dart';
import 'package:smart_courier/features/orders/domain/entities/address.dart';
import 'package:smart_courier/features/orders/domain/entities/create_order_input.dart';
import 'package:smart_courier/features/orders/domain/use_cases/create_order_use_case.dart';
import 'package:smart_courier/features/orders/domain/use_cases/watch_customer_orders_use_case.dart';
import 'package:smart_courier/features/orders/presentation/bloc/order_form_bloc.dart';
import 'package:smart_courier/features/orders/presentation/cubit/customer_orders_cubit.dart';

class MockCreateOrderUseCase extends Mock implements CreateOrderUseCase {}

class MockWatchCustomerOrdersUseCase extends Mock
    implements WatchCustomerOrdersUseCase {}

class MockSendEmailVerificationUseCase extends Mock
    implements SendEmailVerificationUseCase {}

class FakeMapPickerController implements MapPickerController {
  @override
  bool get isAvailable => false;

  @override
  Widget buildMapSection({
    required MapPickTarget target,
    required String addressHint,
    required ValueChanged<MapPickResult> onLocationPicked,
  }) {
    return const SizedBox.shrink();
  }
}

void registerShellTestFallbackValues() {
  registerFallbackValue(
    const CreateOrderInput(
      pickup: Address(address: 'fallback', lat: 0, lng: 0),
      dropoff: Address(address: 'fallback', lat: 0, lng: 0),
    ),
  );
}

/// Minimal GetIt registrations for router/shell widget tests.
void registerShellTestDependencies() {
  if (!sl.isRegistered<MapPickerController>()) {
    sl.registerLazySingleton<MapPickerController>(
      () => FakeMapPickerController(),
    );
  }

  if (!sl.isRegistered<CreateOrderUseCase>()) {
    final useCase = MockCreateOrderUseCase();
    when(
      () => useCase(input: any(named: 'input')),
    ).thenAnswer((_) async => const ResultFailure(UnknownFailure()));
    sl.registerLazySingleton<CreateOrderUseCase>(() => useCase);
  }

  if (!sl.isRegistered<WatchCustomerOrdersUseCase>()) {
    final useCase = MockWatchCustomerOrdersUseCase();
    when(
      () => useCase(customerId: any(named: 'customerId')),
    ).thenAnswer((_) => Stream.value(const Success([])));
    sl.registerLazySingleton<WatchCustomerOrdersUseCase>(() => useCase);
  }

  if (!sl.isRegistered<SendEmailVerificationUseCase>()) {
    sl.registerLazySingleton<SendEmailVerificationUseCase>(
      MockSendEmailVerificationUseCase.new,
    );
  }

  if (!sl.isRegistered<OrderFormBloc>()) {
    sl.registerFactory<OrderFormBloc>(() => OrderFormBloc(sl()));
  }

  if (!sl.isRegistered<CustomerOrdersCubit>()) {
    sl.registerFactory<CustomerOrdersCubit>(() => CustomerOrdersCubit(sl()));
  }

  if (!sl.isRegistered<ResendEmailVerificationCubit>()) {
    sl.registerFactory<ResendEmailVerificationCubit>(
      () => ResendEmailVerificationCubit(sl()),
    );
  }
}
