import '../models/brand.dart';
import 'supabase_service.dart';

class BrandService {
  final _supabase = SupabaseService();

  // Get all brands
  Future<List<Brand>> getAllBrands() async {
    try {
      final response = await _supabase.client
          .from('brandowner')
          .select()
          .order('created_at', ascending: false);

      final List<dynamic> data = response as List<dynamic>;
      print('✅ BrandService: Loaded ${data.length} brands');
      
      if (data.isEmpty) {
        print('⚠️ BrandService: No brands in database. Make sure:');
        print('   1. Brands table has data (check Supabase Table Editor)');
        print('   2. RLS policy allows SELECT (check Authentication → Policies)');
        print('   3. Run add_sample_data.sql to add sample brands');
      } else {
        // Debug: Print first brand's structure to see what fields exist
        print('📋 Sample brand data structure:');
        print(data.first);
      }
      
      return data.map((json) {
        try {
          return Brand.fromJson(json as Map<String, dynamic>);
        } catch (e) {
          print('❌ Error parsing brand: $e');
          print('Problematic JSON: $json');
          rethrow;
        }
      }).toList();
    } catch (e) {
      print('❌ BrandService Error: $e');
      print('Error type: ${e.runtimeType}');
      rethrow; // Re-throw to see the actual error
    }
  }

  // Get brand by ID
  Future<Brand?> getBrandById(String id) async {
    try {
      final response = await _supabase.client
          .from('brandowner')
          .select()
          .eq('brandid', id)
          .single();

      return Brand.fromJson(response);
    } catch (e) {
      return null;
    }
  }

  // Get brands owned by current user
  // NOTE: Since brandowner table doesn't have owner_id, this returns all brands
  // You may need to add owner_id column or use a different approach
  Future<List<Brand>> getUserBrands() async {
    final user = _supabase.currentUser;
    if (user == null) return [];

    try {
      // For now, return all brands since there's no owner_id column
      // TODO: Add owner_id column to brandowner table or implement brand ownership differently
      final response = await _supabase.client
          .from('brandowner')
          .select()
          .order('created_at', ascending: false);

      final List<dynamic> data = response as List<dynamic>? ?? [];
      return data.map((json) => Brand.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  // Check if user owns any brands
  Future<bool> isBrandOwner() async {
    final brands = await getUserBrands();
    return brands.isNotEmpty;
  }

  // Create brand (admin only)
  Future<Brand> createBrand({
    required String name,
    required String description,
    required String address,
    required double latitude,
    required double longitude,
    String? imageUrl,
  }) async {
    final user = _supabase.currentUser;
    if (user == null) throw Exception('User not authenticated');

    final response = await _supabase.client
        .from('brandowner')
        .insert({
          'brandname': name,
          'description': description,
          'address': address,
          'latitude': latitude,
          'longitude': longitude,
          'logo_path': imageUrl, // Using logo_path instead of image_url
          // Note: owner_id doesn't exist in schema, so we can't track ownership
        })
        .select()
        .single();

    return Brand.fromJson(response);
  }
}

