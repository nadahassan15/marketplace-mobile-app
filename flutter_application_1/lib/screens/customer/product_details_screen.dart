import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../providers/review_provider.dart';
import '../../models/product_model.dart';
import '../../providers/cart_provider.dart';
import '../../providers/favorite_provider.dart';
import '../../services/supabase_service.dart';
import 'cart_screen.dart';
import 'checkout_screen.dart';

final _reviewFormKey = GlobalKey<FormState>();

class ProductDetailsScreen extends StatefulWidget {
  final Product product;

  const ProductDetailsScreen({
    super.key,
    required this.product,
  });

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  String? selectedSize;
  String? selectedColor;

  final TextEditingController reviewController = TextEditingController();

  // ✅ REVIEW IMAGE
  File? selectedReviewImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FavoritesProvider>().loadFavorites();
      context.read<ReviewProvider>().loadReviews(widget.product.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;

    return Scaffold(
      appBar: AppBar(
        title: Text(product.name),
        actions: [
          // 🛒 CART ICON
          Consumer<CartProvider>(
            builder: (context, cart, _) {
              return Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.shopping_bag_outlined),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const CartScreen(),
                        ),
                      );
                    },
                  ),
                  if (cart.items.isNotEmpty)
                    Positioned(
                      right: 6,
                      top: 6,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 18,
                          minHeight: 18,
                        ),
                        child: Text(
                          cart.items.length.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),

          // ❤️ FAVORITE
          Consumer<FavoritesProvider>(
            builder: (_, favorites, __) {
              final isFav = favorites.isFavorite(product.id);
              return IconButton(
                icon: Icon(
                  isFav ? Icons.favorite : Icons.favorite_border,
                  color: isFav ? Colors.red : null,
                ),
                onPressed: () async {
                  final user = SupabaseService.client.auth.currentUser;
                  if (user == null) {
                    _showTopToast(
                      context,
                      'Please login first',
                      isError: true,
                    );
                    return;
                  }
                  await favorites.toggleFavorite(product.id);
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
            _image(product),
            _info(product),
            _sizes(product),
            _colors(product),
            _buttons(product),
            _description(product),
            _reviewsSection(),
            _reviewsList(),
          ],
        ),
      ),
    );
  }

  // ================= UI SECTIONS =================

  Widget _image(Product product) {
    return Image.asset(
      'assets/images/${product.imagePath}',
      height: 350,
      width: double.infinity,
      fit: BoxFit.cover,
    );
  }

  Widget _info(Product product) {
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
            'EGP ${product.price}',
            style: const TextStyle(fontSize: 18),
          ),
        ],
      ),
    );
  }

  Widget _sizes(Product product) {
    if (product.sizes.isEmpty) return const SizedBox();

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
            children: product.sizes.map((size) {
              final isSelected = selectedSize == size;
              return ChoiceChip(
                label: Text(size),
                selected: isSelected,
                onSelected: (_) {
                  setState(() => selectedSize = size);
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _colors(Product product) {
    if (product.colors.isEmpty) return const SizedBox();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Select Color',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: product.colors.map((color) {
              final isSelected = selectedColor == color;
              return ChoiceChip(
                label: Text(color),
                selected: isSelected,
                onSelected: (_) {
                  setState(() => selectedColor = color);
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buttons(Product product) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFACBDAA),
              foregroundColor: Colors.black,
              minimumSize: const Size(double.infinity, 48),
            ),
            onPressed: () {
              if (selectedSize == null || selectedColor == null) {
                _showTopToast(
                  context,
                  'Please select size and color',
                  isError: true,
                );
                return;
              }
              context.read<CartProvider>().addToCart(
                    product: product,
                    size: selectedSize!,
                    color: selectedColor!,
                  );

              _showTopToast(
                context,
                'Product added to cart successfully',
                isError: false,
              );
            },
            child: const Text('Add to Cart'),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Colors.black,
              minimumSize: const Size(double.infinity, 48),
            ),
            onPressed: () {
              if (selectedSize == null || selectedColor == null) {
                _showTopToast(
                  context,
                  'Please select size and color',
                  isError: true,
                );
                return;
              }
              context.read<CartProvider>().addToCart(
                    product: product,
                    size: selectedSize!,
                    color: selectedColor!,
                  );

              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CartScreen()),
              );
            },
            child: const Text('Buy it Now'),
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
                  icon: const Icon(Icons.photo, color: Colors.black),
                  label: const Text(
                    'Upload Photo',
                    style: TextStyle(color: Colors.black),
                  ),
                  onPressed: () async {
                    final XFile? image =
                        await _picker.pickImage(source: ImageSource.gallery);

                    if (image != null) {
                      setState(() {
                        selectedReviewImage = File(image.path);
                      });
                    }
                  },
                ),
                const Spacer(),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFACBDAA),
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () async {
                    if (_reviewFormKey.currentState!.validate()) {
                      await context.read<ReviewProvider>().addReview(
                            productId: widget.product.id,
                            comment: reviewController.text,
                            imageFile: selectedReviewImage,
                          );

                      reviewController.clear();
                      setState(() {
                        selectedReviewImage = null;
                      });

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Review submitted')),
                      );
                    }
                  },
                  child: const Text('Submit'),
                ),
              ],
            ),
            if (selectedReviewImage != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Image.file(
                  selectedReviewImage!,
                  height: 120,
                  fit: BoxFit.cover,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _reviewsList() {
    final provider = context.watch<ReviewProvider>();

    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.reviews.isEmpty) {
      return const Text('No reviews yet');
    }

    return Column(
      children: provider.reviews.map((review) {
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(review.comment),
                if (review.imageUrl != null) ...[
                  const SizedBox(height: 8),
                  Image.network(review.imageUrl!, height: 120),
                ],
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _description(Product product) {
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

  // ================= TOAST =================
  void _showTopToast(
    BuildContext context,
    String text, {
    required bool isError,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.warning_amber_rounded : Icons.check_circle,
              color: isError ? Colors.orange : Colors.green,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(color: Colors.black),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
