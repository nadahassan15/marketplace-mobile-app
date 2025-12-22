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

      // special case: men / women include unisex
      if (filters.contains('men') && !categories.contains('men')) {
        if (!categories.contains('unisex')) return false;
      }

      if (filters.contains('women') && !categories.contains('women')) {
        if (!categories.contains('unisex')) return false;
      }

      // check remaining filters (top, bottom, hoodie, etc.)
      for (final f in filters) {
        if (f == 'men' || f == 'women') continue;
        if (!categories.contains(f)) return false;
      }

      return true;
    }).toList();
  }
}
