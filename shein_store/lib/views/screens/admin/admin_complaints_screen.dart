import 'package:flutter/material.dart';

import '../../widgets/common/app_header.dart';

class AdminComplaintsScreen extends StatelessWidget {
  const AdminComplaintsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppHeader(title: 'Complaints'),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          Card(
            child: ListTile(
              title: Text('Shipping delay complaint'),
              subtitle: Text('Customer reported a delayed delivery.'),
            ),
          ),
          Card(
            child: ListTile(
              title: Text('Refund complaint'),
              subtitle: Text('Customer is waiting for a refund update.'),
            ),
          ),
        ],
      ),
    );
  }
}
