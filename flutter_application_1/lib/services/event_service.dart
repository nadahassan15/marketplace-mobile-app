import 'package:supabase_flutter/supabase_flutter.dart';

class EventService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // 1. READ: Get all events
  Future<List<Map<String, dynamic>>> getAllEvents() async {
    final response = await _supabase
        .from('events')
        .select()
        .order('created_at', ascending: false);
    
    return List<Map<String, dynamic>>.from(response);
  }

  // 2. DELETE: Remove an event
  Future<void> deleteEvent(String eventId) async {
    await _supabase.from('events').delete().eq('id', eventId);
  }

  // 3. CREATE: Add a new event
  Future<void> createEvent(String title, String description, String date, int maxSeats) async {
    await _supabase.from('events').insert({
      'title': title,
      'description': description,
      'event_date': date, // Matches the 'event_date' column in your screenshot
      'max_seats': maxSeats, // Matches the 'max_seats' column
    });
  }

  // 4. UPDATE: Edit an existing event (The missing method)
  Future<void> updateEvent({
    required String eventId,
    required String title,
    required String description,
    required String date,
    required int maxSeats,
  }) async {
    await _supabase.from('events').update({
      'title': title,
      'description': description,
      'event_date': date,
      'max_seats': maxSeats,
    }).eq('id', eventId);
  }
}