import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';
import '../../providers/brand_provider.dart';
import '../../services/brand_service.dart';
import '../product/product_management_screen.dart';
import '../../widgets/dialogs/brand_edit_dialog.dart';

class BrandHomeScreen extends ConsumerWidget {
  final String brandId;

  const BrandHomeScreen({super.key, required this.brandId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final brandState = ref.watch(brandProvider(brandId));

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Brand Dashboard',
          style: TextStyle(
            color: Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: brandState.when(
        data: (brand) => SingleChildScrollView(
          child: Column(
            children: [
              // Brand Header Card
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Column(
                  children: [
                    // Logo
                    if (brand.logoPath != null && brand.logoPath!.isNotEmpty)
                      FutureBuilder<String>(
                        future: BrandService().getLocalLogoPath(
                          brand.logoPath!,
                        ),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            return Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: const Color(0xFFACBDAA),
                                  width: 3,
                                ),
                              ),
                              child: ClipOval(
                                child: Image.file(
                                  File(snapshot.data!),
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(
                                    color: Colors.grey[100],
                                    child: Icon(
                                      Icons.store,
                                      size: 60,
                                      color: Colors.grey[400],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }
                          return Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.grey[100],
                            ),
                            child: const Center(
                              child: CircularProgressIndicator(
                                color: Color(0xFFACBDAA),
                              ),
                            ),
                          );
                        },
                      )
                    else
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.grey[100],
                          border: Border.all(
                            color: const Color(0xFFACBDAA),
                            width: 3,
                          ),
                        ),
                        child: Icon(
                          Icons.store,
                          size: 60,
                          color: Colors.grey[400],
                        ),
                      ),

                    const SizedBox(height: 20),

                    // Brand Name
                    Text(
                      brand.brandName ?? 'No Name',
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 12),

                    // Description
                    if (brand.description != null &&
                        brand.description!.isNotEmpty)
                      Text(
                        brand.description!,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 15,
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),

                    const SizedBox(height: 24),

                    // Edit Button
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (_) =>
                                BrandEditDialog(brand: brand, brandId: brandId),
                          );
                        },
                        icon: const Icon(Icons.edit_outlined),
                        label: const Text('Edit Brand Details'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFFACBDAA),
                          side: const BorderSide(color: Color(0xFFACBDAA)),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Brand Details Card
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Brand Information',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Address
                    if (brand.address != null && brand.address!.isNotEmpty)
                      _buildInfoRow(
                        Icons.location_on_outlined,
                        'Address',
                        brand.address!,
                      ),

                    // Coordinates
                    if (brand.latitude != null && brand.longitude != null)
                      _buildInfoRow(
                        Icons.pin_drop_outlined,
                        'Coordinates',
                        '${brand.latitude!.toStringAsFixed(6)}, ${brand.longitude!.toStringAsFixed(6)}',
                      ),

                    // Created Date
                    _buildInfoRow(
                      Icons.calendar_today_outlined,
                      'Joined',
                      '${brand.createdAt.day}/${brand.createdAt.month}/${brand.createdAt.year}',
                    ),

                    // Brand ID
                    _buildInfoRow(
                      Icons.fingerprint_outlined,
                      'Brand ID',
                      brand.brandId,
                      isSmall: true,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Action Buttons
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  ProductManagementScreen(brandId: brandId),
                            ),
                          );
                        },
                        icon: const Icon(
                          Icons.inventory_2_outlined,
                          color: Colors.white,
                        ),
                        label: const Text(
                          'Manage Products',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFACBDAA),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          // Add analytics navigation
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Analytics coming soon!'),
                              backgroundColor: Color(0xFFACBDAA),
                            ),
                          );
                        },
                        icon: const Icon(Icons.analytics_outlined),
                        label: const Text(
                          'View Analytics',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.black,
                          side: BorderSide(color: Colors.grey[300]!),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
        loading: () => const Center(
          child: CircularProgressIndicator(color: Color(0xFFACBDAA)),
        ),
        error: (error, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'Error loading brand',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  error.toString(),
                  style: TextStyle(color: Colors.grey[500], fontSize: 14),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () {
                    ref.refresh(brandProvider(brandId));
                  },
                  icon: const Icon(Icons.refresh, color: Colors.white),
                  label: const Text(
                    'Retry',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFACBDAA),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    IconData icon,
    String label,
    String value, {
    bool isSmall = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFACBDAA).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: const Color(0xFFACBDAA), size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: isSmall ? 12 : 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
