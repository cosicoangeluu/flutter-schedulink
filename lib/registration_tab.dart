import 'package:flutter/material.dart';

import 'api_service.dart';

class RegistrationsPage extends StatefulWidget {
  const RegistrationsPage({super.key});

  @override
  State<RegistrationsPage> createState() => _RegistrationsPageState();
}

class _RegistrationsPageState extends State<RegistrationsPage> {
  final ApiService _apiService = ApiService();
  final TextEditingController _searchController = TextEditingController();

  List<String> _events = [];
  List<String> _courses = ['BSBA', 'BSN', 'CITHM', 'BsCOE', 'BSCS', 'CTELA'];
  Map<String, List<Participant>> _eventParticipants = {};
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      await _loadEvents();
      await _loadRegistrations();
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load data: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadEvents() async {
    final events = await _apiService.getEvents();
    final eventTitles = events.map((e) => e['title'] as String).toList();
    setState(() {
      _events = eventTitles;
      _eventParticipants = {for (final title in eventTitles) title: []};
    });
  }

  Future<void> _loadRegistrations() async {
    final registrations = await _apiService.getRegistrations();
    final Map<String, List<Participant>> participants = {};
    for (final reg in registrations) {
      final eventTitle = reg['event_title'] ?? 'Unknown Event';
      final participant = Participant(
        id: reg['id'].toString(),
        name: reg['participant_name'] ?? '',
        studentId: reg['student_id'] ?? '',
        email: reg['email'] ?? '',
        phone: reg['phone'] ?? '',
        course: reg['organization'] ?? '',
      );
      participants.putIfAbsent(eventTitle, () => []).add(participant);
    }
    setState(() {
      _eventParticipants = participants;
    });
  }

  Future<void> _addParticipant(Map<String, dynamic> data) async {
    try {
      await _apiService.registerParticipant(data);
      await _loadRegistrations(); // Refresh list
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Participant added successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add participant: $e')),
        );
      }
    }
  }

  Future<void> _deleteParticipant(String id) async {
    try {
      await _apiService.deleteRegistration(id);
      await _loadRegistrations(); // Refresh list
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Participant deleted')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete participant: $e')),
        );
      }
    }
  }

  void _showAddParticipantDialog() {
    showDialog(
      context: context,
      builder: (_) => AddParticipantDialog(
        events: _events,
        courses: _courses,
        onSubmit: _addParticipant,
      ),
    );
  }

  void _showCourseSettingsDialog() {
    showDialog(
      context: context,
      builder: (_) => CourseSettingsDialog(
        courses: _courses,
        onCoursesChanged: (updated) => setState(() => _courses = updated),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_errorMessage!),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadData,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    final filteredEvents = _events.where((event) {
      final search = _searchController.text.toLowerCase();
      final eventMatches = event.toLowerCase().contains(search);
      final participants = _eventParticipants[event] ?? [];
      final participantMatches = participants.any((p) =>
          p.name.toLowerCase().contains(search) ||
          p.studentId.toLowerCase().contains(search) ||
          p.course.toLowerCase().contains(search));
      return eventMatches || participantMatches;
    }).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Event Registrations')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      labelText: 'Search events or participants',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text('Add'),
                  onPressed: _showAddParticipantDialog,
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  icon: const Icon(Icons.settings),
                  label: const Text('Courses'),
                  onPressed: _showCourseSettingsDialog,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: filteredEvents.isEmpty
                  ? const Center(child: Text('No matches found'))
                  : ListView(
                      children: filteredEvents.map((event) {
                        final participants = _eventParticipants[event] ?? [];
                        return EventCard(
                          eventTitle: event,
                          participants: participants,
                          onDelete: _deleteParticipant,
                        );
                      }).toList(),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class Participant {
  final String id;
  final String name;
  final String studentId;
  final String email;
  final String phone;
  final String course;

  const Participant({
    required this.id,
    required this.name,
    required this.studentId,
    required this.email,
    required this.phone,
    required this.course,
  });
}

class EventCard extends StatelessWidget {
  final String eventTitle;
  final List<Participant> participants;
  final ValueChanged<String> onDelete;

  const EventCard({
    super.key,
    required this.eventTitle,
    required this.participants,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ExpansionTile(
        title: Text(eventTitle, style: const TextStyle(fontWeight: FontWeight.bold)),
        children: participants.isEmpty
            ? [const ListTile(title: Text('No participants'))]
            : participants.map((p) => ListTile(
                title: Text(p.name),
                subtitle: Text('ID: ${p.studentId} | Course: ${p.course}'),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => onDelete(p.id),
                ),
              )).toList(),
      ),
    );
  }
}

class AddParticipantDialog extends StatefulWidget {
  final List<String> events;
  final List<String> courses;
  final ValueChanged<Map<String, dynamic>> onSubmit;

  const AddParticipantDialog({
    super.key,
    required this.events,
    required this.courses,
    required this.onSubmit,
  });

  @override
  State<AddParticipantDialog> createState() => _AddParticipantDialogState();
}

class _AddParticipantDialogState extends State<AddParticipantDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _studentIdController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  String? _selectedEvent;
  String? _selectedCourse;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _studentIdController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate() || _selectedEvent == null || _selectedCourse == null) return;

    setState(() => _isSubmitting = true);
    final data = {
      'event_title': _selectedEvent!,
      'participant_name': _nameController.text,
      'student_id': _studentIdController.text,
      'email': _emailController.text,
      'phone': _phoneController.text,
      'organization': _selectedCourse!,
    };
    widget.onSubmit(data);
    Navigator.of(context).pop();
    setState(() => _isSubmitting = false);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Participant'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: _studentIdController,
                decoration: const InputDecoration(labelText: 'Student ID'),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Phone'),
              ),
              DropdownButtonFormField<String>(
                value: _selectedCourse,
                decoration: const InputDecoration(labelText: 'Course'),
                items: widget.courses.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (v) => setState(() => _selectedCourse = v),
                validator: (v) => v == null ? 'Required' : null,
              ),
              DropdownButtonFormField<String>(
                value: _selectedEvent,
                decoration: const InputDecoration(labelText: 'Event'),
                items: widget.events.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                onChanged: (v) => setState(() => _selectedEvent = v),
                validator: (v) => v == null ? 'Required' : null,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
        ElevatedButton(
          onPressed: _isSubmitting ? null : _submit,
          child: _isSubmitting ? const CircularProgressIndicator() : const Text('Add'),
        ),
      ],
    );
  }
}

class CourseSettingsDialog extends StatefulWidget {
  final List<String> courses;
  final ValueChanged<List<String>> onCoursesChanged;

  const CourseSettingsDialog({
    super.key,
    required this.courses,
    required this.onCoursesChanged,
  });

  @override
  State<CourseSettingsDialog> createState() => _CourseSettingsDialogState();
}

class _CourseSettingsDialogState extends State<CourseSettingsDialog> {
  late List<String> _courses;
  final _newCourseController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _courses = List.from(widget.courses);
  }

  @override
  void dispose() {
    _newCourseController.dispose();
    super.dispose();
  }

  void _addCourse() {
    final course = _newCourseController.text.trim();
    if (course.isNotEmpty && !_courses.contains(course)) {
      setState(() => _courses.add(course));
      _newCourseController.clear();
    }
  }

  void _removeCourse(String course) {
    setState(() => _courses.remove(course));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Manage Courses'),
      content: SizedBox(
        width: double.maxFinite,
        height: 300,
        child: Column(
          children: [
            TextField(
              controller: _newCourseController,
              decoration: InputDecoration(
                labelText: 'New Course',
                suffixIcon: IconButton(icon: const Icon(Icons.add), onPressed: _addCourse),
              ),
              onSubmitted: (_) => _addCourse(),
            ),
            Expanded(
              child: ListView(
                children: _courses.map((c) => ListTile(
                  title: Text(c),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _removeCourse(c),
                  ),
                )).toList(),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
        ElevatedButton(
          onPressed: () {
            widget.onCoursesChanged(_courses);
            Navigator.of(context).pop();
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
