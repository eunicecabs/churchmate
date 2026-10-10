import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../app/theme.dart';
import '../../../core/services/auth_service.dart';
import '../models/event_model.dart';

/// Create or edit an event. Pass an event id as the route argument to edit
/// an existing event; pass nothing to create a new one.
class EventFormScreen extends StatefulWidget {
  const EventFormScreen({super.key});

  @override
  State<EventFormScreen> createState() => _EventFormScreenState();
}

class _EventFormScreenState extends State<EventFormScreen> {
  final _db = FirebaseFirestore.instance;

  final _nameController = TextEditingController();
  final _placeController = TextEditingController();
  final _detailsController = TextEditingController();
  final _organizerController = TextEditingController();
  final _maxParticipantsController = TextEditingController();

  DateTime _date = DateTime.now();
  TimeOfDay _time = TimeOfDay.now();
  bool _attendanceRequired = false;

  String? _eventId; // null = creating a new event
  bool _loaded = false;
  bool _isSaving = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loaded) return;
    _loaded = true;
    final id = ModalRoute.of(context)?.settings.arguments as String?;
    if (id != null) {
      _eventId = id;
      _loadEvent(id);
    }
  }

  Future<void> _loadEvent(String id) async {
    final doc = await _db.collection('events').doc(id).get();
    if (!doc.exists || !mounted) return;
    final event = EventModel.fromMap(doc.id, doc.data()!);
    setState(() {
      _nameController.text = event.eventName;
      _placeController.text = event.place;
      _detailsController.text = event.details;
      _organizerController.text = event.organizer ?? '';
      _maxParticipantsController.text = event.maxParticipants?.toString() ?? '';
      _date = event.date;
      _attendanceRequired = event.attendanceRequired;
      final parts = event.time.isNotEmpty ? _parseTimeOfDay(event.time) : null;
      if (parts != null) _time = parts;
    });
  }

  TimeOfDay? _parseTimeOfDay(String display) {
    try {
      final parsed = DateFormat('h:mm a').parse(display);
      return TimeOfDay(hour: parsed.hour, minute: parsed.minute);
    } catch (_) {
      return null;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _placeController.dispose();
    _detailsController.dispose();
    _organizerController.dispose();
    _maxParticipantsController.dispose();
    super.dispose();
  }

  String get _formattedTime {
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, _time.hour, _time.minute);
    return DateFormat('h:mm a').format(dt);
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(context: context, initialTime: _time);
    if (picked != null) setState(() => _time = picked);
  }

  Future<void> _save() async {
    if (_nameController.text.trim().isEmpty ||
        _placeController.text.trim().isEmpty ||
        _detailsController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in event name, place, and details.')),
      );
      return;
    }

    final uid = context.read<AuthService>().currentUser?.id ?? '';
    setState(() => _isSaving = true);
    try {
      final data = EventModel(
        id: '',
        eventName: _nameController.text.trim(),
        place: _placeController.text.trim(),
        date: _date,
        time: _formattedTime,
        details: _detailsController.text.trim(),
        organizer: _organizerController.text.trim().isEmpty ? null : _organizerController.text.trim(),
        maxParticipants: int.tryParse(_maxParticipantsController.text.trim()),
        attendanceRequired: _attendanceRequired,
        createdBy: uid,
      ).toMap();

      if (_eventId != null) {
        // update() only touches the fields in `data`, so any old `imageUrl`
        // already stored on this event is left as-is (not deleted).
        await _db.collection('events').doc(_eventId!).update({
          ...data,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      } else {
        await _db.collection('events').add({
          ...data,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_eventId != null ? 'Event updated.' : 'Event created.')),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Could not save event. Please try again.')));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = _eventId != null;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text(isEditing ? 'Edit Event' : 'Create Event', style: AppTextStyles.headlineMd),
        iconTheme: const IconThemeData(color: AppColors.neutralDark),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.margin, vertical: AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Event Name *', style: AppTextStyles.labelMd),
              const SizedBox(height: 6),
              TextField(
                  controller: _nameController,
                  decoration: appInputDecoration(label: 'e.g. Youth Fellowship', icon: Icons.event_outlined)),
              const SizedBox(height: AppSpacing.sm),
              Text('Event Place *', style: AppTextStyles.labelMd),
              const SizedBox(height: 6),
              TextField(
                  controller: _placeController,
                  decoration: appInputDecoration(label: 'e.g. Main Sanctuary', icon: Icons.place_outlined)),
              const SizedBox(height: AppSpacing.sm),
              Row(children: [
                Expanded(
                  child: GestureDetector(
                    onTap: _pickDate,
                    child: InputDecorator(
                      decoration: appInputDecoration(label: 'Event Date *', icon: Icons.calendar_today_outlined),
                      child: Text(DateFormat('MMM d, yyyy').format(_date)),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: GestureDetector(
                    onTap: _pickTime,
                    child: InputDecorator(
                      decoration: appInputDecoration(label: 'Event Time *', icon: Icons.access_time),
                      child: Text(_formattedTime),
                    ),
                  ),
                ),
              ]),
              const SizedBox(height: AppSpacing.sm),
              Text('Event Details / Description *', style: AppTextStyles.labelMd),
              const SizedBox(height: 6),
              TextField(
                controller: _detailsController,
                maxLines: 4,
                decoration: appInputDecoration(label: 'What is this event about?'),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text('Organizer (optional)', style: AppTextStyles.labelMd),
              const SizedBox(height: 6),
              TextField(
                  controller: _organizerController,
                  decoration: appInputDecoration(label: 'e.g. Ptr. Caleb Cruz', icon: Icons.person_outline)),
              const SizedBox(height: AppSpacing.sm),
              Text('Maximum Participants (optional)', style: AppTextStyles.labelMd),
              const SizedBox(height: 6),
              TextField(
                  controller: _maxParticipantsController,
                  keyboardType: TextInputType.number,
                  decoration: appInputDecoration(label: 'e.g. 65', icon: Icons.groups_outlined)),
              const SizedBox(height: AppSpacing.sm),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text('Require QR Attendance Check-In', style: AppTextStyles.labelMd),
                value: _attendanceRequired,
                activeColor: AppColors.primary900,
                onChanged: (v) => setState(() => _attendanceRequired = v),
              ),
              const SizedBox(height: AppSpacing.lg),
              ElevatedButton.icon(
                onPressed: _isSaving ? null : _save,
                icon: _isSaving
                    ? const SizedBox(
                        width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.check),
                label: Text(isEditing ? 'Save Changes' : 'Create Event'),
                style: AppButtonStyles.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
