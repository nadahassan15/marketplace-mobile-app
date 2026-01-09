import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/cart_item_model.dart';

class CheckoutProvider extends ChangeNotifier {
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();

  String governorate = 'Cairo';

  String? emailError;
  String? phoneError;
  String? addressError;

  bool validate() {
    bool valid = true;

    if (emailController.text.isEmpty ||
        !emailController.text.contains('@')) {
      emailError = 'Enter a valid email';
      valid = false;
    } else {
      emailError = null;
    }

    if (phoneController.text.length < 10) {
      phoneError = 'Enter a valid phone number';
      valid = false;
    } else {
      phoneError = null;
    }

    if (addressController.text.isEmpty) {
      addressError = 'Address is required';
      valid = false;
    } else {
      addressError = null;
    }

    notifyListeners();
    return valid;
  }

  /// ✅ READY FOR BACKEND
  Future<void> submitOrder({
    required double total,
    required List<CartItem> items,
  }) async {
    if (!validate()) return;

    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      throw Exception('User not logged in');
    }

    debugPrint('ORDER CREATED');
    debugPrint('User: ${user.id}');
    debugPrint('Total: $total');
    debugPrint('Items count: ${items.length}');
    debugPrint('Address: ${addressController.text}');
    debugPrint('Governorate: $governorate');
  }

  @override
  void dispose() {
    emailController.dispose();
    phoneController.dispose();
    addressController.dispose();
    super.dispose();
  }
}
