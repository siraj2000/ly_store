import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../controllers/admin_product_approval_controller.dart';
import '../../../controllers/product_controller.dart';
import '../../../core/helpers/localized_status_helper.dart';
import '../../widgets/common/app_header.dart';

class AdminProductApprovalScreen extends StatelessWidget {
  const AdminProductApprovalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AdminProductApprovalController>();
    return Scaffold(
      appBar: const AppHeader(title: 'Product Approval Requests'),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: controller.pendingProducts
            .map(
              (product) => Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.title,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text('${product.sellerName} | ${product.department}'),
                      Text(
                        'Status: ${localizedSellerProductStatus(context, product.status)}',
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: [
                          OutlinedButton(
                            onPressed: () {
                              controller.approveProduct(product.id);
                              context
                                  .read<ProductController>()
                                  .refreshPublicProducts();
                            },
                            child: const Text('Approve'),
                          ),
                          OutlinedButton(
                            onPressed: () =>
                                controller.rejectProduct(product.id),
                            child: const Text('Reject'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}
