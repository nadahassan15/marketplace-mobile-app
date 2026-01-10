import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_service.dart';

class UserService {
  final _client = SupabaseService.client;

  // Helper to normalize role values to match database constraints
  // Helper to normalize role values to match database constraints
  String _normalizeRole(String? role) {
    if (role == null) return 'customer'; // Default to customer
    final normalized = role.toLowerCase().trim();
    
    // Map variations to the CORRECT database values
    switch (normalized) {
      // 1. ADMIN
      case 'admin':
      case 'administrator':
        return 'admin';
        
      // 2. BRAND OWNER (Must return 'brand_owner')
      case 'brand':
      case 'brand_owner':
      case 'brandowner':
        return 'brand_owner'; // <--- FIXED
        
      // 3. CUSTOMER (Must return 'customer')
      case 'user':
      case 'customer':
      case 'client':
        return 'customer';    // <--- FIXED
        
      default:
        return 'customer';
    }
  }

  // Get all users from profiles table
  Future<List<Map<String, dynamic>>> getAllUsers() async {
    final response = await _client.from('profiles').select();
    final users = List<Map<String, dynamic>>.from(response);

    // Enrich with email from auth if available
    for (var user in users) {
      try {
        // Try to get email from auth.users (this might require RLS policies)
        // For now, we'll use the profile data and add email if available in metadata
        final userId = user['id'] as String?;
        if (userId != null) {
          // Email might be in user metadata or we can try to get it from auth
          // Note: This might require admin access or proper RLS policies
        }
      } catch (e) {
        // If we can't get email, continue without it
      }
    }

    return users;
  }

  // Get user by ID
  Future<Map<String, dynamic>?> getUserById(String userId) async {
    final response = await _client
        .from('profiles')
        .select()
        .eq('id', userId)
        .single();
    return response;
  }

  // Update user role
  Future<void> updateUserRole(String userId, String role) async {
    try {
      // Normalize role before updating
      final normalizedRole = _normalizeRole(role);
      print('Updating user role: userId=$userId, role=$normalizedRole');

      // Update in profiles table
      final response = await _client
          .from('profiles')
          .update({'role': normalizedRole})
          .eq('id', userId)
          .select();

      print('Update response: $response');

      // Try to update in auth metadata if it's the current user
      final currentUser = _client.auth.currentUser;
      if (currentUser != null && currentUser.id == userId) {
        try {
          final updatedMetadata = Map<String, dynamic>.from(
            currentUser.userMetadata ?? {},
          );
          updatedMetadata['role'] = normalizedRole;
          await _client.auth.updateUser(UserAttributes(data: updatedMetadata));
        } catch (e) {
          print('Note: Could not update auth metadata: $e');
          // If updating auth metadata fails, that's okay - profile update is the main thing
        }
      }
    } catch (e) {
      print('Error in updateUserRole: $e');
      rethrow; // Re-throw to show error to user
    }
  }

  // Update user information
  Future<void> updateUser({
    required String userId,
    String? username,
    String? role,
  }) async {
    try {
      final updateData = <String, dynamic>{};
      if (username != null && username.isNotEmpty) {
        updateData['username'] = username;
      }
      if (role != null) {
        updateData['role'] = _normalizeRole(role);
      }

      if (updateData.isEmpty) {
        throw Exception('No data to update');
      }

      print('Updating user: userId=$userId, data=$updateData');

      final response = await _client
          .from('profiles')
          .update(updateData)
          .eq('id', userId)
          .select();

      print('Update response: $response');
    } catch (e) {
      print('Error in updateUser: $e');
      rethrow; // Re-throw to show error to user
    }
  }

  // Delete user (from profiles table and auth)
  Future<void> deleteUser(String userId) async {
    try {
      print('Deleting user: userId=$userId');

      // Delete from profiles
      final response = await _client
          .from('profiles')
          .delete()
          .eq('id', userId)
          .select();

      print('Delete response: $response');

      // Note: Deleting from auth.users requires admin privileges
      // This might need to be done through Supabase admin API
    } catch (e) {
      print('Error in deleteUser: $e');
      rethrow; // Re-throw to show error to user
    }
  }

  // Note: Creating users directly requires admin API access
  // For now, users should be created through the signup flow
  // Admin can then update their roles

  // Get current user role
  String? getCurrentUserRole() {
    final user = _client.auth.currentUser;
    if (user == null) return null;

    // First check user metadata
    final roleFromMetadata = user.userMetadata?['role'];
    if (roleFromMetadata != null) return roleFromMetadata;

    return null;
  }

  // Get user role from profiles table
  Future<String?> getUserRoleFromProfile(String userId) async {
    try {
      final response = await _client
          .from('profiles')
          .select('role')
          .eq('id', userId)
          .maybeSingle();

      if (response == null) return null;

      // Handle different possible return types (string, enum, etc.)
      final roleValue = response['role'];
      if (roleValue == null) return null;

      // Convert to string, handling enum types
      if (roleValue is String) {
        return roleValue;
      } else {
        // If it's an enum or other type, convert to string
        return roleValue.toString();
      }
    } catch (e) {
      print('Error getting user role from profile: $e');
      return null;
    }
  }
}
