import 'package:flutter/material.dart';
import '../../services/event_service.dart';

class ManageEventsScreen extends StatefulWidget {
  const ManageEventsScreen({super.key});

  @override
  State<ManageEventsScreen> createState() => _ManageEventsScreenState();
}

class _ManageEventsScreenState extends State<ManageEventsScreen> {
  final EventService _eventService = EventService();
  
  List<Map<String, dynamic>> _events = [];
  bool _isLoading = true;
  String? _errorMessage;

  // DESIGN CONSTANTS
  static const Color primarySage = Color(0xFFACBDAA);
  static const Color bgGrey = Color(0xFFFAFAFA);

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  // ==========================================
  // 1. READ
  // ==========================================
  Future<void> _loadEvents() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final events = await _eventService.getAllEvents();
      if (mounted) setState(() => _events = events);
    } catch (e) {
      if (mounted) setState(() => _errorMessage = 'Error loading events: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ==========================================
  // 2. CREATE & UPDATE (FIXED)
  // ==========================================
  Future<void> _showEventDialog({Map<String, dynamic>? event}) async {
    final isEditing = event != null;
    
    // Controllers
    final titleController = TextEditingController(text: event?['title'] ?? '');
    final descController = TextEditingController(text: event?['description'] ?? '');
    final seatsController = TextEditingController(text: event?['max_seats']?.toString() ?? '0');
    
    // Date Setup
    String selectedDate = event?['event_date'] ?? DateTime.now().toIso8601String();
    final dateController = TextEditingController(text: selectedDate.split('T')[0]);

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          isEditing ? "Edit Event" : "Add New Event",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildStyledTextField(titleController, "Event Title", Icons.title),
              const SizedBox(height: 12),
              _buildStyledTextField(descController, "Description", Icons.description_outlined),
              const SizedBox(height: 12),
              _buildStyledTextField(seatsController, "Max Seats", Icons.chair_alt, isNumber: true),
              const SizedBox(height: 12),
              // Date Picker
              TextField(
                controller: dateController,
                readOnly: true,
                onTap: () async {
                  DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.tryParse(selectedDate) ?? DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                    builder: (context, child) {
                      return Theme(
                        data: Theme.of(context).copyWith(
                          colorScheme: const ColorScheme.light(primary: primarySage),
                        ),
                        child: child!,
                      );
                    },
                  );
                  if (picked != null) {
                    selectedDate = picked.toIso8601String();
                    dateController.text = "${picked.year}-${picked.month}-${picked.day}";
                  }
                },
                decoration: _inputStyle("Event Date", Icons.calendar_today),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: primarySage,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () async {
              try {
                // Parse seats safely
                int seats = int.tryParse(seatsController.text) ?? 0;

                if (isEditing) {
                  await _eventService.updateEvent(
                    eventId: event['id'],
                    title: titleController.text,
                    description: descController.text,
                    date: selectedDate,
                    maxSeats: seats,
                  );
                } else {
                  // --- FIX IS HERE: Added the 4th argument (seats) ---
                  await _eventService.createEvent(
                    titleController.text,
                    descController.text,
                    selectedDate,
                    seats, 
                  );
                }
                
                if (context.mounted) {
                  Navigator.pop(context);
                  _loadEvents(); 
                }
              } catch (e) {
                print("Error saving event: $e");
              }
            },
            child: Text(isEditing ? "Save" : "Add", style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // 3. DELETE
  // ==========================================
  Future<void> _deleteEvent(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Delete Event?", style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text("This action cannot be undone."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Delete", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _eventService.deleteEvent(id);
      _loadEvents();
    }
  }

  // ==========================================
  // UI HELPERS
  // ==========================================
  InputDecoration _inputStyle(String hint, IconData icon) {
    return InputDecoration(
      labelText: hint,
      labelStyle: const TextStyle(fontSize: 14, color: Colors.grey),
      prefixIcon: Icon(icon, color: primarySage, size: 20),
      filled: true,
      fillColor: Colors.grey[50],
      contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: primarySage, width: 1.5),
      ),
    );
  }

  Widget _buildStyledTextField(TextEditingController controller, String label, IconData icon, {bool isNumber = false}) {
    return TextField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      decoration: _inputStyle(label, icon),
    );
  }

  // ==========================================
  // MAIN BUILD
  // ==========================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Manage Events', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: primarySage),
      ),
      
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showEventDialog(),
        backgroundColor: primarySage,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: primarySage))
          : _errorMessage != null
              ? Center(child: Text(_errorMessage!, style: const TextStyle(color: Colors.red)))
              : _events.isEmpty
                  ? const Center(child: Text("No events found.", style: TextStyle(color: Colors.grey)))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _events.length,
                      itemBuilder: (context, index) {
                        final event = _events[index];
                        final id = event['id'];
                        final title = event['title'] ?? 'Untitled';
                        final description = event['description'] ?? '';
                        final rawDate = event['event_date'];
                        final displayDate = rawDate != null 
                            ? DateTime.parse(rawDate).toString().split(' ')[0] 
                            : 'No Date';

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            leading: Container(
                              height: 45,
                              width: 45,
                              decoration: BoxDecoration(
                                color: primarySage.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.event_note, color: primarySage),
                            ),
                            title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (description.isNotEmpty)
                                  Text(description, maxLines: 1, overflow: TextOverflow.ellipsis),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(Icons.calendar_today, size: 12, color: primarySage),
                                    const SizedBox(width: 4),
                                    Text(displayDate, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                                  ],
                                )
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit_outlined, color: Colors.grey),
                                  onPressed: () => _showEventDialog(event: event),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                                  onPressed: () => _deleteEvent(id),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
    );
  }
}