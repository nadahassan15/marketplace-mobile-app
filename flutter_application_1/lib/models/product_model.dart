class Product {
  final String id;
  final String name;
  final int price;
  final String imagePath;
  final String colors;
  final String category;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.imagePath,
    required this.colors,
    required this.category,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['productid'].toString(),
      name: json['name'],
      price: json['price'] as int,
      imagePath: json['image_path'],
      colors: json['colors'],
      category: json['category'],
    );
  }
}
