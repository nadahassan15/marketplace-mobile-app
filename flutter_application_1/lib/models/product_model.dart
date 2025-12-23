class Product {
  final String id;
  final String name;
  final int price;
  final String imagePath;
  final String colors;
  final String category;
  final List<String> sizes;
  final String description;
  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.imagePath,
    required this.colors,
    required this.category,
    required this.sizes,
    required this.description,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['productid'].toString(),
      name: json['name'],
      price: json['price'] as int,
      imagePath: json['image_path'],
      colors: json['colors'],
      category: json['category'],
sizes: json['size'] == null
    ? []
    : json['size'] is List
        ? List<String>.from(json['size'])
        : json['size']
            .toString()
            .replaceAll('{', '')
            .replaceAll('}', '')
            .split(',')
            .map((e) => e.trim())
            .toList(),
      description: json['description'] ?? '',
    );
  }
}
