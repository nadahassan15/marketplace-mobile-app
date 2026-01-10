import 'message.dart';

class Chat {
  /// `id` can be UUID (text) or bigint depending on your Postgres schema.
  /// To support both, we store it as a String.
  final String id;

  /// conversation_id in DB (optional)
  final String? conversationId;

  /// user_id in DB (uuid) — some projects may have legacy `user.id` (dot)
  final String userId;

  /// brand_id in DB (text/uuid/int-as-text) — some projects may have legacy `brand.id` (dot)
  final String brandId;

  /// Optional cached "last message" text stored on the chat row
  final String? message;

  final DateTime createdAt;

  /// Optional: messages payload when you load with a join
  final List<Message>? messages;

  const Chat({
    required this.id,
    this.conversationId,
    required this.userId,
    required this.brandId,
    this.message,
    required this.createdAt,
    this.messages,
  });

  factory Chat.fromJson(Map<String, dynamic> json) {
    final id = (json['id'] ?? '').toString();

    return Chat(
      id: id,
      conversationId: json['conversation_id'] as String?,
      userId: (json['user_id'] as String?) ?? (json['user.id'] as String?) ?? '',
      brandId: (json['brand_id'] as String?) ??
          (json['brand.id'] as String?) ??
          (json['brandid'] as String?) ??
          '',
      message: json['message'] as String? ??
          json['last_message'] as String? ??
          json['lastMessage'] as String?,
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      messages: (json['messages'] is List)
          ? (json['messages'] as List)
              .whereType<Map<String, dynamic>>()
              .map(Message.fromJson)
              .toList()
          : null,
    );
  }

  /// Use underscore columns by default (recommended).
  /// If your DB really uses dot-columns (rare), pass `dotColumns: true`.
  Map<String, dynamic> toJson({bool dotColumns = false}) {
    final map = <String, dynamic>{};

    if (conversationId != null && conversationId!.trim().isNotEmpty) {
      map['conversation_id'] = conversationId;
    }

    if (message != null && message!.trim().isNotEmpty) {
      map['message'] = message;
    }

    if (userId.isNotEmpty) {
      map[dotColumns ? 'user.id' : 'user_id'] = userId;
    }

    if (brandId.isNotEmpty) {
      map[dotColumns ? 'brand.id' : 'brand_id'] = brandId;
    }

    return map;
  }
}
