import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/favorite_service.dart';

class FavoritesProvider extends ChangeNotifier {
  final Set<String> _favoriteProductIds = {};
  final FavoriteService _favoriteService = FavoriteService();

  Set<String> get favorites => _favoriteProductIds;

  Future<void> loadFavorites() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    final ids = await _favoriteService.getFavoriteProductIds(user.id);

    _favoriteProductIds
      ..clear()
      ..addAll(ids);

    notifyListeners();
  }

  bool isFavorite(String productId) {
    return _favoriteProductIds.contains(productId);
  }

  Future<void> toggleFavorite(String productId) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    if (_favoriteProductIds.contains(productId)) {
      await _favoriteService.removeFavorite(
        userId: user.id,
        productId: productId,
      );
      _favoriteProductIds.remove(productId);
    } else {
      await _favoriteService.addFavorite(
        userId: user.id,
        productId: productId,
      );
      _favoriteProductIds.add(productId);
    }

    notifyListeners();
  }
}
