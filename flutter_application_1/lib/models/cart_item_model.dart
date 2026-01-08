class CartItem {
  final String productId;
  final String name;
  final int price;
  final String imagePath;
  final String size;
  final String color;
  int quantity;

  CartItem({
    required this.productId,
    required this.name,
    required this.price,
    required this.imagePath,
    required this.size,
    required this.color,
    this.quantity = 1,
  });
}
