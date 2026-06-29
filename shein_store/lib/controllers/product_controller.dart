import 'package:flutter/material.dart';

import '../models/product_model.dart';
import '../models/review_model.dart';
import '../models/store_model.dart';
import '../models/user_role.dart';
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

  List<String> get guestRecentlyViewedProductIds =>
      _mockDataService.guestRecentlyViewedProductIds;

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
      final productSubcategoryId = item.subcategoryId.trim().toLowerCase();
      final productSubcategory = item.subcategoryName.trim().toLowerCase();
      final tagMatch = item.tags.any(
        (tag) => tag.trim().toLowerCase() == normalized,
      );
      return productSubcategoryId == normalized ||
          productSubcategory == normalized ||
          tagMatch;
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
      _mockDataService.approvedReviewsForProduct(productId);

  List<ReviewModel> customerReviews(String customerId) =>
      _mockDataService.reviewsByCustomerId(customerId);

  ProductRatingSummary ratingSummaryForProduct(String productId) =>
      _mockDataService.ratingSummaryForProduct(productId);

  bool currentCustomerPurchasedProduct(String productId) {
    final user = _authController?.currentUser;
    if (user == null || user.role != UserRole.customer) {
      return false;
    }
    return _mockDataService.hasValidPurchasedProduct(
      customerId: user.id,
      productId: productId,
    );
  }

  ReviewModel? currentCustomerReviewForProduct(String productId) {
    final user = _authController?.currentUser;
    if (user == null) {
      return null;
    }
    return _mockDataService.findCustomerReviewForProduct(
      customerId: user.id,
      productId: productId,
    );
  }

  ReviewEligibilityResult reviewEligibilityForProduct(String productId) {
    final product = productById(productId);
    if (product == null) {
      return const ReviewEligibilityResult(
        canReview: false,
        reason: ReviewEligibilityReason.productNotFound,
      );
    }
    final user = _authController?.currentUser;
    if (user == null || _authController?.isLoggedIn != true) {
      return const ReviewEligibilityResult(
        canReview: false,
        reason: ReviewEligibilityReason.notLoggedIn,
      );
    }
    if (user.role != UserRole.customer) {
      return const ReviewEligibilityResult(
        canReview: false,
        reason: ReviewEligibilityReason.notCustomer,
      );
    }
    final existing = _mockDataService.findCustomerReviewForProduct(
      customerId: user.id,
      productId: productId,
    );
    if (existing != null) {
      return ReviewEligibilityResult(
        canReview: false,
        reason: ReviewEligibilityReason.alreadyReviewed,
        eligibleOrderId: existing.orderId,
        existingReview: existing,
      );
    }
    final purchased = _mockDataService.hasValidPurchasedProduct(
      customerId: user.id,
      productId: productId,
    );
    if (!purchased) {
      if (_mockDataService.hasCancelledOnlyPurchase(
        customerId: user.id,
        productId: productId,
      )) {
        return const ReviewEligibilityResult(
          canReview: false,
          reason: ReviewEligibilityReason.orderCancelled,
        );
      }
      if (_mockDataService.hasPaymentIncompletePurchase(
        customerId: user.id,
        productId: productId,
      )) {
        return const ReviewEligibilityResult(
          canReview: false,
          reason: ReviewEligibilityReason.paymentNotCompleted,
        );
      }
      return const ReviewEligibilityResult(
        canReview: false,
        reason: ReviewEligibilityReason.notPurchased,
      );
    }
    final order = _mockDataService.eligiblePurchasedOrderForReview(
      customerId: user.id,
      productId: productId,
    );
    if (order == null) {
      return const ReviewEligibilityResult(
        canReview: false,
        reason: ReviewEligibilityReason.notPurchased,
      );
    }
    return ReviewEligibilityResult(
      canReview: true,
      reason: ReviewEligibilityReason.success,
      eligibleOrderId: order.id,
    );
  }

  Future<ReviewActionResult> saveProductReview({
    required String productId,
    required int rating,
    required String comment,
    ReviewModel? existingReview,
    List<String> imagePaths = const [],
  }) async {
    final trimmedComment = comment.trim();
    if (rating < 1 || rating > 5) {
      return const ReviewActionResult(
        success: false,
        message: 'Rating is required.',
      );
    }
    if (trimmedComment.length < 5 || trimmedComment.length > 1000) {
      return const ReviewActionResult(
        success: false,
        message: 'Comment must be between 5 and 1000 characters.',
      );
    }
    final user = _authController?.currentUser;
    if (user == null || user.role != UserRole.customer) {
      return const ReviewActionResult(
        success: false,
        message: 'Only customers can review products.',
      );
    }
    final eligibility = reviewEligibilityForProduct(productId);
    final editing = existingReview != null;
    if (!editing && !eligibility.canReview) {
      return ReviewActionResult(
        success: false,
        message: eligibility.reason.name,
      );
    }
    if (editing && existingReview.customerId != user.id) {
      return const ReviewActionResult(
        success: false,
        message: 'You can edit only your own review.',
      );
    }
    final now = DateTime.now();
    final orderId =
        existingReview?.orderId ?? eligibility.eligibleOrderId ?? '';
    final review = ReviewModel(
      id:
          existingReview?.id ??
          'review_${productId}_${user.id}_${now.microsecondsSinceEpoch}',
      productId: productId,
      orderId: orderId,
      customerId: user.id,
      customerName: user.name,
      customerAvatarUrl: user.avatar.isEmpty ? null : user.avatar,
      rating: rating.toDouble(),
      comment: trimmedComment,
      imagePaths: imagePaths,
      createdAt: existingReview?.createdAt ?? now,
      updatedAt: now,
      status: ReviewStatus.approved,
      isVerifiedPurchase: true,
    );
    _mockDataService.saveProductReview(review);
    notifyListeners();
    return ReviewActionResult(
      success: true,
      message: 'Review saved.',
      review: review,
    );
  }

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
