import 'package:flutter/material.dart';
import '../services/network_service.dart';
import 'report_list_screen.dart';
import 'report_form_screen.dart';
import 'my_reports_screen.dart';

class TechnicianHomeScreen extends StatefulWidget {
  const TechnicianHomeScreen({Key? key}) : super(key: key);

  @override
  _TechnicianHomeScreenState createState() => _TechnicianHomeScreenState();
}

class _TechnicianHomeScreenState extends State<TechnicianHomeScreen> {
  final _networkService = NetworkService();
  bool _isOffline = false;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _checkConnectivity();
  }

  Future<void> _checkConnectivity() async {
    final isConnected = await _networkService.isConnected();
    setState(() {
      _isOffline = !isConnected;
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Technician Dashboard'),
        actions: [
          if (_isOffline)
            const Icon(Icons.cloud_off, color: Colors.red),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: const [
          ReportListScreen(),
          MyReportsScreen(),
          Center(child: Text('Profile - Coming Soon')),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'All Reports',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment),
            label: 'My Reports',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ReportFormScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
} 