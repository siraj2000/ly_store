import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../controllers/admin_user_controller.dart';
import '../../widgets/common/app_header.dart';

class AdminCustomersScreen extends StatelessWidget {
  const AdminCustomersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AdminUserController>();
    return Scaffold(
      appBar: const AppHeader(title: 'Manage Customers'),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: controller.customers
            .map(
              (user) => Card(
                child: ListTile(
                  title: Text(user.name),
                  subtitle: Text(user.email),
                  trailing: Switch(
                    value: user.isActive,
                    onChanged: (_) => controller.toggleActive(user),
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}
