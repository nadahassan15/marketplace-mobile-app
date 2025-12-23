import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';
import '../models/brand_model.dart';
import '../services/brand_service.dart';

final brandProvider =
    StateNotifierProvider.family<BrandNotifier, AsyncValue<Brand>, String>(
      (ref, brandId) => BrandNotifier(brandId),
    );

class BrandNotifier extends StateNotifier<AsyncValue<Brand>> {
  final String brandId;
  final BrandService _service = BrandService();

  BrandNotifier(this.brandId) : super(const AsyncValue.loading()) {
    loadBrand();
  }

  Future<void> loadBrand() async {
    try {
      state = const AsyncValue.loading();
      final brand = await _service.getBrand(brandId);
      state = AsyncValue.data(brand);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> updateBrand(Brand brand, File? newLogoFile) async {
    try {
      String? logoUrl = brand.logoPath;

      // If new logo is uploaded
      if (newLogoFile != null) {
        // Delete old logo from Supabase Storage if exists
        if (brand.logoPath != null && brand.logoPath!.isNotEmpty) {
          await _service.deleteLogoFromStorage(brand.logoPath!);
          await _service.deleteLocalCache(brand.logoPath!);
        }

        // Upload new logo to Supabase Storage and get URL
        logoUrl = await _service.uploadLogo(newLogoFile, brand.brandId);

        if (logoUrl == null) {
          throw Exception('Failed to upload logo');
        }
      }

      // Update brand with new logo URL
      final updatedBrand = brand.copyWith(logoPath: logoUrl);
      await _service.updateBrand(updatedBrand);

      // Reload brand data
      await loadBrand();
    } catch (e) {
      print('Error updating brand: $e');
      rethrow;
    }
  }
}
