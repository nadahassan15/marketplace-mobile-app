import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/productcustomer_provider.dart';
import '../customer/product_details_screen.dart';

Timer? _debounce;

class AppSearchDelegate extends SearchDelegate<String?> {
  @override
  String get searchFieldLabel => 'Search';

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () {
            query = '';
            context.read<ProductProvider>().searchResults.clear();
          },
        ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildBody(context);
  }

  @override
  @override
  Widget buildSuggestions(BuildContext context) {
    final provider = context.read<ProductProvider>();

    // ⏳ debounce
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      provider.searchProducts(query);
    });

    return _buildBody(context);
  }

  Widget _buildBody(BuildContext context) {
    final provider = context.watch<ProductProvider>();

    if (query.trim().isEmpty) {
      return const Center(child: Text('Start typing to search'));
    }

    if (provider.isSearching) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.searchResults.isEmpty) {
      return const Center(child: Text('No products found'));
    }

    return ListView.builder(
      itemCount: provider.searchResults.length,
      itemBuilder: (context, index) {
        final product = provider.searchResults[index];

        return ListTile(
          leading: Image.asset(
            'assets/images/${product.imagePath}',
            width: 50,
            height: 50,
            fit: BoxFit.cover,
          ),
          title: Text(product.name),
          subtitle: Text('EGP ${product.price.toInt()}'),
          onTap: () {
            close(context, null);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ProductDetailsScreen(product: product),
              ),
            );
          },
        );
      },
    );
  }
}
