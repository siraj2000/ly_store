import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../controllers/admin_dashboard_controller.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/constants/app_sizes.dart';
import '../../widgets/common/app_header.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key, this.embedInScaffold = true});

  final bool embedInScaffold;

  @override
  Widget build(BuildContext context) {
    final body = Consumer<AdminDashboardController>(
      builder: (context, controller, _) => ListView(
        padding: const EdgeInsets.all(AppSizes.lg),
        children: [
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _AdminMetric(
                label: 'Total users',
                value: '${controller.totalUsers}',
              ),
              _AdminMetric(
                label: 'Customers',
                value: '${controller.totalCustomers}',
              ),
              _AdminMetric(
                label: 'Sellers',
                value: '${controller.totalSellers}',
              ),
              _AdminMetric(
                label: 'Products',
                value: '${controller.totalProducts}',
              ),
              _AdminMetric(
                label: 'Pending approvals',
                value: '${controller.pendingProductApprovals}',
              ),
              _AdminMetric(label: 'Orders', value: '${controller.totalOrders}'),
              _AdminMetric(
                label: 'Today revenue',
                value: '\$${controller.todayRevenue.toStringAsFixed(2)}',
              ),
              _AdminMetric(
                label: 'Pending refunds',
                value: '${controller.pendingRefunds}',
              ),
              _AdminMetric(
                label: 'Open complaints',
                value: '${controller.openComplaints}',
              ),
            ],
          ),
          const SizedBox(height: AppSizes.xl),
          Container(
            padding: const EdgeInsets.all(AppSizes.lg),
            decoration: BoxDecoration(
              color: context.appColors.card,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: context.appColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Access management',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  'Review seeded admin accounts, roles, and permissions in one place.',
                  style: TextStyle(color: context.appColors.secondaryText),
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () =>
                      Navigator.pushNamed(context, AppRoutes.adminAccounts),
                  child: const Text('Open Admin Accounts'),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSizes.xl),
          Text(
            'Latest platform activity',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: AppSizes.md),
          const Card(
            child: ListTile(
              title: Text('Seller product pending approval'),
              subtitle: Text('Northline Studio submitted a new listing.'),
            ),
          ),
          const Card(
            child: ListTile(
              title: Text('Customer order created'),
              subtitle: Text(
                'A new marketplace order needs fulfillment routing.',
              ),
            ),
          ),
          const Card(
            child: ListTile(
              title: Text('Complaint opened'),
              subtitle: Text('A customer opened a shipping delay complaint.'),
            ),
          ),
        ],
      ),
    );
    if (!embedInScaffold) return body;
    return Scaffold(
      appBar: const AppHeader(title: 'Admin Dashboard'),
      body: body,
    );
  }
}

class _AdminMetric extends StatelessWidget {
  const _AdminMetric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      width: 170,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: colors.secondaryText,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(color: colors.primaryText),
          ),
        ],
      ),
    );
  }
}
