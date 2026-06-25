import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../controllers/admin_coupon_controller.dart';
import '../../widgets/common/app_header.dart';

class AdminCouponsScreen extends StatelessWidget {
  const AdminCouponsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AdminCouponController>();
    return Scaffold(
      appBar: const AppHeader(title: 'Manage Coupons'),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: controller.coupons
            .map(
              (coupon) => Card(
                child: ListTile(
                  title: Text(coupon.title),
                  subtitle: Text(coupon.code),
                  trailing: Text(
                    coupon.isPercentage
                        ? '${coupon.amount.toInt()}%'
                        : '\$${coupon.amount}',
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}
