import 'package:shared_preferences/shared_preferences.dart';
import 'package:sikarema_mobile/app/constants/storage_constants.dart';

/// Simple storage service for auth token and user profile data.
class StorageService {
  StorageService._();

  static final StorageService _instance = StorageService._();

  factory StorageService() => _instance;

  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(StorageConstants.authToken, token);
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(StorageConstants.authToken);
  }

  Future<void> removeToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(StorageConstants.authToken);
  }

  Future<void> saveUser({
    required int id,
    required String name,
    required String email,
    required String role,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(StorageConstants.userId, id);
    await prefs.setString(StorageConstants.userName, name);
    await prefs.setString(StorageConstants.userEmail, email);
    await prefs.setString(StorageConstants.userRole, role);
  }

  Future<Map<String, dynamic>> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'id': prefs.getInt(StorageConstants.userId),
      'name': prefs.getString(StorageConstants.userName),
      'email': prefs.getString(StorageConstants.userEmail),
      'role': prefs.getString(StorageConstants.userRole),
    };
  }

  Future<void> removeUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(StorageConstants.userId);
    await prefs.remove(StorageConstants.userName);
    await prefs.remove(StorageConstants.userEmail);
    await prefs.remove(StorageConstants.userRole);
  }
}
