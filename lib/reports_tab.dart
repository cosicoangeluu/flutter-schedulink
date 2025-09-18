import 'package:flutter/material.dart';

class ReportsPage extends StatelessWidget {
  const ReportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Page Header
          const Text(
            'Event Attendance Reports',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Track attendance and engagement for your events',
            style: TextStyle(fontSize: 16, color: Colors.black54),
          ),
          const SizedBox(height: 24),
          // Event Reports Grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.2,
            ),
            itemCount: _sampleEvents.length,
            itemBuilder: (context, index) {
              final event = _sampleEvents[index];
              return _buildEventReportCard(event);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEventReportCard(Map<String, dynamic> event) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Event Name
            Text(
              event['name'],
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            // Event Date
            Text(
              event['date'],
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const Spacer(),
            // Attendees Count
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event['attendees'].toString(),
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        // Handle attendees link tap
                      },
                      child: const Text(
                        'Attendees',
                        style: TextStyle(
                          color: Colors.blue,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
                Icon(
                  Icons.people,
                  color: Colors.blue[200],
                  size: 40,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Sample data for demonstration
  static const List<Map<String, dynamic>> _sampleEvents = [
    {
      'name': 'Tech Conference 2024',
      'date': 'March 15, 2024',
      'attendees': 245,
    },
    {
      'name': 'Digital Marketing Summit',
      'date': 'March 18, 2024',
      'attendees': 189,
    },
    {
      'name': 'Leadership Workshop',
      'date': 'March 22, 2024',
      'attendees': 156,
    },
    {
      'name': 'Product Launch Webinar',
      'date': 'March 25, 2024',
      'attendees': 312,
    },
    {
      'name': 'Startup Pitch Competition',
      'date': 'March 28, 2024',
      'attendees': 98,
    },
    {
      'name': 'Customer Success Training',
      'date': 'April 2, 2024',
      'attendees': 167,
    },
  ];
}
