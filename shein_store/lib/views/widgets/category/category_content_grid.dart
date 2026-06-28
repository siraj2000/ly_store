import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../controllers/cart_controller.dart';
import '../../../controllers/wishlist_controller.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/extensions/localization_extension.dart';
import '../../../core/helpers/cart_action_feedback_helper.dart';
import '../../../core/utils/auth_required_helper.dart';
import '../../../core/widgets/app_bottom_sheet.dart';
import '../../../models/product_model.dart';
import '../product/product_card.dart';
import 'category_grid_item.dart';

class CategoryContentGrid extends StatelessWidget {
  const CategoryContentGrid({
    super.key,
    required this.items,
    required this.onTap,
  });

  final List<CategoryGridItemData> items;
  final ValueChanged<CategoryGridItemData> onTap;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, _) {
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: items.length,
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 136,
            crossAxisSpacing: 8,
            mainAxisSpacing: 12,
            mainAxisExtent: 132,
          ),
          itemBuilder: (context, index) => CategoryGridItem(
            item: items[index],
            onTap: () => onTap(items[index]),
          ),
        );
      },
    );
  }
}

class CategoryProductGrid extends StatelessWidget {
  const CategoryProductGrid({
    super.key,
    required this.products,
    required this.wishlistController,
  });

  final List<ProductModel> products;
  final WishlistController wishlistController;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const spacing = 10.0;
        final crossAxisCount = constraints.maxWidth < 280
            ? 1
            : (constraints.maxWidth > 760 ? 3 : 2);
        final cardWidth =
            (constraints.maxWidth - (spacing * (crossAxisCount - 1))) /
            crossAxisCount;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: products.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: spacing,
            mainAxisSpacing: 12,
            mainAxisExtent: ProductCard.mainAxisExtentForWidth(
              cardWidth,
              compact: true,
            ),
          ),
          itemBuilder: (context, index) {
            final product = products[index];
            return ProductCard(
              product: product,
              compact: true,
              isWishlisted: wishlistController.isWishlisted(product.id),
              onTap: () => Navigator.pushNamed(
                context,
                AppRoutes.productDetails,
                arguments: product.id,
              ),
              onWishlistTap: () => AuthRequiredHelper.guard(
                context,
                onAuthenticated: () {
                  final added = wishlistController.toggleWishlist(product);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        added
                            ? context.tr(
                                'Added to wishlist',
                                'تمت الإضافة إلى المفضلة',
                              )
                            : context.tr(
                                'Removed from wishlist',
                                'تمت الإزالة من المفضلة',
                              ),
                      ),
                    ),
                  );
                },
              ),
              onQuickAddTap: () => AuthRequiredHelper.guard(
                context,
                onAuthenticated: () async {
                  final selection = await AppBottomSheet.showVariantSelector(
                    context,
                    colors: product.colors,
                    sizes: product.sizes,
                    maxQuantity: product.stock,
                  );
                  if (!context.mounted || selection == null) {
                    return;
                  }
                  final result = context.read<CartController>().addToCart(
                    product,
                    selection['color'] as String,
                    selection['size'] as String,
                    selection['quantity'] as int,
                  );
                  CartActionFeedbackHelper.show(context, result);
                },
              ),
            );
          },
        );
      },
    );
  }
}
