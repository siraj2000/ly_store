import 'dart:async';

import 'package:flutter/foundation.dart';

import '../core/helpers/public_product_visibility_helper.dart';
import '../core/config/loyalty_policy.dart';
import '../models/address_model.dart';
import '../models/app_preferences_model.dart';
import '../models/category_model.dart';
import '../models/coupon_model.dart';
import '../models/customer_points_transaction_model.dart';
import '../models/gift_card_model.dart';
import '../models/localized_text_model.dart';
import '../models/notification_model.dart';
import '../models/order_item_model.dart';
import '../models/order_model.dart';
import '../models/payment_method_model.dart';
import '../models/product_model.dart';
import '../models/product_status.dart';
import '../models/review_model.dart';
import '../models/seller_order_model.dart';
import '../models/store_model.dart';
import '../models/store_review_model.dart';
import '../models/user_model.dart';
import '../models/user_role.dart';
import '../models/wallet_transaction_model.dart';
import '../models/wishlist_model.dart';
import 'local_storage_service.dart';

class MockDataService extends ChangeNotifier {
  MockDataService._(this._localStorageService);

  static const String _appStateKey = 'stylehub_app_state';
  static const String _seedVersionKey = 'ly_store_seed_version';
  static const int _seedDataVersion = 3;
  static final List<String> _mojibakeMarkers = [
    '\u00C3',
    '\u00D8',
    '\u00D9',
    '\u00EF\u00BF\u00BD',
    '\uFFFD',
    String.fromCharCodes([0x3F, 0x3F, 0x3F, 0x3F]),
  ];
  static const List<String> _womenClothingSubcategories = [
    'Blouses',
    'T-Shirts',
    'Shirts',
    'Crop Tops',
    'Knit Tops',
    'Jeans',
    'Wide Leg Pants',
    'Skirts',
    'Shorts',
    'Leggings',
    'Underwear',
    'Sports Bra',
    'Pajama Set',
    'Nightdress',
    'Lightweight Cardigan',
    'Denim Jacket',
  ];

  final LocalStorageService _localStorageService;

  late AppPreferencesModel _preferences;
  late List<ProductModel> _allProducts;
  late List<StoreModel> _stores;
  Map<String, UserModel> _mockUsersByEmail = {};
  late List<OrderModel> _platformOrders;
  late List<SellerOrderModel> _sellerOrders;
  late List<String> _promoBannerPool;
  late List<CategoryModel> _categories;
  late List<CouponModel> _coupons;
  late List<GiftCardModel> _giftCards;
  late List<NotificationModel> _genericNotifications;
  late List<ReviewModel> _reviews;
  late List<StoreReviewModel> _storeReviews;
  UserModel? _currentSessionUser;
  List<String> _guestRecentSearches = const ['dress', 'sandals', 'home decor'];
  List<String> _guestRecentlyViewedProductIds = const [];

  // Temporary images for UI preview only. Replace with API image URLs later.
  final Map<String, List<String>> _temporaryImageGalleries = const {
    'women': [
      'https://images.unsplash.com/photo-1525507119028-ed4c629a60a3?auto=format&fit=crop&w=900&q=80',
      'https://images.unsplash.com/photo-1515886657613-9f3515b0c78f?auto=format&fit=crop&w=900&q=80',
      'https://images.unsplash.com/photo-1496747611176-843222e1e57c?auto=format&fit=crop&w=900&q=80',
      'https://images.unsplash.com/photo-1483985988355-763728e1935b?auto=format&fit=crop&w=900&q=80',
    ],
    'curve': [
      'https://images.unsplash.com/photo-1512436991641-6745cdb1723f?auto=format&fit=crop&w=900&q=80',
      'https://images.unsplash.com/photo-1523381210434-271e8be1f52b?auto=format&fit=crop&w=900&q=80',
      'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?auto=format&fit=crop&w=900&q=80',
      'https://images.unsplash.com/photo-1492707892479-7bc8d5a4ee93?auto=format&fit=crop&w=900&q=80',
    ],
    'men': [
      'https://images.unsplash.com/photo-1506629905607-d7e297d879e4?auto=format&fit=crop&w=900&q=80',
      'https://images.unsplash.com/photo-1516826957135-700dedea698c?auto=format&fit=crop&w=900&q=80',
      'https://images.unsplash.com/photo-1517841905240-472988babdf9?auto=format&fit=crop&w=900&q=80',
      'https://images.unsplash.com/photo-1617137968427-85924c800a22?auto=format&fit=crop&w=900&q=80',
    ],
    'kids': [
      'https://images.unsplash.com/photo-1519238359922-989348752efb?auto=format&fit=crop&w=900&q=80',
      'https://images.unsplash.com/photo-1514090458221-65bb69cf63e6?auto=format&fit=crop&w=900&q=80',
      'https://images.unsplash.com/photo-1519345182560-3f2917c472ef?auto=format&fit=crop&w=900&q=80',
      'https://images.unsplash.com/photo-1503919545889-aef636e10ad4?auto=format&fit=crop&w=900&q=80',
    ],
    'beauty': [
      'https://images.unsplash.com/photo-1596462502278-27bfdc403348?auto=format&fit=crop&w=900&q=80',
      'https://images.unsplash.com/photo-1590874103328-eac38a683ce7?auto=format&fit=crop&w=900&q=80',
      'https://images.unsplash.com/photo-1522335789203-aabd1fc54bc9?auto=format&fit=crop&w=900&q=80',
      'https://images.unsplash.com/photo-1526045478516-99145907023c?auto=format&fit=crop&w=900&q=80',
    ],
    'home': [
      'https://images.unsplash.com/photo-1556905055-8f358a7a47b2?auto=format&fit=crop&w=900&q=80',
      'https://images.unsplash.com/photo-1505693416388-ac5ce068fe85?auto=format&fit=crop&w=900&q=80',
      'https://images.unsplash.com/photo-1484101403633-562f891dc89a?auto=format&fit=crop&w=900&q=80',
      'https://images.unsplash.com/photo-1505693416388-ac5ce068fe85?auto=format&fit=crop&w=900&q=80',
    ],
    'kitchen': [
      'https://images.unsplash.com/photo-1556909114-f6e7ad7d3136?auto=format&fit=crop&w=900&q=80',
      'https://images.unsplash.com/photo-1484154218962-a197022b5858?auto=format&fit=crop&w=900&q=80',
      'https://images.unsplash.com/photo-1502741338009-cac2772e18bc?auto=format&fit=crop&w=900&q=80',
      'https://images.unsplash.com/photo-1513694203232-719a280e022f?auto=format&fit=crop&w=900&q=80',
    ],
    'house': [
      'https://images.unsplash.com/photo-1494526585095-c41746248156?auto=format&fit=crop&w=900&q=80',
      'https://images.unsplash.com/photo-1505693416388-ac5ce068fe85?auto=format&fit=crop&w=900&q=80',
      'https://images.unsplash.com/photo-1484101403633-562f891dc89a?auto=format&fit=crop&w=900&q=80',
      'https://images.unsplash.com/photo-1505693416388-ac5ce068fe85?auto=format&fit=crop&w=900&q=80',
    ],
    'shoes': [
      'https://images.unsplash.com/photo-1542291026-7eec264c27ff?auto=format&fit=crop&w=900&q=80',
      'https://images.unsplash.com/photo-1543163521-1bf539c55dd2?auto=format&fit=crop&w=900&q=80',
      'https://images.unsplash.com/photo-1600185365483-26d7a4cc7519?auto=format&fit=crop&w=900&q=80',
      'https://images.unsplash.com/photo-1549298916-b41d501d3772?auto=format&fit=crop&w=900&q=80',
    ],
    'jewelry': [
      'https://images.unsplash.com/photo-1617038220319-276d3cfab638?auto=format&fit=crop&w=900&q=80',
      'https://images.unsplash.com/photo-1611085583191-a3b181a88401?auto=format&fit=crop&w=900&q=80',
      'https://images.unsplash.com/photo-1617038260897-41a1f14a8ca0?auto=format&fit=crop&w=900&q=80',
      'https://images.unsplash.com/photo-1611652022419-a9419f74343d?auto=format&fit=crop&w=900&q=80',
    ],
    'bags': [
      'https://images.unsplash.com/photo-1548036328-c9fa89d128fa?auto=format&fit=crop&w=900&q=80',
      'https://images.unsplash.com/photo-1584917865442-de89df76afd3?auto=format&fit=crop&w=900&q=80',
      'https://images.unsplash.com/photo-1591561954557-26941169b49e?auto=format&fit=crop&w=900&q=80',
      'https://images.unsplash.com/photo-1581605405669-fcdf81165afa?auto=format&fit=crop&w=900&q=80',
    ],
    'electronics': [
      'https://images.unsplash.com/photo-1511499767150-a48a237f0083?auto=format&fit=crop&w=900&q=80',
      'https://images.unsplash.com/photo-1511707171634-5f897ff02aa9?auto=format&fit=crop&w=900&q=80',
      'https://images.unsplash.com/photo-1580910051074-3eb694886505?auto=format&fit=crop&w=900&q=80',
      'https://images.unsplash.com/photo-1546868871-7041f2a55e12?auto=format&fit=crop&w=900&q=80',
    ],
    'sale': [
      'https://images.unsplash.com/photo-1523381210434-271e8be1f52b?auto=format&fit=crop&w=900&q=80',
      'https://images.unsplash.com/photo-1512436991641-6745cdb1723f?auto=format&fit=crop&w=900&q=80',
      'https://images.unsplash.com/photo-1483985988355-763728e1935b?auto=format&fit=crop&w=900&q=80',
      'https://images.unsplash.com/photo-1525507119028-ed4c629a60a3?auto=format&fit=crop&w=900&q=80',
    ],
    'default': [
      'https://images.unsplash.com/photo-1525507119028-ed4c629a60a3?auto=format&fit=crop&w=900&q=80',
      'https://images.unsplash.com/photo-1515886657613-9f3515b0c78f?auto=format&fit=crop&w=900&q=80',
      'https://images.unsplash.com/photo-1542291026-7eec264c27ff?auto=format&fit=crop&w=900&q=80',
      'https://images.unsplash.com/photo-1556905055-8f358a7a47b2?auto=format&fit=crop&w=900&q=80',
    ],
  };

  static Future<MockDataService> create({
    required LocalStorageService localStorageService,
  }) async {
    final service = MockDataService._(localStorageService);
    await service._initialize();
    return service;
  }

  Future<void> _initialize() async {
    final snapshot = _localStorageService.getJson(_appStateKey);
    final storedSeedVersion =
        _localStorageService.getInt(_seedVersionKey) ??
        (snapshot?['seedVersion'] as int? ?? 0);
    if (snapshot == null) {
      _seedDefaults();
      await _persistState();
    } else if (storedSeedVersion < _seedDataVersion ||
        _containsMojibake(snapshot)) {
      final preservedPreferences = _preferencesFromSnapshot(snapshot);
      _seedDefaults();
      if (preservedPreferences != null) {
        _preferences = preservedPreferences;
      }
      await _persistState();
    } else {
      _restoreSnapshot(snapshot);
    }
    final savedUser = await _localStorageService.getUser();
    if (savedUser == null) {
      return;
    }
    _currentSessionUser =
        userById(savedUser.id) ?? userByEmail(savedUser.email);
    if (_currentSessionUser != null) {
      await _localStorageService.saveUser(_currentSessionUser!);
    }
  }

  void _seedDefaults() {
    _preferences = const AppPreferencesModel(
      country: 'United States',
      language: 'English',
      currency: 'USD',
    );
    _promoBannerPool = const [
      'Summer Essentials',
      'New Season Layers',
      'Weekend Getaway',
      'Beauty Bestsellers',
      'Home Mood Reset',
      'Deal Drop',
    ];
    _categories = _buildInitialCategories();
    _coupons = _buildInitialCoupons();
    _giftCards = _buildInitialGiftCards();
    _genericNotifications = _buildInitialNotifications();
    _reviews = const [];
    _storeReviews = _buildInitialStoreReviews();
    _guestRecentSearches = const ['dress', 'sandals', 'home decor'];
    _guestRecentlyViewedProductIds = const [];
    _seedProducts();
    _seedStores();
    _seedUsers();
    _platformOrders = List<OrderModel>.from(demoOrders);
    _sellerOrders = _buildSellerOrdersFromOrders(_platformOrders);
    _reviews = _buildInitialReviews();
    _recalculateAllStoreRatings();
    _currentSessionUser = null;
  }

  AppPreferencesModel get preferences => _preferences;

  set preferences(AppPreferencesModel value) {
    _preferences = value;
    unawaited(_persistState());
  }

  List<String> get promoBanners => List.unmodifiable(_promoBannerPool);
  List<CategoryModel> get categories =>
      List.unmodifiable(_categoriesWithPreviewImages(_categories));
  List<CouponModel> get coupons => List.unmodifiable(_coupons);
  List<StoreModel> get stores => List.unmodifiable(_stores);
  List<NotificationModel> get genericNotifications =>
      List.unmodifiable(_genericNotifications);
  List<ReviewModel> get reviews => List.unmodifiable(_reviews);
  List<StoreReviewModel> get storeReviews => List.unmodifiable(_storeReviews);
  List<SellerOrderModel> get sellerOrders => List.unmodifiable(_sellerOrders);
  List<String> get guestRecentSearches =>
      List.unmodifiable(_guestRecentSearches);
  List<String> get guestRecentlyViewedProductIds =>
      List.unmodifiable(_guestRecentlyViewedProductIds);
  UserModel? get currentSessionUser => _currentSessionUser;

  List<ReviewModel> reviewsForProduct(String productId) {
    return _reviews.where((review) => review.productId == productId).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  List<ReviewModel> approvedReviewsForProduct(String productId) {
    return reviewsForProduct(
      productId,
    ).where((review) => review.status == ReviewStatus.approved).toList();
  }

  List<ReviewModel> reviewsByCustomerId(String customerId) {
    return _reviews.where((review) => review.customerId == customerId).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  ReviewModel? findCustomerReviewForProduct({
    required String customerId,
    required String productId,
    String? orderId,
  }) {
    final matches = _reviews.where(
      (review) =>
          review.customerId == customerId &&
          review.productId == productId &&
          (orderId == null || review.orderId == orderId),
    );
    return matches.isEmpty ? null : matches.first;
  }

  ProductRatingSummary ratingSummaryForProduct(String productId) {
    final productReviews = approvedReviewsForProduct(
      productId,
    ).where((review) => review.rating >= 1 && review.rating <= 5).toList();
    if (productReviews.isEmpty) {
      return ProductRatingSummary.empty;
    }
    final breakdown = {5: 0, 4: 0, 3: 0, 2: 0, 1: 0};
    var total = 0.0;
    for (final review in productReviews) {
      total += review.rating;
      final star = review.rating.round().clamp(1, 5);
      breakdown[star] = (breakdown[star] ?? 0) + 1;
    }
    final average = double.parse(
      (total / productReviews.length).toStringAsFixed(1),
    );
    return ProductRatingSummary(
      averageRating: average,
      reviewCount: productReviews.length,
      ratingBreakdown: breakdown,
    );
  }

  OrderModel? eligiblePurchasedOrderForReview({
    required String customerId,
    required String productId,
  }) {
    final orders = ordersForCustomer(customerId);
    for (final order in orders) {
      if (_isValidReviewPurchase(order, productId)) {
        return order;
      }
    }
    return null;
  }

  OrderModel? eligibleDeliveredOrderForReview({
    required String customerId,
    required String productId,
  }) {
    return eligiblePurchasedOrderForReview(
      customerId: customerId,
      productId: productId,
    );
  }

  bool hasPurchasedProduct({
    required String customerId,
    required String productId,
  }) {
    return ordersForCustomer(
      customerId,
    ).any((order) => order.items.any((item) => item.product.id == productId));
  }

  bool hasValidPurchasedProduct({
    required String customerId,
    required String productId,
  }) {
    return ordersForCustomer(
      customerId,
    ).any((order) => _isValidReviewPurchase(order, productId));
  }

  bool hasPaymentIncompletePurchase({
    required String customerId,
    required String productId,
  }) {
    return ordersForCustomer(customerId).any((order) {
      final containsProduct = order.items.any(
        (item) => item.product.id == productId && item.quantity > 0,
      );
      return containsProduct &&
          !_isCancelledOrFailedOrder(order) &&
          !_isPaymentCompleteOrActive(order);
    });
  }

  bool hasCancelledOnlyPurchase({
    required String customerId,
    required String productId,
  }) {
    return ordersForCustomer(customerId).any((order) {
      final containsProduct = order.items.any(
        (item) => item.product.id == productId && item.quantity > 0,
      );
      return containsProduct && _isCancelledOrFailedOrder(order);
    });
  }

  bool _isValidReviewPurchase(OrderModel order, String productId) {
    final containsProduct = order.items.any(
      (item) => item.product.id == productId && item.quantity > 0,
    );
    return containsProduct &&
        !_isCancelledOrFailedOrder(order) &&
        _isPaymentCompleteOrActive(order);
  }

  bool _isCancelledOrFailedOrder(OrderModel order) {
    final blockedStatuses = {
      'cancelled',
      'failed',
      'refunded',
      'returned',
      'returns',
      'return requested',
    };
    final status = order.status.trim().toLowerCase();
    final shippingStatus = order.shippingStatus.trim().toLowerCase();
    return blockedStatuses.contains(status) ||
        blockedStatuses.contains(shippingStatus);
  }

  bool _isPaymentCompleteOrActive(OrderModel order) {
    final paidPaymentStatuses = {'paid', 'completed', 'captured'};
    final activeOrderStatuses = {
      'paid',
      'processing',
      'readytoship',
      'ready to ship',
      'shipped',
      'delivered',
      'completed',
      'confirmedreceived',
      'confirmed received',
      'review',
    };
    final status = order.status.trim().toLowerCase();
    final paymentStatus = order.paymentStatus.trim().toLowerCase();
    final shippingStatus = order.shippingStatus.trim().toLowerCase();
    return paidPaymentStatuses.contains(paymentStatus) ||
        activeOrderStatuses.contains(status) ||
        activeOrderStatuses.contains(shippingStatus);
  }

  void saveProductReview(ReviewModel review) {
    final existingIndex = _reviews.indexWhere((item) => item.id == review.id);
    final duplicateIndex = _reviews.indexWhere(
      (item) =>
          item.customerId == review.customerId &&
          item.productId == review.productId,
    );
    final nextReview = review.copyWith(
      updatedAt: existingIndex == -1 && duplicateIndex == -1
          ? review.updatedAt
          : DateTime.now(),
    );
    if (existingIndex != -1) {
      _reviews[existingIndex] = nextReview;
    } else if (duplicateIndex != -1) {
      _reviews[duplicateIndex] = nextReview;
    } else {
      _reviews = [nextReview, ..._reviews];
    }
    unawaited(_persistState());
    notifyListeners();
  }

  void setGuestRecentSearches(List<String> values) {
    _guestRecentSearches = List<String>.from(values);
    unawaited(_persistState());
  }

  void setGuestRecentlyViewedProductIds(List<String> values) {
    _guestRecentlyViewedProductIds = List<String>.from(values);
    unawaited(_persistState());
  }

  Future<void> setCurrentSessionUser(UserModel? user) async {
    _currentSessionUser = user;
    if (user == null) {
      await _localStorageService.clearUserSession();
      return;
    }
    await _localStorageService.saveUser(user);
  }

  Future<void> clearCurrentSession() async {
    _currentSessionUser = null;
    await _localStorageService.clearUserSession();
  }

  List<ProductModel> get products => _productsWithExtras(
    _allProducts,
  ).where((product) => isProductPublic(product)).toList();

  List<ProductModel> get allProducts =>
      List.unmodifiable(_productsWithExtras(_allProducts));

  List<UserModel> get allUsers => _mockUsersByEmail.values.toList();

  UserModel? userById(String userId) {
    final matches = _mockUsersByEmail.values.where((user) => user.id == userId);
    return matches.isEmpty ? null : matches.first;
  }

  UserModel? userByEmail(String email) =>
      _mockUsersByEmail[email.toLowerCase()];

  UserModel? userByEmailOrPhone(String emailOrPhone) {
    final normalized = emailOrPhone.trim().toLowerCase();
    if (normalized.isEmpty) {
      return null;
    }
    final byEmail = userByEmail(normalized);
    if (byEmail != null) {
      return byEmail;
    }
    final normalizedPhone = _digitsOnly(normalized);
    if (normalizedPhone.isEmpty) {
      return null;
    }
    for (final user in _mockUsersByEmail.values) {
      if (_digitsOnly(user.phone) == normalizedPhone) {
        return user;
      }
    }
    return null;
  }

  String _digitsOnly(String value) => value.replaceAll(RegExp(r'[^0-9]'), '');

  Future<void> addUser(UserModel user) async {
    _mockUsersByEmail[user.email.toLowerCase()] = user;
    await _persistState();
  }

  List<CategoryModel> _categoriesWithPreviewImages(List<CategoryModel> source) {
    final hydrated = source
        .map(
          (category) => category.copyWith(
            imageUrl: (category.imageUrl?.trim().isNotEmpty ?? false)
                ? category.imageUrl
                : _temporaryCategoryImageFor(category.id),
          ),
        )
        .toList();
    return _categoriesWithExtras(hydrated);
  }

  List<CategoryModel> _categoriesWithExtras(List<CategoryModel> source) {
    final items = List<CategoryModel>.from(source);
    final existingIds = items.map((item) => item.id).toSet();
    for (final extra in _extraMarketplaceCategories()) {
      if (!existingIds.contains(extra.id)) {
        items.add(extra.copyWith(displayOrder: items.length));
      }
    }
    return items;
  }

  List<ProductModel> _productsWithExtras(List<ProductModel> source) {
    final items = List<ProductModel>.from(source);
    final existingIds = items.map((item) => item.id).toSet();
    for (final extra in _supplementalMarketplaceProducts()) {
      if (!existingIds.contains(extra.id)) {
        items.add(extra);
      }
    }
    return items;
  }

  List<CategoryModel> _extraMarketplaceCategories() => [
    CategoryModel(
      id: 'kitchen',
      departmentId: 'kitchen',
      nameText: const LocalizedTextModel(en: 'Kitchen', ar: 'المطبخ'),
      descriptionText: const LocalizedTextModel(
        en: 'Temporary category images for UI preview only. Replace with API-managed category images later.',
        ar: 'صور تصنيفات مؤقتة لمعاينة الواجهة فقط. استبدلها لاحقاً بصور التصنيفات القادمة من الواجهة البرمجية.',
      ),
      imageUrl: _temporaryImageGalleries['kitchen']!.first,
      subcategories: const [
        'Cookware',
        'Storage',
        'Tableware',
        'Utensils',
        'Lighting',
        'Decor',
      ],
      bannerTitle: 'Fresh picks for Kitchen',
      displayOrder: 999,
    ),
    CategoryModel(
      id: 'house',
      departmentId: 'house',
      nameText: const LocalizedTextModel(en: 'House', ar: 'المنزل والمعيشة'),
      descriptionText: const LocalizedTextModel(
        en: 'Temporary category images for UI preview only. Replace with API-managed category images later.',
        ar: 'صور تصنيفات مؤقتة لمعاينة الواجهة فقط. استبدلها لاحقاً بصور التصنيفات القادمة من الواجهة البرمجية.',
      ),
      imageUrl: _temporaryImageGalleries['house']!.first,
      subcategories: const [
        'Decor',
        'Bedding',
        'Storage',
        'Lighting',
        'Wall Art',
        'Throws',
      ],
      bannerTitle: 'Fresh picks for House',
      displayOrder: 1000,
    ),
  ];

  List<ProductModel> _supplementalMarketplaceProducts() {
    final kitchenCategory = _extraMarketplaceCategories().firstWhere(
      (category) => category.id == 'kitchen',
    );
    final houseCategory = _extraMarketplaceCategories().firstWhere(
      (category) => category.id == 'house',
    );

    return [
      ProductModel(
        id: 'product_kitchen_1',
        sellerId: 'seller_3',
        sellerName: 'Coastal Edit',
        storeId: 'store_seller_3',
        title: 'Modern Kitchen Starter Set',
        titleText: const LocalizedTextModel(
          en: 'Modern Kitchen Starter Set',
          ar: 'طقم مطبخ عصري للمبتدئين',
        ),
        categoryId: kitchenCategory.id,
        categoryName: kitchenCategory.name,
        department: kitchenCategory.department,
        price: 48.50,
        oldPrice: 62.50,
        discount: 22,
        rating: 4.6,
        reviewCount: 88,
        imageUrls: _temporaryImageGalleries['kitchen']!,
        colors: const ['White', 'Black'],
        sizes: const ['One Size'],
        description:
            'A countertop-ready kitchen set for everyday cooking and easy storage.',
        descriptionText: const LocalizedTextModel(
          en: 'A countertop-ready kitchen set for everyday cooking and easy storage.',
          ar: 'طقم مطبخ جاهز للاستخدام اليومي مع تخزين سهل وتنظيم أنيق.',
        ),
        material: 'Stainless Steel',
        materialText: const LocalizedTextModel(
          en: 'Stainless Steel',
          ar: 'ستانلس ستيل',
        ),
        composition: 'Steel, Silicone',
        compositionText: const LocalizedTextModel(
          en: 'Steel, Silicone',
          ar: 'فولاذ وسيليكون',
        ),
        careInstructions: 'Hand wash recommended.',
        careInstructionsText: const LocalizedTextModel(
          en: 'Hand wash recommended.',
          ar: 'ينصح بالغسل اليدوي.',
        ),
        sku: 'SH-KITCHEN-001',
        stock: 24,
        tags: const ['Home', 'Kitchen', 'New Arrival'],
        isNew: true,
        isHot: true,
        isFlashSale: false,
        soldCount: 142,
        status: ProductStatus.active,
        isActive: true,
        views: 480,
        createdAt: DateTime.now().subtract(const Duration(days: 18)),
        updatedAt: DateTime.now().subtract(const Duration(days: 2)),
        publishedAt: DateTime.now().subtract(const Duration(days: 14)),
        countryOfOrigin: 'United States',
        lowStockThreshold: 5,
      ),
      ProductModel(
        id: 'product_house_1',
        sellerId: 'seller_1',
        sellerName: 'Demo Seller',
        storeId: 'store_seller_1',
        title: 'Soft House Comfort Bundle',
        titleText: const LocalizedTextModel(
          en: 'Soft House Comfort Bundle',
          ar: 'باقة راحة منزلية ناعمة',
        ),
        categoryId: houseCategory.id,
        categoryName: houseCategory.name,
        department: houseCategory.department,
        price: 79.25,
        oldPrice: 99.25,
        discount: 20,
        rating: 4.7,
        reviewCount: 104,
        imageUrls: _temporaryImageGalleries['house']!,
        colors: const ['Beige', 'Ivory'],
        sizes: const ['One Size'],
        description:
            'Layered home accents designed to make bedrooms and living corners feel calmer.',
        descriptionText: const LocalizedTextModel(
          en: 'Layered home accents designed to make bedrooms and living corners feel calmer.',
          ar: 'لمسات منزلية متعددة الطبقات تمنح غرف النوم وزوايا المعيشة إحساساً أهدأ.',
        ),
        material: 'Cotton Blend',
        materialText: const LocalizedTextModel(
          en: 'Cotton Blend',
          ar: 'خليط قطن',
        ),
        composition: 'Cotton, Polyester',
        compositionText: const LocalizedTextModel(
          en: 'Cotton, Polyester',
          ar: 'قطن وبوليستر',
        ),
        careInstructions: 'Machine wash cold.',
        careInstructionsText: const LocalizedTextModel(
          en: 'Machine wash cold.',
          ar: 'يغسل على البارد في الغسالة.',
        ),
        sku: 'SH-HOUSE-001',
        stock: 18,
        tags: const ['House', 'Decor', 'Best Seller'],
        isNew: false,
        isHot: true,
        isFlashSale: true,
        soldCount: 211,
        status: ProductStatus.active,
        isActive: true,
        views: 560,
        createdAt: DateTime.now().subtract(const Duration(days: 26)),
        updatedAt: DateTime.now().subtract(const Duration(days: 3)),
        publishedAt: DateTime.now().subtract(const Duration(days: 20)),
        countryOfOrigin: 'United States',
        lowStockThreshold: 5,
      ),
    ];
  }

  void _seedProducts() {
    final sellerRoster = [
      ('seller_1', 'Demo Seller', 'store_seller_1'),
      ('seller_2', 'Northline Studio', 'store_seller_2'),
      ('seller_3', 'Coastal Edit', 'store_seller_3'),
    ];
    final palette = [
      ['Rose', 'Black', 'Ivory'],
      ['Sage', 'Cream', 'Mocha'],
      ['Sky', 'Navy', 'White'],
      ['Coral', 'Sand', 'Ink'],
    ];
    final sizeSets = [
      ['XS', 'S', 'M', 'L'],
      ['S', 'M', 'L', 'XL'],
      ['28', '30', '32', '34'],
      ['One Size'],
    ];
    final titles = [
      'Ruched Midi Dress',
      'Relaxed Linen Shirt',
      'Wide Leg Trousers',
      'Soft Knit Cardigan',
      'Tailored Vest Set',
      'Everyday Crossbody Bag',
      'Glow Edit Skincare Kit',
      'Minimal Runner Sneakers',
      'Coastal Bedding Bundle',
      'Stackable Rings Set',
    ];
    final arabicTitles = [
      'فستان ميدي بكشكشة',
      'قميص كتان مريح',
      'بنطال واسع الساق',
      'كارديغان محبوك ناعم',
      'طقم فيست مفصل',
      'حقيبة كروس يومية',
      'مجموعة عناية Glow Edit',
      'سنيكرز جري بسيط',
      'طقم مفروشات ساحلي',
      'طقم خواتم قابلة للتكديس',
    ];

    _allProducts = List.generate(40, (index) {
      final category = _categories[index % _categories.length];
      final seller = sellerRoster[index % sellerRoster.length];
      final basePrice = 12 + (index * 3.75);
      final oldPrice = basePrice + 6 + (index % 5) * 4;
      final englishTitle = '${titles[index % titles.length]} ${index + 1}';
      final arabicTitle =
          '${arabicTitles[index % arabicTitles.length]} ${index + 1}';
      final seededSubcategory = category.subcategories.isEmpty
          ? ''
          : category.subcategories[index % category.subcategories.length];
      const englishDescription =
          'An original LY STORE pick built for easy styling, comfort, and day-to-night layering.';
      const arabicDescription =
          'اختيار أصلي من LY STORE مصمم للتنسيق السهل والراحة والانتقال الأنيق من النهار إلى المساء.';
      final englishMaterial = index.isEven ? 'Cotton Blend' : 'Polyester Blend';
      final arabicMaterial = index.isEven ? 'خليط قطن' : 'خليط بوليستر';
      final englishComposition = index.isEven
          ? '65% Cotton, 35% Rayon'
          : '100% Polyester';
      final arabicComposition = index.isEven
          ? '65% قطن، 35% رايون'
          : '100% بوليستر';
      const englishCare = 'Machine wash cold, line dry.';
      const arabicCare = 'يغسل بالغسالة على البارد ويجفف بالتعليق.';
      return ProductModel(
        id: 'product_$index',
        sellerId: seller.$1,
        sellerName: seller.$2,
        storeId: seller.$3,
        title: englishTitle,
        titleText: LocalizedTextModel(en: englishTitle, ar: arabicTitle),
        categoryId: category.id,
        categoryName: category.name,
        department: category.department,
        subcategoryName: seededSubcategory,
        price: basePrice,
        oldPrice: oldPrice,
        discount: ((1 - (basePrice / oldPrice)) * 100).round(),
        rating: 3.8 + (index % 12) * 0.1,
        reviewCount: 24 + index * 7,
        imageUrls: _galleryForProduct(
          category.name,
          titles[index % titles.length],
        ),
        colors: palette[index % palette.length],
        sizes: sizeSets[index % sizeSets.length],
        description: englishDescription,
        descriptionText: const LocalizedTextModel(
          en: englishDescription,
          ar: arabicDescription,
        ),
        material: englishMaterial,
        materialText: LocalizedTextModel(
          en: englishMaterial,
          ar: arabicMaterial,
        ),
        composition: englishComposition,
        compositionText: LocalizedTextModel(
          en: englishComposition,
          ar: arabicComposition,
        ),
        careInstructions: englishCare,
        careInstructionsText: const LocalizedTextModel(
          en: englishCare,
          ar: arabicCare,
        ),
        sku: 'SH-${1000 + index}',
        stock: 6 + (index % 10) * 3,
        tags: [
          if (index % 2 == 0) 'Hot',
          if (index % 3 == 0) 'Flash Sale',
          if (index % 5 == 0) 'New Arrival',
        ],
        isNew: index % 5 == 0,
        isHot: index % 2 == 0,
        isFlashSale: index % 3 == 0,
        soldCount: 180 + index * 11,
        status: ProductStatus.active,
        isActive: true,
        views: 200 + index * 13,
        createdAt: DateTime.now().subtract(Duration(days: 90 - (index % 40))),
        updatedAt: DateTime.now().subtract(Duration(days: index % 14)),
        publishedAt: DateTime.now().subtract(Duration(days: 60 - (index % 25))),
        countryOfOrigin: 'United States',
        lowStockThreshold: 5,
        complaintCount: index % 13 == 0 ? 1 : 0,
        returnRate: (index % 6) * 0.01,
      );
    });

    final kitchenCategory = _extraMarketplaceCategories().firstWhere(
      (category) => category.id == 'kitchen',
    );
    final houseCategory = _extraMarketplaceCategories().firstWhere(
      (category) => category.id == 'house',
    );

    _allProducts.addAll([
      ProductModel(
        id: 'product_kitchen_1',
        sellerId: 'seller_3',
        sellerName: 'Coastal Edit',
        storeId: 'store_seller_3',
        title: 'Modern Kitchen Starter Set',
        titleText: const LocalizedTextModel(
          en: 'Modern Kitchen Starter Set',
          ar: 'طقم مطبخ عصري للمبتدئين',
        ),
        categoryId: kitchenCategory.id,
        categoryName: kitchenCategory.name,
        department: kitchenCategory.department,
        subcategoryName: 'Cookware',
        price: 48.50,
        oldPrice: 62.50,
        discount: 22,
        rating: 4.6,
        reviewCount: 88,
        imageUrls: _temporaryImageGalleries['kitchen']!,
        colors: const ['White', 'Black'],
        sizes: const ['One Size'],
        description:
            'A countertop-ready kitchen set for everyday cooking and easy storage.',
        descriptionText: const LocalizedTextModel(
          en: 'A countertop-ready kitchen set for everyday cooking and easy storage.',
          ar: 'طقم مطبخ جاهز للاستخدام اليومي مع تخزين سهل وتنظيم أنيق.',
        ),
        material: 'Stainless Steel',
        materialText: const LocalizedTextModel(
          en: 'Stainless Steel',
          ar: 'ستانلس ستيل',
        ),
        composition: 'Steel, Silicone',
        compositionText: const LocalizedTextModel(
          en: 'Steel, Silicone',
          ar: 'فولاذ وسيليكون',
        ),
        careInstructions: 'Hand wash recommended.',
        careInstructionsText: const LocalizedTextModel(
          en: 'Hand wash recommended.',
          ar: 'ينصح بالغسل اليدوي.',
        ),
        sku: 'SH-KITCHEN-001',
        stock: 24,
        tags: const ['Home', 'Kitchen', 'New Arrival'],
        isNew: true,
        isHot: true,
        isFlashSale: false,
        soldCount: 142,
        status: ProductStatus.active,
        isActive: true,
        views: 480,
        createdAt: DateTime.now().subtract(const Duration(days: 18)),
        updatedAt: DateTime.now().subtract(const Duration(days: 2)),
        publishedAt: DateTime.now().subtract(const Duration(days: 14)),
        countryOfOrigin: 'United States',
        lowStockThreshold: 5,
      ),
      ProductModel(
        id: 'product_house_1',
        sellerId: 'seller_1',
        sellerName: 'Demo Seller',
        storeId: 'store_seller_1',
        title: 'Soft House Comfort Bundle',
        titleText: const LocalizedTextModel(
          en: 'Soft House Comfort Bundle',
          ar: 'باقة راحة منزلية ناعمة',
        ),
        categoryId: houseCategory.id,
        categoryName: houseCategory.name,
        department: houseCategory.department,
        subcategoryName: 'Decor',
        price: 79.25,
        oldPrice: 99.25,
        discount: 20,
        rating: 4.7,
        reviewCount: 104,
        imageUrls: _temporaryImageGalleries['house']!,
        colors: const ['Beige', 'Ivory'],
        sizes: const ['One Size'],
        description:
            'Layered home accents designed to make bedrooms and living corners feel calmer.',
        descriptionText: const LocalizedTextModel(
          en: 'Layered home accents designed to make bedrooms and living corners feel calmer.',
          ar: 'لمسات منزلية متعددة الطبقات تمنح غرف النوم وزوايا المعيشة إحساساً أهدأ.',
        ),
        material: 'Cotton Blend',
        materialText: const LocalizedTextModel(
          en: 'Cotton Blend',
          ar: 'خليط قطن',
        ),
        composition: 'Cotton, Polyester',
        compositionText: const LocalizedTextModel(
          en: 'Cotton, Polyester',
          ar: 'قطن وبوليستر',
        ),
        careInstructions: 'Machine wash cold.',
        careInstructionsText: const LocalizedTextModel(
          en: 'Machine wash cold.',
          ar: 'يغسل على البارد في الغسالة.',
        ),
        sku: 'SH-HOUSE-001',
        stock: 18,
        tags: const ['House', 'Decor', 'Best Seller'],
        isNew: false,
        isHot: true,
        isFlashSale: true,
        soldCount: 211,
        status: ProductStatus.active,
        isActive: true,
        views: 560,
        createdAt: DateTime.now().subtract(const Duration(days: 26)),
        updatedAt: DateTime.now().subtract(const Duration(days: 3)),
        publishedAt: DateTime.now().subtract(const Duration(days: 20)),
        countryOfOrigin: 'United States',
        lowStockThreshold: 5,
      ),
    ]);
  }

  void _seedStores() {
    final now = DateTime.now();
    _stores = [
      StoreModel(
        id: 'store_seller_1',
        sellerId: 'seller_1',
        nameText: const LocalizedTextModel(
          en: 'Demo Seller',
          ar: 'متجر البائع التجريبي',
        ),
        descriptionText: const LocalizedTextModel(
          en: 'Original daily-wear edits with easy silhouettes and polished basics.',
          ar: 'تصميمات يومية أصلية بقصّات سهلة وأساسيات أنيقة.',
        ),
        policiesText: const LocalizedTextModel(
          en: '7-day returns and marketplace chat support.',
          ar: 'إرجاع خلال 7 أيام ودعم عبر محادثة السوق.',
        ),
        rating: 4.3,
        reviewCount: 284,
        followersCount: 0,
        isActive: true,
        isFeatured: true,
        isVerified: true,
        addressText: const LocalizedTextModel(
          en: '125 Willow Ave, Austin, Texas',
          ar: '125 ويلو أفينيو، أوستن، تكساس',
        ),
        storePhone: '+1 555 0111',
        city: 'Austin',
        countryCode: 'US',
        businessActivityType: 'clothing',
        commissionPercentage: 12,
        allowedCategoryIds: const ['women', 'dresses', 'tops', 'sale'],
        createdAt: now.subtract(const Duration(days: 300)),
        updatedAt: now.subtract(const Duration(days: 2)),
      ),
      StoreModel(
        id: 'store_seller_2',
        sellerId: 'seller_2',
        nameText: const LocalizedTextModel(
          en: 'Northline Studio',
          ar: 'نورث لاين ستوديو',
        ),
        descriptionText: const LocalizedTextModel(
          en: 'Contemporary layers, workwear edits, and tailored staples.',
          ar: 'طبقات عصرية وإطلالات عمل وقطع أساسية مفصلة.',
        ),
        policiesText: const LocalizedTextModel(
          en: 'Fast dispatch and tracked domestic shipping.',
          ar: 'شحن سريع مع تتبع محلي للطلبات.',
        ),
        rating: 4.6,
        reviewCount: 196,
        followersCount: 0,
        isActive: true,
        isVerified: true,
        addressText: const LocalizedTextModel(
          en: '44 Cedar Street, Dallas, Texas',
          ar: '44 شارع سيدار، دالاس، تكساس',
        ),
        storePhone: '+1 555 0112',
        city: 'Dallas',
        countryCode: 'US',
        businessActivityType: 'mixed',
        commissionPercentage: 11,
        allowedCategoryIds: const ['men', 'men-trends', 'shoes', 'bags'],
        createdAt: now.subtract(const Duration(days: 260)),
        updatedAt: now.subtract(const Duration(days: 4)),
      ),
      StoreModel(
        id: 'store_seller_3',
        sellerId: 'seller_3',
        nameText: const LocalizedTextModel(
          en: 'Coastal Edit',
          ar: 'كوستال إيدت',
        ),
        descriptionText: const LocalizedTextModel(
          en: 'Beach-ready home, jewelry, and relaxed resort details.',
          ar: 'منتجات منزلية وإكسسوارات ولمسات منتجع مريحة.',
        ),
        policiesText: const LocalizedTextModel(
          en: 'Quality review before dispatch and seller-backed returns.',
          ar: 'مراجعة جودة قبل الشحن وإرجاع بدعم من البائع.',
        ),
        rating: 4.4,
        reviewCount: 143,
        followersCount: 0,
        isActive: true,
        isFeatured: true,
        addressText: const LocalizedTextModel(
          en: '89 Shoreline Drive, Miami, Florida',
          ar: '89 شورلاين درايف، ميامي، فلوريدا',
        ),
        storePhone: '+1 555 0113',
        city: 'Miami',
        countryCode: 'US',
        businessActivityType: 'accessories',
        commissionPercentage: 13,
        allowedCategoryIds: const ['home', 'jewelry', 'bags', 'beauty'],
        createdAt: now.subtract(const Duration(days: 220)),
        updatedAt: now.subtract(const Duration(days: 5)),
      ),
    ];
  }

  List<String> _galleryForProduct(String categoryName, String title) {
    final key = _galleryKey(categoryName, title);
    return _temporaryImageGalleries[key] ??
        _temporaryImageGalleries['default']!;
  }

  String _galleryKey(String categoryName, String title) {
    final category = categoryName.toLowerCase();
    final productTitle = title.toLowerCase();
    if (productTitle.contains('dress') || productTitle.contains('cardigan')) {
      return category.contains('curve') ? 'curve' : 'women';
    }
    if (productTitle.contains('bag')) {
      return 'bags';
    }
    if (productTitle.contains('sneaker') || category.contains('shoe')) {
      return 'shoes';
    }
    if (productTitle.contains('skincare') || category.contains('beauty')) {
      return 'beauty';
    }
    if (category.contains('men')) {
      return 'men';
    }
    if (category.contains('kids')) {
      return 'kids';
    }
    if (category.contains('home')) {
      return 'home';
    }
    if (category.contains('electronic')) {
      return 'electronics';
    }
    if (category.contains('jewelry')) {
      return 'jewelry';
    }
    if (category.contains('sale')) {
      return 'sale';
    }
    if (category.contains('curve')) {
      return 'curve';
    }
    return 'default';
  }

  bool isProductPublic(ProductModel product) {
    final seller = userById(product.sellerId);
    final store = storeById(product.storeId);
    return PublicProductVisibilityHelper.isProductPublic(
      product: product,
      seller: seller,
      store: store,
    );
  }

  List<AddressModel> get demoAddresses => const [
    AddressModel(
      id: 'address_1',
      fullName: 'Demo Customer',
      phone: '+1 555 0100',
      country: 'United States',
      city: 'Austin',
      region: 'Texas',
      streetAddress: '125 Willow Ave',
      postalCode: '73301',
      isDefault: true,
    ),
    AddressModel(
      id: 'address_2',
      fullName: 'Demo Customer',
      phone: '+1 555 0100',
      country: 'United States',
      city: 'Dallas',
      region: 'Texas',
      streetAddress: '44 Cedar Street',
      postalCode: '75001',
    ),
  ];

  List<PaymentMethodModel> get paymentMethods => const [
    PaymentMethodModel(
      id: 'pay_1',
      brand: 'Visa',
      maskedNumber: '**** 1122',
      token: 'tok_visa_1122',
      isDefault: true,
    ),
    PaymentMethodModel(
      id: 'pay_2',
      brand: 'Mastercard',
      maskedNumber: '**** 4455',
      token: 'tok_master_4455',
    ),
    PaymentMethodModel(
      id: 'pay_3',
      brand: 'PayPal',
      maskedNumber: 'PayPal',
      token: 'tok_paypal',
    ),
  ];

  List<WalletTransactionModel> get walletTransactions => [
    WalletTransactionModel(
      id: 'wallet_1',
      title: 'Welcome Credit',
      amount: 8,
      type: 'credit',
      direction: 'credit',
      status: 'completed',
      description: 'Welcome Credit',
      currency: LoyaltyPolicy.currency,
      balanceAfter: 8,
      createdAt: DateTime.now().subtract(const Duration(days: 8)),
    ),
    WalletTransactionModel(
      id: 'wallet_2',
      title: 'Order Discount Applied',
      amount: -4,
      type: 'debit',
      direction: 'debit',
      status: 'completed',
      description: 'Order Discount Applied',
      currency: LoyaltyPolicy.currency,
      balanceAfter: 4,
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
    ),
  ];

  List<GiftCardModel> get giftCards => List.unmodifiable(_giftCards);

  int redeemedGiftCardCount(String customerId) {
    return _giftCards
        .where((card) => card.isRedeemed && card.redeemedBy == customerId)
        .length;
  }

  GiftCardRedeemResult redeemGiftCard({
    required String customerId,
    required String code,
  }) {
    final normalizedCode = code.trim().toUpperCase();
    final customer = userById(customerId);
    if (customer == null) {
      return const GiftCardRedeemResult.failure('customer_not_found');
    }
    if (normalizedCode.isEmpty) {
      return const GiftCardRedeemResult.failure('empty_code');
    }
    final index = _giftCards.indexWhere(
      (card) => card.code.toUpperCase() == normalizedCode,
    );
    if (index == -1) {
      return const GiftCardRedeemResult.failure('invalid_code');
    }
    final card = _giftCards[index];
    if (card.isRedeemed) {
      return const GiftCardRedeemResult.failure('already_redeemed');
    }
    if (!card.isActive || card.status != 'active') {
      return const GiftCardRedeemResult.failure('inactive');
    }
    if (card.isExpired) {
      return const GiftCardRedeemResult.failure('expired');
    }

    final now = DateTime.now();
    final nextBalance = customer.walletBalance + card.amount;
    final transaction = WalletTransactionModel(
      id: 'wallet_gift_${card.id}_${now.microsecondsSinceEpoch}',
      title: 'Gift card ${card.code}',
      amount: card.amount,
      type: 'gift_card',
      customerId: customer.id,
      giftCardId: card.id,
      direction: 'credit',
      status: 'completed',
      description: 'Gift card ${card.code} redeemed',
      currency: card.currency,
      balanceAfter: nextBalance,
      createdAt: now,
    );
    final updatedCustomer = customer.copyWith(
      walletBalance: nextBalance,
      walletTransactions: [transaction, ...customer.walletTransactions],
      updatedAt: now,
    );
    _giftCards[index] = card.copyWith(
      isRedeemed: true,
      redeemedBy: customer.id,
      redeemedAt: now,
      status: 'redeemed',
    );
    updateUser(updatedCustomer);
    createNotification(
      NotificationModel(
        id: 'notif_gift_${card.id}_${now.microsecondsSinceEpoch}',
        recipientUserId: customer.id,
        recipientRole: UserRole.customer,
        type: NotificationType.generic,
        entityType: 'giftCard',
        entityId: card.id,
        route: '/wallet',
        data: {
          'amount': card.amount,
          'currency': card.currency,
          'code': card.code,
        },
        createdAt: now,
        legacyTitle: 'Gift card redeemed',
        legacyMessage:
            '${card.amount.toStringAsFixed(2)} ${card.currency} added to your wallet.',
      ),
    );
    notifyListeners();
    return GiftCardRedeemResult.success(
      card: _giftCards[index],
      user: userById(customer.id) ?? updatedCustomer,
      transaction: transaction,
    );
  }

  WishlistBoardModel get _defaultWishlistBoard => const WishlistBoardModel(
    id: 'board_saved',
    name: 'Saved',
    productIds: [],
  );

  static const List<String> _superAdminPermissions = ['*'];
  static const List<String> _managerPermissions = [
    'dashboard.view',
    'sellers.view',
    'sellers.create',
    'sellers.edit',
    'sellers.activate',
    'sellers.approve',
    'sellers.suspend',
    'sellers.resetPassword',
    'products.view',
    'products.approve',
    'products.reject',
    'orders.view',
    'orders.update',
    'reports.view',
    'stores.view',
    'stores.create',
    'stores.edit',
    'stores.activate',
    'stores.suspend',
  ];
  static const List<String> _catalogPermissions = [
    'dashboard.view',
    'products.view',
    'products.approve',
    'products.reject',
    'sellers.view',
  ];
  static const List<String> _financePermissions = [
    'dashboard.view',
    'orders.view',
    'refunds.approve',
    'reports.view',
    'audit.view',
  ];
  static const List<String> _supportPermissions = [
    'dashboard.view',
    'support.manage',
    'orders.view',
    'sellers.view',
  ];
  static const List<String> _compliancePermissions = [
    'dashboard.view',
    'products.view',
    'compliance.manage',
    'audit.view',
  ];
  static const List<String> _riskPermissions = [
    'dashboard.view',
    'orders.view',
    'risk.manage',
    'reports.view',
    'audit.view',
  ];

  void _seedUsers() {
    // Mock credentials for local development only. Replace with secure backend authentication and token storage.
    _mockUsersByEmail = {
      'customer@stylehub.com': UserModel(
        id: 'customer_1',
        name: 'Demo Customer',
        email: 'customer@stylehub.com',
        phone: '+1 555 0100',
        role: UserRole.customer,
        avatar: '',
        isActive: true,
        createdAt: DateTime.now().subtract(const Duration(days: 180)),
        points: 120,
        walletBalance: 14,
        coupons: [_coupons.first, _coupons[2]],
        orders: demoOrders,
        addresses: demoAddresses,
        paymentMethods: paymentMethods,
        wishlistProductIds: const ['product_1', 'product_4'],
        walletTransactions: walletTransactions,
        cart: const [],
        wishlistBoards: [_defaultWishlistBoard],
        notifications: _genericNotifications,
        recentSearches: const ['dress', 'summer layers'],
        recentlyViewedProductIds: const ['product_1', 'product_3'],
        mockPassword: '123456',
      ),
      'seller@stylehub.com': UserModel(
        id: 'seller_1',
        name: 'Demo Seller',
        email: 'seller@stylehub.com',
        phone: '+1 555 0111',
        role: UserRole.seller,
        avatar: '',
        isActive: true,
        createdAt: DateTime.now().subtract(const Duration(days: 300)),
        updatedAt: DateTime.now().subtract(const Duration(days: 2)),
        points: 0,
        walletBalance: 0,
        coupons: const [],
        orders: const [],
        addresses: demoAddresses.take(1).toList(),
        paymentMethods: paymentMethods.take(1).toList(),
        wishlistProductIds: const [],
        walletTransactions: const [],
        cart: const [],
        wishlistBoards: const [],
        notifications: const [],
        recentSearches: const [],
        recentlyViewedProductIds: const [],
        mockPassword: '123456',
        linkedStoreId: 'store_seller_1',
        storeDescription:
            'Original daily-wear edits with easy silhouettes and polished basics.',
      ),
      'northline@stylehub.com': UserModel(
        id: 'seller_2',
        name: 'Northline Studio',
        email: 'northline@stylehub.com',
        phone: '+1 555 0112',
        role: UserRole.seller,
        avatar: '',
        isActive: true,
        createdAt: DateTime.now().subtract(const Duration(days: 260)),
        updatedAt: DateTime.now().subtract(const Duration(days: 3)),
        points: 0,
        walletBalance: 0,
        coupons: const [],
        orders: const [],
        addresses: demoAddresses.take(1).toList(),
        paymentMethods: paymentMethods.take(1).toList(),
        wishlistProductIds: const [],
        walletTransactions: const [],
        cart: const [],
        wishlistBoards: const [],
        notifications: const [],
        recentSearches: const [],
        recentlyViewedProductIds: const [],
        mockPassword: '123456',
        linkedStoreId: 'store_seller_2',
        storeDescription:
            'Contemporary layers, workwear edits, and tailored staples.',
      ),
      'coastal@stylehub.com': UserModel(
        id: 'seller_3',
        name: 'Coastal Edit',
        email: 'coastal@stylehub.com',
        phone: '+1 555 0113',
        role: UserRole.seller,
        avatar: '',
        isActive: true,
        createdAt: DateTime.now().subtract(const Duration(days: 220)),
        updatedAt: DateTime.now().subtract(const Duration(days: 5)),
        points: 0,
        walletBalance: 0,
        coupons: const [],
        orders: const [],
        addresses: demoAddresses.take(1).toList(),
        paymentMethods: paymentMethods.take(1).toList(),
        wishlistProductIds: const [],
        walletTransactions: const [],
        cart: const [],
        wishlistBoards: const [],
        notifications: const [],
        recentSearches: const [],
        recentlyViewedProductIds: const [],
        mockPassword: '123456',
        linkedStoreId: 'store_seller_3',
        storeDescription:
            'Beach-ready home, jewelry, and relaxed resort details.',
      ),
      'admin@stylehub.com': UserModel(
        id: 'admin_1',
        name: 'Demo Admin',
        email: 'admin@stylehub.com',
        phone: '+1 555 0999',
        role: UserRole.admin,
        avatar: '',
        isActive: true,
        createdAt: DateTime.now().subtract(const Duration(days: 500)),
        points: 0,
        walletBalance: 0,
        coupons: const [],
        orders: const [],
        addresses: const [],
        paymentMethods: const [],
        wishlistProductIds: const [],
        walletTransactions: const [],
        cart: const [],
        wishlistBoards: const [],
        notifications: const [],
        recentSearches: const [],
        recentlyViewedProductIds: const [],
        mockPassword: '123456',
        adminRoleName: 'Marketplace Manager',
        adminPermissionIds: _managerPermissions,
      ),
      'superadmin@stylehub.com': UserModel(
        id: 'admin_super_1',
        name: 'StyleHub Super Admin',
        email: 'superadmin@stylehub.com',
        phone: '+1 555 1000',
        role: UserRole.admin,
        avatar: '',
        isActive: true,
        createdAt: DateTime.now().subtract(const Duration(days: 520)),
        points: 0,
        walletBalance: 0,
        coupons: const [],
        orders: const [],
        addresses: const [],
        paymentMethods: const [],
        wishlistProductIds: const [],
        walletTransactions: const [],
        cart: const [],
        wishlistBoards: const [],
        notifications: const [],
        recentSearches: const [],
        recentlyViewedProductIds: const [],
        mockPassword: '123456',
        adminRoleName: 'Super Admin',
        adminPermissionIds: _superAdminPermissions,
      ),
      'manager@stylehub.com': UserModel(
        id: 'admin_manager_1',
        name: 'Marketplace Manager',
        email: 'manager@stylehub.com',
        phone: '+1 555 1001',
        role: UserRole.admin,
        avatar: '',
        isActive: true,
        createdAt: DateTime.now().subtract(const Duration(days: 480)),
        points: 0,
        walletBalance: 0,
        coupons: const [],
        orders: const [],
        addresses: const [],
        paymentMethods: const [],
        wishlistProductIds: const [],
        walletTransactions: const [],
        cart: const [],
        wishlistBoards: const [],
        notifications: const [],
        recentSearches: const [],
        recentlyViewedProductIds: const [],
        mockPassword: '123456',
        adminRoleName: 'Marketplace Manager',
        adminPermissionIds: _managerPermissions,
      ),
      'catalog@stylehub.com': UserModel(
        id: 'admin_catalog_1',
        name: 'Catalog Moderator',
        email: 'catalog@stylehub.com',
        phone: '+1 555 1002',
        role: UserRole.admin,
        avatar: '',
        isActive: true,
        createdAt: DateTime.now().subtract(const Duration(days: 450)),
        points: 0,
        walletBalance: 0,
        coupons: const [],
        orders: const [],
        addresses: const [],
        paymentMethods: const [],
        wishlistProductIds: const [],
        walletTransactions: const [],
        cart: const [],
        wishlistBoards: const [],
        notifications: const [],
        recentSearches: const [],
        recentlyViewedProductIds: const [],
        mockPassword: '123456',
        adminRoleName: 'Catalog Moderator',
        adminPermissionIds: _catalogPermissions,
      ),
      'finance@stylehub.com': UserModel(
        id: 'admin_finance_1',
        name: 'Finance Officer',
        email: 'finance@stylehub.com',
        phone: '+1 555 1003',
        role: UserRole.admin,
        avatar: '',
        isActive: true,
        createdAt: DateTime.now().subtract(const Duration(days: 430)),
        points: 0,
        walletBalance: 0,
        coupons: const [],
        orders: const [],
        addresses: const [],
        paymentMethods: const [],
        wishlistProductIds: const [],
        walletTransactions: const [],
        cart: const [],
        wishlistBoards: const [],
        notifications: const [],
        recentSearches: const [],
        recentlyViewedProductIds: const [],
        mockPassword: '123456',
        adminRoleName: 'Finance Officer',
        adminPermissionIds: _financePermissions,
      ),
      'support@stylehub.com': UserModel(
        id: 'admin_support_1',
        name: 'Support Agent',
        email: 'support@stylehub.com',
        phone: '+1 555 1004',
        role: UserRole.admin,
        avatar: '',
        isActive: true,
        createdAt: DateTime.now().subtract(const Duration(days: 400)),
        points: 0,
        walletBalance: 0,
        coupons: const [],
        orders: const [],
        addresses: const [],
        paymentMethods: const [],
        wishlistProductIds: const [],
        walletTransactions: const [],
        cart: const [],
        wishlistBoards: const [],
        notifications: const [],
        recentSearches: const [],
        recentlyViewedProductIds: const [],
        mockPassword: '123456',
        adminRoleName: 'Customer Support Agent',
        adminPermissionIds: _supportPermissions,
      ),
      'compliance@stylehub.com': UserModel(
        id: 'admin_compliance_1',
        name: 'Compliance Officer',
        email: 'compliance@stylehub.com',
        phone: '+1 555 1005',
        role: UserRole.admin,
        avatar: '',
        isActive: true,
        createdAt: DateTime.now().subtract(const Duration(days: 390)),
        points: 0,
        walletBalance: 0,
        coupons: const [],
        orders: const [],
        addresses: const [],
        paymentMethods: const [],
        wishlistProductIds: const [],
        walletTransactions: const [],
        cart: const [],
        wishlistBoards: const [],
        notifications: const [],
        recentSearches: const [],
        recentlyViewedProductIds: const [],
        mockPassword: '123456',
        adminRoleName: 'Compliance Officer',
        adminPermissionIds: _compliancePermissions,
      ),
      'risk@stylehub.com': UserModel(
        id: 'admin_risk_1',
        name: 'Risk Analyst',
        email: 'risk@stylehub.com',
        phone: '+1 555 1006',
        role: UserRole.admin,
        avatar: '',
        isActive: true,
        createdAt: DateTime.now().subtract(const Duration(days: 380)),
        points: 0,
        walletBalance: 0,
        coupons: const [],
        orders: const [],
        addresses: const [],
        paymentMethods: const [],
        wishlistProductIds: const [],
        walletTransactions: const [],
        cart: const [],
        wishlistBoards: const [],
        notifications: const [],
        recentSearches: const [],
        recentlyViewedProductIds: const [],
        mockPassword: '123456',
        adminRoleName: 'Risk Analyst',
        adminPermissionIds: _riskPermissions,
      ),
    };
  }

  UserModel guestUser() {
    return UserModel(
      id: 'guest',
      name: 'Guest',
      email: '',
      phone: '',
      role: UserRole.guest,
      avatar: '',
      isActive: true,
      createdAt: DateTime.now(),
      points: 0,
      walletBalance: 0,
      coupons: const [],
      orders: const [],
      addresses: const [],
      paymentMethods: const [],
      wishlistProductIds: const [],
      walletTransactions: const [],
      cart: const [],
      wishlistBoards: const [],
      notifications: const [],
      recentSearches: _guestRecentSearches,
      recentlyViewedProductIds: _guestRecentlyViewedProductIds,
    );
  }

  UserModel? mockUserForLogin(String email, String password) {
    final user = _mockUsersByEmail[email.toLowerCase()];
    if (user == null || user.mockPassword != password) {
      return null;
    }
    return user;
  }

  StoreModel ensureStoreForSeller(UserModel seller) {
    final existingStore =
        storeById(seller.linkedStoreId) ?? storeBySellerId(seller.id);
    if (existingStore != null) {
      if (seller.linkedStoreId != existingStore.id) {
        updateUser(
          seller.copyWith(
            linkedStoreId: existingStore.id,
            updatedAt: DateTime.now(),
          ),
        );
      }
      return existingStore;
    }

    final primaryAddress = seller.addresses.isNotEmpty
        ? seller.addresses.first
        : null;
    final now = DateTime.now();
    final store = StoreModel(
      id: 'store_${seller.id}',
      sellerId: seller.id,
      nameText: seller.storeNameText,
      descriptionText: seller.storeDescriptionText,
      policiesText: seller.storePoliciesText,
      addressText: LocalizedTextModel(
        en: primaryAddress == null
            ? ''
            : '${primaryAddress.streetAddress}, ${primaryAddress.city}',
        ar: primaryAddress == null
            ? ''
            : '${primaryAddress.streetAddress}, ${primaryAddress.city}',
      ),
      storePhone: seller.phone,
      city: primaryAddress?.city ?? '',
      countryCode: _countryCodeFromName(primaryAddress?.country ?? ''),
      businessActivityType: 'mixed',
      commissionPercentage: 12,
      allowedCategoryIds: const [],
      isActive: seller.isSellerAccountActive,
      vacationMode: seller.sellerVacationMode,
      createdAt: seller.createdAt,
      updatedAt: now,
    );
    addOrUpdateStore(store);
    updateUser(seller.copyWith(linkedStoreId: store.id, updatedAt: now));
    return store;
  }

  UserModel createDefaultUser(
    String email, {
    String password = '123456',
    String? name,
  }) {
    final seedName = name ?? displayNameFromEmail(email);
    return UserModel(
      id: 'user_${email.hashCode.abs()}',
      name: seedName,
      email: email,
      phone: '',
      role: UserRole.customer,
      avatar: '',
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      points: 0,
      walletBalance: 0,
      coupons: const [],
      orders: const [],
      addresses: const [],
      paymentMethods: const [],
      wishlistProductIds: const [],
      walletTransactions: const [],
      cart: const [],
      wishlistBoards: [_defaultWishlistBoard],
      notifications: const [],
      recentSearches: const [],
      recentlyViewedProductIds: const [],
      mockPassword: password,
    );
  }

  List<OrderModel> get demoOrders {
    final orderProducts = allProducts;
    if (orderProducts.isEmpty) {
      return const [];
    }
    final orderCount = orderProducts.length < 5 ? orderProducts.length : 5;
    return List.generate(orderCount, (index) {
      final itemProduct = orderProducts[index];
      return OrderModel(
        id: 'order_${10000 + index}',
        customerId: 'customer_1',
        customerName: 'Demo Customer',
        items: [
          OrderItemModel(
            id: 'order_item_$index',
            product: itemProduct,
            selectedColor: itemProduct.colors.isEmpty
                ? ''
                : itemProduct.colors.first,
            selectedSize: itemProduct.sizes.isEmpty
                ? ''
                : itemProduct.sizes.first,
            quantity: 1 + index % 2,
            price: itemProduct.price,
          ),
        ],
        status: [
          'Unpaid',
          'Processing',
          'Shipped',
          'Delivered',
          'Review',
        ][index],
        createdAt: DateTime.now().subtract(Duration(days: index * 2 + 1)),
        total: itemProduct.price + 6.99,
        address: demoAddresses.first,
        paymentMethod: paymentMethods.first,
        estimatedDelivery: DateTime.now().add(Duration(days: 2 + index)),
        paymentStatus: index == 0 ? 'Pending' : 'Paid',
        shippingStatus: [
          'Pending',
          'Processing',
          'Shipped',
          'Delivered',
          'Delivered',
        ][index],
        platformCommission: itemProduct.price * 0.12,
      );
    });
  }

  List<UserModel> get customers => _mockUsersByEmail.values
      .where((user) => user.role == UserRole.customer)
      .toList();

  List<UserModel> get sellers => _mockUsersByEmail.values
      .where((user) => user.role == UserRole.seller)
      .toList();

  StoreModel? storeById(String storeId) {
    final matches = _stores.where((store) => store.id == storeId);
    return matches.isEmpty ? null : matches.first;
  }

  StoreModel? storeBySellerId(String sellerId) {
    final matches = _stores.where((store) => store.sellerId == sellerId);
    return matches.isEmpty ? null : matches.first;
  }

  List<OrderModel> get platformOrders => List.unmodifiable(_platformOrders);

  List<OrderModel> ordersForCustomer(String customerId) {
    return _platformOrders
        .where((order) => order.customerId == customerId)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  List<OrderModel> ordersForSeller(String sellerId) {
    return _sellerOrders
        .where((order) => order.sellerId == sellerId)
        .map((order) => order.toOrderModel())
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  List<SellerOrderModel> sellerOrdersForSeller(String sellerId) {
    return _sellerOrders.where((order) => order.sellerId == sellerId).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  SellerOrderModel? sellerOrderById(String sellerOrderId) {
    final matches = _sellerOrders.where((order) => order.id == sellerOrderId);
    return matches.isEmpty ? null : matches.first;
  }

  void createOrder(OrderModel order, {List<SellerOrderModel>? sellerOrders}) {
    _platformOrders = [order, ..._platformOrders];
    final generatedSellerOrders =
        sellerOrders ?? _buildSellerOrdersForOrder(order);
    final generatedIds = generatedSellerOrders.map((item) => item.id).toSet();
    _sellerOrders = [
      ...generatedSellerOrders,
      ..._sellerOrders.where((item) => !generatedIds.contains(item.id)),
    ];
    _syncCustomerOrders(order.customerId);
    unawaited(_persistState());
    notifyListeners();
  }

  UserModel? applyCheckoutRewards(OrderModel order) {
    final customer = userById(order.customerId);
    if (customer == null) {
      return null;
    }
    final now = DateTime.now();
    var nextPoints = customer.points;
    var nextWallet = customer.walletBalance;
    final nextPointTransactions = List<CustomerPointsTransactionModel>.from(
      customer.pointsTransactions,
    );
    final nextWalletTransactions = List<WalletTransactionModel>.from(
      customer.walletTransactions,
    );

    if (order.loyaltyPointsRedeemed > 0) {
      if (nextPoints < order.loyaltyPointsRedeemed) {
        return customer;
      }
      nextPoints -= order.loyaltyPointsRedeemed;
      nextPointTransactions.insert(
        0,
        CustomerPointsTransactionModel(
          id: 'points_redeem_${order.id}_${now.microsecondsSinceEpoch}',
          customerId: customer.id,
          orderId: order.id,
          type: 'redeem',
          points: -order.loyaltyPointsRedeemed,
          description:
              'Redeemed ${order.loyaltyPointsRedeemed} points for order ${order.id}',
          createdAt: now,
          status: 'completed',
        ),
      );
    }

    if (order.walletAmountUsed > 0) {
      if (nextWallet + 0.001 < order.walletAmountUsed) {
        return customer;
      }
      nextWallet -= order.walletAmountUsed;
      nextWalletTransactions.insert(
        0,
        WalletTransactionModel(
          id: 'wallet_debit_${order.id}_${now.microsecondsSinceEpoch}',
          title: 'Wallet used for order',
          amount: -order.walletAmountUsed,
          type: 'order_payment',
          customerId: customer.id,
          orderId: order.id,
          direction: 'debit',
          status: 'completed',
          description: 'Wallet payment for order ${order.id}',
          currency: LoyaltyPolicy.currency,
          balanceAfter: nextWallet,
          createdAt: now,
        ),
      );
    }

    final alreadyAwarded = nextPointTransactions.any(
      (transaction) =>
          transaction.orderId == order.id && transaction.type == 'earn',
    );
    if (!alreadyAwarded && order.loyaltyPointsEarned > 0) {
      nextPoints += order.loyaltyPointsEarned;
      nextPointTransactions.insert(
        0,
        CustomerPointsTransactionModel(
          id: 'points_earn_${order.id}_${now.microsecondsSinceEpoch}',
          customerId: customer.id,
          orderId: order.id,
          type: 'earn',
          points: order.loyaltyPointsEarned,
          description:
              'Earned ${order.loyaltyPointsEarned} points from order ${order.id}',
          createdAt: now,
          expiresAt: now.add(const Duration(days: 365)),
          status: 'completed',
        ),
      );
    }

    final updated = customer.copyWith(
      points: nextPoints,
      walletBalance: nextWallet,
      pointsTransactions: nextPointTransactions,
      walletTransactions: nextWalletTransactions,
      updatedAt: now,
    );
    updateUser(updated);
    if (!alreadyAwarded && order.loyaltyPointsEarned > 0) {
      createNotification(
        NotificationModel(
          id: 'notif_points_${order.id}_${now.microsecondsSinceEpoch}',
          recipientUserId: customer.id,
          recipientRole: UserRole.customer,
          type: NotificationType.generic,
          entityType: 'points',
          entityId: order.id,
          route: '/points',
          data: {'orderId': order.id, 'points': order.loyaltyPointsEarned},
          createdAt: now,
          legacyTitle: 'Points earned',
          legacyMessage:
              'You earned ${order.loyaltyPointsEarned} points from your order.',
        ),
      );
      return userById(customer.id) ?? updated;
    }
    return updated;
  }

  void updateOrder(OrderModel order) {
    final index = _platformOrders.indexWhere((item) => item.id == order.id);
    if (index == -1) {
      createOrder(order);
      return;
    }
    _platformOrders[index] = order.copyWith(updatedAt: DateTime.now());
    _syncCustomerOrders(order.customerId);
    unawaited(_persistState());
    notifyListeners();
  }

  Future<void> updateSellerOrder(SellerOrderModel order) async {
    final index = _sellerOrders.indexWhere((item) => item.id == order.id);
    if (index == -1) {
      _sellerOrders = [order, ..._sellerOrders];
    } else {
      _sellerOrders[index] = order.copyWith(updatedAt: DateTime.now());
    }
    recomputeMasterOrderStatus(order.masterOrderId);
    await _persistState();
    notifyListeners();
  }

  void recomputeMasterOrderStatus(String masterOrderId) {
    final masterIndex = _platformOrders.indexWhere(
      (item) => item.id == masterOrderId,
    );
    if (masterIndex == -1) {
      return;
    }
    final linkedSellerOrders = _sellerOrders
        .where((item) => item.masterOrderId == masterOrderId)
        .toList();
    if (linkedSellerOrders.isEmpty) {
      return;
    }
    final nextStatus = _aggregateOrderStatus(linkedSellerOrders);
    _platformOrders[masterIndex] = _platformOrders[masterIndex].copyWith(
      status: nextStatus,
      shippingStatus: _aggregateShippingStatus(nextStatus),
      updatedAt: DateTime.now(),
    );
    _syncCustomerOrders(_platformOrders[masterIndex].customerId);
  }

  void createSellerOrderStatusNotification(SellerOrderModel order) {
    final store = storeById(order.storeId) ?? storeBySellerId(order.sellerId);
    createNotification(
      NotificationModel(
        id: 'seller_order_status_${order.id}_${DateTime.now().millisecondsSinceEpoch}',
        recipientUserId: order.customerId,
        recipientRole: UserRole.customer,
        type: _notificationTypeForSellerOrderStatus(order.status),
        entityType: 'seller_order',
        entityId: order.id,
        route: '/orders',
        data: {
          'sellerOrderId': order.id,
          'masterOrderId': order.masterOrderId,
          'newStatus': order.status,
          'storeId': order.storeId,
          'itemCount': order.items.fold<int>(
            0,
            (sum, item) => sum + item.quantity,
          ),
          'title_en': 'Order update',
          'title_ar': 'تحديث الطلب',
          'message_en':
              '${store?.nameText.en ?? 'A seller'} changed your order status to ${order.status}.',
          'message_ar':
              '${store?.nameText.ar ?? 'المتجر'} قام بتحديث حالة طلبك إلى ${order.status}.',
        },
        createdAt: DateTime.now(),
      ),
    );
  }

  String _aggregateOrderStatus(List<SellerOrderModel> orders) {
    final statuses = orders.map((order) => order.status).toSet();
    if (statuses.every((status) => status == 'Cancelled')) {
      return 'Cancelled';
    }
    if (statuses.every((status) => status == 'Delivered')) {
      return 'Delivered';
    }
    if (statuses.contains('Delivered')) {
      return 'Processing';
    }
    if (statuses.contains('Shipped')) {
      return 'Shipped';
    }
    if (statuses.contains('Ready to Ship')) {
      return 'Ready to Ship';
    }
    if (statuses.contains('Processing')) {
      return 'Processing';
    }
    if (statuses.contains('Returned')) {
      return 'Returned';
    }
    return 'Pending';
  }

  String _aggregateShippingStatus(String status) {
    switch (status) {
      case 'Delivered':
        return 'Delivered';
      case 'Shipped':
        return 'Shipped';
      case 'Ready to Ship':
        return 'Ready to Ship';
      case 'Cancelled':
        return 'Cancelled';
      case 'Returned':
        return 'Returned';
      case 'Processing':
        return 'Processing';
      default:
        return 'Pending';
    }
  }

  NotificationType _notificationTypeForSellerOrderStatus(String status) {
    switch (status) {
      case 'Processing':
      case 'Ready to Ship':
        return NotificationType.orderProcessing;
      case 'Shipped':
        return NotificationType.orderShipped;
      case 'Delivered':
        return NotificationType.orderDelivered;
      case 'Cancelled':
        return NotificationType.orderCancelled;
      default:
        return NotificationType.generic;
    }
  }

  void saveSellerOrders(List<SellerOrderModel> orders) {
    _sellerOrders = List<SellerOrderModel>.from(orders);
    unawaited(_persistState());
    notifyListeners();
  }

  List<ProductModel> productsForSeller(String sellerId) {
    return _allProducts
        .where((product) => product.sellerId == sellerId && !product.isDeleted)
        .toList();
  }

  List<ProductModel> pendingProducts() {
    return _allProducts
        .where((product) => product.status == ProductStatus.pendingApproval)
        .toList();
  }

  Future<void> addOrUpdateProduct(ProductModel product) async {
    final index = _allProducts.indexWhere((item) => item.id == product.id);
    final persistedProduct = product.copyWith(
      updatedAt: DateTime.now(),
      publishedAt:
          product.status == ProductStatus.active && product.publishedAt == null
          ? DateTime.now()
          : product.publishedAt,
    );
    if (index >= 0) {
      _allProducts[index] = persistedProduct;
    } else {
      _allProducts = [persistedProduct, ..._allProducts];
    }
    await _persistState();
    notifyListeners();
  }

  Future<void> saveProducts(List<ProductModel> products) async {
    _allProducts = List<ProductModel>.from(products);
    await _persistState();
    notifyListeners();
  }

  Future<void> deleteProduct(String productId) async {
    final index = _allProducts.indexWhere((product) => product.id == productId);
    if (index == -1) return;
    _allProducts[index] = _allProducts[index].copyWith(
      status: ProductStatus.deleted,
      isActive: false,
      deletedAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    await _persistState();
    notifyListeners();
  }

  void approveProduct(String productId) {
    final index = _allProducts.indexWhere((item) => item.id == productId);
    if (index == -1) return;
    _allProducts[index] = _allProducts[index].copyWith(
      status: ProductStatus.active,
      isActive: true,
      publishedAt: _allProducts[index].publishedAt ?? DateTime.now(),
      rejectionReason: '',
      updatedAt: DateTime.now(),
    );
    unawaited(_persistState());
    notifyListeners();
  }

  void rejectProduct(String productId) {
    final index = _allProducts.indexWhere((item) => item.id == productId);
    if (index == -1) return;
    _allProducts[index] = _allProducts[index].copyWith(
      status: ProductStatus.rejected,
      isActive: false,
      updatedAt: DateTime.now(),
    );
    unawaited(_persistState());
    notifyListeners();
  }

  void addOrUpdateStore(StoreModel store) {
    final index = _stores.indexWhere((item) => item.id == store.id);
    final persistedStore = store.copyWith(updatedAt: DateTime.now());
    if (index == -1) {
      _stores = [persistedStore, ..._stores];
    } else {
      _stores[index] = persistedStore;
    }
    unawaited(_persistState());
    notifyListeners();
  }

  void saveStores(List<StoreModel> stores) {
    _stores = List<StoreModel>.from(stores);
    unawaited(_persistState());
    notifyListeners();
  }

  List<StoreReviewModel> reviewsByStore(String storeId) {
    return _storeReviews.where((review) => review.storeId == storeId).toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  }

  List<StoreReviewModel> reviewsByCustomer(String customerId) {
    return _storeReviews
        .where((review) => review.customerId == customerId)
        .toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  }

  StoreReviewModel? getReviewForOrderStore(
    String customerId,
    String orderId,
    String storeId,
  ) {
    final matches = _storeReviews.where(
      (review) =>
          review.customerId == customerId &&
          review.orderId == orderId &&
          review.storeId == storeId,
    );
    return matches.isEmpty ? null : matches.first;
  }

  void saveStoreReview(StoreReviewModel review) {
    final existingIndex = _storeReviews.indexWhere(
      (item) => item.id == review.id,
    );
    final duplicateIndex = _storeReviews.indexWhere(
      (item) =>
          item.customerId == review.customerId &&
          item.orderId == review.orderId &&
          item.storeId == review.storeId,
    );
    final nextReview = review.copyWith(updatedAt: DateTime.now());
    if (existingIndex != -1) {
      _storeReviews[existingIndex] = nextReview;
    } else if (duplicateIndex != -1) {
      _storeReviews[duplicateIndex] = nextReview;
    } else {
      _storeReviews = [nextReview, ..._storeReviews];
    }
    recalculateStoreRating(review.storeId);
  }

  void deleteStoreReview(String reviewId) {
    final existing = _storeReviews.where((item) => item.id == reviewId);
    final storeId = existing.isEmpty ? '' : existing.first.storeId;
    _storeReviews.removeWhere((item) => item.id == reviewId);
    if (storeId.isNotEmpty) {
      recalculateStoreRating(storeId);
    } else {
      unawaited(_persistState());
      notifyListeners();
    }
  }

  void recalculateStoreRating(String storeId) {
    final storeIndex = _stores.indexWhere((store) => store.id == storeId);
    if (storeIndex == -1) {
      return;
    }
    final reviews = reviewsByStore(storeId);
    final reviewCount = reviews.length;
    final average = reviewCount == 0
        ? 0.0
        : reviews.fold<double>(0, (sum, item) => sum + item.rating) /
              reviewCount;
    _stores[storeIndex] = _stores[storeIndex].copyWith(
      rating: average,
      reviewCount: reviewCount,
      updatedAt: DateTime.now(),
    );
    unawaited(_persistState());
    notifyListeners();
  }

  void _recalculateAllStoreRatings() {
    for (final store in _stores) {
      final reviews = _storeReviews
          .where((item) => item.storeId == store.id)
          .toList();
      final reviewCount = reviews.length;
      final average = reviewCount == 0
          ? 0.0
          : reviews.fold<double>(0, (sum, item) => sum + item.rating) /
                reviewCount;
      final index = _stores.indexWhere((item) => item.id == store.id);
      if (index != -1) {
        _stores[index] = _stores[index].copyWith(
          rating: average,
          reviewCount: reviewCount,
        );
      }
    }
  }

  void deactivateStore(String storeId, {String reason = ''}) {
    final index = _stores.indexWhere((store) => store.id == storeId);
    if (index == -1) return;
    _stores[index] = _stores[index].copyWith(
      isActive: false,
      suspendedAt: DateTime.now(),
      suspensionReason: reason,
      updatedAt: DateTime.now(),
    );
    unawaited(_persistState());
    notifyListeners();
  }

  void reactivateStore(String storeId) {
    final index = _stores.indexWhere((store) => store.id == storeId);
    if (index == -1) return;
    _stores[index] = _stores[index].copyWith(
      isActive: true,
      clearSuspendedAt: true,
      suspensionReason: '',
      updatedAt: DateTime.now(),
    );
    unawaited(_persistState());
    notifyListeners();
  }

  List<NotificationModel> notificationsForUser(String userId) {
    if (userId.isEmpty) {
      return List<NotificationModel>.from(_genericNotifications)
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }
    final notifications = userById(userId)?.notifications ?? const [];
    return List<NotificationModel>.from(notifications)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  void createNotification(NotificationModel notification) {
    createNotifications([notification]);
  }

  void createNotifications(List<NotificationModel> notifications) {
    for (final notification in notifications) {
      if (notification.recipientUserId.isEmpty) {
        _genericNotifications = [
          notification,
          ..._genericNotifications.where((item) => item.id != notification.id),
        ];
        continue;
      }
      final user = userById(notification.recipientUserId);
      if (user == null) {
        continue;
      }
      final nextNotifications = [
        notification,
        ...user.notifications.where((item) => item.id != notification.id),
      ]..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      updateUser(user.copyWith(notifications: nextNotifications));
    }
    unawaited(_persistState());
    notifyListeners();
  }

  void markNotificationRead(String notificationId) {
    final now = DateTime.now();
    var changed = false;
    for (final user in allUsers) {
      final index = user.notifications.indexWhere(
        (item) => item.id == notificationId,
      );
      if (index == -1) {
        continue;
      }
      final next = List<NotificationModel>.from(user.notifications);
      next[index] = next[index].copyWith(isRead: true, readAt: now);
      updateUser(user.copyWith(notifications: next));
      changed = true;
      break;
    }
    if (!changed) {
      final index = _genericNotifications.indexWhere(
        (item) => item.id == notificationId,
      );
      if (index != -1) {
        _genericNotifications[index] = _genericNotifications[index].copyWith(
          isRead: true,
          readAt: now,
        );
        changed = true;
      }
    }
    if (changed) {
      unawaited(_persistState());
      notifyListeners();
    }
  }

  void markAllNotificationsRead(String userId) {
    if (userId.isEmpty) {
      _genericNotifications = _genericNotifications
          .map((item) => item.copyWith(isRead: true, readAt: DateTime.now()))
          .toList();
      unawaited(_persistState());
      notifyListeners();
      return;
    }
    final user = userById(userId);
    if (user == null) {
      return;
    }
    updateUser(
      user.copyWith(
        notifications: user.notifications
            .map((item) => item.copyWith(isRead: true, readAt: DateTime.now()))
            .toList(),
      ),
    );
    unawaited(_persistState());
    notifyListeners();
  }

  void deleteNotification(String notificationId) {
    var changed = false;
    for (final user in allUsers) {
      final next = user.notifications
          .where((item) => item.id != notificationId)
          .toList();
      if (next.length != user.notifications.length) {
        updateUser(user.copyWith(notifications: next));
        changed = true;
        break;
      }
    }
    if (!changed) {
      final initialLength = _genericNotifications.length;
      _genericNotifications.removeWhere((item) => item.id == notificationId);
      changed = _genericNotifications.length != initialLength;
    }
    if (changed) {
      unawaited(_persistState());
      notifyListeners();
    }
  }

  void clearNotifications(String userId) {
    if (userId.isEmpty) {
      _genericNotifications = [];
      unawaited(_persistState());
      notifyListeners();
      return;
    }
    final user = userById(userId);
    if (user == null) {
      return;
    }
    updateUser(user.copyWith(notifications: const []));
    unawaited(_persistState());
    notifyListeners();
  }

  void updateUser(UserModel user) {
    if (user.email.isEmpty) return;
    _mockUsersByEmail.removeWhere(
      (_, existingUser) =>
          existingUser.id == user.id &&
          existingUser.email.toLowerCase() != user.email.toLowerCase(),
    );
    _mockUsersByEmail[user.email.toLowerCase()] = user;
    if (_currentSessionUser?.id == user.id) {
      _currentSessionUser = user;
      unawaited(_localStorageService.saveUser(user));
    }
    unawaited(_persistState());
  }

  Future<void> updateUserPassword(String userId, String password) async {
    final user = userById(userId);
    if (user == null) {
      throw Exception('account_not_found');
    }
    final updated = user.copyWith(
      mockPassword: password,
      updatedAt: DateTime.now(),
    );
    _mockUsersByEmail.removeWhere(
      (_, existingUser) =>
          existingUser.id == updated.id &&
          existingUser.email.toLowerCase() != updated.email.toLowerCase(),
    );
    _mockUsersByEmail[updated.email.toLowerCase()] = updated;
    if (_currentSessionUser?.id == updated.id) {
      _currentSessionUser = updated;
      await _localStorageService.saveUser(updated);
    }
    await _persistState();
    notifyListeners();
  }

  void _syncCustomerOrders(String customerId) {
    final customer = userById(customerId);
    if (customer == null) {
      return;
    }
    updateUser(customer.copyWith(orders: ordersForCustomer(customerId)));
  }

  Map<String, dynamic> _snapshot() => {
    'seedVersion': _seedDataVersion,
    'preferences': _preferences.toJson(),
    'products': _allProducts.map((item) => item.toJson()).toList(),
    'stores': _stores.map((item) => item.toJson()).toList(),
    'users': _mockUsersByEmail.values.map((item) => item.toJson()).toList(),
    'platformOrders': _platformOrders.map((item) => item.toJson()).toList(),
    'sellerOrders': _sellerOrders.map((item) => item.toJson()).toList(),
    'promoBanners': _promoBannerPool,
    'categories': _categories.map((item) => item.toJson()).toList(),
    'coupons': _coupons.map((item) => item.toJson()).toList(),
    'giftCards': _giftCards.map((item) => item.toJson()).toList(),
    'genericNotifications': _genericNotifications
        .map((item) => item.toJson())
        .toList(),
    'reviews': _reviews.map((item) => item.toJson()).toList(),
    'storeReviews': _storeReviews.map((item) => item.toJson()).toList(),
    'guestRecentSearches': _guestRecentSearches,
    'guestRecentlyViewedProductIds': _guestRecentlyViewedProductIds,
  };

  AppPreferencesModel? _preferencesFromSnapshot(Map<String, dynamic> json) {
    final preferencesJson = json['preferences'];
    if (preferencesJson is! Map<String, dynamic>) {
      return null;
    }
    return AppPreferencesModel.fromJson(preferencesJson);
  }

  bool _containsMojibake(Object? value) {
    if (value is String) {
      return _mojibakeMarkers.any(value.contains);
    }
    if (value is Map) {
      return value.values.any(_containsMojibake);
    }
    if (value is Iterable) {
      return value.any(_containsMojibake);
    }
    return false;
  }

  void _restoreSnapshot(Map<String, dynamic> json) {
    _preferences = AppPreferencesModel.fromJson(
      json['preferences'] as Map<String, dynamic>? ?? const {},
    );
    _allProducts = (json['products'] as List<dynamic>? ?? [])
        .map((item) => ProductModel.fromJson(item as Map<String, dynamic>))
        .toList();
    _stores = (json['stores'] as List<dynamic>? ?? [])
        .map((item) => StoreModel.fromJson(item as Map<String, dynamic>))
        .toList();
    final users = (json['users'] as List<dynamic>? ?? [])
        .map((item) => UserModel.fromJson(item as Map<String, dynamic>))
        .toList();
    _mockUsersByEmail = {
      for (final user in users) user.email.toLowerCase(): user,
    };
    _platformOrders = (json['platformOrders'] as List<dynamic>? ?? [])
        .map((item) => OrderModel.fromJson(item as Map<String, dynamic>))
        .toList();
    _sellerOrders = (json['sellerOrders'] as List<dynamic>? ?? [])
        .map((item) => SellerOrderModel.fromJson(item as Map<String, dynamic>))
        .toList();
    _promoBannerPool = (json['promoBanners'] as List<dynamic>? ?? [])
        .map((item) => item as String)
        .toList();
    _categories = (json['categories'] as List<dynamic>? ?? [])
        .map((item) => CategoryModel.fromJson(item as Map<String, dynamic>))
        .toList();
    _coupons = (json['coupons'] as List<dynamic>? ?? [])
        .map((item) => CouponModel.fromJson(item as Map<String, dynamic>))
        .toList();
    _giftCards = (json['giftCards'] as List<dynamic>? ?? [])
        .map((item) => GiftCardModel.fromJson(item as Map<String, dynamic>))
        .toList();
    _genericNotifications =
        (json['genericNotifications'] as List<dynamic>? ?? [])
            .map(
              (item) =>
                  NotificationModel.fromJson(item as Map<String, dynamic>),
            )
            .toList();
    _reviews = (json['reviews'] as List<dynamic>? ?? [])
        .map((item) => ReviewModel.fromJson(item as Map<String, dynamic>))
        .toList();
    _reviews = _reviews
        .where((review) => review.productId.trim().isNotEmpty)
        .toList();
    _storeReviews = (json['storeReviews'] as List<dynamic>? ?? [])
        .map((item) => StoreReviewModel.fromJson(item as Map<String, dynamic>))
        .toList();
    _guestRecentSearches = (json['guestRecentSearches'] as List<dynamic>? ?? [])
        .map((item) => item as String)
        .toList();
    _guestRecentlyViewedProductIds =
        (json['guestRecentlyViewedProductIds'] as List<dynamic>? ?? [])
            .map((item) => item as String)
            .toList();
    final categoriesNormalized = _normalizeCategoryCatalogData();
    final productCategoriesNormalized = _normalizeProductCategoryIds();
    final storeAllowedCategoriesNormalized =
        _normalizeStoreAllowedCategoryIds();
    if (_stores.isEmpty) {
      _stores = _migrateStoresFromUsers();
    }
    if (_storeReviews.isEmpty) {
      _storeReviews = _buildInitialStoreReviews();
    }
    if (_giftCards.isEmpty) {
      _giftCards = _buildInitialGiftCards();
    }
    if (_sellerOrders.isEmpty) {
      _sellerOrders = _buildSellerOrdersFromOrders(_platformOrders);
    }
    if (_reviews.isEmpty && _platformOrders.isNotEmpty) {
      _reviews = _buildInitialReviews();
    }
    _recalculateAllStoreRatings();
    _currentSessionUser = null;
    if (_promoBannerPool.isEmpty ||
        _categories.isEmpty ||
        _coupons.isEmpty ||
        _allProducts.isEmpty ||
        _mockUsersByEmail.isEmpty) {
      _seedDefaults();
    } else if (categoriesNormalized ||
        productCategoriesNormalized ||
        storeAllowedCategoriesNormalized) {
      unawaited(_persistState());
    }
  }

  List<StoreModel> _migrateStoresFromUsers() {
    return sellers.map((seller) {
      final now = DateTime.now();
      return StoreModel(
        id: 'store_${seller.id}',
        sellerId: seller.id,
        nameText: seller.storeNameText,
        descriptionText: seller.storeDescriptionText,
        policiesText: seller.storePoliciesText,
        addressText: LocalizedTextModel(
          en: seller.addresses.isNotEmpty
              ? '${seller.addresses.first.streetAddress}, ${seller.addresses.first.city}'
              : '',
          ar: seller.addresses.isNotEmpty
              ? '${seller.addresses.first.streetAddress}, ${seller.addresses.first.city}'
              : '',
        ),
        storePhone: seller.phone,
        city: seller.addresses.isNotEmpty ? seller.addresses.first.city : '',
        countryCode: _countryCodeFromName(
          seller.addresses.isNotEmpty ? seller.addresses.first.country : '',
        ),
        businessActivityType: 'mixed',
        commissionPercentage: 12,
        rating: 0,
        reviewCount: 0,
        followersCount: 0,
        isActive: seller.isSellerAccountActive,
        createdAt: seller.createdAt,
        updatedAt: now,
        vacationMode: seller.sellerVacationMode,
      );
    }).toList();
  }

  String _countryCodeFromName(String country) {
    switch (country.trim().toLowerCase()) {
      case 'united states':
      case 'usa':
      case 'us':
        return 'US';
      case 'united arab emirates':
      case 'uae':
        return 'AE';
      case 'united kingdom':
      case 'uk':
        return 'GB';
      default:
        return country.trim().toUpperCase();
    }
  }

  String displayNameFromEmail(String email) {
    final localPart = email.split('@').first.trim();
    if (localPart.isEmpty) {
      return 'LY STORE Member';
    }
    return localPart
        .split(RegExp(r'[._-]+'))
        .where((part) => part.isNotEmpty)
        .map(
          (part) =>
              '${part[0].toUpperCase()}${part.length > 1 ? part.substring(1) : ''}',
        )
        .join(' ');
  }

  Future<void> _persistState() async {
    await _localStorageService.saveJson(_appStateKey, _snapshot());
    await _localStorageService.saveInt(_seedVersionKey, _seedDataVersion);
    await _localStorageService.saveUsers(_mockUsersByEmail.values.toList());
    await _localStorageService.saveAppPreferences(_preferences);
  }

  List<CategoryModel> _buildInitialCategories() {
    const categories = [
      ('women', 'Women', 'النساء'),
      ('curve', 'Curve', 'كيرف'),
      ('kids', 'Kids', 'الأطفال'),
      ('men', 'Men', 'الرجال'),
      ('shoes', 'Shoes', 'الأحذية'),
      ('jewelry', 'Jewelry & Accessories', 'المجوهرات والإكسسوارات'),
      ('tops', 'Tops', 'القمصان'),
      ('men-trends', 'Men Trends', 'صيحات الرجال'),
      ('sleepwear', 'Underwear & Sleepwear', 'الملابس الداخلية والنوم'),
      ('dresses', 'Dresses', 'الفساتين'),
      ('beauty', 'Beauty', 'الجمال'),
      ('bags', 'Bags', 'الحقائب'),
      ('home', 'Home', 'المنزل'),
      ('sale', 'Sale', 'التخفيضات'),
      ('electronics', 'Electronics', 'الإلكترونيات'),
    ];
    const sub = [
      'New In',
      'Sale',
      'Tops',
      'Dresses',
      'Denim',
      'Loungewear',
      'Activewear',
      'Beauty Tools',
      'Decor',
      'Sandals',
      'Sneakers',
      'Necklaces',
      'Phone Cases',
      'Backpacks',
      'Stationery',
      'Pet Beds',
      'Swimwear',
      'Suits',
      'Kids Sets',
      'Storage',
      'Skincare',
      'Heels',
      'Rings',
      'Tablets',
      'Travel Bags',
      'Desk Finds',
      'Fitness',
      'Maternity',
      'Bedding',
      'Toys',
    ];
    return List.generate(
      categories.length,
      (index) => CategoryModel(
        id: categories[index].$1,
        departmentId: categories[index].$1,
        nameText: LocalizedTextModel(
          en: categories[index].$2,
          ar: categories[index].$3,
        ),
        descriptionText: const LocalizedTextModel(
          en: 'Temporary category images for UI preview only. Replace with API-managed category images later.',
          ar: 'صور تصنيفات مؤقتة لمعاينة الواجهة فقط. استبدلها لاحقًا بصور التصنيفات القادمة من الواجهة البرمجية.',
        ),
        imageUrl: _temporaryCategoryImageFor(categories[index].$1),
        subcategories: _seededSubcategoriesFor(
          categories[index].$1,
          fallback: sub.skip((index * 2) % sub.length).take(6).toList(),
        ),
        bannerTitle: 'Fresh picks for ${categories[index].$2}',
        displayOrder: index,
      ),
    );
  }

  List<String> _seededSubcategoriesFor(
    String categoryId, {
    required List<String> fallback,
  }) {
    switch (categoryId) {
      case 'women':
        return _womenClothingSubcategories;
      case 'dresses':
        return const [
          'Casual Dress',
          'Party Dress',
          'Maxi Dress',
          'Mini Dress',
          'Midi Dress',
          'Work Dresses',
        ];
      case 'tops':
        return const [
          'Blouses',
          'T-Shirts',
          'Shirts',
          'Crop Tops',
          'Knit Tops',
          'Lightweight Cardigan',
        ];
      case 'sleepwear':
        return const [
          'Underwear',
          'Pajama Set',
          'Nightdress',
          'Lounge Set',
          'Robe',
          'Sports Bra',
        ];
      case 'men':
      case 'men-trends':
        return const [
          'Formal Shirt',
          'Linen Shirt',
          'Basic Tee',
          'Graphic Tee',
          'Chinos',
          'Joggers',
          'Cargo Pants',
        ];
      case 'kids':
        return const [
          'Kids Sets',
          'Toys',
          'Back To School',
          'Soft Toys',
          'Outdoor Toys',
          'Games',
        ];
      case 'shoes':
        return const [
          'Running Sneakers',
          'Lifestyle Sneakers',
          'Sandals',
          'Block Heels',
          'Ankle Boots',
          'Loafers',
        ];
      case 'jewelry':
        return const [
          'Necklaces',
          'Rings',
          'Bracelets',
          'Earrings',
          'Watches',
          'Sunglasses',
        ];
      case 'bags':
        return const [
          'Handbags',
          'Crossbody Bags',
          'Backpacks',
          'Wallets',
          'Travel Bags',
        ];
      case 'beauty':
        return const [
          'Lipstick',
          'Foundation',
          'Palette',
          'Mascara',
          'Skincare',
          'Brushes',
        ];
      case 'home':
        return const ['Bedding', 'Decor', 'Storage', 'Lighting', 'Throws'];
      case 'electronics':
        return const [
          'Phone Cases',
          'Audio',
          'Smart Devices',
          'Gaming',
          'Tablets',
        ];
      case 'sale':
        return const [
          'Flash Sale',
          'Clearance',
          'Bundle Deals',
          'Seasonal Offers',
        ];
      default:
        return fallback;
    }
  }

  bool _normalizeCategoryCatalogData() {
    var changed = false;
    _categories = _categories.map((category) {
      if (category.id == 'women' &&
          !listEquals(category.subcategories, _womenClothingSubcategories)) {
        changed = true;
        return category.copyWith(subcategories: _womenClothingSubcategories);
      }
      return category;
    }).toList();
    return changed;
  }

  bool _normalizeProductCategoryIds() {
    var changed = false;
    final categoriesById = {
      for (final category in categories) category.id: category,
    };
    final categoriesByName = {
      for (final category in categories)
        _categoryLookupKey(category.nameText.en): category,
      for (final category in categories)
        _categoryLookupKey(category.nameText.ar): category,
    };
    _allProducts = _allProducts.map((product) {
      if (categoriesById.containsKey(product.categoryId)) {
        return product;
      }
      final match =
          categoriesByName[_categoryLookupKey(product.categoryName)] ??
          categoriesByName[_categoryLookupKey(product.categoryId)];
      if (match == null) {
        return product;
      }
      changed = true;
      return product.copyWith(
        categoryId: match.id,
        categoryName: match.nameText.en,
        department: match.departmentId,
      );
    }).toList();
    return changed;
  }

  bool _normalizeStoreAllowedCategoryIds() {
    var changed = false;
    const legacyMap = {
      'cat_0': 'women',
      'cat_1': 'curve',
      'cat_2': 'kids',
      'cat_3': 'men',
      'cat_4': 'shoes',
      'cat_5': 'jewelry',
      'cat_6': 'tops',
      'cat_7': 'men-trends',
      'cat_8': 'sleepwear',
      'cat_9': 'dresses',
      'cat_10': 'beauty',
      'cat_11': 'bags',
      'cat_12': 'home',
      'cat_13': 'sale',
      'cat_14': 'electronics',
    };
    final categoryIds = categories.map((category) => category.id).toSet();
    _stores = _stores.map((store) {
      if (store.allowedCategoryIds.isEmpty) {
        return store;
      }
      final normalized = store.allowedCategoryIds
          .map((id) => legacyMap[id] ?? id)
          .where(categoryIds.contains)
          .toSet()
          .toList();
      if (normalized.length == store.allowedCategoryIds.length &&
          normalized.every(store.allowedCategoryIds.contains)) {
        return store;
      }
      changed = true;
      return store.copyWith(allowedCategoryIds: normalized);
    }).toList();
    return changed;
  }

  String _categoryLookupKey(String value) {
    return value.trim().toLowerCase().replaceAll(
      RegExp(r'[^a-z0-9\u0600-\u06ff]+'),
      '',
    );
  }

  String _temporaryCategoryImageFor(String categoryId) {
    final normalized = categoryId.toLowerCase();
    if (normalized == 'tops') {
      return _temporaryImageGalleries['women']![1];
    }
    if (normalized == 'men-trends') {
      return _temporaryImageGalleries['men']![2];
    }
    if (normalized == 'sleepwear') {
      return _temporaryImageGalleries['curve']![0];
    }
    if (normalized == 'dresses') {
      return _temporaryImageGalleries['women']![0];
    }
    final gallery = _temporaryImageGalleries[normalized];
    if (gallery != null && gallery.isNotEmpty) {
      return gallery.first;
    }
    return _temporaryImageGalleries['default']!.first;
  }

  List<CouponModel> _buildInitialCoupons() => const [
    CouponModel(
      id: 'coupon_1',
      code: 'WELCOME10',
      title: 'Welcome 10% Off',
      description: 'Save 10% on your first order.',
      amount: 10,
      minimumSpend: 40,
      isPercentage: true,
    ),
    CouponModel(
      id: 'coupon_2',
      code: 'SHIPFREE',
      title: 'Free Shipping',
      description: 'Shipping fee waived on orders above \$30.',
      amount: 6.99,
      minimumSpend: 30,
    ),
    CouponModel(
      id: 'coupon_3',
      code: 'TREND15',
      title: '\$15 Trend Drop',
      description: 'Best for statement picks.',
      amount: 15,
      minimumSpend: 70,
    ),
    CouponModel(
      id: 'coupon_4',
      code: 'GLOW12',
      title: 'Beauty Savings',
      description: '\$12 off beauty bundles.',
      amount: 12,
      minimumSpend: 45,
    ),
    CouponModel(
      id: 'coupon_5',
      code: 'HOME20',
      title: 'Home Refresh',
      description: '20% off selected home finds.',
      amount: 20,
      minimumSpend: 90,
      isPercentage: true,
    ),
    CouponModel(
      id: 'coupon_6',
      code: 'SETSTYLE',
      title: '\$8 Style Set',
      description: '\$8 off coordinated looks.',
      amount: 8,
      minimumSpend: 35,
    ),
    CouponModel(
      id: 'coupon_7',
      code: 'VIP25',
      title: '\$25 VIP Reward',
      description: 'A bigger reward for higher baskets.',
      amount: 25,
      minimumSpend: 120,
    ),
    CouponModel(
      id: 'coupon_8',
      code: 'SAVE5',
      title: '\$5 Quick Save',
      description: 'A small reward for any style update.',
      amount: 5,
      minimumSpend: 25,
    ),
  ];

  List<GiftCardModel> _buildInitialGiftCards() {
    final now = DateTime.now();
    return [
      GiftCardModel(
        id: 'gift_ly25',
        code: 'LY25',
        amount: 25,
        currency: LoyaltyPolicy.currency,
        createdAt: now.subtract(const Duration(days: 7)),
        expiresAt: now.add(const Duration(days: 180)),
      ),
      GiftCardModel(
        id: 'gift_ly50',
        code: 'LY50',
        amount: 50,
        currency: LoyaltyPolicy.currency,
        createdAt: now.subtract(const Duration(days: 5)),
        expiresAt: now.add(const Duration(days: 180)),
      ),
      GiftCardModel(
        id: 'gift_ly100',
        code: 'LY100',
        amount: 100,
        currency: LoyaltyPolicy.currency,
        createdAt: now.subtract(const Duration(days: 3)),
        expiresAt: now.add(const Duration(days: 180)),
      ),
    ];
  }

  List<NotificationModel> _buildInitialNotifications() => [
    NotificationModel(
      id: 'n1',
      recipientUserId: '',
      recipientRole: UserRole.guest,
      type: NotificationType.genericPromotion,
      entityType: 'promotion',
      entityId: 'promo_dresses',
      data: const {
        'title_en': 'Price Drop Alert',
        'title_ar': 'تنبيه انخفاض الأسعار',
        'message_en': 'Fresh markdowns just landed in dresses and shoes.',
        'message_ar': 'وصلت تخفيضات جديدة على الفساتين والأحذية.',
      },
      createdAt: DateTime.now().subtract(const Duration(hours: 3)),
    ),
    NotificationModel(
      id: 'n2',
      recipientUserId: '',
      recipientRole: UserRole.guest,
      type: NotificationType.genericPromotion,
      entityType: 'arrival',
      entityId: 'arrival_summer',
      data: const {
        'title_en': 'New Arrivals',
        'title_ar': 'وصل حديثاً',
        'message_en': 'Vacation-ready styles are now live.',
        'message_ar': 'الإطلالات الجاهزة للعطلات أصبحت متاحة الآن.',
      },
      createdAt: DateTime.now().subtract(const Duration(hours: 8)),
    ),
    NotificationModel(
      id: 'n3',
      recipientUserId: '',
      recipientRole: UserRole.guest,
      type: NotificationType.generic,
      entityType: 'app',
      entityId: 'build_update',
      data: const {
        'title_en': 'App Update',
        'title_ar': 'تحديث التطبيق',
        'message_en': 'Browse faster and save more with the latest mock build.',
        'message_ar': 'تصفح أسرع ووفر أكثر مع آخر نسخة تجريبية.',
      },
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    NotificationModel(
      id: 'n4',
      recipientUserId: '',
      recipientRole: UserRole.guest,
      type: NotificationType.genericPromotion,
      entityType: 'flash_sale',
      entityId: 'flash_sale_tonight',
      data: const {
        'title_en': 'Flash Sale',
        'title_ar': 'تخفيض سريع',
        'message_en': 'Limited-time picks are ending tonight.',
        'message_ar': 'العروض محدودة الوقت تنتهي الليلة.',
      },
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    NotificationModel(
      id: 'n5',
      recipientUserId: '',
      recipientRole: UserRole.guest,
      type: NotificationType.genericPromotion,
      entityType: 'feed',
      entityId: 'style_edit',
      data: const {
        'title_en': 'Style Edit',
        'title_ar': 'اختيارات الموضة',
        'message_en': 'Office looks and casual basics are trending now.',
        'message_ar': 'إطلالات المكتب والأساسيات اليومية رائجة الآن.',
      },
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
    ),
  ];

  List<StoreReviewModel> _buildInitialStoreReviews() => [
    StoreReviewModel(
      id: 'store_review_1',
      storeId: 'store_seller_1',
      sellerId: 'seller_1',
      customerId: 'customer_1',
      orderId: 'order_10003',
      rating: 5,
      comment: 'Fast delivery and the store quality matched the listing.',
      verifiedPurchase: true,
      createdAt: DateTime.now().subtract(const Duration(days: 10)),
      updatedAt: DateTime.now().subtract(const Duration(days: 10)),
    ),
    StoreReviewModel(
      id: 'store_review_2',
      storeId: 'store_seller_2',
      sellerId: 'seller_2',
      customerId: 'customer_1',
      orderId: 'order_10002',
      rating: 4,
      comment: 'Good packaging and clean product details.',
      verifiedPurchase: true,
      createdAt: DateTime.now().subtract(const Duration(days: 16)),
      updatedAt: DateTime.now().subtract(const Duration(days: 16)),
    ),
    StoreReviewModel(
      id: 'store_review_3',
      storeId: 'store_seller_3',
      sellerId: 'seller_3',
      customerId: 'customer_1',
      orderId: 'order_10004',
      rating: 5,
      comment: 'Beautiful pieces and the seller storefront feels reliable.',
      verifiedPurchase: true,
      createdAt: DateTime.now().subtract(const Duration(days: 21)),
      updatedAt: DateTime.now().subtract(const Duration(days: 21)),
    ),
  ];

  List<SellerOrderModel> _buildSellerOrdersFromOrders(List<OrderModel> orders) {
    return orders.expand(_buildSellerOrdersForOrder).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  List<SellerOrderModel> _buildSellerOrdersForOrder(OrderModel order) {
    final groups = <String, List<OrderItemModel>>{};
    for (final item in order.items) {
      final key = '${item.product.sellerId}::${item.product.storeId}';
      groups.putIfAbsent(key, () => <OrderItemModel>[]).add(item);
    }
    return groups.entries.map((entry) {
      final parts = entry.key.split('::');
      final sellerId = parts.first;
      final storeId = parts.length > 1 ? parts[1] : '';
      final subtotal = entry.value.fold<double>(
        0,
        (sum, item) => sum + (item.price * item.quantity),
      );
      final store = storeById(storeId) ?? storeBySellerId(sellerId);
      final commissionRate = (() {
        final value = store?.commissionPercentage ?? 12;
        return value > 1 ? value / 100 : value;
      })();
      final commission = subtotal * commissionRate;
      return SellerOrderModel(
        id: 'seller_${order.id}_${sellerId}_$storeId',
        masterOrderId: order.id,
        sellerId: sellerId,
        storeId: storeId,
        customerId: order.customerId,
        customerName: order.customerName,
        items: List<OrderItemModel>.from(entry.value),
        subtotal: subtotal,
        platformCommission: commission,
        sellerNetAmount: subtotal - commission,
        status: order.status,
        paymentStatus: order.paymentStatus,
        shippingStatus: order.shippingStatus,
        createdAt: order.createdAt,
        updatedAt: order.updatedAt,
        address: order.address,
        paymentMethod: order.paymentMethod,
        estimatedDelivery: order.estimatedDelivery,
      );
    }).toList();
  }

  List<ReviewModel> _buildInitialReviews() {
    final deliveredOrders = _platformOrders
        .where(
          (order) =>
              order.customerId == 'customer_1' &&
              (order.status == 'Delivered' ||
                  order.status == 'Review' ||
                  order.shippingStatus == 'Delivered'),
        )
        .toList();
    return deliveredOrders.take(2).map((order) {
      final item = order.items.first;
      final index = deliveredOrders.indexOf(order);
      return ReviewModel(
        id: 'review_${order.id}_${item.product.id}',
        productId: item.product.id,
        orderId: order.id,
        customerId: order.customerId,
        customerName: order.customerName,
        rating: index.isEven ? 4.5 : 4,
        comment: index.isEven
            ? 'Verified purchase: comfortable quality and the item arrived as expected.'
            : 'Good value after delivery. The details match the product photos.',
        createdAt: order.updatedAt.add(const Duration(hours: 4)),
        updatedAt: order.updatedAt.add(const Duration(hours: 4)),
        status: ReviewStatus.approved,
        isVerifiedPurchase: true,
      );
    }).toList();
  }
}

class GiftCardRedeemResult {
  const GiftCardRedeemResult._({
    required this.isSuccess,
    required this.messageKey,
    this.card,
    this.user,
    this.transaction,
  });

  const GiftCardRedeemResult.failure(String messageKey)
    : this._(isSuccess: false, messageKey: messageKey);

  const GiftCardRedeemResult.success({
    required GiftCardModel card,
    required UserModel user,
    required WalletTransactionModel transaction,
  }) : this._(
         isSuccess: true,
         messageKey: 'success',
         card: card,
         user: user,
         transaction: transaction,
       );

  final bool isSuccess;
  final String messageKey;
  final GiftCardModel? card;
  final UserModel? user;
  final WalletTransactionModel? transaction;
}
