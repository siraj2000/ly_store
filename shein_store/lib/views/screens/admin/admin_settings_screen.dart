import 'package:flutter/material.dart';

import '../../widgets/common/app_header.dart';

class AdminSettingsScreen extends StatelessWidget {
  const AdminSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppHeader(title: 'Admin Settings'),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          SwitchListTile(
            value: false,
            onChanged: null,
            title: Text('Automatic product approval'),
          ),
          SwitchListTile(
            value: true,
            onChanged: null,
            title: Text('Privacy-safe customer masking'),
          ),
          ListTile(
            title: Text('Platform commission'),
            subtitle: Text('Editable in a real admin backend later'),
          ),
        ],
      ),
    );
  }
}
