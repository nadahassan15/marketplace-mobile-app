import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FavoriteService {
  final SupabaseClient _client = Supabase.instance.client;

  /// Get all favorite product IDs for a user
  Future<List<String>> getFavoriteProductIds(String userId) async {
    final response = await _client
        .from('favorites')
        .select('product_id')
        .eq('user_id', userId);

    return (response as List)
        .map((e) => e['product_id'].toString())
        .toList();
  }

  /// Add product to favorites
  Future<void> addFavorite({
    required String userId,
    required String productId,
  }) async {
    await _client.from('favorites').insert({
      'user_id': userId,
      'product_id': productId,
    });
  }

  /// Remove product from favorites
  Future<void> removeFavorite({
    required String userId,
    required String productId,
  }) async {
    await _client
        .from('favorites')
        .delete()
        .match({
          'user_id': userId,
          'product_id': productId,
        });
  }
}
