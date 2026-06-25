import 'package:flutter/material.dart';

import '../models/address_model.dart';
import '../models/coupon_model.dart';
import '../models/notification_model.dart';
import '../models/order_item_model.dart';
import '../models/order_model.dart';
import '../models/payment_method_model.dart';
import '../models/seller_order_model.dart';
import '../models/user_role.dart';
import '../services/mock_data_service.dart';
import '../services/order_service.dart';
import 'auth_controller.dart';
import 'cart_controller.dart';
import 'order_controller.dart';

class CheckoutController extends ChangeNotifier {
  CheckoutController({
    required MockDataService mockDataService,
    required OrderService orderService,
  }) : _mockDataService = mockDataService,
       _orderService = orderService;

  final MockDataService _mockDataService;
  final OrderService _orderService;
  AuthController? _authController;
  CartController? _cartController;
  OrderController? _orderController;
  AddressModel? selectedAddress;
  String shippingMethod = 'Standard';
  PaymentMethodModel? paymentMethod;
  CouponModel? coupon;
  bool pointsEnabled = false;
  bool walletEnabled = false;
  String giftCardCode = '';
  String? errorMessage;
  bool isPlacingOrder = false;

  void bind({
    required AuthController authController,
    required CartController cartController,
    required OrderController orderController,
  }) {
    _authController = authController;
    _cartController = cartController;
    _orderController = orderController;
    final addresses = authController.currentUser?.addresses ?? [];
    final paymentMethods = authController.currentUser?.paymentMethods ?? [];
    selectedAddress ??= addresses.isNotEmpty ? addresses.first : null;
    paymentMethod ??= paymentMethods.isNotEmpty ? paymentMethods.first : null;
    notifyListeners();
  }

  void setAddress(AddressModel address) {
    selectedAddress = address;
    notifyListeners();
  }

  void setShippingMethod(String method) {
    shippingMethod = method;
    notifyListeners();
  }

  void setPaymentMethod(PaymentMethodModel method) {
    paymentMethod = method;
    notifyListeners();
  }

  void applyCoupon(CouponModel value) {
    coupon = value;
    _cartController?.applyCoupon(value);
    notifyListeners();
  }

  void usePoints(bool enabled) {
    pointsEnabled = enabled;
    _cartController?.setUsePoints(enabled);
    notifyListeners();
  }

  void useWallet(bool enabled) {
    walletEnabled = enabled;
    _cartController?.setUseWallet(enabled);
    notifyListeners();
  }

  Future<OrderModel?> placeOrder() async {
    errorMessage = null;
    if (_authController?.currentRole != UserRole.customer ||
        _authController?.currentUser == null) {
      errorMessage = 'Only customers can place orders';
      notifyListeners();
      return null;
    }
    if (selectedAddress == null) {
      errorMessage = 'Please add a shipping address';
      notifyListeners();
      return null;
    }
    if (paymentMethod == null) {
      errorMessage = 'Please choose a payment method';
      notifyListeners();
      return null;
    }
    final selectedItems = _cartController?.selectedItems ?? [];
    if (selectedItems.isEmpty) {
      errorMessage = 'Please select at least one item';
      notifyListeners();
      return null;
    }
    for (final item in selectedItems) {
      final validation = _cartController!.updateQuantity(
        item.id,
        item.quantity,
      );
      if (!validation.isSuccess) {
        final title = validation.product?.title ?? item.product.title;
        final stock = validation.availableStock;
        errorMessage = stock == null
            ? 'Please review $title before checkout'
            : '$title only has $stock available';
        notifyListeners();
        return null;
      }
    }
    isPlacingOrder = true;
    notifyListeners();
    await Future<void>.delayed(const Duration(milliseconds: 900));
    final baseOrder = OrderModel(
      id: 'order_${DateTime.now().millisecondsSinceEpoch}',
      customerId: _authController!.currentUser!.id,
      customerName: _authController!.currentUser!.name,
      items: selectedItems
          .map(
            (item) => OrderItemModel(
              id: item.id,
              product: item.product,
              selectedColor: item.selectedColor,
              selectedSize: item.selectedSize,
              quantity: item.quantity,
              price: item.product.price,
            ),
          )
          .toList(),
      status: 'Processing',
      createdAt: DateTime.now(),
      total: _cartController!.calculateTotal(),
      address: selectedAddress!,
      paymentMethod: paymentMethod!,
      estimatedDelivery: DateTime.now().add(const Duration(days: 5)),
      paymentStatus: 'Paid',
      shippingStatus: 'Processing',
      platformCommission: _cartController!.calculateSubtotal() * 0.12,
    );
    final sellerOrders = _buildSellerOrders(baseOrder);
    final order = baseOrder.copyWith(
      sellerOrderIds: sellerOrders.map((item) => item.id).toList(),
      updatedAt: DateTime.now(),
    );
    _orderService.createOrder(order, sellerOrders: sellerOrders);
    _orderController?.reload();
    _createOrderNotifications(order, sellerOrders);
    _cartController?.clearPurchasedItems();
    isPlacingOrder = false;
    notifyListeners();
    return order;
  }

  List<SellerOrderModel> _buildSellerOrders(OrderModel order) {
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
      final store =
          _mockDataService.storeById(storeId) ??
          _mockDataService.storeBySellerId(sellerId);
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

  void _createOrderNotifications(
    OrderModel order,
    List<SellerOrderModel> sellerOrders,
  ) {
    final customerNotification = NotificationModel(
      id: 'notif_customer_${order.id}',
      recipientUserId: order.customerId,
      recipientRole: UserRole.customer,
      type: NotificationType.orderPlacedCustomer,
      entityType: 'order',
      entityId: order.id,
      route: '/order-details',
      data: {
        'masterOrderId': order.id,
        'orderNumber': order.id,
        'itemCount': order.items.length,
        'total': order.total,
        'currency': 'USD',
      },
      createdAt: DateTime.now(),
    );
    final sellerNotifications = sellerOrders.map((sellerOrder) {
      final store =
          _mockDataService.storeById(sellerOrder.storeId) ??
          _mockDataService.storeBySellerId(sellerOrder.sellerId);
      return NotificationModel(
        id: 'notif_seller_${sellerOrder.id}',
        recipientUserId: sellerOrder.sellerId,
        recipientRole: UserRole.seller,
        type: NotificationType.newOrderSeller,
        entityType: 'sellerOrder',
        entityId: sellerOrder.id,
        route: '/seller-order-details',
        data: {
          'sellerOrderId': sellerOrder.id,
          'masterOrderId': order.id,
          'storeId': sellerOrder.storeId,
          'storeNameEn': store?.nameText.en ?? '',
          'storeNameAr': store?.nameText.ar ?? '',
          'sellerSpecificItemCount': sellerOrder.items.fold<int>(
            0,
            (sum, item) => sum + item.quantity,
          ),
          'sellerSpecificSubtotal': sellerOrder.subtotal,
        },
        createdAt: DateTime.now(),
      );
    }).toList();
    _mockDataService.createNotifications([
      customerNotification,
      ...sellerNotifications,
    ]);
  }
}
