import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:supabase/supabase.dart';
import '../models/product_model.dart';

import '../providers/product_view_provider.dart';
import '../providers/product_list_provider.dart';

class ProductService {

  final supabase = Supabase.instance.client;

  // Save image to local storage and return the filename
  Future<String?> saveImageLocally(File imageFile) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final imagesDir = Directory('${directory.path}/product_images');
      
      if (!await imagesDir.exists()) {
        await imagesDir.create(recursive: true);
      }

      final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final localPath = '${imagesDir.path}/$fileName';

      await imageFile.copy(localPath);
      print('Image saved locally: $localPath');

      return fileName;
    } catch (e) {
      print('Error saving image locally: $e');
      return null;
    }
  }

  Future<String> getLocalImagePath(String fileName) async {
    final directory = await getApplicationDocumentsDirectory();
    return '${directory.path}/product_images/$fileName';
  }

  Future<void> deleteLocalImage(String fileName) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/product_images/$fileName');
      if (await file.exists()) {
        await file.delete();
        print('Local image deleted: $fileName');
      }
    } catch (e) {
      print('Error deleting local image: $e');
    }
  }

  Future<List<Product>> getBrandProducts(String brandId) async {
    try {
      print('Loading products for brandId: $brandId');
      
      final response = await supabase
          .from('products')
          .select()
          .eq('brandId', brandId)
          .order('created_at', ascending: false);

      print('Supabase response: $response');

      if (response == null) {
        print('No data returned from Supabase');
        return [];
      }

      final products = (response as List)
          .map<Product>((e) => Product.fromJson(e))
          .toList();

      print('Loaded ${products.length} products');
      return products;
    } catch (e) {
      print('Error loading products: $e');
      return [];
    }
  }
  
  Future<List<Product>> fetchProducts({required String filter}) async {
    final response = await supabase.from('products').select();

    final products = (response as List)
        .map((e) => Product.fromJson(e))
        .toList();

    final filters = filter
        .toLowerCase()
        .split(',')
        .map((e) => e.trim())
        .toList();

    return products.where((product) {
      final categories = product.category
          .toLowerCase()
          .split(',')
          .map((e) => e.trim())
          .toList();

      // men / women include unisex
      if (filters.contains('men') && !categories.contains('men')) {
        if (!categories.contains('unisex')) return false;
      }

      if (filters.contains('women') && !categories.contains('women')) {
        if (!categories.contains('unisex')) return false;
      }

      // check remaining filters 
      for (final f in filters) {
        if (f == 'men' || f == 'women') continue;
        if (!categories.contains(f)) return false;
      }

      return true;
    }).toList();
  }
  Future<Product> addProduct(Product product) async {
    try {
      print('Adding product to Supabase: ${product.toJson()}');

      final response = await supabase
          .from('products')
          .insert(product.toJson())
          .select()
          .single();

      print('Product added successfully: $response');

      return Product.fromJson(response);
    } catch (e) {
      print('Error adding product to Supabase: $e');
      rethrow;
    }
  }

  Future<void> updateProduct(Product product) async {
    try {
      print('Updating product in Supabase: ${product.productId}');
      print('Update data: ${product.toJson()}');

      final response = await supabase
          .from('products')
          .update(product.toJson())
          .eq('productId', product.productId)
          .select();

      print('Product updated successfully: $response');
    } catch (e) {
      print('Error updating product in Supabase: $e');
      rethrow;
    }
  }

  Future<void> deleteProduct(String productId, String? imagePath) async {
    try {
      print('Deleting product from Supabase: $productId');

      // Delete local image if exists
      if (imagePath != null && imagePath.isNotEmpty) {
        await deleteLocalImage(imagePath);
      }

      // Delete product from database
      final response = await supabase
          .from('products')
          .delete()
          .eq('productId', productId)
          .select();

      print('Product deleted successfully: $response');
    } catch (e) {
      print('Error deleting product from Supabase: $e');
      rethrow;
    }
  }
}

