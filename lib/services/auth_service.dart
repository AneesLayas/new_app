class AuthService {
  static Future<bool> login(String username, String password) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));
    
    // For demo purposes, accept any non-empty credentials
    return username.isNotEmpty && password.isNotEmpty;
  }
  
  static Future<bool> register(String username, String email, String password) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 2));
    
    // For demo purposes, always return success
    return true;
  }
} 