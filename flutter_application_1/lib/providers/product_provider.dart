import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/product_model.dart';
import '../services/product_service.dart';  

final productProvider =
    StateNotifierProvider<ProductNotifier, List<Product>>((ref) {
  return ProductNotifier();
});

class ProductNotifier extends StateNotifier<List<Product>> {
  final service = ProductService();

  ProductNotifier() : super([]);

  Future<void> loadProducts(String brandId) async {
    state = await service.getBrandProducts(brandId);
  }

  Future<void> add(Product product) async {
    await service.addProduct(product);
    state = [...state, product];
  }

  Future<void> delete(String productId) async {
    await service.deleteProduct(productId);
    state = state.where((p) => p.productId != productId).toList();
  }
}
