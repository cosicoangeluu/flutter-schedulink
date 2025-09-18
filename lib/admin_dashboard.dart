import 'package:flutter/material.dart';
import 'package:schedulink_1/api_service.dart';
import 'package:schedulink_1/calendar_widget.dart';
import 'package:schedulink_1/event_management.dart';
import 'package:schedulink_1/registration_tab.dart';
import 'package:schedulink_1/reports_tab.dart';
import 'package:schedulink_1/resource_tab.dart';

import 'notification_tab.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _selectedIndex = 0;
  // Removed unused field _apiService
  // final ApiService _apiService = ApiService();

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      DashboardPage(onNavigateToEvents: () => setState(() => _selectedIndex = 1)),
      const EventManagement(),
      const ResourcesPage(),
      const RegistrationsPage(),
      const NotificationsPage(),
      const ReportsPage(),
      const LogoutPage(),
    ];
  }

  void _onSidebarItemTap(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _buildSidebarItem(IconData icon, String label, int index) {
    final bool selected = _selectedIndex == index;
    return Container(
      color: selected ? Colors.red[900] : Colors.transparent,
      child: ListTile(
        leading: Icon(icon, color: Colors.white),
        title: Text(label, style: const TextStyle(color: Colors.white)),
        onTap: () => _onSidebarItemTap(index),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 600) {
          // Mobile layout with drawer
          return Scaffold(
            appBar: AppBar(
              title: const Text('ScheduLink'),
              backgroundColor: Colors.red[700],
            ),
            drawer: Drawer(
              child: Container(
                color: Colors.red[700],
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    const DrawerHeader(
                      decoration: BoxDecoration(
                        color: Colors.red,
                      ),
                      child: Text(
                        'ScheduLink',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    _buildSidebarItem(Icons.dashboard, 'Dashboard', 0),
                    _buildSidebarItem(Icons.event, 'Events', 1),
                    _buildSidebarItem(Icons.folder, 'Resources', 2),
                    _buildSidebarItem(Icons.person_add, 'Registrations', 3),
                    _buildSidebarItem(Icons.notifications, 'Notifications', 4),
                    _buildSidebarItem(Icons.bar_chart, 'Reports', 5),
                    _buildSidebarItem(Icons.logout, 'Logout', 6),
                  ],
                ),
              ),
            ),
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: _pages[_selectedIndex],
            ),
          );
        } else {
          // Desktop layout
          return Scaffold(
            body: Row(
              children: [
                // Sidebar
                Container(
                  width: 200,
                  color: Colors.red[700],
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 40),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text(
                          'ScheduLink',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildSidebarItem(Icons.dashboard, 'Dashboard', 0),
                      _buildSidebarItem(Icons.event, 'Events', 1),
                      _buildSidebarItem(Icons.folder, 'Resources', 2),
                      _buildSidebarItem(Icons.person_add, 'Registrations', 3),
                      _buildSidebarItem(Icons.notifications, 'Notifications', 4),
                      _buildSidebarItem(Icons.bar_chart, 'Reports', 5),
                      _buildSidebarItem(Icons.logout, 'Logout', 6),
                    ],
                  ),
                ),
                // Main content
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: _pages[_selectedIndex],
                  ),
                ),
              ],
            ),
          );
        }
      },
    );
  }
}

class DashboardPage extends StatefulWidget {
  final VoidCallback? onNavigateToEvents;

  const DashboardPage({super.key, this.onNavigateToEvents});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  Map<String, dynamic> _dashboardData = {};
  bool _isLoading = true;
  List<Map<String, dynamic>> _notifications = [];
  List<Map<String, dynamic>> _events = [];

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final data = await ApiService.getDashboardSummary();
      final notifications = await ApiService().getNotifications();
      final events = await ApiService().getEvents();
      if (!mounted) return;
      setState(() {
        _dashboardData = data;
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
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _dashboardData = {
          'totalEvents': 12,
          'totalRegistrations': 245,
          'activeNotifications': 4,
        };
        _isLoading = false;
      });
    }
  }

  List<Map<String, dynamic>> get _pendingEvents {
    final pendingEventIds = _notifications.where((n) => n['status'] == 'pending').map((n) => n['event_id']).toSet();
    return _events.where((e) => pendingEventIds.contains(e['id'])).toList();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Dashboard',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "Welcome back! Here's what's happening with your events.",
            style: TextStyle(fontSize: 16, color: Colors.black54),
          ),
          const SizedBox(height: 24),
          // Summary cards
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSummaryCard('Total Events', _dashboardData['totalEvents']?.toString() ?? '0', Icons.calendar_today, Colors.red, '+15%', onTap: widget.onNavigateToEvents),
              _buildSummaryCard('Registrations', _dashboardData['totalRegistrations']?.toString() ?? '0', Icons.person_add, Colors.red, '+8.2%'),
              _buildSummaryCard('Active Notifications', _dashboardData['activeNotifications']?.toString() ?? '0', Icons.notifications, Colors.red, null),
            ],
          ),
          const SizedBox(height: 24),
          // Event Trends and Status
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: _buildEventTrendsCard(),
              ),
              const SizedBox(width: 24),
              Expanded(
                flex: 2,
                child: _buildEventStatusCard(),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Upcoming Events
          _buildUpcomingEventsCard(context),
          const SizedBox(height: 24),
          // Recent Activity
          _buildRecentActivityCard(),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon, Color iconColor, String? change, {VoidCallback? onTap}) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                    const Spacer(),
                    Icon(icon, color: iconColor, size: 20),
                  ],
                ),
                const SizedBox(height: 8),
                Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                if (change != null)
                  Text(change, style: TextStyle(color: Colors.green[700], fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEventTrendsCard() {
    return Card(
      elevation: 2,
      child: Container(
        height: 200,
        padding: const EdgeInsets.all(16.0),
        child: const Text('Event Trends Chart Placeholder'),
      ),
    );
  }

  Widget _buildEventStatusCard() {
    return Card(
      elevation: 2,
      child: Container(
        height: 200,
        padding: const EdgeInsets.all(16.0),
        child: const Text('Event Status Donut Chart Placeholder'),
      ),
    );
  }

  Widget _buildUpcomingEventsCard(BuildContext context) {
    return Card(
      elevation: 2,
      child: Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Upcoming Events', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                TextButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Text('Calendar'),
                    content: SizedBox(
                      width: 400,
                      height: 400,
                      child: CalendarWidget(
                        initialDate: DateTime.now(),
                        onDateSelected: (date) {
                          // You can add any action on date selection here if needed
                          Navigator.of(context).pop();
                        },
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Close'),
                      ),
                    ],
                  );
                },
                    );
                  },
                  child: const Text('View Calendar', style: TextStyle(color: Colors.red)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (_pendingEvents.isEmpty)
              const Text('No pending events requiring approval.')
            else
              ..._pendingEvents.map((event) => _buildEventListItem(event['title'], event['date'], 'TBD', 0, 'pending')),
          ],
        ),
      ),
    );
  }

  Widget _buildEventListItem(String title, String date, String time, int attendees, String status) {
    Color statusColor;
    switch (status) {
      case 'confirmed':
        statusColor = Colors.green[100]!;
        break;
      case 'pending':
        statusColor = Colors.yellow[100]!;
        break;
      case 'draft':
        statusColor = Colors.grey[200]!;
        break;
      default:
        statusColor = Colors.grey[200]!;
    }
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
              const SizedBox(width: 4),
              Text(date, style: const TextStyle(color: Colors.grey)),
              const SizedBox(width: 16),
              const Icon(Icons.access_time, size: 16, color: Colors.grey),
              const SizedBox(width: 4),
              Text(time, style: const TextStyle(color: Colors.grey)),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.person, size: 16, color: Colors.grey),
              const SizedBox(width: 4),
              Text('$attendees attendees', style: const TextStyle(color: Colors.grey)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: status == 'confirmed' ? Colors.green[800] : Colors.black87,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }



  Widget _buildRecentActivityCard() {
    return Card(
      elevation: 2,
      child: Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Recent Activity', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                TextButton(
                  onPressed: () {},
                  child: const Text('View All', style: TextStyle(color: Colors.red)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _buildActivityItem('New registration for Tech Conference 2024', 'Sarah Johnson', '2 minutes ago', Icons.person_add, Colors.green),
            _buildActivityItem('Marketing Workshop scheduled', 'Admin', '15 minutes ago', Icons.event, Colors.blue),
            _buildActivityItem('Event cancelled: Product Launch', 'Mike Chen', '1 hour ago', Icons.cancel, Colors.red),
            _buildActivityItem('New feedback received', 'Emma Wilson', '2 hours ago', Icons.star, Colors.amber),
            _buildActivityItem('Bulk registration for Leadership Summit', 'Corporate Team', '3 hours ago', Icons.group, Colors.purple),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityItem(String title, String user, String time, IconData icon, Color iconColor) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: iconColor,
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text('$user · $time', style: const TextStyle(color: Colors.grey)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class LogoutPage extends StatelessWidget {
  const LogoutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Logout Page'));
  }
}
