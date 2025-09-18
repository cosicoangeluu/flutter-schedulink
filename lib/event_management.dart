// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:schedulink_1/api_service.dart';
import 'package:schedulink_1/calendar_widget.dart';

class EventManagement extends StatefulWidget {
  const EventManagement({super.key});

  @override
  State<EventManagement> createState() => _EventManagementState();
}

class _EventManagementState extends State<EventManagement> {
  final TextEditingController _searchController = TextEditingController();
  DateTime? _selectedDate;
  final ApiService _apiService = ApiService();
  bool _isLoading = false;
  List<Map<String, dynamic>> _events = [];

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadEvents() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final events = await _apiService.getEvents();
      if (!mounted) return;
      setState(() {
        _events = events
            .where((event) => event['status'] == 'approved')
            .map((event) => {
                  'name': event['title'] ?? '',
                  'date': event['date'] != null
                      ? DateTime.parse(event['date'])
                      : DateTime.now(),
                  'venue': event['location'] ?? '',
                  'attendees': event['registered_count'] ?? 0,
                  'status': event['status'] ?? 'pending',
                })
            .toList();
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load events: $error')),
      );
    }
  }

  Future<String?> _getEventId(String eventName) async {
    try {
      final events = await _apiService.getEvents();
      final event = events.firstWhere(
        (e) => e['title'] == eventName,
        orElse: () => <String, dynamic>{},
      );
      return event['id']?.toString();
    } catch (e) {
      return null;
    }
  }

  final List<String> _venues = [
    'ERMC',
    'Gymnasium',
    'HRM Function Hall',
    'Sports and Recreational Hall',
  ];

  List<Map<String, dynamic>> get _filteredEvents {
    if (_searchController.text.isEmpty) {
      return _events;
    }
    return _events
        .where((event) =>
            event['name'].toLowerCase().contains(_searchController.text.toLowerCase()))
        .toList();
  }

  Future<void> _deleteEvent(int index) async {
    final event = _events[index];
    final eventId = await _getEventId(event['name']);
    if (eventId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to find event ID')),
      );
      return;
    }
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text('Are you sure you want to delete this event?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              try {
                await _apiService.deleteEvent(eventId);
                if (!mounted) return;
                setState(() {
                  _events.removeAt(index);
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Event deleted successfully')),
                );
              } catch (error) {
                if (!mounted) return;
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Failed to delete event: $error')),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showEventDialog({int? index}) {
    final isEdit = index != null;
    final event = isEdit ? _events[index] : null;
    final nameController = TextEditingController(text: isEdit ? event!['name'] : '');
    String? venue = isEdit ? event!['venue'] : null;
    DateTime date = isEdit ? event!['date'] : (_selectedDate ?? DateTime.now());

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          title: Text(isEdit ? 'Edit Event' : 'Add Event'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Event Name'),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: venue,
                decoration: const InputDecoration(labelText: 'Venue'),
                items: _venues
                    .map((v) => DropdownMenuItem(value: v, child: Text(v)))
                    .toList(),
                onChanged: (val) {
                  setStateDialog(() {
                    venue = val;
                  });
                },
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: date,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2101),
                  );
                  if (picked != null) {
                    setStateDialog(() {
                      date = picked;
                    });
                  }
                },
                child: Text('Select Date: ${date.day}/${date.month}/${date.year}'),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.isEmpty || venue == null) {
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please fill all fields')));
                  return;
                }

                // Update outer state loading indicator
                setState(() {
                  _isLoading = true;
                });

                try {
                  if (isEdit) {
                    final eventId = await _getEventId(event!['name']);
                    if (eventId == null) {
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Failed to find event ID')),
                      );
                      return;
                    }

                    await _apiService.updateEvent(eventId, {
                      'title': nameController.text,
                      'description': '',
                      'date':
                          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}',
                      'time': '',
                      'location': venue,
                      'capacity': 0,
                      'status': _events[index!]['status'], // preserve current status
                    });

                    if (!mounted) return;
                    setState(() {
                      _events[index!] = {
                        'name': nameController.text,
                        'date': date,
                        'venue': venue,
                        'attendees': _events[index!]['attendees'],
                        'status': _events[index!]['status'],
                      };
                      _isLoading = false;
                    });

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Event updated successfully')),
                    );
                  } else {
                    final eventResponse = await _apiService.createEvent({
                      'title': nameController.text,
                      'description': '',
                      'date':
                          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}',
                      'time': '',
                      'location': venue,
                      'capacity': 0,
                      'organizer_id': null,
                      'status': 'pending',
                    });
                    final eventId = eventResponse['id'];

                    await _apiService.createNotification({
                      'event_id': eventId,
                      'message':
                          'New event "${nameController.text}" requires approval',
                      'status': 'pending',
                    });

                    if (!mounted) return;
                    setState(() {
                      _isLoading = false;
                    });

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Event submitted for approval')),
                    );
                  }
                  Navigator.pop(context);
                } catch (error) {
                  if (!mounted) return;
                  setState(() {
                    _isLoading = false;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text('Failed to ${isEdit ? 'update' : 'add'} event: $error')),
                  );
                }
              },
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(isEdit ? 'Update' : 'Add'),
            ),
          ],
        ),
      ),
    );
  }

  void _editEvent(int index) {
    _showEventDialog(index: index);
  }

  Map<DateTime, List<String>> _getEventsMap() {
    final Map<DateTime, List<String>> eventsMap = {};
    for (final event in _events) {
      final date = DateTime(event['date'].year, event['date'].month, event['date'].day);
      if (eventsMap.containsKey(date)) {
        eventsMap[date]!.add(event['name']);
      } else {
        eventsMap[date] = [event['name']];
      }
    }
    return eventsMap;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Event Management'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              ElevatedButton(
                onPressed: () => _showEventDialog(),
                child: const Text('Add Event'),
              ),
              const SizedBox(height: 16),
              // Search Section
              TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  labelText: 'Search events...',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  setState(() {});
                },
              ),
              const SizedBox(height: 16),
              // Separate Calendar Card
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SizedBox(
                    height: 300,
                    child: CalendarWidget(
                      initialDate: _selectedDate,
                      onDateSelected: (date) {
                        setState(() {
                          _selectedDate = date;
                        });
                      },
                      events: _getEventsMap(),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Event Cards Grid
              LayoutBuilder(
                builder: (context, constraints) {
                  int crossAxisCount = constraints.maxWidth > 600
                      ? 3
                      : (constraints.maxWidth > 400 ? 2 : 1);
                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _filteredEvents.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 3 / 2,
                    ),
                    itemBuilder: (context, index) {
                      final event = _filteredEvents[index];
                      int originalIndex = _events.indexOf(event);
                      Color statusColor;
                      switch (event['status']) {
                        case 'approved':
                          statusColor = Colors.green[100]!;
                          break;
                        case 'pending':
                          statusColor = Colors.yellow[100]!;
                          break;
                        case 'declined':
                          statusColor = Colors.red[100]!;
                          break;
                        default:
                          statusColor = Colors.grey[200]!;
                      }
                      return Card(
                        elevation: 2,
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(event['name'],
                                  style:
                                      const TextStyle(fontWeight: FontWeight.bold)),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.calendar_today,
                                      size: 16, color: Colors.grey),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${event['date'].day.toString().padLeft(2, '0')}/${event['date'].month.toString().padLeft(2, '0')}/${event['date'].year}',
                                    style: const TextStyle(color: Colors.grey),
                                  ),
                                  const SizedBox(width: 16),
                                  const Icon(Icons.location_on,
                                      size: 16, color: Colors.grey),
                                  const SizedBox(width: 4),
                                  Text(event['venue'],
                                      style: const TextStyle(color: Colors.grey)),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.person, size: 16, color: Colors.grey),
                                  const SizedBox(width: 4),
                                  Text('${event['attendees']} attendees',
                                      style: const TextStyle(color: Colors.grey)),
                                  const Spacer(),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: statusColor,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      event['status'],
                                      style: TextStyle(
                                        color: event['status'] == 'approved'
                                            ? Colors.green[800]
                                            : Colors.black87,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const Spacer(),
                              Row(
                                children: [
                                  TextButton(
                                    onPressed: () => _editEvent(originalIndex),
                                    child: const Text('Edit'),
                                  ),
                                  const SizedBox(width: 8),
                                  ElevatedButton(
                                    onPressed: () => _deleteEvent(originalIndex),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          const Color.fromARGB(255, 192, 43, 32),
                                      ),
                                    child: const Text('Delete'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}