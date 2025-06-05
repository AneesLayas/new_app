import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;
import 'database_service.dart';

class NetworkService {
  final DatabaseService _dbService = DatabaseService();
  final String baseUrl = 'http://20.71.136.123:5000/api'; // Public IP address

  Future<bool> isConnected() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }

  Future<void> syncOfflineData() async {
    if (!await isConnected()) return;

    final unsyncedData = await _dbService.getUnsyncedData();
    for (var data in unsyncedData) {
      try {
        final response = await http.post(
          Uri.parse('$baseUrl${data['endpoint']}'),
          headers: {'Content-Type': 'application/json'},
          body: data['data'],
        );

        if (response.statusCode == 200) {
          await _dbService.markAsSynced(data['id']);
        }
      } catch (e) {
        print('Error syncing data: $e');
      }
    }
  }

  // Authentication
  Future<Map<String, dynamic>> login(String username, String password) async {
    if (await isConnected()) {
      try {
        final response = await http.post(
          Uri.parse('$baseUrl/login'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'username': username,
            'password': password,
          }),
        );

        if (response.statusCode == 200) {
          return jsonDecode(response.body);
        }
      } catch (e) {
        print('Error during login: $e');
      }
    }
    throw Exception('Failed to login');
  }

  // Reports
  Future<List<Map<String, dynamic>>> getReports({
    int page = 1,
    int perPage = 10,
    DateTime? startDate,
    DateTime? endDate,
    String? instrumentType,
    String? technicianName,
    String? manufacturer,
    String? customerType,
  }) async {
    final endpoint = '/reports';
    if (await isConnected()) {
      try {
        final queryParams = {
          'page': page.toString(),
          'per_page': perPage.toString(),
          if (startDate != null) 'start_date': startDate.toIso8601String(),
          if (endDate != null) 'end_date': endDate.toIso8601String(),
          if (instrumentType != null) 'instrument_type': instrumentType,
          if (technicianName != null) 'technician_name': technicianName,
          if (manufacturer != null) 'manufacturer': manufacturer,
          if (customerType != null) 'customer_type': customerType,
        };

        final response = await http.get(
          Uri.parse('$baseUrl$endpoint').replace(queryParameters: queryParams),
        );

        if (response.statusCode == 200) {
          return List<Map<String, dynamic>>.from(jsonDecode(response.body));
        }
      } catch (e) {
        print('Error fetching reports: $e');
      }
    }
    
    // If offline or error, return cached data
    final cachedData = await _dbService.getUnsyncedData();
    if (cachedData.isNotEmpty) {
      return List<Map<String, dynamic>>.from(
        jsonDecode(cachedData.first['data']),
      );
    }
    
    return [];
  }

  // Save Report
  Future<void> saveReport(Map<String, dynamic> reportData) async {
    final endpoint = '/reports';
    if (await isConnected()) {
      try {
        final response = await http.post(
          Uri.parse('$baseUrl$endpoint'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(reportData),
        );
        if (response.statusCode == 200) {
          return;
        }
      } catch (e) {
        print('Error saving report: $e');
      }
    }
    
    // If offline or error, save locally
    await _dbService.saveOfflineData(endpoint, jsonEncode(reportData));
  }

  // Get Report Details
  Future<Map<String, dynamic>> getReportDetails(String reportId) async {
    final endpoint = '/reports/$reportId';
    if (await isConnected()) {
      try {
        final response = await http.get(Uri.parse('$baseUrl$endpoint'));
        if (response.statusCode == 200) {
          return jsonDecode(response.body);
        }
      } catch (e) {
        print('Error fetching report details: $e');
      }
    }
    
    // If offline or error, return cached data
    final cachedData = await _dbService.getUnsyncedData();
    if (cachedData.isNotEmpty) {
      return jsonDecode(cachedData.first['data']);
    }
    
    return {};
  }

  // Get Materials
  Future<List<Map<String, dynamic>>> getMaterials(String reportId) async {
    final endpoint = '/reports/$reportId/materials';
    if (await isConnected()) {
      try {
        final response = await http.get(Uri.parse('$baseUrl$endpoint'));
        if (response.statusCode == 200) {
          return List<Map<String, dynamic>>.from(jsonDecode(response.body));
        }
      } catch (e) {
        print('Error fetching materials: $e');
      }
    }
    
    // If offline or error, return cached data
    final cachedData = await _dbService.getUnsyncedData();
    if (cachedData.isNotEmpty) {
      return List<Map<String, dynamic>>.from(
        jsonDecode(cachedData.first['data']),
      );
    }
    
    return [];
  }

  // Get Equipment Types
  Future<List<String>> getEquipmentTypes() async {
    final endpoint = '/equipment-types';
    if (await isConnected()) {
      try {
        final response = await http.get(Uri.parse('$baseUrl$endpoint'));
        if (response.statusCode == 200) {
          return List<String>.from(jsonDecode(response.body));
        }
      } catch (e) {
        print('Error fetching equipment types: $e');
      }
    }
    
    // If offline or error, return cached data
    final cachedData = await _dbService.getUnsyncedData();
    if (cachedData.isNotEmpty) {
      return List<String>.from(jsonDecode(cachedData.first['data']));
    }
    
    return [];
  }

  // Get Technicians
  Future<List<String>> getTechnicians() async {
    final endpoint = '/technicians';
    if (await isConnected()) {
      try {
        final response = await http.get(Uri.parse('$baseUrl$endpoint'));
        if (response.statusCode == 200) {
          return List<String>.from(jsonDecode(response.body));
        }
      } catch (e) {
        print('Error fetching technicians: $e');
      }
    }
    
    // If offline or error, return cached data
    final cachedData = await _dbService.getUnsyncedData();
    if (cachedData.isNotEmpty) {
      return List<String>.from(jsonDecode(cachedData.first['data']));
    }
    
    return [];
  }

  // Get Manufacturers
  Future<List<String>> getManufacturers() async {
    final endpoint = '/manufacturers';
    if (await isConnected()) {
      try {
        final response = await http.get(Uri.parse('$baseUrl$endpoint'));
        if (response.statusCode == 200) {
          return List<String>.from(jsonDecode(response.body));
        }
      } catch (e) {
        print('Error fetching manufacturers: $e');
      }
    }
    
    // If offline or error, return cached data
    final cachedData = await _dbService.getUnsyncedData();
    if (cachedData.isNotEmpty) {
      return List<String>.from(jsonDecode(cachedData.first['data']));
    }
    
    return [];
  }

  // Get Customer Types
  Future<List<String>> getCustomerTypes() async {
    final endpoint = '/customer-types';
    if (await isConnected()) {
      try {
        final response = await http.get(Uri.parse('$baseUrl$endpoint'));
        if (response.statusCode == 200) {
          return List<String>.from(jsonDecode(response.body));
        }
      } catch (e) {
        print('Error fetching customer types: $e');
      }
    }
    
    // If offline or error, return cached data
    final cachedData = await _dbService.getUnsyncedData();
    if (cachedData.isNotEmpty) {
      return List<String>.from(jsonDecode(cachedData.first['data']));
    }
    
    return [];
  }
} 