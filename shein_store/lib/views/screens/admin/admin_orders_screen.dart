import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../controllers/admin_order_controller.dart';
import '../../widgets/common/app_header.dart';

class AdminOrdersScreen extends StatelessWidget {
  const AdminOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AdminOrderController>();
    return Scaffold(
      appBar: const AppHeader(title: 'Manage Orders'),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: controller.orders
            .map(
              (order) => Card(
                child: ListTile(
                  title: Text(order.id),
                  subtitle: Text('${order.customerName} • ${order.status}'),
                  trailing: Text('\$${order.total.toStringAsFixed(2)}'),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}
