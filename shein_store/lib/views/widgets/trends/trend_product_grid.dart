import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../controllers/product_controller.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/app_empty_state.dart';
import '../../../core/widgets/product_image.dart';
import '../../../models/product_model.dart';

class TrendProductGrid extends StatelessWidget {
  const TrendProductGrid({
    super.key,
    required this.products,
    required this.emptyTitle,
    required this.emptyMessage,
    required this.tagLabelForProduct,
    required this.isWishlisted,
    required this.onProductTap,
    required this.onWishlistTap,
    required this.onQuickAddTap,
    required this.onStoreTap,
  });

  final List<ProductModel> products;
  final String emptyTitle;
  final String emptyMessage;
  final String Function(ProductModel product) tagLabelForProduct;
  final bool Function(String productId) isWishlisted;
  final void Function(ProductModel product) onProductTap;
  final void Function(ProductModel product) onWishlistTap;
  final Future<void> Function(ProductModel product) onQuickAddTap;
  final void Function(ProductModel product) onStoreTap;

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) {
      return AppEmptyState(title: emptyTitle, message: emptyMessage);
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 880
            ? 4
            : (constraints.maxWidth > 620 ? 3 : 2);
        final spacing = constraints.maxWidth > 620 ? 14.0 : 12.0;
        final width =
            (constraints.maxWidth - (spacing * (crossAxisCount - 1))) /
            crossAxisCount;
        final height = width / 0.72 + 122;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: products.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: spacing,
            mainAxisSpacing: spacing,
            mainAxisExtent: height,
          ),
          itemBuilder: (context, index) {
            final product = products[index];
            return _TrendProductTile(
              product: product,
              tagLabel: tagLabelForProduct(product),
              wishlisted: isWishlisted(product.id),
              onTap: () => onProductTap(product),
              onWishlistTap: () => onWishlistTap(product),
              onQuickAddTap: () => onQuickAddTap(product),
              onStoreTap: () => onStoreTap(product),
            );
          },
        );
      },
    );
  }
}

class _TrendProductTile extends StatelessWidget {
  const _TrendProductTile({
    required this.product,
    required this.tagLabel,
    required this.wishlisted,
    required this.onTap,
    required this.onWishlistTap,
    required this.onQuickAddTap,
    required this.onStoreTap,
  });

  final ProductModel product;
  final String tagLabel;
  final bool wishlisted;
  final VoidCallback onTap;
  final VoidCallback onWishlistTap;
  final Future<void> Function() onQuickAddTap;
  final VoidCallback onStoreTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final productController = context.watch<ProductController>();
    return Material(
      color: colors.card,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          decoration: BoxDecoration(
            color: colors.card,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: colors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(18),
                        ),
                        child: ProductImage(
                          imageUrl: product.imageUrl ?? '',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    PositionedDirectional(
                      top: 10,
                      start: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: colors.accent.withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          tagLabel,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    PositionedDirectional(
                      top: 10,
                      end: 10,
                      child: _RoundIconButton(
                        icon: wishlisted
                            ? Icons.favorite_rounded
                            : Icons.favorite_border_rounded,
                        color: wishlisted ? colors.accent : colors.primaryText,
                        onTap: onWishlistTap,
                      ),
                    ),
                    PositionedDirectional(
                      bottom: 10,
                      end: 10,
                      child: _RoundIconButton(
                        icon: Icons.shopping_bag_outlined,
                        color: colors.primaryText,
                        onTap: () {
                          onQuickAddTap();
                        },
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.resolvedTitle(Localizations.localeOf(context)),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: colors.primaryText,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: onStoreTap,
                      child: Text(
                        product.sellerName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: colors.secondaryText,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          '\$${product.price.toStringAsFixed(2)}',
                          style: TextStyle(
                            color: colors.price,
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(width: 6),
                        if (product.oldPrice > product.price)
                          Expanded(
                            child: Text(
                              '\$${product.oldPrice.toStringAsFixed(2)}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: colors.mutedText,
                                fontSize: 12,
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          Icons.star_rounded,
                          color: colors.warning,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            '${productController.ratingSummaryForProduct(product.id).averageRating.toStringAsFixed(1)} • ${product.soldCount} sold',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: colors.secondaryText,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  const _RoundIconButton({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.9),
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 40,
          height: 40,
          child: Icon(icon, color: color, size: 20),
        ),
      ),
    );
  }
}
