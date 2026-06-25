import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../controllers/cart_controller.dart';
import '../../../controllers/trend_controller.dart';
import '../../../controllers/wishlist_controller.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/extensions/localization_extension.dart';
import '../../../core/helpers/cart_action_feedback_helper.dart';
import '../../../core/utils/auth_required_helper.dart';
import '../../../core/widgets/app_bottom_sheet.dart';
import '../../../core/widgets/app_empty_state.dart';
import '../../../models/product_model.dart';
import '../../../models/trend_tag_model.dart';
import '../../widgets/trends/trend_filter_chips.dart';
import '../../widgets/trends/trend_filter_panel.dart';
import '../../widgets/trends/trend_header.dart';
import '../../widgets/trends/trend_main_tabs.dart';
import '../../widgets/trends/trend_product_grid.dart';
import '../../widgets/trends/trend_store_card.dart';
import '../../widgets/trends/trend_store_category_panel.dart';
import '../../widgets/trends/trend_store_filter_bar.dart';

class TrendsScreen extends StatefulWidget {
  const TrendsScreen({super.key});

  @override
  State<TrendsScreen> createState() => _TrendsScreenState();
}

class _TrendsScreenState extends State<TrendsScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _requestedInitialLoad = false;
  bool _searchExpanded = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<TrendController, WishlistController>(
      builder: (context, trendController, wishlistController, _) {
        if (!_requestedInitialLoad &&
            !trendController.initialized &&
            !trendController.isLoading) {
          _requestedInitialLoad = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) {
              return;
            }
            context.read<TrendController>().initialize();
          });
        }

        final colors = context.appColors;
        final campaigns = trendController.filteredCampaigns;
        final campaignIndex = campaigns.isEmpty
            ? 0
            : trendController.currentCampaignIndex.clamp(
                0,
                campaigns.length - 1,
              );
        final heroImage = campaigns.isEmpty
            ? ''
            : campaigns[campaignIndex].imageUrl;
        final products = trendController.getFilteredTrendingProducts();
        final stores = trendController.getFilteredTrendStores();
        final panelOpen =
            trendController.isFilterPanelOpen ||
            trendController.isCategoryPanelOpen;

        return Scaffold(
          backgroundColor: colors.background,
          body: SafeArea(
            bottom: false,
            child: Column(
              children: [
                TrendHeader(
                  searchController: _searchController,
                  searchHint: context.l10n.trendsSearchHint,
                  campaigns: campaigns,
                  currentCampaignIndex: campaignIndex,
                  heroImageUrl: heroImage,
                  shopNowLabel: context.l10n.trendsCampaignShopNow,
                  searchExpanded: _searchExpanded,
                  onSearchChanged: trendController.setSearchQuery,
                  onWishlistTap: () => AuthRequiredHelper.guard(
                    context,
                    onAuthenticated: () async {
                      Navigator.pushNamed(context, AppRoutes.wishlist);
                    },
                  ),
                  onSearchTap: () {
                    FocusScope.of(context).unfocus();
                    trendController.setSearchQuery(_searchController.text);
                  },
                  onToggleSearch: () {
                    setState(() {
                      _searchExpanded = !_searchExpanded;
                    });
                    if (!_searchExpanded) {
                      FocusScope.of(context).unfocus();
                    }
                  },
                  onCampaignPageChanged:
                      trendController.setCurrentCampaignIndex,
                  onCampaignTap: trendController.openCampaign,
                  productsForCampaign: trendController.campaignProducts,
                ),
                Expanded(
                  child: Transform.translate(
                    offset: const Offset(0, -20),
                    child: Stack(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: context.isDarkMode
                                ? colors.card
                                : colors.surface,
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(30),
                            ),
                            boxShadow: context.isDarkMode
                                ? null
                                : [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.06,
                                      ),
                                      blurRadius: 18,
                                      offset: const Offset(0, -4),
                                    ),
                                  ],
                          ),
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.fromLTRB(16, 12, 16, 140),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                TrendMainTabs(
                                  selectedTab: trendController.selectedMainTab,
                                  trendingPicksLabel:
                                      context.l10n.trendsTrendingPicks,
                                  trendsStoreLabel: context.l10n.trendsStore,
                                  onSelected: trendController.selectMainTab,
                                ),
                                const SizedBox(height: 12),
                                if (trendController.selectedMainTab ==
                                    TrendMainTab.trendingPicks) ...[
                                  TrendFilterChips(
                                    labels: trendController.visibleFilterTags
                                        .map((tag) => tag.id)
                                        .toList(),
                                    selectedId:
                                        trendController.selectedTrendTagId,
                                    labelForId: (id) => _labelForTagId(
                                      context,
                                      trendController,
                                      id,
                                    ),
                                    onSelected: trendController.selectTrendTag,
                                    onOpenFilter:
                                        trendController.toggleFilterPanel,
                                  ),
                                  const SizedBox(height: 16),
                                  TrendProductGrid(
                                    products: products,
                                    emptyTitle: context.l10n.trendsNoProducts,
                                    emptyMessage: context.l10n.trendsNoResults,
                                    tagLabelForProduct: (product) =>
                                        _tagLabelForProduct(
                                          context,
                                          trendController,
                                          product,
                                        ),
                                    isWishlisted:
                                        wishlistController.isWishlisted,
                                    onProductTap: (product) =>
                                        Navigator.pushNamed(
                                          context,
                                          AppRoutes.productDetails,
                                          arguments: product.id,
                                        ),
                                    onWishlistTap: (product) =>
                                        AuthRequiredHelper.guard(
                                          context,
                                          onAuthenticated: () async {
                                            wishlistController.toggleWishlist(
                                              product,
                                            );
                                          },
                                        ),
                                    onQuickAddTap: (product) async {
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
                                    onStoreTap: (product) =>
                                        Navigator.pushNamed(
                                          context,
                                          AppRoutes.storefront,
                                          arguments: product.storeId,
                                        ),
                                  ),
                                ] else ...[
                                  TrendStoreFilterBar(
                                    categoryLabel: context.l10n.trendsCategory,
                                    selectedCategoryLabel:
                                        trendController
                                            .selectedStoreCategory
                                            ?.labelText
                                            .valueFor(
                                              Localizations.localeOf(context),
                                            ) ??
                                        context.l10n.trendsAll,
                                    newLabel: context.l10n.trendsNew,
                                    isNewOnly: trendController.isNewOnly,
                                    onCategoryTap:
                                        trendController.toggleCategoryPanel,
                                    onNewTap: trendController.toggleNewOnly,
                                  ),
                                  const SizedBox(height: 16),
                                  if (stores.isEmpty)
                                    AppEmptyState(
                                      title: context.l10n.trendsNoStores,
                                      message: context.l10n.trendsNoResults,
                                    )
                                  else
                                    Column(
                                      children: stores.map((section) {
                                        final store = trendController.storeById(
                                          section.storeId,
                                        );
                                        if (store == null) {
                                          return const SizedBox.shrink();
                                        }
                                        final storeProducts = trendController
                                            .getProductsForStore(store.id)
                                            .take(4)
                                            .toList();
                                        if (storeProducts.isEmpty) {
                                          return const SizedBox.shrink();
                                        }
                                        final hashtags = section.trendTagIds
                                            .map(
                                              (id) => _labelForTagId(
                                                context,
                                                trendController,
                                                id,
                                              ),
                                            )
                                            .toList();
                                        return Padding(
                                          padding: const EdgeInsets.only(
                                            bottom: 14,
                                          ),
                                          child: TrendStoreCard(
                                            store: store,
                                            section: section,
                                            hashtags: hashtags,
                                            products: storeProducts,
                                            newLabel: context
                                                .l10n
                                                .trendsStoreNewBadge,
                                            trendingLabel: context
                                                .l10n
                                                .trendsStoreTrendingBadge,
                                            followersLabel:
                                                context.l10n.trendsFollowers,
                                            soldLabel:
                                                context.l10n.trendsSoldCount,
                                            viewStoreLabel:
                                                context.l10n.trendsViewStore,
                                            onStoreTap: () =>
                                                Navigator.pushNamed(
                                                  context,
                                                  AppRoutes.storefront,
                                                  arguments: store.id,
                                                ),
                                            onProductTap: (product) =>
                                                Navigator.pushNamed(
                                                  context,
                                                  AppRoutes.productDetails,
                                                  arguments: product.id,
                                                ),
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                ],
                              ],
                            ),
                          ),
                        ),
                        if (panelOpen)
                          Positioned.fill(
                            child: GestureDetector(
                              onTap: trendController.closePanels,
                              child: Container(
                                color: Colors.black.withValues(alpha: 0.26),
                              ),
                            ),
                          ),
                        if (trendController.isFilterPanelOpen)
                          Positioned(
                            top: 74,
                            left: 16,
                            right: 16,
                            child: TrendFilterPanel(
                              title: context.l10n.trendsFilter,
                              closeLabel: context.l10n.trendsCloseFilter,
                              selectedId: trendController.selectedTrendTagId,
                              options: trendController.visibleFilterTags
                                  .map((tag) => tag.id)
                                  .toList(),
                              labelForId: (id) =>
                                  _labelForTagId(context, trendController, id),
                              onSelected: trendController.selectTrendTag,
                              onClose: trendController.closePanels,
                            ),
                          ),
                        if (trendController.isCategoryPanelOpen)
                          Positioned(
                            top: 74,
                            left: 16,
                            right: 16,
                            child: TrendStoreCategoryPanel(
                              title: context.l10n.trendsCategory,
                              options: trendController.storeCategories,
                              selectedId:
                                  trendController.selectedStoreCategoryId,
                              labelForOption: (option) => option.labelText
                                  .valueFor(Localizations.localeOf(context)),
                              onSelected: trendController.selectStoreCategory,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _labelForTagId(
    BuildContext context,
    TrendController controller,
    String id,
  ) {
    for (final tag in controller.visibleFilterTags) {
      if (tag.id == id) {
        return tag.localizedLabelText?.valueFor(
              Localizations.localeOf(context),
            ) ??
            tag.label;
      }
    }
    return id;
  }

  String _tagLabelForProduct(
    BuildContext context,
    TrendController controller,
    ProductModel product,
  ) {
    if (controller.selectedTrendTagId != 'for_you') {
      return _labelForTagId(context, controller, controller.selectedTrendTagId);
    }

    for (final TrendTagModel tag in controller.visibleFilterTags) {
      if (tag.id == 'for_you') {
        continue;
      }
      if (tag.productIds.contains(product.id)) {
        return tag.localizedLabelText?.valueFor(
              Localizations.localeOf(context),
            ) ??
            tag.label;
      }
    }

    return '#${product.categoryName.replaceAll(' ', '')}';
  }
}
