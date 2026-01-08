import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../services/product_service.dart';

class ProductProvider extends ChangeNotifier {
  final ProductService _service = ProductService();

  // PRODUCTS
  List<Product> products = [];
  bool isLoading = false;

  // 🔍 SEARCH
  List<Product> searchResults = [];
  bool isSearching = false;

  Future<void> loadProducts(String filter) async {
    try {
      isLoading = true;
      notifyListeners();

      products = await _service.fetchProducts(filter: filter);
    } catch (e) {
      products = [];
      debugPrint('PROVIDER ERROR: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // 🔍 SEARCH (stable – no flicker)
  Future<void> searchProducts(String query) async {
    if (query.trim().isEmpty) {
      searchResults = [];
      isSearching = false;
      notifyListeners();
      return;
    }

    try {
      // show loader only if no previous results
      if (searchResults.isEmpty) {
        isSearching = true;
        notifyListeners();
      }

      final results = await _service.searchProducts(query);
      searchResults = results;
    } catch (e) {
      debugPrint('SEARCH ERROR: $e');
    } finally {
      isSearching = false;
      notifyListeners();
    }
  }

  // PREVIEW PRODUCTS
  Map<String, List<Product>> previewProducts = {};

  Future<void> loadPreviewProducts(String filter) async {
    final result = await _service.fetchProducts(filter: filter);
    previewProducts[filter] = result.take(3).toList();
    notifyListeners();
  }
}
