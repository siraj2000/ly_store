import 'package:flutter/material.dart';

import '../../widgets/common/app_header.dart';

class AccountSecurityScreen extends StatelessWidget {
  const AccountSecurityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppHeader(title: 'Account Security'),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const ListTile(
            title: Text('Password'),
            subtitle: Text('Last changed recently in this mock profile.'),
          ),
          const ListTile(
            title: Text('Two-step verification'),
            subtitle: Text('Placeholder for future backend integration.'),
          ),
          const ListTile(
            title: Text('Trusted devices'),
            subtitle: Text('Device management can be added later.'),
          ),
          OutlinedButton(
            onPressed: () => _confirmDeleteAccount(context),
            child: const Text('Delete account'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteAccount(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete account'),
        content: const Text(
          'This is a placeholder action in the mock application.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
