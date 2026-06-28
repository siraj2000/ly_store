import 'package:flutter/material.dart';

import '../../../core/constants/app_motion.dart';
import '../../../core/extensions/localization_extension.dart';
import 'seller_add_product_screen.dart';
import 'seller_dashboard_screen.dart';
import 'seller_finance_screen.dart';
import 'seller_orders_screen.dart';
import 'seller_products_screen.dart';
import 'seller_store_screen.dart';

class SellerMainScreen extends StatefulWidget {
  const SellerMainScreen({super.key});

  @override
  State<SellerMainScreen> createState() => _SellerMainScreenState();
}

class _SellerMainScreenState extends State<SellerMainScreen> {
  int _index = 0;

  final _screens = const [
    SellerDashboardScreen(),
    SellerOrdersScreen(),
    SellerAddProductScreen(),
    SellerProductsScreen(),
    SellerStoreScreen(),
    SellerFinanceScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (value) => setState(() => _index = value),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.space_dashboard_outlined),
            selectedIcon: const _SelectedNavIcon(
              icon: Icons.space_dashboard_outlined,
            ),
            label: context.tr('Dashboard', 'لوحة التحكم'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.receipt_long_outlined),
            selectedIcon: const _SelectedNavIcon(
              icon: Icons.receipt_long_outlined,
            ),
            label: context.tr('Orders', 'الطلبات'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.add_box_outlined),
            selectedIcon: const _SelectedNavIcon(icon: Icons.add_box_outlined),
            label: context.tr('Add', 'إضافة'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.inventory_2_outlined),
            selectedIcon: const _SelectedNavIcon(
              icon: Icons.inventory_2_outlined,
            ),
            label: context.tr('Products', 'المنتجات'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.storefront_outlined),
            selectedIcon: const _SelectedNavIcon(
              icon: Icons.storefront_outlined,
            ),
            label: context.tr('Store', 'المتجر'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.account_balance_wallet_outlined),
            selectedIcon: const _SelectedNavIcon(
              icon: Icons.account_balance_wallet_outlined,
            ),
            label: context.tr('Finance', 'المالية'),
          ),
        ],
      ),
    );
  }
}

class _SelectedNavIcon extends StatelessWidget {
  const _SelectedNavIcon({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.94, end: 1.08),
      duration: AppMotion.duration(context, AppMotion.fast),
      curve: AppMotion.standard,
      builder: (context, scale, child) =>
          Transform.scale(scale: scale, child: child),
      child: Icon(icon),
    );
  }
}
