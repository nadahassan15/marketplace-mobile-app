import 'package:flutter/material.dart';
import '../services/supabase_service.dart';

class FavoritesProvider extends ChangeNotifier {
  final Set<String> _favoriteProductIds = {};

  Set<String> get favorites => _favoriteProductIds;

  Future<void> loadFavorites() async {
    final user = SupabaseService.client.auth.currentUser;
    if (user == null) return;

    final data = await SupabaseService.client
        .from('favorites')
        .select('product_id')
        .eq('user_id', user.id);

    _favoriteProductIds
      ..clear()
      ..addAll((data as List).map((e) => e['product_id'] as String));

    notifyListeners();
  }

  bool isFavorite(String productId) {
    return _favoriteProductIds.contains(productId);
  }

  Future<void> toggleFavorite(String productId) async {
    final user = SupabaseService.client.auth.currentUser;
    if (user == null) return;

    if (isFavorite(productId)) {
      await SupabaseService.client
          .from('favorites')
          .delete()
          .match({
            'user_id': user.id,
            'product_id': productId,
          });

      _favoriteProductIds.remove(productId);
    } else {
      await SupabaseService.client.from('favorites').insert({
        'user_id': user.id,
        'product_id': productId,
      });

      _favoriteProductIds.add(productId);
    }

    notifyListeners();
  }
}
