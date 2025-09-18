import 'package:flutter/material.dart';

class CalendarWidget extends StatefulWidget {
  final Function(DateTime)? onDateSelected;
  final DateTime? initialDate;
  final Map<DateTime, List<String>>? events;

  const CalendarWidget({super.key, this.onDateSelected, this.initialDate, this.events});

  @override
  State<CalendarWidget> createState() => _CalendarWidgetState();
}

class _CalendarWidgetState extends State<CalendarWidget> {
  late DateTime _selectedDate;

  // Sample events data: Map of DateTime (date only) to list of event titles
  Map<DateTime, List<String>> get _events => widget.events ?? {
    DateTime(2024, 3, 15): ['Digital Marketing Summit 2024'],
    DateTime(2024, 3, 18): ['Leadership Workshop Series'],
    DateTime(2024, 3, 22): ['Product Launch Webinar'],
    DateTime(2024, 3, 25): ['Customer Success Training'],
  };

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate ?? DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CalendarDatePicker(
          initialDate: _selectedDate,
          firstDate: DateTime(2023, 1, 1),
          lastDate: DateTime(2025, 12, 31),
          onDateChanged: (date) {
            setState(() {
              _selectedDate = date;
            });
            if (widget.onDateSelected != null) {
              widget.onDateSelected!(date);
            }
          },
        ),
        const SizedBox(height: 8),
        Expanded(
          child: _buildEventsForSelectedDate(),
        ),
      ],
    );
  }

  Widget _buildEventsForSelectedDate() {
    final events = _events[_selectedDate] ?? [];
    if (events.isEmpty) {
      return const Center(child: Text('No events on this day.'));
    }
    return ListView.builder(
      itemCount: events.length,
      itemBuilder: (context, index) {
        return ListTile(
          leading: const Icon(Icons.event),
          title: Text(events[index]),
        );
      },
    );
  }
}
