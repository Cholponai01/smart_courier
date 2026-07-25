import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_courier/core/di/injection.dart';
import 'package:smart_courier/core/router/app_routes.dart';
import 'package:smart_courier/core/widgets/empty_state_view.dart';
import 'package:smart_courier/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:smart_courier/features/orders/domain/entities/order.dart';
import 'package:smart_courier/features/orders/presentation/cubit/customer_orders_cubit.dart';
import 'package:smart_courier/l10n/app_localizations.dart';

class CustomerOrdersScreen extends StatefulWidget {
  const CustomerOrdersScreen({super.key});

  @override
  State<CustomerOrdersScreen> createState() => _CustomerOrdersScreenState();
}

class _CustomerOrdersScreenState extends State<CustomerOrdersScreen> {
  final _filterController = TextEditingController();

  @override
  void dispose() {
    _filterController.dispose();
    super.dispose();
  }

  String? _highlightFromRoute(BuildContext context) {
    return GoRouterState.of(context).uri.queryParameters[
      AppRoutes.highlightOrderQueryParam
    ];
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final authState = context.read<AuthBloc>().state;
    if (authState is! Authenticated) {
      return const SizedBox.shrink();
    }

    return BlocProvider(
      create: (_) => sl<CustomerOrdersCubit>()
        ..watchOrders(
          customerId: authState.user.id,
          highlightOrderId: _highlightFromRoute(context),
        ),
      child: Scaffold(
        appBar: AppBar(title: Text(l10n.ordersTab)),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                key: const Key('customer_orders_filter_field'),
                controller: _filterController,
                decoration: InputDecoration(labelText: l10n.ordersFilterHint),
              ),
            ),
            Expanded(
              child: BlocBuilder<CustomerOrdersCubit, CustomerOrdersState>(
                builder: (context, state) {
                  if (state is CustomerOrdersLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (state is CustomerOrdersError) {
                    return Center(child: Text(state.message));
                  }
                  if (state is CustomerOrdersLoaded) {
                    final filtered = _filterOrders(
                      state.orders,
                      _filterController.text,
                    );
                    if (filtered.isEmpty) {
                      return EmptyStateView(
                        icon: Icons.receipt_long_outlined,
                        message: l10n.customerOrdersEmpty,
                      );
                    }
                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final order = filtered[index];
                        final isHighlighted = order.id == state.highlightOrderId;
                        return _OrderListTile(
                          order: order,
                          isHighlighted: isHighlighted,
                          statusLabel: _statusLabel(l10n, order.status),
                        );
                      },
                    );
                  }
                  return EmptyStateView(
                    icon: Icons.receipt_long_outlined,
                    message: l10n.customerOrdersEmpty,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Order> _filterOrders(List<Order> orders, String query) {
    final normalized = query.trim().toLowerCase();
    if (normalized.isEmpty) {
      return orders;
    }
    return orders
        .where(
          (order) =>
              order.pickup.address.toLowerCase().contains(normalized) ||
              order.dropoff.address.toLowerCase().contains(normalized),
        )
        .toList(growable: false);
  }

  String _statusLabel(AppLocalizations l10n, OrderStatus status) {
    return switch (status) {
      OrderStatus.created => l10n.orderStatusCreated,
      OrderStatus.accepted => l10n.orderStatusAccepted,
      OrderStatus.pickedUp => l10n.orderStatusPickedUp,
      OrderStatus.delivered => l10n.orderStatusDelivered,
      OrderStatus.completed => l10n.orderStatusCompleted,
      OrderStatus.cancelled => l10n.orderStatusCancelled,
    };
  }
}

class _OrderListTile extends StatelessWidget {
  const _OrderListTile({
    required this.order,
    required this.isHighlighted,
    required this.statusLabel,
  });

  final Order order;
  final bool isHighlighted;
  final String statusLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      color: isHighlighted
          ? colorScheme.primaryContainer.withValues(alpha: 0.35)
          : null,
      child: ListTile(
        key: Key('customer_order_tile_${order.id}'),
        title: Text('${order.pickup.address} → ${order.dropoff.address}'),
        subtitle: Text(statusLabel),
      ),
    );
  }
}
