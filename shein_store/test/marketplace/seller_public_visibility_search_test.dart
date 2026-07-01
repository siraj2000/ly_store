import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stylehub_store/controllers/auth_controller.dart';
import 'package:stylehub_store/controllers/category_controller.dart';
import 'package:stylehub_store/controllers/product_controller.dart';
import 'package:stylehub_store/controllers/search_controller.dart';
import 'package:stylehub_store/core/constants/app_routes.dart';
import 'package:stylehub_store/core/policies/product_availability_policy.dart';
import 'package:stylehub_store/models/localized_text_model.dart';
import 'package:stylehub_store/models/product_model.dart';
import 'package:stylehub_store/models/product_status.dart';
import 'package:stylehub_store/services/auth_service.dart';
import 'package:stylehub_store/services/dummy_json_product_api.dart';
import 'package:stylehub_store/services/fake_store_fashion_api.dart';
import 'package:stylehub_store/services/local_storage_service.dart';
import 'package:stylehub_store/services/mock_data_service.dart';
import 'package:stylehub_store/services/product_service.dart';

void main() {
  group('seller product public catalog and search', () {
    test(
      'approved seller product appears in public marketplace products',
      () async {
        final context = await _MarketplaceSearchTestContext.create();

        expect(
          context.productController.marketplaceProducts.map((item) => item.id),
          contains(context.activeProduct.id),
        );
      },
    );

    test(
      'newly published seller product appears live in home listing search and storefront',
      () async {
        final context = await _MarketplaceSearchTestContext.create();
        final liveProduct = _sellerProduct(
          id: 'seller_public_live_update',
          storeId: 'store_seller_1',
          status: ProductStatus.active,
          isActive: true,
          titleEn: 'Live Emerald Demo Coat',
          titleAr: 'معطف زمردي مباشر',
        );

        context.searchController
          ..setQuery('Live Emerald Demo Coat')
          ..search();
        expect(
          context.searchController.results.map((item) => item.id),
          isNot(contains(liveProduct.id)),
        );

        await context.mockData.addOrUpdateProduct(liveProduct);

        expect(
          context.productController.marketplaceProducts.map((item) => item.id),
          contains(liveProduct.id),
        );
        expect(
          context.productController.forYou('women').map((item) => item.id),
          contains(liveProduct.id),
        );
        expect(
          context.productController
              .productsForCategoryIds(const ['women'])
              .map((item) => item.id),
          contains(liveProduct.id),
        );
        expect(
          context.productController
              .productsForStore('store_seller_1')
              .map((item) => item.id),
          contains(liveProduct.id),
        );
        expect(
          context.searchController.results.map((item) => item.id),
          contains(liveProduct.id),
        );
      },
    );

    test('pending seller product does not appear publicly', () async {
      final context = await _MarketplaceSearchTestContext.create();

      expect(
        context.productController.marketplaceProducts.map((item) => item.id),
        isNot(contains(context.pendingProduct.id)),
      );
    });

    test(
      'search finds seller product by exact partial and fuzzy names',
      () async {
        final context = await _MarketplaceSearchTestContext.create();

        context.searchController
          ..setQuery('Azure Cotton Test Tunic')
          ..search();
        expect(
          context.searchController.results.map((item) => item.id),
          contains(context.activeProduct.id),
        );

        context.searchController
          ..setQuery('Cotton Tunic')
          ..search();
        expect(
          context.searchController.results.map((item) => item.id),
          contains(context.activeProduct.id),
        );

        context.searchController
          ..setQuery('Azurre Coton Tunik')
          ..search();
        expect(
          context.searchController.results.map((item) => item.id),
          contains(context.activeProduct.id),
        );
      },
    );

    test('Arabic normalization tolerates alef ta marbuta ya and tashkeel', () {
      expect(
        normalizeSearchText('أزياءٌ راقية'),
        normalizeSearchText('ازياء راقيه'),
      );
      expect(normalizeSearchText('إطلالة'), normalizeSearchText('اطلاله'));
      expect(normalizeSearchText('فتى أنيق'), normalizeSearchText('فتي انيق'));
    });

    test(
      'search by store name returns store and products from that store',
      () async {
        final context = await _MarketplaceSearchTestContext.create();

        context.searchController
          ..setQuery('Demo Seller')
          ..search();

        expect(
          context.searchController.storeResults.map((item) => item.id),
          contains('store_seller_1'),
        );
        expect(
          context.searchController.results.map((item) => item.id),
          contains(context.activeProduct.id),
        );
      },
    );

    test('product and storefront result routes exist', () {
      expect(AppRoutes.productDetails, isNotEmpty);
      expect(AppRoutes.storefront, isNotEmpty);
    });

    test(
      'unavailable stock follows catalog config without exposing pending approval',
      () async {
        final context = await _MarketplaceSearchTestContext.create();
        final store = context.mockData.storeBySellerId('seller_1');
        final seller = context.mockData.userById('seller_1');
        final outOfStock = context.activeProduct.copyWith(
          id: 'seller_public_out_of_stock',
          stock: 0,
          status: ProductStatus.outOfStock,
          isActive: false,
        );

        final outOfStockResult = ProductAvailabilityPolicy.getAvailability(
          product: outOfStock,
          seller: seller,
          store: store,
        );
        final pendingResult = ProductAvailabilityPolicy.getAvailability(
          product: context.pendingProduct,
          seller: seller,
          store: store,
        );

        expect(outOfStockResult.isVisible, isTrue);
        expect(outOfStockResult.isOrderable, isFalse);
        expect(pendingResult.isVisible, isFalse);
        expect(pendingResult.isOrderable, isFalse);
      },
    );
  });
}

class _MarketplaceSearchTestContext {
  const _MarketplaceSearchTestContext({
    required this.mockData,
    required this.productController,
    required this.searchController,
    required this.activeProduct,
    required this.pendingProduct,
  });

  final MockDataService mockData;
  final ProductController productController;
  final SearchController searchController;
  final ProductModel activeProduct;
  final ProductModel pendingProduct;

  static Future<_MarketplaceSearchTestContext> create() async {
    SharedPreferences.setMockInitialValues({});
    final localStorageService = await LocalStorageService.create();
    final mockData = await MockDataService.create(
      localStorageService: localStorageService,
    );
    final authController = AuthController(authService: AuthService(mockData))
      ..continueAsGuest();
    final productController = ProductController(
      productService: ProductService(
        mockData,
        productApi: _EmptyDummyJsonProductApi(),
        fashionApi: _EmptyFakeStoreFashionApi(),
      ),
      mockDataService: mockData,
    )..bind(authController: authController);
    final categoryController = CategoryController(mockDataService: mockData)
      ..loadCategories();
    final searchController = SearchController(mockDataService: mockData);
    final store = mockData.storeBySellerId('seller_1')!;
    final activeProduct = _sellerProduct(
      id: 'seller_public_test_active',
      storeId: store.id,
      status: ProductStatus.active,
      isActive: true,
      titleEn: 'Azure Cotton Test Tunic',
      titleAr: 'تونيك قطني أزرق للاختبار',
    );
    final pendingProduct = _sellerProduct(
      id: 'seller_public_test_pending',
      storeId: store.id,
      status: ProductStatus.pendingApproval,
      isActive: false,
      titleEn: 'Hidden Pending Review Tunic',
      titleAr: 'تونيك مخفي بانتظار الموافقة',
    );

    await mockData.addOrUpdateProduct(activeProduct);
    await mockData.addOrUpdateProduct(pendingProduct);
    await productController.loadInitialData();
    searchController.bind(
      authController: authController,
      productController: productController,
      categoryController: categoryController,
    );

    return _MarketplaceSearchTestContext(
      mockData: mockData,
      productController: productController,
      searchController: searchController,
      activeProduct: activeProduct,
      pendingProduct: pendingProduct,
    );
  }
}

ProductModel _sellerProduct({
  required String id,
  required String storeId,
  required ProductStatus status,
  required bool isActive,
  required String titleEn,
  required String titleAr,
}) {
  final now = DateTime(2026, 1, 1);
  return ProductModel(
    id: id,
    sellerId: 'seller_1',
    sellerName: 'Demo Seller',
    storeId: storeId,
    title: titleEn,
    titleText: LocalizedTextModel(en: titleEn, ar: titleAr),
    categoryId: 'women',
    categoryName: 'Women',
    department: 'women',
    departmentId: 'women',
    subcategoryId: 'women-clothing',
    subcategoryName: 'Women Clothing',
    price: 28,
    oldPrice: 36,
    discount: 22,
    rating: 0,
    reviewCount: 0,
    imageUrls: const ['https://example.com/test-product.jpg'],
    colors: const ['Blue'],
    sizes: const ['M'],
    description: 'A searchable local seller product.',
    descriptionText: const LocalizedTextModel(
      en: 'A searchable local seller product.',
      ar: 'منتج بائع محلي قابل للبحث.',
    ),
    material: 'Cotton',
    materialText: const LocalizedTextModel(en: 'Cotton', ar: 'قطن'),
    composition: '100% cotton',
    compositionText: const LocalizedTextModel(
      en: '100% cotton',
      ar: 'قطن 100%',
    ),
    careInstructions: 'Machine wash cold',
    careInstructionsText: const LocalizedTextModel(
      en: 'Machine wash cold',
      ar: 'غسل بارد',
    ),
    sku: 'SELLER-PUBLIC-TEST',
    stock: 8,
    tags: const ['seller listing', 'women clothing', 'tunic'],
    isNew: true,
    isHot: false,
    isFlashSale: false,
    soldCount: 0,
    status: status,
    isActive: isActive,
    createdAt: now,
    updatedAt: now,
    publishedAt: status == ProductStatus.active ? now : null,
  );
}

class _EmptyDummyJsonProductApi extends DummyJsonProductApi {
  @override
  Future<List<ProductModel>> fetchProducts() async => const [];
}

class _EmptyFakeStoreFashionApi extends FakeStoreFashionApi {
  @override
  Future<List<ProductModel>> fetchClothingProducts() async => const [];
}
