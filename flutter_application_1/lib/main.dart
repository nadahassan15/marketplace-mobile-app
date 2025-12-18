import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/checkout_provider.dart';
import 'screens/customer/home_screen.dart';
import 'screens/customer/checkout_screen.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => CheckoutProvider(),
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
      home: const HomeScreen(),
      // home: const CheckoutScreen(),
    );
  }
}
