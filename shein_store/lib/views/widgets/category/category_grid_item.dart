import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/product_image.dart';

class CategoryGridItemData {
  const CategoryGridItemData({
    required this.id,
    required this.label,
    required this.imageUrl,
    this.isViewAll = false,
  });

  final String id;
  final String label;
  final String imageUrl;
  final bool isViewAll;
}

class CategoryGridItem extends StatelessWidget {
  const CategoryGridItem({
    super.key,
    required this.item,
    required this.onTap,
    this.circular = true,
  });

  final CategoryGridItemData item;
  final VoidCallback onTap;
  final bool circular;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final radius = circular ? 999.0 : 20.0;

    return Semantics(
      button: true,
      label: item.label,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 78,
                height: 78,
                decoration: BoxDecoration(
                  color: colors.card,
                  shape: circular ? BoxShape.circle : BoxShape.rectangle,
                  borderRadius: circular ? null : BorderRadius.circular(20),
                  border: Border.all(color: colors.border),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(radius),
                  child: item.isViewAll
                      ? Center(
                          child: Icon(
                            Icons.grid_view_rounded,
                            color: colors.icon,
                            size: 28,
                          ),
                        )
                      : ProductImage(
                          imageUrl: item.imageUrl,
                          radius: radius,
                          fit: BoxFit.cover,
                        ),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: 88,
                child: Text(
                  item.label,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.2,
                    fontWeight: FontWeight.w600,
                    color: colors.primaryText,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
