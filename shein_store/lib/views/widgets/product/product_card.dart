import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../controllers/product_controller.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_motion.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/extensions/localization_extension.dart';
import '../../../core/helpers/catalog_localization_helper.dart';
import '../../../core/widgets/animated_pressable.dart';
import '../../../core/widgets/app_animated_switcher.dart';
import '../../../core/widgets/product_image.dart';
import '../../../models/product_model.dart';
import '../../../models/store_model.dart';
import '../common/price_text.dart';
import '../common/rating_stars.dart';
import '../common/store_rating_stars.dart';

class ProductCard extends StatelessWidget {
  const ProductCard({
    super.key,
    required this.product,
    required this.onTap,
    required this.onWishlistTap,
    required this.onQuickAddTap,
    this.compact = false,
    this.showRating = true,
    this.showQuickAdd = true,
    this.isWishlisted = false,
    this.onStoreTap,
  });

  static const double imageAspectRatio = 3 / 4;

  static double mainAxisExtentForWidth(
    double width, {
    bool compact = false,
    bool showRating = true,
  }) {
    final detailHeight = compact
        ? (showRating ? 126.0 : 108.0)
        : (showRating ? 140.0 : 118.0);
    final outerPadding = compact ? 10.0 : 12.0;
    return (width / imageAspectRatio) + detailHeight + outerPadding;
  }

  final ProductModel product;
  final VoidCallback onTap;
  final VoidCallback onWishlistTap;
  final VoidCallback onQuickAddTap;
  final bool compact;
  final bool showRating;
  final bool showQuickAdd;
  final bool isWishlisted;
  final VoidCallback? onStoreTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return LayoutBuilder(
      builder: (context, constraints) {
        final expectedHeight = mainAxisExtentForWidth(
          constraints.maxWidth,
          compact: compact,
          showRating: showRating,
        );
        final useHorizontalLayout =
            constraints.hasBoundedHeight &&
            constraints.maxHeight < (expectedHeight - 50);

        final radius = BorderRadius.circular(compact ? 12 : 14);
        return AnimatedPressable(
          onTap: onTap,
          borderRadius: radius,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: colors.card,
              borderRadius: radius,
              border: Border.all(color: colors.border),
              boxShadow: [
                BoxShadow(
                  color: colors.background.withValues(
                    alpha: context.isDarkMode ? 0.22 : 0.08,
                  ),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: useHorizontalLayout
                  ? _HorizontalProductCard(
                      product: product,
                      compact: compact,
                      showRating: showRating,
                      showQuickAdd: showQuickAdd,
                      isWishlisted: isWishlisted,
                      onWishlistTap: onWishlistTap,
                      onQuickAddTap: onQuickAddTap,
                      onStoreTap: onStoreTap,
                    )
                  : _VerticalProductCard(
                      product: product,
                      compact: compact,
                      showRating: showRating,
                      showQuickAdd: showQuickAdd,
                      isWishlisted: isWishlisted,
                      onWishlistTap: onWishlistTap,
                      onQuickAddTap: onQuickAddTap,
                      onStoreTap: onStoreTap,
                    ),
            ),
          ),
        );
      },
    );
  }
}

class _VerticalProductCard extends StatelessWidget {
  const _VerticalProductCard({
    required this.product,
    required this.compact,
    required this.showRating,
    required this.showQuickAdd,
    required this.isWishlisted,
    required this.onWishlistTap,
    required this.onQuickAddTap,
    required this.onStoreTap,
  });

  final ProductModel product;
  final bool compact;
  final bool showRating;
  final bool showQuickAdd;
  final bool isWishlisted;
  final VoidCallback onWishlistTap;
  final VoidCallback onQuickAddTap;
  final VoidCallback? onStoreTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final imageRadius = compact ? 10.0 : 12.0;
    final localizedTitle = product.resolvedTitle(
      Localizations.localeOf(context),
    );
    final localizedCategory = _localizedCatalogLabel(
      context,
      product.categoryName,
    );
    final store = context.read<ProductController>().storeForProduct(product);

    return Padding(
      padding: EdgeInsets.all(compact ? 5 : 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: ProductCard.imageAspectRatio,
            child: _ProductImageStack(
              product: product,
              compact: compact,
              isWishlisted: isWishlisted,
              showQuickAdd: showQuickAdd,
              onWishlistTap: onWishlistTap,
              onQuickAddTap: onQuickAddTap,
              imageRadius: imageRadius,
            ),
          ),
          SizedBox(height: compact ? 8 : 10),
          Text(
            context.isArabic
                ? localizedCategory
                : localizedCategory.toUpperCase(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ).copyWith(color: colors.secondaryText),
          ),
          const SizedBox(height: 4),
          Text(
            localizedTitle,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: compact ? 13 : 14,
              fontWeight: FontWeight.w600,
              height: 1.25,
              color: colors.primaryText,
            ),
          ),
          const SizedBox(height: 6),
          _StoreIdentityRow(
            product: product,
            store: store,
            compact: compact,
            onTap: onStoreTap,
          ),
          SizedBox(height: compact ? 5 : 6),
          PriceText(price: product.price, oldPrice: product.oldPrice),
          if (showRating) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                RatingStars(
                  rating: product.rating,
                  reviewCount: product.reviewCount,
                ),
                const Spacer(),
                Flexible(
                  child: Text(
                    context.tr(
                      '${product.soldCount} sold',
                      'تم بيع ${product.soldCount}',
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11,
                    ).copyWith(color: colors.secondaryText),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _HorizontalProductCard extends StatelessWidget {
  const _HorizontalProductCard({
    required this.product,
    required this.compact,
    required this.showRating,
    required this.showQuickAdd,
    required this.isWishlisted,
    required this.onWishlistTap,
    required this.onQuickAddTap,
    required this.onStoreTap,
  });

  final ProductModel product;
  final bool compact;
  final bool showRating;
  final bool showQuickAdd;
  final bool isWishlisted;
  final VoidCallback onWishlistTap;
  final VoidCallback onQuickAddTap;
  final VoidCallback? onStoreTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final imageWidth = compact ? 108.0 : 118.0;
    final localizedTitle = product.resolvedTitle(
      Localizations.localeOf(context),
    );
    final localizedCategory = _localizedCatalogLabel(
      context,
      product.categoryName,
    );
    final store = context.read<ProductController>().storeForProduct(product);

    return Padding(
      padding: EdgeInsets.all(compact ? 6 : 8),
      child: Row(
        children: [
          SizedBox(
            width: imageWidth,
            child: AspectRatio(
              aspectRatio: ProductCard.imageAspectRatio,
              child: _ProductImageStack(
                product: product,
                compact: compact,
                isWishlisted: isWishlisted,
                showQuickAdd: showQuickAdd,
                onWishlistTap: onWishlistTap,
                onQuickAddTap: onQuickAddTap,
                imageRadius: 10,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  context.isArabic
                      ? localizedCategory
                      : localizedCategory.toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.4,
                  ).copyWith(color: colors.secondaryText),
                ),
                const SizedBox(height: 4),
                Text(
                  localizedTitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    height: 1.25,
                    color: colors.primaryText,
                  ),
                ),
                const SizedBox(height: 6),
                _StoreIdentityRow(
                  product: product,
                  store: store,
                  compact: true,
                  onTap: onStoreTap,
                ),
                const SizedBox(height: 6),
                PriceText(price: product.price, oldPrice: product.oldPrice),
                if (showRating) ...[
                  const SizedBox(height: 6),
                  RatingStars(
                    rating: product.rating,
                    reviewCount: product.reviewCount,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

String _localizedCatalogLabel(BuildContext context, String value) {
  final categoryValue = localizedCategoryName(context, value);
  if (categoryValue != value) {
    return categoryValue;
  }
  return localizedDepartmentName(context, value);
}

class _StoreIdentityRow extends StatelessWidget {
  const _StoreIdentityRow({
    required this.product,
    required this.store,
    required this.compact,
    required this.onTap,
  });

  final ProductModel product;
  final StoreModel? store;
  final bool compact;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final locale = Localizations.localeOf(context);
    final storeName =
        store?.localizedName(locale) ??
        context.tr('Store unavailable', 'المتجر غير متاح');
    final city = store?.city ?? '';
    final rating = store?.rating ?? 0;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap:
          onTap ??
          () => Navigator.pushNamed(
            context,
            AppRoutes.storefront,
            arguments: store?.id ?? product.storeId,
          ),
      child: Row(
        children: [
          Container(
            width: compact ? 22 : 24,
            height: compact ? 22 : 24,
            decoration: BoxDecoration(
              color: colors.surfaceSoft,
              shape: BoxShape.circle,
              border: Border.all(color: colors.border),
            ),
            child: Icon(
              Icons.storefront_outlined,
              size: compact ? 12 : 13,
              color: colors.icon,
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              city.isEmpty ? storeName : '$storeName  ·  $city',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: compact ? 11 : 12,
                fontWeight: FontWeight.w600,
                color: colors.secondaryText,
              ),
            ),
          ),
          if (store?.isVerified == true) ...[
            const SizedBox(width: 4),
            Icon(Icons.verified_rounded, size: 14, color: colors.info),
          ],
          const SizedBox(width: 6),
          StoreRatingStars(
            rating: rating,
            compact: true,
            reviewCount: null,
            size: 12,
          ),
        ],
      ),
    );
  }
}

class _ProductImageStack extends StatelessWidget {
  const _ProductImageStack({
    required this.product,
    required this.compact,
    required this.isWishlisted,
    required this.showQuickAdd,
    required this.onWishlistTap,
    required this.onQuickAddTap,
    required this.imageRadius,
  });

  final ProductModel product;
  final bool compact;
  final bool isWishlisted;
  final bool showQuickAdd;
  final VoidCallback onWishlistTap;
  final VoidCallback onQuickAddTap;
  final double imageRadius;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final actionSize = compact ? 30.0 : 32.0;
    final actionIconSize = compact ? 16.0 : 17.0;

    return Stack(
      children: [
        Positioned.fill(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(imageRadius),
            child: ProductImage(
              imageUrl: product.imageUrl,
              imageUrls: product.imageUrls,
              radius: imageRadius,
            ),
          ),
        ),
        if (product.discount > 0)
          Positioned(
            top: 8,
            left: 8,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.92, end: 1),
              duration: AppMotion.duration(context, AppMotion.fast),
              curve: AppMotion.standard,
              builder: (context, scale, child) => Transform.scale(
                scale: scale,
                child: Opacity(opacity: scale.clamp(0.0, 1.0), child: child),
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
                decoration: BoxDecoration(
                  color: colors.discount,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '-${product.discount}%',
                  style: TextStyle(
                    color: context.isDarkMode
                        ? colors.background
                        : colors.surface,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        Positioned(
          top: 8,
          right: 8,
          child: _ActionCircleButton(
            size: actionSize,
            iconSize: actionIconSize,
            backgroundColor: colors.surface,
            onPressed: onWishlistTap,
            icon: AppAnimatedSwitcher(
              child: Icon(
                isWishlisted ? Icons.favorite : Icons.favorite_border_outlined,
                key: ValueKey(isWishlisted),
                color: isWishlisted ? colors.accent : colors.icon,
              ),
            ),
          ),
        ),
        if (showQuickAdd)
          Positioned(
            right: 8,
            bottom: 8,
            child: _ActionCircleButton(
              size: actionSize,
              iconSize: actionIconSize,
              backgroundColor: context.isDarkMode
                  ? colors.surfaceSoft
                  : colors.primaryText,
              iconColor: context.isDarkMode
                  ? colors.primaryText
                  : colors.surface,
              onPressed: onQuickAddTap,
              icon: const Icon(Icons.shopping_bag_outlined),
            ),
          ),
      ],
    );
  }
}

class _ActionCircleButton extends StatelessWidget {
  const _ActionCircleButton({
    required this.size,
    required this.iconSize,
    required this.onPressed,
    required this.icon,
    this.backgroundColor = AppColors.lightSurface,
    this.iconColor,
  });

  final double size;
  final double iconSize;
  final VoidCallback onPressed;
  final Widget icon;
  final Color backgroundColor;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return AnimatedPressable(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(999),
      scale: 0.9,
      child: Material(
        color: backgroundColor,
        shape: const CircleBorder(),
        elevation: 0,
        child: Ink(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: backgroundColor,
            shape: BoxShape.circle,
            border:
                backgroundColor == AppColors.lightSurface ||
                    backgroundColor == colors.surface ||
                    backgroundColor == colors.surfaceSoft
                ? Border.all(color: colors.border)
                : null,
            boxShadow: [
              BoxShadow(
                color: colors.background.withValues(
                  alpha: context.isDarkMode ? 0.2 : 0.08,
                ),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: SizedBox(
            width: size,
            height: size,
            child: Center(
              child: IconTheme.merge(
                data: IconThemeData(size: iconSize, color: iconColor),
                child: icon,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
