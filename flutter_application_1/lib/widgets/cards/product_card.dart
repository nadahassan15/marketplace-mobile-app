import 'package:flutter/material.dart';
import '../../models/product_model.dart';
class ProductCard extends StatelessWidget {
  final Product product;

  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Image.network(product.imagePath, width: 50),
        title: Text(product.name),
        subtitle: Text('\$${product.price}'),
        trailing: Icon(Icons.edit),
      ),
    );
  }
}
