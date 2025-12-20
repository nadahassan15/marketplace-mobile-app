import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/product_model.dart';

class ProductService {
  final supabase = Supabase.instance.client;

  Future<List<Product>> getBrandProducts(String brandId) async {
    final data = await supabase
        .from('products')
        .select()
        .eq('brandId', brandId);

    return data.map<Product>((e) => Product.fromJson(e)).toList();
  }

  Future<void> addProduct(Product product) async {
    await supabase.from('products').insert(product.toJson());
  }

  Future<void> updateProduct(Product product) async {
    await supabase
        .from('products')
        .update(product.toJson())
        .eq('productId', product.productId);
  }

  Future<void> deleteProduct(String productId) async {
    await supabase
        .from('products')
        .delete()
        .eq('productId', productId);
  }
}
