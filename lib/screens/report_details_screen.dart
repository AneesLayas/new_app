import 'package:flutter/material.dart';
import '../models/report_model.dart';
import '../services/network_service.dart';
import 'report_form_screen.dart';

class ReportDetailsScreen extends StatefulWidget {
  final MaintenanceReport report;

  const ReportDetailsScreen({
    Key? key,
    required this.report,
  }) : super(key: key);

  @override
  _ReportDetailsScreenState createState() => _ReportDetailsScreenState();
}

class _ReportDetailsScreenState extends State<ReportDetailsScreen> {
  final _networkService = NetworkService();
  bool _isSyncing = false;

  Future<void> _syncReport() async {
    if (!widget.report.isSync) {
      setState(() {
        _isSyncing = true;
      });

      try {
        await _networkService.saveReport(widget.report);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Report synced successfully')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error syncing report: $e')),
        );
      } finally {
        setState(() {
          _isSyncing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Report #${widget.report.reportId}'),
        actions: [
          if (!widget.report.isSync)
            IconButton(
              icon: _isSyncing
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.sync),
              onPressed: _isSyncing ? null : _syncReport,
            ),
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ReportFormScreen(
                    report: widget.report,
                  ),
                ),
              );
              setState(() {});
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection(
              'Customer Information',
              [
                _buildInfoRow('Name', widget.report.customerName),
                _buildInfoRow('Type', widget.report.customerType),
                _buildInfoRow('Telephone', widget.report.customerTelephone),
                _buildInfoRow('City', widget.report.city),
              ],
            ),
            const SizedBox(height: 16),
            _buildSection(
              'Instrument Details',
              [
                _buildInfoRow('Name', widget.report.instrumentName),
                _buildInfoRow('Manufacturer', widget.report.instrumentManufacturer),
                _buildInfoRow('Serial Number', widget.report.serialNumber),
                _buildInfoRow('Software Version', widget.report.swVersion),
              ],
            ),
            const SizedBox(height: 16),
            _buildSection(
              'Visit Details',
              [
                _buildInfoRow('Date', widget.report.udDate),
                _buildInfoRow('Time In', widget.report.timeIn),
                _buildInfoRow('Time Out', widget.report.timeOut),
                _buildInfoRow(
                  'Duration',
                  '${widget.report.durationHours}h ${widget.report.durationMinutes}m',
                ),
                _buildInfoRow('Call/Visit', widget.report.callVisit),
                _buildInfoRow(
                  'Purposes',
                  widget.report.purposes.join(', '),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildSection(
              'Problem Details',
              [
                _buildInfoRow('Description', widget.report.problemDescription),
                _buildInfoRow('Solved', widget.report.problemSolved ? 'Yes' : 'No'),
                if (widget.report.problemSolved)
                  _buildInfoRow('Remedy', widget.report.remedyDescription),
              ],
            ),
            const SizedBox(height: 16),
            _buildSection(
              'Materials Used',
              widget.report.materials.map((material) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text(material.materialName),
                      ),
                      Expanded(
                        child: Text('Qty: ${material.quantity}'),
                      ),
                      if (material.remarks.isNotEmpty)
                        Expanded(
                          flex: 2,
                          child: Text('Remarks: ${material.remarks}'),
                        ),
                    ],
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            _buildSection(
              'Signatures',
              [
                if (widget.report.customerSignature.isNotEmpty)
                  _buildSignatureRow('Customer', widget.report.customerSignature),
                if (widget.report.engineerSignature.isNotEmpty)
                  _buildSignatureRow('Engineer', widget.report.engineerSignature),
              ],
            ),
            const SizedBox(height: 16),
            _buildSection(
              'Additional Information',
              [
                _buildInfoRow('Technician', widget.report.technicianName),
                _buildInfoRow('Created', widget.report.createdAt),
                if (widget.report.syncedAt.isNotEmpty)
                  _buildInfoRow('Last Synced', widget.report.syncedAt),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        ...children,
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  Widget _buildSignatureRow(String label, String signature) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Image.memory(
            base64Decode(signature),
            height: 100,
          ),
        ],
      ),
    );
  }
} 