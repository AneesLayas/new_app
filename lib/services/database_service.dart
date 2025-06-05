import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  static Database? _database;

  factory DatabaseService() => _instance;

  DatabaseService._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'adsd_offline.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDatabase,
    );
  }

  Future<void> _createDatabase(Database db, int version) async {
    // Reports table
    await db.execute('''
      CREATE TABLE reports(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        report_id TEXT UNIQUE,
        instrument_type TEXT,
        instrument_manufacturer TEXT,
        date TEXT,
        problem_description TEXT,
        problem_solved TEXT,
        remedy_description TEXT,
        technician_name TEXT,
        pdf_path TEXT,
        customer_type TEXT,
        timestamp INTEGER,
        synced INTEGER DEFAULT 0
      )
    ''');

    // Materials used table
    await db.execute('''
      CREATE TABLE materials_used(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        report_id TEXT,
        material_number TEXT,
        material_name TEXT,
        quantity INTEGER,
        remarks TEXT,
        FOREIGN KEY (report_id) REFERENCES reports(report_id)
      )
    ''');

    // Offline data table for API responses
    await db.execute('''
      CREATE TABLE offline_data(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        endpoint TEXT,
        data TEXT,
        timestamp INTEGER,
        synced INTEGER DEFAULT 0
      )
    ''');

    // User data table
    await db.execute('''
      CREATE TABLE user_data(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT UNIQUE,
        role TEXT,
        email TEXT,
        first_name TEXT,
        last_name TEXT,
        phone_number TEXT,
        last_sync INTEGER
      )
    ''');

    // Equipment types table
    await db.execute('''
      CREATE TABLE equipment_types(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        type TEXT UNIQUE,
        last_sync INTEGER
      )
    ''');

    // Manufacturers table
    await db.execute('''
      CREATE TABLE manufacturers(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT UNIQUE,
        last_sync INTEGER
      )
    ''');

    // Customer types table
    await db.execute('''
      CREATE TABLE customer_types(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        type TEXT UNIQUE,
        last_sync INTEGER
      )
    ''');
  }

  // Save report with materials
  Future<void> saveReport(Map<String, dynamic> report, List<Map<String, dynamic>> materials) async {
    final db = await database;
    await db.transaction((txn) async {
      // Insert report
      await txn.insert('reports', {
        'report_id': report['report_id'],
        'instrument_type': report['instrument_type'],
        'instrument_manufacturer': report['instrument_manufacturer'],
        'date': report['date'],
        'problem_description': report['problem_description'],
        'problem_solved': report['problem_solved'],
        'remedy_description': report['remedy_description'],
        'technician_name': report['technician_name'],
        'pdf_path': report['pdf_path'],
        'customer_type': report['customer_type'],
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'synced': 0,
      });

      // Insert materials
      for (var material in materials) {
        await txn.insert('materials_used', {
          'report_id': report['report_id'],
          'material_number': material['material_number'],
          'material_name': material['material_name'],
          'quantity': material['quantity'],
          'remarks': material['remarks'],
        });
      }
    });
  }

  // Get unsynced reports
  Future<List<Map<String, dynamic>>> getUnsyncedReports() async {
    final db = await database;
    return await db.query(
      'reports',
      where: 'synced = ?',
      whereArgs: [0],
    );
  }

  // Get materials for a report
  Future<List<Map<String, dynamic>>> getMaterialsForReport(String reportId) async {
    final db = await database;
    return await db.query(
      'materials_used',
      where: 'report_id = ?',
      whereArgs: [reportId],
    );
  }

  // Mark report as synced
  Future<void> markReportAsSynced(String reportId) async {
    final db = await database;
    await db.update(
      'reports',
      {'synced': 1},
      where: 'report_id = ?',
      whereArgs: [reportId],
    );
  }

  // Save offline API data
  Future<int> saveOfflineData(String endpoint, String data) async {
    final db = await database;
    return await db.insert('offline_data', {
      'endpoint': endpoint,
      'data': data,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'synced': 0,
    });
  }

  // Get unsynced API data
  Future<List<Map<String, dynamic>>> getUnsyncedData() async {
    final db = await database;
    return await db.query(
      'offline_data',
      where: 'synced = ?',
      whereArgs: [0],
    );
  }

  // Mark API data as synced
  Future<void> markAsSynced(int id) async {
    final db = await database;
    await db.update(
      'offline_data',
      {'synced': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Save user data
  Future<void> saveUserData(Map<String, dynamic> userData) async {
    final db = await database;
    await db.insert(
      'user_data',
      {
        'username': userData['username'],
        'role': userData['role'],
        'email': userData['email'],
        'first_name': userData['first_name'],
        'last_name': userData['last_name'],
        'phone_number': userData['phone_number'],
        'last_sync': DateTime.now().millisecondsSinceEpoch,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Get user data
  Future<Map<String, dynamic>?> getUserData(String username) async {
    final db = await database;
    final List<Map<String, dynamic>> results = await db.query(
      'user_data',
      where: 'username = ?',
      whereArgs: [username],
    );
    return results.isNotEmpty ? results.first : null;
  }

  // Save equipment types
  Future<void> saveEquipmentTypes(List<String> types) async {
    final db = await database;
    await db.transaction((txn) async {
      for (var type in types) {
        await txn.insert(
          'equipment_types',
          {
            'type': type,
            'last_sync': DateTime.now().millisecondsSinceEpoch,
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }

  // Get equipment types
  Future<List<String>> getEquipmentTypes() async {
    final db = await database;
    final List<Map<String, dynamic>> results = await db.query('equipment_types');
    return results.map((row) => row['type'] as String).toList();
  }

  // Save manufacturers
  Future<void> saveManufacturers(List<String> manufacturers) async {
    final db = await database;
    await db.transaction((txn) async {
      for (var manufacturer in manufacturers) {
        await txn.insert(
          'manufacturers',
          {
            'name': manufacturer,
            'last_sync': DateTime.now().millisecondsSinceEpoch,
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }

  // Get manufacturers
  Future<List<String>> getManufacturers() async {
    final db = await database;
    final List<Map<String, dynamic>> results = await db.query('manufacturers');
    return results.map((row) => row['name'] as String).toList();
  }

  // Save customer types
  Future<void> saveCustomerTypes(List<String> types) async {
    final db = await database;
    await db.transaction((txn) async {
      for (var type in types) {
        await txn.insert(
          'customer_types',
          {
            'type': type,
            'last_sync': DateTime.now().millisecondsSinceEpoch,
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }

  // Get customer types
  Future<List<String>> getCustomerTypes() async {
    final db = await database;
    final List<Map<String, dynamic>> results = await db.query('customer_types');
    return results.map((row) => row['type'] as String).toList();
  }
} 