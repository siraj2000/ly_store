import 'package:flutter/material.dart' hide SearchController;
import 'package:provider/provider.dart';

import '../../../controllers/cart_controller.dart';
import '../../../controllers/product_controller.dart';
import '../../../controllers/search_controller.dart';
import '../../../controllers/wishlist_controller.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/extensions/localization_extension.dart';
import '../../../core/helpers/catalog_localization_helper.dart';
import '../../../core/helpers/cart_action_feedback_helper.dart';
import '../../../core/utils/auth_required_helper.dart';
import '../../../core/widgets/app_bottom_sheet.dart';
import '../../../core/widgets/app_empty_state.dart';
import '../../../core/widgets/app_error_state.dart';
import '../../../core/widgets/app_loading.dart';
import '../../../models/product_model.dart';
import '../../widgets/common/app_header.dart';
import '../../widgets/product/product_card.dart';

class ProductListingScreen extends StatefulWidget {
  const ProductListingScreen({
    super.key,
    required this.title,
    this.categoryId,
    this.categoryIds = const [],
    this.subcategoryId,
    this.department,
    this.campaignTag,
  });

  final String title;
  final String? categoryId;
  final List<String> categoryIds;
  final String? subcategoryId;
  final String? department;
  final String? campaignTag;

  @override
  State<ProductListingScreen> createState() => _ProductListingScreenState();
}

class _ProductListingScreenState extends State<ProductListingScreen> {
  bool _gridView = true;
  String _sort = 'Recommended';

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final localizedTitle = _localizedListingTitle(context, widget.title);
    return Consumer3<ProductController, WishlistController, SearchController>(
      builder:
          (
            context,
            productController,
            wishlistController,
            searchController,
            _,
          ) {
            if (productController.isLoading) {
              return const Scaffold(body: AppLoading());
            }
            if (productController.errorMessage != null) {
              return Scaffold(
                appBar: AppHeader(title: localizedTitle),
                body: AppErrorState(
                  message: productController.errorMessage!,
                  onRetry: productController.loadInitialData,
                ),
              );
            }
            final selectedCategoryIds = <String>{
              ...widget.categoryIds
                  .map((item) => item.trim())
                  .where((item) => item.isNotEmpty),
              if (widget.categoryId != null &&
                  widget.categoryId!.trim().isNotEmpty)
                widget.categoryId!.trim(),
            };

            List<ProductModel> products = productController.marketplaceProducts;
            if (selectedCategoryIds.isNotEmpty) {
              products = productController.productsForCategoryIds(
                selectedCategoryIds,
              );
            }
            if (widget.subcategoryId != null &&
                widget.subcategoryId!.trim().isNotEmpty) {
              final subcategoryProducts = productController.bySubcategory(
                widget.subcategoryId,
              );
              final productIds = subcategoryProducts
                  .map((item) => item.id)
                  .toSet();
              products = products
                  .where((item) => productIds.contains(item.id))
                  .toList();
            }
            if (widget.department != null && selectedCategoryIds.isEmpty) {
              products = products
                  .where(
                    (item) =>
                        item.department.toLowerCase() ==
                        widget.department!.toLowerCase(),
                  )
                  .toList();
            }
            if (widget.campaignTag != null) {
              switch (widget.campaignTag!.toLowerCase()) {
                case 'sale':
                  products = products
                      .where(
                        (item) =>
                            item.oldPrice > item.price || item.discount > 0,
                      )
                      .toList();
                  break;
                case 'campaign':
                  products = List<ProductModel>.from(products)
                    ..sort(
                      (a, b) => (b.publishedAt ?? b.createdAt).compareTo(
                        a.publishedAt ?? a.createdAt,
                      ),
                    );
                  break;
              }
            }
            if (products.isEmpty) {
              return Scaffold(
                appBar: AppHeader(title: localizedTitle),
                body: AppEmptyState(
                  title: context.tr(
                    'No products found in this category.',
                    'لا توجد منتجات في هذا التصنيف.',
                  ),
                  message: context.tr(
                    'Try changing the department, sort, or filters.',
                    'جرّب تغيير القسم أو الترتيب أو الفلاتر.',
                  ),
                  action: FilledButton(
                    onPressed: () => Navigator.pushNamedAndRemoveUntil(
                      context,
                      AppRoutes.main,
                      (_) => false,
                    ),
                    child: Text(
                      context.tr('View All Products', 'عرض جميع المنتجات'),
                    ),
                  ),
                ),
              );
            }
            return Scaffold(
              appBar: AppHeader(
                title: localizedTitle,
                leading: BackButton(onPressed: () => Navigator.pop(context)),
                actions: [
                  IconButton(
                    onPressed: () =>
                        Navigator.pushNamed(context, AppRoutes.search),
                    icon: const Icon(Icons.search),
                  ),
                  IconButton(
                    onPressed: () =>
                        Navigator.pushNamed(context, AppRoutes.cart),
                    icon: const Icon(Icons.shopping_bag_outlined),
                  ),
                ],
              ),
              body: ListView(
                padding: const EdgeInsets.all(AppSizes.lg),
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      Chip(label: Text(context.tr('Category', 'الفئة'))),
                      Chip(label: Text(context.tr('Size', 'المقاس'))),
                      Chip(label: Text(context.tr('Color', 'اللون'))),
                      Chip(label: Text(context.tr('Price', 'السعر'))),
                      Chip(label: Text(context.tr('Discount', 'الخصم'))),
                      Chip(label: Text(context.tr('Rating', 'التقييم'))),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: colors.card,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: colors.border),
                    ),
                    child: Row(
                      children: [
                        Text(
                          context.tr(
                            '${products.length} products',
                            '${products.length} منتجًا',
                          ),
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: colors.primaryText,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          onPressed: () =>
                              setState(() => _gridView = !_gridView),
                          icon: Icon(
                            _gridView
                                ? Icons.view_agenda_outlined
                                : Icons.grid_view_rounded,
                          ),
                        ),
                        TextButton.icon(
                          onPressed: () async {
                            final sort = await AppBottomSheet.showSortOptions(
                              context,
                              selected: _sort,
                            );
                            if (sort != null) {
                              setState(() => _sort = sort);
                            }
                          },
                          icon: const Icon(Icons.swap_vert),
                          label: Text(context.tr('Sort', 'ترتيب')),
                        ),
                        TextButton.icon(
                          onPressed: () async {
                            final filters =
                                await AppBottomSheet.showFilterOptions(context);
                            if (filters != null) {
                              searchController.applyFilters(filters);
                            }
                          },
                          icon: const Icon(Icons.filter_alt_outlined),
                          label: Text(context.tr('Filter', 'تصفية')),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      const spacing = 10.0;
                      final crossAxisCount = _gridView ? 2 : 1;
                      final cardWidth =
                          (constraints.maxWidth -
                              (spacing * (crossAxisCount - 1))) /
                          crossAxisCount;
                      final cardHeight = _gridView
                          ? ProductCard.mainAxisExtentForWidth(
                              cardWidth,
                              compact: true,
                            )
                          : 188.0;

                      return GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: products.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: spacing,
                          mainAxisExtent: cardHeight,
                        ),
                        itemBuilder: (context, index) {
                          final product = products[index];
                          return ProductCard(
                            product: product,
                            compact: _gridView,
                            showRating: _gridView,
                            isWishlisted: wishlistController.isWishlisted(
                              product.id,
                            ),
                            onTap: () => Navigator.pushNamed(
                              context,
                              AppRoutes.productDetails,
                              arguments: product.id,
                            ),
                            onWishlistTap: () => AuthRequiredHelper.guard(
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
                            onQuickAddTap: () => _quickAdd(context, product),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            );
          },
    );
  }

  String _localizedListingTitle(BuildContext context, String value) {
    final categoryValue = localizedCategoryName(context, value);
    if (categoryValue != value) {
      return categoryValue;
    }
    final departmentValue = localizedDepartmentName(context, value);
    if (departmentValue != value) {
      return departmentValue;
    }
    switch (value) {
      case 'Summer Layers':
        return context.tr(value, 'طبقات الصيف');
      case 'Mini Trend Drop':
        return context.tr(value, 'صيحات صغيرة جديدة');
      case 'Office Reset':
        return context.tr(value, 'تجديد إطلالة المكتب');
      case 'Weekend Sale':
        return context.tr(value, 'تخفيضات نهاية الأسبوع');
      case 'Flash Sale':
        return context.tr(value, 'تخفيضات سريعة');
      case 'New Arrivals':
        return context.tr(value, 'وصل حديثاً');
      default:
        return value;
    }
  }

  void _quickAdd(BuildContext context, ProductModel product) {
    AuthRequiredHelper.guard(
      context,
      onAuthenticated: () async {
        final selection = await AppBottomSheet.showVariantSelector(
          context,
          colors: product.colors,
          sizes: product.sizes,
          maxQuantity: product.stock,
        );
        if (!context.mounted || selection == null) return;
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
