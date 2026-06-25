import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/helpers/catalog_localization_helper.dart';

class CategoryBubble extends StatelessWidget {
  const CategoryBubble({super.key, required this.label, this.onTap});

  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final icon = _iconForLabel(label);
    final localizedLabel = _localizedLabel(context, label);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: 82,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: colors.card,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: colors.border),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: colors.surfaceSoft,
                shape: BoxShape.circle,
                border: Border.all(color: colors.border),
              ),
              child: Icon(icon, size: 20, color: colors.icon),
            ),
            const SizedBox(height: 6),
            Flexible(
              child: Text(
                localizedLabel,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  height: 1.1,
                  color: colors.primaryText,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _localizedLabel(BuildContext context, String value) {
    final categoryValue = localizedCategoryName(context, value);
    if (categoryValue != value) {
      return categoryValue;
    }
    return localizedDepartmentName(context, value);
  }

  IconData _iconForLabel(String label) {
    final value = label.toLowerCase();
    if (value.contains('dress')) return Icons.checkroom_outlined;
    if (value.contains('shoe')) return Icons.shopping_bag_outlined;
    if (value.contains('beauty')) return Icons.spa_outlined;
    if (value.contains('bag')) return Icons.work_outline;
    if (value.contains('jewelry')) return Icons.diamond_outlined;
    if (value.contains('pet')) return Icons.pets_outlined;
    if (value.contains('school') || value.contains('office')) {
      return Icons.edit_outlined;
    }
    if (value.contains('home')) return Icons.chair_outlined;
    return Icons.grid_view_outlined;
  }
}
