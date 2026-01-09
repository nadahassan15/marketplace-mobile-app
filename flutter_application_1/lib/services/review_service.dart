import 'package:flutter/material.dart';
import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/supabase_service.dart';

class ReviewService {
  final supabase = SupabaseService.client;

  Future<List> getReviews(String productId) async {
    return await supabase
        .from('reviews')
        .select()
        .eq('product_id', productId)
        .order('created_at', ascending: false);
  }

  Future<void> addReview({
    required String productId,
    required String comment,
    String? imageUrl,
  }) async {
    await supabase.from('reviews').insert({
      'product_id': productId,
      'user_id': supabase.auth.currentUser!.id,
      'comment': comment,
      'image_url': imageUrl,
    });
  }

  Future<String> uploadReviewImage({
    required String productId,
    required File imageFile,
  }) async {
    final path =
        'reviews/$productId/${DateTime.now().millisecondsSinceEpoch}.jpg';

    await supabase.storage
        .from('review-images')
        .upload(path, imageFile);

    return supabase.storage.from('review-images').getPublicUrl(path);
  }
}
