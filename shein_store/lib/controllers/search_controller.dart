import 'dart:async';

import 'package:flutter/material.dart';

import '../models/product_model.dart';
import '../models/user_role.dart';
import '../services/mock_data_service.dart';
import 'auth_controller.dart';
import 'category_controller.dart';
import 'product_controller.dart';

String normalizeSearchText(String value) {
  var output = value.toLowerCase().trim();
  output = output.replaceAll(RegExp(r'\s+'), ' ');
  output = output
      .replaceAll(RegExp(r'[\u064B-\u065F\u0670]'), '')
      .replaceAll('ـ', '')
      .replaceAll(RegExp('[أإآ]'), 'ا')
      .replaceAll('ى', 'ي')
      .replaceAll('ؤ', 'و')
      .replaceAll('ئ', 'ي')
      .replaceAll('ة', 'ه');
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
  String selectedSort = 'Recommended';
  Map<String, dynamic> filters = {};
  List<String> recentSearches = const ['dress', 'sandals', 'home decor'];
  final List<String> hotSearches = const [
    'vacation dresses',
    'office outfits',
    'beauty tools',
    'minimal sneakers',
  ];
  List<ProductModel> results = [];

  void bind({
    required AuthController authController,
    required ProductController productController,
    required CategoryController categoryController,
  }) {
    _authController = authController;
    _productController = productController;
    final nextUserId = authController.currentUser?.id;
    if (_boundUserId != nextUserId) {
      _boundUserId = nextUserId;
      recentSearches = List<String>.from(
        authController.currentUser?.recentSearches ??
            _mockDataService.guestRecentSearches,
      );
    }
    results = query.trim().isEmpty
        ? productController.marketplaceProducts.take(12).toList()
        : _searchProducts(productController.marketplaceProducts, query);
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
    final products = _productController?.marketplaceProducts ?? [];
    final searched = _searchProducts(products, query);
    results = _applyFilters(searched);
    applySort(notify: false);
    notifyListeners();
  }

  void clearQuery() {
    _debounce?.cancel();
    query = '';
    results = _productController?.marketplaceProducts.take(12).toList() ?? [];
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
      selectedSort = value;
    }
    switch (selectedSort) {
      case 'Newest':
        results.sort(
          (a, b) => (b.publishedAt ?? b.createdAt).compareTo(
            a.publishedAt ?? a.createdAt,
          ),
        );
        break;
      case 'Price low to high':
        results.sort((a, b) => a.price.compareTo(b.price));
        break;
      case 'Price high to low':
        results.sort((a, b) => b.price.compareTo(a.price));
        break;
      case 'Top rated':
        results.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case 'Most popular':
        results.sort((a, b) => b.soldCount.compareTo(a.soldCount));
        break;
      case 'Biggest discount':
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

  List<ProductModel> _searchProducts(
    List<ProductModel> products,
    String value,
  ) {
    final normalizedQuery = normalizeSearchText(value);
    if (normalizedQuery.isEmpty) {
      return products;
    }
    return products.where((product) {
      final store =
          _mockDataService.storeById(product.storeId) ??
          _mockDataService.storeBySellerId(product.sellerId);
      final haystack = normalizeSearchText(
        [
          product.title,
          product.titleText.en,
          product.titleText.ar,
          product.description,
          product.descriptionText.en,
          product.descriptionText.ar,
          product.sku,
          product.categoryName,
          product.department,
          product.tags.join(' '),
          product.sellerName,
          store?.nameText.en ?? '',
          store?.nameText.ar ?? '',
          store?.city ?? '',
          store?.addressText.en ?? '',
          store?.addressText.ar ?? '',
          store?.businessActivityType ?? '',
        ].join(' '),
      );
      return haystack.contains(normalizedQuery);
    }).toList();
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
      if (minRating != null && product.rating < minRating) {
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
    super.dispose();
  }
}
