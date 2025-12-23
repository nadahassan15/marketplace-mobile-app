import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/customer/checkout_screen.dart';
import '../../models/product_model.dart';
import '../customer/cart_screen.dart';
final _reviewFormKey = GlobalKey<FormState>();

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

  Widget _productImage(Product product) {
    return Stack(
      children: [
        Image.asset(
          'assets/images/${product.imagePath}',
          width: double.infinity,
          height: 350,
          fit: BoxFit.cover,
        ),
      
      ],
    );
  }
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

  Widget _buttonsSection() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
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
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => const CartScreen(),
    ),
  );
},

            child: const Text('Add to Cart'),
          ),

          const SizedBox(height: 12),
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
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => const CheckoutScreen(),
    ),
  );
},

            child: const Text('Buy it Now'),
          ),
        ],
      ),
    );
  }
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
  Widget _reviewsSection() {
  return Padding(
    padding: const EdgeInsets.all(16),
    child: Form(
      key: _reviewFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Reviews',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          TextFormField(
            controller: reviewController,
            maxLines: 3,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please write a review';
              }
              if (value.length < 5) {
                return 'Review must be at least 5 characters';
              }
              return null;
            },
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
                onPressed: () {},
              ),
              const Spacer(),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFACBDAA),
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  if (_reviewFormKey.currentState!.validate()) {
                    reviewController.clear();

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Review submitted')),
                    );
                  }
                },
                child: const Text('Submit'),
              ),
            ],
          ),
        ],
      ),
    ),
  );
  }
}
