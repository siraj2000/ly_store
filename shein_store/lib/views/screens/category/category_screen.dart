import 'package:flutter/material.dart' hide SearchController;
import 'package:provider/provider.dart';

import '../../../controllers/auth_controller.dart';
import '../../../controllers/category_controller.dart';
import '../../../controllers/product_controller.dart';
import '../../../controllers/search_controller.dart';
import '../../../controllers/wishlist_controller.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/extensions/localization_extension.dart';
import '../../../core/helpers/catalog_localization_helper.dart';
import '../../../core/widgets/app_bottom_sheet.dart';
import '../../../core/widgets/app_empty_state.dart';
import '../../../core/widgets/app_loading.dart';
import '../../../models/category_model.dart';
import '../../../models/product_model.dart';
import '../../widgets/category/category_content_grid.dart';
import '../../widgets/category/category_department_tabs.dart';
import '../../widgets/category/category_grid_item.dart';
import '../../widgets/category/category_search_header.dart';
import '../../widgets/category/category_side_menu.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  final TextEditingController _searchController = TextEditingController();

  bool _menuOpen = true;
  String _selectedDepartmentId = 'all';
  String _selectedMenuId = 'just_for_you';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer4<
      CategoryController,
      ProductController,
      WishlistController,
      AuthController
    >(
      builder:
          (
            context,
            categoryController,
            productController,
            wishlistController,
            authController,
            _,
          ) {
            if (categoryController.categories.isEmpty) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  categoryController.loadCategories();
                }
              });
              return const Scaffold(body: AppLoading());
            }

            final colors = context.appColors;
            final menuEntries = _menuEntriesForDepartment(
              context,
              departmentId: _selectedDepartmentId,
            );
            final selectedEntry = _selectedEntryFor(menuEntries);
            final contentState = _buildContentState(
              context: context,
              entry: selectedEntry,
              categoryController: categoryController,
              productController: productController,
            );

            final menu = CategorySideMenu(
              items: menuEntries
                  .map(
                    (item) => CategorySideMenuItemData(
                      id: item.id,
                      label: item.label(context),
                      icon: item.icon,
                    ),
                  )
                  .toList(),
              selectedId: selectedEntry.id,
              isOpen: _menuOpen,
              onToggle: () => setState(() => _menuOpen = !_menuOpen),
              onSelected: (id) => setState(() => _selectedMenuId = id),
            );

            final contentPane = Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsetsDirectional.only(bottom: 92),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      contentState.title,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: colors.primaryText,
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (contentState.gridItems.isNotEmpty)
                      CategoryContentGrid(
                        items: contentState.gridItems,
                        onTap: (item) => _handleGridTap(
                          context: context,
                          item: item,
                          entry: selectedEntry,
                          categoryController: categoryController,
                        ),
                      )
                    else if (contentState.products.isEmpty)
                      AppEmptyState(
                        title: context.tr(
                          'No subcategories',
                          'لا توجد فئات فرعية',
                        ),
                        message: context.tr(
                          'Try another department or category.',
                          'جرّب قسمًا أو فئة أخرى.',
                        ),
                      ),
                    if (contentState.products.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              contentState.productsTitle,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: colors.primaryText,
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () => _openListingForEntry(
                              context: context,
                              entry: selectedEntry,
                              categoryController: categoryController,
                            ),
                            child: Text(context.tr('View All', 'عرض الكل')),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      CategoryProductGrid(
                        products: contentState.products.take(8).toList(),
                        wishlistController: wishlistController,
                      ),
                    ],
                  ],
                ),
              ),
            );

            return Scaffold(
              backgroundColor: colors.background,
              body: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(12, 8, 12, 0),
                  child: Column(
                    children: [
                      CategorySearchHeader(
                        controller: _searchController,
                        hintText: context.tr(
                          'Search shoes, bags, beauty...',
                          'ابحث عن أحذية وحقائب ومكياج...',
                        ),
                        onNotificationsTap: () => Navigator.pushNamed(
                          context,
                          AppRoutes.notifications,
                        ),
                        onCameraTap: () => _showCameraPlaceholder(context),
                        onSearchTap: () => _openSearch(context, selectedEntry),
                        onWishlistTap: () {
                          if (authController.isGuest) {
                            AppBottomSheet.showAuthRequired(context);
                          } else {
                            Navigator.pushNamed(context, AppRoutes.wishlist);
                          }
                        },
                        onChanged: (_) => setState(() {}),
                      ),
                      const SizedBox(height: 12),
                      CategoryDepartmentTabs(
                        tabs: [
                          CategoryDepartmentTabData(
                            id: 'all',
                            label: context.l10n.statusAll,
                          ),
                          CategoryDepartmentTabData(
                            id: 'women',
                            label: context.tr('Women', 'النساء'),
                          ),
                          CategoryDepartmentTabData(
                            id: 'curve',
                            label: context.tr('Curve', 'كيرف'),
                          ),
                          CategoryDepartmentTabData(
                            id: 'kids',
                            label: context.tr('Kids', 'الأطفال'),
                          ),
                          CategoryDepartmentTabData(
                            id: 'men',
                            label: context.tr('Men', 'الرجال'),
                          ),
                          CategoryDepartmentTabData(
                            id: 'home',
                            label: context.tr('Home', 'المنزل'),
                          ),
                        ],
                        selectedId: _selectedDepartmentId,
                        onSelected: (id) {
                          final nextMenuEntries = _menuEntriesForDepartment(
                            context,
                            departmentId: id,
                          );
                          setState(() {
                            _selectedDepartmentId = id;
                            _selectedMenuId = nextMenuEntries.first.id;
                          });
                        },
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: context.isArabic
                              ? [contentPane, const SizedBox(width: 12), menu]
                              : [menu, const SizedBox(width: 12), contentPane],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
    );
  }

  _CategoryMenuEntry _selectedEntryFor(List<_CategoryMenuEntry> entries) {
    final matchIndex = entries.indexWhere((item) => item.id == _selectedMenuId);
    if (matchIndex >= 0) {
      return entries[matchIndex];
    }
    final fallback = entries.first;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _selectedMenuId != fallback.id) {
        setState(() => _selectedMenuId = fallback.id);
      }
    });
    return fallback;
  }

  List<_CategoryMenuEntry> _menuEntriesForDepartment(
    BuildContext context, {
    required String departmentId,
  }) {
    final entries = _allMenuEntries(context);
    if (departmentId == 'all') {
      return entries;
    }

    final filtered = entries
        .where((item) => item.departments.contains(departmentId))
        .toList();
    return filtered.isEmpty ? entries : filtered;
  }

  List<_CategoryMenuEntry> _allMenuEntries(BuildContext context) => [
    _CategoryMenuEntry(
      id: 'just_for_you',
      label: (context) => context.tr('Just for You', 'مخصص لك'),
      title: (context) => context.tr('Picks for You', 'مختارات لك'),
      icon: Icons.star_border_rounded,
      departments: const {'all', 'women', 'curve', 'kids', 'men', 'home'},
    ),
    _CategoryMenuEntry(
      id: 'new_in',
      label: (context) => context.tr('New In', 'وصل حديثًا'),
      title: (context) => context.tr('You May Also Like', 'قد يعجبك أيضًا'),
      icon: Icons.fiber_new_outlined,
      departments: const {'all', 'women', 'curve', 'kids', 'men', 'home'},
      onlyNew: true,
    ),
    _CategoryMenuEntry(
      id: 'sale',
      label: (context) => context.tr('Sale', 'التخفيضات'),
      title: (context) => context.tr('Sale Picks', 'اختيارات التخفيضات'),
      icon: Icons.local_offer_outlined,
      departments: const {'all', 'women', 'curve', 'kids', 'men', 'home'},
      onlySale: true,
    ),
    _CategoryMenuEntry(
      id: 'women_clothing',
      label: (context) => context.tr('Women Clothing', 'ملابس نسائية'),
      title: (context) => context.tr('Women Clothing', 'ملابس نسائية'),
      icon: Icons.checkroom_outlined,
      departments: const {'all', 'women'},
      primaryCategoryId: 'women',
      categoryIds: const [
        'women',
        'dresses',
        'tops',
        'sleepwear',
        'bags',
        'shoes',
      ],
      preferredDepartmentId: 'women',
    ),
    _CategoryMenuEntry(
      id: 'beachwear',
      label: (context) => context.tr('Beachwear', 'ملابس بحر'),
      title: (context) => context.tr('Beachwear', 'ملابس بحر'),
      icon: Icons.beach_access_outlined,
      departments: const {'all', 'women', 'curve'},
      categoryIds: const ['women', 'curve', 'shoes', 'bags'],
      keywords: const ['swimwear', 'beachwear', 'vacation'],
      preferredDepartmentId: 'women',
    ),
    _CategoryMenuEntry(
      id: 'shoes',
      label: (context) => context.tr('Shoes', 'أحذية'),
      title: (context) => context.tr('Shoes', 'أحذية'),
      icon: Icons.hiking_outlined,
      departments: const {'all', 'women', 'curve', 'men'},
      primaryCategoryId: 'shoes',
      categoryIds: const ['shoes'],
    ),
    _CategoryMenuEntry(
      id: 'curve',
      label: (context) => context.tr('Curve', 'كيرف'),
      title: (context) => context.tr('Curve', 'كيرف'),
      icon: Icons.auto_awesome_outlined,
      departments: const {'all', 'curve'},
      primaryCategoryId: 'curve',
      categoryIds: const ['curve', 'sleepwear', 'shoes'],
      preferredDepartmentId: 'curve',
    ),
    _CategoryMenuEntry(
      id: 'men_clothing',
      label: (context) => context.tr('Men Clothing', 'ملابس رجالية'),
      title: (context) => context.tr('Men Clothing', 'ملابس رجالية'),
      icon: Icons.male_outlined,
      departments: const {'all', 'men'},
      primaryCategoryId: 'men',
      categoryIds: const ['men', 'men-trends', 'shoes', 'bags'],
      preferredDepartmentId: 'men',
    ),
    _CategoryMenuEntry(
      id: 'kids',
      label: (context) => context.tr('Kids', 'الأطفال'),
      title: (context) => context.tr('Kids', 'الأطفال'),
      icon: Icons.child_care_outlined,
      departments: const {'all', 'kids'},
      primaryCategoryId: 'kids',
      categoryIds: const ['kids'],
      preferredDepartmentId: 'kids',
    ),
    _CategoryMenuEntry(
      id: 'jewelry_accessories',
      label: (context) =>
          context.tr('Jewelry & Accessories', 'المجوهرات والإكسسوارات'),
      title: (context) =>
          context.tr('Jewelry & Accessories', 'المجوهرات والإكسسوارات'),
      icon: Icons.diamond_outlined,
      departments: const {'all', 'women'},
      primaryCategoryId: 'jewelry',
      categoryIds: const ['jewelry'],
    ),
    _CategoryMenuEntry(
      id: 'home_living',
      label: (context) => context.tr('Home & Living', 'المنزل والمعيشة'),
      title: (context) => context.tr('Home & Living', 'المنزل والمعيشة'),
      icon: Icons.chair_outlined,
      departments: const {'all', 'home'},
      primaryCategoryId: 'home',
      categoryIds: const ['home', 'house', 'kitchen'],
      preferredDepartmentId: 'home',
    ),
    _CategoryMenuEntry(
      id: 'underwear_sleepwear',
      label: (context) =>
          context.tr('Underwear & Sleepwear', 'الملابس الداخلية والنوم'),
      title: (context) =>
          context.tr('Underwear & Sleepwear', 'الملابس الداخلية والنوم'),
      icon: Icons.nightlight_outlined,
      departments: const {'all', 'women', 'curve', 'kids'},
      primaryCategoryId: 'sleepwear',
      categoryIds: const ['sleepwear'],
    ),
    _CategoryMenuEntry(
      id: 'baby_maternity',
      label: (context) => context.tr('Baby & Maternity', 'الأطفال والأمومة'),
      title: (context) => context.tr('Baby & Maternity', 'الأطفال والأمومة'),
      icon: Icons.pregnant_woman_outlined,
      departments: const {'all', 'kids', 'women'},
      categoryIds: const ['kids'],
      keywords: const ['baby', 'maternity'],
      preferredDepartmentId: 'kids',
    ),
    _CategoryMenuEntry(
      id: 'beauty_health',
      label: (context) => context.tr('Beauty & Health', 'الجمال والصحة'),
      title: (context) => context.tr('Beauty & Health', 'الجمال والصحة'),
      icon: Icons.spa_outlined,
      departments: const {'all', 'women', 'curve'},
      primaryCategoryId: 'beauty',
      categoryIds: const ['beauty'],
    ),
    _CategoryMenuEntry(
      id: 'sports_outdoors',
      label: (context) =>
          context.tr('Sports & Outdoors', 'الرياضة والهواء الطلق'),
      title: (context) =>
          context.tr('Sports & Outdoors', 'الرياضة والهواء الطلق'),
      icon: Icons.sports_basketball_outlined,
      departments: const {'all', 'men', 'women'},
      categoryIds: const ['shoes', 'men', 'women'],
      keywords: const ['fitness', 'sport', 'activewear'],
    ),
    _CategoryMenuEntry(
      id: 'bags_luggage',
      label: (context) => context.tr('Bags & Luggage', 'الحقائب والأمتعة'),
      title: (context) => context.tr('Bags & Luggage', 'الحقائب والأمتعة'),
      icon: Icons.luggage_outlined,
      departments: const {'all', 'women', 'men'},
      primaryCategoryId: 'bags',
      categoryIds: const ['bags'],
    ),
    _CategoryMenuEntry(
      id: 'cell_phones_accessories',
      label: (context) =>
          context.tr('Cell Phones & Accessories', 'الهواتف وإكسسواراتها'),
      title: (context) =>
          context.tr('Cell Phones & Accessories', 'الهواتف وإكسسواراتها'),
      icon: Icons.phone_iphone_outlined,
      departments: const {'all', 'home', 'kids'},
      primaryCategoryId: 'electronics',
      categoryIds: const ['electronics'],
      keywords: const ['phone', 'smart', 'case'],
    ),
    _CategoryMenuEntry(
      id: 'toys_games',
      label: (context) => context.tr('Toys & Games', 'الألعاب'),
      title: (context) => context.tr('Toys & Games', 'الألعاب'),
      icon: Icons.toys_outlined,
      departments: const {'all', 'kids'},
      categoryIds: const ['kids'],
      keywords: const ['toy'],
      preferredDepartmentId: 'kids',
    ),
    _CategoryMenuEntry(
      id: 'home_textiles',
      label: (context) => context.tr('Home Textiles', 'مفروشات المنزل'),
      title: (context) => context.tr('Home Textiles', 'مفروشات المنزل'),
      icon: Icons.bed_outlined,
      departments: const {'all', 'home'},
      primaryCategoryId: 'house',
      categoryIds: const ['house', 'home'],
      preferredDepartmentId: 'home',
    ),
    _CategoryMenuEntry(
      id: 'electronics',
      label: (context) => context.tr('Electronics', 'الإلكترونيات'),
      title: (context) => context.tr('Electronics', 'الإلكترونيات'),
      icon: Icons.devices_outlined,
      departments: const {'all', 'home'},
      primaryCategoryId: 'electronics',
      categoryIds: const ['electronics'],
      preferredDepartmentId: 'home',
    ),
    _CategoryMenuEntry(
      id: 'tools_home_improvement',
      label: (context) =>
          context.tr('Tools & Home Improvement', 'الأدوات وتحسين المنزل'),
      title: (context) =>
          context.tr('Tools & Home Improvement', 'الأدوات وتحسين المنزل'),
      icon: Icons.handyman_outlined,
      departments: const {'all', 'home'},
      primaryCategoryId: 'house',
      categoryIds: const ['house', 'kitchen', 'electronics'],
      preferredDepartmentId: 'home',
    ),
    _CategoryMenuEntry(
      id: 'office_school_supplies',
      label: (context) =>
          context.tr('Office & School Supplies', 'اللوازم المكتبية والمدرسية'),
      title: (context) =>
          context.tr('Office & School Supplies', 'اللوازم المكتبية والمدرسية'),
      icon: Icons.school_outlined,
      departments: const {'all', 'kids', 'home'},
      categoryIds: const ['electronics', 'kids'],
      keywords: const ['school', 'stationery', 'desk'],
    ),
    _CategoryMenuEntry(
      id: 'automotive',
      label: (context) => context.tr('Automotive', 'السيارات'),
      title: (context) => context.tr('Automotive', 'السيارات'),
      icon: Icons.directions_car_outlined,
      departments: const {'all', 'home'},
      categoryIds: const ['electronics'],
      keywords: const ['automotive', 'car'],
    ),
    _CategoryMenuEntry(
      id: 'pet_supplies',
      label: (context) => context.tr('Pet Supplies', 'مستلزمات الحيوانات'),
      title: (context) => context.tr('Pet Supplies', 'مستلزمات الحيوانات'),
      icon: Icons.pets_outlined,
      departments: const {'all', 'home'},
      categoryIds: const ['house', 'home'],
      keywords: const ['pet'],
    ),
    _CategoryMenuEntry(
      id: 'appliances',
      label: (context) => context.tr('Appliances', 'الأجهزة المنزلية'),
      title: (context) => context.tr('Appliances', 'الأجهزة المنزلية'),
      icon: Icons.kitchen_outlined,
      departments: const {'all', 'home'},
      primaryCategoryId: 'kitchen',
      categoryIds: const ['kitchen', 'house'],
      preferredDepartmentId: 'home',
    ),
  ];

  _CategoryContentState _buildContentState({
    required BuildContext context,
    required _CategoryMenuEntry entry,
    required CategoryController categoryController,
    required ProductController productController,
  }) {
    final entryProducts = _productsForEntry(
      entry,
      productController: productController,
    );

    if (entry.id == 'just_for_you') {
      final recommended = productController.forYou(
        _selectedDepartmentId == 'all' ? null : _selectedDepartmentId,
      );
      return _CategoryContentState(
        title: entry.title(context),
        productsTitle: context.tr('You May Also Like', 'قد يعجبك أيضًا'),
        gridItems: recommended
            .take(12)
            .map(
              (product) => CategoryGridItemData(
                id: 'product:${product.id}',
                label: product.resolvedTitle(Localizations.localeOf(context)),
                imageUrl: _productImage(product),
              ),
            )
            .toList(),
        products: recommended.take(8).toList(),
      );
    }

    final primaryCategory = categoryController.categoryById(
      entry.primaryCategoryId,
    );
    final gridItems = <CategoryGridItemData>[];

    if (primaryCategory != null && primaryCategory.subcategories.isNotEmpty) {
      for (final subcategory in primaryCategory.subcategories) {
        gridItems.add(
          CategoryGridItemData(
            id: 'subcategory:${primaryCategory.id}:$subcategory',
            label: localizedSubcategoryName(context, subcategory),
            imageUrl: _imageForSubcategory(
              subcategory: subcategory,
              fallbackCategory: primaryCategory,
              products: entryProducts,
            ),
          ),
        );
      }
    } else {
      final relatedCategories = categoryController.categories
          .where((item) => entry.categoryIds.contains(item.id))
          .toList();
      for (final category in relatedCategories.take(8)) {
        gridItems.add(
          CategoryGridItemData(
            id: 'category:${category.id}',
            label: category.localizedName(Localizations.localeOf(context)),
            imageUrl: category.imageUrl ?? category.localImagePath ?? '',
          ),
        );
      }
    }

    if (entry.categoryIds.isNotEmpty || primaryCategory != null) {
      gridItems.add(
        CategoryGridItemData(
          id: 'view_all:${entry.id}',
          label: context.tr('View All', 'عرض الكل'),
          imageUrl: '',
          isViewAll: true,
        ),
      );
    }

    return _CategoryContentState(
      title: entry.title(context),
      productsTitle: context.tr('Popular Products', 'منتجات شائعة'),
      gridItems: gridItems,
      products: entryProducts.take(10).toList(),
    );
  }

  List<ProductModel> _productsForEntry(
    _CategoryMenuEntry entry, {
    required ProductController productController,
  }) {
    if (entry.id == 'just_for_you') {
      return productController.forYou(
        _selectedDepartmentId == 'all' ? null : _selectedDepartmentId,
      );
    }
    if (entry.id == 'new_in') {
      return productController.newest(
        _selectedDepartmentId == 'all' ? null : _selectedDepartmentId,
      );
    }
    if (entry.id == 'sale') {
      return productController.deals(
        _selectedDepartmentId == 'all' ? null : _selectedDepartmentId,
      );
    }

    var products = List<ProductModel>.from(productController.products);

    if (entry.preferredDepartmentId != null &&
        entry.preferredDepartmentId!.isNotEmpty &&
        entry.preferredDepartmentId != 'all') {
      products = products
          .where((item) => item.department == entry.preferredDepartmentId)
          .toList();
    }

    if (entry.categoryIds.isNotEmpty) {
      final allowedCategories = entry.categoryIds.toSet();
      products = products
          .where((item) => allowedCategories.contains(item.categoryId))
          .toList();
    }

    if (entry.onlyNew) {
      products = products.where((item) => item.isNew).toList();
    }

    if (entry.onlySale) {
      products = products
          .where((item) => item.discount > 0 || item.oldPrice > item.price)
          .toList();
    }

    if (entry.keywords.isNotEmpty) {
      products = products.where((product) {
        final haystack = normalizeSearchText(
          [
            product.subcategoryName,
            product.categoryName,
            product.title,
            product.tags.join(' '),
          ].join(' '),
        );
        return entry.keywords.any(
          (keyword) => haystack.contains(normalizeSearchText(keyword)),
        );
      }).toList();
    }

    return products;
  }

  String _productImage(ProductModel product) {
    return product.imageUrl ??
        (product.imageUrls.isNotEmpty ? product.imageUrls.first : '');
  }

  String _imageForSubcategory({
    required String subcategory,
    required CategoryModel fallbackCategory,
    required List<ProductModel> products,
  }) {
    final normalizedSubcategory = subcategory.toLowerCase();
    for (final product in products) {
      final tagMatch = product.tags.any(
        (tag) => tag.trim().toLowerCase() == normalizedSubcategory,
      );
      if (product.subcategoryName.trim().toLowerCase() ==
              normalizedSubcategory ||
          tagMatch) {
        return _productImage(product);
      }
    }
    return fallbackCategory.imageUrl ?? fallbackCategory.localImagePath ?? '';
  }

  void _handleGridTap({
    required BuildContext context,
    required CategoryGridItemData item,
    required _CategoryMenuEntry entry,
    required CategoryController categoryController,
  }) {
    if (item.id.startsWith('product:')) {
      Navigator.pushNamed(
        context,
        AppRoutes.productDetails,
        arguments: item.id.split(':').last,
      );
      return;
    }

    if (item.id.startsWith('view_all:')) {
      _openListingForEntry(
        context: context,
        entry: entry,
        categoryController: categoryController,
      );
      return;
    }

    if (item.id.startsWith('category:')) {
      final categoryId = item.id.split(':').last;
      final category = categoryController.categoryById(categoryId);
      Navigator.pushNamed(
        context,
        AppRoutes.productListing,
        arguments: {
          'title': item.label,
          'categoryId': categoryId,
          'department': category?.departmentId,
        },
      );
      return;
    }

    if (item.id.startsWith('subcategory:')) {
      final parts = item.id.split(':');
      final categoryId = parts[1];
      final subcategoryId = parts.sublist(2).join(':');
      final category = categoryController.categoryById(categoryId);
      Navigator.pushNamed(
        context,
        AppRoutes.productListing,
        arguments: {
          'title': item.label,
          'categoryId': categoryId,
          'subcategoryId': subcategoryId,
          'department': category?.departmentId,
        },
      );
    }
  }

  void _openListingForEntry({
    required BuildContext context,
    required _CategoryMenuEntry entry,
    required CategoryController categoryController,
  }) {
    final primaryCategory = categoryController.categoryById(
      entry.primaryCategoryId,
    );
    Navigator.pushNamed(
      context,
      AppRoutes.productListing,
      arguments: {
        'title': entry.title(context),
        'categoryId': primaryCategory?.id,
        'department':
            entry.preferredDepartmentId ?? primaryCategory?.departmentId,
        if (entry.onlySale) 'campaignTag': 'Sale',
      },
    );
  }

  void _openSearch(BuildContext context, _CategoryMenuEntry entry) {
    final searchController = context.read<SearchController>();
    final filters = <String, dynamic>{};

    if (entry.preferredDepartmentId != null &&
        entry.preferredDepartmentId != 'all') {
      filters['departmentId'] = entry.preferredDepartmentId;
    }
    if (entry.primaryCategoryId != null) {
      filters['categoryId'] = entry.primaryCategoryId;
    }

    final query = _searchController.text.trim();
    searchController.setContextFilters(filters);
    if (query.isNotEmpty) {
      searchController.setQuery(query);
      searchController.addRecentSearch(query);
      searchController.search();
    }

    Navigator.pushNamed(context, AppRoutes.search);
  }

  void _showCameraPlaceholder(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.tr('Image search', 'البحث بالصور')),
        content: Text(
          context.tr(
            'Visual search placeholder ready for future API integration.',
            'ميزة البحث بالصور جاهزة مؤقتًا للربط مع الواجهة البرمجية لاحقًا.',
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
}

class _CategoryMenuEntry {
  const _CategoryMenuEntry({
    required this.id,
    required this.label,
    required this.title,
    required this.icon,
    required this.departments,
    this.primaryCategoryId,
    this.categoryIds = const [],
    this.keywords = const [],
    this.preferredDepartmentId,
    this.onlySale = false,
    this.onlyNew = false,
  });

  final String id;
  final String Function(BuildContext) label;
  final String Function(BuildContext) title;
  final IconData icon;
  final Set<String> departments;
  final String? primaryCategoryId;
  final List<String> categoryIds;
  final List<String> keywords;
  final String? preferredDepartmentId;
  final bool onlySale;
  final bool onlyNew;
}

class _CategoryContentState {
  const _CategoryContentState({
    required this.title,
    required this.productsTitle,
    required this.gridItems,
    required this.products,
  });

  final String title;
  final String productsTitle;
  final List<CategoryGridItemData> gridItems;
  final List<ProductModel> products;
}
