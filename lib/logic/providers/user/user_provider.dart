import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../../data/models/user/user_model.dart';
import '../../../services/login_service.dart';

class UserProvider with ChangeNotifier {
  final LoginService _loginService = LoginService();

  User? _user;
  User? get user => _user;

  void setUser(User newUser) {
    _user = newUser;
    notifyListeners();
  }

  void addChild(String childId) {
    _user = _user!.copyWith(childList: [..._user!.childList, childId]);
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
}