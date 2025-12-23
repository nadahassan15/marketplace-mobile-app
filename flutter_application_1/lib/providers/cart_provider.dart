import 'package:flutter/material.dart';
import '../models/cart_item_model.dart';

class CartProvider extends ChangeNotifier {
  //TEMP DATA
  final List<CartItem> _items = [
  CartItem(
    id: '1',
    name: 'Basic Sweatshirt',
    price: 850,
    color: 'Green',
    quantity: 1,
    image: 'assets/images/sweatshirt.png',
  ),
  CartItem(
    id: '2',
    name: 'Mid-Rise Straight Leg Denim',
    price: 1350,
    color: 'Dark Blue',
    quantity: 2,
    image: 'assets/images/denim.png',
  ),
  CartItem(
    id: '3',
    name: 'Full Length Coat',
    price: 2000,
    color: 'Black',
    quantity: 1,
    image: 'assets/images/coat.png',
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

