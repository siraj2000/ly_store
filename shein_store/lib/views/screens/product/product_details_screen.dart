import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../controllers/auth_controller.dart';
import '../../../controllers/cart_controller.dart';
import '../../../controllers/product_controller.dart';
import '../../../controllers/wishlist_controller.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/extensions/localization_extension.dart';
import '../../../core/helpers/business_activity_helper.dart';
import '../../../core/helpers/cart_action_feedback_helper.dart';
import '../../../core/utils/auth_required_helper.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/widgets/app_bottom_sheet.dart';
import '../../../core/widgets/app_empty_state.dart';
import '../../../core/widgets/product_image.dart';
import '../../../models/product_model.dart';
import '../../../models/store_model.dart';
import '../../widgets/common/app_header.dart';
import '../../widgets/common/section_header.dart';
import '../../widgets/common/store_rating_stars.dart';
import '../../widgets/product/product_card.dart';

class ProductDetailsScreen extends StatefulWidget {
  const ProductDetailsScreen({super.key, required this.productId});

  final String? productId;

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  int _currentImage = 0;
  String? _selectedColor;
  String? _selectedSize;
  int _quantity = 1;
  bool _trackedView = false;

  @override
  Widget build(BuildContext context) {
    return Consumer3<ProductController, WishlistController, AuthController>(
      builder: (context, productController, wishlistController, authController, _) {
        final colors = context.appColors;
        final product = productController.productById(widget.productId);
        if (product == null) {
          return Scaffold(
            body: AppEmptyState(
              title: context.tr(
                'Product unavailable',
                'Ã˜Â§Ã™â€žÃ™â€¦Ã™â€ Ã˜ÂªÃ˜Â¬ Ã˜ÂºÃ™Å Ã˜Â± Ã™â€¦Ã˜ÂªÃ™Ë†Ã™ÂÃ˜Â±',
              ),
              message: context.tr(
                'The item could not be found.',
                'تعذر العثور على هذا المنتج.',
              ),
            ),
          );
        }

        if (!productController.isProductPublic(product)) {
          return Scaffold(
            body: AppEmptyState(
              title: context.tr('Product unavailable', 'المنتج غير متوفر'),
              message: context.tr(
                'This item is not available for customers right now.',
                'هذا المنتج غير متاح للعملاء حالياً.',
              ),
            ),
          );
        }

        if (!_trackedView) {
          _trackedView = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) {
              return;
            }
            context.read<ProductController>().trackProductView(product.id);
          });
        }

        if (_selectedColor != null &&
            !product.colors.contains(_selectedColor)) {
          _selectedColor = null;
        }
        if (_selectedSize != null && !product.sizes.contains(_selectedSize)) {
          _selectedSize = null;
        }
        if (_quantity > product.stock) {
          _quantity = product.stock < 1 ? 1 : product.stock;
        }

        final locale = Localizations.localeOf(context);
        final reviews = productController.reviewsForProduct(product.id);
        final related = productController.relatedProducts(product);
        final store = productController.storeForProduct(product);
        // ignore: unused_local_variable
        final localizedStoreName =
            store?.localizedName(locale) ??
            context.tr(
              'Store unavailable',
              'Ã˜Â§Ã™â€žÃ™â€¦Ã˜ÂªÃ˜Â¬Ã˜Â± Ã˜ÂºÃ™Å Ã˜Â± Ã™â€¦Ã˜ÂªÃ˜Â§Ã˜Â­',
            );
        final localizedTitle = product.resolvedTitle(locale);
        final localizedDescription = product.resolvedDescription(locale);
        final localizedMaterial = product.resolvedMaterial(locale);
        final localizedComposition = product.resolvedComposition(locale);
        final localizedCareInstructions = product.resolvedCareInstructions(
          locale,
        );
        final gallery = product.imageUrls.isNotEmpty
            ? product.imageUrls
            : [
                if (product.imageUrl != null && product.imageUrl!.isNotEmpty)
                  product.imageUrl!,
              ];
        final highlightLabels = [
          if (product.isFlashSale)
            context.tr('Flash Sale', 'Ã˜ÂªÃ˜Â®Ã™ÂÃ™Å Ã˜Â¶ Ã˜Â³Ã˜Â±Ã™Å Ã˜Â¹'),
          if (product.isHot)
            context.tr('Hot pick', 'Ã˜Â§Ã˜Â®Ã˜ÂªÃ™Å Ã˜Â§Ã˜Â± Ã˜Â±Ã˜Â§Ã˜Â¦Ã˜Â¬'),
          if (product.isNew)
            context.tr('New in', 'Ã™Ë†Ã˜ÂµÃ™â€ž Ã˜Â­Ã˜Â¯Ã™Å Ã˜Â«Ã˜Â§Ã™â€¹'),
          if (product.isReturnable)
            context.tr(
              '30-day return',
              'Ã˜Â¥Ã˜Â±Ã˜Â¬Ã˜Â§Ã˜Â¹ Ã˜Â®Ã™â€žÃ˜Â§Ã™â€ž 30 Ã™Å Ã™Ë†Ã™â€¦Ã˜Â§Ã™â€¹',
            ),
        ];

        return Scaffold(
          appBar: AppHeader(
            title: product.categoryName,
            leading: BackButton(onPressed: () => Navigator.pop(context)),
            actions: [
              IconButton(
                onPressed: () => _showShareMessage(context),
                icon: const Icon(Icons.share_outlined),
              ),
            ],
          ),
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              color: colors.surface,
              border: Border(top: BorderSide(color: colors.border)),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(26),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 22,
                  offset: const Offset(0, -10),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              minimum: const EdgeInsets.fromLTRB(12, 12, 12, 12),
              child: Row(
                children: [
                  _BottomActionIcon(
                    icon: Icons.support_agent_outlined,
                    onTap: () =>
                        Navigator.pushNamed(context, AppRoutes.liveChat),
                  ),
                  const SizedBox(width: 8),
                  _BottomActionIcon(
                    icon: wishlistController.isWishlisted(product.id)
                        ? Icons.favorite
                        : Icons.favorite_border,
                    onTap: () => AuthRequiredHelper.guard(
                      context,
                      onAuthenticated: () {
                        final added = wishlistController.toggleWishlist(
                          product,
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              added
                                  ? context.tr(
                                      'Added to wishlist',
                                      'Ã˜ÂªÃ™â€¦Ã˜Âª Ã˜Â§Ã™â€žÃ˜Â¥Ã˜Â¶Ã˜Â§Ã™ÂÃ˜Â© Ã˜Â¥Ã™â€žÃ™â€° Ã˜Â§Ã™â€žÃ™â€¦Ã™ÂÃ˜Â¶Ã™â€žÃ˜Â©',
                                    )
                                  : context.tr(
                                      'Removed from wishlist',
                                      'Ã˜ÂªÃ™â€¦Ã˜Âª Ã˜Â§Ã™â€žÃ˜Â¥Ã˜Â²Ã˜Â§Ã™â€žÃ˜Â© Ã™â€¦Ã™â€  Ã˜Â§Ã™â€žÃ™â€¦Ã™ÂÃ˜Â¶Ã™â€žÃ˜Â©',
                                    ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _addToBag(context, product),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(50),
                        side: BorderSide(color: colors.border),
                        backgroundColor: colors.surface,
                      ),
                      child: Text(
                        context.tr(
                          'Add to Bag',
                          'Ã˜Â£Ã˜Â¶Ã™Â Ã˜Â¥Ã™â€žÃ™â€° Ã˜Â§Ã™â€žÃ˜Â³Ã™â€žÃ˜Â©',
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: FilledButton(
                      onPressed: () => _buyNow(context, product),
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(50),
                      ),
                      child: Text(
                        context.tr(
                          'Buy Now',
                          'Ã˜Â§Ã˜Â´Ã˜ÂªÃ˜Â± Ã˜Â§Ã™â€žÃ˜Â¢Ã™â€ ',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
            children: [
              _HeroGalleryCard(
                gallery: gallery,
                currentImage: _currentImage,
                onPageChanged: (value) => setState(() => _currentImage = value),
                topLabel: context.tr(
                  'Editor\'s Pick',
                  'Ã˜Â§Ã˜Â®Ã˜ÂªÃ™Å Ã˜Â§Ã˜Â± Ã˜Â§Ã™â€žÃ™â€¦Ã˜Â­Ã˜Â±Ã˜Â±',
                ),
                discountLabel: context.tr(
                  '${product.discount}% off',
                  'Ã˜Â®Ã˜ÂµÃ™â€¦ ${product.discount}%',
                ),
                metrics: [
                  _HeroMetricData(
                    label: context.tr(
                      'Sold',
                      'Ã˜ÂªÃ™â€¦ Ã˜Â§Ã™â€žÃ˜Â¨Ã™Å Ã˜Â¹',
                    ),
                    value: '${product.soldCount}',
                    icon: Icons.local_fire_department_outlined,
                  ),
                  _HeroMetricData(
                    label: context.tr(
                      'Stock',
                      'Ã˜Â§Ã™â€žÃ™â€¦Ã˜Â®Ã˜Â²Ã™Ë†Ã™â€ ',
                    ),
                    value: '${product.stock}',
                    icon: Icons.inventory_2_outlined,
                  ),
                  _HeroMetricData(
                    label: context.tr(
                      'Views',
                      'Ã˜Â§Ã™â€žÃ™â€¦Ã˜Â´Ã˜Â§Ã™â€¡Ã˜Â¯Ã˜Â§Ã˜Âª',
                    ),
                    value: '${product.views}',
                    icon: Icons.visibility_outlined,
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: colors.card,
                  borderRadius: BorderRadius.circular(26),
                  border: Border.all(color: colors.border),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      colors.card,
                      colors.surfaceSoft.withValues(alpha: 0.82),
                    ],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 7,
                          ),
                          decoration: BoxDecoration(
                            color: colors.surface,
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(color: colors.border),
                          ),
                          child: Text(
                            product.department.toUpperCase(),
                            style: TextStyle(
                              color: colors.secondaryText,
                              fontWeight: FontWeight.w800,
                              fontSize: 11,
                              letterSpacing: 0.6,
                            ),
                          ),
                        ),
                        const Spacer(),
                        _RatingBadge(
                          rating: product.rating,
                          reviewCount: product.reviewCount,
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Text(
                      localizedTitle,
                      style: TextStyle(
                        fontSize: 29,
                        fontWeight: FontWeight.w900,
                        color: colors.primaryText,
                        height: 1.08,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '${context.tr('Sold by', 'Ã™Å Ã˜Â¨Ã˜Â§Ã˜Â¹ Ã˜Â¨Ã™Ë†Ã˜Â§Ã˜Â³Ã˜Â·Ã˜Â©')} ${product.sellerName}',
                      style: TextStyle(
                        color: colors.secondaryText,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: _PriceHero(
                            price: product.price,
                            oldPrice: product.oldPrice > product.price
                                ? product.oldPrice
                                : null,
                            discount: product.discount,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: colors.surface,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: colors.border),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                context.tr(
                                  'Store SKU',
                                  'Ã˜Â±Ã™â€¦Ã˜Â² Ã˜Â§Ã™â€žÃ™â€¦Ã™â€ Ã˜ÂªÃ˜Â¬',
                                ),
                                style: TextStyle(
                                  color: colors.secondaryText,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                product.sku,
                                style: TextStyle(
                                  color: colors.primaryText,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: highlightLabels
                          .map((label) => _BadgePill(label: label))
                          .toList(),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      localizedDescription,
                      style: TextStyle(
                        color: colors.secondaryText,
                        fontSize: 14,
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 18),
                    _InfoStrip(
                      items: [
                        _InfoStripItem(
                          context.tr(
                            'Secure pay',
                            'Ã˜Â¯Ã™ÂÃ˜Â¹ Ã˜Â¢Ã™â€¦Ã™â€ ',
                          ),
                          context.tr(
                            'Protected checkout',
                            'Ã˜Â¥Ã˜ÂªÃ™â€¦Ã˜Â§Ã™â€¦ Ã˜Â´Ã˜Â±Ã˜Â§Ã˜Â¡ Ã™â€¦Ã˜Â­Ã™â€¦Ã™Å ',
                          ),
                          Icons.lock_outline_rounded,
                        ),
                        _InfoStripItem(
                          context.tr(
                            'Fast delivery',
                            'Ã˜ÂªÃ™Ë†Ã˜ÂµÃ™Å Ã™â€ž Ã˜Â³Ã˜Â±Ã™Å Ã˜Â¹',
                          ),
                          context.tr(
                            'Express options',
                            'Ã˜Â®Ã™Å Ã˜Â§Ã˜Â±Ã˜Â§Ã˜Âª Ã˜Â³Ã˜Â±Ã™Å Ã˜Â¹Ã˜Â©',
                          ),
                          Icons.local_shipping_outlined,
                        ),
                        _InfoStripItem(
                          context.tr(
                            'Free return',
                            'Ã˜Â¥Ã˜Â±Ã˜Â¬Ã˜Â§Ã˜Â¹ Ã™â€¦Ã˜Â¬Ã˜Â§Ã™â€ Ã™Å ',
                          ),
                          context.tr(
                            'Easy 30-day return',
                            'Ã˜Â¥Ã˜Â±Ã˜Â¬Ã˜Â§Ã˜Â¹ Ã˜Â³Ã™â€¡Ã™â€ž Ã˜Â®Ã™â€žÃ˜Â§Ã™â€ž 30 Ã™Å Ã™Ë†Ã™â€¦Ã˜Â§Ã™â€¹',
                          ),
                          Icons.assignment_return_outlined,
                        ),
                      ],
                    ),
                    if (store != null) ...[
                      const SizedBox(height: 18),
                      _StoreShowcaseCard(store: store),
                    ],
                  ],
                ),
              ),
              _DetailPanel(
                title: context.tr(
                  'Offer highlights',
                  'Ã˜Â£Ã˜Â¨Ã˜Â±Ã˜Â² Ã˜Â§Ã™â€žÃ˜Â¹Ã˜Â±Ã™Ë†Ã˜Â¶',
                ),
                subtitle: context.tr(
                  'The best reasons to shop this item right now.',
                  'Ã˜Â£Ã™ÂÃ˜Â¶Ã™â€ž Ã˜Â£Ã˜Â³Ã˜Â¨Ã˜Â§Ã˜Â¨ Ã˜Â´Ã˜Â±Ã˜Â§Ã˜Â¡ Ã™â€¡Ã˜Â°Ã˜Â§ Ã˜Â§Ã™â€žÃ™â€¦Ã™â€ Ã˜ÂªÃ˜Â¬ Ã˜Â§Ã™â€žÃ˜Â¢Ã™â€ .',
                ),
                icon: Icons.auto_awesome_rounded,
                child: Column(
                  children: [
                    _MiniInfoTile(
                      icon: Icons.sell_outlined,
                      title: context.tr(
                        'Coupon stack',
                        'Ã™â€šÃ˜Â³Ã˜Â§Ã˜Â¦Ã™â€¦ Ã™â€¦Ã˜ÂªÃ˜Â§Ã˜Â­Ã˜Â©',
                      ),
                      subtitle: context.tr(
                        'Browse welcome and seasonal coupon offers before checkout.',
                        'Ã˜ÂªÃ˜ÂµÃ™ÂÃ˜Â­ Ã™â€šÃ˜Â³Ã˜Â§Ã˜Â¦Ã™â€¦ Ã˜Â§Ã™â€žÃ˜ÂªÃ˜Â±Ã˜Â­Ã™Å Ã˜Â¨ Ã™Ë†Ã˜Â§Ã™â€žÃ˜Â¹Ã˜Â±Ã™Ë†Ã˜Â¶ Ã˜Â§Ã™â€žÃ™â€¦Ã™Ë†Ã˜Â³Ã™â€¦Ã™Å Ã˜Â© Ã™â€šÃ˜Â¨Ã™â€ž Ã˜Â¥Ã˜ÂªÃ™â€¦Ã˜Â§Ã™â€¦ Ã˜Â§Ã™â€žÃ˜Â·Ã™â€žÃ˜Â¨.',
                      ),
                    ),
                    _MiniInfoTile(
                      icon: Icons.stars_outlined,
                      title: context.tr(
                        'Reward points',
                        'Ã™â€ Ã™â€šÃ˜Â§Ã˜Â· Ã˜Â§Ã™â€žÃ™â€¦Ã™Æ’Ã˜Â§Ã™ÂÃ˜Â¢Ã˜Âª',
                      ),
                      subtitle: context.tr(
                        'Earn points on every successful purchase from this listing.',
                        'Ã˜Â§Ã™Æ’Ã˜Â³Ã˜Â¨ Ã™â€ Ã™â€šÃ˜Â§Ã˜Â·Ã˜Â§Ã™â€¹ Ã™â€¦Ã˜Â¹ Ã™Æ’Ã™â€ž Ã˜Â¹Ã™â€¦Ã™â€žÃ™Å Ã˜Â© Ã˜Â´Ã˜Â±Ã˜Â§Ã˜Â¡ Ã™â€¦Ã™Æ’Ã˜ÂªÃ™â€¦Ã™â€žÃ˜Â© Ã™â€¦Ã™â€  Ã™â€¡Ã˜Â°Ã˜Â§ Ã˜Â§Ã™â€žÃ™â€¦Ã™â€ Ã˜ÂªÃ˜Â¬.',
                      ),
                    ),
                    _MiniInfoTile(
                      icon: Icons.timer_outlined,
                      title: context.tr(
                        'Sale countdown',
                        'Ã˜Â§Ã™â€žÃ˜Â¹Ã˜Â¯ Ã˜Â§Ã™â€žÃ˜ÂªÃ™â€ Ã˜Â§Ã˜Â²Ã™â€žÃ™Å ',
                      ),
                      subtitle: context.tr(
                        'Flash event pricing is still active for a limited time.',
                        'Ã˜Â³Ã˜Â¹Ã˜Â± Ã˜Â§Ã™â€žÃ˜Â¹Ã˜Â±Ã˜Â¶ Ã˜Â§Ã™â€žÃ˜Â³Ã˜Â±Ã™Å Ã˜Â¹ Ã™â€¦Ã˜Â§ Ã˜Â²Ã˜Â§Ã™â€ž Ã™ÂÃ˜Â¹Ã˜Â§Ã™â€žÃ˜Â§Ã™â€¹ Ã™â€žÃ™ÂÃ˜ÂªÃ˜Â±Ã˜Â© Ã™â€¦Ã˜Â­Ã˜Â¯Ã™Ë†Ã˜Â¯Ã˜Â©.',
                      ),
                    ),
                  ],
                ),
              ),
              _DetailPanel(
                title: context.tr(
                  'Choose your options',
                  'Ã˜Â§Ã˜Â®Ã˜ÂªÃ˜Â± Ã˜Â®Ã™Å Ã˜Â§Ã˜Â±Ã˜Â§Ã˜ÂªÃ™Æ’',
                ),
                subtitle: context.tr(
                  'Pick the right color, size, and quantity before adding to bag.',
                  'Ã˜Â§Ã˜Â®Ã˜ÂªÃ˜Â± Ã˜Â§Ã™â€žÃ™â€žÃ™Ë†Ã™â€  Ã™Ë†Ã˜Â§Ã™â€žÃ™â€¦Ã™â€šÃ˜Â§Ã˜Â³ Ã™Ë†Ã˜Â§Ã™â€žÃ™Æ’Ã™â€¦Ã™Å Ã˜Â© Ã˜Â§Ã™â€žÃ™â€¦Ã™â€ Ã˜Â§Ã˜Â³Ã˜Â¨Ã˜Â© Ã™â€šÃ˜Â¨Ã™â€ž Ã˜Â§Ã™â€žÃ˜Â¥Ã˜Â¶Ã˜Â§Ã™ÂÃ˜Â© Ã˜Â¥Ã™â€žÃ™â€° Ã˜Â§Ã™â€žÃ˜Â³Ã™â€žÃ˜Â©.',
                ),
                icon: Icons.tune_rounded,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _PanelLabel(
                      title: context.tr('Color', 'Ã˜Â§Ã™â€žÃ™â€žÃ™Ë†Ã™â€ '),
                      subtitle: context.tr(
                        'Available shades',
                        'Ã˜Â§Ã™â€žÃ˜Â£Ã™â€žÃ™Ë†Ã˜Â§Ã™â€  Ã˜Â§Ã™â€žÃ™â€¦Ã˜ÂªÃ˜Â§Ã˜Â­Ã˜Â©',
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: product.colors.isEmpty
                          ? [
                              Chip(
                                label: Text(
                                  context.tr(
                                    'No color selection needed',
                                    'لا يلزم اختيار لون',
                                  ),
                                ),
                              ),
                            ]
                          : product.colors
                                .map(
                                  (color) => ChoiceChip(
                                    label: Text(color),
                                    selected: _selectedColor == color,
                                    onSelected: (_) =>
                                        setState(() => _selectedColor = color),
                                  ),
                                )
                                .toList(),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Expanded(
                          child: _PanelLabel(
                            title: context.tr('Size', 'المقاس'),
                            subtitle: context.tr(
                              'Find your best fit',
                              'اعثر على المقاس الأنسب',
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () =>
                              AppBottomSheet.showSizeGuide(context),
                          child: Text(
                            context.tr('Size Guide', 'دليل المقاسات'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: product.sizes.isEmpty
                          ? [
                              Chip(
                                label: Text(
                                  context.tr(
                                    'No size selection needed',
                                    'لا يلزم اختيار مقاس',
                                  ),
                                ),
                              ),
                            ]
                          : product.sizes
                                .map(
                                  (size) => ChoiceChip(
                                    label: Text(size),
                                    selected: _selectedSize == size,
                                    onSelected: (_) =>
                                        setState(() => _selectedSize = size),
                                  ),
                                )
                                .toList(),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Expanded(
                          child: _PanelLabel(
                            title: context.tr(
                              'Quantity',
                              'Ã˜Â§Ã™â€žÃ™Æ’Ã™â€¦Ã™Å Ã˜Â©',
                            ),
                            subtitle: context.tr(
                              '${product.stock} pieces ready to ship',
                              '${product.stock} Ã™â€šÃ˜Â·Ã˜Â¹ Ã˜Â¬Ã˜Â§Ã™â€¡Ã˜Â²Ã˜Â© Ã™â€žÃ™â€žÃ˜Â´Ã˜Â­Ã™â€ ',
                            ),
                          ),
                        ),
                        _QtyControl(
                          quantity: _quantity,
                          onDecrease: _quantity == 1
                              ? null
                              : () => setState(() => _quantity--),
                          onIncrease: _quantity >= product.stock
                              ? null
                              : () => setState(() => _quantity++),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              _DetailPanel(
                title: context.tr(
                  'Shipping and return',
                  'Ã˜Â§Ã™â€žÃ˜Â´Ã˜Â­Ã™â€  Ã™Ë†Ã˜Â§Ã™â€žÃ˜Â¥Ã˜Â±Ã˜Â¬Ã˜Â§Ã˜Â¹',
                ),
                subtitle: context.tr(
                  'Helpful delivery details before you place the order.',
                  'Ã˜ÂªÃ™ÂÃ˜Â§Ã˜ÂµÃ™Å Ã™â€ž Ã™â€¦Ã™ÂÃ™Å Ã˜Â¯Ã˜Â© Ã˜Â¹Ã™â€  Ã˜Â§Ã™â€žÃ˜ÂªÃ™Ë†Ã˜ÂµÃ™Å Ã™â€ž Ã™â€šÃ˜Â¨Ã™â€ž Ã˜ÂªÃ™â€ Ã™ÂÃ™Å Ã˜Â° Ã˜Â§Ã™â€žÃ˜Â·Ã™â€žÃ˜Â¨.',
                ),
                icon: Icons.local_shipping_outlined,
                child: Column(
                  children: [
                    _MiniInfoTile(
                      icon: Icons.delivery_dining_outlined,
                      title: context.tr(
                        'Shipping method',
                        'Ã˜Â·Ã˜Â±Ã™Å Ã™â€šÃ˜Â© Ã˜Â§Ã™â€žÃ˜Â´Ã˜Â­Ã™â€ ',
                      ),
                      subtitle: context.tr(
                        'Standard and express delivery options are available.',
                        'Ã˜Â®Ã™Å Ã˜Â§Ã˜Â±Ã˜Â§Ã˜Âª Ã˜Â§Ã™â€žÃ˜Â´Ã˜Â­Ã™â€  Ã˜Â§Ã™â€žÃ˜Â¹Ã˜Â§Ã˜Â¯Ã™Å  Ã™Ë†Ã˜Â§Ã™â€žÃ˜Â³Ã˜Â±Ã™Å Ã˜Â¹ Ã™â€¦Ã˜ÂªÃ˜Â§Ã˜Â­Ã˜Â©.',
                      ),
                    ),
                    _MiniInfoTile(
                      icon: Icons.schedule_outlined,
                      title: context.tr(
                        'Estimated delivery',
                        'Ã˜Â§Ã™â€žÃ˜ÂªÃ™Ë†Ã˜ÂµÃ™Å Ã™â€ž Ã˜Â§Ã™â€žÃ™â€¦Ã˜ÂªÃ™Ë†Ã™â€šÃ˜Â¹',
                      ),
                      subtitle: context.tr(
                        'Expected arrival within 3 to 7 business days.',
                        'Ã˜Â§Ã™â€žÃ™Ë†Ã˜ÂµÃ™Ë†Ã™â€ž Ã˜Â§Ã™â€žÃ™â€¦Ã˜ÂªÃ™Ë†Ã™â€šÃ˜Â¹ Ã˜Â®Ã™â€žÃ˜Â§Ã™â€ž 3 Ã˜Â¥Ã™â€žÃ™â€° 7 Ã˜Â£Ã™Å Ã˜Â§Ã™â€¦ Ã˜Â¹Ã™â€¦Ã™â€ž.',
                      ),
                    ),
                    _MiniInfoTile(
                      icon: Icons.assignment_return_outlined,
                      title: context.tr(
                        'Return policy',
                        'Ã˜Â³Ã™Å Ã˜Â§Ã˜Â³Ã˜Â© Ã˜Â§Ã™â€žÃ˜Â¥Ã˜Â±Ã˜Â¬Ã˜Â§Ã˜Â¹',
                      ),
                      subtitle: context.tr(
                        'Eligible items can be returned within 30 days.',
                        'Ã™Å Ã™â€¦Ã™Æ’Ã™â€  Ã˜Â¥Ã˜Â±Ã˜Â¬Ã˜Â§Ã˜Â¹ Ã˜Â§Ã™â€žÃ™â€¦Ã™â€ Ã˜ÂªÃ˜Â¬Ã˜Â§Ã˜Âª Ã˜Â§Ã™â€žÃ™â€¦Ã˜Â¤Ã™â€¡Ã™â€žÃ˜Â© Ã˜Â®Ã™â€žÃ˜Â§Ã™â€ž 30 Ã™Å Ã™Ë†Ã™â€¦Ã˜Â§Ã™â€¹.',
                      ),
                    ),
                  ],
                ),
              ),
              _DetailPanel(
                title: context.tr(
                  'Product details',
                  'Ã˜ÂªÃ™ÂÃ˜Â§Ã˜ÂµÃ™Å Ã™â€ž Ã˜Â§Ã™â€žÃ™â€¦Ã™â€ Ã˜ÂªÃ˜Â¬',
                ),
                subtitle: context.tr(
                  'Materials, care, and catalog information in one place.',
                  'Ã˜Â§Ã™â€žÃ˜Â®Ã˜Â§Ã™â€¦Ã˜Â§Ã˜Âª Ã™Ë†Ã˜Â§Ã™â€žÃ˜Â¹Ã™â€ Ã˜Â§Ã™Å Ã˜Â© Ã™Ë†Ã™â€¦Ã˜Â¹Ã™â€žÃ™Ë†Ã™â€¦Ã˜Â§Ã˜Âª Ã˜Â§Ã™â€žÃ™Æ’Ã˜ÂªÃ˜Â§Ã™â€žÃ™Ë†Ã˜Â¬ Ã™ÂÃ™Å  Ã™â€¦Ã™Æ’Ã˜Â§Ã™â€  Ã™Ë†Ã˜Â§Ã˜Â­Ã˜Â¯.',
                ),
                icon: Icons.inventory_2_outlined,
                child: Column(
                  children: [
                    _MiniInfoTile(
                      icon: Icons.description_outlined,
                      title: context.tr('Description', 'Ã˜Â§Ã™â€žÃ™Ë†Ã˜ÂµÃ™Â'),
                      subtitle: localizedDescription,
                    ),
                    _MiniInfoTile(
                      icon: Icons.checkroom_outlined,
                      title: context.tr(
                        'Material',
                        'Ã˜Â§Ã™â€žÃ˜Â®Ã˜Â§Ã™â€¦Ã˜Â©',
                      ),
                      subtitle: '$localizedMaterial\n$localizedComposition',
                    ),
                    _MiniInfoTile(
                      icon: Icons.clean_hands_outlined,
                      title: context.tr(
                        'Care instructions',
                        'Ã˜ÂªÃ˜Â¹Ã™â€žÃ™Å Ã™â€¦Ã˜Â§Ã˜Âª Ã˜Â§Ã™â€žÃ˜Â¹Ã™â€ Ã˜Â§Ã™Å Ã˜Â©',
                      ),
                      subtitle: localizedCareInstructions,
                    ),
                    _MiniInfoTile(
                      icon: Icons.qr_code_rounded,
                      title: context.tr(
                        'SKU / Category / Season',
                        'Ã˜Â§Ã™â€žÃ˜Â±Ã™â€¦Ã˜Â² / Ã˜Â§Ã™â€žÃ™ÂÃ˜Â¦Ã˜Â© / Ã˜Â§Ã™â€žÃ™â€¦Ã™Ë†Ã˜Â³Ã™â€¦',
                      ),
                      subtitle:
                          '${product.sku}\n${product.categoryName}\n${context.tr('All-season', 'Ã™â€¦Ã™â€ Ã˜Â§Ã˜Â³Ã˜Â¨ Ã™â€žÃ™Æ’Ã™â€ž Ã˜Â§Ã™â€žÃ™â€¦Ã™Ë†Ã˜Â§Ã˜Â³Ã™â€¦')}',
                    ),
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.only(top: 12),
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: colors.card,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: colors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                context.tr(
                                  'Reviews',
                                  'Ã˜Â§Ã™â€žÃ˜ÂªÃ™â€šÃ™Å Ã™Å Ã™â€¦Ã˜Â§Ã˜Âª',
                                ),
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w900,
                                  color: colors.primaryText,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                context.tr(
                                  'What shoppers are saying about the fit, quality, and overall value.',
                                  'Ã™â€¦Ã˜Â§Ã˜Â°Ã˜Â§ Ã™Å Ã™â€šÃ™Ë†Ã™â€ž Ã˜Â§Ã™â€žÃ™â€¦Ã˜ÂªÃ˜Â³Ã™Ë†Ã™â€šÃ™Ë†Ã™â€  Ã˜Â¹Ã™â€  Ã˜Â§Ã™â€žÃ™â€¦Ã™â€šÃ˜Â§Ã˜Â³ Ã™Ë†Ã˜Â§Ã™â€žÃ˜Â¬Ã™Ë†Ã˜Â¯Ã˜Â© Ã™Ë†Ã˜Â§Ã™â€žÃ™â€šÃ™Å Ã™â€¦Ã˜Â© Ã˜Â§Ã™â€žÃ˜Â¹Ã˜Â§Ã™â€¦Ã˜Â©.',
                                ),
                                style: TextStyle(
                                  color: colors.secondaryText,
                                  height: 1.45,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        _RatingBadge(
                          rating: product.rating,
                          reviewCount: product.reviewCount,
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        Chip(
                          label: Text(
                            context.tr(
                              'With photos',
                              'Ã™â€¦Ã˜Â¹ Ã˜Â§Ã™â€žÃ˜ÂµÃ™Ë†Ã˜Â±',
                            ),
                          ),
                        ),
                        Chip(
                          label: Text(
                            context.tr('Size', 'Ã˜Â§Ã™â€žÃ™â€¦Ã™â€šÃ˜Â§Ã˜Â³'),
                          ),
                        ),
                        Chip(
                          label: Text(
                            context.tr(
                              'Rating',
                              'Ã˜Â§Ã™â€žÃ˜ÂªÃ™â€šÃ™Å Ã™Å Ã™â€¦',
                            ),
                          ),
                        ),
                        Chip(
                          label: Text(
                            context.tr(
                              'Most recent',
                              'Ã˜Â§Ã™â€žÃ˜Â£Ã˜Â­Ã˜Â¯Ã˜Â«',
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (reviews.isEmpty)
                      _MiniInfoTile(
                        icon: Icons.rate_review_outlined,
                        title: context.tr(
                          'No reviews yet',
                          'Ã™â€žÃ˜Â§ Ã˜ÂªÃ™Ë†Ã˜Â¬Ã˜Â¯ Ã˜ÂªÃ™â€šÃ™Å Ã™Å Ã™â€¦Ã˜Â§Ã˜Âª Ã˜Â¨Ã˜Â¹Ã˜Â¯',
                        ),
                        subtitle: context.tr(
                          'Be the first shopper to share an opinion once the order is delivered.',
                          'Ã™Æ’Ã™â€  Ã˜Â£Ã™Ë†Ã™â€ž Ã™â€¦Ã™â€  Ã™Å Ã˜Â´Ã˜Â§Ã˜Â±Ã™Æ’ Ã˜Â±Ã˜Â£Ã™Å Ã™â€¡ Ã˜Â¨Ã˜Â¹Ã˜Â¯ Ã˜Â§Ã˜Â³Ã˜ÂªÃ™â€žÃ˜Â§Ã™â€¦ Ã˜Â§Ã™â€žÃ˜Â·Ã™â€žÃ˜Â¨.',
                        ),
                      )
                    else
                      ...reviews
                          .take(3)
                          .map(
                            (review) => _ReviewTile(
                              author: review.author,
                              comment: review.comment,
                              rating: review.rating,
                            ),
                          ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: AlignmentDirectional.centerEnd,
                      child: TextButton(
                        onPressed: () => _reviewAction(context, authController),
                        child: Text(
                          context.tr(
                            'Write Review',
                            'Ã˜Â§Ã™Æ’Ã˜ÂªÃ˜Â¨ Ã˜ÂªÃ™â€šÃ™Å Ã™Å Ã™â€¦Ã˜Â§Ã™â€¹',
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              SectionHeader(
                title: context.tr(
                  'Recommendations',
                  'Ã™â€¦Ã™â€ Ã˜ÂªÃ˜Â¬Ã˜Â§Ã˜Âª Ã™â€¦Ã™â€šÃ˜ÂªÃ˜Â±Ã˜Â­Ã˜Â©',
                ),
              ),
              const SizedBox(height: 10),
              Builder(
                builder: (context) {
                  const relatedCardWidth = 164.0;
                  final relatedCardHeight = ProductCard.mainAxisExtentForWidth(
                    relatedCardWidth,
                    compact: true,
                  );
                  return SizedBox(
                    height: relatedCardHeight,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: related.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 10),
                      itemBuilder: (context, index) {
                        final item = related[index];
                        return SizedBox(
                          width: relatedCardWidth,
                          child: ProductCard(
                            product: item,
                            compact: true,
                            isWishlisted: wishlistController.isWishlisted(
                              item.id,
                            ),
                            onTap: () => Navigator.pushReplacementNamed(
                              context,
                              AppRoutes.productDetails,
                              arguments: item.id,
                            ),
                            onWishlistTap: () =>
                                wishlistController.toggleWishlist(item),
                            onQuickAddTap: () {},
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showShareMessage(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.tr('Share', 'Ã™â€¦Ã˜Â´Ã˜Â§Ã˜Â±Ã™Æ’Ã˜Â©')),
        content: Text(
          context.tr(
            'Native sharing is not configured in this mock app yet.',
            'Ã˜Â§Ã™â€žÃ™â€¦Ã˜Â´Ã˜Â§Ã˜Â±Ã™Æ’Ã˜Â© Ã˜Â§Ã™â€žÃ˜Â£Ã˜ÂµÃ™â€žÃ™Å Ã˜Â© Ã˜ÂºÃ™Å Ã˜Â± Ã™â€¦Ã™ÂÃ˜Â¹Ã™â€žÃ˜Â© Ã™ÂÃ™Å  Ã™â€¡Ã˜Â°Ã˜Â§ Ã˜Â§Ã™â€žÃ˜ÂªÃ˜Â·Ã˜Â¨Ã™Å Ã™â€š Ã˜Â§Ã™â€žÃ˜ÂªÃ˜Â¬Ã˜Â±Ã™Å Ã˜Â¨Ã™Å  Ã˜Â¨Ã˜Â¹Ã˜Â¯.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(context.tr('Close', 'Ã˜Â¥Ã˜ÂºÃ™â€žÃ˜Â§Ã™â€š')),
          ),
        ],
      ),
    );
  }

  void _reviewAction(BuildContext context, AuthController authController) {
    if (authController.isGuest) {
      AppBottomSheet.showAuthRequired(context);
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          context.tr(
            'Review form available after delivered purchase',
            'Ã™â€ Ã™â€¦Ã™Ë†Ã˜Â°Ã˜Â¬ Ã˜Â§Ã™â€žÃ˜ÂªÃ™â€šÃ™Å Ã™Å Ã™â€¦ Ã™â€¦Ã˜ÂªÃ˜Â§Ã˜Â­ Ã˜Â¨Ã˜Â¹Ã˜Â¯ Ã˜Â§Ã˜Â³Ã˜ÂªÃ™â€žÃ˜Â§Ã™â€¦ Ã˜Â§Ã™â€žÃ˜Â·Ã™â€žÃ˜Â¨',
          ),
        ),
      ),
    );
  }

  void _addToBag(BuildContext context, ProductModel product) {
    AuthRequiredHelper.guard(
      context,
      onAuthenticated: () {
        if (!_hasRequiredSelections(product)) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                context.tr(
                  'Please choose color and size',
                  'Ã™Å Ã˜Â±Ã˜Â¬Ã™â€° Ã˜Â§Ã˜Â®Ã˜ÂªÃ™Å Ã˜Â§Ã˜Â± Ã˜Â§Ã™â€žÃ™â€žÃ™Ë†Ã™â€  Ã™Ë†Ã˜Â§Ã™â€žÃ™â€¦Ã™â€šÃ˜Â§Ã˜Â³',
                ),
              ),
            ),
          );
          return;
        }
        final result = context.read<CartController>().addToCart(
          product,
          _selectedColor ?? '',
          _selectedSize ?? '',
          _quantity,
        );
        CartActionFeedbackHelper.show(context, result);
      },
    );
  }

  void _buyNow(BuildContext context, ProductModel product) {
    AuthRequiredHelper.guard(
      context,
      onAuthenticated: () {
        if (!_hasRequiredSelections(product)) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                context.tr(
                  'Please choose color and size',
                  'Ã™Å Ã˜Â±Ã˜Â¬Ã™â€° Ã˜Â§Ã˜Â®Ã˜ÂªÃ™Å Ã˜Â§Ã˜Â± Ã˜Â§Ã™â€žÃ™â€žÃ™Ë†Ã™â€  Ã™Ë†Ã˜Â§Ã™â€žÃ™â€¦Ã™â€šÃ˜Â§Ã˜Â³',
                ),
              ),
            ),
          );
          return;
        }
        final result = context.read<CartController>().addToCart(
          product,
          _selectedColor ?? '',
          _selectedSize ?? '',
          _quantity,
        );
        if (!result.isSuccess) {
          CartActionFeedbackHelper.show(context, result);
          return;
        }
        Navigator.pushNamed(context, AppRoutes.checkout);
      },
    );
  }

  bool _hasRequiredSelections(ProductModel product) {
    final hasColor = product.colors.isEmpty || _selectedColor != null;
    final hasSize = product.sizes.isEmpty || _selectedSize != null;
    return hasColor && hasSize;
  }
}

class _HeroGalleryCard extends StatelessWidget {
  const _HeroGalleryCard({
    required this.gallery,
    required this.currentImage,
    required this.onPageChanged,
    required this.topLabel,
    required this.discountLabel,
    required this.metrics,
  });

  final List<String> gallery;
  final int currentImage;
  final ValueChanged<int> onPageChanged;
  final String topLabel;
  final String discountLabel;
  final List<_HeroMetricData> metrics;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        children: [
          AspectRatio(
            aspectRatio: 0.86,
            child: Stack(
              children: [
                Positioned.fill(
                  child: gallery.isEmpty
                      ? const ProductImage(radius: 24)
                      : PageView.builder(
                          itemCount: gallery.length,
                          onPageChanged: onPageChanged,
                          itemBuilder: (context, index) => ProductImage(
                            imageUrl: gallery[index],
                            imageUrls: gallery,
                            radius: 24,
                          ),
                        ),
                ),
                Positioned(
                  top: 14,
                  left: 14,
                  right: 14,
                  child: Row(
                    children: [
                      _HeroTopChip(
                        icon: Icons.auto_awesome_rounded,
                        label: topLabel,
                      ),
                      const Spacer(),
                      _HeroTopChip(
                        icon: Icons.discount_outlined,
                        label: discountLabel,
                      ),
                    ],
                  ),
                ),
                if (gallery.length > 1)
                  Positioned(
                    bottom: 18,
                    left: 18,
                    right: 18,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        gallery.length,
                        (index) => Container(
                          width: currentImage == index ? 22 : 7,
                          height: 7,
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          decoration: BoxDecoration(
                            color: currentImage == index
                                ? colors.primaryText
                                : Colors.white.withValues(alpha: 0.55),
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: metrics
                .map(
                  (metric) => Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3),
                      child: _HeroMetricCard(metric: metric),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _HeroTopChip extends StatelessWidget {
  const _HeroTopChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.34),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.white),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroMetricData {
  const _HeroMetricData({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;
}

class _HeroMetricCard extends StatelessWidget {
  const _HeroMetricCard({required this.metric});

  final _HeroMetricData metric;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: colors.surfaceSoft,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(metric.icon, size: 18, color: colors.icon),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  metric.label,
                  style: TextStyle(
                    color: colors.secondaryText,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  metric.value,
                  style: TextStyle(
                    color: colors.primaryText,
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PriceHero extends StatelessWidget {
  const _PriceHero({
    required this.price,
    this.oldPrice,
    required this.discount,
  });

  final double price;
  final double? oldPrice;
  final int discount;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              formatCurrency(price),
              style: TextStyle(
                color: colors.price,
                fontWeight: FontWeight.w900,
                fontSize: 30,
                height: 1,
              ),
            ),
            if (oldPrice != null) ...[
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  formatCurrency(oldPrice!),
                  style: TextStyle(
                    color: colors.mutedText,
                    decoration: TextDecoration.lineThrough,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: colors.discount.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            context.tr('Save $discount%', 'Ã™Ë†Ã™ÂÃ˜Â± $discount%'),
            style: TextStyle(
              color: colors.discount,
              fontWeight: FontWeight.w800,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }
}

class _RatingBadge extends StatelessWidget {
  const _RatingBadge({required this.rating, required this.reviewCount});

  final double rating;
  final int reviewCount;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.star_rounded, color: Colors.amber.shade600, size: 18),
          const SizedBox(width: 6),
          Text(
            '${rating.toStringAsFixed(1)} ($reviewCount)',
            style: TextStyle(
              color: colors.primaryText,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _BadgePill extends StatelessWidget {
  const _BadgePill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: colors.border),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: colors.primaryText,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _PanelLabel extends StatelessWidget {
  const _PanelLabel({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w800,
            color: colors.primaryText,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: TextStyle(color: colors.secondaryText, fontSize: 12),
        ),
      ],
    );
  }
}

class _DetailPanel extends StatelessWidget {
  const _DetailPanel({
    required this.title,
    required this.child,
    this.subtitle,
    this.icon,
  });

  final String title;
  final String? subtitle;
  final IconData? icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: colors.surfaceSoft,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, color: colors.icon),
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: colors.primaryText,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtitle!,
                        style: TextStyle(
                          color: colors.secondaryText,
                          height: 1.45,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _MiniInfoTile extends StatelessWidget {
  const _MiniInfoTile({required this.title, required this.subtitle, this.icon});

  final String title;
  final String subtitle;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.surfaceSoft,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, size: 20, color: colors.icon),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: colors.primaryText,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: colors.secondaryText,
                    fontSize: 13,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomActionIcon extends StatelessWidget {
  const _BottomActionIcon({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: colors.surfaceSoft,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colors.border),
        ),
        child: Icon(icon, size: 21, color: colors.icon),
      ),
    );
  }
}

class _QtyControl extends StatelessWidget {
  const _QtyControl({
    required this.quantity,
    required this.onDecrease,
    required this.onIncrease,
  });

  final int quantity;
  final VoidCallback? onDecrease;
  final VoidCallback? onIncrease;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.border),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: onDecrease,
            icon: const Icon(Icons.remove),
            visualDensity: VisualDensity.compact,
          ),
          Text(
            '$quantity',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              color: colors.primaryText,
            ),
          ),
          IconButton(
            onPressed: onIncrease,
            icon: const Icon(Icons.add),
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }
}

class _InfoStrip extends StatelessWidget {
  const _InfoStrip({required this.items});

  final List<_InfoStripItem> items;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: items
          .map(
            (item) => Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: _InfoStripCard(item: item),
              ),
            ),
          )
          .toList(),
    );
  }
}

class _InfoStripItem {
  const _InfoStripItem(this.label, this.subtitle, this.icon);

  final String label;
  final String subtitle;
  final IconData icon;
}

class _InfoStripCard extends StatelessWidget {
  const _InfoStripCard({required this.item});

  final _InfoStripItem item;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: colors.surfaceSoft,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(item.icon, size: 18, color: colors.icon),
          ),
          const SizedBox(height: 10),
          Text(
            item.label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: colors.primaryText,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            item.subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              height: 1.35,
              color: colors.secondaryText,
            ),
          ),
        ],
      ),
    );
  }
}

class _StoreShowcaseCard extends StatelessWidget {
  const _StoreShowcaseCard({required this.store});

  final StoreModel store;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final locale = Localizations.localeOf(context);

    return GestureDetector(
      onTap: () => Navigator.pushNamed(
        context,
        AppRoutes.storefront,
        arguments: store.id,
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: colors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: colors.surfaceSoft,
                    shape: BoxShape.circle,
                    border: Border.all(color: colors.border),
                  ),
                  child: Icon(Icons.storefront_outlined, color: colors.icon),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              store.localizedName(locale),
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                color: colors.primaryText,
                              ),
                            ),
                          ),
                          if (store.isVerified)
                            Icon(
                              Icons.verified_rounded,
                              color: colors.info,
                              size: 18,
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      StoreRatingStars(
                        rating: store.rating,
                        reviewCount: store.reviewCount,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              store.localizedDescription(locale),
              style: TextStyle(
                color: colors.secondaryText,
                fontSize: 13,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _StorePill(
                  icon: Icons.location_on_outlined,
                  label: store.localizedAddress(locale),
                ),
                _StorePill(icon: Icons.call_outlined, label: store.storePhone),
                _StorePill(
                  icon: Icons.badge_outlined,
                  label: localizedBusinessActivity(
                    context,
                    store.businessActivityType,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: FilledButton.tonalIcon(
                onPressed: () => Navigator.pushNamed(
                  context,
                  AppRoutes.storefront,
                  arguments: store.id,
                ),
                icon: const Icon(Icons.store_outlined),
                label: Text(
                  context.tr(
                    'Visit Store',
                    'Ã˜Â²Ã™Å Ã˜Â§Ã˜Â±Ã˜Â© Ã˜Â§Ã™â€žÃ™â€¦Ã˜ÂªÃ˜Â¬Ã˜Â±',
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StorePill extends StatelessWidget {
  const _StorePill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: colors.surfaceSoft,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: colors.icon),
          const SizedBox(width: 6),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 220),
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: colors.primaryText,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReviewTile extends StatelessWidget {
  const _ReviewTile({
    required this.author,
    required this.comment,
    required this.rating,
  });

  final String author;
  final String comment;
  final double rating;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.surfaceSoft,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: colors.surface,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              author.isEmpty ? '?' : author.characters.first.toUpperCase(),
              style: TextStyle(
                fontWeight: FontWeight.w800,
                color: colors.primaryText,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        author,
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          color: colors.primaryText,
                        ),
                      ),
                    ),
                    Text(
                      rating.toStringAsFixed(1),
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        color: colors.primaryText,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.star_rounded,
                      color: Colors.amber.shade600,
                      size: 16,
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  comment,
                  style: TextStyle(
                    fontSize: 13,
                    color: colors.secondaryText,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
