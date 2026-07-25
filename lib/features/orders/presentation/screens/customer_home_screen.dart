import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_courier/core/router/app_routes.dart';
import 'package:smart_courier/features/orders/presentation/widgets/customer_home_widgets.dart';
import 'package:smart_courier/l10n/app_localizations.dart';

class CustomerHomeScreen extends StatelessWidget {
  const CustomerHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;

    const recentOrders = <({String route, String subtitle})>[];
    const activeOrderEtaMinutes = null as int?;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.homeTab, style: textTheme.titleMedium)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (activeOrderEtaMinutes != null) ...[
            ActiveOrderBanner(
              statusLabel: l10n.activeOrderOnTheWay,
              etaLabel: l10n.activeOrderEta(activeOrderEtaMinutes),
            ),
            const SizedBox(height: 16),
          ],
          CreateOrderCard(
            label: l10n.createNewOrder,
            onTap: () => context.go(AppRoutes.customerNewOrder),
          ),
          const SizedBox(height: 24),
          Text(l10n.recentSectionTitle, style: textTheme.titleMedium),
          const SizedBox(height: 12),
          if (recentOrders.isEmpty)
            RecentOrdersEmpty(message: l10n.recentOrdersEmpty)
          else
            ...recentOrders.map(
              (order) => RecentOrderTile(
                routeLabel: order.route,
                subtitle: order.subtitle,
              ),
            ),
        ],
      ),
    );
  }
}
