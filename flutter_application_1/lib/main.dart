import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/auth/login_screen.dart';
import 'screens/customer/home_screen.dart';
import 'screens/admin/admin_dashboard_screen.dart';
import 'providers/auth_provider.dart';
import 'services/user_service.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://ptnxcsugztfcdyrjhbrj.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InB0bnhjc3VnenRmY2R5cmpoYnJqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjU4OTc5MDksImV4cCI6MjA4MTQ3MzkwOX0.smtWt94cPbkZFwQK3v37igoA9KANwZC2SqUXFgu7mfQ',
  );

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Golokal',
      theme: AppTheme.lightTheme,
      home: authState.when(
        data: (data) {
          // If a session exists, check role and route accordingly
          if (data.session != null) {
            return RouteBasedOnRole();
          }
          // Otherwise, go to Login
          return const LoginScreen();
        },
        loading: () {
          // QUICK CHECK: Prevent the "need to refresh" issue
          final currentSession = Supabase.instance.client.auth.currentSession;
          if (currentSession != null) {
            return RouteBasedOnRole();
          }

          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        },
        error: (e, __) => const LoginScreen(),
      ),
    );
  }
}

// Widget that routes based on user role from profiles table
class RouteBasedOnRole extends StatefulWidget {
  const RouteBasedOnRole({super.key});

  @override
  State<RouteBasedOnRole> createState() => _RouteBasedOnRoleState();
}

class _RouteBasedOnRoleState extends State<RouteBasedOnRole> {
  final UserService _userService = UserService();
  Widget? _routeWidget;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _determineRoute();
  }

  Future<void> _determineRoute() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        setState(() {
          _routeWidget = const LoginScreen();
          _isLoading = false;
        });
        return;
      }

      // Check if it's the admin email (hardcoded admin account)
      const adminEmail = 'admin@golokal.com';
      if (user.email?.toLowerCase() == adminEmail.toLowerCase()) {
        setState(() {
          _routeWidget = const AdminDashboardScreen();
          _isLoading = false;
        });
        return;
      }

      // First check userMetadata (faster)
      String? role = user.userMetadata?['role']?.toString().toLowerCase();

      // If not in metadata, check profiles table
      if (role == null || role.isEmpty) {
        try {
          role = await _userService.getUserRoleFromProfile(user.id);
          role = role?.toLowerCase();
        } catch (e) {
          // If fetching from profiles fails, continue with null role
          print('Error fetching role from profiles: $e');
        }
      }

      setState(() {
        // Check if role is admin (case-insensitive)
        if (role != null && role.toLowerCase() == 'admin') {
          _routeWidget = const AdminDashboardScreen();
        } else {
          _routeWidget = const HomePage();
        }
        _isLoading = false;
      });
    } catch (e) {
      // On error, default to home page
      print('Error determining route: $e');
      setState(() {
        _routeWidget = const HomePage();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return _routeWidget ?? const HomePage();
  }
}
