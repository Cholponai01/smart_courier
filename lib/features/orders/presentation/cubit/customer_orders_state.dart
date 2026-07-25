part of 'customer_orders_cubit.dart';

sealed class CustomerOrdersState extends Equatable {
  const CustomerOrdersState();

  @override
  List<Object?> get props => [];
}

final class CustomerOrdersInitial extends CustomerOrdersState {
  const CustomerOrdersInitial();
}

final class CustomerOrdersLoading extends CustomerOrdersState {
  const CustomerOrdersLoading();
}

final class CustomerOrdersLoaded extends CustomerOrdersState {
  const CustomerOrdersLoaded({
    required this.orders,
    this.highlightOrderId,
  });

  final List<Order> orders;
  final String? highlightOrderId;

  @override
  List<Object?> get props => [orders, highlightOrderId];
}

final class CustomerOrdersError extends CustomerOrdersState {
  const CustomerOrdersError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
