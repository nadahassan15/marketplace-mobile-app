class Brand {
  final String brandId;
  final String? brandName;
  final String? description;
  final String? logoPath;
  final String? address;
  final double? latitude;
  final double? longitude;
  final DateTime createdAt;

  Brand({
    required this.brandId,
    this.brandName,
    this.description,
    this.logoPath,
    this.address,
    this.latitude,
    this.longitude,
    required this.createdAt,
  });

  factory Brand.fromJson(Map<String, dynamic> json) {
    return Brand(
      // Match your database column names exactly (lowercase)
      brandId: json['brandid'] as String, // Changed from 'brandId'
      brandName: json['brandname'] as String?, // Changed from 'brandName'
      description: json['description'] as String?,
      logoPath: json['logo_path'] as String?,
      address: json['address'] as String?,
      latitude: json['latitude'] != null
          ? (json['latitude'] as num).toDouble()
          : null,
      longitude: json['longitude'] != null
          ? (json['longitude'] as num).toDouble()
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
    // Match your database column names exactly (lowercase)
    'brandid': brandId, // Changed from 'brandId'
    'brandname': brandName, // Changed from 'brandName'
    'description': description,
    'logo_path': logoPath,
    'address': address,
    'latitude': latitude,
    'longitude': longitude,
    // Don't include created_at in updates - it's auto-generated
  };

  Brand copyWith({
    String? brandId,
    String? brandName,
    String? description,
    String? logoPath,
    String? address,
    double? latitude,
    double? longitude,
    DateTime? createdAt,
  }) {
    return Brand(
      brandId: brandId ?? this.brandId,
      brandName: brandName ?? this.brandName,
      description: description ?? this.description,
      logoPath: logoPath ?? this.logoPath,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
