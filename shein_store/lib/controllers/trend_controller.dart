import 'package:flutter/foundation.dart';

import '../models/localized_text_model.dart';
import '../models/product_model.dart';
import '../models/store_model.dart';
import '../models/trend_campaign_model.dart';
import '../models/trend_store_section_model.dart';
import '../models/trend_tag_model.dart';
import '../repositories/marketplace_repository.dart';
import '../services/mock_data_service.dart';
import 'product_controller.dart';

enum TrendMainTab { trendingPicks, trendsStore }

class TrendStoreCategoryOption {
  const TrendStoreCategoryOption({
    required this.id,
    required this.labelText,
    this.departments = const {},
    this.keywords = const [],
  });

  final String id;
  final LocalizedTextModel labelText;
  final Set<String> departments;
  final List<String> keywords;
}

class TrendController extends ChangeNotifier {
  TrendController({
    required MarketplaceRepository marketplaceRepository,
    required MockDataService mockDataService,
  }) : _marketplaceRepository = marketplaceRepository,
       _mockDataService = mockDataService;

  final MarketplaceRepository _marketplaceRepository;
  final MockDataService _mockDataService;

  ProductController? _productController;
  VoidCallback? _productCatalogListener;
  List<StoreModel> _stores = const [];
  String _catalogSignature = '';

  bool _initialized = false;
  bool isLoading = false;
  String? errorMessage;

  TrendMainTab selectedMainTab = TrendMainTab.trendsStore;
  String selectedTrendTagId = 'for_you';
  String selectedStoreCategoryId = 'all';
  String searchQuery = '';
  bool isNewOnly = false;
  bool isFilterPanelOpen = false;
  bool isCategoryPanelOpen = false;
  int currentCampaignIndex = 0;

  List<TrendCampaignModel> trendCampaigns = const [];
  List<TrendTagModel> trendTags = const [];
  List<TrendStoreSectionModel> trendStoreSections = const [];

  final List<TrendStoreCategoryOption> storeCategories = const [
    TrendStoreCategoryOption(
      id: 'all',
      labelText: LocalizedTextModel(en: 'All', ar: 'الكل'),
    ),
    TrendStoreCategoryOption(
      id: 'women_denim',
      labelText: LocalizedTextModel(en: 'Women Denim', ar: 'جينز نسائي'),
      departments: {'women'},
      keywords: ['denim', 'jeans'],
    ),
    TrendStoreCategoryOption(
      id: 'women_bottoms',
      labelText: LocalizedTextModel(en: 'Women Bottoms', ar: 'قيعان نسائية'),
      departments: {'women'},
      keywords: ['pants', 'skirts', 'shorts', 'leggings', 'bottoms'],
    ),
    TrendStoreCategoryOption(
      id: 'women_sandals',
      labelText: LocalizedTextModel(en: 'Women Sandals', ar: 'صنادل نسائية'),
      departments: {'women', 'shoes'},
      keywords: ['sandals'],
    ),
    TrendStoreCategoryOption(
      id: 'women_tops',
      labelText: LocalizedTextModel(
        en: 'Women Tops, Blouses & Tee',
        ar: 'بلايز وتيشيرتات نسائية',
      ),
      departments: {'women', 'tops'},
      keywords: ['tops', 'blouse', 'tee', 'shirt', 'crop tops', 'knit tops'],
    ),
    TrendStoreCategoryOption(
      id: 'men_tops',
      labelText: LocalizedTextModel(en: 'Men Tops', ar: 'قمصان رجالية'),
      departments: {'men'},
      keywords: ['shirt', 'tee', 'polo', 'overshirt', 'tops'],
    ),
    TrendStoreCategoryOption(
      id: 'women_knitwear',
      labelText: LocalizedTextModel(en: 'Women Knitwear', ar: 'تريكو نسائي'),
      departments: {'women'},
      keywords: ['knit', 'cardigan'],
    ),
    TrendStoreCategoryOption(
      id: 'women_coords',
      labelText: LocalizedTextModel(en: 'Women Co-ords', ar: 'أطقم نسائية'),
      departments: {'women'},
      keywords: ['co-ords', 'sets', 'coords'],
    ),
    TrendStoreCategoryOption(
      id: 'women_beachwear',
      labelText: LocalizedTextModel(
        en: 'Women Beachwear',
        ar: 'ملابس بحر نسائية',
      ),
      departments: {'women'},
      keywords: ['beach', 'swimwear', 'vacation', 'coastal'],
    ),
    TrendStoreCategoryOption(
      id: 'plus_size_dresses',
      labelText: LocalizedTextModel(en: 'Plus Size Dresses', ar: 'فساتين كيرف'),
      departments: {'curve'},
      keywords: ['curve', 'dress'],
    ),
    TrendStoreCategoryOption(
      id: 'face_makeup',
      labelText: LocalizedTextModel(en: 'Face Make Up', ar: 'مكياج الوجه'),
      departments: {'beauty'},
      keywords: ['makeup', 'face', 'foundation', 'palette', 'primer', 'blush'],
    ),
    TrendStoreCategoryOption(
      id: 'women_active_bottoms',
      labelText: LocalizedTextModel(
        en: 'Women Active Bottoms',
        ar: 'قيعان رياضية نسائية',
      ),
      departments: {'women'},
      keywords: ['activewear', 'leggings', 'pants', 'joggers'],
    ),
    TrendStoreCategoryOption(
      id: 'women_pumps',
      labelText: LocalizedTextModel(en: 'Women Pumps', ar: 'أحذية كعب نسائية'),
      departments: {'women', 'shoes'},
      keywords: ['pumps', 'heels'],
    ),
    TrendStoreCategoryOption(
      id: 'phone_cases',
      labelText: LocalizedTextModel(en: 'Phone Cases', ar: 'أغطية الهاتف'),
      departments: {'electronics'},
      keywords: ['phone cases', 'phone accessories', 'case'],
    ),
    TrendStoreCategoryOption(
      id: 'women_party_wear',
      labelText: LocalizedTextModel(
        en: 'Women Party Wear',
        ar: 'ملابس سهرات نسائية',
      ),
      departments: {'women'},
      keywords: ['party', 'dress', 'evening', 'glam'],
    ),
    TrendStoreCategoryOption(
      id: 'women_bracelets',
      labelText: LocalizedTextModel(en: 'Women Bracelets', ar: 'أساور نسائية'),
      departments: {'jewelry'},
      keywords: ['bracelet'],
    ),
    TrendStoreCategoryOption(
      id: 'women_flats',
      labelText: LocalizedTextModel(en: 'Women Flats', ar: 'أحذية فلات نسائية'),
      departments: {'shoes'},
      keywords: ['flat', 'flats', 'loafers', 'ballet'],
    ),
    TrendStoreCategoryOption(
      id: 'plus_size_tops',
      labelText: LocalizedTextModel(en: 'Plus Size Tops', ar: 'بلوزات كيرف'),
      departments: {'curve'},
      keywords: ['curve', 'top', 'blouse', 'tee'],
    ),
    TrendStoreCategoryOption(
      id: 'women_shoulder_bags',
      labelText: LocalizedTextModel(
        en: 'Women Shoulder Bags',
        ar: 'حقائب كتف نسائية',
      ),
      departments: {'bags'},
      keywords: ['shoulder bag', 'handbag', 'crossbody', 'bag'],
    ),
    TrendStoreCategoryOption(
      id: 'women_earrings',
      labelText: LocalizedTextModel(en: 'Women Earrings', ar: 'أقراط نسائية'),
      departments: {'jewelry'},
      keywords: ['earring', 'studs', 'hoops'],
    ),
    TrendStoreCategoryOption(
      id: 'women_active_sets',
      labelText: LocalizedTextModel(
        en: 'Women Active Sets',
        ar: 'أطقم رياضية نسائية',
      ),
      departments: {'women'},
      keywords: ['activewear', 'set', 'sports bra', 'lounge set'],
    ),
    TrendStoreCategoryOption(
      id: 'men_bottoms',
      labelText: LocalizedTextModel(en: 'Men Bottoms', ar: 'قيعان رجالية'),
      departments: {'men'},
      keywords: ['pants', 'chinos', 'joggers', 'cargo'],
    ),
    TrendStoreCategoryOption(
      id: 'women_outerwear',
      labelText: LocalizedTextModel(
        en: 'Women Outerwear',
        ar: 'ملابس خارجية نسائية',
      ),
      departments: {'women'},
      keywords: ['outerwear', 'jacket', 'blazer', 'coat', 'trench'],
    ),
    TrendStoreCategoryOption(
      id: 'women_eyewear',
      labelText: LocalizedTextModel(
        en: 'Women Glasses & Eyewear Accessories',
        ar: 'نظارات وإكسسوارات نسائية',
      ),
      departments: {'jewelry', 'bags'},
      keywords: ['glasses', 'eyewear', 'sunglasses'],
    ),
    TrendStoreCategoryOption(
      id: 'women_active_tops',
      labelText: LocalizedTextModel(
        en: 'Women Active Tops',
        ar: 'قمصان رياضية نسائية',
      ),
      departments: {'women'},
      keywords: ['activewear', 'sports bra', 'tee', 'top'],
    ),
    TrendStoreCategoryOption(
      id: 'women_top_handle_bags',
      labelText: LocalizedTextModel(
        en: 'Women Top Handle Bags',
        ar: 'حقائب بمقبض علوي',
      ),
      departments: {'bags'},
      keywords: ['top handle', 'bag', 'handbag'],
    ),
    TrendStoreCategoryOption(
      id: 'men_denim',
      labelText: LocalizedTextModel(en: 'Men Denim', ar: 'جينز رجالي'),
      departments: {'men'},
      keywords: ['denim', 'jeans'],
    ),
    TrendStoreCategoryOption(
      id: 'women_hair_accessories',
      labelText: LocalizedTextModel(
        en: 'Women Hair Accessories',
        ar: 'إكسسوارات شعر نسائية',
      ),
      departments: {'beauty', 'jewelry'},
      keywords: ['hair', 'clip', 'scrunchie'],
    ),
    TrendStoreCategoryOption(
      id: 'young_girls_sets',
      labelText: LocalizedTextModel(
        en: 'Young Girls Sets',
        ar: 'أطقم البنات الصغيرات',
      ),
      departments: {'kids'},
      keywords: ['kids', 'girls', 'set'],
    ),
    TrendStoreCategoryOption(
      id: 'women_sneakers',
      labelText: LocalizedTextModel(en: 'Women Sneakers', ar: 'سنيكرز نسائية'),
      departments: {'shoes'},
      keywords: ['sneakers', 'sport shoes'],
    ),
    TrendStoreCategoryOption(
      id: 'women_evening_bags',
      labelText: LocalizedTextModel(
        en: 'Women Evening Bags',
        ar: 'حقائب سهرة نسائية',
      ),
      departments: {'bags'},
      keywords: ['evening bag', 'bag', 'party'],
    ),
  ];

  bool get initialized => _initialized;

  void bind({required ProductController productController}) {
    if (identical(_productController, productController)) {
      return;
    }
    if (_productController != null && _productCatalogListener != null) {
      _productController!.removeListener(_productCatalogListener!);
    }
    _productController = productController;
    _productCatalogListener = _handleProductCatalogChanged;
    productController.addListener(_productCatalogListener!);
  }

  @override
  void dispose() {
    if (_productController != null && _productCatalogListener != null) {
      _productController!.removeListener(_productCatalogListener!);
    }
    super.dispose();
  }

  Future<void> initialize() async {
    if (isLoading) {
      return;
    }

    final productController = _productController;
    if (productController == null) {
      return;
    }

    final nextSignature = _buildCatalogSignature(productController);
    if (_initialized && _catalogSignature == nextSignature) {
      return;
    }

    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      _stores = await _marketplaceRepository.getStores();
      _catalogSignature = nextSignature;
      _hydrateTrendData();
      _initialized = true;
    } catch (_) {
      errorMessage = 'Unable to load trends';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void _handleProductCatalogChanged() {
    final productController = _productController;
    if (productController == null || isLoading) {
      return;
    }

    final nextSignature = _buildCatalogSignature(productController);
    if (_initialized && _catalogSignature == nextSignature) {
      return;
    }

    if (!_initialized && productController.marketplaceProducts.isEmpty) {
      return;
    }

    initialize();
  }

  Future<void> refresh() => initialize();

  void selectMainTab(TrendMainTab tab) {
    if (selectedMainTab == tab) {
      return;
    }
    selectedMainTab = tab;
    isFilterPanelOpen = false;
    isCategoryPanelOpen = false;
    notifyListeners();
  }

  void selectTrendTag(String tagId) {
    selectedTrendTagId = tagId;
    selectedMainTab = TrendMainTab.trendingPicks;
    isFilterPanelOpen = false;
    notifyListeners();
  }

  void clearTrendTag() {
    selectTrendTag('for_you');
  }

  void toggleFilterPanel() {
    isFilterPanelOpen = !isFilterPanelOpen;
    if (isFilterPanelOpen) {
      isCategoryPanelOpen = false;
    }
    notifyListeners();
  }

  void toggleCategoryPanel() {
    isCategoryPanelOpen = !isCategoryPanelOpen;
    if (isCategoryPanelOpen) {
      isFilterPanelOpen = false;
    }
    notifyListeners();
  }

  void closePanels() {
    if (!isFilterPanelOpen && !isCategoryPanelOpen) {
      return;
    }
    isFilterPanelOpen = false;
    isCategoryPanelOpen = false;
    notifyListeners();
  }

  void selectStoreCategory(String categoryId) {
    selectedStoreCategoryId = categoryId;
    isCategoryPanelOpen = false;
    notifyListeners();
  }

  void toggleNewOnly() {
    isNewOnly = !isNewOnly;
    notifyListeners();
  }

  void setSearchQuery(String value) {
    if (searchQuery == value) {
      return;
    }
    searchQuery = value;
    if (currentCampaignIndex >= filteredCampaigns.length) {
      currentCampaignIndex = 0;
    }
    notifyListeners();
  }

  void setCurrentCampaignIndex(int index) {
    if (currentCampaignIndex == index) {
      return;
    }
    currentCampaignIndex = index;
    notifyListeners();
  }

  void openCampaign(String campaignId) {
    selectTrendTag(campaignId);
    currentCampaignIndex = trendCampaigns.indexWhere(
      (campaign) => campaign.id == campaignId,
    );
    if (currentCampaignIndex < 0) {
      currentCampaignIndex = 0;
    }
    notifyListeners();
  }

  List<ProductModel> getFilteredTrendingProducts() {
    var products = List<ProductModel>.from(_publicProducts);

    if (selectedTrendTagId != 'for_you') {
      final tag = trendTags.firstWhere(
        (item) => item.id == selectedTrendTagId,
        orElse: () => const TrendTagModel(
          id: 'for_you',
          label: 'For You',
          productIds: [],
          storeIds: [],
          displayOrder: 0,
          isActive: true,
        ),
      );
      if (tag.productIds.isNotEmpty) {
        final allowedIds = tag.productIds.toSet();
        products = products
            .where((item) => allowedIds.contains(item.id))
            .toList();
      }
    }

    if (searchQuery.trim().isNotEmpty) {
      products = products.where(_matchesProductSearch).toList();
    }

    products.sort((a, b) {
      final popularity = b.soldCount.compareTo(a.soldCount);
      if (popularity != 0) {
        return popularity;
      }
      final rating = b.rating.compareTo(a.rating);
      if (rating != 0) {
        return rating;
      }
      return (b.publishedAt ?? b.createdAt).compareTo(
        a.publishedAt ?? a.createdAt,
      );
    });

    return products;
  }

  List<TrendStoreSectionModel> getFilteredTrendStores() {
    final productsByStore = {
      for (final store in _publicStores)
        store.id: getProductsForStore(store.id),
    };

    var sections = trendStoreSections.where((section) {
      final products =
          productsByStore[section.storeId] ?? const <ProductModel>[];
      if (products.isEmpty) {
        return false;
      }
      if (isNewOnly && !section.isNew) {
        return false;
      }
      return true;
    }).toList();

    sections.sort((a, b) {
      final trendingCompare = b.isTrending.toString().compareTo(
        a.isTrending.toString(),
      );
      if (trendingCompare != 0) {
        return trendingCompare;
      }
      return a.displayOrder.compareTo(b.displayOrder);
    });

    return sections;
  }

  List<ProductModel> getProductsForStore(String storeId) {
    var products = _publicProducts
        .where((product) => product.storeId == storeId)
        .toList();

    final category = selectedStoreCategory;
    if (selectedMainTab == TrendMainTab.trendsStore &&
        category != null &&
        category.id != 'all') {
      products = products.where((product) {
        final store = storeById(storeId);
        return store != null && _matchesStoreCategory(product, store, category);
      }).toList();
    }

    if (selectedMainTab == TrendMainTab.trendsStore && isNewOnly) {
      products = products.where((product) => product.isNew).toList();
    }

    if (searchQuery.trim().isNotEmpty) {
      products = products.where(_matchesProductSearch).toList();
    }

    products.sort((a, b) {
      final newCompare = b.isNew.toString().compareTo(a.isNew.toString());
      if (newCompare != 0) {
        return newCompare;
      }
      final popularity = b.soldCount.compareTo(a.soldCount);
      if (popularity != 0) {
        return popularity;
      }
      return (b.publishedAt ?? b.createdAt).compareTo(
        a.publishedAt ?? a.createdAt,
      );
    });
    return products;
  }

  StoreModel? storeById(String storeId) {
    for (final store in _publicStores) {
      if (store.id == storeId) {
        return store;
      }
    }
    return null;
  }

  TrendStoreSectionModel? sectionForStore(String storeId) {
    for (final section in trendStoreSections) {
      if (section.storeId == storeId) {
        return section;
      }
    }
    return null;
  }

  TrendStoreCategoryOption? get selectedStoreCategory {
    for (final option in storeCategories) {
      if (option.id == selectedStoreCategoryId) {
        return option;
      }
    }
    return null;
  }

  List<TrendCampaignModel> get filteredCampaigns {
    if (searchQuery.trim().isEmpty) {
      return trendCampaigns;
    }
    final normalizedQuery = _normalize(searchQuery);
    final filtered = trendCampaigns.where((campaign) {
      final combined = [
        campaign.titleText.en,
        campaign.titleText.ar,
        campaign.subtitleText.en,
        campaign.subtitleText.ar,
        campaign.hashtag,
      ].join(' ');
      return _normalize(combined).contains(normalizedQuery);
    }).toList();
    return filtered.isEmpty ? trendCampaigns : filtered;
  }

  List<ProductModel> campaignProducts(TrendCampaignModel campaign) {
    final ids = campaign.productIds.toSet();
    return _publicProducts
        .where((product) => ids.contains(product.id))
        .toList();
  }

  List<TrendTagModel> get visibleFilterTags =>
      trendTags.where((tag) => tag.isActive).toList();

  String _buildCatalogSignature(ProductController productController) {
    final buffer = StringBuffer();
    for (final product in productController.marketplaceProducts) {
      buffer
        ..write(product.id)
        ..write(':')
        ..write(product.updatedAt.millisecondsSinceEpoch)
        ..write('|');
    }
    return buffer.toString();
  }

  void _hydrateTrendData() {
    final tags = _buildTrendTags();
    trendTags = tags;
    trendCampaigns = _buildTrendCampaigns(tags);
    trendStoreSections = _buildTrendStoreSections(tags);

    final validTagIds = tags.map((item) => item.id).toSet();
    if (!validTagIds.contains(selectedTrendTagId)) {
      selectedTrendTagId = 'for_you';
    }
    final validCategoryIds = storeCategories.map((item) => item.id).toSet();
    if (!validCategoryIds.contains(selectedStoreCategoryId)) {
      selectedStoreCategoryId = 'all';
    }
    if (currentCampaignIndex >= trendCampaigns.length) {
      currentCampaignIndex = 0;
    }
  }

  List<TrendTagModel> _buildTrendTags() {
    final products = _publicProducts;
    final stores = _publicStores;
    final definitions = _trendTagDefinitions;
    final tags = <TrendTagModel>[
      TrendTagModel(
        id: 'for_you',
        label: 'For You',
        localizedLabelText: const LocalizedTextModel(en: 'For You', ar: 'لكِ'),
        productIds: products.map((product) => product.id).toList(),
        storeIds: stores.map((store) => store.id).toList(),
        displayOrder: 0,
        isActive: true,
      ),
    ];

    for (final definition in definitions) {
      final matchingProducts = products
          .where(
            (product) => _matchesKeywords(
              _productSearchBag(product),
              definition.keywords,
            ),
          )
          .toList();
      final storeIds = matchingProducts
          .map((product) => product.storeId)
          .toSet()
          .toList();
      tags.add(
        TrendTagModel(
          id: definition.id,
          label: definition.labelText.en,
          localizedLabelText: definition.labelText,
          productIds: matchingProducts.map((product) => product.id).toList(),
          storeIds: storeIds,
          displayOrder: definition.displayOrder,
          isActive: true,
          keywords: definition.keywords,
        ),
      );
    }

    return tags;
  }

  List<TrendCampaignModel> _buildTrendCampaigns(List<TrendTagModel> tags) {
    final campaigns = <TrendCampaignModel>[];
    final seeds = _campaignDefinitions;
    for (final seed in seeds) {
      final tag = tags.firstWhere(
        (item) => item.id == seed.id,
        orElse: () => TrendTagModel(
          id: seed.id,
          label: seed.hashtagText.en,
          localizedLabelText: seed.hashtagText,
          productIds: const [],
          storeIds: const [],
          displayOrder: seed.displayOrder,
          isActive: true,
        ),
      );
      final previewProducts = _publicProducts
          .where((product) => tag.productIds.contains(product.id))
          .take(4)
          .toList();
      if (previewProducts.isEmpty) {
        continue;
      }
      campaigns.add(
        TrendCampaignModel(
          id: seed.id,
          titleText: seed.titleText,
          subtitleText: seed.subtitleText,
          hashtag: seed.hashtagText.en,
          imageUrl:
              previewProducts.first.imageUrl ??
              (previewProducts.first.imageUrls.isNotEmpty
                  ? previewProducts.first.imageUrls.first
                  : ''),
          productIds: previewProducts.map((product) => product.id).toList(),
          displayOrder: seed.displayOrder,
          isActive: true,
          startAt: DateTime.now().subtract(const Duration(days: 4)),
          endAt: DateTime.now().add(const Duration(days: 18)),
        ),
      );
    }
    campaigns.sort((a, b) => a.displayOrder.compareTo(b.displayOrder));
    return campaigns;
  }

  List<TrendStoreSectionModel> _buildTrendStoreSections(
    List<TrendTagModel> tags,
  ) {
    final sections = <TrendStoreSectionModel>[];
    final now = DateTime.now();

    for (var index = 0; index < _publicStores.length; index++) {
      final store = _publicStores[index];
      final products =
          _publicProducts
              .where((product) => product.storeId == store.id)
              .toList()
            ..sort((a, b) => b.soldCount.compareTo(a.soldCount));
      if (products.isEmpty) {
        continue;
      }

      final relatedTagIds = tags
          .where(
            (tag) =>
                tag.id != 'for_you' &&
                tag.productIds.any(
                  (productId) =>
                      products.any((product) => product.id == productId),
                ),
          )
          .map((tag) => tag.id)
          .take(4)
          .toList();

      final isNew =
          products.any((product) => product.isNew) ||
          store.createdAt.isAfter(now.subtract(const Duration(days: 180)));
      final isTrending =
          store.isFeatured ||
          store.followersCount >= 1800 ||
          products.take(2).any((product) => product.soldCount >= 180);

      sections.add(
        TrendStoreSectionModel(
          storeId: store.id,
          trendTagIds: relatedTagIds,
          featuredProductIds: products
              .take(4)
              .map((product) => product.id)
              .toList(),
          isNew: isNew,
          isTrending: isTrending,
          displayOrder: index,
          reviewPreviewText: _reviewPreviewForStore(store),
        ),
      );
    }

    return sections;
  }

  LocalizedTextModel _reviewPreviewForStore(StoreModel store) {
    switch (store.id) {
      case 'store_seller_2':
        return const LocalizedTextModel(
          en: 'Sharp edits and polished basics that feel ready for everyday wear.',
          ar: 'اختيارات حادة وأساسيات أنيقة تبدو جاهزة للارتداء اليومي.',
        );
      case 'store_seller_3':
        return const LocalizedTextModel(
          en: 'Coastal details and resort-inspired picks with easy charm.',
          ar: 'تفاصيل ساحلية واختيارات مستوحاة من المنتجعات بلمسة مريحة.',
        );
      default:
        return const LocalizedTextModel(
          en: 'Fresh outfits, accessories, and favorites customers keep saving.',
          ar: 'إطلالات وإكسسوارات واختيارات يحب العملاء حفظها باستمرار.',
        );
    }
  }

  bool _matchesProductSearch(ProductModel product) {
    final normalizedQuery = _normalize(searchQuery);
    if (normalizedQuery.isEmpty) {
      return true;
    }
    return _normalize(_productSearchBag(product)).contains(normalizedQuery);
  }

  bool _matchesStoreCategory(
    ProductModel product,
    StoreModel store,
    TrendStoreCategoryOption option,
  ) {
    if (option.id == 'all') {
      return true;
    }
    if (option.departments.isNotEmpty &&
        !option.departments.contains(product.department.toLowerCase()) &&
        !option.departments.contains(product.categoryId.toLowerCase())) {
      return false;
    }
    return _matchesKeywords(
      _productSearchBag(product, store: store),
      option.keywords,
    );
  }

  bool _matchesKeywords(String haystack, List<String> keywords) {
    if (keywords.isEmpty) {
      return false;
    }
    final normalizedHaystack = _normalize(haystack);
    for (final keyword in keywords) {
      if (normalizedHaystack.contains(_normalize(keyword))) {
        return true;
      }
    }
    return false;
  }

  String _productSearchBag(ProductModel product, {StoreModel? store}) {
    final resolvedStore = store ?? storeById(product.storeId);
    return [
      product.title,
      product.titleText.en,
      product.titleText.ar,
      product.description,
      product.descriptionText.en,
      product.descriptionText.ar,
      product.categoryName,
      product.categoryId,
      product.subcategoryName,
      product.department,
      product.sku,
      product.sellerName,
      if (resolvedStore != null) ...[
        resolvedStore.nameText.en,
        resolvedStore.nameText.ar,
        resolvedStore.descriptionText.en,
        resolvedStore.descriptionText.ar,
        resolvedStore.city,
        resolvedStore.businessActivityType,
      ],
      ...product.tags,
    ].join(' ');
  }

  String _normalize(String value) {
    return value
        .toLowerCase()
        .replaceAll(RegExp(r'[\u064B-\u065F\u0670\u06D6-\u06ED]'), '')
        .replaceAll('ـ', '')
        .replaceAll(RegExp(r'[أإآٱ]'), 'ا')
        .replaceAll('ى', 'ي')
        .replaceAll('ؤ', 'و')
        .replaceAll('ئ', 'ي')
        .replaceAll('ة', 'ه')
        .trim();
  }

  List<ProductModel> get _publicProducts {
    final productController = _productController;
    if (productController == null) {
      return const [];
    }
    return productController.marketplaceProducts.where((product) {
      final store = productController.storeForProduct(product);
      final seller = _mockDataService.userById(product.sellerId);
      return store != null &&
          store.isActive &&
          !store.vacationMode &&
          (seller?.isSellerAccountActive ?? true) &&
          _mockDataService.isProductPublic(product);
    }).toList();
  }

  List<StoreModel> get _publicStores {
    final productController = _productController;
    final source = _stores.isNotEmpty
        ? _stores
        : (productController?.publicStores ?? const []);
    return source.where((store) {
      final seller = _mockDataService.userById(store.sellerId);
      return store.isActive &&
          !store.vacationMode &&
          (seller?.isSellerAccountActive ?? true);
    }).toList();
  }

  List<_TrendTagSeed> get _trendTagDefinitions => const [
    _TrendTagSeed(
      id: 'spotlight_sparkle',
      labelText: LocalizedTextModel(en: '#SpotlightSparkle', ar: '#لمعة_مميزة'),
      keywords: ['sparkle', 'jewelry', 'glow', 'earrings', 'necklace', 'ring'],
      displayOrder: 1,
    ),
    _TrendTagSeed(
      id: 'elegance_in_flat_shoes',
      labelText: LocalizedTextModel(
        en: '#EleganceInFlatShoes',
        ar: '#أناقة_الأحذية_المسطحة',
      ),
      keywords: ['flat', 'flats', 'loafer', 'ballet', 'shoe'],
      displayOrder: 2,
    ),
    _TrendTagSeed(
      id: 'bold_steps',
      labelText: LocalizedTextModel(en: '#BoldSteps', ar: '#خطوات_جريئة'),
      keywords: ['heels', 'boots', 'sandals', 'shoe'],
      displayOrder: 3,
    ),
    _TrendTagSeed(
      id: 'retro_styles',
      labelText: LocalizedTextModel(en: '#RetroStyles', ar: '#ستايلات_ريترو'),
      keywords: ['retro', 'classic', 'denim', 'vintage', 'striped'],
      displayOrder: 4,
    ),
    _TrendTagSeed(
      id: 'girls_night_out',
      labelText: LocalizedTextModel(en: '#GirlsNightOut', ar: '#سهرة_البنات'),
      keywords: ['party', 'dress', 'bag', 'glam', 'heels'],
      displayOrder: 5,
    ),
    _TrendTagSeed(
      id: 'old_money_vibe',
      labelText: LocalizedTextModel(en: '#OldMoneyVibe', ar: '#ستايل_النخبة'),
      keywords: ['tailored', 'classic', 'blazer', 'watch', 'neutral'],
      displayOrder: 6,
    ),
    _TrendTagSeed(
      id: 'everyday_elegance_heels',
      labelText: LocalizedTextModel(
        en: '#EverydayEleganceHeels',
        ar: '#أناقة_يومية_بالكعب',
      ),
      keywords: ['heels', 'pumps', 'dress', 'evening'],
      displayOrder: 7,
    ),
    _TrendTagSeed(
      id: 'party_glam',
      labelText: LocalizedTextModel(en: '#PartyGlam', ar: '#بريق_السهرات'),
      keywords: ['makeup', 'dress', 'jewelry', 'bag', 'glam'],
      displayOrder: 8,
    ),
    _TrendTagSeed(
      id: 'workwear_basics',
      labelText: LocalizedTextModel(
        en: '#WorkwearBasics',
        ar: '#أساسيات_العمل',
      ),
      keywords: ['office', 'shirt', 'blazer', 'pants', 'tailored'],
      displayOrder: 9,
    ),
    _TrendTagSeed(
      id: 'ocean_story',
      labelText: LocalizedTextModel(en: '#OceanStory', ar: '#قصة_البحر'),
      keywords: ['beach', 'coastal', 'swim', 'sandals', 'resort'],
      displayOrder: 10,
    ),
    _TrendTagSeed(
      id: 'burgundy_red',
      labelText: LocalizedTextModel(en: '#BurgundyRed', ar: '#أحمر_خمري'),
      keywords: ['red', 'burgundy', 'dress', 'bag'],
      displayOrder: 11,
    ),
    _TrendTagSeed(
      id: 'city_cool',
      labelText: LocalizedTextModel(en: '#CityCool', ar: '#ستايل_المدينة'),
      keywords: ['street', 'casual', 'sneakers', 'bag'],
      displayOrder: 12,
    ),
    _TrendTagSeed(
      id: 'pre_spring_dresses',
      labelText: LocalizedTextModel(
        en: '#PreSpringDresses',
        ar: '#فساتين_قبل_الربيع',
      ),
      keywords: ['dress', 'floral', 'lightweight'],
      displayOrder: 13,
    ),
    _TrendTagSeed(
      id: 'back_to_school',
      labelText: LocalizedTextModel(en: '#BackToSchool', ar: '#العودة_للدراسة'),
      keywords: ['kids', 'backpack', 'stationery', 'sets'],
      displayOrder: 14,
    ),
    _TrendTagSeed(
      id: 'millennial_pink',
      labelText: LocalizedTextModel(en: '#MillennialPink', ar: '#وردي_عصري'),
      keywords: ['pink', 'beauty', 'bag', 'dress'],
      displayOrder: 15,
    ),
    _TrendTagSeed(
      id: 'party_dress',
      labelText: LocalizedTextModel(en: '#PartyDress', ar: '#فستان_السهرات'),
      keywords: ['dress', 'party', 'evening'],
      displayOrder: 16,
    ),
    _TrendTagSeed(
      id: 'hawaiian_charm',
      labelText: LocalizedTextModel(en: '#HawaiianCharm', ar: '#سحر_هاواي'),
      keywords: ['vacation', 'beach', 'tropical', 'coastal'],
      displayOrder: 17,
    ),
    _TrendTagSeed(
      id: 'ethereal_allure',
      labelText: LocalizedTextModel(en: '#EtherealAllure', ar: '#سحر_حالم'),
      keywords: ['jewelry', 'dress', 'beauty', 'shimmer'],
      displayOrder: 18,
    ),
    _TrendTagSeed(
      id: 'prom_season',
      labelText: LocalizedTextModel(en: '#PromSeason', ar: '#موسم_الحفلات'),
      keywords: ['dress', 'heels', 'glam', 'party'],
      displayOrder: 19,
    ),
    _TrendTagSeed(
      id: 'coastal_chic',
      labelText: LocalizedTextModel(en: '#CoastalChic', ar: '#أناقة_ساحلية'),
      keywords: ['coastal', 'home', 'jewelry', 'resort', 'bag'],
      displayOrder: 20,
    ),
  ];

  List<_TrendCampaignSeed> get _campaignDefinitions => const [
    _TrendCampaignSeed(
      id: 'old_money_vibe',
      hashtagText: LocalizedTextModel(
        en: '#ClassicAmericana',
        ar: '#أناقة_كلاسيكية',
      ),
      titleText: LocalizedTextModel(
        en: 'Classic Americana',
        ar: 'أناقة كلاسيكية',
      ),
      subtitleText: LocalizedTextModel(
        en: 'Timeless American spirit with polished everyday pieces.',
        ar: 'روح أمريكية خالدة بقطع يومية أنيقة.',
      ),
      displayOrder: 0,
    ),
    _TrendCampaignSeed(
      id: 'party_glam',
      hashtagText: LocalizedTextModel(en: '#TopTiers', ar: '#الأكثر_رواجًا'),
      titleText: LocalizedTextModel(en: 'Top Tiers', ar: 'الأكثر رواجًا'),
      subtitleText: LocalizedTextModel(
        en: 'Discover elevated edits with high-impact details.',
        ar: 'اكتشف اختيارات مرتفعة الذوق بتفاصيل لافتة.',
      ),
      displayOrder: 1,
    ),
    _TrendCampaignSeed(
      id: 'coastal_chic',
      hashtagText: LocalizedTextModel(en: '#CoastalChic', ar: '#أناقة_ساحلية'),
      titleText: LocalizedTextModel(en: 'Coastal Chic', ar: 'أناقة ساحلية'),
      subtitleText: LocalizedTextModel(
        en: 'Fresh summer favorites with relaxed resort energy.',
        ar: 'اختيارات صيفية منعشة بروح منتجعية مريحة.',
      ),
      displayOrder: 2,
    ),
    _TrendCampaignSeed(
      id: 'spotlight_sparkle',
      hashtagText: LocalizedTextModel(
        en: '#SpotlightSparkle',
        ar: '#لمعة_مميزة',
      ),
      titleText: LocalizedTextModel(en: 'Spotlight Sparkle', ar: 'لمعة مميزة'),
      subtitleText: LocalizedTextModel(
        en: 'Shiny accessories and glam accents for day-to-night looks.',
        ar: 'إكسسوارات لامعة ولمسات براقة لإطلالات النهار والمساء.',
      ),
      displayOrder: 3,
    ),
  ];
}

class _TrendTagSeed {
  const _TrendTagSeed({
    required this.id,
    required this.labelText,
    required this.keywords,
    required this.displayOrder,
  });

  final String id;
  final LocalizedTextModel labelText;
  final List<String> keywords;
  final int displayOrder;
}

class _TrendCampaignSeed {
  const _TrendCampaignSeed({
    required this.id,
    required this.hashtagText,
    required this.titleText,
    required this.subtitleText,
    required this.displayOrder,
  });

  final String id;
  final LocalizedTextModel hashtagText;
  final LocalizedTextModel titleText;
  final LocalizedTextModel subtitleText;
  final int displayOrder;
}
