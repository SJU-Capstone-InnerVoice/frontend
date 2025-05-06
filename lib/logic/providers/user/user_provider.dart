import 'package:flutter/material.dart';
import '../../../data/models/user/user_model.dart';

class UserProvider with ChangeNotifier {
  late User _user;
  User get user => _user;

  void setUser(User newUser) {
    _user = newUser;
    notifyListeners();
  }

  void addChild(String childId) {
    _user = _user.copyWith(childList: [..._user.childList, childId]);
    notifyListeners();
  }

  void setParent(String parentId) {
    _user = _user.copyWith(myParent: parentId);
    notifyListeners();
  }
}