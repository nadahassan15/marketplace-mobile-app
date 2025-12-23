// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';


// import 'services/user_service.dart';
// import 'theme/app_theme.dart';



// import 'package:provider/provider.dart';


// // PROVIDERS
// import 'providers/checkout_provider.dart';
// import 'providers/cart_provider.dart';
// import 'providers/order_provider.dart';
// import 'providers/favorite_provider.dart';

// import 'providers/product_list_provider.dart';
// import 'providers/product_view_provider.dart';



// import 'providers/auth_provider.dart';


// // SCREENS
// import 'screens/customer/home_screen.dart';
// import 'screens/customer/checkout_screen.dart';
// import 'screens/customer/cart_screen.dart';
// import 'screens/customer/ordershistory_screen.dart';
// import 'screens/customer/products_screen.dart';
// import 'screens/customer/product_details_screen.dart';
// import 'screens/brand/brand_home_screen.dart';
// import 'screens/auth/login_screen.dart';
// import 'screens/admin/admin_dashboard_screen.dart';



// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();


// Future<void> main() async {
//   WidgetsFlutterBinding.ensureInitialized();

//   await Supabase.initialize(
//     url: 'https://ptnxcsugztfcdyrjhbrj.supabase.co',

// //     anonKey:
// //         'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InB0bnhjc3VnenRmY2R5cmpoYnJqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjU4OTc5MDksImV4cCI6MjA4MTQ3MzkwOX0.smtWt94cPbkZFwQK3v37igoA9KANwZC2SqUXFgu7mfQ',
// //   );
//     anonKey: 'sb_publishable_hek7Qv_4MBnKC9cx1LRsZA_4ttCtIz9',
//   );
//   runApp( ProviderScope(child: MyApp()));
//   //consistent theming across the app
//   MaterialApp(
    
//     theme: ThemeData(

//       primaryColor: const Color(0xFFACBDAA),
//       scaffoldBackgroundColor: Colors.white,
//       appBarTheme: const AppBarTheme(
//         backgroundColor: Colors.white,
//         foregroundColor: Colors.black,
//         elevation: 0,
//       ),
//       elevatedButtonTheme: ElevatedButtonThemeData(
//         style: ElevatedButton.styleFrom(
//           backgroundColor: const Color(0xFFACBDAA),
//           foregroundColor: Colors.white,
//           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//         ),
//       ),
//     ),
//     home: const HomeScreen(),
//   );

//   // runApp(
//     // MultiProvider(
//     //   providers: [
//     //     ChangeNotifierProvider(create: (_) => CheckoutProvider()),
//     //     ChangeNotifierProvider(create: (_) => CartProvider()),
//     //     ChangeNotifierProvider(create: (_) => OrdersProvider()),
//     //     ChangeNotifierProvider(create: (_) => FavoritesProvider()),
//     //     ChangeNotifierProvider(create: (_) => CheckoutProvider()),
//     //     ChangeNotifierProvider(create: (_) => CartProvider()),
//     //     ChangeNotifierProvider(create: (_) => ProductProvider()),
//     //   ],
//     //   child: const MyApp(),
//   //   ),
//   // );

// }

// class MyApp extends ConsumerWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final authState = ref.watch(authStateProvider);

//     return MaterialApp(

//       debugShowCheckedModeBanner: false,
//       title: 'Golocal',
//       theme: AppTheme.lightTheme,
//       home: authState.when(
//         data: (data) {
//           // If a session exists, check role and route accordingly
//           if (data.session != null) {
//             return RouteBasedOnRole();
//           }
//           // Otherwise, go to Login
//           return const LoginScreen();
//         },
//         loading: () {
//           // QUICK CHECK: Prevent the "need to refresh" issue
//           final currentSession = Supabase.instance.client.auth.currentSession;
//           if (currentSession != null) {
//             return RouteBasedOnRole();
//           }

//           return const Scaffold(
//             body: Center(child: CircularProgressIndicator()),
//           );
//         },
//         error: (e, __) => const LoginScreen(),
//       ),
//     );
//   }
// }

// // Widget that routes based on user role from profiles table
// class RouteBasedOnRole extends StatefulWidget {
//   const RouteBasedOnRole({super.key});
//   @override
//   State<RouteBasedOnRole> createState() => _RouteBasedOnRoleState();
// }


// class _RouteBasedOnRoleState extends State<RouteBasedOnRole> {
//   final UserService _userService = UserService();
//   Widget? _routeWidget;
//   bool _isLoading = true;
//   final String title;


//   @override
//   void initState() {
//     super.initState();
//     _determineRoute();
//   }


//   Future<void> _determineRoute() async {
//     try {
//       final user = Supabase.instance.client.auth.currentUser;
//       if (user == null) {
//         setState(() {
//           _routeWidget = const LoginScreen();
//           _isLoading = false;
//         });
//         return;
//       }

//       // Check if it's the admin email (hardcoded admin account)
//       const adminEmail = 'admin@golokal.com';
//       if (user.email?.toLowerCase() == adminEmail.toLowerCase()) {
//         setState(() {
//           _routeWidget = const AdminDashboardScreen();
//           _isLoading = false;
//         });
//         return;
//       }

//       // First check userMetadata (faster)
//       String? role = user.userMetadata?['role']?.toString().toLowerCase();


//       // If not in metadata, check profiles table
//       if (role == null || role.isEmpty) {
//         try {
//           role = await _userService.getUserRoleFromProfile(user.id);
//           role = role?.toLowerCase();
//         } catch (e) {
//           // If fetching from profiles fails, continue with null role
//           print('Error fetching role from profiles: $e');
//         }
//       }

//       setState(() {
//         // Check if role is admin (case-insensitive)
//         if (role != null && role.toLowerCase() == 'admin') {
//           _routeWidget = const AdminDashboardScreen();
//         } else if (role != null && role.toLowerCase() == 'customer'){
//           _routeWidget = const HomePage();
//         } else {
//           _routeWidget = const BrandHomeScreen(
//              brandId: '67be9637-1561-40ae-8ce4-3bc561ac4504',
//           ),
//         }
//         _isLoading = false;
//       });
//     } catch (e) {
//       // On error, default to home page
//       print('Error determining route: $e');
//       setState(() {
//         _routeWidget = const HomePage();
//         _isLoading = false;
//       });
//     }


//   @override
//   Widget build(BuildContext context) {

//     if (_isLoading) {
//       return const Scaffold(
//         body: Center(child: CircularProgressIndicator()),
//       );
//     }
//     return _routeWidget ?? const HomePage();

//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Theme.of(context).colorScheme.inversePrimary,
//         title: Text(widget.title),
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: <Widget>[
//             const Text('You have pushed the button this many times:'),
//             Text(
//               '$_counter',
//               style: Theme.of(context).textTheme.headlineMedium,
//             ),
//           ],
//         ),
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: _incrementCounter,
//         tooltip: 'Increment',
//         child: const Icon(Icons.add),
//       ),
//     );
//   }
//       debugShowCheckedModeBanner: false,
//       title: 'Golocal',
//       theme: ThemeData(
//         colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
//       ),

//       // choose what to run
//       home: const HomeScreen(),
//       // home: const CheckoutScreen(),
//       // home: const CartScreen(),
//       //  home: const ProductsScreen(),
//       // home: const OrdersHistoryScreen(),
//       // home:const ProductDetailsScreen();
//       // home: ProductsScreen(),
//       //  home: const BrandHomeScreen(
//       //brandId: '67be9637-1561-40ae-8ce4-3bc561ac4504',
//     //),
//     );

//   }
// };
// }
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'services/user_service.dart';
import 'theme/app_theme.dart';

// PROVIDERS
import 'providers/auth_provider.dart';

// SCREENS
import 'screens/customer/home_screen.dart';
import 'screens/brand/brand_home_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/admin/admin_dashboard_screen.dart';

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
      title: 'Golocal',
      theme: AppTheme.lightTheme,
      home: authState.when(
        data: (data) {
          if (data.session != null) {
            return const RouteBasedOnRole();
          }
          return const LoginScreen();
        },
        loading: () {
          final currentSession = Supabase.instance.client.auth.currentSession;
          if (currentSession != null) {
            return const RouteBasedOnRole();
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
          print('Error fetching role from profiles: $e');
        }
      }

      setState(() {
        if (role != null && role.toLowerCase() == 'admin') {
          _routeWidget = const AdminDashboardScreen();
        } else if (role != null && role.toLowerCase() == 'customer') {
          _routeWidget = const HomeScreen();
        } else {
          _routeWidget = const BrandHomeScreen(
            brandId: '67be9637-1561-40ae-8ce4-3bc561ac4504',
          );
        }
        _isLoading = false;
      });
    } catch (e) {
      print('Error determining route: $e');
      setState(() {
        _routeWidget = const HomeScreen();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return _routeWidget ?? const HomeScreen();
  }
}
