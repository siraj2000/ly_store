import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../controllers/auth_controller.dart';
import '../../../core/constants/app_routes.dart';
import '../../widgets/common/app_header.dart';
import 'admin_dashboard_screen.dart';

class AdminMainScreen extends StatelessWidget {
  const AdminMainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppHeader(title: 'Admin Dashboard'),
      drawer: Drawer(
        child: ListView(
          children: [
            const DrawerHeader(child: Text('StyleHub Admin')),
            ...[
              ('Admin Accounts', AppRoutes.adminAccounts),
              ('Manage Customers', AppRoutes.adminCustomers),
              ('Manage Sellers', AppRoutes.adminSellers),
              ('Seller Approval Requests', AppRoutes.adminSellerApproval),
              ('Product Approval Requests', AppRoutes.adminProductApproval),
              ('Manage Products', AppRoutes.adminProducts),
              ('Manage Categories', AppRoutes.adminCategories),
              ('Manage Orders', AppRoutes.adminOrders),
              ('Manage Coupons', AppRoutes.adminCoupons),
              ('Manage Banners', AppRoutes.adminBanners),
              ('Reports', AppRoutes.adminReports),
              ('Complaints', AppRoutes.adminComplaints),
              ('Settings', AppRoutes.adminSettings),
            ].map(
              (entry) => ListTile(
                title: Text(entry.$1),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, entry.$2);
                },
              ),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout_rounded),
              title: const Text('Log out'),
              onTap: () {
                context.read<AuthController>().logout();
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  AppRoutes.login,
                  (_) => false,
                );
              },
            ),
          ],
        ),
      ),
      body: const AdminDashboardScreen(embedInScaffold: false),
    );
  }
}
