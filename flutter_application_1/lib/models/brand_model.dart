class Brand {
  final String brandId;
  final String brandName;
  final String description;
  final String logoPath;
  final String address;
  final double latitude;
  final double longitude;
  final DateTime createdAt;

  Brand({
    required this.brandId,
    required this.brandName,
    required this.description,
    required this.logoPath,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.createdAt,
  });

  factory Brand.fromJson(Map<String, dynamic> json) {
    return Brand(
      brandId: json['brandId'],
      brandName: json['brandName'],
      description: json['description'],
      logoPath: json['logo_path'],
      address: json['address'],
      latitude: (json['latitude'] ?? 0).toDouble(),
      longitude: (json['longitude'] ?? 0).toDouble(),
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() => {
    'brandId': brandId,
    'brandName': brandName,
    'description': description,
    'logo_path': logoPath,
    'address': address,
    'latitude': latitude,
    'longitude': longitude,
  };
}
// class BrandModel {
//   String id = '';
//   String name = '';
//   String description = '';
//   String logoUrl = '';

//   BrandModel();
// }
