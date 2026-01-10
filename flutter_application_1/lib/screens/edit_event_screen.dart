import 'package:flutter/material.dart';
import '../models/event.dart';
import '../services/event_service.dart';

class EditEventScreen extends StatefulWidget {
  final Event event;
  const EditEventScreen({super.key, required this.event});

  @override
  State<EditEventScreen> createState() => _EditEventScreenState();
}

class _EditEventScreenState extends State<EditEventScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _title;
  late String _description;
  late DateTime _eventDate;
  late int _maxSeats;
  bool _isSaving = false;
  final EventService _eventService = EventService();

  @override
  void initState() {
    super.initState();
    _title = widget.event.title;
    _description = widget.event.description;
    _eventDate = widget.event.eventDate;
    _maxSeats = widget.event.maxSeats;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();
    setState(() => _isSaving = true);
    try {
      final updated = await _eventService.updateEvent(
        eventId: widget.event.id,
        title: _title,
        description: _description,
        eventDate: _eventDate,
        maxSeats: _maxSeats,
      );
      if (mounted) {
        Navigator.pop(context, updated);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating event: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      backgroundColor: primaryColor.withOpacity(0.08),
      appBar: AppBar(title: const Text('Edit Event')),
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
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                TextFormField(
                  initialValue: _title,
                  decoration: const InputDecoration(labelText: 'Title'),
                  validator: (v) => v == null || v.isEmpty ? 'Enter title' : null,
                  onSaved: (v) => _title = v!,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  initialValue: _description,
                  decoration: const InputDecoration(labelText: 'Description'),
                  maxLines: 3,
                  validator: (v) => v == null || v.isEmpty ? 'Enter description' : null,
                  onSaved: (v) => _description = v!,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  initialValue: _maxSeats.toString(),
                  decoration: const InputDecoration(labelText: 'Max Seats'),
                  keyboardType: TextInputType.number,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Enter max seats';
                    final n = int.tryParse(v);
                    if (n == null || n < 1) return 'Enter a valid number';
                    return null;
                  },
                  onSaved: (v) => _maxSeats = int.parse(v!),
                ),
                const SizedBox(height: 16),
                ListTile(
                  title: Text('Event Date: ${_eventDate.toLocal().toString().split(' ')[0]}'),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _eventDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) setState(() => _eventDate = picked);
                  },
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _isSaving ? null : _save,
                  child: _isSaving
                      ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator())
                      : const Text('Save Changes'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
