class Brand {
  final String id; // brandid in database
  final String name; // brandname in database
  final String description;
  final String? logoPath; // logo_path in database
  final String? address;
  final double latitude;
  final double longitude;
  final DateTime createdAt;

  Brand({
    required this.id,
    required this.name,
    required this.description,
    this.logoPath,
    this.address,
    required this.latitude,
    required this.longitude,
    required this.createdAt,
  });

  factory Brand.fromJson(Map<String, dynamic> json) {
    try {
      // Helper function to safely get string or provide default
      String getString(String key, {String defaultValue = ''}) {
        final value = json[key];
        if (value == null) {
          print('⚠️ Warning: Field "$key" is null in brand data');
          return defaultValue;
        }
        return value.toString();
      }

      // Helper function to safely parse DateTime
      DateTime parseDateTime(String key) {
        final value = json[key];
        if (value == null) {
          print('⚠️ Warning: Field "$key" is null, using current time');
          return DateTime.now();
        }
        if (value is DateTime) return value;
        return DateTime.parse(value.toString());
      }

      return Brand(
        id: getString('brandid'), // Primary key is 'brandid'
        name: getString('brandname'),
        description: getString('description'),
        logoPath: json['logo_path'] as String?,
        address: json['address'] as String?,
        latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
        longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
        createdAt: parseDateTime('created_at'),
      );
    } catch (e, stackTrace) {
      print('❌ Error parsing Brand from JSON: $e');
      print('JSON data: $json');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'brandid': id,
      'brandname': name,
      'description': description,
      'logo_path': logoPath,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

