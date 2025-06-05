import 'package:flutter/material.dart';
import '../services/database_service.dart';
import '../services/network_service.dart';
import '../models/report_model.dart';
import 'report_form_screen.dart';
import 'report_details_screen.dart';

class ReportListScreen extends StatefulWidget {
  const ReportListScreen({Key? key}) : super(key: key);

  @override
  _ReportListScreenState createState() => _ReportListScreenState();
}

class _ReportListScreenState extends State<ReportListScreen> {
  final _dbService = DatabaseService();
  final _networkService = NetworkService();
  List<MaintenanceReport> _reports = [];
  bool _isLoading = true;
  bool _isOffline = false;
  String _searchQuery = '';
  DateTime? _startDate;
  DateTime? _endDate;
  String? _selectedTechnician;
  String? _selectedManufacturer;
  String? _selectedCustomerType;

  @override
  void initState() {
    super.initState();
    _loadReports();
    _checkConnectivity();
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
          startDate: _startDate,
          endDate: _endDate,
          technicianName: _selectedTechnician,
          manufacturer: _selectedManufacturer,
          customerType: _selectedCustomerType,
        );
        
        // Save to local database
        for (var report in reports) {
          await _dbService.saveReport(report);
        }
      } else {
        // Load from local database
        reports = await _dbService.getAllReports();
      }

      // Apply search filter
      if (_searchQuery.isNotEmpty) {
        reports = reports.where((report) {
          final searchLower = _searchQuery.toLowerCase();
          return report.customerName.toLowerCase().contains(searchLower) ||
              report.instrumentName.toLowerCase().contains(searchLower) ||
              report.technicianName.toLowerCase().contains(searchLower) ||
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

  Future<void> _showFilterDialog() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => FilterDialog(
        startDate: _startDate,
        endDate: _endDate,
        selectedTechnician: _selectedTechnician,
        selectedManufacturer: _selectedManufacturer,
        selectedCustomerType: _selectedCustomerType,
      ),
    );

    if (result != null) {
      setState(() {
        _startDate = result['startDate'];
        _endDate = result['endDate'];
        _selectedTechnician = result['technician'];
        _selectedManufacturer = result['manufacturer'];
        _selectedCustomerType = result['customerType'];
      });
      _loadReports();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Maintenance Reports'),
        actions: [
          if (_isOffline)
            const Icon(Icons.cloud_off, color: Colors.red),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
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
                          return ReportCard(
                            report: report,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ReportDetailsScreen(
                                  report: report,
                                ),
                              ),
                            ),
                            onEdit: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ReportFormScreen(
                                  report: report,
                                ),
                              ),
                            ),
                            onDelete: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Delete Report'),
                                  content: const Text(
                                    'Are you sure you want to delete this report?',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, false),
                                      child: const Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () => Navigator.pop(context, true),
                                      child: const Text('Delete'),
                                    ),
                                  ],
                                ),
                              );

                              if (confirm == true) {
                                await _dbService.deleteReport(report.reportId);
                                _loadReports();
                              }
                            },
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

class ReportCard extends StatelessWidget {
  final MaintenanceReport report;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ReportCard({
    Key? key,
    required this.report,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: ListTile(
        onTap: onTap,
        title: Text(report.customerName),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Instrument: ${report.instrumentName}'),
            Text('Technician: ${report.technicianName}'),
            Text('Date: ${report.createdAt.split('T')[0]}'),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!report.isSync)
              const Icon(Icons.cloud_off, color: Colors.red, size: 16),
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: onEdit,
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}

class FilterDialog extends StatefulWidget {
  final DateTime? startDate;
  final DateTime? endDate;
  final String? selectedTechnician;
  final String? selectedManufacturer;
  final String? selectedCustomerType;

  const FilterDialog({
    Key? key,
    this.startDate,
    this.endDate,
    this.selectedTechnician,
    this.selectedManufacturer,
    this.selectedCustomerType,
  }) : super(key: key);

  @override
  _FilterDialogState createState() => _FilterDialogState();
}

class _FilterDialogState extends State<FilterDialog> {
  late DateTime? _startDate;
  late DateTime? _endDate;
  late String? _selectedTechnician;
  late String? _selectedManufacturer;
  late String? _selectedCustomerType;

  @override
  void initState() {
    super.initState();
    _startDate = widget.startDate;
    _endDate = widget.endDate;
    _selectedTechnician = widget.selectedTechnician;
    _selectedManufacturer = widget.selectedManufacturer;
    _selectedCustomerType = widget.selectedCustomerType;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Filter Reports'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Start Date'),
              subtitle: Text(_startDate?.toString().split(' ')[0] ?? 'Not set'),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _startDate ?? DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime.now(),
                );
                if (date != null) {
                  setState(() => _startDate = date);
                }
              },
            ),
            ListTile(
              title: const Text('End Date'),
              subtitle: Text(_endDate?.toString().split(' ')[0] ?? 'Not set'),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _endDate ?? DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime.now(),
                );
                if (date != null) {
                  setState(() => _endDate = date);
                }
              },
            ),
            // Add more filter options here
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            setState(() {
              _startDate = null;
              _endDate = null;
              _selectedTechnician = null;
              _selectedManufacturer = null;
              _selectedCustomerType = null;
            });
          },
          child: const Text('Clear'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context, {
              'startDate': _startDate,
              'endDate': _endDate,
              'technician': _selectedTechnician,
              'manufacturer': _selectedManufacturer,
              'customerType': _selectedCustomerType,
            });
          },
          child: const Text('Apply'),
        ),
      ],
    );
  }
} 