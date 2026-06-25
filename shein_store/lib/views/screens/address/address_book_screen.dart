import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../controllers/profile_controller.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/extensions/localization_extension.dart';
import '../../../core/widgets/app_empty_state.dart';
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
            )
          : ListView(
              padding: const EdgeInsets.all(AppSizes.lg),
              children: [
                ...addresses.map(
                  (address) => AddressCard(address: address, onTap: () {}),
                ),
              ],
            ),
    );
  }
}
