class Product {
  final String productId;
  final String brandId;
  final String name;
  final String category;
  final String description;
  final double price;
  final int stockQty;
  final String imagePath;
  final bool status;
  final DateTime createdAt;

  Product({
    required this.productId,
    required this.brandId,
    required this.name,
    required this.category,
    required this.description,
    required this.price,
    required this.stockQty,
    required this.imagePath,
    required this.status,
    required this.createdAt,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      productId: json['productId'],
      brandId: json['brandId'],
      name: json['name'],
      category: json['category'],
      description: json['description'],
      price: (json['price']).toDouble(),
      stockQty: json['stock_qty'],
      imagePath: json['image_path'],
      status: json['product_status'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() => {
    'brandId': brandId,
    'name': name,
    'category': category,
    'description': description,
    'price': price,
    'stock_qty': stockQty,
    'image_path': imagePath,
    'product_status': status,
  };
}
