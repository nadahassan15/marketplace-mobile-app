import 'package:flutter/material.dart';
import '../models/order_model.dart';
import '../services/supabase_service.dart';
import '../services/order_service.dart';


class OrdersProvider extends ChangeNotifier {
  final _service = OrderService();
  List<OrderModel> _orders = [];
  bool isLoading = false;

  List<OrderModel> get orders => _orders;

  Future<void> loadOrders() async {
    isLoading = true;
    notifyListeners();

    final data = await _service.getMyOrders();
    _orders = data.map((e) => OrderModel.fromMap(e)).toList();

    isLoading = false;
    notifyListeners();
  }
}

