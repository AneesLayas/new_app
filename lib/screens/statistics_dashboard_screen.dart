import 'package:flutter/material.dart';
import '../services/network_service.dart';
import '../services/database_service.dart';
import '../models/report_model.dart';

class StatisticsDashboardScreen extends StatefulWidget {
  const StatisticsDashboardScreen({Key? key}) : super(key: key);

  @override
  _StatisticsDashboardScreenState createState() => _StatisticsDashboardScreenState();
}

class _StatisticsDashboardScreenState extends State<StatisticsDashboardScreen> {
  final _networkService = NetworkService();
  final _dbService = DatabaseService();
  bool _isLoading = true;
  bool _isOffline = false;
  Map<String, dynamic> _stats = {};

  @override
  void initState() {
    super.initState();
    _loadStatistics();
    _checkConnectivity();
  }

  Future<void> _checkConnectivity() async {
    final isConnected = await _networkService.isConnected();
    setState(() {
      _isOffline = !isConnected;
    });
  }

  Future<void> _loadStatistics() async {
    setState(() {
      _isLoading = true;
    });

    try {
      if (await _networkService.isConnected()) {
        // Load from network
        _stats = await _networkService.getStatistics();
      } else {
        // Load from local database
        final reports = await _dbService.getAllReports();
        _stats = _calculateLocalStatistics(reports);
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading statistics: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Map<String, dynamic> _calculateLocalStatistics(List<MaintenanceReport> reports) {
    final totalReports = reports.length;
    final syncedReports = reports.where((r) => r.isSync).length;
    final unsyncedReports = totalReports - syncedReports;

    // Calculate reports by technician
    final reportsByTechnician = <String, int>{};
    for (var report in reports) {
      reportsByTechnician[report.technicianName] = 
          (reportsByTechnician[report.technicianName] ?? 0) + 1;
    }

    // Calculate reports by customer type
    final reportsByCustomerType = <String, int>{};
    for (var report in reports) {
      reportsByCustomerType[report.customerType] = 
          (reportsByCustomerType[report.customerType] ?? 0) + 1;
    }

    return {
      'total_reports': totalReports,
      'synced_reports': syncedReports,
      'unsynced_reports': unsyncedReports,
      'reports_by_technician': reportsByTechnician,
      'reports_by_customer_type': reportsByCustomerType,
    };
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSummaryCards(),
          const SizedBox(height: 24),
          _buildTechnicianStats(),
          const SizedBox(height: 24),
          _buildCustomerTypeStats(),
        ],
      ),
    );
  }

  Widget _buildSummaryCards() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: [
        _buildStatCard(
          'Total Reports',
          _stats['total_reports']?.toString() ?? '0',
          Icons.assignment,
          Colors.blue,
        ),
        _buildStatCard(
          'Synced Reports',
          _stats['synced_reports']?.toString() ?? '0',
          Icons.cloud_done,
          Colors.green,
        ),
        _buildStatCard(
          'Unsynced Reports',
          _stats['unsynced_reports']?.toString() ?? '0',
          Icons.cloud_off,
          Colors.orange,
        ),
        _buildStatCard(
          'Sync Rate',
          '${((_stats['synced_reports'] ?? 0) / (_stats['total_reports'] ?? 1) * 100).toStringAsFixed(1)}%',
          Icons.sync,
          Colors.purple,
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTechnicianStats() {
    final reportsByTechnician = _stats['reports_by_technician'] as Map<String, dynamic>? ?? {};
    final technicians = reportsByTechnician.keys.toList();
    final reports = reportsByTechnician.values.toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Reports by Technician',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ...List.generate(technicians.length, (index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text(technicians[index]),
                ),
                Expanded(
                  flex: 3,
                  child: LinearProgressIndicator(
                    value: reports[index] / (_stats['total_reports'] ?? 1),
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Colors.blue,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  reports[index].toString(),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildCustomerTypeStats() {
    final reportsByCustomerType = _stats['reports_by_customer_type'] as Map<String, dynamic>? ?? {};
    final customerTypes = reportsByCustomerType.keys.toList();
    final reports = reportsByCustomerType.values.toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Reports by Customer Type',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ...List.generate(customerTypes.length, (index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text(customerTypes[index]),
                ),
                Expanded(
                  flex: 3,
                  child: LinearProgressIndicator(
                    value: reports[index] / (_stats['total_reports'] ?? 1),
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Colors.green,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  reports[index].toString(),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
} 