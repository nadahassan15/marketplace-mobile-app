import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_1/screens/customer/checkout_screen.dart';
import '../../models/product_model.dart';
import '../customer/cart_screen.dart';
import '../../providers/favorite_provider.dart';
import '../../services/supabase_service.dart';

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
  void initState() {
    super.initState();
    // Load favorites when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FavoritesProvider>().loadFavorites();
    });
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;

    return Scaffold(
      appBar: AppBar(
        title: Text(product.name),
        actions: [
          Consumer<FavoritesProvider>(
            builder: (context, favoriteProvider, _) {
              final isFavorite = favoriteProvider.isFavorite(product.id);
              return IconButton(
                icon: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: isFavorite ? Colors.red : null,
                ),
                onPressed: () async {
                  // Check if user is logged in
                  final user = SupabaseService.client.auth.currentUser;
                  if (user == null) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: Colors.white,
                                size: 20,
                              ),
                              SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  'Please login to add favorites',
                                  style: TextStyle(fontSize: 14),
                                ),
                              ),
                            ],
                          ),
                          duration: const Duration(seconds: 2),
                          backgroundColor: const Color(0xFFACBDAA),
                          behavior: SnackBarBehavior.floating,
                          margin: const EdgeInsets.only(
                            bottom: 16,
                            left: 16,
                            right: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      );
                    }
                    return;
                  }

                  try {
                    debugPrint(
                        'ProductDetailsScreen: Toggling favorite for product: ${product.id}');
                    await favoriteProvider.toggleFavorite(product.id);
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            favoriteProvider.isFavorite(product.id)
                                ? 'Added to favorites ✓'
                                : 'Removed from favorites',
                          ),
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    }
                  } catch (e) {
                    debugPrint('ProductDetailsScreen Error: $e');
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                },
              );
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
            product.description.isNotEmpty
                ? product.description
                : 'No description available',
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
