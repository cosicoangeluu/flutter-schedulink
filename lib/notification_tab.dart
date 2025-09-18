// ignore_for_file: library_private_types_in_public_api, prefer_final_fields, unused_element

import 'package:flutter/material.dart';
import 'package:schedulink_1/api_service.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  _NotificationsPageState createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  String _selectedStatus = 'All Status';
  late TabController _tabController;
  final ApiService _apiService = ApiService();
  bool _isLoading = false;
  List<Map<String, dynamic>> _notifications = [];
  List<Map<String, dynamic>> _events = [];

  @override

  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final notifications = await _apiService.getNotifications();
      final events = await _apiService.getEvents();
      if (!mounted) return;
      setState(() {
        _notifications = notifications.map((n) => {
          'id': n['id'],
          'event_id': n['event_id'],
          'message': n['message'],
          'status': n['status'],
          'created_at': DateTime.parse(n['created_at']),
        }).toList();
        _events = events.map((e) => {
          'id': e['id'],
          'title': e['title'],
          'date': e['date'],
          'location': e['location'],
          'status': e['status'],
        }).toList();
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load data: $error')),
      );
    }
  }

  Map<String, int> get _statusCounts {
    final Map<String, int> counts = {'pending': 0, 'approved': 0, 'declined': 0};
    for (var notification in _notifications) {
      final status = notification['status'] as String;
      if (counts.containsKey(status)) {
        counts[status] = counts[status]! + 1;
      }
    }
    return counts;
  }

  List<Map<String, dynamic>> get _filteredNotifications {
    return _notifications.where((notification) {
      final searchText = _searchController.text.toLowerCase();
      final statusFilter = _selectedStatus.toLowerCase();
      final matchesSearch = notification['message'].toLowerCase().contains(searchText);
      final matchesStatus = statusFilter == 'all status' || notification['status'] == statusFilter;
      return matchesSearch && matchesStatus;
    }).toList();
  }

  List<Map<String, dynamic>> get _deletedNotifications {
    return _notifications.where((notification) => notification['status'] == 'declined').toList();
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.yellow.shade100;
      case 'approved':
        return Colors.green.shade100;
      case 'declined':
        return Colors.red.shade100;
      default:
        return Colors.grey.shade100;
    }
  }

  Color _statusTextColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.yellow.shade800;
      case 'approved':
        return Colors.green.shade800;
      case 'declined':
        return Colors.red.shade800;
      default:
        return Colors.grey.shade800;
    }
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case 'pending':
        return Icons.access_time;
      case 'approved':
        return Icons.check_circle;
      case 'declined':
        return Icons.cancel;
      default:
        return Icons.info;
    }
  }

  Future<void> _approveNotification(int index) async {
    final notification = _filteredNotifications[index];
    try {
      await _apiService.approveNotification(notification['id'].toString());
      await _apiService.updateEventStatus(notification['event_id'].toString(), 'approved');
      _loadData(); // Reload data
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Notification approved')),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to approve: $error')),
      );
    }
  }

  Future<void> _declineNotification(int index) async {
    final notification = _filteredNotifications[index];
    try {
      await _apiService.declineNotification(notification['id'].toString());
      await _apiService.updateEventStatus(notification['event_id'].toString(), 'declined');
      _loadData(); // Reload data
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Notification declined')),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to decline: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final counts = _statusCounts;
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Add refresh button row
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton.icon(
                onPressed: _loadData,
                icon: const Icon(Icons.refresh),
                label: const Text('Refresh'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Status summary cards
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatusCard('Pending', counts['pending']!, Colors.yellow.shade100, Colors.yellow.shade800, Icons.access_time),
              _buildStatusCard('Approved', counts['approved']!, Colors.green.shade100, Colors.green.shade800, Icons.check_circle),
              _buildStatusCard('Declined', counts['declined']!, Colors.red.shade100, Colors.red.shade800, Icons.cancel),
            ],
          ),
          const SizedBox(height: 16),
          // Tabs for Pending/Approved and Deleted History
          TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'Pending/Approved'),
              Tab(text: 'Deleted History'),
            ],
          ),
          const SizedBox(height: 16),
          // Search and filter row
          Row(
            children: [
              Expanded(
                flex: 3,
                child: TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    labelText: 'Search notifications...',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.search),
                  ),
                  onChanged: (value) {
                    setState(() {});
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 1,
                child: DropdownButtonFormField<String>(
                  initialValue: _selectedStatus,
                  decoration: const InputDecoration(
                    labelText: 'All Status',
                    border: OutlineInputBorder(),
                  ),
                  items: ['All Status', 'pending', 'approved', 'declined']
                      .map((status) => DropdownMenuItem(value: status, child: Text(status)))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedStatus = value;
                      });
                    }
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Pending/Approved notifications
                _buildNotificationList(_filteredNotifications.where((n) => n['status'] != 'declined').toList()),
                // Deleted history
                _buildNotificationList(_deletedNotifications),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationList(List<Map<String, dynamic>> notifications) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    return ListView.builder(
      itemCount: notifications.length,
      itemBuilder: (context, index) {
        final notification = notifications[index];
        final event = _events.firstWhere(
          (e) => e['id'] == notification['event_id'],
          orElse: () => {'title': 'Unknown Event', 'date': '', 'location': ''},
        );
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8),
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        event['title'],
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _statusColor(notification['status']),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        notification['status'],
                        style: TextStyle(
                          color: _statusTextColor(notification['status']),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(notification['message']),
                Text('Date: ${event['date']}'),
                Text('Location: ${event['location']}'),
                Text('Created: ${notification['created_at'].month}/${notification['created_at'].day}/${notification['created_at'].year}'),
                if (notification['status'] == 'pending')
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton(
                        onPressed: () => _approveNotification(index),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                        child: const Text('Approve'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () => _declineNotification(index),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                        child: const Text('Decline'),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusCard(String label, int count, Color bgColor, Color textColor, IconData icon) {
    return Expanded(
      child: Card(
        color: bgColor,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: textColor),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: TextStyle(color: textColor)),
                  Text(count.toString(), style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 18)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
