import 'package:flutter/material.dart';
import '../../models/product_model.dart';

class ProductCard extends StatelessWidget {
  final Product product;

  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!, width: 1),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: Container(
          width: 60,
height: 60,
decoration: BoxDecoration(
color: Colors.grey[50],
borderRadius: BorderRadius.circular(12),
),
child: ClipRRect(
borderRadius: BorderRadius.circular(12),
child: product.imagePath != null && product.imagePath!.isNotEmpty
? Image.asset(
'assets/images/${product.imagePath}',
fit: BoxFit.cover,
errorBuilder: (_, __, ___) => Icon(
Icons.image_outlined,
color: Colors.grey[300],
size: 30,
),
)
: Icon(
Icons.image_outlined,
color: Colors.grey[300],
size: 30,
),
),
),
title: Text(
product.name,
style: const TextStyle(
color: Colors.black,
fontWeight: FontWeight.w600,
fontSize: 15,
),
maxLines: 1,
overflow: TextOverflow.ellipsis,
),
subtitle: Padding(
padding: const EdgeInsets.only(top: 4),
child: Text(
'${product.price.toStringAsFixed(2)}',
style: const TextStyle(
color: Colors.black,
fontWeight: FontWeight.bold,
fontSize: 15,
),
),
),
trailing: Icon(
Icons.arrow_forward_ios,
color: Colors.grey[400],
size: 16,
),
),
);
}
}