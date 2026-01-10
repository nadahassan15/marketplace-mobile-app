import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import '../models/message.dart';
import '../services/chat_service.dart';
import '../services/brand_service.dart';
import '../models/brand.dart';
import '../services/supabase_service.dart';

class ChatScreen extends StatefulWidget {
  final String brandId;

  const ChatScreen({super.key, required this.brandId});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ChatService _chatService = ChatService();
  final BrandService _brandService = BrandService();
  final SupabaseService _supabaseService = SupabaseService();

  final TextEditingController _messageController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();

  StreamSubscription<List<Message>>? _messagesSub;

  Brand? _brand;
  List<Message> _messages = [];
  bool _isLoading = true;
  bool _isSending = false;
  bool _showJumpToBottom = false;

  String? _chatId;

  // Used to animate only *new* messages (not every rebuild)
  final Set<String> _animatedKeys = <String>{};

  @override
  void initState() {
    super.initState();
    _initializeChat();

    _scrollController.addListener(() {
      if (!_scrollController.hasClients) return;
      final pos = _scrollController.position;
      final atBottom = (pos.pixels >= (pos.maxScrollExtent - 40));
      final next = !atBottom;
      if (next != _showJumpToBottom) {
        setState(() => _showJumpToBottom = next);
      }
    });
  }

  Future<void> _initializeChat() async {
    setState(() => _isLoading = true);

    try {
      final brand = await _brandService.getBrandById(widget.brandId);
      final chat = await _chatService.getOrCreateChat(widget.brandId);
      final messages = await _chatService.getMessages(chat.id);

      _chatId = chat.id;
      _brand = brand;
      _messages = messages;
      _isLoading = false;

      if (mounted) setState(() {});

      // Mark initial as read
      final me = _supabaseService.currentUser?.id;
      if (me != null) {
        await _chatService.markMessagesAsRead(chat.id, me);
      }

      // Subscribe
      await _messagesSub?.cancel();
      _messagesSub = _chatService.subscribeToMessages(chat.id).listen((newMessages) async {
        if (!mounted) return;
        setState(() => _messages = newMessages);

        final me = _supabaseService.currentUser?.id;
        if (me != null) {
          await _chatService.markMessagesAsRead(chat.id, me);
        }

        WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottomIfNearBottom());
      });

      WidgetsBinding.instance.addPostFrameCallback((_) => _jumpToBottom());
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Chat error: $e')),
        );
      }
    }
  }

  Future<void> _sendMessage() async {
    final chatId = _chatId;
    if (chatId == null) return;

    final raw = _messageController.text;
    final content = raw.trim();
    if (content.isEmpty) return;

    setState(() => _isSending = true);

    // Optimistic UI (clears input instantly)
    _messageController.clear();
    _focusNode.requestFocus();

    try {
      await _chatService.sendMessage(chatId: chatId, content: content);
      // Stream will update list, but ensure we're at the bottom.
      WidgetsBinding.instance.addPostFrameCallback((_) => _jumpToBottom());
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Send error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  void _jumpToBottom() {
    if (!_scrollController.hasClients) return;
    _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
  }

  void _scrollToBottomIfNearBottom() {
    if (!_scrollController.hasClients) return;
    final pos = _scrollController.position;

    // if user is close to bottom, keep them pinned
    final dist = (pos.maxScrollExtent - pos.pixels).abs();
    if (dist <= 220) {
      _scrollController.animateTo(
        pos.maxScrollExtent,
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOutCubic,
      );
    }
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  String _formatDay(DateTime dt) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final that = DateTime(dt.year, dt.month, dt.day);
    final diff = today.difference(that).inDays;

    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    // Simple dd/MM/yyyy (no intl dependency)
    final d = dt.day.toString().padLeft(2, '0');
    final mo = dt.month.toString().padLeft(2, '0');
    return '$d/$mo/${dt.year}';
  }

  String _msgKey(Message m) {
    return '${m.senderId}|${m.createdAt.toIso8601String()}|${m.content.hashCode}';
  }

  List<_ChatItem> _buildItems(List<Message> msgs) {
    final items = <_ChatItem>[];
    DateTime? lastDay;

    for (final m in msgs) {
      final day = DateTime(m.createdAt.year, m.createdAt.month, m.createdAt.day);
      if (lastDay == null || day != lastDay) {
        items.add(_ChatItem.dayHeader(_formatDay(m.createdAt)));
        lastDay = day;
      }
      items.add(_ChatItem.message(m));
    }
    return items;
  }

  @override
  void dispose() {
    _messagesSub?.cancel();
    _messageController.dispose();
    _focusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final me = _supabaseService.currentUser?.id;
    final theme = Theme.of(context);
    final items = _buildItems(_messages);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        titleSpacing: 0,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Row(
          children: [
            _BrandAvatar(name: _brand?.name ?? 'Chat'),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                _brand?.name ?? 'Chat',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          const _ChatBackground(),
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 6),
                Expanded(
                  child: _isLoading
                      ? const Center(
                          child: CircularProgressIndicator(color: Colors.white),
                        )
                      : items.isEmpty
                          ? _EmptyState(onStart: () => _focusNode.requestFocus())
                          : ListView.builder(
                              controller: _scrollController,
                              padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                              itemCount: items.length,
                              itemBuilder: (context, index) {
                                final item = items[index];
                                if (item.type == _ChatItemType.dayHeader) {
                                  return _DayHeader(text: item.dayLabel!);
                                }

                                final msg = item.message!;
                                final isMe = (me != null && msg.senderId == me);
                                final key = _msgKey(msg);
                                final animate = _animatedKeys.add(key);

                                return _MessageBubble(
                                  key: ValueKey(key),
                                  message: msg,
                                  isMe: isMe,
                                  timeText: _formatTime(msg.createdAt),
                                  animate: animate,
                                );
                              },
                            ),
                ),

                // Input
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                  child: _InputBar(
                    controller: _messageController,
                    focusNode: _focusNode,
                    isSending: _isSending,
                    onSend: _sendMessage,
                  ),
                ),
              ],
            ),
          ),

          // Jump to bottom button
          if (_showJumpToBottom)
            Positioned(
              right: 14,
              bottom: 92,
              child: _JumpToBottomButton(
                onTap: () {
                  _scrollController.animateTo(
                    _scrollController.position.maxScrollExtent,
                    duration: const Duration(milliseconds: 240),
                    curve: Curves.easeOutCubic,
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

enum _ChatItemType { dayHeader, message }

class _ChatItem {
  final _ChatItemType type;
  final String? dayLabel;
  final Message? message;

  const _ChatItem._(this.type, {this.dayLabel, this.message});

  factory _ChatItem.dayHeader(String label) =>
      _ChatItem._(_ChatItemType.dayHeader, dayLabel: label);

  factory _ChatItem.message(Message m) =>
      _ChatItem._(_ChatItemType.message, message: m);
}

class _ChatBackground extends StatelessWidget {
  const _ChatBackground();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF0B1320),
            Color(0xFF0F1B2B),
            Color(0xFF0B1320),
          ],
        ),
      ),
      child: Align(
        alignment: const Alignment(0, -0.35),
        child: Opacity(
          opacity: 0.14,
          child: Transform.scale(
            scale: 1.15,
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                width: 260,
                height: 260,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [Color(0xFFACBDAA), Colors.transparent],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BrandAvatar extends StatelessWidget {
  final String name;
  const _BrandAvatar({required this.name});

  @override
  Widget build(BuildContext context) {
    final letter = name.trim().isEmpty ? 'C' : name.trim()[0].toUpperCase();
    return CircleAvatar(
      radius: 18,
      backgroundColor: const Color(0xFFACBDAA),
      child: Text(
        letter,
        style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w900),
      ),
    );
  }
}

class _DayHeader extends StatelessWidget {
  final String text;
  const _DayHeader({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.10),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: Colors.white.withOpacity(0.10)),
          ),
          child: Text(
            text,
            style: TextStyle(
              color: Colors.white.withOpacity(0.85),
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final Message message;
  final bool isMe;
  final String timeText;
  final bool animate;

  const _MessageBubble({
    super.key,
    required this.message,
    required this.isMe,
    required this.timeText,
    required this.animate,
  });

  @override
  Widget build(BuildContext context) {
    final maxWidth = MediaQuery.sizeOf(context).width * 0.76;

    final bubble = ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: isMe ? const Color(0xFFACBDAA) : Colors.white.withOpacity(0.12),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: Radius.circular(isMe ? 18 : 6),
            bottomRight: Radius.circular(isMe ? 6 : 18),
          ),
          border: Border.all(
            color: isMe ? Colors.transparent : Colors.white.withOpacity(0.10),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.18),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
          child: Column(
            crossAxisAlignment:
                isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              Text(
                message.content,
                style: TextStyle(
                  color: isMe ? Colors.black : Colors.white,
                  fontSize: 15,
                  height: 1.25,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                timeText,
                style: TextStyle(
                  color: isMe
                      ? Colors.black.withOpacity(0.55)
                      : Colors.white.withOpacity(0.60),
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    final aligned = Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [bubble],
      ),
    );

    // Animation only for new messages
    if (!animate) return aligned;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
      builder: (context, t, child) {
        final dx = (1 - t) * (isMe ? 18 : -18);
        final dy = (1 - t) * 10;
        return Opacity(
          opacity: t,
          child: Transform.translate(
            offset: Offset(dx, dy),
            child: child,
          ),
        );
      },
      child: aligned,
    );
  }
}

class _InputBar extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isSending;
  final VoidCallback onSend;

  const _InputBar({
    required this.controller,
    required this.focusNode,
    required this.isSending,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.10),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: Colors.white.withOpacity(0.10)),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  focusNode: focusNode,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => onSend(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Write a message…',
                    hintStyle: TextStyle(
                      color: Colors.white.withOpacity(0.55),
                      fontWeight: FontWeight.w600,
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              AnimatedScale(
                scale: isSending ? 0.96 : 1,
                duration: const Duration(milliseconds: 140),
                curve: Curves.easeOut,
                child: IconButton(
                  onPressed: isSending ? null : onSend,
                  icon: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 160),
                    child: isSending
                        ? const SizedBox(
                            key: ValueKey('sending'),
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(
                            key: ValueKey('send'),
                            Icons.send_rounded,
                            color: Color(0xFFACBDAA),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _JumpToBottomButton extends StatelessWidget {
  final VoidCallback onTap;
  const _JumpToBottomButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      builder: (context, t, child) => Opacity(
        opacity: t,
        child: Transform.scale(scale: 0.9 + 0.1 * t, child: child),
      ),
      child: Material(
        color: Colors.white.withOpacity(0.12),
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: const Padding(
            padding: EdgeInsets.all(12),
            child: Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white),
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onStart;
  const _EmptyState({required this.onStart});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: const Duration(milliseconds: 380),
        curve: Curves.easeOutCubic,
        builder: (context, t, child) {
          return Opacity(
            opacity: t,
            child: Transform.translate(offset: Offset(0, (1 - t) * 12), child: child),
          );
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.chat_bubble_outline_rounded, size: 70, color: Colors.white),
            const SizedBox(height: 14),
            const Text(
              'No messages yet',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Say hi and start the conversation.',
              style: TextStyle(
                color: Colors.white.withOpacity(0.72),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 18),
            ElevatedButton(
              onPressed: onStart,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFACBDAA),
                foregroundColor: Colors.black,
                shape: const StadiumBorder(),
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              ),
              child: const Text('Start chat', style: TextStyle(fontWeight: FontWeight.w900)),
            ),
          ],
        ),
      ),
    );
  }
}
