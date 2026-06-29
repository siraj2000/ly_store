import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stylehub_store/controllers/auth_controller.dart';
import 'package:stylehub_store/controllers/seller_dashboard_controller.dart';
import 'package:stylehub_store/controllers/seller_finance_controller.dart';
import 'package:stylehub_store/controllers/seller_order_controller.dart';
import 'package:stylehub_store/controllers/seller_product_controller.dart';
import 'package:stylehub_store/controllers/seller_store_controller.dart';
import 'package:stylehub_store/models/admin/platform_setting_model.dart';
import 'package:stylehub_store/models/order_item_model.dart';
import 'package:stylehub_store/models/order_model.dart';
import 'package:stylehub_store/models/product_status.dart';
import 'package:stylehub_store/models/seller_order_model.dart';
import 'package:stylehub_store/repositories/local_admin_repository.dart';
import 'package:stylehub_store/repositories/local_marketplace_repository.dart';
import 'package:stylehub_store/services/auth_service.dart';
import 'package:stylehub_store/services/local_storage_service.dart';
import 'package:stylehub_store/services/mock_data_service.dart';
import 'package:stylehub_store/services/order_service.dart';

void main() {
  group('seller marketplace safety', () {
    test(
      'seller cannot activate directly when product approval is required',
      () async {
        final context = await _SellerTestContext.create(
          requiresProductApproval: true,
        );
        final controller = context.productController;
        final original = context.mockData.productsForSeller('seller_1').first;
        await context.mockData.addOrUpdateProduct(
          original.copyWith(
            status: ProductStatus.inactive,
            isActive: false,
            clearPublishedAt: true,
          ),
        );

        await controller.toggleActive(original.id);

        final updated = context.mockData
            .productsForSeller('seller_1')
            .firstWhere((product) => product.id == original.id);
        expect(updated.status, ProductStatus.pendingApproval);
        expect(updated.isActive, isFalse);
      },
    );

    test('rejected product resubmits to pending approval', () async {
      final context = await _SellerTestContext.create(
        requiresProductApproval: true,
      );
      final controller = context.productController;
      final existing = context.mockData
          .productsForSeller('seller_1')
          .first
          .copyWith(status: ProductStatus.rejected, isActive: false);

      final rebuilt = controller.buildProduct(
        id: existing.id,
        titleEn: existing.titleText.en,
        titleAr: existing.titleText.ar,
        descriptionEn: existing.descriptionText.en,
        descriptionAr: existing.descriptionText.ar,
        categoryId: existing.categoryId,
        categoryName: existing.categoryName,
        subcategoryId: existing.subcategoryId,
        subcategoryName: existing.subcategoryName,
        department: existing.department,
        price: existing.price,
        oldPrice: existing.oldPrice,
        stock: existing.stock,
        sku: existing.sku,
        colors: existing.colors,
        sizes: existing.sizes,
        materialEn: existing.materialText.en,
        materialAr: existing.materialText.ar,
        compositionEn: existing.compositionText.en,
        compositionAr: existing.compositionText.ar,
        careInstructionsEn: existing.careInstructionsText.en,
        careInstructionsAr: existing.careInstructionsText.ar,
        saveAsDraft: false,
        isReturnable: existing.isReturnable,
        selectedImagePaths: existing.imageUrls,
        existingProduct: existing,
      );

      expect(rebuilt.status, ProductStatus.pendingApproval);
      expect(rebuilt.isActive, isFalse);
    });

    test('active price edit moves product back to pending approval', () async {
      final context = await _SellerTestContext.create(
        requiresProductApproval: true,
      );
      final original = context.mockData.productsForSeller('seller_1').first;
      await context.mockData.addOrUpdateProduct(
        original.copyWith(status: ProductStatus.active, isActive: true),
      );

      await context.productController.changePrice(
        original.id,
        original.price + 5,
      );

      final updated = context.mockData
          .productsForSeller('seller_1')
          .firstWhere((product) => product.id == original.id);
      expect(updated.price, original.price + 5);
      expect(updated.status, ProductStatus.pendingApproval);
      expect(updated.isActive, isFalse);
    });

    test(
      'draft validation is relaxed while publish validation is strict',
      () async {
        final context = await _SellerTestContext.create();
        final controller = context.productController;

        expect(
          controller.validateProductInput(
            saveAsDraft: true,
            titleEn: 'Draft idea',
            titleAr: '',
            descriptionEn: '',
            descriptionAr: '',
            price: '',
            oldPrice: '',
            stock: '',
            sku: '',
            materialEn: '',
            materialAr: '',
          ),
          isTrue,
        );

        expect(
          controller.validateProductInput(
            saveAsDraft: false,
            titleEn: 'Publish idea',
            titleAr: '',
            descriptionEn: '',
            descriptionAr: '',
            price: '',
            oldPrice: '',
            stock: '',
            sku: '',
            materialEn: '',
            materialAr: '',
          ),
          isFalse,
        );
        expect(controller.validationErrors['images'], isNotNull);
        expect(controller.validationErrors['titleAr'], isNotNull);
      },
    );

    test(
      'seller categories use central IDs and enforce store allowed categories',
      () async {
        final context = await _SellerTestContext.create();
        final store = context.mockData.storeBySellerId('seller_1')!;
        context.mockData.addOrUpdateStore(
          store.copyWith(allowedCategoryIds: const ['women']),
        );
        await context.rebindProductController();

        expect(
          context.productController.categoriesForSelectedDepartment,
          isEmpty,
        );
        context.productController.setDepartment('women');
        expect(context.productController.categoriesForSelectedDepartment, [
          'women',
        ]);

        context.productController.setDepartment('electronics');
        context.productController.setCategory('electronics');
        final valid = context.productController.validateProductInput(
          saveAsDraft: false,
          titleEn: 'Phone stand',
          titleAr: 'حامل هاتف',
          descriptionEn: 'Desk phone stand',
          descriptionAr: 'حامل هاتف للمكتب',
          price: '10',
          oldPrice: '12',
          stock: '4',
          sku: 'PHONE-STAND',
          materialEn: 'Metal',
          materialAr: 'معدن',
        );
        expect(valid, isFalse);
        expect(
          context.productController.validationErrors['category'],
          'This category is not allowed for your store.',
        );
      },
    );

    test('seller product save persists stable category identifiers', () async {
      final context = await _SellerTestContext.create();
      final controller = context.productController;
      final existing = context.mockData.productsForSeller('seller_1').first;

      final product = controller.buildProduct(
        id: 'seller_test_stable_ids',
        titleEn: 'Stable IDs Dress',
        titleAr: 'فستان بمعرفات ثابتة',
        descriptionEn: 'Uses stable category identifiers.',
        descriptionAr: 'يستخدم معرفات تصنيف ثابتة.',
        categoryId: existing.categoryId,
        categoryName: existing.categoryName,
        subcategoryId: existing.subcategoryId,
        subcategoryName: existing.subcategoryName,
        department: existing.departmentId.isNotEmpty
            ? existing.departmentId
            : existing.department,
        price: 25,
        oldPrice: 30,
        stock: 6,
        sku: 'STABLE-ID-DRESS',
        colors: const ['Black'],
        sizes: const ['M'],
        materialEn: 'Cotton',
        materialAr: 'قطن',
        compositionEn: '100% cotton',
        compositionAr: 'قطن 100%',
        careInstructionsEn: 'Machine wash cold',
        careInstructionsAr: 'غسل بارد',
        saveAsDraft: false,
        isReturnable: true,
        selectedImagePaths: existing.imageUrls,
      );

      await controller.saveProduct(product);

      final saved = context.mockData.allProducts.firstWhere(
        (item) => item.id == product.id,
      );
      expect(saved.departmentId, product.departmentId);
      expect(saved.categoryId, product.categoryId);
      expect(saved.subcategoryId, product.subcategoryId);
      expect(saved.subcategoryName, product.subcategoryName);
    });

    test('active variant stock controls total seller product stock', () async {
      final context = await _SellerTestContext.create();
      final controller = context.productController;
      final existing = context.mockData.productsForSeller('seller_1').first;

      final product = controller.buildProduct(
        id: 'seller_test_variant_stock',
        titleEn: 'Variant Stock Shirt',
        titleAr: 'قميص بمخزون متغيرات',
        descriptionEn: 'Stock is split across variants.',
        descriptionAr: 'المخزون موزع على المتغيرات.',
        categoryId: existing.categoryId,
        categoryName: existing.categoryName,
        subcategoryId: existing.subcategoryId,
        subcategoryName: existing.subcategoryName,
        department: existing.departmentId.isNotEmpty
            ? existing.departmentId
            : existing.department,
        price: 35,
        oldPrice: 40,
        stock: 9,
        sku: 'VARIANT-STOCK-SHIRT',
        colors: const ['Black', 'White'],
        sizes: const ['S', 'M'],
        materialEn: 'Cotton',
        materialAr: 'قطن',
        compositionEn: 'Cotton blend',
        compositionAr: 'مزيج قطن',
        careInstructionsEn: 'Wash gently',
        careInstructionsAr: 'غسل بلطف',
        saveAsDraft: false,
        isReturnable: true,
        selectedImagePaths: existing.imageUrls,
      );

      expect(product.variants, hasLength(4));
      expect(
        product.stock,
        product.variants
            .where((variant) => variant.isActive)
            .fold<int>(0, (total, variant) => total + variant.stock),
      );
    });

    test(
      'seller order update recomputes master status and notifies customer',
      () async {
        final context = await _SellerTestContext.create();
        final orderService = OrderService(context.mockData);
        final controller = SellerOrderController(orderService: orderService)
          ..bind(authController: context.authController);
        final fixture = _createSplitOrder(context.mockData);
        context.mockData.createOrder(
          fixture.masterOrder,
          sellerOrders: fixture.sellerOrders,
        );

        await controller.updateOrderStatus(
          fixture.sellerOrders.first.id,
          'Delivered',
        );

        final master = context.mockData.platformOrders.firstWhere(
          (order) => order.id == fixture.masterOrder.id,
        );
        expect(master.status, 'Processing');
        expect(master.paymentStatus, 'Pending');
        final notifications = context.mockData.notificationsForUser(
          'customer_1',
        );
        expect(
          notifications.any(
            (notification) =>
                notification.data['sellerOrderId'] ==
                    fixture.sellerOrders.first.id &&
                notification.data['newStatus'] == 'Delivered',
          ),
          isTrue,
        );
      },
    );

    test('mark shipped saves carrier and tracking data', () async {
      final context = await _SellerTestContext.create();
      final orderService = OrderService(context.mockData);
      final controller = SellerOrderController(orderService: orderService)
        ..bind(authController: context.authController);
      final fixture = _createSplitOrder(context.mockData);
      context.mockData.createOrder(
        fixture.masterOrder,
        sellerOrders: fixture.sellerOrders,
      );

      final updated = await controller.markOrderShipped(
        orderId: fixture.sellerOrders.first.id,
        carrierName: 'LY Express',
        trackingNumber: 'TRK-100',
        shippingNotes: 'Handed to carrier',
      );

      expect(updated, isTrue);
      final sellerOrder = context.mockData.sellerOrders.firstWhere(
        (order) => order.id == fixture.sellerOrders.first.id,
      );
      expect(sellerOrder.status, 'Shipped');
      expect(sellerOrder.carrierName, 'LY Express');
      expect(sellerOrder.trackingNumber, 'TRK-100');
      expect(sellerOrder.shippedAt, isNotNull);
      expect(
        context.mockData
            .notificationsForUser('customer_1')
            .any(
              (notification) =>
                  notification.data['sellerOrderId'] == sellerOrder.id &&
                  notification.data['newStatus'] == 'Shipped',
            ),
        isTrue,
      );
    });

    test('seller cancel order requires and saves a reason', () async {
      final context = await _SellerTestContext.create();
      final orderService = OrderService(context.mockData);
      final controller = SellerOrderController(orderService: orderService)
        ..bind(authController: context.authController);
      final fixture = _createSplitOrder(context.mockData);
      context.mockData.createOrder(
        fixture.masterOrder,
        sellerOrders: fixture.sellerOrders,
      );

      expect(
        await controller.cancelOrder(
          orderId: fixture.sellerOrders.first.id,
          reason: '',
        ),
        isFalse,
      );

      final cancelled = await controller.cancelOrder(
        orderId: fixture.sellerOrders.first.id,
        reason: 'Out of stock',
      );

      expect(cancelled, isTrue);
      final sellerOrder = context.mockData.sellerOrders.firstWhere(
        (order) => order.id == fixture.sellerOrders.first.id,
      );
      expect(sellerOrder.status, 'Cancelled');
      expect(sellerOrder.cancellationReason, 'Out of stock');
      expect(sellerOrder.cancelledAt, isNotNull);
      expect(
        context.mockData
            .notificationsForUser('customer_1')
            .any(
              (notification) =>
                  notification.data['sellerOrderId'] == sellerOrder.id &&
                  notification.data['newStatus'] == 'Cancelled',
            ),
        isTrue,
      );
    });

    test(
      'seller finance excludes pending and refunded returned orders',
      () async {
        final context = await _SellerTestContext.create();
        final controller = SellerFinanceController(
          orderService: OrderService(context.mockData),
        )..bind(authController: context.authController);
        final fixture = _createSplitOrder(context.mockData);
        context.mockData.saveSellerOrders([
          fixture.sellerOrders.first.copyWith(
            status: 'Delivered',
            paymentStatus: 'Paid',
          ),
          fixture.sellerOrders.last.copyWith(
            status: 'Returned',
            paymentStatus: 'Refunded',
          ),
        ]);
        await _settleAsync();

        expect(
          controller.availableBalance,
          fixture.sellerOrders.first.sellerNetAmount,
        );
        expect(
          controller.totalEarnings,
          fixture.sellerOrders.first.sellerNetAmount,
        );
      },
    );

    test(
      'store rating and public visibility do not use fake fallbacks',
      () async {
        final context = await _SellerTestContext.create();
        final store = context.mockData.storeBySellerId('seller_1')!;
        context.mockData.addOrUpdateStore(
          store.copyWith(rating: 0, reviewCount: 0, followersCount: 0),
        );
        final storeController =
            SellerStoreController(
              marketplaceRepository: context.marketplaceRepository,
            )..bind(
              authController: context.authController,
              sellerProductController: context.productController,
            );
        await _settleAsync();

        expect(storeController.storeRating, 0);
        expect(storeController.followers, 0);

        final product = context.mockData.productsForSeller('seller_1').first;
        expect(
          context.mockData.isProductPublic(
            product.copyWith(sellerId: 'missing'),
          ),
          isFalse,
        );
        expect(
          context.mockData.isProductPublic(
            product.copyWith(storeId: 'missing'),
          ),
          isFalse,
        );
      },
    );

    test('dashboard conversion is data-derived, not hardcoded', () async {
      final context = await _SellerTestContext.create();
      final controller = SellerDashboardController(
        mockDataService: context.mockData,
      )..bind(authController: context.authController);

      if (controller.totalProductViews == 0) {
        expect(controller.conversionRate, isNull);
      } else {
        expect(
          controller.conversionRate,
          controller.sellerOrders.length / controller.totalProductViews,
        );
      }
    });
  });
}

class _SellerTestContext {
  _SellerTestContext({
    required this.mockData,
    required this.authController,
    required this.productController,
    required this.marketplaceRepository,
  });

  final MockDataService mockData;
  final AuthController authController;
  final SellerProductController productController;
  final LocalMarketplaceRepository marketplaceRepository;

  static Future<_SellerTestContext> create({
    bool requiresProductApproval = false,
  }) async {
    SharedPreferences.setMockInitialValues({});
    final localStorageService = await LocalStorageService.create();
    final mockData = await MockDataService.create(
      localStorageService: localStorageService,
    );
    final adminRepository = LocalAdminRepository(
      localStorageService: localStorageService,
    );
    await adminRepository.savePlatformSettings(
      PlatformSettingModel(
        platformName: 'StyleHub',
        defaultLanguageCode: 'en',
        defaultCurrencyCode: 'USD',
        requiresProductApproval: requiresProductApproval,
        defaultCommissionRate: 0.12,
        minimumPayoutAmount: 50,
        refundMakerCheckerThreshold: 150,
      ),
    );
    final authController = AuthController(authService: AuthService(mockData));
    await authController.loginWithEmail('seller@stylehub.com', '123456');
    final marketplaceRepository = LocalMarketplaceRepository(
      mockDataService: mockData,
    );
    final productController = SellerProductController(
      mockDataService: mockData,
      adminRepository: adminRepository,
      marketplaceRepository: marketplaceRepository,
    )..bind(authController: authController);
    final context = _SellerTestContext(
      mockData: mockData,
      authController: authController,
      productController: productController,
      marketplaceRepository: marketplaceRepository,
    );
    await context.rebindProductController();
    return context;
  }

  Future<void> rebindProductController() async {
    productController.bind(authController: authController);
    await _settleAsync();
  }
}

class _SplitOrderFixture {
  const _SplitOrderFixture({
    required this.masterOrder,
    required this.sellerOrders,
  });

  final OrderModel masterOrder;
  final List<SellerOrderModel> sellerOrders;
}

_SplitOrderFixture _createSplitOrder(MockDataService mockData) {
  final productOne = mockData.productsForSeller('seller_1').first;
  final productTwo = mockData.productsForSeller('seller_2').first;
  final itemOne = OrderItemModel(
    id: 'test_item_1',
    product: productOne,
    selectedColor: productOne.colors.firstOrNull ?? '',
    selectedSize: productOne.sizes.firstOrNull ?? '',
    quantity: 1,
    price: productOne.price,
  );
  final itemTwo = OrderItemModel(
    id: 'test_item_2',
    product: productTwo,
    selectedColor: productTwo.colors.firstOrNull ?? '',
    selectedSize: productTwo.sizes.firstOrNull ?? '',
    quantity: 1,
    price: productTwo.price,
  );
  final address = mockData.demoAddresses.first;
  final paymentMethod = mockData.paymentMethods.first;
  final now = DateTime.now();
  final masterOrder = OrderModel(
    id: 'test_master_order',
    customerId: 'customer_1',
    customerName: 'Demo Customer',
    items: [itemOne, itemTwo],
    status: 'Pending',
    createdAt: now,
    total: productOne.price + productTwo.price,
    address: address,
    paymentMethod: paymentMethod,
    estimatedDelivery: now.add(const Duration(days: 5)),
    paymentStatus: 'Pending',
    shippingStatus: 'Pending',
  );
  final sellerOrders = [
    SellerOrderModel(
      id: 'test_seller_order_1',
      masterOrderId: masterOrder.id,
      sellerId: 'seller_1',
      storeId: productOne.storeId,
      customerId: 'customer_1',
      customerName: 'Demo Customer',
      items: [itemOne],
      subtotal: productOne.price,
      platformCommission: productOne.price * 0.12,
      sellerNetAmount: productOne.price * 0.88,
      status: 'Processing',
      paymentStatus: 'Pending',
      shippingStatus: 'Processing',
      createdAt: now,
      updatedAt: now,
      address: address,
      paymentMethod: paymentMethod,
      estimatedDelivery: now.add(const Duration(days: 5)),
    ),
    SellerOrderModel(
      id: 'test_seller_order_2',
      masterOrderId: masterOrder.id,
      sellerId: 'seller_2',
      storeId: productTwo.storeId,
      customerId: 'customer_1',
      customerName: 'Demo Customer',
      items: [itemTwo],
      subtotal: productTwo.price,
      platformCommission: productTwo.price * 0.12,
      sellerNetAmount: productTwo.price * 0.88,
      status: 'Processing',
      paymentStatus: 'Pending',
      shippingStatus: 'Processing',
      createdAt: now,
      updatedAt: now,
      address: address,
      paymentMethod: paymentMethod,
      estimatedDelivery: now.add(const Duration(days: 5)),
    ),
  ];
  return _SplitOrderFixture(
    masterOrder: masterOrder,
    sellerOrders: sellerOrders,
  );
}

Future<void> _settleAsync() async {
  await Future<void>.delayed(const Duration(milliseconds: 20));
}
