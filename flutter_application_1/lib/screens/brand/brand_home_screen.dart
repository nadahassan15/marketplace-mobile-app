import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/brand_provider.dart';
import '../product/product_management_screen.dart';

class BrandHomeScreen extends ConsumerWidget {
  final String brandId;

  const BrandHomeScreen({super.key, required this.brandId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final brand = ref.watch(brandProvider(brandId));

    return Scaffold(
      appBar: AppBar(title: const Text('Brand Dashboard')),
      body: brand.when(
        data: (b) => Column(
          children: [
            CircleAvatar(radius: 40, backgroundImage: NetworkImage(b.logoPath)),
            Text(b.brandName, style: Theme.of(context).textTheme.headlineSmall),
            Text(b.description),
            ElevatedButton(
              child: const Text('Manage Products'),
              onPressed: () {
                Navigator.push(context,
                  MaterialPageRoute(
                    builder: (_) => ProductManagementScreen(brandId: brandId),
                  ),
                );
              },
            ),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const Text('Error loading brand'),
      ),
    );
  }
}
