import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../services/user_service.dart';
import 'login_screen.dart';
import '../admin/admin_dashboard_screen.dart';
import '../customer/home_screen.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  final UserService _userService = UserService();
  Widget? _routeWidget;
  bool _isLoading = true;
  late final StreamSubscription<AuthState> _authSubscription;

  @override
  void initState() {
    super.initState();
    _determineRoute(); // Check immediately on start

    // LISTEN for login/logout events automatically
    _authSubscription = Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      final AuthChangeEvent event = data.event;
      if (event == AuthChangeEvent.signedIn || event == AuthChangeEvent.signedOut) {
        // If the user logs in or out, re-check where they should go
        _determineRoute();
      }
    });
  }

  @override
  void dispose() {
    _authSubscription.cancel(); // Stop listening when screen closes
    super.dispose();
  }

  Future<void> _determineRoute() async {
    // Reset state to loading momentarily to prevent flickering
    if (mounted) setState(() => _isLoading = true);

    try {
      final user = Supabase.instance.client.auth.currentUser;
      
      // 1. If not logged in -> Login Screen
      if (user == null) {
        if (mounted) {
          setState(() {
            _routeWidget = const LoginScreen();
            _isLoading = false;
          });
        }
        return;
      }

      // 2. Check for Hardcoded Admin Email
      const adminEmail = 'admin@golokal.com';
      if (user.email?.toLowerCase() == adminEmail.toLowerCase()) {
        if (mounted) {
          setState(() {
            _routeWidget = const AdminHomeScreen();
            _isLoading = false;
          });
        }
        return;
      }

      // 3. Check Role (Metadata first, then Database)
      String? role = user.userMetadata?['role']?.toString().toLowerCase();

      if (role == null || role.isEmpty) {
        try {
          role = await _userService.getUserRoleFromProfile(user.id);
          role = role?.toLowerCase();
        } catch (e) {
          debugPrint('Error fetching role: $e');
        }
      }

      // 4. Route based on Role
      if (mounted) {
        setState(() {
          if (role == 'admin') {
            _routeWidget = const AdminHomeScreen();
          } else {
            // Both 'brand' and 'customer' go to HomePage for now
            _routeWidget = const HomePage(); 
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error determining route: $e');
      if (mounted) {
        setState(() {
          _routeWidget = const LoginScreen(); // Default to login on error
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return _routeWidget ?? const LoginScreen();
  }
}