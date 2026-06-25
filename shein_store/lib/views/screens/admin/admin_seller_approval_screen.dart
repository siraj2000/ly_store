import 'package:flutter/material.dart';

import '../../widgets/common/app_header.dart';

class AdminSellerApprovalScreen extends StatelessWidget {
  const AdminSellerApprovalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppHeader(title: 'Seller Approval Requests'),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Northline Studio',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 6),
                  const Text('Seller verification request placeholder'),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      OutlinedButton(
                        onPressed: () => _showPendingMessage(context),
                        child: const Text('Approve'),
                      ),
                      OutlinedButton(
                        onPressed: () => _showPendingMessage(context),
                        child: const Text('Reject'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showPendingMessage(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Seller approval workflow is being connected.'),
      ),
    );
  }
}
