import 'supabase_service.dart';

class ProfileService {
  final _supabase = SupabaseService();

  // Get user ID from profiles table by username or role
  Future<String?> getUserIdByUsername(String username) async {
    try {
      final response = await _supabase.client
          .from('profiles')
          .select('id')
          .eq('username', username)
          .single();
      
      return response['id'] as String?;
    } catch (e) {
      return null;
    }
  }

  // Get brand owner user IDs (users with role = 'brand_owner' or similar)
  Future<List<String>> getBrandOwnerUserIds() async {
    try {
      final response = await _supabase.client
          .from('profiles')
          .select('id')
          .eq('role', 'brand_owner'); // Adjust role name based on your schema
      
      final List<dynamic> data = response as List<dynamic>? ?? [];
      return data.map((item) => item['id'] as String).toList();
    } catch (e) {
      return [];
    }
  }

  // Get brand owner user ID for a specific brand
  // Since brandowner table doesn't have owner_id, we'll try to get it from profiles
  // This is a workaround - ideally you'd add owner_id to brandowner table
  Future<String?> getBrandOwnerUserId(String brandId) async {
    try {
      // Option 1: If profiles has a brand_id or brandid column
      final response = await _supabase.client
          .from('profiles')
          .select('id')
          .eq('role', 'brand_owner')
          .limit(1); // Get first brand owner (this is a workaround)
      
      final List<dynamic> data = response as List<dynamic>? ?? [];
      if (data.isNotEmpty) {
        return data[0]['id'] as String?;
      }
      
      // Option 2: If no brand owners found, return null
      return null;
    } catch (e) {
      return null;
    }
  }

  // Get current user's profile
  Future<Map<String, dynamic>?> getCurrentUserProfile() async {
    final user = _supabase.currentUser;
    if (user == null) return null;

    try {
      final response = await _supabase.client
          .from('profiles')
          .select()
          .eq('id', user.id)
          .single();
      
      return response as Map<String, dynamic>?;
    } catch (e) {
      return null;
    }
  }
}

