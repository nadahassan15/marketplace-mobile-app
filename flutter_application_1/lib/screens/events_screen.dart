import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/event.dart';
import '../services/event_service.dart';
import '../services/brand_service.dart';
import 'event_detail_screen.dart';
import 'create_event_screen.dart';

class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  final EventService _eventService = EventService();
  final BrandService _brandService = BrandService();
  List<Event> _events = [];
  bool _isLoading = true;
  bool _isBrandOwner = false;

  @override
  void initState() {
    super.initState();
    _checkBrandOwner();
    _loadEvents();
  }

  Future<void> _checkBrandOwner() async {
    try {
      final isOwner = await _brandService.isBrandOwner();
      setState(() {
        _isBrandOwner = isOwner;
      });
    } catch (e) {
      // Ignore error
    }
  }

  Future<void> _loadEvents() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      print('🔄 EventsScreen: Loading events...');
      final events = await _eventService.getAllEvents();
      print('✅ EventsScreen: Loaded ${events.length} events');
      
      setState(() {
        _events = events;
        _isLoading = false;
      });
    } catch (e) {
      print('❌ EventsScreen: Error loading events: $e');
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading events: $e'),
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  Widget _eventCard(Event event) {
    final day = DateFormat('dd').format(event.eventDate);
    final mon = DateFormat('MMM').format(event.eventDate);
    final time = DateFormat('HH:mm').format(event.eventDate);

    final isPast = event.eventDate.isBefore(DateTime.now());
    final badgeText = isPast ? 'PAST' : (event.isFull ? 'FULL' : 'OPEN');

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        // Always allow opening event detail (even if full/past)
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => EventDetailScreen(event: event)),
        ).then((_) => _loadEvents());
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: [
            // Date badge
            Container(
              width: 56,
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFACBDAA).withOpacity(0.18),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                children: [
                  Text(
                    day,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    mon,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[700],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 14),

            // Main content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${DateFormat('MMM dd, yyyy').format(event.eventDate)} • $time',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: isPast
                              ? Colors.grey.withOpacity(0.12)
                              : event.isFull
                                  ? Colors.red.withOpacity(0.12)
                                  : const Color(0xFFACBDAA).withOpacity(0.12),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          badgeText,
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 12,
                            color: isPast
                                ? Colors.grey[700]
                                : event.isFull
                                    ? Colors.red
                                    : const Color(0xFFACBDAA),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        '${event.currentReservations}/${event.maxSeats} reserved',
                        style: TextStyle(
                          color: event.isFull ? Colors.red : const Color(0xFFACBDAA),
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Color(0xFFACBDAA)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFFACBDAA);
    return Scaffold(
      backgroundColor: primaryColor.withOpacity(0.08),
      appBar: AppBar(
        title: const Text(
          'Events',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFFACBDAA)),
        actions: [
          if (_isBrandOwner)
            IconButton(
              icon: const Icon(Icons.add, color: Color(0xFFACBDAA)),
              tooltip: 'Create Event',
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CreateEventScreen(),
                  ),
                );
                // Refresh events if event was created successfully
                if (result == true) {
                  _loadEvents();
                }
              },
            ),
        ],
      ),
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 700),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [primaryColor.withOpacity(0.18), Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Color(0xFFACBDAA)),
              )
            : _events.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.event, size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        const Text(
                          'No events available',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _loadEvents,
                    color: const Color(0xFFACBDAA),
                    child: ListView.builder(
                      itemCount: _events.length,
                      itemBuilder: (context, index) {
                        return _eventCard(_events[index]);
                      },
                    ),
                  ),
      ),
    );
  }
}
