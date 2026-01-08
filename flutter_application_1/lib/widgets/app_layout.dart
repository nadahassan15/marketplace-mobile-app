import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/customer/search_screen.dart';
import 'package:flutter_application_1/screens/customer/cart_screen.dart';
import 'package:flutter_application_1/screens/customer/favorite_screen.dart';

class AppLayout extends StatelessWidget {
  final Widget body;
  final Widget? drawer;

  const AppLayout({super.key, required this.body, this.drawer});

  void _openSearch(BuildContext context) {
    showSearch(context: context, delegate: AppSearchDelegate());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: drawer,

      //APP BAR
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'GOLOCAL',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => _openSearch(context),
          ),
        ],
      ),

      body: body,

      //BOTTOM NAV
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        onTap: (index) {
          if (index == 1) {
            _openSearch(context);
          } else if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CartScreen()),
            );
          } else if (index == 3) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const FavoriteScreen()),
            );
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: ''),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag_outlined),
            label: '',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.favorite_border), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: ''),
        ],
      ),
    );
  }
}
