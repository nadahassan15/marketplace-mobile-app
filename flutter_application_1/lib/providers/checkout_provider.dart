import 'package:flutter/material.dart';

class CheckoutProvider extends ChangeNotifier {
  // Controllers
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();

  String governorate = 'Cairo';

  // Errors
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

  void submitOrder() {
    if (!validate()) return;

    debugPrint('Checkout valid');
    debugPrint(emailController.text);
    debugPrint(phoneController.text);
    debugPrint(addressController.text);
    debugPrint(governorate);

    // Replace this later with Supabase order insert
  }

  @override
  void dispose() {
    emailController.dispose();
    phoneController.dispose();
    addressController.dispose();
    super.dispose();
  }
}
