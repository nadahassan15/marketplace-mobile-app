import '../models/chat.dart';
import '../models/message.dart';
import 'supabase_service.dart';
import 'package:uuid/uuid.dart';

class ChatService {
  final _supabase = SupabaseService();
  final Uuid _uuid = const Uuid();

  String? _cachedChatsTable;
  String? _cachedMessagesTable;

  Future<String> _resolveTable(List<String> candidates) async {
    for (final t in candidates) {
      try {
        // A tiny probe to verify table exists & is accessible
        await _supabase.client.from(t).select('id').limit(1);
        return t;
      } catch (_) {
        // try next
      }
    }
    // Default (most common)
    return candidates.first;
  }

  Future<String> _chatsTable() async {
    _cachedChatsTable ??= await _resolveTable(const ['chats', 'Chat', 'chat']);
    return _cachedChatsTable!;
  }

  Future<String> _messagesTable() async {
    _cachedMessagesTable ??=
        await _resolveTable(const ['messages', 'Messages', 'message']);
    return _cachedMessagesTable!;
  }

  Future<Map<String, dynamic>?> _tryFindChat({
    required String table,
    required String userId,
    required String brandId,
    required bool dotColumns,
  }) async {
    try {
      final response = await _supabase.client
          .from(table)
          .select()
          .eq(dotColumns ? 'user.id' : 'user_id', userId)
          .eq(dotColumns ? 'brand.id' : 'brand_id', brandId)
          .limit(1);

      final list = (response as List?)?.cast<dynamic>() ?? const <dynamic>[];
      if (list.isEmpty) return null;

      final row = list.first;
      if (row is Map<String, dynamic>) return row;
      return Map<String, dynamic>.from(row as Map);
    } catch (_) {
      return null;
    }
  }

  Future<Map<String, dynamic>> _insertSingle(
    String table,
    List<Map<String, dynamic>> candidates,
  ) async {
    Object? lastError;
    for (final payload in candidates) {
      try {
        final response =
            await _supabase.client.from(table).insert(payload).select().single();
        return Map<String, dynamic>.from(response as Map);
      } catch (e) {
        lastError = e;
      }
    }
    throw lastError ?? Exception('Insert failed on $table');
  }

  Future<Chat> getOrCreateChat(String brandId) async {
    final user = _supabase.currentUser;
    if (user == null) {
      throw Exception('You must be logged in to start a chat');
    }

    final userId = user.id;
    final chatsTable = await _chatsTable();

    // 1) Find existing (underscore columns first)
    final existingUnderscore = await _tryFindChat(
      table: chatsTable,
      userId: userId,
      brandId: brandId,
      dotColumns: false,
    );
    if (existingUnderscore != null) return Chat.fromJson(existingUnderscore);

    // 2) Find existing (dot-columns fallback)
    final existingDot = await _tryFindChat(
      table: chatsTable,
      userId: userId,
      brandId: brandId,
      dotColumns: true,
    );
    if (existingDot != null) return Chat.fromJson(existingDot);

    // 3) Create (try a few payload variants)
    final conversationId = '${userId}_$brandId';
    final candidates = <Map<String, dynamic>>[
      {'user_id': userId, 'brand_id': brandId, 'conversation_id': conversationId},
      {'user_id': userId, 'brand_id': brandId},
      {'user.id': userId, 'brand.id': brandId, 'conversation_id': conversationId},
      {'user.id': userId, 'brand.id': brandId},
    ];

    final row = await _insertSingle(chatsTable, candidates);
    return Chat.fromJson(row);
  }

  Future<Chat?> getChatById(String chatId) async {
    final chatsTable = await _chatsTable();
    try {
      final response =
          await _supabase.client.from(chatsTable).select().eq('id', chatId).single();
      return Chat.fromJson(Map<String, dynamic>.from(response as Map));
    } catch (_) {
      return null;
    }
  }

  Future<List<Chat>> getUserChats() async {
    final user = _supabase.currentUser;
    if (user == null) return [];

    final chatsTable = await _chatsTable();

    // underscore first, then dot
    try {
      final response = await _supabase.client
          .from(chatsTable)
          .select()
          .eq('user_id', user.id)
          .order('created_at', ascending: false);

      final list = (response as List?)?.cast<dynamic>() ?? const <dynamic>[];
      return list
          .map((e) => Chat.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    } catch (_) {
      final response = await _supabase.client
          .from(chatsTable)
          .select()
          .eq('user.id', user.id)
          .order('created_at', ascending: false);

      final list = (response as List?)?.cast<dynamic>() ?? const <dynamic>[];
      return list
          .map((e) => Chat.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    }
  }

  Future<List<Chat>> getBrandChats(String brandId) async {
    final chatsTable = await _chatsTable();

    // underscore first, then dot
    try {
      final response = await _supabase.client
          .from(chatsTable)
          .select()
          .eq('brand_id', brandId)
          .order('created_at', ascending: false);

      final list = (response as List?)?.cast<dynamic>() ?? const <dynamic>[];
      return list
          .map((e) => Chat.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    } catch (_) {
      final response = await _supabase.client
          .from(chatsTable)
          .select()
          .eq('brand.id', brandId)
          .order('created_at', ascending: false);

      final list = (response as List?)?.cast<dynamic>() ?? const <dynamic>[];
      return list
          .map((e) => Chat.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    }
  }

  Future<List<Message>> getMessages(String chatId) async {
    final messagesTable = await _messagesTable();

    try {
      final response = await _supabase.client
          .from(messagesTable)
          .select()
          .eq('chat_id', chatId)
          .order('created_at', ascending: true);

      final list = (response as List?)?.cast<dynamic>() ?? const <dynamic>[];
      return list
          .map((e) => Message.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<Message> sendMessage({
    required String chatId,
    required String content,
  }) async {
    final user = _supabase.currentUser;
    if (user == null) {
      throw Exception('You must be logged in to send messages');
    }

    final messagesTable = await _messagesTable();
    final chatsTable = await _chatsTable();

    // Some schemas use content/message/body, and some have id without default.
    final withContent = <Map<String, dynamic>>[
      {
        'chat_id': chatId,
        'sender_id': user.id,
        'content': content,
        'is_read': false,
      },
      {
        'chat_id': chatId,
        'sender_id': user.id,
        'message': content,
        'is_read': false,
      },
      {
        'chat_id': chatId,
        'sender_id': user.id,
        'body': content,
        'is_read': false,
      },
      {
        'chat_id': chatId,
        'sender_id': user.id,
        'content': content,
      },
    ];

    // Retry variants with generated uuid id (only matters if your table needs it).
    final withId = withContent
        .map((m) => <String, dynamic>{...m, 'id': _uuid.v4()})
        .toList();

    Map<String, dynamic> row;
    try {
      row = await _insertSingle(messagesTable, withContent);
    } catch (_) {
      row = await _insertSingle(messagesTable, withId);
    }

    // Best-effort: update chat last message (schema varies → try a few columns)
    for (final col in const ['message', 'last_message', 'lastMessage']) {
      try {
        await _supabase.client.from(chatsTable).update({col: content}).eq('id', chatId);
        break;
      } catch (_) {
        // keep trying
      }
    }

    return Message.fromJson(row);
  }

  Future<void> markMessagesAsRead(String chatId, String currentUserId) async {
    final messagesTable = await _messagesTable();

    // Mark all messages in this chat NOT sent by me as read
    try {
      await _supabase.client
          .from(messagesTable)
          .update({'is_read': true})
          .eq('chat_id', chatId)
          .neq('sender_id', currentUserId);
    } catch (_) {
      // ignore
    }
  }

  Stream<List<Message>> subscribeToMessages(String chatId) {
    return Stream.fromFuture(_messagesTable()).asyncExpand((messagesTable) {
      return _supabase.client
          .from(messagesTable)
          .stream(primaryKey: const ['id'])
          .eq('chat_id', chatId)
          .order('created_at')
          .map((data) {
        final list = (data as List?)?.cast<dynamic>() ?? const <dynamic>[];
        return list
            .map((e) => Message.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList();
      });
    });
  }
}
