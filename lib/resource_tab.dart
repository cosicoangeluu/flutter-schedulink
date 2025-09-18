import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'api_service.dart';

class ResourcesPage extends StatefulWidget {
   const ResourcesPage({super.key});

  @override
  State<ResourcesPage> createState() => _ResourcesPageState();
}

class _ResourcesPageState extends State<ResourcesPage> {
  DateTime _selectedDate = DateTime.now();
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'All Categories';
  String _selectedStatus = 'All Status';
  final ApiService _apiService = ApiService();
  bool _isLoading = false;
  List<Map<String, dynamic>> _resources = [];

  final List<String> _categories = ['All Categories', 'Furniture', 'Equipment', 'Facilities'];
  final List<String> _statuses = ['All Status', 'Available', 'In Use', 'Maintenance'];

  // Form controllers for Add Resource modal
  final TextEditingController _resourceNameController = TextEditingController();
  final TextEditingController _totalQuantityController = TextEditingController();
  final TextEditingController _availableController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  String? _selectedResourceCategory;
  String? _selectedCondition;
  String? _selectedResourceStatus;

  final List<String> _resourceCategories = ['Chairs', 'Tables', 'Equipment', 'Electronics', 'Other'];
  final List<String> _conditions = ['Good', 'Fair', 'Poor'];
  final List<String> _resourceStatuses = ['Available', 'In Use', 'Maintenance'];

  final List<Map<String, dynamic>> _facilities = [
    {'name': 'Gymnasium', 'color': Colors.blue, 'status': 'Available'},
    {'name': 'Function Hall', 'color': Colors.green, 'status': 'In Use'},
    {'name': 'Recreational Hall', 'color': Colors.orange, 'status': 'Available'},
    {'name': 'EMRC', 'color': Colors.purple, 'status': 'Maintenance'},
  ];

  final List<Map<String, dynamic>> _upcomingBookings = [
    {
      'facility': 'Gymnasium',
      'event': 'Tech Conference 2024',
      'date': 'March 15, 2024',
      'time': '9:00 AM - 5:00 PM'
    },
    {
      'facility': 'Function Hall',
      'event': 'Leadership Workshop',
      'date': 'March 18, 2024',
      'time': '2:00 PM - 4:00 PM'
    },
    {
      'facility': 'Recreational Hall',
      'event': 'Product Launch',
      'date': 'March 22, 2024',
      'time': '11:00 AM - 12:00 PM'
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadResources();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _resourceNameController.dispose();
    _totalQuantityController.dispose();
    _availableController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _loadResources() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final resources = await _apiService.getResources();
      if (!mounted) return;
      setState(() {
        _resources = resources.map((r) => {
          'id': r['id'],
          'name': r['name'],
          'category': r['category'],
          'status': r['status'],
          'location': r['location'],
          'condition': r['condition'],
          'total': r['total_quantity'],
          'available': r['available_quantity'],
          'inUse': r['total_quantity'] - r['available_quantity'],
          'utilization': r['total_quantity'] > 0 ? ((r['total_quantity'] - r['available_quantity']) / r['total_quantity'] * 100).round() : 0,
        }).toList();
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load resources: $error')),
      );
    }
  }

  void _showAddResourceModal() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            double dialogWidth = MediaQuery.of(context).size.width > 600 ? 500 : MediaQuery.of(context).size.width * 0.9;
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                width: dialogWidth,
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header with title and close button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Add New Resource',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // Form fields
                    TextField(
                      controller: _resourceNameController,
                      decoration: const InputDecoration(
                        labelText: 'Resource Name *',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedResourceCategory,
                      decoration: const InputDecoration(
                        labelText: 'Category *',
                        border: OutlineInputBorder(),
                      ),
                      items: _resourceCategories
                          .map((category) => DropdownMenuItem(value: category, child: Text(category)))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedResourceCategory = value;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _totalQuantityController,
                            decoration: const InputDecoration(
                              labelText: 'Total Quantity *',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextField(
                            controller: _availableController,
                            decoration: const InputDecoration(
                              labelText: 'Available',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _locationController,
                      decoration: const InputDecoration(
                        labelText: 'Location',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            initialValue: _selectedCondition,
                            decoration: const InputDecoration(
                              labelText: 'Condition',
                              border: OutlineInputBorder(),
                            ),
                            items: _conditions
                                .map((condition) => DropdownMenuItem(value: condition, child: Text(condition)))
                                .toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedCondition = value;
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            initialValue: _selectedResourceStatus,
                            decoration: const InputDecoration(
                              labelText: 'Status',
                              border: OutlineInputBorder(),
                            ),
                            items: _resourceStatuses
                                .map((status) => DropdownMenuItem(value: status, child: Text(status)))
                                .toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedResourceStatus = value;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // Action buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        OutlinedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          ),
                          child: const Text('Cancel'),
                        ),
                        const SizedBox(width: 16),
                        ElevatedButton(
                          onPressed: _validateAndSubmit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          ),
                          child: const Text('Add Resource'),
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
    );
  }

  void _validateAndSubmit() async {
    // Basic validation
    if (_resourceNameController.text.isEmpty ||
        _selectedResourceCategory == null ||
        _totalQuantityController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all required fields')),
      );
      return;
    }

    try {
      final resourceData = {
        'name': _resourceNameController.text,
        'category': _selectedResourceCategory,
        'total_quantity': int.parse(_totalQuantityController.text),
        'available_quantity': _availableController.text.isNotEmpty ? int.parse(_availableController.text) : int.parse(_totalQuantityController.text),
        'location': _locationController.text,
        'condition': _selectedCondition ?? 'Good',
        'status': _selectedResourceStatus ?? 'available',
      };

      await _apiService.createResource(resourceData);

      // Reload resources to show the new one
      await _loadResources();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Resource added successfully')),
      );

      // Clear form and close modal
      _clearForm();
      Navigator.of(context).pop();
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add resource: $error')),
      );
    }
  }

  void _clearForm() {
    _resourceNameController.clear();
    _totalQuantityController.clear();
    _availableController.clear();
    _locationController.clear();
    _selectedResourceCategory = null;
    _selectedCondition = null;
    _selectedResourceStatus = null;
  }

  @override
  Widget build(BuildContext context) {
    bool isMobile = MediaQuery.of(context).size.width < 600;
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Page Header
          const Text(
            'Resource Management',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Manage your venue resources and facility bookings',
            style: TextStyle(fontSize: 16, color: Colors.black54),
          ),
          const SizedBox(height: 24),
          // Summary Cards
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSummaryCard('Total Chairs', '365', Icons.event_seat, Colors.blue, isMobile),
              _buildSummaryCard('Total Electric Fans', '48', Icons.toys, Colors.green, isMobile),
              _buildSummaryCard('Available Items', '353', Icons.check_circle, Colors.purple, isMobile),
              _buildSummaryCard('Items in Use', '60', Icons.access_time, Colors.orange, isMobile),
            ],
          ),
          const SizedBox(height: 24),
          // Facility Booking Calendar
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Facility Booking Calendar',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Date Picker
                  Row(
                    children: [
                      const Text('Select Date: ', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () async {
                          final DateTime? picked = await showDatePicker(
                            context: context,
                            initialDate: _selectedDate,
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(const Duration(days: 365)),
                          );
                          if (picked != null && picked != _selectedDate) {
                            setState(() {
                              _selectedDate = picked;
                            });
                          }
                        },
                        child: Text(
                          '${_selectedDate.month}/${_selectedDate.day}/${_selectedDate.year}',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Facilities List
                  const Text(
                    'Facilities',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ..._facilities.map((facility) => _buildFacilityItem(facility)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Upcoming Bookings
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Upcoming Bookings',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ..._upcomingBookings.map((booking) => _buildBookingItem(booking)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Search and Filter Controls
          Row(
            children: [
              Expanded(
                flex: 3,
                child: TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    labelText: 'Search resources...',
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
                  initialValue: _selectedCategory,
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(),
                  ),
                  items: _categories
                      .map((category) => DropdownMenuItem(value: category, child: Text(category)))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedCategory = value;
                      });
                    }
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 1,
                child: DropdownButtonFormField<String>(
                  initialValue: _selectedStatus,
                  decoration: const InputDecoration(
                    labelText: 'Status',
                    border: OutlineInputBorder(),
                  ),
                  items: _statuses
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
          // Resource Cards Grid
          LayoutBuilder(
            builder: (context, constraints) {
              int crossAxisCount = constraints.maxWidth > 600 ? 3 : (constraints.maxWidth > 400 ? 2 : 1);
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.4,
                ),
                itemCount: _resourceCards.length,
                itemBuilder: (context, index) {
                  final resource = _resourceCards[index];
                  return _buildResourceCard(resource);
                },
              );
            },
          ),
          const SizedBox(height: 24),
          // Add Resource Button
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton.icon(
              onPressed: _showAddResourceModal,
              icon: const Icon(Icons.add),
              label: const Text('Add Resource'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildResourceCard(Map<String, dynamic> resource) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Resource Name and Category
            Text(
              resource['name'],
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              resource['category'],
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 12),
            // Status and Location Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Status with colored badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _statusColor(resource['status']),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    resource['status'],
                    style: TextStyle(
                      color: _statusTextColor(resource['status']),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  resource['location'],
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Condition
            Row(
              children: [
                const Text('Condition: ', style: TextStyle(fontWeight: FontWeight.bold)),
                Text(
                  resource['condition'],
                  style: TextStyle(
                    color: _conditionColor(resource['condition']),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Availability Bar and Text
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                LinearProgressIndicator(
                  value: resource['available'] / resource['total'],
                  color: Colors.green,
                  backgroundColor: Colors.grey[300],
                  minHeight: 8,
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Availability'),
                    Text('${resource['available']}/${resource['total']}'),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('In Use: ${resource['inUse']}'),
                    Text('Utilization: ${resource['utilization']}%'),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Available':
        return Colors.green.shade100;
      case 'In Use':
        return Colors.orange.shade100;
      case 'Maintenance':
        return Colors.yellow.shade100;
      default:
        return Colors.grey.shade100;
    }
  }

  Color _statusTextColor(String status) {
    switch (status) {
      case 'Available':
        return Colors.green.shade800;
      case 'In Use':
        return Colors.orange.shade800;
      case 'Maintenance':
        return Colors.yellow.shade800;
      default:
        return Colors.grey.shade800;
    }
  }

  Color _conditionColor(String condition) {
    switch (condition) {
      case 'Good':
        return Colors.green;
      case 'Fair':
        return Colors.orange;
      case 'Poor':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  static const List<Map<String, dynamic>> _resourceCards = [
    {
      'name': 'Executive Chair Premium',
      'category': 'Chairs',
      'status': 'Available',
      'location': 'Main Hall',
      'condition': 'Excellent',
      'available': 32,
      'total': 45,
      'inUse': 13,
      'utilization': 29,
    },
    {
      'name': 'Conference Chair Standard',
      'category': 'Chairs',
      'status': 'Available',
      'location': 'Conference Room A',
      'condition': 'Good',
      'available': 98,
      'total': 120,
      'inUse': 22,
      'utilization': 18,
    },
    {
      'name': 'Folding Chair Lightweight',
      'category': 'Chairs',
      'status': 'Available',
      'location': 'Storage Room',
      'condition': 'Good',
      'available': 185,
      'total': 200,
      'inUse': 15,
      'utilization': 8,
    },
    {
      'name': 'Ceiling Fan Industrial',
      'category': 'Electric Fans',
      'status': 'Maintenance',
      'location': 'Main Hall',
      'condition': 'Fair',
      'available': 6,
      'total': 8,
      'inUse': 2,
      'utilization': 25,
    },
    {
      'name': 'Standing Fan Portable',
      'category': 'Electric Fans',
      'status': 'Available',
      'location': 'Various Rooms',
      'condition': 'Excellent',
      'available': 20,
      'total': 25,
      'inUse': 5,
      'utilization': 20,
    },
    {
      'name': 'Wall Mount Fan',
      'category': 'Electric Fans',
      'status': 'Available',
      'location': 'Meeting Rooms',
      'condition': 'Good',
      'available': 12,
      'total': 15,
      'inUse': 3,
      'utilization': 20,
    },
  ];

  Widget _buildSummaryCard(String title, String value, IconData icon, Color iconColor, bool isMobile) {
    return Expanded(
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.all(8),
                child: isMobile ? Transform.rotate(angle: math.pi, child: Icon(icon, color: iconColor, size: 28)) : Icon(icon, color: iconColor, size: 28),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFacilityItem(Map<String, dynamic> facility) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: facility['color'],
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              facility['name'],
              style: const TextStyle(fontSize: 16),
            ),
          ),
          Text(
            facility['status'],
            style: TextStyle(
              color: facility['status'] == 'Available' ? Colors.green : Colors.grey,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingItem(Map<String, dynamic> booking) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  booking['facility'],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  booking['event'],
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                booking['date'],
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                booking['time'],
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

