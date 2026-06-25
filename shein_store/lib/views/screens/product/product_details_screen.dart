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
                'Ø§Ù„Ù…Ù†ØªØ¬ ØºÙŠØ± Ù…ØªÙˆÙØ±',
              ),
              message: context.tr(
                'The item could not be found.',
                'ØªØ¹Ø°Ø± Ø§Ù„Ø¹Ø«ÙˆØ± Ø¹Ù„Ù‰ Ù‡Ø°Ø§ Ø§Ù„Ù…Ù†ØªØ¬.',
              ),
            ),
          );
        }

        if (!productController.isProductPublic(product)) {
          return Scaffold(
            body: AppEmptyState(
              title: context.tr(
                'Product unavailable',
                'Ã˜Â§Ã™â€žÃ™â€¦Ã™â€ Ã˜ÂªÃ˜Â¬ Ã˜ÂºÃ™Å Ã˜Â± Ã™â€¦Ã˜ÂªÃ™Ë†Ã™ÂÃ˜Â±',
              ),
              message: context.tr(
                'This item is not available for customers right now.',
                'Ã™â€¡Ã˜Â°Ã˜Â§ Ã˜Â§Ã™â€žÃ™â€¦Ã™â€ Ã˜ÂªÃ˜Â¬ Ã˜ÂºÃ™Å Ã˜Â± Ã™â€¦Ã˜ÂªÃ˜Â§Ã˜Â­ Ã™â€žÃ™â€žÃ˜Â¹Ã™â€¦Ã™â€žÃ˜Â§Ã˜Â¡ Ã˜Â­Ã˜Â§Ã™â€žÃ™Å Ã˜Â§Ã™â€¹.',
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
            context.tr('Store unavailable', 'Ø§Ù„Ù…ØªØ¬Ø± ØºÙŠØ± Ù…ØªØ§Ø­');
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
            context.tr('Flash Sale', 'ØªØ®ÙÙŠØ¶ Ø³Ø±ÙŠØ¹'),
          if (product.isHot) context.tr('Hot pick', 'Ø§Ø®ØªÙŠØ§Ø± Ø±Ø§Ø¦Ø¬'),
          if (product.isNew) context.tr('New in', 'ÙˆØµÙ„ Ø­Ø¯ÙŠØ«Ø§Ù‹'),
          if (product.isReturnable)
            context.tr('30-day return', 'Ø¥Ø±Ø¬Ø§Ø¹ Ø®Ù„Ø§Ù„ 30 ÙŠÙˆÙ…Ø§Ù‹'),
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
                                      'ØªÙ…Øª Ø§Ù„Ø¥Ø¶Ø§ÙØ© Ø¥Ù„Ù‰ Ø§Ù„Ù…ÙØ¶Ù„Ø©',
                                    )
                                  : context.tr(
                                      'Removed from wishlist',
                                      'ØªÙ…Øª Ø§Ù„Ø¥Ø²Ø§Ù„Ø© Ù…Ù† Ø§Ù„Ù…ÙØ¶Ù„Ø©',
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
                        context.tr('Add to Bag', 'Ø£Ø¶Ù Ø¥Ù„Ù‰ Ø§Ù„Ø³Ù„Ø©'),
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
                      child: Text(context.tr('Buy Now', 'Ø§Ø´ØªØ± Ø§Ù„Ø¢Ù†')),
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
                  'Ø§Ø®ØªÙŠØ§Ø± Ø§Ù„Ù…Ø­Ø±Ø±',
                ),
                discountLabel: context.tr(
                  '${product.discount}% off',
                  'Ø®ØµÙ… ${product.discount}%',
                ),
                metrics: [
                  _HeroMetricData(
                    label: context.tr('Sold', 'ØªÙ… Ø§Ù„Ø¨ÙŠØ¹'),
                    value: '${product.soldCount}',
                    icon: Icons.local_fire_department_outlined,
                  ),
                  _HeroMetricData(
                    label: context.tr('Stock', 'Ø§Ù„Ù…Ø®Ø²ÙˆÙ†'),
                    value: '${product.stock}',
                    icon: Icons.inventory_2_outlined,
                  ),
                  _HeroMetricData(
                    label: context.tr('Views', 'Ø§Ù„Ù…Ø´Ø§Ù‡Ø¯Ø§Øª'),
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
                      '${context.tr('Sold by', 'ÙŠØ¨Ø§Ø¹ Ø¨ÙˆØ§Ø³Ø·Ø©')} ${product.sellerName}',
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
                                context.tr('Store SKU', 'Ø±Ù…Ø² Ø§Ù„Ù…Ù†ØªØ¬'),
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
                          context.tr('Secure pay', 'Ø¯ÙØ¹ Ø¢Ù…Ù†'),
                          context.tr(
                            'Protected checkout',
                            'Ø¥ØªÙ…Ø§Ù… Ø´Ø±Ø§Ø¡ Ù…Ø­Ù…ÙŠ',
                          ),
                          Icons.lock_outline_rounded,
                        ),
                        _InfoStripItem(
                          context.tr('Fast delivery', 'ØªÙˆØµÙŠÙ„ Ø³Ø±ÙŠØ¹'),
                          context.tr(
                            'Express options',
                            'Ø®ÙŠØ§Ø±Ø§Øª Ø³Ø±ÙŠØ¹Ø©',
                          ),
                          Icons.local_shipping_outlined,
                        ),
                        _InfoStripItem(
                          context.tr('Free return', 'Ø¥Ø±Ø¬Ø§Ø¹ Ù…Ø¬Ø§Ù†ÙŠ'),
                          context.tr(
                            'Easy 30-day return',
                            'Ø¥Ø±Ø¬Ø§Ø¹ Ø³Ù‡Ù„ Ø®Ù„Ø§Ù„ 30 ÙŠÙˆÙ…Ø§Ù‹',
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
                title: context.tr('Offer highlights', 'Ø£Ø¨Ø±Ø² Ø§Ù„Ø¹Ø±ÙˆØ¶'),
                subtitle: context.tr(
                  'The best reasons to shop this item right now.',
                  'Ø£ÙØ¶Ù„ Ø£Ø³Ø¨Ø§Ø¨ Ø´Ø±Ø§Ø¡ Ù‡Ø°Ø§ Ø§Ù„Ù…Ù†ØªØ¬ Ø§Ù„Ø¢Ù†.',
                ),
                icon: Icons.auto_awesome_rounded,
                child: Column(
                  children: [
                    _MiniInfoTile(
                      icon: Icons.sell_outlined,
                      title: context.tr(
                        'Coupon stack',
                        'Ù‚Ø³Ø§Ø¦Ù… Ù…ØªØ§Ø­Ø©',
                      ),
                      subtitle: context.tr(
                        'Browse welcome and seasonal coupon offers before checkout.',
                        'ØªØµÙØ­ Ù‚Ø³Ø§Ø¦Ù… Ø§Ù„ØªØ±Ø­ÙŠØ¨ ÙˆØ§Ù„Ø¹Ø±ÙˆØ¶ Ø§Ù„Ù…ÙˆØ³Ù…ÙŠØ© Ù‚Ø¨Ù„ Ø¥ØªÙ…Ø§Ù… Ø§Ù„Ø·Ù„Ø¨.',
                      ),
                    ),
                    _MiniInfoTile(
                      icon: Icons.stars_outlined,
                      title: context.tr(
                        'Reward points',
                        'Ù†Ù‚Ø§Ø· Ø§Ù„Ù…ÙƒØ§ÙØ¢Øª',
                      ),
                      subtitle: context.tr(
                        'Earn points on every successful purchase from this listing.',
                        'Ø§ÙƒØ³Ø¨ Ù†Ù‚Ø§Ø·Ø§Ù‹ Ù…Ø¹ ÙƒÙ„ Ø¹Ù…Ù„ÙŠØ© Ø´Ø±Ø§Ø¡ Ù…ÙƒØªÙ…Ù„Ø© Ù…Ù† Ù‡Ø°Ø§ Ø§Ù„Ù…Ù†ØªØ¬.',
                      ),
                    ),
                    _MiniInfoTile(
                      icon: Icons.timer_outlined,
                      title: context.tr(
                        'Sale countdown',
                        'Ø§Ù„Ø¹Ø¯ Ø§Ù„ØªÙ†Ø§Ø²Ù„ÙŠ',
                      ),
                      subtitle: context.tr(
                        'Flash event pricing is still active for a limited time.',
                        'Ø³Ø¹Ø± Ø§Ù„Ø¹Ø±Ø¶ Ø§Ù„Ø³Ø±ÙŠØ¹ Ù…Ø§ Ø²Ø§Ù„ ÙØ¹Ø§Ù„Ø§Ù‹ Ù„ÙØªØ±Ø© Ù…Ø­Ø¯ÙˆØ¯Ø©.',
                      ),
                    ),
                  ],
                ),
              ),
              _DetailPanel(
                title: context.tr(
                  'Choose your options',
                  'Ø§Ø®ØªØ± Ø®ÙŠØ§Ø±Ø§ØªÙƒ',
                ),
                subtitle: context.tr(
                  'Pick the right color, size, and quantity before adding to bag.',
                  'Ø§Ø®ØªØ± Ø§Ù„Ù„ÙˆÙ† ÙˆØ§Ù„Ù…Ù‚Ø§Ø³ ÙˆØ§Ù„ÙƒÙ…ÙŠØ© Ø§Ù„Ù…Ù†Ø§Ø³Ø¨Ø© Ù‚Ø¨Ù„ Ø§Ù„Ø¥Ø¶Ø§ÙØ© Ø¥Ù„Ù‰ Ø§Ù„Ø³Ù„Ø©.',
                ),
                icon: Icons.tune_rounded,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _PanelLabel(
                      title: context.tr('Color', 'Ø§Ù„Ù„ÙˆÙ†'),
                      subtitle: context.tr(
                        'Available shades',
                        'Ø§Ù„Ø£Ù„ÙˆØ§Ù† Ø§Ù„Ù…ØªØ§Ø­Ø©',
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
                                    'Ã™â€žÃ˜Â§ Ã™Å Ã™â€žÃ˜Â²Ã™â€¦ Ã˜Â§Ã˜Â®Ã˜ÂªÃ™Å Ã˜Â§Ã˜Â± Ã™â€žÃ™Ë†Ã™â€ ',
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
                            title: context.tr('Size', 'Ø§Ù„Ù…Ù‚Ø§Ø³'),
                            subtitle: context.tr(
                              'Find your best fit',
                              'Ø§Ø¹Ø«Ø± Ø¹Ù„Ù‰ Ø§Ù„Ù…Ù‚Ø§Ø³ Ø§Ù„Ø£Ù†Ø³Ø¨',
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () =>
                              AppBottomSheet.showSizeGuide(context),
                          child: Text(
                            context.tr(
                              'Size Guide',
                              'Ø¯Ù„ÙŠÙ„ Ø§Ù„Ù…Ù‚Ø§Ø³Ø§Øª',
                            ),
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
                                    'Ã™â€žÃ˜Â§ Ã™Å Ã™â€žÃ˜Â²Ã™â€¦ Ã˜Â§Ã˜Â®Ã˜ÂªÃ™Å Ã˜Â§Ã˜Â± Ã™â€¦Ã™â€šÃ˜Â§Ã˜Â³',
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
                            title: context.tr('Quantity', 'Ø§Ù„ÙƒÙ…ÙŠØ©'),
                            subtitle: context.tr(
                              '${product.stock} pieces ready to ship',
                              '${product.stock} Ù‚Ø·Ø¹ Ø¬Ø§Ù‡Ø²Ø© Ù„Ù„Ø´Ø­Ù†',
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
                  'Ø§Ù„Ø´Ø­Ù† ÙˆØ§Ù„Ø¥Ø±Ø¬Ø§Ø¹',
                ),
                subtitle: context.tr(
                  'Helpful delivery details before you place the order.',
                  'ØªÙØ§ØµÙŠÙ„ Ù…ÙÙŠØ¯Ø© Ø¹Ù† Ø§Ù„ØªÙˆØµÙŠÙ„ Ù‚Ø¨Ù„ ØªÙ†ÙÙŠØ° Ø§Ù„Ø·Ù„Ø¨.',
                ),
                icon: Icons.local_shipping_outlined,
                child: Column(
                  children: [
                    _MiniInfoTile(
                      icon: Icons.delivery_dining_outlined,
                      title: context.tr(
                        'Shipping method',
                        'Ø·Ø±ÙŠÙ‚Ø© Ø§Ù„Ø´Ø­Ù†',
                      ),
                      subtitle: context.tr(
                        'Standard and express delivery options are available.',
                        'Ø®ÙŠØ§Ø±Ø§Øª Ø§Ù„Ø´Ø­Ù† Ø§Ù„Ø¹Ø§Ø¯ÙŠ ÙˆØ§Ù„Ø³Ø±ÙŠØ¹ Ù…ØªØ§Ø­Ø©.',
                      ),
                    ),
                    _MiniInfoTile(
                      icon: Icons.schedule_outlined,
                      title: context.tr(
                        'Estimated delivery',
                        'Ø§Ù„ØªÙˆØµÙŠÙ„ Ø§Ù„Ù…ØªÙˆÙ‚Ø¹',
                      ),
                      subtitle: context.tr(
                        'Expected arrival within 3 to 7 business days.',
                        'Ø§Ù„ÙˆØµÙˆÙ„ Ø§Ù„Ù…ØªÙˆÙ‚Ø¹ Ø®Ù„Ø§Ù„ 3 Ø¥Ù„Ù‰ 7 Ø£ÙŠØ§Ù… Ø¹Ù…Ù„.',
                      ),
                    ),
                    _MiniInfoTile(
                      icon: Icons.assignment_return_outlined,
                      title: context.tr(
                        'Return policy',
                        'Ø³ÙŠØ§Ø³Ø© Ø§Ù„Ø¥Ø±Ø¬Ø§Ø¹',
                      ),
                      subtitle: context.tr(
                        'Eligible items can be returned within 30 days.',
                        'ÙŠÙ…ÙƒÙ† Ø¥Ø±Ø¬Ø§Ø¹ Ø§Ù„Ù…Ù†ØªØ¬Ø§Øª Ø§Ù„Ù…Ø¤Ù‡Ù„Ø© Ø®Ù„Ø§Ù„ 30 ÙŠÙˆÙ…Ø§Ù‹.',
                      ),
                    ),
                  ],
                ),
              ),
              _DetailPanel(
                title: context.tr(
                  'Product details',
                  'ØªÙØ§ØµÙŠÙ„ Ø§Ù„Ù…Ù†ØªØ¬',
                ),
                subtitle: context.tr(
                  'Materials, care, and catalog information in one place.',
                  'Ø§Ù„Ø®Ø§Ù…Ø§Øª ÙˆØ§Ù„Ø¹Ù†Ø§ÙŠØ© ÙˆÙ…Ø¹Ù„ÙˆÙ…Ø§Øª Ø§Ù„ÙƒØªØ§Ù„ÙˆØ¬ ÙÙŠ Ù…ÙƒØ§Ù† ÙˆØ§Ø­Ø¯.',
                ),
                icon: Icons.inventory_2_outlined,
                child: Column(
                  children: [
                    _MiniInfoTile(
                      icon: Icons.description_outlined,
                      title: context.tr('Description', 'Ø§Ù„ÙˆØµÙ'),
                      subtitle: localizedDescription,
                    ),
                    _MiniInfoTile(
                      icon: Icons.checkroom_outlined,
                      title: context.tr('Material', 'Ø§Ù„Ø®Ø§Ù…Ø©'),
                      subtitle: '$localizedMaterial\n$localizedComposition',
                    ),
                    _MiniInfoTile(
                      icon: Icons.clean_hands_outlined,
                      title: context.tr(
                        'Care instructions',
                        'ØªØ¹Ù„ÙŠÙ…Ø§Øª Ø§Ù„Ø¹Ù†Ø§ÙŠØ©',
                      ),
                      subtitle: localizedCareInstructions,
                    ),
                    _MiniInfoTile(
                      icon: Icons.qr_code_rounded,
                      title: context.tr(
                        'SKU / Category / Season',
                        'Ø§Ù„Ø±Ù…Ø² / Ø§Ù„ÙØ¦Ø© / Ø§Ù„Ù…ÙˆØ³Ù…',
                      ),
                      subtitle:
                          '${product.sku}\n${product.categoryName}\n${context.tr('All-season', 'Ù…Ù†Ø§Ø³Ø¨ Ù„ÙƒÙ„ Ø§Ù„Ù…ÙˆØ§Ø³Ù…')}',
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
                                context.tr('Reviews', 'Ø§Ù„ØªÙ‚ÙŠÙŠÙ…Ø§Øª'),
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
                                  'Ù…Ø§Ø°Ø§ ÙŠÙ‚ÙˆÙ„ Ø§Ù„Ù…ØªØ³ÙˆÙ‚ÙˆÙ† Ø¹Ù† Ø§Ù„Ù…Ù‚Ø§Ø³ ÙˆØ§Ù„Ø¬ÙˆØ¯Ø© ÙˆØ§Ù„Ù‚ÙŠÙ…Ø© Ø§Ù„Ø¹Ø§Ù…Ø©.',
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
                            context.tr('With photos', 'Ù…Ø¹ Ø§Ù„ØµÙˆØ±'),
                          ),
                        ),
                        Chip(label: Text(context.tr('Size', 'Ø§Ù„Ù…Ù‚Ø§Ø³'))),
                        Chip(
                          label: Text(context.tr('Rating', 'Ø§Ù„ØªÙ‚ÙŠÙŠÙ…')),
                        ),
                        Chip(
                          label: Text(
                            context.tr('Most recent', 'Ø§Ù„Ø£Ø­Ø¯Ø«'),
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
                          'Ù„Ø§ ØªÙˆØ¬Ø¯ ØªÙ‚ÙŠÙŠÙ…Ø§Øª Ø¨Ø¹Ø¯',
                        ),
                        subtitle: context.tr(
                          'Be the first shopper to share an opinion once the order is delivered.',
                          'ÙƒÙ† Ø£ÙˆÙ„ Ù…Ù† ÙŠØ´Ø§Ø±Ùƒ Ø±Ø£ÙŠÙ‡ Ø¨Ø¹Ø¯ Ø§Ø³ØªÙ„Ø§Ù… Ø§Ù„Ø·Ù„Ø¨.',
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
                          context.tr('Write Review', 'Ø§ÙƒØªØ¨ ØªÙ‚ÙŠÙŠÙ…Ø§Ù‹'),
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
                  'Ù…Ù†ØªØ¬Ø§Øª Ù…Ù‚ØªØ±Ø­Ø©',
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
        title: Text(context.tr('Share', 'Ù…Ø´Ø§Ø±ÙƒØ©')),
        content: Text(
          context.tr(
            'Native sharing is not configured in this mock app yet.',
            'Ø§Ù„Ù…Ø´Ø§Ø±ÙƒØ© Ø§Ù„Ø£ØµÙ„ÙŠØ© ØºÙŠØ± Ù…ÙØ¹Ù„Ø© ÙÙŠ Ù‡Ø°Ø§ Ø§Ù„ØªØ·Ø¨ÙŠÙ‚ Ø§Ù„ØªØ¬Ø±ÙŠØ¨ÙŠ Ø¨Ø¹Ø¯.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(context.tr('Close', 'Ø¥ØºÙ„Ø§Ù‚')),
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
            'Ù†Ù…ÙˆØ°Ø¬ Ø§Ù„ØªÙ‚ÙŠÙŠÙ… Ù…ØªØ§Ø­ Ø¨Ø¹Ø¯ Ø§Ø³ØªÙ„Ø§Ù… Ø§Ù„Ø·Ù„Ø¨',
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
                  'ÙŠØ±Ø¬Ù‰ Ø§Ø®ØªÙŠØ§Ø± Ø§Ù„Ù„ÙˆÙ† ÙˆØ§Ù„Ù…Ù‚Ø§Ø³',
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
                  'ÙŠØ±Ø¬Ù‰ Ø§Ø®ØªÙŠØ§Ø± Ø§Ù„Ù„ÙˆÙ† ÙˆØ§Ù„Ù…Ù‚Ø§Ø³',
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
            context.tr('Save $discount%', 'ÙˆÙØ± $discount%'),
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
                  context.tr('Visit Store', 'Ø²ÙŠØ§Ø±Ø© Ø§Ù„Ù…ØªØ¬Ø±'),
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
