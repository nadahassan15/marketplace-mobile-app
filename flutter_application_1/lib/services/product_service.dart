import 'package:flutter_application_1/services/supabase_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/product_model.dart';

class ProductService {
  final SupabaseClient supabase = Supabase.instance.client;

  Future<List<Product>> fetchProducts({required String filter}) async {
    final response = await supabase.from('products').select();

    final products = (response as List)
        .map((e) => Product.fromJson(e))
        .toList();

    final filters = filter
        .toLowerCase()
        .split(',')
        .map((e) => e.trim())
        .toList();

    return products.where((product) {
      final categories = product.category
          .toLowerCase()
          .split(',')
          .map((e) => e.trim())
          .toList();

      // men / women include unisex
      if (filters.contains('men') && !categories.contains('men')) {
        if (!categories.contains('unisex')) return false;
      }

      if (filters.contains('women') && !categories.contains('women')) {
        if (!categories.contains('unisex')) return false;
      }

      // check remaining filters 
      for (final f in filters) {
        if (f == 'men' || f == 'women') continue;
        if (!categories.contains(f)) return false;
      }

      return true;
    }).toList();
  }
  Future<List<Product>> searchProducts(String query) async {
  final response = await SupabaseService.client
      .from('products')
      .select()
      .ilike('name', '%$query%');

  return (response as List)
      .map((e) => Product.fromJson(e))
      .toList();
}

}
