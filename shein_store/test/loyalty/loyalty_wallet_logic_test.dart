import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stylehub_store/controllers/auth_controller.dart';
import 'package:stylehub_store/controllers/cart_controller.dart';
import 'package:stylehub_store/controllers/checkout_controller.dart';
import 'package:stylehub_store/controllers/order_controller.dart';
import 'package:stylehub_store/controllers/product_controller.dart';
import 'package:stylehub_store/core/config/loyalty_policy.dart';
import 'package:stylehub_store/core/helpers/product_orderability_helper.dart';
import 'package:stylehub_store/core/policies/product_availability_policy.dart';
import 'package:stylehub_store/models/order_item_model.dart';
import 'package:stylehub_store/models/order_model.dart';
import 'package:stylehub_store/models/payment_method_model.dart';
import 'package:stylehub_store/models/product_model.dart';
import 'package:stylehub_store/models/product_status.dart';
import 'package:stylehub_store/models/product_variant_model.dart';
import 'package:stylehub_store/services/auth_service.dart';
import 'package:stylehub_store/services/cart_service.dart';
import 'package:stylehub_store/services/local_storage_service.dart';
import 'package:stylehub_store/services/mock_data_service.dart';
import 'package:stylehub_store/services/order_service.dart';
import 'package:stylehub_store/services/product_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<MockDataService> buildMockData() async {
    SharedPreferences.setMockInitialValues({});
    final localStorage = await LocalStorageService.create();
    return MockDataService.create(localStorageService: localStorage);
  }

  test(
    'gift card redemption credits wallet and blocks duplicate use',
    () async {
      final mockData = await buildMockData();
      final customer = mockData.userById('customer_1')!;
      final startingBalance = customer.walletBalance;

      final result = mockData.redeemGiftCard(
        customerId: customer.id,
        code: 'ly25',
      );

      expect(result.isSuccess, isTrue);
      final updated = mockData.userById(customer.id)!;
      expect(updated.walletBalance, startingBalance + 25);
      expect(updated.walletTransactions.first.type, 'gift_card');
      expect(mockData.redeemedGiftCardCount(customer.id), 1);

      final duplicate = mockData.redeemGiftCard(
        customerId: customer.id,
        code: 'LY25',
      );
      expect(duplicate.isSuccess, isFalse);
      expect(duplicate.messageKey, 'already_redeemed');
    },
  );

  test('checkout rewards award order points once', () async {
    final mockData = await buildMockData();
    final customer = mockData.userById('customer_1')!;
    final product = mockData.products.first;
    final subtotal = product.price * 2;
    final earned = LoyaltyPolicy.pointsEarned(
      eligibleSubtotal: subtotal,
      totalQuantity: 2,
    );

    final order = OrderModel(
      id: 'order_loyalty_test',
      customerId: customer.id,
      customerName: customer.name,
      items: [
        OrderItemModel(
          id: 'order_item_loyalty_test',
          product: product,
          selectedColor: product.colors.isEmpty ? '' : product.colors.first,
          selectedSize: product.sizes.isEmpty ? '' : product.sizes.first,
          quantity: 2,
          price: product.price,
        ),
      ],
      status: 'Processing',
      createdAt: DateTime.now(),
      total: subtotal,
      address: mockData.demoAddresses.first,
      paymentMethod: mockData.paymentMethods.first,
      estimatedDelivery: DateTime.now().add(const Duration(days: 5)),
      loyaltyPointsEarned: earned,
    );

    mockData.applyCheckoutRewards(order);
    final afterFirstAward = mockData.userById(customer.id)!;
    expect(afterFirstAward.points, customer.points + earned);
    expect(
      afterFirstAward.pointsTransactions
          .where((item) => item.orderId == order.id && item.type == 'earn')
          .length,
      1,
    );

    mockData.applyCheckoutRewards(order);
    final afterSecondAward = mockData.userById(customer.id)!;
    expect(afterSecondAward.points, afterFirstAward.points);
    expect(
      afterSecondAward.pointsTransactions
          .where((item) => item.orderId == order.id && item.type == 'earn')
          .length,
      1,
    );
  });

  test(
    'checkout inventory reservation deducts selected variant stock',
    () async {
      final mockData = await buildMockData();
      final baseProduct = mockData.productsForSeller('seller_1').first;
      final product = baseProduct.copyWith(
        id: 'variant_inventory_test',
        stock: 3,
        status: ProductStatus.active,
        isActive: true,
        variants: const [
          ProductVariantModel(
            id: 'variant_black_m',
            color: 'Black',
            size: 'M',
            sku: 'BLACK-M',
            stock: 3,
          ),
        ],
      );
      await mockData.addOrUpdateProduct(product);

      final order = _inventoryOrder(
        mockData: mockData,
        product: product,
        quantity: 2,
        color: 'Black',
        size: 'M',
      );

      expect(mockData.reserveInventoryForOrder(order), isTrue);
      final updated = mockData.allProducts.firstWhere(
        (item) => item.id == product.id,
      );
      expect(updated.stock, 1);
      expect(updated.variants.single.stock, 1);
      expect(updated.status, ProductStatus.active);
    },
  );

  test(
    'checkout inventory reservation fails without partial stock changes',
    () async {
      final mockData = await buildMockData();
      final baseProduct = mockData.productsForSeller('seller_1').first;
      final product = baseProduct.copyWith(
        id: 'variant_inventory_fail_test',
        stock: 1,
        status: ProductStatus.active,
        isActive: true,
        variants: const [
          ProductVariantModel(
            id: 'variant_white_s',
            color: 'White',
            size: 'S',
            sku: 'WHITE-S',
            stock: 1,
          ),
        ],
      );
      await mockData.addOrUpdateProduct(product);

      final order = _inventoryOrder(
        mockData: mockData,
        product: product,
        quantity: 2,
        color: 'White',
        size: 'S',
      );

      expect(mockData.reserveInventoryForOrder(order), isFalse);
      final unchanged = mockData.allProducts.firstWhere(
        (item) => item.id == product.id,
      );
      expect(unchanged.stock, 1);
      expect(unchanged.variants.single.stock, 1);
      expect(unchanged.status, ProductStatus.active);
    },
  );

  test(
    'checkout availability succeeds for valid non-variant product',
    () async {
      final mockData = await buildMockData();
      final baseProduct = mockData.productsForSeller('seller_1').first;
      final product = baseProduct.copyWith(
        id: 'simple_inventory_valid_test',
        stock: 4,
        status: ProductStatus.active,
        isActive: true,
        colors: const [],
        sizes: const [],
        variants: const [],
      );
      await mockData.addOrUpdateProduct(product);

      final order = _inventoryOrder(
        mockData: mockData,
        product: product,
        quantity: 2,
        color: '',
        size: '',
      );
      final result = mockData.validateOrderAvailability(order).single;

      expect(result.isAvailable, isTrue);
      expect(mockData.reserveInventoryForOrder(order), isTrue);
      final updated = mockData.allProducts.firstWhere(
        (item) => item.id == product.id,
      );
      expect(updated.stock, 2);
    },
  );

  test(
    'checkout availability fails with product-specific pending approval reason',
    () async {
      final mockData = await buildMockData();
      final baseProduct = mockData.productsForSeller('seller_1').first;
      final product = baseProduct.copyWith(
        id: 'pending_inventory_test',
        title: 'Launch Dress',
        stock: 3,
        status: ProductStatus.pendingApproval,
        isActive: true,
        variants: const [],
      );
      await mockData.addOrUpdateProduct(product);

      final result = mockData
          .validateOrderAvailability(
            _inventoryOrder(
              mockData: mockData,
              product: product,
              quantity: 1,
              color: '',
              size: '',
            ),
          )
          .single;

      expect(result.isAvailable, isFalse);
      expect(
        result.reasonCode,
        CartItemAvailabilityReason.productPendingApproval,
      );
      expect(result.englishMessage, contains('Launch Dress'));
    },
  );

  test('checkout availability fails when store is in vacation mode', () async {
    final mockData = await buildMockData();
    final product = mockData
        .productsForSeller('seller_1')
        .first
        .copyWith(
          id: 'vacation_store_product_test',
          stock: 3,
          status: ProductStatus.active,
          isActive: true,
          variants: const [],
        );
    await mockData.addOrUpdateProduct(product);
    final store = mockData.storeById(product.storeId)!;
    mockData.addOrUpdateStore(store.copyWith(vacationMode: true));

    final result = mockData
        .validateOrderAvailability(
          _inventoryOrder(
            mockData: mockData,
            product: product,
            quantity: 1,
            color: '',
            size: '',
          ),
        )
        .single;

    expect(result.isAvailable, isFalse);
    expect(result.reasonCode, CartItemAvailabilityReason.storeVacationMode);
    expect(result.arabicMessage, 'المتجر حالياً في وضع الإجازة.');
  });

  test('checkout availability fails when seller is inactive', () async {
    final mockData = await buildMockData();
    final product = mockData
        .productsForSeller('seller_1')
        .first
        .copyWith(
          id: 'inactive_seller_product_test',
          stock: 3,
          status: ProductStatus.active,
          isActive: true,
          variants: const [],
        );
    await mockData.addOrUpdateProduct(product);
    final seller = mockData.userById(product.sellerId)!;
    mockData.updateUser(seller.copyWith(isActive: false));

    final result = mockData
        .validateOrderAvailability(
          _inventoryOrder(
            mockData: mockData,
            product: product,
            quantity: 1,
            color: '',
            size: '',
          ),
        )
        .single;

    expect(result.isAvailable, isFalse);
    expect(result.reasonCode, CartItemAvailabilityReason.sellerInactive);
  });

  test(
    'checkout availability fails when selected variant stock is zero',
    () async {
      final mockData = await buildMockData();
      final baseProduct = mockData.productsForSeller('seller_1').first;
      final product = baseProduct.copyWith(
        id: 'variant_zero_stock_test',
        stock: 0,
        status: ProductStatus.active,
        isActive: true,
        variants: const [
          ProductVariantModel(
            id: 'variant_red_l',
            color: 'Red',
            size: 'L',
            sku: 'RED-L',
            stock: 0,
          ),
        ],
      );
      await mockData.addOrUpdateProduct(product);

      final result = mockData
          .validateOrderAvailability(
            _inventoryOrder(
              mockData: mockData,
              product: product,
              quantity: 1,
              color: 'Red',
              size: 'L',
            ),
          )
          .single;

      expect(result.isAvailable, isFalse);
      expect(result.reasonCode, CartItemAvailabilityReason.variantOutOfStock);
    },
  );

  test(
    'available product with no colors and no sizes can be checked out',
    () async {
      final mockData = await buildMockData();
      final baseProduct = mockData.productsForSeller('seller_1').first;
      final product = baseProduct.copyWith(
        id: 'no_options_checkout_test',
        stock: 5,
        status: ProductStatus.active,
        isActive: true,
        colors: const [],
        sizes: const [],
        variants: const [],
      );
      await mockData.addOrUpdateProduct(product);

      final order = _inventoryOrder(
        mockData: mockData,
        product: product,
        quantity: 2,
        color: '',
        size: '',
      );
      final result = mockData.validateOrderAvailability(order).single;

      expect(ProductAvailabilityPolicy.requiresColor(product), isFalse);
      expect(ProductAvailabilityPolicy.requiresSize(product), isFalse);
      expect(result.isAvailable, isTrue);
      expect(mockData.reserveInventoryForOrder(order), isTrue);
    },
  );

  test('product with colors only requires color but not size', () async {
    final mockData = await buildMockData();
    final baseProduct = mockData.productsForSeller('seller_1').first;
    final product = baseProduct.copyWith(
      id: 'color_only_checkout_test',
      stock: 4,
      status: ProductStatus.active,
      isActive: true,
      colors: const ['Black'],
      sizes: const [],
      variants: const [],
    );
    await mockData.addOrUpdateProduct(product);

    final missingColor = mockData
        .validateOrderAvailability(
          _inventoryOrder(
            mockData: mockData,
            product: product,
            quantity: 1,
            color: '',
            size: '',
          ),
        )
        .single;
    final selectedColor = mockData
        .validateOrderAvailability(
          _inventoryOrder(
            mockData: mockData,
            product: product,
            quantity: 1,
            color: 'Black',
            size: '',
          ),
        )
        .single;

    expect(ProductAvailabilityPolicy.requiresColor(product), isTrue);
    expect(ProductAvailabilityPolicy.requiresSize(product), isFalse);
    expect(
      missingColor.reasonCode,
      CartItemAvailabilityReason.variantSelectionRequired,
    );
    expect(selectedColor.isAvailable, isTrue);
  });

  test('product with sizes only requires size but not color', () async {
    final mockData = await buildMockData();
    final baseProduct = mockData.productsForSeller('seller_1').first;
    final product = baseProduct.copyWith(
      id: 'size_only_checkout_test',
      stock: 4,
      status: ProductStatus.active,
      isActive: true,
      colors: const [],
      sizes: const ['M'],
      variants: const [],
    );
    await mockData.addOrUpdateProduct(product);

    final missingSize = mockData
        .validateOrderAvailability(
          _inventoryOrder(
            mockData: mockData,
            product: product,
            quantity: 1,
            color: '',
            size: '',
          ),
        )
        .single;
    final selectedSize = mockData
        .validateOrderAvailability(
          _inventoryOrder(
            mockData: mockData,
            product: product,
            quantity: 1,
            color: '',
            size: 'M',
          ),
        )
        .single;

    expect(ProductAvailabilityPolicy.requiresColor(product), isFalse);
    expect(ProductAvailabilityPolicy.requiresSize(product), isTrue);
    expect(
      missingSize.reasonCode,
      CartItemAvailabilityReason.variantSelectionRequired,
    );
    expect(selectedSize.isAvailable, isTrue);
  });

  test('product with colors and sizes requires both selections', () async {
    final mockData = await buildMockData();
    final baseProduct = mockData.productsForSeller('seller_1').first;
    final product = baseProduct.copyWith(
      id: 'color_size_checkout_test',
      stock: 4,
      status: ProductStatus.active,
      isActive: true,
      colors: const ['Black'],
      sizes: const ['M'],
      variants: const [],
    );
    await mockData.addOrUpdateProduct(product);

    final missingSize = mockData
        .validateOrderAvailability(
          _inventoryOrder(
            mockData: mockData,
            product: product,
            quantity: 1,
            color: 'Black',
            size: '',
          ),
        )
        .single;
    final complete = mockData
        .validateOrderAvailability(
          _inventoryOrder(
            mockData: mockData,
            product: product,
            quantity: 1,
            color: 'Black',
            size: 'M',
          ),
        )
        .single;

    expect(ProductAvailabilityPolicy.requiresColor(product), isTrue);
    expect(ProductAvailabilityPolicy.requiresSize(product), isTrue);
    expect(
      missingSize.reasonCode,
      CartItemAvailabilityReason.variantSelectionRequired,
    );
    expect(complete.isAvailable, isTrue);
  });

  test(
    'out-of-stock product is visible but not orderable by catalog config',
    () async {
      final mockData = await buildMockData();
      final baseProduct = mockData.productsForSeller('seller_1').first;
      final product = baseProduct.copyWith(
        id: 'catalog_out_of_stock_visibility_test',
        stock: 0,
        status: ProductStatus.outOfStock,
        isActive: true,
        colors: const [],
        sizes: const [],
        variants: const [],
      );
      await mockData.addOrUpdateProduct(product);

      final availability = ProductAvailabilityPolicy.getAvailability(
        product: product,
        seller: mockData.userById(product.sellerId),
        store: mockData.storeById(product.storeId),
      );

      expect(ProductAvailabilityPolicy.shouldShowUnavailableProducts(), isTrue);
      expect(availability.isVisible, isTrue);
      expect(availability.isOrderable, isFalse);
      expect(availability.messageKey, 'outOfStock');
    },
  );

  test(
    'cash checkout creates an unpaid order, not a fake paid order',
    () async {
      final mockData = await buildMockData();
      final authController = AuthController(authService: AuthService(mockData));
      await authController.loginWithEmail('customer@stylehub.com', '123456');
      final product = mockData
          .productsForSeller('seller_1')
          .first
          .copyWith(
            id: 'cash_checkout_unpaid_test',
            stock: 3,
            status: ProductStatus.active,
            isActive: true,
            colors: const [],
            sizes: const [],
            variants: const [],
          );
      await mockData.addOrUpdateProduct(product);

      final productController =
          ProductController(
              productService: ProductService(mockData),
              mockDataService: mockData,
            )
            ..bind(authController: authController)
            ..products = mockData.allProducts;
      final cartController = CartController(cartService: CartService(mockData))
        ..bind(
          authController: authController,
          productController: productController,
        );
      expect(cartController.addToCart(product, '', '', 1).isSuccess, isTrue);

      final orderService = OrderService(mockData);
      final orderController = OrderController(orderService: orderService)
        ..bind(authController: authController);
      final checkoutController =
          CheckoutController(
            mockDataService: mockData,
            orderService: orderService,
          )..bind(
            authController: authController,
            cartController: cartController,
            orderController: orderController,
          );
      checkoutController.setAddress(mockData.demoAddresses.first);
      checkoutController.setPaymentMethod(
        const PaymentMethodModel(
          id: 'cash',
          brand: 'Cash',
          maskedNumber: 'Pay on delivery',
          token: 'cash',
        ),
      );

      final order = await checkoutController.placeOrder();

      expect(order, isNotNull);
      expect(order!.paymentStatus, 'Unpaid');
      expect(
        mockData.sellerOrders
            .where((item) => item.masterOrderId == order.id)
            .map((item) => item.paymentStatus),
        everyElement('Unpaid'),
      );
    },
  );
}

OrderModel _inventoryOrder({
  required MockDataService mockData,
  required ProductModel product,
  required int quantity,
  required String color,
  required String size,
}) {
  final customer = mockData.userById('customer_1')!;
  return OrderModel(
    id: 'order_inventory_${product.id}',
    customerId: customer.id,
    customerName: customer.name,
    items: [
      OrderItemModel(
        id: 'order_item_inventory_${product.id}',
        product: product,
        selectedColor: color,
        selectedSize: size,
        quantity: quantity,
        price: product.price,
      ),
    ],
    status: 'Processing',
    createdAt: DateTime.now(),
    total: product.price * quantity,
    address: mockData.demoAddresses.first,
    paymentMethod: mockData.paymentMethods.first,
    estimatedDelivery: DateTime.now().add(const Duration(days: 5)),
  );
}
