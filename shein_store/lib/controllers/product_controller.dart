import 'package:flutter/material.dart';

import '../models/product_model.dart';
import '../models/review_model.dart';
import '../models/store_model.dart';
import '../core/helpers/public_product_visibility_helper.dart';
import '../services/mock_data_service.dart';
import '../services/product_service.dart';
import 'auth_controller.dart';

class ProductController extends ChangeNotifier {
  ProductController({
    required ProductService productService,
    required MockDataService mockDataService,
  }) : _productService = productService,
       _mockDataService = mockDataService {
    _mockDataService.addListener(_syncMarketplaceCatalog);
  }

  final ProductService _productService;
  final MockDataService _mockDataService;
  AuthController? _authController;
  List<ProductModel> products = [];
  bool isLoading = false;
  String? errorMessage;

  void bind({required AuthController authController}) {
    _authController = authController;
  }

  Future<void> loadInitialData() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      products = await _productService.fetchProducts();
    } catch (_) {
      errorMessage = 'Unable to load products';
      products = [];
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  List<ProductModel> get marketplaceProducts =>
      List.unmodifiable(products.where(isProductPublic));

  List<StoreModel> get publicStores =>
      _mockDataService.stores
          .where(
            (store) =>
                store.isActive &&
                !store.vacationMode &&
                store.suspendedAt == null &&
                _mockDataService
                        .userById(store.sellerId)
                        ?.isSellerAccountActive !=
                    false,
          )
          .toList()
        ..sort((a, b) => b.rating.compareTo(a.rating));

  StoreModel? storeForProduct(ProductModel product) {
    return _mockDataService.storeById(product.storeId) ??
        _mockDataService.storeBySellerId(product.sellerId);
  }

  StoreModel? storeById(String storeId) => _mockDataService.storeById(storeId);

  bool isProductPublic(ProductModel product) {
    final seller = _mockDataService.userById(product.sellerId);
    final store = storeForProduct(product);
    return PublicProductVisibilityHelper.isProductPublic(
      product: product,
      seller: seller,
      store: store,
    );
  }

  List<ProductModel> productsForStore(String storeId) {
    return marketplaceProducts
        .where(
          (product) =>
              product.storeId == storeId &&
              _mockDataService.isProductPublic(product),
        )
        .toList();
  }

  List<ProductModel> productsByDepartment(String department) {
    final normalized = department.trim().toLowerCase();
    if (normalized.isEmpty || normalized == 'all') {
      return marketplaceProducts;
    }
    return marketplaceProducts
        .where((item) => item.department.toLowerCase() == normalized)
        .toList();
  }

  ProductModel? productById(String? productId) {
    if (productId == null) return null;
    final matches = products.where((item) => item.id == productId);
    return matches.isEmpty ? null : matches.first;
  }

  List<ProductModel> byCategory(String? categoryId) {
    if (categoryId == null) return marketplaceProducts;
    return marketplaceProducts
        .where((item) => item.categoryId == categoryId)
        .toList();
  }

  List<ProductModel> bySubcategory(String? subcategoryId) {
    if (subcategoryId == null || subcategoryId.trim().isEmpty) {
      return marketplaceProducts;
    }
    final normalized = subcategoryId.trim().toLowerCase();
    return marketplaceProducts.where((item) {
      final productSubcategory = item.subcategoryName.trim().toLowerCase();
      final tagMatch = item.tags.any(
        (tag) => tag.trim().toLowerCase() == normalized,
      );
      return productSubcategory == normalized || tagMatch;
    }).toList();
  }

  List<ProductModel> productsForCategoryIds(Iterable<String> categoryIds) {
    final ids = categoryIds
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toSet();
    if (ids.isEmpty) {
      return marketplaceProducts;
    }
    return marketplaceProducts
        .where((item) => ids.contains(item.categoryId))
        .toList();
  }

  List<ProductModel> deals([String? departmentId]) {
    final source = departmentId == null
        ? products
        : productsByDepartment(departmentId);
    return source
        .where((item) => item.oldPrice > item.price || item.discount > 0)
        .toList()
      ..sort((a, b) => b.discount.compareTo(a.discount));
  }

  List<ProductModel> bestSellers([String? departmentId]) {
    final source = departmentId == null
        ? products
        : productsByDepartment(departmentId);
    return List<ProductModel>.from(source)
      ..sort((a, b) => b.soldCount.compareTo(a.soldCount));
  }

  List<ProductModel> newest([String? departmentId]) {
    final source = departmentId == null
        ? products
        : productsByDepartment(departmentId);
    return List<ProductModel>.from(source)..sort(
      (a, b) => (b.publishedAt ?? b.createdAt).compareTo(
        a.publishedAt ?? a.createdAt,
      ),
    );
  }

  List<ProductModel> forYou([String? departmentId]) {
    final source = departmentId == null
        ? products
        : productsByDepartment(departmentId);
    return List<ProductModel>.from(source)..sort((a, b) {
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
  }

  List<ProductModel> flashSale() =>
      marketplaceProducts.where((item) => item.isFlashSale).take(10).toList();

  List<ProductModel> newArrivals() =>
      marketplaceProducts.where((item) => item.isNew).take(12).toList();

  List<ProductModel> recommendations() => marketplaceProducts.take(20).toList();

  List<ProductModel> relatedProducts(ProductModel product) {
    return marketplaceProducts
        .where(
          (item) =>
              item.categoryId == product.categoryId && item.id != product.id,
        )
        .take(8)
        .toList();
  }

  List<ReviewModel> reviewsForProduct(String productId) =>
      _mockDataService.reviews;

  void trackProductView(String? productId) {
    if (productId == null || productId.isEmpty) {
      return;
    }
    final currentUser = _authController?.currentUser;
    if (currentUser == null) {
      final viewed = [
        productId,
        ..._mockDataService.guestRecentlyViewedProductIds.where(
          (item) => item != productId,
        ),
      ].take(24).toList();
      _mockDataService.setGuestRecentlyViewedProductIds(viewed);
      return;
    }
    final viewed = [
      productId,
      ...currentUser.recentlyViewedProductIds.where(
        (item) => item != productId,
      ),
    ].take(24).toList();
    _authController?.replaceUser(
      currentUser.copyWith(recentlyViewedProductIds: viewed),
    );
  }

  Future<void> refreshPublicProducts() => loadInitialData();

  void _syncMarketplaceCatalog() {
    products = _mockDataService.products;
    errorMessage = null;
    if (!isLoading) {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _mockDataService.removeListener(_syncMarketplaceCatalog);
    super.dispose();
  }
}
