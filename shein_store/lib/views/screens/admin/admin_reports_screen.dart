import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../controllers/admin_report_controller.dart';
import '../../widgets/common/app_header.dart';

class AdminReportsScreen extends StatelessWidget {
  const AdminReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AdminReportController>();
    return Scaffold(
      appBar: const AppHeader(title: 'Reports'),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              title: const Text('Total revenue'),
              trailing: Text('\$${controller.totalRevenue.toStringAsFixed(2)}'),
            ),
          ),
          Card(
            child: ListTile(
              title: const Text('Delivered orders'),
              trailing: Text('${controller.deliveredOrders}'),
            ),
          ),
          Card(
            child: ListTile(
              title: const Text('Pending refunds'),
              trailing: Text('${controller.pendingRefunds}'),
            ),
          ),
          Card(
            child: ListTile(
              title: const Text('Complaints'),
              trailing: Text('${controller.complaints}'),
            ),
          ),
        ],
      ),
    );
  }
}
