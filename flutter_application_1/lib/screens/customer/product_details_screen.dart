import 'package:flutter/material.dart';
import '../../models/product_model.dart';

class ProductDetailsScreen extends StatefulWidget {
  final Product product;

  const ProductDetailsScreen({super.key, required this.product});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  String? selectedSize;
  final TextEditingController reviewController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final product = widget.product;

    return Scaffold(
      appBar: AppBar(
        title: Text(product.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite_border),
            onPressed: () {
              // TODO: add to favorites
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _productImage(product),
            _productInfo(product),
            _sizesSection(product),
            _buttonsSection(),
            _descriptionSection(product),
            _reviewsSection(),
          ],
        ),
      ),
    );
  }

  // ---------------- IMAGE + ADD ----------------
  Widget _productImage(Product product) {
    return Stack(
      children: [
        Image.asset(
          'assets/images/${product.imagePath}',
          width: double.infinity,
          height: 350,
          fit: BoxFit.cover,
        ),
        // Positioned(
        //   bottom: 16,
        //   right: 16,
        //   child: Container(
        //     decoration: BoxDecoration(
        //       shape: BoxShape.circle,
        //       color: Colors.black.withAlpha(130),
        //     ),
        //     child: IconButton(
        //       icon: const Icon(Icons.add, color: Colors.white),
        //       onPressed: () {
        //         // TODO: add to cart
        //       },
        //     ),
        //   ),
        // ),
      ],
    );
  }

  // ---------------- NAME + PRICE ----------------
  Widget _productInfo(Product product) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            product.name,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'EGP ${product.price.toInt()}',
            style: const TextStyle(fontSize: 18),
          ),
        ],
      ),
    );
  }

  // ---------------- SIZES ----------------
  Widget _sizesSection(Product product) {

  if (product.sizes.isEmpty) {
    return const SizedBox();
  }

  final sizes = product.sizes;

  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Size',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: sizes.map((size) {
            final isSelected = selectedSize == size;
            return ChoiceChip(
              label: Text(size),
              selected: isSelected,
              onSelected: (_) {
                setState(() {
                  selectedSize = size;
                });
              },
            );
          }).toList(),
        ),
      ],
    ),
  );
}

  // ---------------- BUTTONS ----------------
  Widget _buttonsSection() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // ADD TO CART
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFACBDAA),
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {
              // TODO: add to cart
            },
            child: const Text('Add to Cart'),
          ),

          const SizedBox(height: 12),

          // BUY IT NOW
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {
              // TODO: buy now
            },
            child: const Text('Buy it Now'),
          ),
        ],
      ),
    );
  }

  // ---------------- DESCRIPTION ----------------
  Widget _descriptionSection(Product product) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Description',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            product.description ?? 'No description available',
            style: const TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  // ---------------- REVIEWS ----------------
  Widget _reviewsSection() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Reviews',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: reviewController,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: 'Write your review...',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              TextButton.icon(
                icon: const Icon(Icons.camera_alt),
                label: const Text('Upload Photo'),
                onPressed: () {
                  // TODO: pick image
                },
                style: TextButton.styleFrom(
                  foregroundColor: const Color.fromARGB(255, 0, 0, 0),
                ),
              ),
              const Spacer(),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFACBDAA),
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  reviewController.clear();
                },
                child: const Text('Submit'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
