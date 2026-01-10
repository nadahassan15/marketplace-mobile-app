import 'package:supabase_flutter/supabase_flutter.dart';

class SearchService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // 1. Search Products by Name
  Future<List<Map<String, dynamic>>> searchProducts(String query) async {
    try {
      final response = await _supabase
          .from('products')
          .select()
          .ilike('name', '%$query%'); // 'ilike' is case-insensitive search

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Error searching products: $e');
    }
  }

  // 2. Search Brands by Name (Table: brandowner)
  Future<List<Map<String, dynamic>>> searchBrands(String query) async {
    try {
      final response = await _supabase
          .from('brandowner') 
          .select()
          .ilike('brandname', '%$query%'); // UPDATED: uses 'brandname'

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Error searching brands: $e');
    }
  }

  // 3. Filter Products (Price Range, Category)
  Future<List<Map<String, dynamic>>> filterProducts({
    double? minPrice,
    double? maxPrice,
    String? category,
  }) async {
    try {
      var query = _supabase.from('products').select();

      if (minPrice != null) {
        query = query.gte('price', minPrice); // Greater than or equal
      }
      if (maxPrice != null) {
        query = query.lte('price', maxPrice); // Less than or equal
      }
      if (category != null && category.isNotEmpty) {
        query = query.eq('category', category);
      }

      final response = await query;
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Error filtering products: $e');
    }
  }
}