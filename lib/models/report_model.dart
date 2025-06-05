import 'package:json_annotation/json_annotation.dart';

part 'report_model.g.dart';

@JsonSerializable()
class MaintenanceReport {
  final String reportId;
  final String customerName;
  final String customerType;
  final String customerTelephone;
  final String city;
  final String callVisit;
  final List<String> purposes;
  final String instrumentName;
  final String instrumentManufacturer;
  final String serialNumber;
  final String swVersion;
  final String udDate;
  final String timeIn;
  final String timeOut;
  final int durationHours;
  final int durationMinutes;
  final String problemDescription;
  final String problemSolved;
  final String? remedyDescription;
  final String technicianName;
  final String? customerSignature;
  final String? engineerSignature;
  final List<MaterialUsed> materials;
  final String createdAt;
  final String? syncedAt;
  final bool isSync;

  MaintenanceReport({
    required this.reportId,
    required this.customerName,
    required this.customerType,
    required this.customerTelephone,
    required this.city,
    required this.callVisit,
    required this.purposes,
    required this.instrumentName,
    required this.instrumentManufacturer,
    required this.serialNumber,
    required this.swVersion,
    required this.udDate,
    required this.timeIn,
    required this.timeOut,
    required this.durationHours,
    required this.durationMinutes,
    required this.problemDescription,
    required this.problemSolved,
    this.remedyDescription,
    required this.technicianName,
    this.customerSignature,
    this.engineerSignature,
    required this.materials,
    required this.createdAt,
    this.syncedAt,
    required this.isSync,
  });

  factory MaintenanceReport.fromJson(Map<String, dynamic> json) =>
      _$MaintenanceReportFromJson(json);

  Map<String, dynamic> toJson() => _$MaintenanceReportToJson(this);

  factory MaintenanceReport.fromDbMap(Map<String, dynamic> map) {
    return MaintenanceReport(
      reportId: map['report_id'],
      customerName: map['customer_name'],
      customerType: map['customer_type'],
      customerTelephone: map['customer_telephone'],
      city: map['city'],
      callVisit: map['call_visit'],
      purposes: List<String>.from(map['purpose'].split(',')),
      instrumentName: map['instrument_name'],
      instrumentManufacturer: map['instrument_manufacturer'],
      serialNumber: map['serial_number'],
      swVersion: map['sw_version'],
      udDate: map['ud_date'],
      timeIn: map['time_in'],
      timeOut: map['time_out'],
      durationHours: map['duration_hours'],
      durationMinutes: map['duration_minutes'],
      problemDescription: map['problem_description'],
      problemSolved: map['problem_solved'],
      remedyDescription: map['remedy_description'],
      technicianName: map['technician_name'],
      customerSignature: map['customer_signature'],
      engineerSignature: map['engineer_signature'],
      materials: [], // Will be populated separately
      createdAt: map['created_at'],
      syncedAt: map['synced_at'],
      isSync: map['is_sync'] == 1,
    );
  }

  Map<String, dynamic> toDbMap() {
    return {
      'report_id': reportId,
      'customer_name': customerName,
      'customer_type': customerType,
      'customer_telephone': customerTelephone,
      'city': city,
      'call_visit': callVisit,
      'purpose': purposes.join(','),
      'instrument_name': instrumentName,
      'instrument_manufacturer': instrumentManufacturer,
      'serial_number': serialNumber,
      'sw_version': swVersion,
      'ud_date': udDate,
      'time_in': timeIn,
      'time_out': timeOut,
      'duration_hours': durationHours,
      'duration_minutes': durationMinutes,
      'problem_description': problemDescription,
      'problem_solved': problemSolved,
      'remedy_description': remedyDescription,
      'technician_name': technicianName,
      'customer_signature': customerSignature,
      'engineer_signature': engineerSignature,
      'created_at': createdAt,
      'synced_at': syncedAt,
      'is_sync': isSync ? 1 : 0,
    };
  }

  MaintenanceReport copyWith({
    String? reportId,
    String? customerName,
    String? customerType,
    String? customerTelephone,
    String? city,
    String? callVisit,
    List<String>? purposes,
    String? instrumentName,
    String? instrumentManufacturer,
    String? serialNumber,
    String? swVersion,
    String? udDate,
    String? timeIn,
    String? timeOut,
    int? durationHours,
    int? durationMinutes,
    String? problemDescription,
    String? problemSolved,
    String? remedyDescription,
    String? technicianName,
    String? customerSignature,
    String? engineerSignature,
    List<MaterialUsed>? materials,
    String? createdAt,
    String? syncedAt,
    bool? isSync,
  }) {
    return MaintenanceReport(
      reportId: reportId ?? this.reportId,
      customerName: customerName ?? this.customerName,
      customerType: customerType ?? this.customerType,
      customerTelephone: customerTelephone ?? this.customerTelephone,
      city: city ?? this.city,
      callVisit: callVisit ?? this.callVisit,
      purposes: purposes ?? this.purposes,
      instrumentName: instrumentName ?? this.instrumentName,
      instrumentManufacturer: instrumentManufacturer ?? this.instrumentManufacturer,
      serialNumber: serialNumber ?? this.serialNumber,
      swVersion: swVersion ?? this.swVersion,
      udDate: udDate ?? this.udDate,
      timeIn: timeIn ?? this.timeIn,
      timeOut: timeOut ?? this.timeOut,
      durationHours: durationHours ?? this.durationHours,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      problemDescription: problemDescription ?? this.problemDescription,
      problemSolved: problemSolved ?? this.problemSolved,
      remedyDescription: remedyDescription ?? this.remedyDescription,
      technicianName: technicianName ?? this.technicianName,
      customerSignature: customerSignature ?? this.customerSignature,
      engineerSignature: engineerSignature ?? this.engineerSignature,
      materials: materials ?? this.materials,
      createdAt: createdAt ?? this.createdAt,
      syncedAt: syncedAt ?? this.syncedAt,
      isSync: isSync ?? this.isSync,
    );
  }
}

@JsonSerializable()
class MaterialUsed {
  final String id;
  final String materialNumber;
  final String materialName;
  final int quantity;
  final String? remarks;
  final String? reportId;

  MaterialUsed({
    required this.id,
    required this.materialNumber,
    required this.materialName,
    required this.quantity,
    this.remarks,
    this.reportId,
  });

  factory MaterialUsed.fromJson(Map<String, dynamic> json) =>
      _$MaterialUsedFromJson(json);

  Map<String, dynamic> toJson() => _$MaterialUsedToJson(this);

  factory MaterialUsed.fromDbMap(Map<String, dynamic> map) {
    return MaterialUsed(
      id: map['id'].toString(),
      materialNumber: map['material_number'],
      materialName: map['material_name'],
      quantity: map['quantity'],
      remarks: map['remarks'],
      reportId: map['report_id'],
    );
  }

  Map<String, dynamic> toDbMap() {
    return {
      'material_number': materialNumber,
      'material_name': materialName,
      'quantity': quantity,
      'remarks': remarks,
      'report_id': reportId,
    };
  }

  MaterialUsed copyWith({
    String? id,
    String? materialNumber,
    String? materialName,
    int? quantity,
    String? remarks,
    String? reportId,
  }) {
    return MaterialUsed(
      id: id ?? this.id,
      materialNumber: materialNumber ?? this.materialNumber,
      materialName: materialName ?? this.materialName,
      quantity: quantity ?? this.quantity,
      remarks: remarks ?? this.remarks,
      reportId: reportId ?? this.reportId,
    );
  }
} 