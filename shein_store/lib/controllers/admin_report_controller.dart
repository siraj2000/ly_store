import 'package:flutter/material.dart';

import '../services/order_service.dart';

class AdminReportController extends ChangeNotifier {
  AdminReportController({required OrderService orderService})
    : _orderService = orderService;

  final OrderService _orderService;

  double get totalRevenue =>
      _orderService.allOrders().fold(0, (sum, order) => sum + order.total);

  int get deliveredOrders => _orderService
      .allOrders()
      .where((order) => order.status == 'Delivered')
      .length;

  int get pendingRefunds => _orderService
      .allOrders()
      .where((order) => order.status == 'Returned')
      .length;
  int get complaints => _orderService
      .allOrders()
      .where((order) => order.status == 'Review')
      .length;
}
