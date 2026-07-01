import 'package:flutter/material.dart' hide SearchController;
import 'package:provider/provider.dart';

import '../../../controllers/auth_controller.dart';
import '../../../controllers/cart_controller.dart';
import '../../../controllers/category_controller.dart';
import '../../../controllers/notification_controller.dart';
import '../../../controllers/product_controller.dart';
import '../../../controllers/search_controller.dart';
import '../../../controllers/wishlist_controller.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/extensions/localization_extension.dart';
import '../../../core/helpers/cart_action_feedback_helper.dart';
import '../../../core/utils/auth_required_helper.dart';
import '../../../core/widgets/app_bottom_sheet.dart';
import '../../../core/widgets/app_loading.dart';
import '../../../models/category_model.dart';
import '../../../models/product_model.dart';
import '../../widgets/product/product_card.dart';
import '../../widgets/shop/category_image_item.dart';
import '../../widgets/shop/promo_banner.dart';

class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  final PageController _pageController = PageController(viewportFraction: 0.94);
  final TextEditingController _homeSearchController = TextEditingController();

  int _bannerIndex = 0;
  String _selectedDepartmentId = 'all';
  String _selectedFeedTab = 'for_you';
  String? _selectedHomeCategoryId;
  bool _openedSearchFromTyping = false;

  static const List<String> _departments = [
    'all',
    'women',
    'shoes',
    'men',
    'curve',
    'kids',
    'jewelry',
  ];

  static const List<({String title, String subtitle})> _bannerCampaigns = [
    (
      title: 'Summer Layers',
      subtitle:
          'Polished everyday pieces with softer prices and faster styling wins.',
    ),
    (
      title: 'Mini Trend Drop',
      subtitle:
          'Fresh edits for kids, denim, and weekend outfits in one sweep.',
    ),
    (
      title: 'Office Reset',
      subtitle:
          'Sharp essentials, easy tailoring, and clean accessories for daily wear.',
    ),
    (
      title: 'Weekend Sale',
      subtitle: 'Shop markdowns on dresses, shoes, and carry-everywhere bags.',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    _homeSearchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Consumer4<
      ProductController,
      WishlistController,
      AuthController,
      CategoryController
    >(
      builder:
          (
            context,
            productController,
            wishlistController,
            authController,
            categoryController,
            _,
          ) {
            if (productController.isLoading) {
              return Scaffold(
                backgroundColor: colors.background,
                body: AppLoading(
                  layout: AppLoadingLayout.marketplace,
                  message: context.tr(
                    'Loading storefront...',
                    'جارٍ تحميل واجهة التسوق...',
                  ),
                ),
              );
            }

            final departmentId = _selectedDepartmentId == 'all'
                ? null
                : _selectedDepartmentId;
            final categoryItems = categoryController.categoriesForHomePreview();
            final feedProducts = _productsForFeed(
              productController,
              departmentId: departmentId,
            ).take(24).toList();

            return Scaffold(
              backgroundColor: colors.background,
              body: SafeArea(
                bottom: false,
                child: RefreshIndicator(
                  onRefresh: productController.loadInitialData,
                  child: CustomScrollView(
                    slivers: [
                      SliverPadding(
                        padding: EdgeInsetsDirectional.fromSTEB(
                          12,
                          8,
                          12,
                          MediaQuery.paddingOf(context).bottom + 12,
                        ),
                        sliver: SliverList(
                          delegate: SliverChildListDelegate([
                            _buildSlimTopSearchHeader(
                              context,
                              authController: authController,
                            ),
                            const SizedBox(height: 10),
                            _buildPolishedDepartmentNavigation(context),
                            const SizedBox(height: 10),
                            _buildHeroCarousel(context),
                            const SizedBox(height: 10),
                            _buildServiceStrip(context),
                            const SizedBox(height: 14),
                            _buildCategoryGrid(context, categoryItems),
                            const SizedBox(height: 16),
                            _buildFeedTabs(context),
                            const SizedBox(height: 10),
                          ]),
                        ),
                      ),
                      SliverPadding(
                        padding: const EdgeInsetsDirectional.fromSTEB(
                          12,
                          0,
                          12,
                          0,
                        ),
                        sliver: _HomeProductGridSliver(
                          products: feedProducts,
                          wishlistController: wishlistController,
                          onQuickAdd: _handleQuickAdd,
                          onWishlist: (product) =>
                              _handleWishlist(product, wishlistController),
                        ),
                      ),
                      const SliverToBoxAdapter(child: SizedBox(height: 16)),
                    ],
                  ),
                ),
              ),
            );
          },
    );
  }

  List<ProductModel> _productsForFeed(
    ProductController productController, {
    String? departmentId,
  }) {
    final source = switch (_selectedFeedTab) {
      'new_in' => productController.newest(departmentId),
      'deals' => productController.deals(departmentId),
      'bestsellers' => productController.bestSellers(departmentId),
      _ => productController.forYou(departmentId),
    };

    if (_selectedHomeCategoryId == null) {
      return source;
    }

    return source
        .where((product) => product.categoryId == _selectedHomeCategoryId)
        .toList();
  }

  // Kept as a fallback reference while the polished shop header is active.
  // ignore: unused_element
  Widget _buildTopSearchHeader(
    BuildContext context, {
    required AuthController authController,
  }) {
    final colors = context.appColors;

    return Row(
      children: [
        const SizedBox.shrink(),
        IconButton(
          tooltip: context.tr('Orders', 'الطلبات'),
          onPressed: () {
            if (authController.isGuest) {
              AppBottomSheet.showAuthRequired(context);
            } else {
              Navigator.pushNamed(context, AppRoutes.orders);
            }
          },
          icon: const Icon(Icons.calendar_today_outlined),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Container(
            height: 42,
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: colors.border),
            ),
            child: Row(
              children: [
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _homeSearchController,
                    textInputAction: TextInputAction.search,
                    onSubmitted: (_) => _runHeaderSearch(context),
                    decoration: InputDecoration(
                      isCollapsed: true,
                      border: InputBorder.none,
                      hintText: context.tr(
                        'Search dresses, shoes, beauty...',
                        'ابحث عن فساتين وأحذية وجمال...',
                      ),
                      hintStyle: TextStyle(color: colors.secondaryText),
                    ),
                    style: TextStyle(color: colors.primaryText),
                  ),
                ),
                IconButton(
                  tooltip: context.tr('Image search', 'البحث بالصور'),
                  onPressed: () => _openImageSearchInfo(context),
                  icon: const Icon(Icons.camera_alt_outlined),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 6),
        SizedBox(
          height: 42,
          child: FilledButton(
            onPressed: () => _runHeaderSearch(context),
            style: FilledButton.styleFrom(
              minimumSize: Size.zero,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Icon(Icons.search, size: 18),
          ),
        ),
        const SizedBox(width: 4),
        IconButton(
          tooltip: context.tr('Wishlist', 'المفضلة'),
          onPressed: () {
            if (authController.isGuest) {
              AppBottomSheet.showAuthRequired(context);
            } else {
              Navigator.pushNamed(context, AppRoutes.wishlist);
            }
          },
          icon: const Icon(Icons.favorite_border),
        ),
      ],
    );
  }

  Widget _buildSlimTopSearchHeader(
    BuildContext context, {
    required AuthController authController,
  }) {
    final colors = context.appColors;

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          _shopHeaderIconButton(
            context,
            tooltip: context.tr('Shop Menu', 'قائمة التسوق'),
            icon: Icons.menu_rounded,
            onPressed: _openShopMenu,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                color: colors.background,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: colors.border),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 14),
                  Expanded(
                    child: TextField(
                      controller: _homeSearchController,
                      textAlignVertical: TextAlignVertical.center,
                      textInputAction: TextInputAction.search,
                      onChanged: (value) =>
                          _handleHeaderSearchTyping(context, value),
                      onSubmitted: (_) => _runHeaderSearch(context),
                      decoration: InputDecoration(
                        isDense: true,
                        border: InputBorder.none,
                        hintText: context.tr(
                          'Search fashion, beauty, home...',
                          'ابحث عن أزياء وجمال ومنزل...',
                        ),
                        hintStyle: TextStyle(
                          color: colors.secondaryText,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: TextStyle(
                        color: colors.primaryText,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: context.tr('Image search', 'البحث بالصور'),
                    onPressed: () => _openImageSearchInfo(context),
                    icon: const Icon(Icons.camera_alt_outlined),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          _shopHeaderNotificationButton(context),
          const SizedBox(width: 6),
          _shopHeaderIconButton(
            context,
            tooltip: context.tr('Wishlist', 'المفضلة'),
            icon: Icons.favorite_border,
            onPressed: () {
              if (authController.isGuest) {
                AppBottomSheet.showAuthRequired(context);
              } else {
                Navigator.pushNamed(context, AppRoutes.wishlist);
              }
            },
          ),
        ],
      ),
    );
  }

  // Kept as a fallback reference while the slim shop header is active.
  // ignore: unused_element
  Widget _buildPolishedTopSearchHeader(
    BuildContext context, {
    required AuthController authController,
  }) {
    final colors = context.appColors;

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          _shopHeaderIconButton(
            context,
            tooltip: context.tr('Shop Menu', 'قائمة التسوق'),
            icon: Icons.menu_rounded,
            onPressed: _openShopMenu,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: colors.background,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: colors.border),
              ),
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsetsDirectional.only(start: 14),
                    child: Icon(
                      Icons.search_rounded,
                      size: 22,
                      color: colors.secondaryText,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _homeSearchController,
                      textAlignVertical: TextAlignVertical.center,
                      textInputAction: TextInputAction.search,
                      onChanged: (value) =>
                          _handleHeaderSearchTyping(context, value),
                      onSubmitted: (_) => _runHeaderSearch(context),
                      decoration: InputDecoration(
                        isDense: true,
                        border: InputBorder.none,
                        hintText: context.tr(
                          'Search fashion, beauty, home...',
                          'ابحث عن أزياء وجمال ومنزل...',
                        ),
                        hintStyle: TextStyle(
                          color: colors.secondaryText,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: TextStyle(
                        color: colors.primaryText,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: context.tr('Image search', 'البحث بالصور'),
                    onPressed: () => _openImageSearchInfo(context),
                    icon: const Icon(Icons.camera_alt_outlined),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          _shopHeaderIconButton(
            context,
            tooltip: context.tr('Orders', 'الطلبات'),
            icon: Icons.calendar_today_outlined,
            onPressed: () {
              if (authController.isGuest) {
                AppBottomSheet.showAuthRequired(context);
              } else {
                Navigator.pushNamed(context, AppRoutes.orders);
              }
            },
          ),
          const SizedBox(width: 6),
          const SizedBox.shrink(),
          const SizedBox(width: 6),
          _shopHeaderIconButton(
            context,
            tooltip: context.tr('Wishlist', 'المفضلة'),
            icon: Icons.favorite_border,
            onPressed: () {
              if (authController.isGuest) {
                AppBottomSheet.showAuthRequired(context);
              } else {
                Navigator.pushNamed(context, AppRoutes.wishlist);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _shopHeaderIconButton(
    BuildContext context, {
    required String tooltip,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return _shopHeaderIconShell(
      context,
      child: IconButton(
        tooltip: tooltip,
        onPressed: onPressed,
        icon: Icon(icon),
      ),
    );
  }

  Widget _shopHeaderIconShell(BuildContext context, {required Widget child}) {
    final colors = context.appColors;

    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.border),
      ),
      alignment: Alignment.center,
      child: child,
    );
  }

  Widget _shopHeaderNotificationButton(BuildContext context) {
    final colors = context.appColors;

    return Selector<NotificationController, int>(
      selector: (_, controller) => controller.unreadCount,
      builder: (context, unreadCount, _) {
        final label = unreadCount > 99 ? '99+' : '$unreadCount';

        return InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => Navigator.pushNamed(context, AppRoutes.notifications),
          child: SizedBox(
            width: 50,
            height: 50,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Center(
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: colors.background,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: colors.border),
                    ),
                    child: Icon(
                      Icons.notifications_none_outlined,
                      color: colors.primaryText,
                    ),
                  ),
                ),
                if (unreadCount > 0)
                  PositionedDirectional(
                    top: 0,
                    end: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 3,
                      ),
                      constraints: const BoxConstraints(minWidth: 22),
                      decoration: BoxDecoration(
                        color: colors.discount,
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: colors.surface, width: 2),
                      ),
                      child: Text(
                        label,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                        ),
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

  void _runHeaderSearch(BuildContext context) {
    final controller = context.read<SearchController>();
    final query = _homeSearchController.text.trim();

    if (query.isNotEmpty) {
      controller.setQuery(query);
      controller.addRecentSearch(query);
      controller.search();
    }

    Navigator.pushNamed(context, AppRoutes.search);
  }

  void _handleHeaderSearchTyping(BuildContext context, String value) {
    final query = value.trim();
    final controller = context.read<SearchController>();
    controller.setQuery(query);

    if (query.isEmpty || _openedSearchFromTyping) {
      return;
    }

    _openedSearchFromTyping = true;
    controller.addRecentSearch(query);
    controller.search();
    Navigator.pushNamed(context, AppRoutes.search).whenComplete(() {
      if (mounted) {
        _openedSearchFromTyping = false;
      }
    });
  }

  void _openImageSearchInfo(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.tr('Image search', 'البحث بالصور')),
        content: Text(
          context.tr(
            'Image search is not enabled in this local demo yet. It is prepared for future API integration.',
            'البحث بالصور غير مفعل في نسخة الديمو المحلية حالياً، لكنه جاهز للربط مع الواجهة البرمجية لاحقاً.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(context.tr('Close', 'إغلاق')),
          ),
        ],
      ),
    );
  }

  // Kept as a fallback reference while the polished department chips are active.
  // ignore: unused_element
  Widget _buildDepartmentNavigation(BuildContext context) {
    final colors = context.appColors;

    return SizedBox(
      height: 32,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _departments.length + 1,
        separatorBuilder: (_, _) => const SizedBox(width: 14),
        itemBuilder: (context, index) {
          if (index == _departments.length) {
            return InkWell(
              onTap: _openShopMenu,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: Icon(
                  Icons.menu_rounded,
                  size: 20,
                  color: colors.primaryText,
                ),
              ),
            );
          }

          final id = _departments[index];
          final isSelected = _selectedDepartmentId == id;

          return InkWell(
            onTap: () {
              setState(() {
                _selectedDepartmentId = id;
                _selectedHomeCategoryId = null;
              });
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _localizedDepartmentNavLabel(context, id),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                    color: colors.primaryText,
                  ),
                ),
                const SizedBox(height: 4),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: isSelected ? 18 : 0,
                  height: 2.5,
                  decoration: BoxDecoration(
                    color: colors.primaryText,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPolishedDepartmentNavigation(BuildContext context) {
    final colors = context.appColors;

    return SizedBox(
      height: 42,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _departments.length + 1,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          if (index == _departments.length) {
            return _departmentMenuChip(
              context,
              label: context.tr('More', 'المزيد'),
              onTap: _openShopMenu,
            );
          }

          final id = _departments[index];
          final isSelected = _selectedDepartmentId == id;

          return InkWell(
            borderRadius: BorderRadius.circular(999),
            onTap: () {
              setState(() {
                _selectedDepartmentId = id;
                _selectedHomeCategoryId = null;
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: isSelected ? colors.primaryText : colors.surface,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: isSelected ? colors.primaryText : colors.border,
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                _localizedDepartmentNavLabel(context, id),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: isSelected ? colors.surface : colors.primaryText,
                  fontWeight: FontWeight.w900,
                  fontSize: 13,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _departmentMenuChip(
    BuildContext context, {
    required String label,
    required VoidCallback onTap,
  }) {
    final colors = context.appColors;

    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: colors.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.menu_rounded, size: 18, color: colors.primaryText),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: colors.primaryText,
                fontWeight: FontWeight.w900,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _localizedDepartmentNavLabel(BuildContext context, String id) {
    switch (id) {
      case 'all':
        return context.l10n.statusAll;
      case 'women':
        return context.tr('Women', 'النساء');
      case 'shoes':
        return context.tr('Shoes', 'الأحذية');
      case 'men':
        return context.tr('Men', 'الرجال');
      case 'curve':
        return context.tr('Curve', 'كيرف');
      case 'kids':
        return context.tr('Kids', 'الأطفال');
      case 'jewelry':
        return context.tr('Jewelry', 'المجوهرات');
      default:
        return id;
    }
  }

  Widget _buildHeroCarousel(BuildContext context) {
    final colors = context.appColors;

    return LayoutBuilder(
      builder: (context, constraints) {
        final heroHeight = (constraints.maxWidth * 0.48).clamp(150.0, 190.0);

        return Column(
          children: [
            SizedBox(
              height: heroHeight,
              child: PageView.builder(
                controller: _pageController,
                itemCount: _bannerCampaigns.length,
                onPageChanged: (value) => setState(() => _bannerIndex = value),
                itemBuilder: (context, index) {
                  final item = _bannerCampaigns[index];
                  return Padding(
                    padding: const EdgeInsetsDirectional.only(end: 8),
                    child: PromoBanner(
                      title: _localizedCampaignTitle(context, item.title),
                      subtitle: _localizedCampaignSubtitle(
                        context,
                        item.title,
                        item.subtitle,
                      ),
                      onTap: () => Navigator.pushNamed(
                        context,
                        AppRoutes.productListing,
                        arguments: {
                          'title': item.title,
                          'campaignTag': 'Campaign',
                          if (_selectedDepartmentId != 'all')
                            'department': _selectedDepartmentId,
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _bannerCampaigns.length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: _bannerIndex == index ? 18 : 6,
                  height: 6,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  decoration: BoxDecoration(
                    color: _bannerIndex == index
                        ? colors.primaryText
                        : colors.inactiveIcon.withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildServiceStrip(BuildContext context) {
    final colors = context.appColors;

    return Container(
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: () => showDialog<void>(
                context: context,
                builder: (dialogContext) => AlertDialog(
                  title: Text(context.tr('Free Shipping', 'شحن مجاني')),
                  content: Text(
                    context.tr(
                      'Buy 129.00 or more to unlock free shipping.',
                      'اشترِ بقيمة 129.00 أو أكثر للحصول على شحن مجاني.',
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(dialogContext),
                      child: Text(context.tr('Close', 'إغلاق')),
                    ),
                  ],
                ),
              ),
              child: _ServiceStripItem(
                icon: Icons.local_shipping_outlined,
                title: context.tr('Free Shipping', 'شحن مجاني'),
                subtitle: context.tr(
                  'Buy 129.00 or more',
                  'عند الشراء بقيمة 129.00 أو أكثر',
                ),
              ),
            ),
          ),
          Container(width: 1, height: 52, color: colors.border),
          Expanded(
            child: InkWell(
              onTap: () => Navigator.pushNamed(
                context,
                AppRoutes.productListing,
                arguments: {
                  'title': context.tr('Flash Sale', 'عروض سريعة'),
                  'campaignTag': 'Sale',
                },
              ),
              child: _ServiceStripItem(
                icon: Icons.flash_on_outlined,
                title: context.tr('Flash Sale', 'عروض سريعة'),
                subtitle: context.tr('View more', 'عرض المزيد'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryGrid(
    BuildContext context,
    List<CategoryModel> categories,
  ) {
    final locale = Localizations.localeOf(context);

    return SizedBox(
      height: 224,
      child: GridView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        padding: const EdgeInsets.symmetric(horizontal: 2),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          mainAxisExtent: 92,
        ),
        itemBuilder: (context, index) {
          final category = categories[index];
          return CategoryImageItem(
            category: category,
            localizedName: category.localizedName(locale),
            selected: _selectedHomeCategoryId == category.id,
            onTap: () {
              setState(() => _selectedHomeCategoryId = category.id);
              Navigator.pushNamed(
                context,
                AppRoutes.productListing,
                arguments: {
                  'title': category.localizedName(locale),
                  'categoryId': category.id,
                  'department': category.departmentId,
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildFeedTabs(BuildContext context) {
    final colors = context.appColors;
    final tabs = [
      ('for_you', context.tr('For You', 'لك')),
      ('new_in', context.tr('New In', 'جديدنا')),
      ('deals', context.tr('Deals', 'العروض')),
      ('bestsellers', context.tr('Bestsellers', 'الأكثر مبيعاً')),
    ];

    return Container(
      height: 38,
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: colors.border),
      ),
      child: Row(
        children: tabs.map((tab) {
          final isActive = _selectedFeedTab == tab.$1;
          return Expanded(
            child: InkWell(
              onTap: () => setState(() => _selectedFeedTab = tab.$1),
              borderRadius: BorderRadius.circular(9),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                margin: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: isActive ? colors.primaryText : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: Text(
                  tab.$2,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: isActive
                        ? (context.isDarkMode
                              ? colors.background
                              : colors.surface)
                        : colors.primaryText,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  List<_ShortcutItem> _shortcutItems(BuildContext context) => [
    _ShortcutItem(
      context.tr('Sale', 'تخفيضات'),
      Icons.local_fire_department_outlined,
    ),
    _ShortcutItem(context.tr('Coupons', 'كوبونات'), Icons.local_offer_outlined),
    _ShortcutItem(context.tr('New In', 'جديدنا'), Icons.fiber_new_outlined),
    _ShortcutItem(
      context.tr('Best Sellers', 'الأكثر مبيعاً'),
      Icons.workspace_premium_outlined,
    ),
  ];

  String _localizedCampaignTitle(BuildContext context, String title) {
    switch (title) {
      case 'Summer Layers':
        return context.tr('Summer Layers', 'طبقات الصيف');
      case 'Mini Trend Drop':
        return context.tr('Mini Trend Drop', 'صيحات صغيرة جديدة');
      case 'Office Reset':
        return context.tr('Office Reset', 'تجديد إطلالة المكتب');
      case 'Weekend Sale':
        return context.tr('Weekend Sale', 'تخفيضات نهاية الأسبوع');
      default:
        return title;
    }
  }

  String _localizedCampaignSubtitle(
    BuildContext context,
    String title,
    String fallback,
  ) {
    switch (title) {
      case 'Summer Layers':
        return context.tr(
          fallback,
          'قطع يومية أنيقة بأسعار ألطف ولمسات تنسيق أسرع.',
        );
      case 'Mini Trend Drop':
        return context.tr(
          fallback,
          'اختيارات جديدة للأطفال والدنيم وإطلالات نهاية الأسبوع في مكان واحد.',
        );
      case 'Office Reset':
        return context.tr(
          fallback,
          'أساسيات حادة وتفصيل سهل وإكسسوارات نظيفة للارتداء اليومي.',
        );
      case 'Weekend Sale':
        return context.tr(
          fallback,
          'تسوقي التخفيضات على الفساتين والأحذية والحقائب اليومية.',
        );
      default:
        return fallback;
    }
  }

  void _handleShortcutTap(_ShortcutItem item) {
    if (item.label == 'Coupons' || item.label == 'كوبونات') {
      AuthRequiredHelper.guard(
        context,
        onAuthenticated: () => Navigator.pushNamed(context, AppRoutes.coupons),
      );
      return;
    }

    if (item.label == 'New In' || item.label == 'جديدنا') {
      setState(() => _selectedFeedTab = 'new_in');
      return;
    }

    if (item.label == 'Best Sellers' || item.label == 'الأكثر مبيعاً') {
      setState(() => _selectedFeedTab = 'bestsellers');
      return;
    }

    Navigator.pushNamed(
      context,
      AppRoutes.productListing,
      arguments: {
        'title': item.label,
        if (item.label == 'Sale' || item.label == 'تخفيضات')
          'campaignTag': 'Sale',
      },
    );
  }

  void _openShopMenu() {
    final colors = context.appColors;
    final locale = Localizations.localeOf(context);
    final shortcuts = _shortcutItems(context);
    final categories = context
        .read<CategoryController>()
        .categoriesForHomePreview();

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: colors.surface,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.tr('Shop Menu', 'قائمة التسوق'),
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: colors.primaryText,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  context.tr(
                    'Open shortcuts and browse departments from one place.',
                    'افتح الاختصارات وتصفح الأقسام من مكان واحد.',
                  ),
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.4,
                    color: colors.secondaryText,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  context.tr('Quick Actions', 'إجراءات سريعة'),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: colors.primaryText,
                  ),
                ),
                const SizedBox(height: 10),
                ...shortcuts.map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: ListTile(
                      tileColor: colors.surfaceSoft,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                        side: BorderSide(color: colors.border),
                      ),
                      leading: Icon(item.icon, color: colors.icon),
                      title: Text(
                        item.label,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: colors.primaryText,
                        ),
                      ),
                      trailing: Icon(
                        Directionality.of(context) == TextDirection.rtl
                            ? Icons.arrow_back_ios_new_rounded
                            : Icons.arrow_forward_ios_rounded,
                        size: 16,
                        color: colors.inactiveIcon,
                      ),
                      onTap: () {
                        Navigator.pop(sheetContext);
                        _handleShortcutTap(item);
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        context.tr('Categories', 'الفئات'),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: colors.primaryText,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(sheetContext);
                        Navigator.pushNamed(context, AppRoutes.categories);
                      },
                      child: Text(context.tr('View All', 'عرض الكل')),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: categories
                      .map(
                        (category) => ActionChip(
                          side: BorderSide(color: colors.border),
                          backgroundColor: colors.surfaceSoft,
                          labelStyle: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: colors.primaryText,
                          ),
                          label: Text(category.localizedName(locale)),
                          onPressed: () {
                            Navigator.pop(sheetContext);
                            Navigator.pushNamed(
                              context,
                              AppRoutes.productListing,
                              arguments: {
                                'title': category.localizedName(locale),
                                'categoryId': category.id,
                                'department': category.departmentId,
                              },
                            );
                          },
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _handleWishlist(
    ProductModel product,
    WishlistController wishlistController,
  ) {
    AuthRequiredHelper.guard(
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
    );
  }

  void _handleQuickAdd(ProductModel product) {
    AuthRequiredHelper.guard(
      context,
      onAuthenticated: () async {
        final selection = await AppBottomSheet.showVariantSelector(
          context,
          colors: product.colors,
          sizes: product.sizes,
          variants: product.variants,
          maxQuantity: product.stock,
        );
        if (!mounted || selection == null) {
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

class _HomeProductGridSliver extends StatelessWidget {
  const _HomeProductGridSliver({
    required this.products,
    required this.wishlistController,
    required this.onQuickAdd,
    required this.onWishlist,
  });

  final List<ProductModel> products;
  final WishlistController wishlistController;
  final ValueChanged<ProductModel> onQuickAdd;
  final ValueChanged<ProductModel> onWishlist;

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) {
      final colors = context.appColors;
      return SliverToBoxAdapter(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 26),
          decoration: BoxDecoration(
            color: colors.card,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: colors.border),
          ),
          child: Column(
            children: [
              Icon(Icons.inbox_outlined, size: 36, color: colors.inactiveIcon),
              const SizedBox(height: 10),
              Text(
                context.tr(
                  'No products found in this category.',
                  'لا توجد منتجات في هذه الفئة حالياً.',
                ),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: colors.primaryText,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SliverLayoutBuilder(
      builder: (context, constraints) {
        const spacing = 10.0;
        final crossAxisCount = _gridCrossAxisCount(constraints.crossAxisExtent);
        final cardWidth =
            (constraints.crossAxisExtent - (spacing * (crossAxisCount - 1))) /
            crossAxisCount;
        final cardHeight = ProductCard.mainAxisExtentForWidth(
          cardWidth,
          compact: true,
        );

        return SliverGrid(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisSpacing: 12,
            crossAxisSpacing: spacing,
            mainAxisExtent: cardHeight,
          ),
          delegate: SliverChildBuilderDelegate((context, index) {
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
              onWishlistTap: () => onWishlist(product),
              onQuickAddTap: () => onQuickAdd(product),
              onStoreTap: () {
                final storeId =
                    context
                        .read<ProductController>()
                        .storeForProduct(product)
                        ?.id ??
                    product.storeId;
                if (storeId.isEmpty) {
                  return;
                }
                Navigator.pushNamed(
                  context,
                  AppRoutes.storefront,
                  arguments: storeId,
                );
              },
            );
          }, childCount: products.length),
        );
      },
    );
  }
}

int _gridCrossAxisCount(double width) {
  if (width >= 1180) {
    return 4;
  }
  if (width >= 760) {
    return 3;
  }
  if (width < 300) {
    return 1;
  }
  return 2;
}

class _ServiceStripItem extends StatelessWidget {
  const _ServiceStripItem({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: colors.surfaceSoft,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 18, color: colors.icon),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: colors.primaryText,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    height: 1.25,
                    color: colors.secondaryText,
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

class _ShortcutItem {
  const _ShortcutItem(this.label, this.icon);

  final String label;
  final IconData icon;
}
