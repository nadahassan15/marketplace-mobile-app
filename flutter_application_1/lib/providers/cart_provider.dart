import 'package:flutter/material.dart';
import '../models/cart_item_model.dart';

class CartProvider extends ChangeNotifier {
  //TEMP DATA
  final List<CartItem> _items = [
    CartItem(
      id: '1',
      name: 'GOLOCAL Hoodie',
      price: 750,
      color: 'Black',
      quantity: 1,
      // imageUrl: null, image: '', 
    ),
    CartItem(
      id: '2',
      name: 'Relaxed Fleece Sweatshirt',
      price: 1100,
      color: 'Grey',
      quantity: 2,
      // imageUrl: null, image: '',
    ),
  ];

  List<CartItem> get items => _items;

  //CART ACTIONS

  void addToCart(CartItem item) {
    // TODO: Supabase insert
    _items.add(item);
    notifyListeners();
  }

  void removeFromCart(String id) {
    // TODO: Supabase delete
    _items.removeWhere((item) => item.id == id);
    notifyListeners();
  }

  void increaseQty(String id) {
    final item = _items.firstWhere((e) => e.id == id);
    item.quantity++;
    // TODO: Supabase update
    notifyListeners();
  }

  void decreaseQty(String id) {
    final item = _items.firstWhere((e) => e.id == id);
    if (item.quantity > 1) {
      item.quantity--;
      // TODO: Supabase update
      notifyListeners();
    }
  }

  double get totalPrice {
    return _items.fold(0, (sum, item) => sum + (item.price * item.quantity));
  }
}
