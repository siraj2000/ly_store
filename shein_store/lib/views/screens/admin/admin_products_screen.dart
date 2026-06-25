import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../controllers/admin_product_approval_controller.dart';
import '../../../core/helpers/localized_status_helper.dart';
import '../../widgets/common/app_header.dart';

class AdminProductsScreen extends StatelessWidget {
  const AdminProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AdminProductApprovalController>();
    return Scaffold(
      appBar: const AppHeader(title: 'Manage Products'),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: controller.allProducts
            .map(
              (product) => Card(
                child: ListTile(
                  title: Text(product.title),
                  subtitle: Text(
                    '${product.sellerName} | ${localizedSellerProductStatus(context, product.status)}',
                  ),
                  trailing: IconButton(
                    onPressed: () => controller.removeProduct(product.id),
                    icon: const Icon(Icons.delete_outline),
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}
