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

  Future<void> requestFriend({
    required Dio dio,
    required int friendId,
    required String friendName,
  }) async {
    if (_user == null) {
      return;
    }

    final int userId = int.tryParse(_user!.userId) ?? -1;
    if (userId == -1) {
      return;
    }
    await _friendService.sendFriendRequest(
      dio: dio,
      userId: userId,
      friendId: friendId,
      friendName: friendName,
    );
  }

  Future<Map<String, dynamic>?> searchFriend({
    required Dio dio,
    required String friendName,
  }) async {
    if (friendName.trim().isEmpty) {
      debugPrint('⚠️ searchFriend: 이름이 비어 있습니다.');
      return null;
    }

    try {
      final result = await _friendService.searchFriendByName(
        dio: dio,
        name: friendName,
      );
      return result;
    } catch (e) {
      debugPrint('❗ UserProvider.searchFriend 에러: $e');
      return null;
    }
  }
  void clear() {
    debugPrint('🧹 [UserProvider] clear() 호출됨 - 현재 user: ${_user?.userId}');
    _user = null;
    debugPrint('🧹 [UserProvider] user null로 초기화됨');
    notifyListeners();
  }
}
