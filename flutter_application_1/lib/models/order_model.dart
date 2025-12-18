class OrderModel {
  final String id;
  final String date;
  final double total;
  final String status;

  OrderModel({
    required this.id,
    required this.date,
    required this.total,
    required this.status,
  });

  // // 🔹 READY FOR SUPABASE
  // factory OrderModel.fromMap(Map<String, dynamic> map) {
  //   return OrderModel(
  //     id: map['id'],
  //     date: map['created_at'],
  //     total: map['total'],
  //     status: map['status'],
  //   );
  // }

  // Map<String, dynamic> toMap() {
  //   return {
  //     'id': id,
  //     'created_at': date,
  //     'total': total,
  //     'status': status,
  //   };
  // }
}
