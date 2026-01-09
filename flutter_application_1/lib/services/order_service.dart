import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/order_item_model.dart';

class OrderService {
  final SupabaseClient _client = Supabase.instance.client;

  Future<void> placeOrder({
    required double total,
    required String address,
    required String governorate,
    required String phone,
    required List<OrderItemModel> items,
  }) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      throw Exception('User not logged in');
    }

    await _client.rpc(
      'place_order',
      params: {
        'p_user_id': user.id,
        'p_total': total,
        'p_address': address,
        'p_governorate': governorate,
        'p_phone': phone,
        'p_items': items
            .map((e) => {
                  'product_id': e.productId,
                  'quantity': e.quantity,
                  'price': e.price,
                })
            .toList(),
      },
    );
  }

  Future<List<Map<String, dynamic>>> getMyOrders() async {
    final user = _client.auth.currentUser;
    if (user == null) return [];

    return await _client
        .from('orders')
        .select()
        .eq('user_id', user.id)
        .order('created_at', ascending: false);
  }
}
