import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/extensions/localization_extension.dart';
import '../../../models/address_model.dart';

class AddressCard extends StatelessWidget {
  const AddressCard({super.key, required this.address, this.onTap});

  final AddressModel address;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.border),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        leading: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: colors.surfaceSoft,
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.location_on_outlined, size: 20, color: colors.icon),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                address.fullName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                ).copyWith(color: colors.primaryText),
              ),
            ),
            if (address.isDefault)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: colors.discount.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  context.tr('Default', 'افتراضي'),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: colors.discount,
                  ),
                ),
              ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            '${address.streetAddress}, ${address.city}, ${address.region}\n${address.country} ${address.postalCode}\n${address.phone}',
            style: TextStyle(
              height: 1.35,
              color: colors.secondaryText,
              fontSize: 12,
            ),
          ),
        ),
        trailing: Icon(
          Directionality.of(context) == TextDirection.rtl
              ? Icons.chevron_left_rounded
              : Icons.chevron_right_rounded,
          color: colors.inactiveIcon,
        ),
      ),
    );
  }
}
