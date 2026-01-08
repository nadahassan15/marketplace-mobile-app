import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/product_model.dart';
import '../../providers/favorite_provider.dart';
import '../../services/supabase_service.dart';
import 'product_details_screen.dart';
import '../../utils/responsive.dart';

class FavoriteScreen extends StatefulWidget {
  const FavoriteScreen({super.key});

  @override
  State<FavoriteScreen> createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  List<Product> _favoriteProducts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFavoriteProducts();
    // Listen to favorite changes
    context.read<FavoritesProvider>().addListener(_onFavoritesChanged);
  }

  @override
  void dispose() {
    context.read<FavoritesProvider>().removeListener(_onFavoritesChanged);
    super.dispose();
  }

  void _onFavoritesChanged() {
    // Reload when favorites change
    _loadFavoriteProducts();
  }

  Future<void> _loadFavoriteProducts() async {
    setState(() {
      _isLoading = true;
    });

    try {
      debugPrint('FavoriteScreen: Loading favorite products...');

      // Check if user is logged in
      final user = SupabaseService.client.auth.currentUser;
      if (user == null) {
        debugPrint('FavoriteScreen: No user logged in');
        setState(() {
          _favoriteProducts = [];
          _isLoading = false;
        });
        return;
      }

      final favoriteProvider = context.read<FavoritesProvider>();
      await favoriteProvider.loadFavorites();

      final favoriteIds = favoriteProvider.favorites.toList();
      debugPrint(
          'FavoriteScreen: Found ${favoriteIds.length} favorite IDs: $favoriteIds');

      if (favoriteIds.isEmpty) {
        debugPrint('FavoriteScreen: No favorites found');
        setState(() {
          _favoriteProducts = [];
          _isLoading = false;
        });
        return;
      }

      // Fetch all products from database and filter by favorite IDs
      debugPrint('FavoriteScreen: Fetching products from database...');
      final response = await SupabaseService.client.from('products').select();
      debugPrint(
          'FavoriteScreen: Fetched ${(response as List).length} products from database');

      final allProducts =
          (response as List).map((e) => Product.fromJson(e)).toList();

      // Debug: Print all product IDs to check matching
      debugPrint(
          'FavoriteScreen: All product IDs: ${allProducts.map((p) => p.id).toList()}');

      // Filter products by favorite IDs
      final products = allProducts.where((product) {
        final isMatch = favoriteIds.contains(product.id);
        if (isMatch) {
          debugPrint(
              'FavoriteScreen: Matched product: ${product.name} (ID: ${product.id})');
        }
        return isMatch;
      }).toList();

      debugPrint(
          'FavoriteScreen: Filtered to ${products.length} favorite products');

      setState(() {
        _favoriteProducts = products;
        _isLoading = false;
      });
    } catch (e, stackTrace) {
      debugPrint('FavoriteScreen Error: $e');
      debugPrint('FavoriteScreen StackTrace: $stackTrace');
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading favorites: $e'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenPadding = Responsive.padding(context);
    final double titleFontSize = Responsive.fontSize(
      context,
      mobile: 24,
      tablet: 26,
      desktop: 28,
    );
    final double bodyFontSize = Responsive.fontSize(
      context,
      mobile: 12,
      tablet: 14,
      desktop: 16,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Favorites'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _checkUserLoggedIn()
              ? _favoriteProducts.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.favorite_border,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No favorites yet',
                            style: TextStyle(
                              fontSize: titleFontSize,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Start adding products to your favorites',
                            style: TextStyle(
                              fontSize: bodyFontSize,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadFavoriteProducts,
                      child: GridView.builder(
                        padding: EdgeInsets.all(screenPadding),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.7,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                        itemCount: _favoriteProducts.length,
                        itemBuilder: (context, index) {
                          return _FavoriteProductCard(
                            product: _favoriteProducts[index],
                            onFavoriteRemoved: _loadFavoriteProducts,
                          );
                        },
                      ),
                    )
              : Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.login,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Please Login',
                        style: TextStyle(
                          fontSize: titleFontSize,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'You need to login to view your favorites',
                        style: TextStyle(
                          fontSize: bodyFontSize,
                          color: Colors.grey[500],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () {
                          // Navigate to login screen if exists
                          // Navigator.pushNamed(context, '/login');
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please login to continue'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFACBDAA),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 12,
                          ),
                        ),
                        child: const Text('Go to Login'),
                      ),
                    ],
                  ),
                ),
    );
  }

  bool _checkUserLoggedIn() {
    final user = SupabaseService.client.auth.currentUser;
    return user != null;
  }
}

class _FavoriteProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onFavoriteRemoved;

  const _FavoriteProductCard({
    required this.product,
    required this.onFavoriteRemoved,
  });

  @override
  Widget build(BuildContext context) {
    final favoriteProvider = context.watch<FavoritesProvider>();

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProductDetailsScreen(product: product),
          ),
        ).then((_) {
          // Reload favorites when returning from product details
          onFavoriteRemoved();
        });
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: Image.asset(
                        'assets/images/${product.imagePath}',
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: InkWell(
                        onTap: () async {
                          await favoriteProvider.toggleFavorite(product.id);
                          onFavoriteRemoved();
                        },
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.9),
                          ),
                          child: Icon(
                            favoriteProvider.isFavorite(product.id)
                                ? Icons.favorite
                                : Icons.favorite_border,
                            size: 20,
                            color: favoriteProvider.isFavorite(product.id)
                                ? Colors.red
                                : Colors.grey,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      product.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Text(
                'EGP ${product.price.toInt()}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFACBDAA),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Text(
                product.colors,
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ),
            const SizedBox(height: 6),
          ],
        ),
      ),
    );
  }
}
