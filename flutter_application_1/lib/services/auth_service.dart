import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';

class AuthService {
  // --- Simulating Backend Authentication ---

  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    // Simulate network delay (API call)
    await Future.delayed(const Duration(seconds: 2));

    if (email == 'admin@example.com' && password == 'admin123') {
      // Successful Admin Login
      return UserModel(
        id: '1',
        email: email,
        role: UserRole.admin,
      );
    } else if (email == 'brand@example.com' && password == 'brand123') {
      // Successful Brand Owner Login (for Member 2)
      return UserModel(
        id: '2',
        email: email,
        role: UserRole.brand,
      );
    } else {
      // Failed Login
      throw Exception('Invalid credentials.');
    }
  }

  Future<void> logout() async {
    // Simulate API call to invalidate token
    await Future.delayed(const Duration(milliseconds: 500));
  }
}

// Provider for the AuthService so it can be accessed by the Notifier
final authServiceProvider = Provider((ref) => AuthService());