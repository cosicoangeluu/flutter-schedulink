import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:5000/api';

  // Authentication
  Future<Map<String, dynamic>> register(String username, String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username, 'email': email, 'password': password}),
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      final token = data['token'];
      await _saveToken(token);
      return data;
    } else {
      throw Exception('Registration failed: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> login(String username, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username, 'password': password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final token = data['token'];
      await _saveToken(token);
      return data;
    } else {
      throw Exception('Login failed: ${response.body}');
    }
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

  Future<Map<String, String>> _getHeaders() async {
    final token = await _getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // Events
  Future<List<dynamic>> getEvents() async {
    final response = await http.get(Uri.parse('$baseUrl/events'));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load events');
    }
  }

  Future<Map<String, dynamic>> createEvent(Map<String, dynamic> event) async {
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse('$baseUrl/events'),
      headers: headers,
      body: jsonEncode(event),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to create event');
    }
  }

  Future<Map<String, dynamic>> getEventById(String id) async {
    final response = await http.get(Uri.parse('$baseUrl/events/$id'));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load event');
    }
  }

  Future<void> updateEvent(String id, Map<String, dynamic> event) async {
    final headers = await _getHeaders();
    final response = await http.put(
      Uri.parse('$baseUrl/events/$id'),
      headers: headers,
      body: jsonEncode(event),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update event');
    }
  }

  Future<void> updateEventStatus(String id, String status) async {
    final headers = await _getHeaders();
    final response = await http.put(
      Uri.parse('$baseUrl/events/$id/status'),
      headers: headers,
      body: jsonEncode({'status': status}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update event status');
    }
  }

  Future<void> deleteEvent(String id) async {
    final headers = await _getHeaders();
    final response = await http.delete(
      Uri.parse('$baseUrl/events/$id'),
      headers: headers,
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete event');
    }
  }

  // Registrations
  Future<List<dynamic>> getRegistrations() async {
    final response = await http.get(Uri.parse('$baseUrl/registrations'));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load registrations');
    }
  }

  Future<Map<String, dynamic>> registerParticipant(Map<String, dynamic> participant) async {
    final response = await http.post(
      Uri.parse('$baseUrl/registrations'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(participant),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to register participant');
    }
  }

  Future<void> deleteRegistration(String id) async {
    final headers = await _getHeaders();
    final response = await http.delete(
      Uri.parse('$baseUrl/registrations/$id'),
      headers: headers,
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete registration');
    }
  }

  Future<void> updateRegistration(String id, Map<String, dynamic> data) async {
    final headers = await _getHeaders();
    final response = await http.put(
      Uri.parse('$baseUrl/registrations/$id/status'),
      headers: headers,
      body: jsonEncode(data),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update registration');
    }
  }

  // Notifications
  Future<List<dynamic>> getNotifications() async {
    final response = await http.get(Uri.parse('$baseUrl/notifications'));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load notifications');
    }
  }

  Future<Map<String, dynamic>> approveNotification(String id) async {
    final response = await http.put(Uri.parse('$baseUrl/notifications/$id/approve'));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to approve notification');
    }
  }

  Future<Map<String, dynamic>> declineNotification(String id) async {
    final headers = await _getHeaders();
    final response = await http.put(
      Uri.parse('$baseUrl/notifications/$id/decline'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to decline notification');
    }
  }

  Future<Map<String, dynamic>> getNotificationById(String id) async {
    final response = await http.get(Uri.parse('$baseUrl/notifications/$id'));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load notification');
    }
  }

  Future<Map<String, dynamic>> createNotification(Map<String, dynamic> notification) async {
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse('$baseUrl/notifications'),
      headers: headers,
      body: jsonEncode(notification),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to create notification');
    }
  }

  Future<void> deleteNotification(String id) async {
    final headers = await _getHeaders();
    final response = await http.delete(
      Uri.parse('$baseUrl/notifications/$id'),
      headers: headers,
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete notification');
    }
  }

  // Reports
  Future<List<dynamic>> getEventReports() async {
    final response = await http.get(Uri.parse('$baseUrl/reports/events'));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load reports');
    }
  }

  Future<Map<String, dynamic>> getDashboardStats() async {
    final response = await http.get(Uri.parse('$baseUrl/reports/dashboard'));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load dashboard stats');
    }
  }

  // Resources
  Future<List<dynamic>> getResources() async {
    final response = await http.get(Uri.parse('$baseUrl/resources'));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load resources');
    }
  }

  Future<Map<String, dynamic>> createResource(Map<String, dynamic> resource) async {
    final response = await http.post(
      Uri.parse('$baseUrl/resources'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(resource),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to create resource');
    }
  }

  // Dashboard
  static Future<Map<String, dynamic>> getDashboardSummary() async {
    final response = await http.get(Uri.parse('$baseUrl/reports/dashboard'));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load dashboard summary');
    }
  }
}
