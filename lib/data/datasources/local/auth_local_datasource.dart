import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

class AuthLocalDataSource {
  static const _userIdKey = 'userId';
  static const _userRoleKey = 'userRole';

  static Future<void> saveUser(String id, String role) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userIdKey, id);
    await prefs.setString(_userRoleKey, role);

    debugPrint('✅ [AuthLocal] 저장 완료: userId=$id, role=$role');
  }

  static Future<Map<String, String>?> getStoredUser() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getString(_userIdKey);
    final role = prefs.getString(_userRoleKey);

    if (id != null && role != null) {
      debugPrint('🔄 [AuthLocal] 불러오기 성공: userId=$id, role=$role');
      return {'id': id, 'role': role};
    } else {
      debugPrint('⚠️ [AuthLocal] 저장된 사용자 정보 없음');
      return null;
    }
  }

  static Future<void> clearUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userIdKey);
    await prefs.remove(_userRoleKey);

    debugPrint('🚪 [AuthLocal] 사용자 정보 삭제 완료');
  }
}