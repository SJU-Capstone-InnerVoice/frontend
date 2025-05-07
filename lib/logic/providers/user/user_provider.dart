import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../../data/models/user/user_model.dart';
import '../../../data/models/friend/friend_model.dart';
import '../../../services/login_service.dart';
import '../../../services/friend_service.dart';
class UserProvider with ChangeNotifier {
  final LoginService _loginService = LoginService();
  final FriendService _friendService = FriendService();

  User? _user;

  User? get user => _user;


  void setUser(User newUser) {
    _user = newUser;
    notifyListeners();
  }

  void setParent(String parentId) {
    _user = _user!.copyWith(myParent: parentId);
    notifyListeners();
  }

  Future<void> handleLogin(Dio dio, String name, String password) async {
    final user = await _loginService.login(dio, name, password);
    setUser(user);
  }

  Future<void> setChildList(Dio dio) async {
    if (_user == null) return;

    try {
      final List<Friend> childList =
      await _friendService.queryChildList(dio: dio, userId: _user!.userId);
      _user = _user!.copyWith(childList: childList);
      notifyListeners();
    } catch (e) {
      print('❌ childList 설정 실패: $e');
    }
  }
  void clear() {
    debugPrint('🧹 [UserProvider] clear() 호출됨 - 현재 user: ${_user?.userId}');
    _user = null;
    debugPrint('🧹 [UserProvider] user null로 초기화됨');
    notifyListeners();
  }
}