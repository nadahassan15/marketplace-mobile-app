class Event {
  final String id; // uuid in database
  final String brandId; // brand_id (text) in database
  final String title; // text in database
  final String description; // text in database
  final DateTime eventDate; // event_date (timestamp) in database
  final int maxSeats; // max_seats (int4) in database
  final DateTime createdAt; // created_at (timestamptz) in database
  int _currentReservations; // Calculated from reservations table

  Event({
    required this.id,
    required this.brandId,
    required this.title,
    required this.description,
    required this.eventDate,
    required this.maxSeats,
    required this.createdAt,
    int currentReservations = 0,
  }) : _currentReservations = currentReservations;

  factory Event.fromJson(Map<String, dynamic> json) {
    try {
      // Handle null values safely
      final id = json['id']?.toString() ?? '';
      final brandId = json['brand_id']?.toString() ?? '';
      final title = json['title']?.toString() ?? 'Untitled Event';
      final description = json['description']?.toString() ?? '';
      final maxSeats = (json['max_seats'] as num?)?.toInt() ?? 0;
      
      // Parse dates safely
      DateTime eventDate;
      try {
        if (json['event_date'] != null) {
          eventDate = DateTime.parse(json['event_date'].toString());
        } else {
          eventDate = DateTime.now();
        }
      } catch (e) {
        eventDate = DateTime.now();
      }
      
      DateTime createdAt;
      try {
        if (json['created_at'] != null) {
          createdAt = DateTime.parse(json['created_at'].toString());
        } else {
          createdAt = DateTime.now();
        }
      } catch (e) {
        createdAt = DateTime.now();
      }
      
      return Event(
        id: id,
        brandId: brandId,
        title: title,
        description: description,
        eventDate: eventDate,
        maxSeats: maxSeats,
        createdAt: createdAt,
        currentReservations: (json['current_reservations'] as int?) ?? 0,
      );
    } catch (e) {
      print('❌ Event.fromJson Error: $e');
      print('Problematic JSON: $json');
      // Return a default event instead of crashing
      return Event(
        id: json['id']?.toString() ?? '',
        brandId: json['brand_id']?.toString() ?? '',
        title: json['title']?.toString() ?? 'Untitled Event',
        description: json['description']?.toString() ?? 'No description',
        eventDate: DateTime.now(),
        maxSeats: (json['max_seats'] as num?)?.toInt() ?? 0,
        createdAt: DateTime.now(),
        currentReservations: 0,
      );
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'brand_id': brandId,
      'title': title,
      'description': description,
      'event_date': eventDate.toIso8601String(),
      'max_seats': maxSeats,
      'created_at': createdAt.toIso8601String(),
    };
  }

  // Get current reservations count
  int get currentReservations => _currentReservations;
  
  // Check if event is full
  bool get isFull => _currentReservations >= maxSeats;
  
  // Check if event is available (not full and not in the past)
  bool get isAvailable => !isFull && eventDate.isAfter(DateTime.now());
  
  // Set current reservations (used when loading from database)
  void setCurrentReservations(int count) {
    _currentReservations = count;
  }
}
