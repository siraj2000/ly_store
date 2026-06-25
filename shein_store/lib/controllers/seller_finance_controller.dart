import 'package:flutter/material.dart';

import '../models/seller_order_model.dart';
import '../models/user_role.dart';
import '../services/order_service.dart';
import 'auth_controller.dart';

class SellerFinanceController extends ChangeNotifier {
  SellerFinanceController({required OrderService orderService})
    : _orderService = orderService;

  final OrderService _orderService;
  AuthController? _authController;

  void bind({required AuthController authController}) {
    _authController = authController;
    notifyListeners();
  }

  String get sellerId => _authController?.currentUser?.id ?? '';
  bool get _isSeller => _authController?.currentRole == UserRole.seller;

  List<SellerOrderModel> get sellerOrders {
    if (!_isSeller) return [];
    final orders = _orderService.sellerOrdersForSeller(sellerId);
    orders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return orders;
  }

  double get totalEarnings =>
      sellerOrders.fold(0, (sum, order) => sum + _earningFor(order));

  double get pendingBalance => sellerOrders
      .where((order) => !_isAvailable(order))
      .fold(0, (sum, order) => sum + _earningFor(order));

  double get availableBalance => sellerOrders
      .where(_isAvailable)
      .fold(0, (sum, order) => sum + _earningFor(order));

  double get totalCommission =>
      sellerOrders.fold(0, (sum, order) => sum + order.platformCommission);

  int get deliveredOrdersCount =>
      sellerOrders.where((order) => order.status == 'Delivered').length;

  int get pendingOrdersCount =>
      sellerOrders.where((order) => order.status != 'Delivered').length;

  int get paidOrdersCount =>
      sellerOrders.where((order) => order.paymentStatus == 'Paid').length;

  double get averageOrderNet =>
      sellerOrders.isEmpty ? 0 : totalEarnings / sellerOrders.length;

  double get thisWeekNet {
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));
    return sellerOrders
        .where((order) => order.createdAt.isAfter(weekAgo))
        .fold(0, (sum, order) => sum + _earningFor(order));
  }

  double get thisMonthNet {
    final now = DateTime.now();
    return sellerOrders
        .where(
          (order) =>
              order.createdAt.year == now.year &&
              order.createdAt.month == now.month,
        )
        .fold(0, (sum, order) => sum + _earningFor(order));
  }

  double get payoutReadiness =>
      totalEarnings <= 0 ? 0 : (availableBalance / totalEarnings).clamp(0, 1);

  bool get payoutBackendConnected => false;

  bool _isAvailable(SellerOrderModel order) {
    return order.status == 'Delivered' &&
        order.paymentStatus == 'Paid' &&
        !_isRefundedOrReturned(order);
  }

  bool _isRefundedOrReturned(SellerOrderModel order) {
    final status = order.status.toLowerCase();
    final payment = order.paymentStatus.toLowerCase();
    return status.contains('return') ||
        status.contains('refund') ||
        payment.contains('refund');
  }

  double _earningFor(SellerOrderModel order) {
    if (_isRefundedOrReturned(order)) {
      return 0;
    }
    return order.sellerNetAmount;
  }
}
