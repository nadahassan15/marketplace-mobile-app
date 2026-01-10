import 'package:flutter/material.dart';
import '../models/chat.dart';
import '../services/chat_service.dart';
import '../services/brand_service.dart';
import '../models/brand.dart';
import 'chat_screen.dart';

class ChatsListScreen extends StatefulWidget {
  const ChatsListScreen({super.key});

  @override
  State<ChatsListScreen> createState() => _ChatsListScreenState();
}

class _ChatsListScreenState extends State<ChatsListScreen> {
  final ChatService _chatService = ChatService();
  final BrandService _brandService = BrandService();

  bool _isLoading = true;
  List<Chat> _chats = [];
  Map<String, Brand> _brandsMap = {};

  String _query = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      final chats = await _chatService.getUserChats();
      final brands = await _brandService.getAllBrands();

      final map = <String, Brand>{};
      for (final b in brands) {
        map[b.id] = b;
      }

      if (!mounted) return;
      setState(() {
        _chats = chats;
        _brandsMap = map;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading chats: $e')),
      );
    }
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);

    if (diff.inMinutes < 60) {
      final m = diff.inMinutes.clamp(1, 59);
      return '${m}m';
    }
    if (diff.inHours < 24) {
      return '${diff.inHours}h';
    }
    if (diff.inDays < 7) {
      return '${diff.inDays}d';
    }
    final d = dt.day.toString().padLeft(2, '0');
    final mo = dt.month.toString().padLeft(2, '0');
    return '$d/$mo';
  }

  List<Chat> get _filteredChats {
    if (_query.trim().isEmpty) return _chats;

    final q = _query.trim().toLowerCase();
    return _chats.where((c) {
      final brand = _brandsMap[c.brandId];
      final brandName = (brand?.name ?? '').toLowerCase();
      final lastMsg = (c.message ?? '').toLowerCase();
      return brandName.contains(q) || lastMsg.contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final chats = _filteredChats;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Messages',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      body: Stack(
        children: [
          const _ListBackground(),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
                  child: _SearchBar(
                    onChanged: (v) => setState(() => _query = v),
                  ),
                ),
                Expanded(
                  child: _isLoading
                      ? const Center(
                          child: CircularProgressIndicator(color: Colors.white),
                        )
                      : RefreshIndicator(
                          onRefresh: _loadData,
                          child: chats.isEmpty
                              ? const _NoChatsState()
                              : ListView.separated(
                                  padding:
                                      const EdgeInsets.fromLTRB(12, 10, 12, 20),
                                  itemCount: chats.length,
                                  separatorBuilder: (_, __) =>
                                      const SizedBox(height: 10),
                                  itemBuilder: (context, index) {
                                    final chat = chats[index];
                                    final brand = _brandsMap[chat.brandId];
                                    final title = brand?.name ?? 'Brand';
                                    final subtitle = (chat.message?.trim().isNotEmpty ?? false)
                                        ? chat.message!.trim()
                                        : 'Tap to open chat';
                                    final time = _formatTime(chat.createdAt);

                                    return TweenAnimationBuilder<double>(
                                      tween: Tween(begin: 0, end: 1),
                                      duration: Duration(
                                        milliseconds: 220 + (index.clamp(0, 8) * 40),
                                      ),
                                      curve: Curves.easeOutCubic,
                                      builder: (context, t, child) => Opacity(
                                        opacity: t,
                                        child: Transform.translate(
                                          offset: Offset(0, (1 - t) * 10),
                                          child: child,
                                        ),
                                      ),
                                      child: _ChatTile(
                                        title: title,
                                        subtitle: subtitle,
                                        time: time,
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) =>
                                                  ChatScreen(brandId: chat.brandId),
                                            ),
                                          );
                                        },
                                      ),
                                    );
                                  },
                                ),
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ListBackground extends StatelessWidget {
  const _ListBackground();

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
    );
  }
}

class _SearchBar extends StatelessWidget {
  final ValueChanged<String> onChanged;
  const _SearchBar({required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: onChanged,
      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
      decoration: InputDecoration(
        hintText: 'Search chats…',
        hintStyle: TextStyle(color: Colors.white.withOpacity(0.55)),
        prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFFACBDAA)),
        filled: true,
        fillColor: Colors.white.withOpacity(0.10),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(999),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.10)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(999),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.10)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(999),
          borderSide: const BorderSide(color: Color(0xFFACBDAA), width: 1.2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
    );
  }
}

class _ChatTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final String time;
  final VoidCallback onTap;

  const _ChatTile({
    required this.title,
    required this.subtitle,
    required this.time,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final letter = title.trim().isEmpty ? 'B' : title.trim()[0].toUpperCase();

    return Material(
      color: Colors.white.withOpacity(0.10),
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: const Color(0xFFACBDAA),
                child: Text(
                  letter,
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.72),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Text(
                time,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.62),
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NoChatsState extends StatelessWidget {
  const _NoChatsState();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 80),
      children: [
        const Icon(Icons.chat_bubble_outline_rounded, size: 74, color: Colors.white),
        const SizedBox(height: 14),
        const Center(
          child: Text(
            'No chats yet',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 18,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Center(
          child: Text(
            'Start a chat from any brand page.',
            style: TextStyle(
              color: Colors.white.withOpacity(0.72),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 18),
      ],
    );
  }
}
