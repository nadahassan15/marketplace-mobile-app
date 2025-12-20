import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/brand_model.dart';
import '../services/brand_service.dart';

final brandProvider = FutureProvider.family<Brand, String>((ref, brandId) {
  return BrandService().getBrand(brandId);
});