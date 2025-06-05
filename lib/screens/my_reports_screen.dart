import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/database_service.dart';
import '../services/network_service.dart';
import '../models/report_model.dart';
import 'report_details_screen.dart';
import 'report_form_screen.dart';

class MyReportsScreen extends StatefulWidget {
  const MyReportsScreen({Key? key}) : super(key: key);

  @override
  _MyReportsScreenState createState() => _MyReportsScreenState();
}

class _MyReportsScreenState extends State<MyReportsScreen> {
  final _dbService = DatabaseService();
  final _networkService = NetworkService();
  List<MaintenanceReport> _reports = [];
  bool _isLoading = true;
  bool _isOffline = false;
  String _searchQuery = '';
  String? _username;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadReports();
    _checkConnectivity();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _username = prefs.getString('username');
    });
  }

  Future<void> _checkConnectivity() async {
    final isConnected = await _networkService.isConnected();
    setState(() {
      _isOffline = !isConnected;
    });
  }

  Future<void> _loadReports() async {
    setState(() {
      _isLoading = true;
    });

    try {
      List<MaintenanceReport> reports;
      
      if (await _networkService.isConnected()) {
        // Try to load from network first
        reports = await _networkService.getReports(
          technicianName: _username,
        );
        
        // Save to local database
        for (var report in reports) {
          await _dbService.saveReport(report);
        }
      } else {
        // Load from local database
        reports = await _dbService.getReportsByTechnician(_username ?? '');
      }

      // Apply search filter
      if (_searchQuery.isNotEmpty) {
        reports = reports.where((report) {
          final searchLower = _searchQuery.toLowerCase();
          return report.customerName.toLowerCase().contains(searchLower) ||
              report.instrumentName.toLowerCase().contains(searchLower) ||
              report.reportId.toLowerCase().contains(searchLower);
        }).toList();
      }

      setState(() {
        _reports = reports;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading reports: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Search',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
                _loadReports();
              },
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _reports.isEmpty
                    ? const Center(child: Text('No reports found'))
                    : ListView.builder(
                        itemCount: _reports.length,
                        itemBuilder: (context, index) {
                          final report = _reports[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 8.0,
                              vertical: 4.0,
                            ),
                            child: ListTile(
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ReportDetailsScreen(
                                    report: report,
                                  ),
                                ),
                              ),
                              title: Text(report.customerName),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Instrument: ${report.instrumentName}'),
                                  Text('Date: ${report.createdAt.split('T')[0]}'),
                                ],
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (!report.isSync)
                                    const Icon(Icons.cloud_off,
                                        color: Colors.red, size: 16),
                                  IconButton(
                                    icon: const Icon(Icons.edit),
                                    onPressed: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ReportFormScreen(
                                          report: report,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ReportFormScreen(),
            ),
          );
          _loadReports();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
} 