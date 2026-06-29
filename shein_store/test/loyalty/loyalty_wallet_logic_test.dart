import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stylehub_store/core/config/loyalty_policy.dart';
import 'package:stylehub_store/models/order_item_model.dart';
import 'package:stylehub_store/models/order_model.dart';
import 'package:stylehub_store/services/local_storage_service.dart';
import 'package:stylehub_store/services/mock_data_service.dart';

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
}
