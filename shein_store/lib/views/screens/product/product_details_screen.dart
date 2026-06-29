import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
import '../../../core/helpers/app_copy_helper.dart';
import '../../../core/utils/auth_required_helper.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/widgets/app_bottom_sheet.dart';
import '../../../core/widgets/app_empty_state.dart';
import '../../../core/widgets/product_image.dart';
import '../../../models/product_model.dart';
import '../../../models/review_model.dart';
import '../../../models/store_model.dart';
import '../../widgets/common/app_header.dart';
import '../../widgets/common/section_header.dart';
import '../../widgets/common/store_rating_stars.dart';
import '../../widgets/product/product_card.dart';
import '../../widgets/reviews/product_review_form_sheet.dart';

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
  String _reviewSort = 'recent';

  @override
  Widget build(BuildContext context) {
    return Consumer3<ProductController, WishlistController, AuthController>(
      builder: (context, productController, wishlistController, authController, _) {
        final colors = context.appColors;
        final product = productController.productById(widget.productId);
        if (product == null) {
          return Scaffold(
            body: AppEmptyState(
              title: context.tr('Product unavailable', 'المنتج غير متوفر'),
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
        final reviews = _sortedReviews(
          productController.reviewsForProduct(product.id),
        );
        final ratingSummary = productController.ratingSummaryForProduct(
          product.id,
        );
        final existingReview = productController
            .currentCustomerReviewForProduct(product.id);
        final reviewEligibility = productController.reviewEligibilityForProduct(
          product.id,
        );
        final canShowReviewAction =
            reviewEligibility.canReview || existingReview != null;
        final isPurchased = productController.currentCustomerPurchasedProduct(
          product.id,
        );
        final related = productController.relatedProducts(product);
        final store = productController.storeForProduct(product);
        // ignore: unused_local_variable
        final localizedStoreName =
            store?.localizedName(locale) ??
            context.tr('Store unavailable', 'المتجر غير متاح');
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
          if (product.isFlashSale) context.tr('Flash Sale', 'تخفيض سريع'),
          if (product.isHot) context.tr('Hot pick', 'اختيار رائج'),
          if (product.isNew) context.tr('New in', 'وصل حديثاً'),
          if (product.isReturnable)
            context.tr('30-day return', 'إرجاع خلال 30 يوماً'),
          if (isPurchased) context.tr('Purchased', 'تم شراؤه'),
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
                      child: Text(context.tr('Add to Bag', 'أضف إلى السلة')),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: FilledButton(
                      onPressed: () => _buyNow(context, product),
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(50),
                      ),
                      child: Text(context.tr('Buy Now', 'اشتر الآن')),
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
                topLabel: context.tr('Editor\'s Pick', 'اختيار المحرر'),
                discountLabel: context.tr(
                  '${product.discount}% off',
                  'خصم ${product.discount}%',
                ),
                metrics: [
                  _HeroMetricData(
                    label: context.tr('Sold', 'تم البيع'),
                    value: '${product.soldCount}',
                    icon: Icons.local_fire_department_outlined,
                  ),
                  _HeroMetricData(
                    label: context.tr('Stock', 'المخزون'),
                    value: '${product.stock}',
                    icon: Icons.inventory_2_outlined,
                  ),
                  _HeroMetricData(
                    label: context.tr('Views', 'المشاهدات'),
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
                          rating: ratingSummary.averageRating,
                          reviewCount: ratingSummary.reviewCount,
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
                      '${context.tr('Sold by', 'يباع بواسطة')} ${product.sellerName}',
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
                                context.tr('Store SKU', 'رمز المنتج'),
                                style: TextStyle(
                                  color: colors.secondaryText,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Flexible(
                                    child: Text(
                                      product.sku,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: colors.primaryText,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                                  AppCopyIconButton(
                                    text: product.sku,
                                    feedback: context.l10n.copiedSku,
                                    tooltip: context.l10n.copy,
                                    iconSize: 18,
                                  ),
                                ],
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
                          context.tr('Secure pay', 'دفع آمن'),
                          context.tr('Protected checkout', 'إتمام شراء محمي'),
                          Icons.lock_outline_rounded,
                        ),
                        _InfoStripItem(
                          context.tr('Fast delivery', 'توصيل سريع'),
                          context.tr('Express options', 'خيارات سريعة'),
                          Icons.local_shipping_outlined,
                        ),
                        _InfoStripItem(
                          context.tr('Free return', 'إرجاع مجاني'),
                          context.tr(
                            'Easy 30-day return',
                            'إرجاع سهل خلال 30 يوماً',
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
                title: context.tr('Offer highlights', 'أبرز العروض'),
                subtitle: context.tr(
                  'The best reasons to shop this item right now.',
                  'أفضل أسباب شراء هذا المنتج الآن.',
                ),
                icon: Icons.auto_awesome_rounded,
                child: Column(
                  children: [
                    _MiniInfoTile(
                      icon: Icons.sell_outlined,
                      title: context.tr('Coupon stack', 'قسائم متاحة'),
                      subtitle: context.tr(
                        'Browse welcome and seasonal coupon offers before checkout.',
                        'تصفح قسائم الترحيب والعروض الموسمية قبل إتمام الطلب.',
                      ),
                    ),
                    _MiniInfoTile(
                      icon: Icons.stars_outlined,
                      title: context.tr('Reward points', 'نقاط المكافآت'),
                      subtitle: context.tr(
                        'Earn points on every successful purchase from this listing.',
                        'اكسب نقاطاً مع كل عملية شراء مكتملة من هذا المنتج.',
                      ),
                    ),
                    _MiniInfoTile(
                      icon: Icons.timer_outlined,
                      title: context.tr('Sale countdown', 'العد التنازلي'),
                      subtitle: context.tr(
                        'Flash event pricing is still active for a limited time.',
                        'سعر العرض السريع ما زال فعالاً لفترة محدودة.',
                      ),
                    ),
                  ],
                ),
              ),
              _DetailPanel(
                title: context.tr('Choose your options', 'اختر خياراتك'),
                subtitle: context.tr(
                  'Pick the right color, size, and quantity before adding to bag.',
                  'اختر اللون والمقاس والكمية المناسبة قبل الإضافة إلى السلة.',
                ),
                icon: Icons.tune_rounded,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _PanelLabel(
                      title: context.tr('Color', 'اللون'),
                      subtitle: context.tr(
                        'Available shades',
                        'الألوان المتاحة',
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
                            title: context.tr('Quantity', 'الكمية'),
                            subtitle: context.tr(
                              '${product.stock} pieces ready to ship',
                              '${product.stock} قطع جاهزة للشحن',
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
                title: context.tr('Shipping and return', 'الشحن والإرجاع'),
                subtitle: context.tr(
                  'Helpful delivery details before you place the order.',
                  'تفاصيل مفيدة عن التوصيل قبل تنفيذ الطلب.',
                ),
                icon: Icons.local_shipping_outlined,
                child: Column(
                  children: [
                    _MiniInfoTile(
                      icon: Icons.delivery_dining_outlined,
                      title: context.tr('Shipping method', 'طريقة الشحن'),
                      subtitle: context.tr(
                        'Standard and express delivery options are available.',
                        'خيارات الشحن العادي والسريع متاحة.',
                      ),
                    ),
                    _MiniInfoTile(
                      icon: Icons.schedule_outlined,
                      title: context.tr(
                        'Estimated delivery',
                        'التوصيل المتوقع',
                      ),
                      subtitle: context.tr(
                        'Expected arrival within 3 to 7 business days.',
                        'الوصول المتوقع خلال 3 إلى 7 أيام عمل.',
                      ),
                    ),
                    _MiniInfoTile(
                      icon: Icons.assignment_return_outlined,
                      title: context.tr('Return policy', 'سياسة الإرجاع'),
                      subtitle: context.tr(
                        'Eligible items can be returned within 30 days.',
                        'يمكن إرجاع المنتجات المؤهلة خلال 30 يوماً.',
                      ),
                    ),
                  ],
                ),
              ),
              _DetailPanel(
                title: context.tr('Product details', 'تفاصيل المنتج'),
                subtitle: context.tr(
                  'Materials, care, and catalog information in one place.',
                  'الخامات والعناية ومعلومات الكتالوج في مكان واحد.',
                ),
                icon: Icons.inventory_2_outlined,
                child: Column(
                  children: [
                    _MiniInfoTile(
                      icon: Icons.description_outlined,
                      title: context.tr('Description', 'الوصف'),
                      subtitle: localizedDescription,
                    ),
                    _MiniInfoTile(
                      icon: Icons.checkroom_outlined,
                      title: context.tr('Material', 'الخامة'),
                      subtitle: '$localizedMaterial\n$localizedComposition',
                    ),
                    _MiniInfoTile(
                      icon: Icons.clean_hands_outlined,
                      title: context.tr('Care instructions', 'تعليمات العناية'),
                      subtitle: localizedCareInstructions,
                    ),
                    _MiniInfoTile(
                      icon: Icons.qr_code_rounded,
                      title: context.tr(
                        'SKU / Category / Season',
                        'الرمز / الفئة / الموسم',
                      ),
                      subtitle:
                          '${product.sku}\n${product.categoryName}\n${context.tr('All-season', 'مناسب لكل المواسم')}',
                    ),
                  ],
                ),
              ),
              _DetailPanel(
                title: context.tr('Customer reviews', 'تقييمات العملاء'),
                subtitle: context.tr(
                  'Real feedback from shoppers who received this product.',
                  'آراء حقيقية من عملاء استلموا هذا المنتج.',
                ),
                icon: Icons.rate_review_outlined,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _ReviewSummaryCard(summary: ratingSummary),
                    const SizedBox(height: 14),
                    _ReviewSortBar(
                      selectedSort: _reviewSort,
                      onChanged: (value) => setState(() => _reviewSort = value),
                    ),
                    const SizedBox(height: 12),
                    if (reviews.isEmpty)
                      _MiniInfoTile(
                        icon: Icons.rate_review_outlined,
                        title: context.tr(
                          'No reviews yet',
                          'لا توجد تقييمات بعد',
                        ),
                        subtitle: context.tr(
                          'Be the first shopper to share an opinion once the order is delivered.',
                          'كن أول من يشارك رأيه بعد استلام الطلب.',
                        ),
                      )
                    else
                      ...reviews.map((review) => _ReviewTile(review: review)),
                    const SizedBox(height: 10),
                    if (canShowReviewAction)
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: () => _reviewAction(
                            context,
                            product,
                            existingReview: existingReview,
                          ),
                          icon: const Icon(Icons.edit_outlined),
                          label: Text(
                            existingReview == null
                                ? context.tr('Write a Review', 'اكتب تقييمًا')
                                : context.tr('Edit Review', 'تعديل التقييم'),
                          ),
                        ),
                      )
                    else
                      _ReviewEligibilityHint(eligibility: reviewEligibility),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              SectionHeader(
                title: context.tr('Recommendations', 'منتجات مقترحة'),
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
                            onQuickAddTap: () => _quickAdd(context, item),
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

  Future<void> _showShareMessage(BuildContext context) async {
    final product = context.read<ProductController>().productById(
      widget.productId,
    );
    final text = product == null
        ? 'LY STORE'
        : 'LY STORE • ${product.title} • ${formatCurrency(product.price)}';
    await Clipboard.setData(ClipboardData(text: text));
    if (!context.mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(context.tr('Product link copied', 'تم نسخ رابط المنتج')),
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

  List<ReviewModel> _sortedReviews(List<ReviewModel> reviews) {
    final items = List<ReviewModel>.from(reviews);
    switch (_reviewSort) {
      case 'highest':
        items.sort((a, b) => b.rating.compareTo(a.rating));
      case 'lowest':
        items.sort((a, b) => a.rating.compareTo(b.rating));
      case 'recent':
      default:
        items.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }
    return items;
  }

  Future<void> _reviewAction(
    BuildContext context,
    ProductModel product, {
    ReviewModel? existingReview,
  }) async {
    final productController = context.read<ProductController>();
    final authController = context.read<AuthController>();
    if (authController.isGuest || !authController.isLoggedIn) {
      await AppBottomSheet.showAuthRequired(context);
      return;
    }
    final eligibility = productController.reviewEligibilityForProduct(
      product.id,
    );
    if (existingReview == null && !eligibility.canReview) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_reviewEligibilityMessage(context, eligibility)),
        ),
      );
      return;
    }
    await ProductReviewFormSheet.show(
      context: context,
      product: product,
      existingReview: existingReview,
      onSubmit: ({required rating, required comment}) =>
          productController.saveProductReview(
            productId: product.id,
            rating: rating,
            comment: comment,
            existingReview: existingReview,
          ),
    );
  }

  String _reviewEligibilityMessage(
    BuildContext context,
    ReviewEligibilityResult eligibility,
  ) {
    switch (eligibility.reason) {
      case ReviewEligibilityReason.notLoggedIn:
        return context.tr(
          'Please log in and purchase this product before writing a review.',
          'يرجى تسجيل الدخول وشراء هذا المنتج قبل كتابة تقييم.',
        );
      case ReviewEligibilityReason.notCustomer:
        return context.tr(
          'Only customer accounts can review products.',
          'يمكن لحسابات العملاء فقط تقييم المنتجات.',
        );
      case ReviewEligibilityReason.notPurchased:
        return context.tr(
          'You can review this product after purchasing it.',
          'يمكنك تقييم هذا المنتج بعد شرائه.',
        );
      case ReviewEligibilityReason.paymentNotCompleted:
        return context.tr(
          'You can review this product after payment is completed.',
          'يمكنك تقييم هذا المنتج بعد اكتمال الدفع.',
        );
      case ReviewEligibilityReason.orderCancelled:
        return context.tr(
          'Cancelled or refunded orders cannot be reviewed.',
          'لا يمكن تقييم الطلبات الملغية أو المستردة.',
        );
      case ReviewEligibilityReason.alreadyReviewed:
        return context.tr(
          'You already reviewed this product. Use Edit Review instead.',
          'لقد قيّمت هذا المنتج بالفعل. استخدم تعديل التقييم.',
        );
      case ReviewEligibilityReason.productNotFound:
        return context.tr('Product unavailable.', 'المنتج غير متوفر.');
      case ReviewEligibilityReason.success:
        return '';
    }
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
                  'يرجى اختيار اللون والمقاس',
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
                  'يرجى اختيار اللون والمقاس',
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
        Wrap(
          spacing: 8,
          runSpacing: 4,
          crossAxisAlignment: WrapCrossAlignment.end,
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
            context.tr('Save $discount%', 'وفر $discount%'),
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
                label: Text(context.tr('Visit Store', 'زيارة المتجر')),
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

class _ReviewSummaryCard extends StatelessWidget {
  const _ReviewSummaryCard({required this.summary});

  final ProductRatingSummary summary;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surfaceSoft,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 92,
            child: Column(
              children: [
                Text(
                  summary.averageRating.toStringAsFixed(1),
                  style: TextStyle(
                    color: colors.primaryText,
                    fontSize: 34,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  context.tr(
                    '${summary.reviewCount} reviews',
                    '${summary.reviewCount} تقييم',
                  ),
                  textAlign: TextAlign.center,
                  style: TextStyle(color: colors.secondaryText, fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              children: [5, 4, 3, 2, 1]
                  .map(
                    (star) => _RatingBreakdownRow(
                      star: star,
                      count: summary.ratingBreakdown[star] ?? 0,
                      total: summary.reviewCount,
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _RatingBreakdownRow extends StatelessWidget {
  const _RatingBreakdownRow({
    required this.star,
    required this.count,
    required this.total,
  });

  final int star;
  final int count;
  final int total;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final value = total == 0 ? 0.0 : count / total;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Text(
            '$star',
            style: TextStyle(
              color: colors.secondaryText,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: 4),
          Icon(Icons.star_rounded, color: colors.warning, size: 14),
          const SizedBox(width: 8),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                minHeight: 7,
                value: value,
                backgroundColor: colors.surface,
                color: colors.warning,
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 22,
            child: Text(
              '$count',
              textAlign: TextAlign.end,
              style: TextStyle(color: colors.secondaryText, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReviewSortBar extends StatelessWidget {
  const _ReviewSortBar({required this.selectedSort, required this.onChanged});

  final String selectedSort;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final options = {
      'recent': context.tr('Most Recent', 'الأحدث'),
      'highest': context.tr('Highest Rating', 'الأعلى تقييماً'),
      'lowest': context.tr('Lowest Rating', 'الأقل تقييماً'),
    };
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options.entries.map((entry) {
        return ChoiceChip(
          label: Text(entry.value),
          selected: selectedSort == entry.key,
          onSelected: (_) => onChanged(entry.key),
        );
      }).toList(),
    );
  }
}

class _ReviewEligibilityHint extends StatelessWidget {
  const _ReviewEligibilityHint({required this.eligibility});

  final ReviewEligibilityResult eligibility;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final message = switch (eligibility.reason) {
      ReviewEligibilityReason.notLoggedIn => context.tr(
        'You can read reviews. To write one, purchase this product first.',
        'يمكنك قراءة التقييمات، ولإضافة تقييم يجب شراء المنتج أولًا.',
      ),
      ReviewEligibilityReason.notCustomer => context.tr(
        'Only customer accounts can write product reviews.',
        'يمكن لحسابات العملاء فقط كتابة تقييمات المنتجات.',
      ),
      ReviewEligibilityReason.notPurchased => context.tr(
        'You can review this product after purchasing it.',
        'يمكنك تقييم هذا المنتج بعد شرائه.',
      ),
      ReviewEligibilityReason.paymentNotCompleted => context.tr(
        'You can review this product after payment is completed.',
        'يمكنك تقييم هذا المنتج بعد اكتمال الدفع.',
      ),
      ReviewEligibilityReason.orderCancelled => context.tr(
        'Cancelled or refunded orders cannot be reviewed.',
        'لا يمكن تقييم الطلبات الملغية أو المستردة.',
      ),
      ReviewEligibilityReason.productNotFound => context.tr(
        'Product unavailable.',
        'المنتج غير متوفر.',
      ),
      ReviewEligibilityReason.alreadyReviewed ||
      ReviewEligibilityReason.success => '',
    };
    if (message.isEmpty) {
      return const SizedBox.shrink();
    }
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.surfaceSoft,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded, color: colors.icon, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              textAlign: TextAlign.start,
              style: TextStyle(
                color: colors.secondaryText,
                fontSize: 13,
                height: 1.45,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReviewTile extends StatelessWidget {
  const _ReviewTile({required this.review});

  final ReviewModel review;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final date =
        '${review.createdAt.year}/${review.createdAt.month.toString().padLeft(2, '0')}/${review.createdAt.day.toString().padLeft(2, '0')}';
    final author = review.customerName;
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
          CircleAvatar(
            backgroundColor: colors.surface,
            foregroundColor: colors.primaryText,
            child: Text(author.isEmpty ? '?' : author.characters.first),
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
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          color: colors.primaryText,
                        ),
                      ),
                    ),
                    Icon(Icons.star_rounded, color: colors.warning, size: 17),
                    const SizedBox(width: 3),
                    Text(
                      review.rating.toStringAsFixed(1),
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        color: colors.primaryText,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    if (review.isVerifiedPurchase)
                      _BadgePill(
                        label: context.tr('Verified Purchase', 'شراء موثق'),
                      ),
                    _BadgePill(label: date),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  review.comment,
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
