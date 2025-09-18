// ignore_for_file: library_private_types_in_public_api, deprecated_member_use, prefer_final_fields, unused_element

import 'package:flutter/material.dart';

import 'api_service.dart';

class RegistrationsPage extends StatefulWidget {
  const RegistrationsPage({super.key});

  @override
  _RegistrationsPageState createState() => _RegistrationsPageState();
}

class _RegistrationsPageState extends State<RegistrationsPage> {
  final ApiService _apiService = ApiService();

  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _studentIdController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  String? _selectedEvent;
  String? _selectedCourse;

  List<String> _events = [];
  List<String> _courses = [];

  Map<String, List<Participant>> _eventParticipants = {};

  @override
  void initState() {
    super.initState();
    _loadEvents();
    _loadCourses();
    _loadRegistrations();
  }

  Future<void> _loadEvents() async {
    try {
      final events = await _apiService.getEvents();
      setState(() {
        _events = events.map<String>((e) => e['title'] as String).toList();
        // Initialize empty participant lists for each event
        _eventParticipants = {for (var event in _events) event: []};
      });
    } catch (e) {
      // Handle error
    }
  }

  Future<void> _loadCourses() async {
    // Assuming courses are static or fetched from backend if available
    setState(() {
      _courses = [
        'BSBA',
        'BSN',
        'CITHM',
        'BsCOE',
        'BSCS',
        'CTELA',
      ];
    });
  }

  Future<void> _loadRegistrations() async {
    try {
      final registrations = await _apiService.getRegistrations();
      Map<String, List<Participant>> participantsMap = {};
      for (var reg in registrations) {
        final eventTitle = reg['event_title'] ?? 'Unknown Event';
        final participant = Participant(
          id: reg['id'].toString(),
          name: reg['participant_name'] ?? '',
          studentId: '', // No studentId in backend, can be added if needed
          email: reg['email'] ?? '',
          phone: reg['phone'] ?? '',
          course: '', // No course info in backend, can be added if needed
        );
        participantsMap.putIfAbsent(eventTitle, () => []).add(participant);
      }
      setState(() {
        _eventParticipants = participantsMap;
      });
    } catch (e) {
      // Handle error
    }
  }

  Future<String?> _getEventId(String eventTitle) async {
    try {
      final events = await _apiService.getEvents();
      final event = events.firstWhere(
        (e) => e['title'] == eventTitle,
        orElse: () => null,
      );
      return event?['id']?.toString();
    } catch (e) {
      return null;
    }
  }

  Future<void> _addParticipant() async {
    if (_nameController.text.isEmpty ||
        _studentIdController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _phoneController.text.isEmpty ||
        _selectedEvent == null ||
        _selectedCourse == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    try {
      // Get event ID from event title
      final eventId = await _getEventId(_selectedEvent!);
      if (eventId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to find event')),
        );
        return;
      }

      // Prepare participant data for API
      final participantData = {
        'event_id': int.parse(eventId),
        'participant_name': _nameController.text,
        'email': _emailController.text,
        'phone': _phoneController.text,
        'organization': _selectedCourse, // Map course to organization field
      };

      // Call API to register participant
      final result = await _apiService.registerParticipant(participantData);

      // Create participant object for local state
      final participant = Participant(
        id: result['id'].toString(),
        name: _nameController.text,
        studentId: _studentIdController.text,
        email: _emailController.text,
        phone: _phoneController.text,
        course: _selectedCourse!,
      );

      setState(() {
        _eventParticipants[_selectedEvent!]!.add(participant);
        _clearForm();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Participant added successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add participant: $e')),
      );
    }
  }

  void _clearForm() {
    _nameController.clear();
    _studentIdController.clear();
    _emailController.clear();
    _phoneController.clear();
    _selectedEvent = null;
    _selectedCourse = null;
  }

  Future<void> _deleteParticipant(String id) async {
    try {
      await _apiService.deleteRegistration(id);
      _loadRegistrations(); // Reload after delete
    } catch (e) {
      // Handle error
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _nameController.dispose();
    _studentIdController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Event Participants'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Add Participant and Settings buttons above search
            Row(
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text('Add Participant'),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AddParticipantDialog(
                        events: _events,
                        courses: _courses,
                        apiService: _apiService,
                      ),
                    ).then((_) {
                      // Reload registrations after dialog closes
                      _loadRegistrations();
                    });
                  },
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  icon: const Icon(Icons.settings),
                  label: const Text('Settings'),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => CourseSettingsDialog(
                        courses: _courses,
                        onCoursesChanged: (updatedCourses) {
                          setState(() {
                            _courses = updatedCourses;
                          });
                        },
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Search bar for event and participant
            TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Search events or participants...',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                setState(() {});
              },
            ),
            const SizedBox(height: 16),
            // Event cards with checklist for all events
            Expanded(
              child: ListView(
                children: _events.map((event) {
                  final participants = (_eventParticipants[event] ?? [])
                      .where((p) => p.name.toLowerCase().contains(_searchController.text.toLowerCase()))
                      .toList();
                  return EventCard(
                    eventName: event,
                    participants: participants,
                    onToggle: (participant, isChecked) {
                      setState(() {
                        participant.isChecked = isChecked;
                      });
                    },
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
  bool isChecked;

  Participant({
    required this.id,
    required this.name,
    required this.studentId,
    required this.email,
    required this.phone,
    required this.course,
    this.isChecked = false,
  });
}

class EventCard extends StatelessWidget {
  final String eventName;
  final List<Participant> participants;
  final Function(Participant, bool) onToggle;

  const EventCard({
    super.key,
    required this.eventName,
    required this.participants,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ExpansionTile(
        title: Text(eventName, style: const TextStyle(fontWeight: FontWeight.bold)),
        children: participants.isEmpty
            ? [
                const ListTile(
                  title: Text('No participants registered'),
                )
              ]
            : participants
                .map(
                  (p) => CheckboxListTile(
                    title: Text(p.name),
                    subtitle: Text('ID: ${p.studentId} | Course: ${p.course}'),
                    value: p.isChecked,
                    onChanged: (value) {
                      onToggle(p, value ?? false);
                    },
                  ),
                )
                .toList(),
      ),
    );
  }
}

class AddParticipantDialog extends StatefulWidget {
  final List<String> events;
  final List<String> courses;
  final ApiService apiService;

  const AddParticipantDialog({
    super.key,
    required this.events,
    required this.courses,
    required this.apiService,
  });

  @override
  _AddParticipantDialogState createState() => _AddParticipantDialogState();
}

class _AddParticipantDialogState extends State<AddParticipantDialog> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _studentIdController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  String? _selectedEvent;
  String? _selectedCourse;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _studentIdController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<String?> _getEventId(String eventTitle) async {
    try {
      final events = await widget.apiService.getEvents();
      final event = events.firstWhere(
        (e) => e['title'] == eventTitle,
        orElse: () => null,
      );
      return event?['id']?.toString();
    } catch (e) {
      return null;
    }
  }

  Future<void> _submit() async {
    if (_formKey.currentState?.validate() != true) return;
    if (_selectedEvent == null || _selectedCourse == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Get event ID from event title
      final eventId = await _getEventId(_selectedEvent!);
      if (eventId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to find event')),
        );
        return;
      }

      // Prepare participant data for API
      final participantData = {
        'event_id': int.parse(eventId),
        'participant_name': _nameController.text,
        'email': _emailController.text,
        'phone': _phoneController.text,
        'organization': _selectedCourse, // Map course to organization field
      };

      // Call API to register participant
      await widget.apiService.registerParticipant(participantData);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Participant added successfully')),
      );

      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add participant: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add New Participant'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) => value == null || value.isEmpty ? 'Enter full name' : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _studentIdController,
                decoration: const InputDecoration(
                  labelText: 'Student ID',
                  prefixIcon: Icon(Icons.badge),
                ),
                validator: (value) => value == null || value.isEmpty ? 'Enter student ID' : null,
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedCourse,
                decoration: const InputDecoration(
                  labelText: 'Select Course',
                  prefixIcon: Icon(Icons.book),
                ),
                items: widget.courses
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCourse = value;
                  });
                },
                validator: (value) => value == null ? 'Select a course' : null,
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedEvent,
                decoration: const InputDecoration(
                  labelText: 'Select Event',
                  prefixIcon: Icon(Icons.event),
                ),
                items: widget.events
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedEvent = value;
                  });
                },
                validator: (value) => value == null ? 'Select an event' : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email),
                ),
                validator: (value) => value == null || value.isEmpty ? 'Enter email' : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  prefixIcon: Icon(Icons.phone),
                ),
                validator: (value) => value == null || value.isEmpty ? 'Enter phone number' : null,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _submit,
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Add Participant'),
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
  _CourseSettingsDialogState createState() => _CourseSettingsDialogState();
}

class _CourseSettingsDialogState extends State<CourseSettingsDialog> {
  late List<String> _editableCourses;
  final TextEditingController _newCourseController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _editableCourses = List.from(widget.courses);
  }

  @override
  void dispose() {
    _newCourseController.dispose();
    super.dispose();
  }

  void _addCourse() {
    final newCourse = _newCourseController.text.trim();
    if (newCourse.isNotEmpty && !_editableCourses.contains(newCourse)) {
      setState(() {
        _editableCourses.add(newCourse);
        _newCourseController.clear();
      });
    }
  }

  void _removeCourse(String course) {
    setState(() {
      _editableCourses.remove(course);
    });
  }

  void _save() {
    widget.onCoursesChanged(_editableCourses);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Manage Courses'),
      content: SizedBox(
        width: double.maxFinite,
        height: 300,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _newCourseController,
              decoration: InputDecoration(
                labelText: 'New Course',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: _addCourse,
                ),
              ),
              onSubmitted: (_) => _addCourse(),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: _editableCourses.length,
                itemBuilder: (context, index) {
                  final course = _editableCourses[index];
                  return ListTile(
                    title: Text(course),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _removeCourse(course),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _save,
          child: const Text('Save'),
        ),
      ],
    );
  }
}


  