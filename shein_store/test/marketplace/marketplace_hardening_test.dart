import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:stylehub_store/core/helpers/product_orderability_helper.dart';
import 'package:stylehub_store/models/address_model.dart';
import 'package:stylehub_store/models/localized_text_model.dart';
import 'package:stylehub_store/models/order_model.dart';
import 'package:stylehub_store/models/payment_method_model.dart';
import 'package:stylehub_store/models/product_model.dart';
import 'package:stylehub_store/models/product_status.dart';
import 'package:stylehub_store/models/seller_order_model.dart';
import 'package:stylehub_store/models/store_model.dart';
import 'package:stylehub_store/models/user_model.dart';
import 'package:stylehub_store/models/user_role.dart';

void main() {
  test('orders do not default to a fake paid payment status', () {
    final now = DateTime(2026, 1, 1);
    final order = OrderModel(
      id: 'order_1',
      customerId: 'customer_1',
      customerName: 'Demo Customer',
      items: const [],
      status: 'Processing',
      createdAt: now,
      total: 42,
      address: AddressModel.fromJson(const {}),
      paymentMethod: PaymentMethodModel.fromJson(const {}),
      estimatedDelivery: now.add(const Duration(days: 5)),
    );

    expect(order.paymentStatus, 'Pending');
    expect(OrderModel.fromJson(const {}).paymentStatus, 'Pending');
    expect(SellerOrderModel.fromJson(const {}).paymentStatus, 'Pending');
  });

  test(
    'store approval and operating status block customer purchase visibility',
    () {
      final product = _activeProduct();
      final seller = _seller();

      final pendingStore = _store(
        approvalStatus: StoreApprovalStatusIds.pendingApproval,
      );
      final pendingResult = ProductOrderabilityHelper.validate(
        cartItemId: 'cart_1',
        product: product,
        seller: seller,
        store: pendingStore,
        selectedColor: '',
        selectedSize: '',
        requestedQuantity: 1,
        requireVariantSelection: false,
      );
      expect(pendingResult.isAvailable, isFalse);
      expect(
        pendingResult.reasonCode,
        CartItemAvailabilityReason.storeInactive,
      );

      final vacationStore = _store(status: StoreStatusIds.vacation);
      final vacationResult = ProductOrderabilityHelper.validate(
        cartItemId: 'cart_1',
        product: product,
        seller: seller,
        store: vacationStore,
        selectedColor: '',
        selectedSize: '',
        requestedQuantity: 1,
        requireVariantSelection: false,
      );
      expect(vacationResult.isAvailable, isFalse);
      expect(
        vacationResult.reasonCode,
        CartItemAvailabilityReason.storeVacationMode,
      );

      final activeResult = ProductOrderabilityHelper.validate(
        cartItemId: 'cart_1',
        product: product,
        seller: seller,
        store: _store(),
        selectedColor: '',
        selectedSize: '',
        requestedQuantity: 1,
        requireVariantSelection: false,
      );
      expect(activeResult.isAvailable, isTrue);
    },
  );

  test('orders screen does not contain fake payment success mutation', () {
    final source = File(
      'lib/views/screens/orders/orders_screen.dart',
    ).readAsStringSync();
    final controllerSource = File(
      'lib/controllers/order_controller.dart',
    ).readAsStringSync();

    expect(source, isNot(contains('markOrderPaid')));
    expect(controllerSource, isNot(contains('markOrderPaid')));
    expect(source, isNot(contains('Payment completed')));
  });
}

ProductModel _activeProduct() {
  return ProductModel(
    id: 'product_1',
    sellerId: 'seller_1',
    sellerName: 'Demo Seller',
    storeId: 'store_1',
    title: 'Test Product',
    categoryId: 'women',
    categoryName: 'Women',
    department: 'women',
    price: 20,
    oldPrice: 24,
    discount: 10,
    rating: 4.5,
    reviewCount: 12,
    colors: const [],
    sizes: const [],
    description: 'A product ready to buy.',
    material: 'Cotton',
    composition: '100% cotton',
    careInstructions: 'Wash cold',
    sku: 'TEST-1',
    stock: 4,
    tags: const [],
    isNew: false,
    isHot: false,
    isFlashSale: false,
    soldCount: 0,
    status: ProductStatus.active,
    isActive: true,
  );
}

StoreModel _store({String? status, String? approvalStatus}) {
  return StoreModel(
    id: 'store_1',
    sellerId: 'seller_1',
    nameText: const LocalizedTextModel(en: 'Demo Store', ar: 'Demo Store'),
    descriptionText: const LocalizedTextModel(
      en: 'A demo seller store.',
      ar: 'A demo seller store.',
    ),
    policiesText: const LocalizedTextModel(
      en: 'Returns within 7 days.',
      ar: 'Returns within 7 days.',
    ),
    city: 'Austin',
    createdAt: DateTime(2026, 1, 1),
    updatedAt: DateTime(2026, 1, 1),
    status: status,
    approvalStatus: approvalStatus,
  );
}

UserModel _seller() {
  return UserModel(
    id: 'seller_1',
    name: 'Demo Seller',
    email: 'seller@example.com',
    phone: '+15550100',
    role: UserRole.seller,
    avatar: '',
    isActive: true,
    createdAt: DateTime(2026, 1, 1),
    points: 0,
    walletBalance: 0,
    coupons: const [],
    orders: const [],
    addresses: const [],
    paymentMethods: const [],
    wishlistProductIds: const [],
    walletTransactions: const [],
    linkedStoreId: 'store_1',
    sellerStatus: 'active',
  );
}
