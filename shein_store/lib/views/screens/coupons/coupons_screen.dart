import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../controllers/coupon_controller.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/extensions/localization_extension.dart';
import '../../../core/widgets/app_empty_state.dart';
import '../../widgets/common/app_header.dart';
import '../../widgets/common/coupon_card.dart';

class CouponsScreen extends StatelessWidget {
  const CouponsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppHeader(title: context.tr('Coupons', 'الكوبونات')),
        body: Column(
          children: [
            TabBar(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              tabs: [
                Tab(text: context.tr('Available', 'متاحة')),
                Tab(text: context.tr('Used', 'مستخدمة')),
                Tab(text: context.tr('Expired', 'منتهية')),
              ],
            ),
            Expanded(
              child: Consumer<CouponController>(
                builder: (context, couponController, _) => TabBarView(
                  children: [
                    ListView(
                      padding: const EdgeInsets.all(AppSizes.lg),
                      children: couponController.allCoupons
                          .map((coupon) => CouponCard(coupon: coupon))
                          .toList(),
                    ),
                    AppEmptyState(
                      title: context.tr(
                        'No used coupons',
                        'لا توجد كوبونات مستخدمة',
                      ),
                      message: context.tr(
                        'Coupons you redeem will appear here.',
                        'ستظهر هنا الكوبونات التي قمت باستخدامها.',
                      ),
                    ),
                    AppEmptyState(
                      title: context.tr(
                        'No expired coupons',
                        'لا توجد كوبونات منتهية',
                      ),
                      message: context.tr(
                        'Expired offers will appear here for reference.',
                        'ستظهر هنا العروض المنتهية للرجوع إليها.',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
