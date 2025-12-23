class Product {
  final String productId;
  final String brandId;
  final String name;
  final String category;
  final String? colors;
  final List<String> sizes;
  final String? description;
  final double price;
  final int stockQty;
  final String? imagePath;
  final bool status;
  final DateTime createdAt;

  Product({
    required this.productId,
    required this.brandId,
    required this.name,
    required this.category,
    this.colors,
    required this.sizes,
    this.description,
    required this.price,
    required this.stockQty,
    this.imagePath,
    required this.status,
    required this.createdAt,
  });
  
   ///Backward compatibility (old code uses product.id)
  String get id => productId;
  String get imageUrl => imagePath ?? '';

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      productId: (json['productId'] ?? json['productid'] ?? '').toString(),
      brandId: json['brandId'] as String,
      name: json['name'] as String? ?? '',
      category: json['category'] as String? ?? '',
      colors: json['colors'] as String?,
      sizes: _parseSizes(json['size']),
      description: json['description'] as String?,
      price: ((json['price'] ?? 0) as num).toDouble(),      
      stockQty: (json['stock_qty'] ?? 0) as int,
      imagePath: json['image_path'] as String?,
      status: json['product_status'] as bool? ?? true,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }
  
  static List<String> _parseSizes(dynamic size) {
    if (size == null) return [];
    if (size is List) return List<String>.from(size);
    return size
        .toString()
        .replaceAll('{', '')
        .replaceAll('}', '')
        .split(',')
        .map((e) => e.trim())
        .toList();
  }

  Map<String, dynamic> toJson() {
    // For INSERT (add new product) - don't include productId
    if (productId.isEmpty) {
      return {
        'brandId': brandId,
        'name': name,
        'category': category,
        'colors': colors,
        'size': sizes,
        'description': description,
        'price': price.toInt(),
        'stock_qty': stockQty,
        'image_path': imagePath,
        'product_status': status,
      };
    }

    // For UPDATE - include productId
    return {
      'productId': productId,
      'brandId': brandId,
      'name': name,
      'category': category,
      'colors': colors,
      'size': sizes,
      'description': description,
      'price': price.toInt(),
      'stock_qty': stockQty,
      'image_path': imagePath,
      'product_status': status,
    };
  }

  Product copyWith({
    String? productId,
    String? brandId,
    String? name,
    String? category,
    String? colors,
    String? size,
    String? description,
    double? price,
    int? stockQty,
    String? imagePath,
    bool? status,
    DateTime? createdAt,
  }) {
    return Product(
      productId: productId ?? this.productId,
      brandId: brandId ?? this.brandId,
      name: name ?? this.name,
      category: category ?? this.category,
      colors: colors ?? this.colors,
      sizes: sizes ?? this.sizes,
      description: description ?? this.description,
      price: price ?? this.price,
      stockQty: stockQty ?? this.stockQty,
      imagePath: imagePath ?? this.imagePath,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
