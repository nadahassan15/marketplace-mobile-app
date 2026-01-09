import 'dart:io';
import 'package:flutter/material.dart';
import '../models/review_model.dart';
import '../services/review_service.dart';

class ReviewProvider extends ChangeNotifier {
  final ReviewService _service = ReviewService();

  List<Review> reviews = [];
  bool isLoading = false;

  Future<void> loadReviews(String productId) async {
    isLoading = true;
    notifyListeners();

    try {
      final data = await _service.getReviews(productId);
      reviews = data.map((e) => Review.fromJson(e)).toList();
    } catch (e) {
      reviews = [];
    }

    isLoading = false;
    notifyListeners();
  }

  Future<void> addReview({
    required String productId,
    required String comment,
    File? imageFile,
  }) async {
    String? imageUrl;

    if (imageFile != null) {
      imageUrl = await _service.uploadReviewImage(
        productId: productId,
        imageFile: imageFile,
      );
    }

    await _service.addReview(
      productId: productId,
      comment: comment,
      imageUrl: imageUrl,
    );

    // reload reviews after insert
    await loadReviews(productId);
  }
}
