import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:smart_courier/core/utils/result.dart';
import 'package:smart_courier/features/orders/domain/entities/order.dart';
import 'package:smart_courier/features/orders/domain/use_cases/watch_customer_orders_use_case.dart';

part 'customer_orders_state.dart';

class CustomerOrdersCubit extends Cubit<CustomerOrdersState> {
  CustomerOrdersCubit(this._watchCustomerOrdersUseCase)
    : super(const CustomerOrdersInitial());

  final WatchCustomerOrdersUseCase _watchCustomerOrdersUseCase;
  StreamSubscription<Result<List<Order>>>? _subscription;

  void watchOrders({required String customerId, String? highlightOrderId}) {
    _subscription?.cancel();
    emit(const CustomerOrdersLoading());

    _subscription = _watchCustomerOrdersUseCase(customerId: customerId).listen(
      (result) {
        switch (result) {
          case Success(:final data):
            emit(
              CustomerOrdersLoaded(
                orders: data,
                highlightOrderId: highlightOrderId,
              ),
            );
          case ResultFailure(:final failure):
            emit(CustomerOrdersError(failure.message));
        }
      },
    );
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
