import 'package:flutter/material.dart';
import '../models/order_model.dart';

class OrdersProvider extends ChangeNotifier {
  // DUMMY DATA
  final List<OrderModel> _orders = [
    OrderModel(
      id: 'ORD-005',
      date: '2025-10-06',
      total: 2295,
      status: 'Processing',
    ),
    OrderModel(
      id: 'ORD-004',
      date: '2025-05-15',
      total: 1450,
      status: 'Shipped',
    ),
    OrderModel(
      id: 'ORD-003',
      date: '2025-04-22',
      total: 3200,
      status: 'Delivered',
    ),
    OrderModel(
      id: 'ORD-002',
      date: '2025-02-28',
      total: 980,
      status: 'Cancelled',
    ),
    OrderModel(
      id: 'ORD-001',
      date: '2025-01-01',
      total: 1875,
      status: 'Delivered',
    ),
  ];

  List<OrderModel> get orders => _orders;
}
