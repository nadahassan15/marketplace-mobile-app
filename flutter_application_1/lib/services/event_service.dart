import '../models/event.dart';
import '../models/reservation.dart';
import 'supabase_service.dart';

class EventService {
  final _supabase = SupabaseService();

  // Get all events with reservation counts
  Future<List<Event>> getAllEvents() async {
    try {
      final response = await _supabase.client
          .from('events')
          .select()
          .order('event_date', ascending: true);

      final List<dynamic> data = response as List<dynamic>;
      print('✅ EventService: Loaded ${data.length} events from database');
      
      if (data.isEmpty) {
        print('⚠️ EventService: No events found in database');
        return [];
      }
      
      final List<Event> events = data.map((json) {
        try {
          return Event.fromJson(json);
        } catch (e) {
          print('❌ EventService: Error parsing event: $e');
          print('Problematic JSON: $json');
          rethrow;
        }
      }).toList();
      
      // Load reservation counts for each event
      for (var event in events) {
        try {
          final reservationsResponse = await _supabase.client
              .from('reservations')
              .select('id')
              .eq('event_id', event.id);
          
          final reservationCount = (reservationsResponse as List).length;
          event.setCurrentReservations(reservationCount);
        } catch (e) {
          // If we can't get reservations, leave it at 0
          event.setCurrentReservations(0);
        }
      }
      
      print('✅ EventService: Successfully loaded ${events.length} events');
      return events;
    } catch (e) {
      print('❌ EventService Error: $e');
      print('Error type: ${e.runtimeType}');
      rethrow; // Re-throw to see the actual error
    }
  }

  // Get events by brand
  Future<List<Event>> getEventsByBrand(String brandId) async {
    try {
      final response = await _supabase.client
          .from('events')
          .select()
          .eq('brand_id', brandId)
          .order('event_date', ascending: true);

      final List<dynamic> data = response as List<dynamic>? ?? [];
      final List<Event> events = data.map((json) => Event.fromJson(json)).toList();
      
      // Load reservation counts for each event
      for (var event in events) {
        try {
          final reservationsResponse = await _supabase.client
              .from('reservations')
              .select('id')
              .eq('event_id', event.id);
          
          final reservationCount = (reservationsResponse as List).length;
          event.setCurrentReservations(reservationCount);
        } catch (e) {
          event.setCurrentReservations(0);
        }
      }
      
      return events;
    } catch (e) {
      return [];
    }
  }

  // Create event
  Future<Event> createEvent({
    required String brandId,
    required String title,
    required String description,
    required DateTime eventDate,
    required int maxSeats,
  }) async {
    final user = _supabase.currentUser;
    if (user == null) throw Exception('User must be authenticated to create events');
    
    print('📝 EventService: Creating event...');
    print('   Brand ID: $brandId');
    print('   Title: $title');
    print('   Date: $eventDate');
    print('   Max Seats: $maxSeats');
    
    try {
      final response = await _supabase.client
          .from('events')
          .insert({
            'brand_id': brandId, // text in database
            'title': title,
            'description': description,
            'event_date': eventDate.toIso8601String(), // timestamp in database
            'max_seats': maxSeats, // int4 in database
          })
          .select()
          .single();

      print('✅ EventService: Event created successfully!');
      print('   Event ID: ${response['id']}');
      return Event.fromJson(response);
    } catch (e) {
      print('❌ EventService: Error creating event: $e');
      print('   Error type: ${e.runtimeType}');
      throw Exception('Error creating event: $e');
    }
  }

  // Update event
  Future<Event> updateEvent({
    required String eventId,
    required String title,
    required String description,
    required DateTime eventDate,
    required int maxSeats,
  }) async {
    final user = _supabase.currentUser;
    if (user == null) throw Exception('User must be authenticated to update events');
    try {
      final response = await _supabase.client
          .from('events')
          .update({
            'title': title,
            'description': description,
            'event_date': eventDate.toIso8601String(),
            'max_seats': maxSeats,
          })
          .eq('id', eventId)
          .select()
          .single();
      return Event.fromJson(response);
    } catch (e) {
      throw Exception('Error updating event: $e');
    }
  }

  // Delete event
  Future<void> deleteEvent(String eventId) async {
    final user = _supabase.currentUser;
    if (user == null) throw Exception('User must be authenticated to delete events');
    try {
      await _supabase.client
          .from('events')
          .delete()
          .eq('id', eventId);
    } catch (e) {
      throw Exception('Error deleting event: $e');
    }
  }

  // Create reservation
  Future<Reservation> createReservation({
    required String eventId,
  }) async {
    final user = _supabase.currentUser;
    if (user == null) throw Exception('User not authenticated');

    // Check if event has capacity by counting existing reservations
    final reservationsResponse = await _supabase.client
        .from('reservations')
        .select('id')
        .eq('event_id', eventId);
    
    final existingReservations = (reservationsResponse as List).length;
    
    final eventResponse = await _supabase.client
        .from('events')
        .select()
        .eq('id', eventId)
        .single();

    final event = Event.fromJson(eventResponse);
    if (existingReservations >= event.maxSeats) {
      throw Exception('Event is full');
    }

    // Create reservation
    final reservationResponse = await _supabase.client
        .from('reservations')
        .insert({
          'event_id': eventId,
          'user_id': user.id,
        })
        .select()
        .single();

    return Reservation.fromJson(reservationResponse);
  }

  // Get user reservations
  Future<List<Reservation>> getUserReservations() async {
    final user = _supabase.currentUser;
    if (user == null) throw Exception('User not authenticated');

    try {
      final response = await _supabase.client
          .from('reservations')
          .select()
          .eq('user_id', user.id)
          .order('created_at', ascending: false);

      final List<dynamic> data = response as List<dynamic>? ?? [];
      return data.map((json) => Reservation.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }
}
