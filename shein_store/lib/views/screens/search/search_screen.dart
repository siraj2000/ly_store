import 'package:flutter/material.dart' hide SearchController;
import 'package:provider/provider.dart';

import '../../../controllers/cart_controller.dart';
import '../../../controllers/search_controller.dart';
import '../../../controllers/wishlist_controller.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/extensions/localization_extension.dart';
import '../../../core/helpers/cart_action_feedback_helper.dart';
import '../../../core/utils/auth_required_helper.dart';
import '../../../core/widgets/app_bottom_sheet.dart';
import '../../../core/widgets/app_empty_state.dart';
import '../../../models/product_model.dart';
import '../../../models/store_model.dart';
import '../../widgets/common/app_header.dart';
import '../../widgets/common/search_bar_widget.dart';
import '../../widgets/common/store_rating_stars.dart';
import '../../widgets/product/product_card.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<SearchController, WishlistController>(
      builder: (context, searchController, wishlistController, _) {
        if (_controller.text != searchController.query) {
          _controller.text = searchController.query;
          _controller.selection = TextSelection.fromPosition(
            TextPosition(offset: _controller.text.length),
          );
        }

        return Scaffold(
          appBar: AppHeader(title: context.tr('Search', 'البحث')),
          body: Padding(
            padding: const EdgeInsets.all(AppSizes.lg),
            child: Column(
              children: [
                _SearchInput(
                  controller: _controller,
                  searchController: searchController,
                ),
                const SizedBox(height: AppSizes.md),
                _SearchTools(searchController: searchController),
                const SizedBox(height: AppSizes.md),
                Expanded(
                  child: ListView(
                    children: [
                      if (searchController.query.trim().isEmpty)
                        _SearchLanding(
                          controller: _controller,
                          searchController: searchController,
                        )
                      else if (searchController.results.isEmpty &&
                          searchController.storeResults.isEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 56),
                          child: AppEmptyState(
                            title: context.tr(
                              'No results found',
                              'لا توجد نتائج',
                            ),
                            message: context.tr(
                              'Try a different keyword',
                              'جرّب كلمة بحث مختلفة',
                            ),
                          ),
                        )
                      else
                        _SearchResults(
                          products: searchController.results,
                          stores: searchController.storeResults,
                          wishlistController: wishlistController,
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SearchInput extends StatelessWidget {
  const _SearchInput({
    required this.controller,
    required this.searchController,
  });

  final TextEditingController controller;
  final SearchController searchController;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final searchButton = SizedBox(
          height: 46,
          width: constraints.maxWidth < 420 ? double.infinity : 116,
          child: FilledButton(
            onPressed: () {
              searchController.addRecentSearch(controller.text);
              searchController.search();
            },
            child: Text(context.tr('Search', 'بحث')),
          ),
        );
        final field = SearchBarWidget(
          hintText: context.tr(
            'Search products or stores...',
            'ابحث عن منتجات أو متاجر...',
          ),
          readOnly: false,
          controller: controller,
          onChanged: searchController.setQuery,
          trailing: IconButton(
            onPressed: () {
              controller.clear();
              searchController.clearQuery();
            },
            icon: const Icon(Icons.close),
          ),
        );

        if (constraints.maxWidth < 420) {
          return Column(
            children: [field, const SizedBox(height: 8), searchButton],
          );
        }

        return Row(
          children: [
            Expanded(child: field),
            const SizedBox(width: 8),
            searchButton,
          ],
        );
      },
    );
  }
}

class _SearchTools extends StatelessWidget {
  const _SearchTools({required this.searchController});

  final SearchController searchController;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final filterButton = OutlinedButton.icon(
          onPressed: () async {
            final filters = await AppBottomSheet.showFilterOptions(context);
            if (filters != null) {
              searchController.applyFilters(filters);
            }
          },
          icon: const Icon(Icons.filter_list),
          label: Text(context.tr('Filter', 'تصفية')),
        );
        final sortButton = OutlinedButton.icon(
          onPressed: () async {
            final sort = await AppBottomSheet.showSortOptions(
              context,
              selected: searchController.selectedSort,
            );
            if (sort != null) {
              searchController.applySort(value: sort);
            }
          },
          icon: const Icon(Icons.swap_vert),
          label: Text(context.tr('Sort', 'ترتيب')),
        );
        final clearButton = TextButton(
          onPressed: searchController.clearRecentSearches,
          child: Text(context.tr('Clear history', 'مسح السجل')),
        );

        if (constraints.maxWidth < 520) {
          return Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [filterButton, sortButton, clearButton],
          );
        }

        return Row(
          children: [
            filterButton,
            const SizedBox(width: 8),
            sortButton,
            const Spacer(),
            clearButton,
          ],
        );
      },
    );
  }
}

class _SearchLanding extends StatelessWidget {
  const _SearchLanding({
    required this.controller,
    required this.searchController,
  });

  final TextEditingController controller;
  final SearchController searchController;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SearchSection(
          title: context.tr('Recent searches', 'عمليات البحث الأخيرة'),
        ),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: searchController.recentSearches
              .map(
                (item) => InputChip(
                  label: Text(item),
                  onPressed: () {
                    controller.text = item;
                    searchController.setQuery(item);
                    searchController.search();
                  },
                  onDeleted: () => searchController.removeRecentSearch(item),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: AppSizes.lg),
        _SearchSection(
          title: context.tr('Hot searches', 'عمليات البحث الشائعة'),
        ),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: searchController.hotSearches
              .map(
                (item) => ActionChip(
                  label: Text(item),
                  onPressed: () {
                    controller.text = item;
                    searchController.setQuery(item);
                    searchController.search();
                  },
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

class _SearchResults extends StatelessWidget {
  const _SearchResults({
    required this.products,
    required this.stores,
    required this.wishlistController,
  });

  final List<ProductModel> products;
  final List<StoreModel> stores;
  final WishlistController wishlistController;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (stores.isNotEmpty) ...[
          _SearchSection(title: context.tr('Stores', 'المتاجر')),
          ...stores.map((store) => _SearchStoreCard(store: store)),
          const SizedBox(height: AppSizes.lg),
        ],
        if (products.isNotEmpty) ...[
          _SearchSection(title: context.tr('Products', 'المنتجات')),
          _SearchSection(
            title: context.tr(
              '${products.length} product results',
              '${products.length} نتيجة منتجات',
            ),
          ),
          LayoutBuilder(
            builder: (context, constraints) {
              const spacing = 10.0;
              final cardWidth = (constraints.maxWidth - spacing) / 2;
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: products.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: spacing,
                  mainAxisExtent: ProductCard.mainAxisExtentForWidth(
                    cardWidth,
                    compact: true,
                  ),
                ),
                itemBuilder: (context, index) => _SearchProductCard(
                  product: products[index],
                  wishlistController: wishlistController,
                ),
              );
            },
          ),
        ],
      ],
    );
  }
}

class _SearchProductCard extends StatelessWidget {
  const _SearchProductCard({
    required this.product,
    required this.wishlistController,
  });

  final ProductModel product;
  final WishlistController wishlistController;

  @override
  Widget build(BuildContext context) {
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
                    ? context.tr('Added to wishlist', 'تمت الإضافة إلى المفضلة')
                    : context.tr(
                        'Removed from wishlist',
                        'تمت الإزالة من المفضلة',
                      ),
              ),
            ),
          );
        },
      ),
      onQuickAddTap: () async {
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
      },
    );
  }
}

class _SearchStoreCard extends StatelessWidget {
  const _SearchStoreCard({required this.store});

  final StoreModel store;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final locale = Localizations.localeOf(context);
    final subtitleParts = [
      if (store.city.trim().isNotEmpty) store.city.trim(),
      if (store.businessActivityType.trim().isNotEmpty)
        store.businessActivityType.trim(),
    ];

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: () => _openStore(context),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: colors.border),
          ),
          child: Row(
            children: [
              Container(
                height: 54,
                width: 54,
                decoration: BoxDecoration(
                  color: colors.surfaceSoft,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(Icons.storefront_outlined, color: colors.accent),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      store.localizedName(locale),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: colors.primaryText,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (subtitleParts.isNotEmpty)
                      Text(
                        subtitleParts.join(' • '),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: colors.secondaryText),
                      ),
                    const SizedBox(height: 8),
                    StoreRatingStars(
                      rating: store.rating,
                      reviewCount: store.reviewCount,
                      compact: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              TextButton(
                onPressed: () => _openStore(context),
                child: Text(context.tr('Visit store', 'زيارة المتجر')),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openStore(BuildContext context) {
    Navigator.pushNamed(context, AppRoutes.storefront, arguments: store.id);
  }
}

class _SearchSection extends StatelessWidget {
  const _SearchSection({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 4),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w800,
          color: colors.primaryText,
        ),
      ),
    );
  }
}
