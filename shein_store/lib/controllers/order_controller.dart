import 'package:flutter/material.dart';

import '../models/order_model.dart';
import '../models/user_role.dart';
import '../services/order_service.dart';
import 'auth_controller.dart';

class OrderController extends ChangeNotifier {
  OrderController({required OrderService orderService})
    : _orderService = orderService;

  final OrderService _orderService;
  List<OrderModel> orders = [];
  AuthController? _authController;

  void bind({required AuthController authController}) {
    _authController = authController;
    if (authController.currentRole == UserRole.customer &&
        authController.currentUser != null) {
      orders = _orderService.ordersForCustomer(authController.currentUser!.id);
    } else {
      orders = [];
    }
    notifyListeners();
  }

  void createOrder(OrderModel order) {
    _orderService.createOrder(order);
    reload();
    notifyListeners();
  }

  void reload() {
    if (_authController?.currentUser != null) {
      orders = _orderService.ordersForCustomer(
        _authController!.currentUser!.id,
      );
    } else {
      orders = [];
    }
    notifyListeners();
  }

  List<OrderModel> getOrdersByStatus(String status) {
    if (status == 'All') return orders;
    return orders.where((order) => order.status == status).toList();
  }

  void cancelOrder(String orderId) {
    _replaceStatus(orderId, 'Cancelled');
  }

  void confirmReceived(String orderId) {
    _replaceStatus(orderId, 'Delivered');
  }

  void buyAgain(String orderId) {}

  void _replaceStatus(String orderId, String status) {
    final index = orders.indexWhere((order) => order.id == orderId);
    if (index == -1) {
      return;
    }
    final updatedOrder = orders[index].copyWith(status: status);
    _orderService.updateOrder(updatedOrder);
    reload();
  }
}
