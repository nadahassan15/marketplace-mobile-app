import 'package:flutter/material.dart';
import '../../providers/order_provider.dart';
import '../../theme/app_theme.dart';

class OrdersHistoryScreen extends StatelessWidget {
  const OrdersHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Get dummy data from OrdersProvider
    final ordersProvider = OrdersProvider();
    final orders = ordersProvider.orders;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Orders History',
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: orders.isEmpty
          ? const Center(
              child: Text(
                'No orders yet',
                style: TextStyle(color: Colors.grey),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: orders.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final order = orders[index];
                return _OrderCard(
                  orderId: order.id,
                  date: order.date,
                  total: order.total,
                  status: order.status,
                  onView: () {
                    // TODO: Navigate to Order Details screen
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Viewing details for ${order.id}'),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final String orderId;
  final String date;
  final double total;
  final String status;
  final VoidCallback onView;

  const _OrderCard({
    required this.orderId,
    required this.date,
    required this.total,
    required this.status,
    required this.onView,
  });

  Color _statusColor() {
    switch (status) {
      case 'Delivered':
        return Colors.green;
      case 'Processing':
        return Colors.orange;
      case 'Shipped':
        return Colors.blue;
      case 'Cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade100,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ORDER ID + STATUS
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                orderId,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Text(
                status,
                style: TextStyle(
                  color: _statusColor(),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // DATE
          Text(
            'Date: $date',
            style: const TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 12),
          // TOTAL + VIEW ORDER
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total: EGP ${total.toStringAsFixed(0)}',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              GestureDetector(
                onTap: onView,
                child: const Text(
                  'View Order Details',
                  style: TextStyle(
                    color: AppTheme.primaryColor,
                    decoration: TextDecoration.underline,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
