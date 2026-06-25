import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/product_image.dart';
import '../../../models/category_model.dart';

class CategoryImageItem extends StatelessWidget {
  const CategoryImageItem({
    super.key,
    required this.category,
    required this.localizedName,
    required this.onTap,
    this.selected = false,
  });

  final CategoryModel category;
  final String localizedName;
  final VoidCallback onTap;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: selected ? colors.primaryText : colors.border,
                  width: selected ? 1.4 : 1,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(17),
                child: ProductImage(
                  imageUrl: category.localImagePath ?? category.imageUrl,
                  radius: 17,
                ),
              ),
            ),
            const SizedBox(height: 6),
            SizedBox(
              width: 72,
              child: Text(
                localizedName,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  height: 1.2,
                  fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                  color: colors.primaryText,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
