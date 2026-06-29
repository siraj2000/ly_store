import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../controllers/profile_controller.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/extensions/localization_extension.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_empty_state.dart';
import '../../../models/address_model.dart';
import '../../widgets/cart/address_card.dart';
import '../../widgets/common/app_header.dart';

class AddressBookScreen extends StatelessWidget {
  const AddressBookScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<ProfileController>().user;
    final addresses = user?.addresses ?? [];

    return Scaffold(
      appBar: AppHeader(title: context.tr('Address Book', 'دفتر العناوين')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, AppRoutes.addressForm),
        label: Text(context.tr('Add Address', 'إضافة عنوان')),
        icon: const Icon(Icons.add),
      ),
      body: addresses.isEmpty
          ? AppEmptyState(
              title: context.tr('No saved addresses', 'لا توجد عناوين محفوظة'),
              message: context.tr(
                'Add your shipping address to speed up checkout.',
                'أضف عنوان الشحن لتسريع عملية الدفع.',
              ),
              action: AppButton(
                text: context.tr('Add Address', 'إضافة عنوان'),
                onPressed: () =>
                    Navigator.pushNamed(context, AppRoutes.addressForm),
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(AppSizes.lg),
              children: [
                ...addresses.map(
                  (address) => AddressCard(
                    address: address,
                    onTap: () => _showAddressActions(context, address),
                  ),
                ),
              ],
            ),
    );
  }

  void _showAddressActions(BuildContext context, AddressModel address) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit_location_alt_outlined),
              title: Text(context.tr('Edit Address', 'تعديل العنوان')),
              onTap: () {
                Navigator.pop(sheetContext);
                Navigator.pushNamed(
                  context,
                  AppRoutes.addressForm,
                  arguments: address.id,
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.check_circle_outline),
              title: Text(context.tr('Set as Default', 'تعيين كافتراضي')),
              enabled: !address.isDefault,
              onTap: () {
                context.read<ProfileController>().setDefaultAddress(address.id);
                Navigator.pop(sheetContext);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      context.tr(
                        'Default address updated',
                        'تم تحديث العنوان الافتراضي',
                      ),
                    ),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline),
              title: Text(context.tr('Delete Address', 'حذف العنوان')),
              onTap: () async {
                Navigator.pop(sheetContext);
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (dialogContext) => AlertDialog(
                    title: Text(context.tr('Delete Address?', 'حذف العنوان؟')),
                    content: Text(
                      context.tr(
                        'This saved address will be removed.',
                        'سيتم حذف هذا العنوان المحفوظ.',
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
                context.read<ProfileController>().deleteAddress(address.id);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      context.tr('Address deleted', 'تم حذف العنوان'),
                    ),
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
