class Reservation {
  final String id;
  final String eventId;
  final String userId;
  final DateTime createdAt;

  Reservation({
    required this.id,
    required this.eventId,
    required this.userId,
    required this.createdAt,
  });

  factory Reservation.fromJson(Map<String, dynamic> json) {
    return Reservation(
      id: json['id'] as String,
      eventId: json['event_id'] as String,
      userId: json['user_id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'event_id': eventId,
      'user_id': userId,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

