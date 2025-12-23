import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../services/product_service.dart';

class ProductProvider extends ChangeNotifier {
  final ProductService _service = ProductService();
  
  List<Product> products = [];
  bool isLoading = false;
  
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
  Map<String, List<Product>> previewProducts = {};
  Future<void> loadPreviewProducts(String filter) async {
    final result = await _service.fetchProducts(filter: filter);
    previewProducts[filter] = result.take(3).toList();
    notifyListeners();
  }
}
