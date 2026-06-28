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
import '../../widgets/common/app_header.dart';
import '../../widgets/common/search_bar_widget.dart';
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
                LayoutBuilder(
                  builder: (context, constraints) {
                    final searchButton = SizedBox(
                      height: 46,
                      width: constraints.maxWidth < 420 ? double.infinity : 116,
                      child: FilledButton(
                        onPressed: () {
                          searchController.addRecentSearch(_controller.text);
                          searchController.search();
                        },
                        child: Text(context.tr('Search', 'بحث')),
                      ),
                    );

                    if (constraints.maxWidth < 420) {
                      return Column(
                        children: [
                          SearchBarWidget(
                            hintText: context.tr(
                              'Search dresses, shoes, beauty...',
                              'ابحث عن الفساتين والأحذية والجمال...',
                            ),
                            readOnly: false,
                            controller: _controller,
                            onChanged: searchController.setQuery,
                            trailing: IconButton(
                              onPressed: () {
                                _controller.clear();
                                searchController.clearQuery();
                              },
                              icon: const Icon(Icons.close),
                            ),
                          ),
                          const SizedBox(height: 8),
                          searchButton,
                        ],
                      );
                    }

                    return Row(
                      children: [
                        Expanded(
                          child: SearchBarWidget(
                            hintText: context.tr(
                              'Search dresses, shoes, beauty...',
                              'ابحث عن الفساتين والأحذية والجمال...',
                            ),
                            readOnly: false,
                            controller: _controller,
                            onChanged: searchController.setQuery,
                            trailing: IconButton(
                              onPressed: () {
                                _controller.clear();
                                searchController.clearQuery();
                              },
                              icon: const Icon(Icons.close),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        searchButton,
                      ],
                    );
                  },
                ),
                const SizedBox(height: AppSizes.md),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final filterButton = OutlinedButton.icon(
                      onPressed: () async {
                        final filters = await AppBottomSheet.showFilterOptions(
                          context,
                        );
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
                ),
                Expanded(
                  child: ListView(
                    children: [
                      if (searchController.query.isEmpty) ...[
                        _SearchSection(
                          title: context.tr(
                            'Recent searches',
                            'عمليات البحث الأخيرة',
                          ),
                        ),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: searchController.recentSearches
                              .map(
                                (item) => InputChip(
                                  label: Text(item),
                                  onPressed: () {
                                    _controller.text = item;
                                    searchController.setQuery(item);
                                    searchController.search();
                                  },
                                  onDeleted: () =>
                                      searchController.removeRecentSearch(item),
                                ),
                              )
                              .toList(),
                        ),
                        const SizedBox(height: AppSizes.lg),
                        _SearchSection(
                          title: context.tr(
                            'Hot searches',
                            'عمليات البحث الشائعة',
                          ),
                        ),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: searchController.hotSearches
                              .map(
                                (item) => ActionChip(
                                  label: Text(item),
                                  onPressed: () {
                                    _controller.text = item;
                                    searchController.setQuery(item);
                                    searchController.search();
                                  },
                                ),
                              )
                              .toList(),
                        ),
                      ] else if (searchController.results.isEmpty) ...[
                        const SizedBox(height: 60),
                        AppEmptyState(
                          title: context.tr('No results', 'لا توجد نتائج'),
                          message: context.tr(
                            'Try another keyword, category, or filter combination.',
                            'جرّب كلمة مختلفة أو فئة أخرى أو إعدادات تصفية مختلفة.',
                          ),
                        ),
                      ] else ...[
                        _SearchSection(
                          title: context.tr(
                            '${searchController.results.length} Results',
                            '${searchController.results.length} نتيجة',
                          ),
                        ),
                        LayoutBuilder(
                          builder: (context, constraints) {
                            const spacing = 10.0;
                            final cardWidth =
                                (constraints.maxWidth - spacing) / 2;
                            return GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: searchController.results.length,
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    mainAxisSpacing: 12,
                                    crossAxisSpacing: spacing,
                                    mainAxisExtent:
                                        ProductCard.mainAxisExtentForWidth(
                                          cardWidth,
                                          compact: true,
                                        ),
                                  ),
                              itemBuilder: (context, index) {
                                final product = searchController.results[index];
                                return ProductCard(
                                  product: product,
                                  compact: true,
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
                                      final added = wishlistController
                                          .toggleWishlist(product);
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
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
                                  onQuickAddTap: () async {
                                    await AuthRequiredHelper.guard(
                                      context,
                                      onAuthenticated: () async {
                                        final selection =
                                            await AppBottomSheet.showVariantSelector(
                                              context,
                                              colors: product.colors,
                                              sizes: product.sizes,
                                              maxQuantity: product.stock,
                                            );
                                        if (!context.mounted ||
                                            selection == null) {
                                          return;
                                        }
                                        final result = context
                                            .read<CartController>()
                                            .addToCart(
                                              product,
                                              selection['color'] as String,
                                              selection['size'] as String,
                                              selection['quantity'] as int,
                                            );
                                        CartActionFeedbackHelper.show(
                                          context,
                                          result,
                                        );
                                      },
                                    );
                                  },
                                );
                              },
                            );
                          },
                        ),
                      ],
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
