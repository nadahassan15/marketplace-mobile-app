import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/brand_model.dart';

class BrandService {
  final SupabaseClient supabase = Supabase.instance.client;

  Future<Brand> getBrand(String brandId) async {
    final data = await supabase
        .from('brandowner')
        .select()
        .eq('brandId', brandId)
        .single();

    return Brand.fromJson(data);
  }

  Future<void> updateBrand(Brand brand) async {
    await supabase
        .from('brandowner')
        .update(brand.toJson())
        .eq('brandId', brand.brandId);
  }
}
