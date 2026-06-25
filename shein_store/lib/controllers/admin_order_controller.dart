import 'package:flutter/material.dart';

import '../models/order_model.dart';
import '../services/order_service.dart';

class AdminOrderController extends ChangeNotifier {
  AdminOrderController({required OrderService orderService})
    : _orderService = orderService;

  final OrderService _orderService;

  List<OrderModel> get orders => _orderService.allOrders();
}
