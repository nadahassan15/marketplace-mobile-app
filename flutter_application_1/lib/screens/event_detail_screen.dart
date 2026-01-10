import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/event.dart';
import 'reservation_screen.dart';
import '../services/brand_service.dart';
import '../services/event_service.dart';
import 'edit_event_screen.dart';

class EventDetailScreen extends StatefulWidget {
  final Event event;
  const EventDetailScreen({super.key, required this.event});

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  final BrandService _brandService = BrandService();
  final EventService _eventService = EventService();
  bool _isOwner = false;
  bool _loadingOwner = true;
  late Event _currentEvent;

  @override
  void initState() {
    super.initState();
    _currentEvent = widget.event;
    _checkOwnership();
  }

  Future<void> _checkOwnership() async {
    // Get brands owned by user and check if event.brandId is among them
    final brands = await _brandService.getUserBrands();
    setState(() {
      _isOwner = brands.any((b) => b.id == widget.event.brandId);
      _loadingOwner = false;
    });
  }

  void _editEvent() async {
    final updated = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditEventScreen(event: _currentEvent),
      ),
    );
    if (updated != null && mounted) {
      setState(() {
        // Replace the event object with the updated one
        _currentEvent = updated;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Event updated successfully!')),
      );
    }
  }

  void _deleteEvent() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Event'),
        content: const Text('Are you sure you want to delete this event?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirm == true) {
      try {
        await _eventService.deleteEvent(widget.event.id);
        if (mounted) {
          Navigator.pop(context, true); // Return to previous screen
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete event: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final event = _currentEvent;
    final dateFormat = DateFormat('MMM dd, yyyy');
    final timeFormat = DateFormat('HH:mm');
    final isPast = event.eventDate.isBefore(DateTime.now());
    final statusText = isPast
        ? 'Event ended'
        : event.isFull
            ? 'Event is full'
            : 'Not available';

    return Scaffold(
      backgroundColor: const Color(0xFFACBDAA).withOpacity(0.08),
      appBar: AppBar(
        title: Text(
          event.title,
          style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFFACBDAA)),
        actions: [
          if (!_loadingOwner && _isOwner) ...[
            IconButton(
              icon: const Icon(Icons.edit, color: Color(0xFFACBDAA)),
              tooltip: 'Edit Event',
              onPressed: _editEvent,
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              tooltip: 'Delete Event',
              onPressed: _deleteEvent,
            ),
          ],
        ],
      ),
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 700),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [const Color(0xFFACBDAA).withOpacity(0.18), Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.title,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Icon(Icons.calendar_today, size: 20, color: Color(0xFFACBDAA)),
                        const SizedBox(width: 8),
                        Text(
                          dateFormat.format(event.eventDate),
                          style: const TextStyle(fontSize: 16, color: Colors.black87),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.access_time, size: 20, color: Color(0xFFACBDAA)),
                        const SizedBox(width: 8),
                        Text(
                          timeFormat.format(event.eventDate),
                          style: const TextStyle(fontSize: 16, color: Colors.black87),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.people, size: 20, color: Color(0xFFACBDAA)),
                        const SizedBox(width: 8),
                        Text(
                          '${event.currentReservations}/${event.maxSeats} reserved',
                          style: TextStyle(
                            fontSize: 16,
                            color: event.isFull ? Colors.red : const Color(0xFFACBDAA),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Description',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      event.description,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 32),
                    if (event.isAvailable)
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    ReservationScreen(event: event),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFACBDAA),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Make Reservation',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                      )
                    else
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            statusText,
                            style: const TextStyle(
                              fontSize: 18,
                              color: Colors.grey,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
