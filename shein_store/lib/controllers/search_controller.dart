import 'dart:async';

import 'package:flutter/material.dart';

import '../models/category_model.dart';
import '../models/product_model.dart';
import '../models/store_model.dart';
import '../models/user_role.dart';
import '../services/mock_data_service.dart';
import 'auth_controller.dart';
import 'category_controller.dart';
import 'product_controller.dart';

String normalizeSearchText(String value) {
  var output = value.toLowerCase().trim();
  output = output
      .replaceAll(RegExp(r'[\u064B-\u065F\u0670]'), '')
      .replaceAll('ـ', '')
      .replaceAll(RegExp('[أإآٱ]'), 'ا')
      .replaceAll('ة', 'ه')
      .replaceAll('ى', 'ي')
      .replaceAll('ؤ', 'و')
      .replaceAll('ئ', 'ي')
      .replaceAll(RegExp(r'[^\p{L}\p{N}\s]+', unicode: true), ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
  return output;
}

class SearchController extends ChangeNotifier {
  SearchController({required MockDataService mockDataService})
    : _mockDataService = mockDataService;

  final MockDataService _mockDataService;
  AuthController? _authController;
  ProductController? _productController;
  String? _boundUserId;
  Timer? _debounce;
  String query = '';
  String selectedSort = 'recommended';
  Map<String, dynamic> filters = {};
  List<String> recentSearches = const ['dress', 'sandals', 'home decor'];
  final List<String> hotSearches = const [
    'vacation dresses',
    'office outfits',
    'beauty tools',
    'minimal sneakers',
  ];
  List<ProductModel> results = [];
  List<StoreModel> storeResults = [];
  List<CategoryModel> _categories = const [];

  void bind({
    required AuthController authController,
    required ProductController productController,
    required CategoryController categoryController,
  }) {
    _authController = authController;
    if (!identical(_productController, productController)) {
      _productController?.removeListener(_handleProductCatalogChanged);
      _productController = productController;
      _productController?.addListener(_handleProductCatalogChanged);
    }
    _categories = categoryController.categories;
    final nextUserId = authController.currentUser?.id;
    if (_boundUserId != nextUserId) {
      _boundUserId = nextUserId;
      recentSearches = List<String>.from(
        authController.currentUser?.recentSearches ??
            _mockDataService.guestRecentSearches,
      );
    }
    _runSearch(productController);
    applySort(notify: false);
    notifyListeners();
  }

  void _handleProductCatalogChanged() {
    final productController = _productController;
    if (productController == null) {
      return;
    }
    _runSearch(productController);
    applySort(notify: false);
    notifyListeners();
  }

  void setQuery(String value) {
    query = value;
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), search);
    notifyListeners();
  }

  void search() {
    final productController = _productController;
    if (productController == null) {
      results = [];
      storeResults = [];
      notifyListeners();
      return;
    }
    _runSearch(productController);
    applySort(notify: false);
    notifyListeners();
  }

  void clearQuery() {
    _debounce?.cancel();
    query = '';
    results = _productController?.marketplaceProducts.take(12).toList() ?? [];
    storeResults = [];
    notifyListeners();
  }

  void addRecentSearch(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return;
    recentSearches = [
      trimmed,
      ...recentSearches.where((item) => item != trimmed),
    ].take(8).toList();
    _persistRecentSearches();
    notifyListeners();
  }

  void removeRecentSearch(String value) {
    recentSearches = recentSearches.where((item) => item != value).toList();
    _persistRecentSearches();
    notifyListeners();
  }

  void clearRecentSearches() {
    recentSearches = [];
    _persistRecentSearches();
    notifyListeners();
  }

  void applyFilters([Map<String, dynamic>? values]) {
    if (values != null) {
      filters = values;
    }
    search();
  }

  void setContextFilters(
    Map<String, dynamic> values, {
    bool searchNow = false,
  }) {
    filters = values;
    if (searchNow) {
      search();
    } else {
      notifyListeners();
    }
  }

  void applySort({String? value, bool notify = true}) {
    if (value != null) {
      selectedSort = _normalizeSortId(value);
    }
    switch (selectedSort) {
      case 'newest':
        results.sort(
          (a, b) => (b.publishedAt ?? b.createdAt).compareTo(
            a.publishedAt ?? a.createdAt,
          ),
        );
        break;
      case 'price_asc':
        results.sort((a, b) => a.price.compareTo(b.price));
        break;
      case 'price_desc':
        results.sort((a, b) => b.price.compareTo(a.price));
        break;
      case 'top_rated':
        results.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case 'most_popular':
        results.sort((a, b) => b.soldCount.compareTo(a.soldCount));
        break;
      case 'biggest_discount':
        results.sort((a, b) => b.discount.compareTo(a.discount));
        break;
      default:
        results.sort((a, b) => b.soldCount.compareTo(a.soldCount));
        break;
    }
    if (notify) {
      notifyListeners();
    }
  }

  String _normalizeSortId(String value) {
    return switch (value) {
      'Recommended' => 'recommended',
      'Newest' => 'newest',
      'Price low to high' => 'price_asc',
      'Price high to low' => 'price_desc',
      'Top rated' => 'top_rated',
      'Most popular' => 'most_popular',
      'Biggest discount' => 'biggest_discount',
      _ => value,
    };
  }

  void _persistRecentSearches() {
    final currentUser = _authController?.currentUser;
    if (currentUser == null || currentUser.role == UserRole.guest) {
      _mockDataService.setGuestRecentSearches(recentSearches);
      return;
    }
    _authController?.replaceUser(
      currentUser.copyWith(recentSearches: List<String>.from(recentSearches)),
    );
  }

  void _runSearch(ProductController productController) {
    final products = productController.marketplaceProducts;
    if (query.trim().isEmpty) {
      results = _applyFilters(products.take(12).toList());
      storeResults = [];
      return;
    }
    results = _applyFilters(_searchProducts(products, query));
    storeResults = _searchStores(productController.publicStores, query);
  }

  List<ProductModel> _searchProducts(
    List<ProductModel> products,
    String value,
  ) {
    final normalizedQuery = normalizeSearchText(value);
    if (normalizedQuery.isEmpty) {
      return products;
    }
    final scored = <_ScoredProduct>[];
    for (final product in products) {
      final store =
          _mockDataService.storeById(product.storeId) ??
          _mockDataService.storeBySellerId(product.sellerId);
      final category = _categoryById(product.categoryId);
      final score = _scoreFields(normalizedQuery, [
        product.title,
        product.titleText.en,
        product.titleText.ar,
        product.description,
        product.descriptionText.en,
        product.descriptionText.ar,
        product.sku,
        product.categoryId,
        product.categoryName,
        product.subcategoryId,
        product.subcategoryName,
        product.department,
        category?.nameText.en ?? '',
        category?.nameText.ar ?? '',
        category?.subcategories.join(' ') ?? '',
        product.tags.join(' '),
        product.sellerName,
        store?.nameText.en ?? '',
        store?.nameText.ar ?? '',
        store?.storeSlug ?? '',
        store?.city ?? '',
        store?.addressText.en ?? '',
        store?.addressText.ar ?? '',
        store?.businessActivityType ?? '',
      ]);
      if (score > 0) {
        scored.add(
          _ScoredProduct(
            product: product,
            score:
                score +
                product.rating.clamp(0, 5).round() +
                (product.soldCount / 100).clamp(0, 6).round() +
                (product.stock > 0 ? 2 : 0) +
                (product.discount > 0 ? 1 : 0),
          ),
        );
      }
    }
    scored.sort((a, b) => b.score.compareTo(a.score));
    return scored.map((item) => item.product).toList();
  }

  List<StoreModel> _searchStores(List<StoreModel> stores, String value) {
    final normalizedQuery = normalizeSearchText(value);
    if (normalizedQuery.isEmpty) {
      return const [];
    }
    final scored = <_ScoredStore>[];
    for (final store in stores) {
      final seller = _mockDataService.userById(store.sellerId);
      final score = _scoreFields(normalizedQuery, [
        store.nameText.en,
        store.nameText.ar,
        store.storeSlug,
        seller?.name ?? '',
        store.businessActivityType,
        store.city,
        store.descriptionText.en,
        store.descriptionText.ar,
        store.addressText.en,
        store.addressText.ar,
      ]);
      if (score > 0) {
        scored.add(
          _ScoredStore(
            store: store,
            score:
                score +
                store.rating.clamp(0, 5).round() +
                (store.productsCount / 20).clamp(0, 4).round(),
          ),
        );
      }
    }
    scored.sort((a, b) => b.score.compareTo(a.score));
    return scored.map((item) => item.store).toList();
  }

  int _scoreFields(String normalizedQuery, List<String> fields) {
    final queryTokens = normalizedQuery
        .split(' ')
        .where((token) => token.trim().isNotEmpty)
        .toList();
    var bestScore = 0;
    var combinedScore = 0;
    for (final field in fields) {
      final normalizedField = normalizeSearchText(field);
      if (normalizedField.isEmpty) {
        continue;
      }
      var score = 0;
      if (normalizedField == normalizedQuery) {
        score += 120;
      } else if (normalizedField.startsWith(normalizedQuery)) {
        score += 95;
      } else if (normalizedField.contains(normalizedQuery)) {
        score += 76;
      }
      final fieldTokens = normalizedField.split(' ');
      for (final queryToken in queryTokens) {
        if (fieldTokens.contains(queryToken)) {
          score += 34;
        } else if (fieldTokens.any((token) => token.startsWith(queryToken))) {
          score += 24;
        } else if (fieldTokens.any((token) => token.contains(queryToken))) {
          score += 16;
        } else if (fieldTokens.any(
          (token) => _isSmallTypo(queryToken, token),
        )) {
          score += 10;
        }
      }
      bestScore = score > bestScore ? score : bestScore;
      combinedScore += score;
    }
    final score = bestScore + (combinedScore / 8).round();
    return score < 10 ? 0 : score;
  }

  bool _isSmallTypo(String queryToken, String candidate) {
    if (queryToken.length < 4 || candidate.length < 4) {
      return false;
    }
    final lengthDelta = (queryToken.length - candidate.length).abs();
    if (lengthDelta > 2) {
      return false;
    }
    final distance = _editDistance(queryToken, candidate);
    return distance <= (queryToken.length <= 6 ? 1 : 2);
  }

  int _editDistance(String a, String b) {
    final previous = List<int>.generate(b.length + 1, (index) => index);
    for (var i = 0; i < a.length; i++) {
      var diagonal = previous[0];
      previous[0] = i + 1;
      for (var j = 0; j < b.length; j++) {
        final oldDiagonal = previous[j + 1];
        final cost = a[i] == b[j] ? 0 : 1;
        previous[j + 1] = [
          previous[j + 1] + 1,
          previous[j] + 1,
          diagonal + cost,
        ].reduce((value, element) => value < element ? value : element);
        diagonal = oldDiagonal;
      }
    }
    return previous[b.length];
  }

  CategoryModel? _categoryById(String categoryId) {
    final matches = _categories.where((category) => category.id == categoryId);
    return matches.isEmpty ? null : matches.first;
  }

  List<ProductModel> _applyFilters(List<ProductModel> products) {
    return products.where((product) {
      final store =
          _mockDataService.storeById(product.storeId) ??
          _mockDataService.storeBySellerId(product.sellerId);
      final department =
          filters['departmentId'] as String? ??
          filters['department'] as String?;
      final category =
          filters['categoryId'] as String? ?? filters['category'] as String?;
      final subcategory =
          filters['subcategoryId'] as String? ??
          filters['subcategory'] as String?;
      final storeId = filters['store'] as String?;
      final size = filters['size'] as String?;
      final color = filters['color'] as String?;
      final minPrice = (filters['minPrice'] as num?)?.toDouble();
      final maxPrice = (filters['maxPrice'] as num?)?.toDouble();
      final minRating = (filters['minRating'] as num?)?.toDouble();
      final minStoreRating = (filters['minStoreRating'] as num?)?.toDouble();
      final inStock = filters['inStock'] == true;
      final saleOnly = filters['saleOnly'] == true;
      final newArrivals = filters['newArrivals'] == true;

      if (department != null &&
          department.isNotEmpty &&
          product.department != department) {
        return false;
      }
      if (category != null &&
          category.isNotEmpty &&
          product.categoryId != category &&
          product.categoryName != category) {
        return false;
      }
      if (subcategory != null &&
          subcategory.isNotEmpty &&
          product.subcategoryId != subcategory &&
          product.subcategoryName != subcategory &&
          !product.tags.contains(subcategory)) {
        return false;
      }
      if (storeId != null && storeId.isNotEmpty && product.storeId != storeId) {
        return false;
      }
      if (size != null && size.isNotEmpty && !product.sizes.contains(size)) {
        return false;
      }
      if (color != null &&
          color.isNotEmpty &&
          !product.colors.contains(color)) {
        return false;
      }
      if (minPrice != null && product.price < minPrice) {
        return false;
      }
      if (maxPrice != null && product.price > maxPrice) {
        return false;
      }
      final realRating =
          _productController
              ?.ratingSummaryForProduct(product.id)
              .averageRating ??
          product.rating;
      if (minRating != null && realRating < minRating) {
        return false;
      }
      if (minStoreRating != null && (store?.rating ?? 0) < minStoreRating) {
        return false;
      }
      if (inStock && product.stock <= 0) {
        return false;
      }
      if (saleOnly && product.discount <= 0) {
        return false;
      }
      if (newArrivals && !product.isNew) {
        return false;
      }
      return true;
    }).toList();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _productController?.removeListener(_handleProductCatalogChanged);
    super.dispose();
  }
}

class _ScoredProduct {
  const _ScoredProduct({required this.product, required this.score});

  final ProductModel product;
  final int score;
}

class _ScoredStore {
  const _ScoredStore({required this.store, required this.score});

  final StoreModel store;
  final int score;
}
