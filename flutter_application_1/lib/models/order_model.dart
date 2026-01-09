class OrderModel {
  final String id;
  final String userId;
  final double total;
  final String status;
  final DateTime createdAt;

  OrderModel({
    required this.id,
    required this.userId,
    required this.total,
    required this.status,
    required this.createdAt,
  });

  factory OrderModel.fromMap(Map<String, dynamic> map) {
    return OrderModel(
      id: map['id'],
      userId: map['user_id'],
      total: (map['total'] as num).toDouble(),
      status: map['status'],
      createdAt: DateTime.parse(map['created_at']),
    );
  }
}
