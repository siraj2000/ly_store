import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../controllers/profile_controller.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/extensions/localization_extension.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_empty_state.dart';
import '../../../models/payment_method_model.dart';
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
              action: AppButton(
                text: context.tr('Add Card', 'إضافة بطاقة'),
                onPressed: () =>
                    Navigator.pushNamed(context, AppRoutes.paymentForm),
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(AppSizes.lg),
              children: [
                ...methods.map(
                  (method) => PaymentMethodCard(
                    method: method,
                    selected: method.isDefault,
                    onTap: () => _showPaymentActions(context, method),
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
                      'PayPal',
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    subtitle: Text(
                      context.tr(
                        'PayPal connection is not available yet.',
                        'ربط PayPal غير متاح حالياً.',
                      ),
                    ),
                    trailing: Icon(
                      Icons.lock_outline,
                      color: context.appColors.inactiveIcon,
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  void _showPaymentActions(BuildContext context, PaymentMethodModel method) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.check_circle_outline),
              title: Text(context.tr('Set as Default', 'تعيين كافتراضي')),
              enabled: !method.isDefault,
              onTap: () {
                context.read<ProfileController>().setDefaultPaymentMethod(
                  method.id,
                );
                Navigator.pop(sheetContext);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      context.tr(
                        'Default payment method updated',
                        'تم تحديث وسيلة الدفع الافتراضية',
                      ),
                    ),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: Text(context.tr('Edit Card', 'تعديل البطاقة')),
              onTap: () {
                Navigator.pop(sheetContext);
                Navigator.pushNamed(
                  context,
                  AppRoutes.paymentForm,
                  arguments: method.id,
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline),
              title: Text(context.tr('Delete Card', 'حذف البطاقة')),
              onTap: () async {
                Navigator.pop(sheetContext);
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (dialogContext) => AlertDialog(
                    title: Text(context.tr('Delete Card?', 'حذف البطاقة؟')),
                    content: Text(
                      context.tr(
                        'This saved payment method will be removed.',
                        'سيتم حذف وسيلة الدفع المحفوظة.',
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(dialogContext, false),
                        child: Text(context.tr('Cancel', 'إلغاء')),
                      ),
                      FilledButton(
                        onPressed: () => Navigator.pop(dialogContext, true),
                        child: Text(context.tr('Delete', 'حذف')),
                      ),
                    ],
                  ),
                );
                if (confirmed != true || !context.mounted) {
                  return;
                }
                context.read<ProfileController>().deletePaymentMethod(
                  method.id,
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(context.tr('Card deleted', 'تم حذف البطاقة')),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
