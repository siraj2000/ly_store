import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../controllers/admin_banner_controller.dart';
import '../../widgets/common/app_header.dart';

class AdminBannersScreen extends StatelessWidget {
  const AdminBannersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AdminBannerController>();
    return Scaffold(
      appBar: const AppHeader(title: 'Manage Banners'),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: controller.banners
            .map(
              (banner) => Card(
                child: ListTile(
                  title: Text(banner),
                  subtitle: const Text('Homepage banner placeholder'),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}
