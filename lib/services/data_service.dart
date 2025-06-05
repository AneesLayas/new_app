class DataService {
  static List<Map<String, dynamic>> _records = [];

  static Future<List<Map<String, dynamic>>> getAllRecords() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));
    return _records;
  }

  static Future<bool> addRecord(Map<String, dynamic> record) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));
    
    record['id'] = DateTime.now().millisecondsSinceEpoch.toString();
    record['createdDate'] = DateTime.now().toString().split(' ')[0];
    _records.add(record);
    
    return true;
  }

  static Future<bool> updateRecord(String id, Map<String, dynamic> updatedRecord) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));
    
    final index = _records.indexWhere((record) => record['id'] == id);
    if (index != -1) {
      _records[index] = {...updatedRecord, 'id': id};
      return true;
    }
    return false;
  }

  static Future<bool> deleteRecord(String id) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));
    
    _records.removeWhere((record) => record['id'] == id);
    return true;
  }
} 