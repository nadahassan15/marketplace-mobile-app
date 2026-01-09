import 'package:flutter/material.dart';
import '../models/cart_item_model.dart';
import '../models/productcustomer_model.dart';

class CartProvider extends ChangeNotifier {
  final List<CartItem> _items = [];

  List<CartItem> get items => _items;
  // ADD TO CART
  void addToCart({
    required Product product,
    required String size,
    required String color,
  }) {
    final existingIndex = _items.indexWhere(
      (item) =>
          item.productId == product.id &&
          item.size == size &&
          item.color == color,
    );

    if (existingIndex != -1) {
      _items[existingIndex].quantity += 1;
    } else {
      _items.add(
        CartItem(
          productId: product.id,
          name: product.name,
          price: product.price,
imagePath: 'assets/images/${product.imagePath}',
          size: size,
          color: color,
          quantity: 1,
        ),
      );
    }

    notifyListeners();
  }
  // REMOVE ITEM
  void removeFromCart(CartItem item) {
    _items.remove(item);
    notifyListeners();
  }
  // INCREASE QTY
  void increaseQty(CartItem item) {
    item.quantity++;
    notifyListeners();
  }
  // DECREASE QTY
  void decreaseQty(CartItem item) {
    if (item.quantity > 1) {
      item.quantity--;
      notifyListeners();
    }
  }
  // TOTAL PRICE
  double get totalPrice {
    return _items.fold(
      0,
      (sum, item) => sum + (item.price * item.quantity),
    );
  }
  // CART COUNT (BADGE)
  int get totalItems {
    return _items.fold(0, (sum, item) => sum + item.quantity);
  }
}
