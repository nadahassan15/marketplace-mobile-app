import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// PROVIDERS
import 'providers/checkout_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/order_provider.dart';

// SCREENS
import 'screens/customer/home_screen.dart';
import 'screens/customer/checkout_screen.dart';
import 'screens/customer/cart_screen.dart';
import 'screens/customer/ordershistory_screen.dart';
import 'providers/order_provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CheckoutProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => OrdersProvider()),
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

      //choose what to run
      // home: const HomeScreen(),
      // home: const CheckoutScreen(),
      // home: const CartScreen(),
      // home: const OrdersScreen(),
      home: const OrdersHistoryScreen(),
    );
  }
}
