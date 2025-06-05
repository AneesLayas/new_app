import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:signature/signature.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../services/database_service.dart';
import '../services/network_service.dart';
import '../models/report_model.dart';

class ReportFormScreen extends StatefulWidget {
  final MaintenanceReport? report; // For editing existing report

  const ReportFormScreen({Key? key, this.report}) : super(key: key);

  @override
  _ReportFormScreenState createState() => _ReportFormScreenState();
}

class _ReportFormScreenState extends State<ReportFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _networkService = NetworkService();
  final _dbService = DatabaseService();
  final _signatureController = SignatureController(
    penStrokeWidth: 5,
    penColor: Colors.black,
    exportBackgroundColor: Colors.white,
  );

  // Form fields
  String? _customerName;
  String? _customerType;
  String? _customerTelephone;
  String? _city;
  String? _callVisit;
  List<String> _purposes = [];
  String? _instrumentName;
  String? _instrumentManufacturer;
  String? _serialNumber;
  String? _swVersion;
  String? _udDate;
  String? _timeIn;
  String? _timeOut;
  int? _durationHours;
  int? _durationMinutes;
  String? _problemDescription;
  String? _problemSolved;
  String? _remedyDescription;
  String? _technicianName;
  String? _customerSignature;
  String? _engineerSignature;
  List<MaterialUsed> _materials = [];

  // Dropdown options
  List<String> _customerTypes = [];
  List<String> _cities = [];
  List<String> _manufacturers = [];
  List<String> _purposesList = [];
  List<String> _technicians = [];

  @override
  void initState() {
    super.initState();
    _loadDropdownData();
    if (widget.report != null) {
      _loadExistingReport();
    }
  }

  Future<void> _loadDropdownData() async {
    // Load data from local database first
    _customerTypes = await _dbService.getCustomerTypes();
    _manufacturers = await _dbService.getManufacturers();
    _technicians = await _dbService.getTechnicians();

    // Try to load from network if available
    if (await _networkService.isConnected()) {
      try {
        final config = await _networkService.getConfig();
        setState(() {
          _customerTypes = config['customer_types'] ?? _customerTypes;
          _cities = config['cities'] ?? _cities;
          _manufacturers = config['manufacturers'] ?? _manufacturers;
          _purposesList = config['purposes'] ?? _purposesList;
          _technicians = config['technicians'] ?? _technicians;
        });
      } catch (e) {
        print('Error loading config: $e');
      }
    }
  }

  void _loadExistingReport() {
    final report = widget.report!;
    setState(() {
      _customerName = report.customerName;
      _customerType = report.customerType;
      _customerTelephone = report.customerTelephone;
      _city = report.city;
      _callVisit = report.callVisit;
      _purposes = report.purposes;
      _instrumentName = report.instrumentName;
      _instrumentManufacturer = report.instrumentManufacturer;
      _serialNumber = report.serialNumber;
      _swVersion = report.swVersion;
      _udDate = report.udDate;
      _timeIn = report.timeIn;
      _timeOut = report.timeOut;
      _durationHours = report.durationHours;
      _durationMinutes = report.durationMinutes;
      _problemDescription = report.problemDescription;
      _problemSolved = report.problemSolved;
      _remedyDescription = report.remedyDescription;
      _technicianName = report.technicianName;
      _customerSignature = report.customerSignature;
      _engineerSignature = report.engineerSignature;
      _materials = report.materials;
    });
  }

  Future<void> _saveReport() async {
    if (!_formKey.currentState!.validate()) return;

    _formKey.currentState!.save();

    final report = MaintenanceReport(
      reportId: widget.report?.reportId ?? DateTime.now().millisecondsSinceEpoch.toString(),
      customerName: _customerName!,
      customerType: _customerType!,
      customerTelephone: _customerTelephone!,
      city: _city!,
      callVisit: _callVisit!,
      purposes: _purposes,
      instrumentName: _instrumentName!,
      instrumentManufacturer: _instrumentManufacturer!,
      serialNumber: _serialNumber!,
      swVersion: _swVersion!,
      udDate: _udDate!,
      timeIn: _timeIn!,
      timeOut: _timeOut!,
      durationHours: _durationHours!,
      durationMinutes: _durationMinutes!,
      problemDescription: _problemDescription!,
      problemSolved: _problemSolved!,
      remedyDescription: _remedyDescription,
      technicianName: _technicianName!,
      customerSignature: _customerSignature,
      engineerSignature: _engineerSignature,
      materials: _materials,
      createdAt: DateTime.now().toIso8601String(),
      isSync: false,
    );

    try {
      // Save to local database
      await _dbService.saveReport(report);

      // Try to sync if online
      if (await _networkService.isConnected()) {
        await _networkService.saveReport(report.toJson());
        await _dbService.markReportAsSynced(report.reportId);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Report saved successfully')),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving report: $e')),
      );
    }
  }

  Future<void> _captureSignature(bool isCustomer) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SignatureScreen(
          controller: _signatureController,
          title: isCustomer ? 'Customer Signature' : 'Engineer Signature',
        ),
      ),
    );

    if (result != null) {
      final signature = await _signatureController.toPngBytes();
      if (signature != null) {
        final directory = await getApplicationDocumentsDirectory();
        final path = '${directory.path}/${isCustomer ? 'customer' : 'engineer'}_signature.png';
        await File(path).writeAsBytes(signature);
        
        setState(() {
          if (isCustomer) {
            _customerSignature = path;
          } else {
            _engineerSignature = path;
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.report == null ? 'New Report' : 'Edit Report'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveReport,
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // Customer Information
            _buildSection('Customer Information', [
              TextFormField(
                initialValue: _customerName,
                decoration: const InputDecoration(labelText: 'Customer Name'),
                validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
                onSaved: (value) => _customerName = value,
              ),
              DropdownButtonFormField<String>(
                value: _customerType,
                decoration: const InputDecoration(labelText: 'Customer Type'),
                items: _customerTypes.map((type) => DropdownMenuItem(
                  value: type,
                  child: Text(type),
                )).toList(),
                validator: (value) => value == null ? 'Required' : null,
                onChanged: (value) => setState(() => _customerType = value),
              ),
              TextFormField(
                initialValue: _customerTelephone,
                decoration: const InputDecoration(labelText: 'Customer Telephone'),
                validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
                onSaved: (value) => _customerTelephone = value,
              ),
              DropdownButtonFormField<String>(
                value: _city,
                decoration: const InputDecoration(labelText: 'City'),
                items: _cities.map((city) => DropdownMenuItem(
                  value: city,
                  child: Text(city),
                )).toList(),
                validator: (value) => value == null ? 'Required' : null,
                onChanged: (value) => setState(() => _city = value),
              ),
            ]),

            // Instrument Information
            _buildSection('Instrument Information', [
              TextFormField(
                initialValue: _instrumentName,
                decoration: const InputDecoration(labelText: 'Instrument Name'),
                validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
                onSaved: (value) => _instrumentName = value,
              ),
              DropdownButtonFormField<String>(
                value: _instrumentManufacturer,
                decoration: const InputDecoration(labelText: 'Manufacturer'),
                items: _manufacturers.map((manufacturer) => DropdownMenuItem(
                  value: manufacturer,
                  child: Text(manufacturer),
                )).toList(),
                validator: (value) => value == null ? 'Required' : null,
                onChanged: (value) => setState(() => _instrumentManufacturer = value),
              ),
              TextFormField(
                initialValue: _serialNumber,
                decoration: const InputDecoration(labelText: 'Serial Number'),
                validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
                onSaved: (value) => _serialNumber = value,
              ),
              TextFormField(
                initialValue: _swVersion,
                decoration: const InputDecoration(labelText: 'Software Version'),
                validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
                onSaved: (value) => _swVersion = value,
              ),
            ]),

            // Visit Details
            _buildSection('Visit Details', [
              DropdownButtonFormField<String>(
                value: _callVisit,
                decoration: const InputDecoration(labelText: 'Call/Visit'),
                items: ['Call', 'Visit'].map((type) => DropdownMenuItem(
                  value: type,
                  child: Text(type),
                )).toList(),
                validator: (value) => value == null ? 'Required' : null,
                onChanged: (value) => setState(() => _callVisit = value),
              ),
              MultiSelectChip(
                options: _purposesList,
                selectedOptions: _purposes,
                onSelectionChanged: (selected) {
                  setState(() => _purposes = selected);
                },
              ),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      initialValue: _timeIn,
                      decoration: const InputDecoration(labelText: 'Time In'),
                      validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
                      onSaved: (value) => _timeIn = value,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      initialValue: _timeOut,
                      decoration: const InputDecoration(labelText: 'Time Out'),
                      validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
                      onSaved: (value) => _timeOut = value,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      initialValue: _durationHours?.toString(),
                      decoration: const InputDecoration(labelText: 'Duration (Hours)'),
                      keyboardType: TextInputType.number,
                      validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
                      onSaved: (value) => _durationHours = int.tryParse(value ?? '0'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      initialValue: _durationMinutes?.toString(),
                      decoration: const InputDecoration(labelText: 'Duration (Minutes)'),
                      keyboardType: TextInputType.number,
                      validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
                      onSaved: (value) => _durationMinutes = int.tryParse(value ?? '0'),
                    ),
                  ),
                ],
              ),
            ]),

            // Problem Details
            _buildSection('Problem Details', [
              TextFormField(
                initialValue: _problemDescription,
                decoration: const InputDecoration(labelText: 'Problem Description'),
                maxLines: 3,
                validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
                onSaved: (value) => _problemDescription = value,
              ),
              TextFormField(
                initialValue: _problemSolved,
                decoration: const InputDecoration(labelText: 'Problem Solved'),
                maxLines: 3,
                validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
                onSaved: (value) => _problemSolved = value,
              ),
              TextFormField(
                initialValue: _remedyDescription,
                decoration: const InputDecoration(labelText: 'Remedy Description'),
                maxLines: 3,
                onSaved: (value) => _remedyDescription = value,
              ),
            ]),

            // Materials Used
            _buildSection('Materials Used', [
              MaterialsList(
                materials: _materials,
                onMaterialsChanged: (materials) {
                  setState(() => _materials = materials);
                },
              ),
            ]),

            // Signatures
            _buildSection('Signatures', [
              ListTile(
                title: const Text('Customer Signature'),
                trailing: _customerSignature != null
                    ? Image.file(File(_customerSignature!), height: 50)
                    : const Icon(Icons.edit),
                onTap: () => _captureSignature(true),
              ),
              ListTile(
                title: const Text('Engineer Signature'),
                trailing: _engineerSignature != null
                    ? Image.file(File(_engineerSignature!), height: 50)
                    : const Icon(Icons.edit),
                onTap: () => _captureSignature(false),
              ),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        ...children,
        const Divider(),
      ],
    );
  }
}

class MultiSelectChip extends StatelessWidget {
  final List<String> options;
  final List<String> selectedOptions;
  final Function(List<String>) onSelectionChanged;

  const MultiSelectChip({
    Key? key,
    required this.options,
    required this.selectedOptions,
    required this.onSelectionChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8.0,
      children: options.map((option) {
        final isSelected = selectedOptions.contains(option);
        return FilterChip(
          label: Text(option),
          selected: isSelected,
          onSelected: (selected) {
            final newSelection = List<String>.from(selectedOptions);
            if (selected) {
              newSelection.add(option);
            } else {
              newSelection.remove(option);
            }
            onSelectionChanged(newSelection);
          },
        );
      }).toList(),
    );
  }
}

class MaterialsList extends StatelessWidget {
  final List<MaterialUsed> materials;
  final Function(List<MaterialUsed>) onMaterialsChanged;

  const MaterialsList({
    Key? key,
    required this.materials,
    required this.onMaterialsChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ...materials.map((material) => MaterialItem(
          material: material,
          onChanged: (updated) {
            final newMaterials = List<MaterialUsed>.from(materials);
            final index = newMaterials.indexWhere((m) => m.id == updated.id);
            if (index != -1) {
              newMaterials[index] = updated;
              onMaterialsChanged(newMaterials);
            }
          },
          onDeleted: () {
            final newMaterials = List<MaterialUsed>.from(materials);
            newMaterials.removeWhere((m) => m.id == material.id);
            onMaterialsChanged(newMaterials);
          },
        )),
        TextButton.icon(
          icon: const Icon(Icons.add),
          label: const Text('Add Material'),
          onPressed: () {
            final newMaterial = MaterialUsed(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              materialNumber: '',
              materialName: '',
              quantity: 1,
              remarks: '',
            );
            onMaterialsChanged([...materials, newMaterial]);
          },
        ),
      ],
    );
  }
}

class MaterialItem extends StatelessWidget {
  final MaterialUsed material;
  final Function(MaterialUsed) onChanged;
  final VoidCallback onDeleted;

  const MaterialItem({
    Key? key,
    required this.material,
    required this.onChanged,
    required this.onDeleted,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: material.materialNumber,
                    decoration: const InputDecoration(labelText: 'Material Number'),
                    onChanged: (value) => onChanged(material.copyWith(materialNumber: value)),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: onDeleted,
                ),
              ],
            ),
            TextFormField(
              initialValue: material.materialName,
              decoration: const InputDecoration(labelText: 'Material Name'),
              onChanged: (value) => onChanged(material.copyWith(materialName: value)),
            ),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: material.quantity.toString(),
                    decoration: const InputDecoration(labelText: 'Quantity'),
                    keyboardType: TextInputType.number,
                    onChanged: (value) => onChanged(
                      material.copyWith(quantity: int.tryParse(value) ?? 1),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    initialValue: material.remarks,
                    decoration: const InputDecoration(labelText: 'Remarks'),
                    onChanged: (value) => onChanged(material.copyWith(remarks: value)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class SignatureScreen extends StatelessWidget {
  final SignatureController controller;
  final String title;

  const SignatureScreen({
    Key? key,
    required this.controller,
    required this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Signature(
              controller: controller,
              backgroundColor: Colors.white,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () => controller.clear(),
              ),
              IconButton(
                icon: const Icon(Icons.check),
                onPressed: () => Navigator.pop(context, true),
              ),
            ],
          ),
        ],
      ),
    );
  }
} 