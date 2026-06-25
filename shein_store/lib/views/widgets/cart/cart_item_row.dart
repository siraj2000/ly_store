import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/extensions/localization_extension.dart';
import '../../../core/widgets/product_image.dart';
import '../../../models/cart_item_model.dart';
import '../common/price_text.dart';

class CartItemRow extends StatelessWidget {
  const CartItemRow({
    super.key,
    required this.item,
    required this.onSelect,
    required this.onDelete,
    required this.onIncrease,
    required this.onDecrease,
    required this.onSaveForLater,
  });

  final CartItemModel item;
  final ValueChanged<bool> onSelect;
  final VoidCallback onDelete;
  final VoidCallback onIncrease;
  final VoidCallback onDecrease;
  final VoidCallback onSaveForLater;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 18),
            child: Checkbox(
              value: item.isSelected,
              onChanged: (value) => onSelect(value ?? false),
            ),
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: ProductImage(
              imageUrl: item.product.imageUrl,
              imageUrls: item.product.imageUrls,
              height: 108,
              width: 84,
              radius: 12,
            ),
          ),
          const SizedBox(width: AppSizes.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.product.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    height: 1.25,
                  ).copyWith(color: colors.primaryText),
                ),
                const SizedBox(height: 5),
                Text(
                  '${item.selectedColor} / ${item.selectedSize}',
                  style: TextStyle(color: colors.secondaryText, fontSize: 12),
                ),
                const SizedBox(height: 8),
                PriceText(
                  price: item.product.price,
                  oldPrice: item.product.oldPrice,
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: colors.surfaceSoft,
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: colors.border),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _QtyButton(icon: Icons.remove, onTap: onDecrease),
                          Container(
                            width: 34,
                            alignment: Alignment.center,
                            child: Text(
                              '${item.quantity}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                              ).copyWith(color: colors.primaryText),
                            ),
                          ),
                          _QtyButton(icon: Icons.add, onTap: onIncrease),
                        ],
                      ),
                    ),
                    TextButton(
                      onPressed: onSaveForLater,
                      style: TextButton.styleFrom(
                        foregroundColor: colors.secondaryText,
                        visualDensity: VisualDensity.compact,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        textStyle: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      child: Text(context.tr('Save', 'حفظ')),
                    ),
                    TextButton(
                      onPressed: onDelete,
                      style: TextButton.styleFrom(
                        foregroundColor: colors.discount,
                        visualDensity: VisualDensity.compact,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        textStyle: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      child: Text(context.tr('Delete', 'حذف')),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QtyButton extends StatelessWidget {
  const _QtyButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: colors.border),
          color: colors.surface,
        ),
        child: Icon(icon, size: 16, color: colors.icon),
      ),
    );
  }
}
