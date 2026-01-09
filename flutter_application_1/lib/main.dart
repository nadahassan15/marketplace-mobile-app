import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// PROVIDERS
import 'providers/checkout_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/order_provider.dart';
import 'providers/favorite_provider.dart';
import 'providers/productcustomer_provider.dart';
import 'providers/review_provider.dart';

// SCREENS
import 'screens/customer/home_screen.dart';
import 'screens/customer/checkout_screen.dart';
import 'screens/customer/cart_screen.dart';
import 'screens/customer/ordershistory_screen.dart';
import 'screens/customer/products_screen.dart';
import 'screens/customer/product_details_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://ptnxcsugztfcdyrjhbrj.supabase.co',
    anonKey: 'sb_publishable_hek7Qv_4MBnKC9cx1LRsZA_4ttCtIz9',
  );
  // //consistent theming across the app
  // MaterialApp(
  //   theme: ThemeData(
  //     primaryColor: const Color(0xFFACBDAA),
  //     scaffoldBackgroundColor: Colors.white,
  //     appBarTheme: const AppBarTheme(
  //       backgroundColor: Colors.white,
  //       foregroundColor: Colors.black,
  //       elevation: 0,
  //     ),
  //     elevatedButtonTheme: ElevatedButtonThemeData(
  //       style: ElevatedButton.styleFrom(
  //         backgroundColor: const Color(0xFFACBDAA),
  //         foregroundColor: Colors.white,
  //         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
  //       ),
  //     ),
  //   ),
  //   home: const HomeScreen(),
  // );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CheckoutProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => OrdersProvider()),
        ChangeNotifierProvider(create: (_) => FavoritesProvider()),
        ChangeNotifierProvider(create: (_) => CheckoutProvider()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider( create: (_) => ReviewProvider(),
),
        
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Golocal',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),

      // choose what to run
      home: const HomeScreen(),
      // home: const CheckoutScreen(),
      // home: const CartScreen(),
      //  home: const ProductsScreen(),
      // home: const OrdersHistoryScreen(),
      // home:const ProductDetailsScreen();
      // home: ProductsScreen(),
    );
  }
}
