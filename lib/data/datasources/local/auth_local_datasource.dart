// lib/data/datasources/local/auth_local_datasource.dart

import 'package:shared_preferences/shared_preferences.dart';

class AuthLocalDataSource {
  static const _userIdKey = 'userId';
  static const _userRoleKey = 'userRole';

  static Future<void> saveUser(String id, String role) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userIdKey, id);
    await prefs.setString(_userRoleKey, role);
  }

  static Future<Map<String, String>?> getStoredUser() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getString(_userIdKey);
    final role = prefs.getString(_userRoleKey);
    if (id != null && role != null) {
      return {'id': id, 'role': role};
    }
    return null;
  }

  static Future<void> clearUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userIdKey);
    await prefs.remove(_userRoleKey);
  }
}