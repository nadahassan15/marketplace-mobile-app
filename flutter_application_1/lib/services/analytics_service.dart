import 'package:supabase_flutter/supabase_flutter.dart';

class AnalyticsService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // 1. Get System Counts (for Admin Dashboard Cards)
  Future<Map<String, int>> getSystemStats() async {
    try {
      // Run these counts in parallel for performance
      final responses = await Future.wait([
        _supabase.from('profiles').count(),      // Total Users
        _supabase.from('brandowner').count(),    // Total Brands
        _supabase.from('products').count(),      // Total Products
        _supabase.from('reviews').count(),       // Total Reviews
      ]);

      return {
        'total_users': responses[0],
        'total_brands': responses[1],
        'total_products': responses[2],
        'total_reviews': responses[3],
      };
    } catch (e) {
      // Fallback if 'count' is not enabled or fails
      print('Analytics Error: $e');
      return {
        'total_users': 0,
        'total_brands': 0,
        'total_products': 0,
        'total_reviews': 0,
      };
    }
  }

  // 2. Get Recent Activity (e.g., Last 5 users joined)
  Future<List<Map<String, dynamic>>> getRecentUsers() async {
    try {
      final response = await _supabase
          .from('profiles')
          .select()
          .order('created_at', ascending: false) // Newest first
          .limit(5);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error fetching recent users: $e');
      return [];
    }
  }
}