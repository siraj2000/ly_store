import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../controllers/auth_controller.dart';
import '../../../controllers/cart_controller.dart';
import '../../../controllers/product_controller.dart';
import '../../../controllers/wishlist_controller.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/extensions/localization_extension.dart';
import '../../../core/helpers/cart_action_feedback_helper.dart';
import '../../../core/utils/auth_required_helper.dart';
import '../../../core/widgets/app_bottom_sheet.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_empty_state.dart';
import '../../../models/product_model.dart';
import '../../widgets/common/app_header.dart';
import '../../widgets/product/product_card.dart';

class RecentlyViewedScreen extends StatelessWidget {
  const RecentlyViewedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final productController = context.watch<ProductController>();
    final wishlistController = context.watch<WishlistController>();
    final ids =
        auth.currentUser?.recentlyViewedProductIds ??
        productController.guestRecentlyViewedProductIds;
    final productsById = {
      for (final product in productController.marketplaceProducts)
        product.id: product,
    };
    final products = ids
        .map((id) => productsById[id])
        .whereType<ProductModel>()
        .toList();

    return Scaffold(
      appBar: AppHeader(title: context.tr('Recently Viewed', 'شوهد مؤخراً')),
      body: products.isEmpty
          ? AppEmptyState(
              title: context.tr(
                'No recently viewed products',
                'لا توجد منتجات شوهدت مؤخراً',
              ),
              message: context.tr(
                'Start browsing and your viewed products will appear here.',
                'ابدأ التصفح وستظهر المنتجات التي شاهدتها هنا.',
              ),
              action: AppButton(
                text: context.tr('Start Shopping', 'ابدأ التسوق'),
                onPressed: () => Navigator.pushNamedAndRemoveUntil(
                  context,
                  AppRoutes.main,
                  (route) => false,
                ),
              ),
            )
          : GridView.builder(
              padding: EdgeInsets.fromLTRB(
                AppSizes.lg,
                AppSizes.lg,
                AppSizes.lg,
                MediaQuery.paddingOf(context).bottom + AppSizes.lg,
              ),
              itemCount: products.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: MediaQuery.sizeOf(context).width > 720 ? 3 : 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 12,
                mainAxisExtent: ProductCard.mainAxisExtentForWidth(
                  (MediaQuery.sizeOf(context).width - (AppSizes.lg * 2) - 10) /
                      2,
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
                  onQuickAddTap: () => _quickAdd(context, product),
                );
              },
            ),
    );
  }

  Future<void> _quickAdd(BuildContext context, ProductModel product) async {
    await AuthRequiredHelper.guard(
      context,
      onAuthenticated: () async {
        final selection = await AppBottomSheet.showVariantSelector(
          context,
          colors: product.colors,
          sizes: product.sizes,
          variants: product.variants,
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
    );
  }
}
