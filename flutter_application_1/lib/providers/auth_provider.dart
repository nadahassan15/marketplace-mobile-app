import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/supabase_service.dart';

final authStateProvider = StreamProvider<AuthState>((ref) {
  return SupabaseService.client.auth.onAuthStateChange;
});

final sessionProvider = Provider<Session?>((ref) {
  final authState = ref.watch(authStateProvider).value;
  return authState?.session ?? Supabase.instance.client.auth.currentSession;
});

final authControllerProvider = Provider<AuthController>((ref) {
  return AuthController();
});

class AuthController {
  final _client = SupabaseService.client;

  // Helper to normalize role values to match database constraints
  String _normalizeRole(String? role) {
    if (role == null) return 'user';
    final normalized = role.toLowerCase().trim();
    // Map any variations to the correct database values
    switch (normalized) {
      case 'admin':
      case 'administrator':
        return 'admin';
      case 'brand':
      case 'brand_owner':
      case 'brandowner':
        return 'brand';
      case 'user':
      case 'customer':
      case 'client':
        return 'user';
      default:
        return 'user'; // Default to 'user' if unknown
    }
  }

  Future<void> signIn({required String email, required String password}) async {
    // Hardcoded admin account
    const adminEmail = 'admin@golokal.com';
    const adminPassword = 'admin123';
    const adminUsername = 'Admin';

    if (email == adminEmail && password == adminPassword) {
      // Try to sign in first
      try {
        await _client.auth.signInWithPassword(
          email: adminEmail,
          password: adminPassword,
        );
        // If sign in succeeds, ensure profile exists and update metadata
        final currentUser = _client.auth.currentUser;
        if (currentUser != null) {
          // Update profile with admin role
          await _client.from('profiles').upsert({
            'id': currentUser.id,
            'username': adminUsername,
            'role': _normalizeRole('admin'),
          });
          
          // Also update user metadata to ensure role is available immediately
          try {
            final updatedMetadata = Map<String, dynamic>.from(currentUser.userMetadata ?? {});
            updatedMetadata['role'] = 'admin';
            updatedMetadata['username'] = adminUsername;
            await _client.auth.updateUser(
              UserAttributes(data: updatedMetadata),
            );
          } catch (e) {
            // If updating metadata fails, that's okay - profile has the role
            print('Note: Could not update user metadata: $e');
          }
        }
      } catch (signInError) {
          // Check if it's an invalid credentials error
          final errorStr = signInError.toString().toLowerCase();
          if (errorStr.contains('invalid') || 
              errorStr.contains('credentials') ||
              errorStr.contains('invalid_credentials')) {
            
            // User doesn't exist in auth, create it
            try {
              final res = await _client.auth.signUp(
                email: adminEmail,
                password: adminPassword,
                data: {'username': adminUsername, 'role': 'admin'},
              );

              if (res.user != null) {
                // Create/update profile with admin role
                await _client.from('profiles').upsert({
                  'id': res.user!.id,
                  'username': adminUsername,
                  'role': _normalizeRole('admin'),
                });
                
                // Try to sign in after signup
                // Note: If email confirmation is enabled in Supabase, this will fail
                // Solution: Go to Supabase Dashboard > Authentication > Settings
                // and disable "Enable email confirmations" for development
                try {
                  await _client.auth.signInWithPassword(
                    email: adminEmail,
                    password: adminPassword,
                  );
                } catch (signInAfterSignupError) {
                  final signInErrorStr = signInAfterSignupError.toString().toLowerCase();
                  if (signInErrorStr.contains('email') && 
                      (signInErrorStr.contains('confirm') || signInErrorStr.contains('verify'))) {
                    throw Exception(
                      'Admin account created successfully! However, email confirmation is required. '
                      'Please:\n'
                      '1. Check your email (admin@golokal.com) for a confirmation link, OR\n'
                      '2. Go to Supabase Dashboard > Authentication > Settings and disable '
                      '"Enable email confirmations" for development, OR\n'
                      '3. Manually confirm the email in Supabase Dashboard > Authentication > Users'
                    );
                  }
                  // If it's not an email confirmation error, re-throw
                  rethrow;
                }
              }
            } catch (signUpError) {
              final signUpErrorStr = signUpError.toString().toLowerCase();
              // Check if user already exists
              if (signUpErrorStr.contains('already') || 
                  signUpErrorStr.contains('registered') ||
                  signUpErrorStr.contains('exists')) {
                // User exists but we can't sign in - might need email confirmation
                throw Exception(
                  'Admin account exists but may require email confirmation. '
                  'Please check your email or disable email confirmation in Supabase settings.'
                );
              }
              rethrow;
            }
          } else {
            // Some other error
            rethrow;
          }
        }
      } else {
      // Regular user login
      await _client.auth.signInWithPassword(email: email, password: password);
    }
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String username,
    String? role,
  }) async {
    final res = await _client.auth.signUp(
      email: email,
      password: password,
      data: {'username': username, 'role': role},
    );

    if (res.user != null) {
      await _client.from('profiles').insert({
        'id': res.user!.id,
        'username': username,
        'role': _normalizeRole(role),
      });
    }
  }

  Future<void> resetPassword(String email) async {
    await _client.auth.resetPasswordForEmail(email,
    redirectTo: 'io.supabase.flutter://reset-callback/',);
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }
}
