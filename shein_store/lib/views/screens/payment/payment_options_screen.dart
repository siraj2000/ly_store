import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../controllers/profile_controller.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/extensions/localization_extension.dart';
import '../../../core/widgets/app_empty_state.dart';
import '../../widgets/checkout/payment_method_card.dart';
import '../../widgets/common/app_header.dart';

class PaymentOptionsScreen extends StatelessWidget {
  const PaymentOptionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<ProfileController>().user;
    final methods = user?.paymentMethods ?? [];

    return Scaffold(
      appBar: AppHeader(title: context.tr('Payment Options', 'خيارات الدفع')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, AppRoutes.paymentForm),
        label: Text(context.tr('Add Card', 'إضافة بطاقة')),
        icon: const Icon(Icons.add),
      ),
      body: methods.isEmpty
          ? AppEmptyState(
              title: context.tr(
                'No saved payment methods',
                'لا توجد وسائل دفع محفوظة',
              ),
              message: context.tr(
                'Add a card now to make checkout faster later.',
                'أضف بطاقة الآن لتسريع الدفع لاحقاً.',
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(AppSizes.lg),
              children: [
                ...methods.map(
                  (method) => PaymentMethodCard(
                    method: method,
                    selected: method.isDefault,
                    onTap: () {},
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 6),
                  decoration: BoxDecoration(
                    color: context.appColors.card,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: context.appColors.border),
                  ),
                  child: ListTile(
                    title: Text(
                      context.tr('PayPal placeholder', 'عنصر PayPal تجريبي'),
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    subtitle: Text(
                      context.tr(
                        'Real account linking can be added later.',
                        'يمكن إضافة ربط الحساب الحقيقي لاحقاً.',
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
