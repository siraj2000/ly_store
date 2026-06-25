import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../controllers/admin_category_controller.dart';
import '../../widgets/common/app_header.dart';

class AdminCategoriesScreen extends StatelessWidget {
  const AdminCategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AdminCategoryController>();
    return Scaffold(
      appBar: const AppHeader(title: 'Manage Categories'),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: controller.categories
            .map(
              (category) => Card(
                child: ListTile(
                  title: Text(category.name),
                  subtitle: Text(category.subcategories.join(', ')),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}
