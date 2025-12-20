import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/product_provider.dart';
import '../../widgets/cards/product_card.dart';

class ProductManagementScreen extends ConsumerStatefulWidget {
  final String brandId;

  const ProductManagementScreen({super.key, required this.brandId});

  @override
  ConsumerState createState() => _ProductManagementScreenState();
}

class _ProductManagementScreenState
    extends ConsumerState<ProductManagementScreen> {

  @override
  void initState() {
    super.initState();
    ref.read(productProvider.notifier).loadProducts(widget.brandId);
  }

  @override
  Widget build(BuildContext context) {
    final products = ref.watch(productProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('My Products')),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // open add product dialog
        },
        child: const Icon(Icons.add),
      ),
      body: ListView.builder(
        itemCount: products.length,
        itemBuilder: (_, i) {
          return ProductCard(product: products[i]);
        },
      ),
    );
  }
}
