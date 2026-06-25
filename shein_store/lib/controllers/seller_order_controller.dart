import 'package:flutter/material.dart';

import '../models/order_model.dart';
import '../models/user_role.dart';
import '../services/order_service.dart';
import 'auth_controller.dart';

class SellerOrderController extends ChangeNotifier {
  SellerOrderController({required OrderService orderService})
    : _orderService = orderService;

  final OrderService _orderService;
  AuthController? _authController;

  static const List<String> statusSections = [
    'All',
    'New',
    'Processing',
    'Ready to Ship',
    'Shipped',
    'Delivered',
    'Cancelled',
    'Returned',
  ];

  String selectedStatus = 'All';
  String query = '';

  void bind({required AuthController authController}) {
    _authController = authController;
    notifyListeners();
  }

  String get sellerId => _authController?.currentUser?.id ?? '';
  bool get _isSeller => _authController?.currentRole == UserRole.seller;

  List<OrderModel> get orders {
    if (!_isSeller) return [];
    final sellerOrders = _orderService.ordersForSeller(sellerId);
    sellerOrders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return sellerOrders;
  }

  List<OrderModel> get filteredOrders {
    var items = orders;
    if (selectedStatus != 'All') {
      items = ordersByStatus(selectedStatus);
    }
    if (query.trim().isEmpty) {
      return items;
    }
    final lower = query.toLowerCase().trim();
    return items.where((order) {
      final firstItem = order.items.isEmpty ? null : order.items.first;
      final productTitle = firstItem?.product.title.toLowerCase() ?? '';
      final productSku = firstItem?.product.sku.toLowerCase() ?? '';
      return order.id.toLowerCase().contains(lower) ||
          order.customerName.toLowerCase().contains(lower) ||
          productTitle.contains(lower) ||
          productSku.contains(lower);
    }).toList();
  }

  List<OrderModel> ordersByStatus(String status) {
    return orders.where((order) => displayStatus(order) == status).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  String displayStatus(OrderModel order) {
    switch (order.status) {
      case 'Unpaid':
      case 'Pending':
        return 'New';
      case 'Processing':
        return 'Processing';
      case 'Ready to Ship':
        return 'Ready to Ship';
      case 'Shipped':
        return 'Shipped';
      case 'Delivered':
        return 'Delivered';
      case 'Cancelled':
        return 'Cancelled';
      case 'Returned':
      case 'Review':
        return 'Returned';
      default:
        return 'Processing';
    }
  }

  int countForStatus(String status) {
    if (status == 'All') {
      return orders.length;
    }
    return ordersByStatus(status).length;
  }

  String? nextStatusFor(OrderModel order) {
    switch (displayStatus(order)) {
      case 'New':
        return 'Processing';
      case 'Processing':
        return 'Ready to Ship';
      case 'Ready to Ship':
        return 'Shipped';
      case 'Shipped':
        return 'Delivered';
      default:
        return null;
    }
  }

  String? primaryActionLabel(OrderModel order) {
    switch (displayStatus(order)) {
      case 'New':
        return 'Accept Order';
      case 'Processing':
        return 'Prepare Order';
      case 'Ready to Ship':
        return 'Mark Shipped';
      case 'Shipped':
        return 'Mark Delivered';
      default:
        return null;
    }
  }

  void setStatusFilter(String value) {
    selectedStatus = value;
    notifyListeners();
  }

  void setQuery(String value) {
    query = value;
    notifyListeners();
  }

  void updateOrderStatus(String orderId, String status) {
    if (!_isSeller) return;
    final matches = _orderService
        .sellerOrdersForSeller(sellerId)
        .where((order) => order.id == orderId);
    final existing = matches.isEmpty ? null : matches.first;
    if (existing == null) return;
    final updated = existing.copyWith(
      status: status,
      shippingStatus: _shippingStatusFor(status),
      updatedAt: DateTime.now(),
    );
    _orderService.updateSellerOrder(updated);
    _orderService.recomputeMasterOrderStatus(updated.masterOrderId);
    _orderService.notifyCustomerSellerOrderStatusChanged(updated);
    notifyListeners();
  }

  String _shippingStatusFor(String status) {
    switch (status) {
      case 'Processing':
        return 'Processing';
      case 'Ready to Ship':
        return 'Ready to Ship';
      case 'Shipped':
        return 'Shipped';
      case 'Delivered':
        return 'Delivered';
      case 'Cancelled':
        return 'Cancelled';
      case 'Returned':
        return 'Returned';
      default:
        return 'Pending';
    }
  }
}
