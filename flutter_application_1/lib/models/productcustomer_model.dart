class Product {
  final String id;
  final String name;
  final int price;
  final String imagePath;
  final String category;
  final List<String> sizes;
  final List<String> colors; 
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
  List<String> parseList(dynamic value) {
    if (value == null) return [];

    if (value is List) {
      return value
          .map((e) => e.toString().replaceAll('"', '').trim())
          .toList();
    }

    return value
        .toString()
        .replaceAll('[', '')
        .replaceAll(']', '')
        .replaceAll('"', '')
        .split(',')
        .map((e) => e.trim())
        .toList();
  }

  return Product(
    id: json['productid'].toString(),
    name: json['name'],
    price: json['price'] as int,
    imagePath: json['image_path'],
    category: json['category'],
    sizes: parseList(json['size']),     
    colors: parseList(json['colors']), 
    description: json['description'] ?? '',
  );
}
}