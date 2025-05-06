import 'package:inner_voice/data/models/friend/friend_model.dart';

import '../../../core/constants/user/role.dart';

class User {
  final String userId;
  final List<Friend> childList;
  final String? myParent;
  final UserRole role;

  User({
    required this.userId,
    this.childList = const [],
    this.myParent,
    required this.role,
  });

  User copyWith({
    String? userId,
    List<Friend>? childList,
    String? myParent,
    UserRole? role,
  }) {
    return User(
      userId: userId ?? this.userId,
      childList: childList ?? this.childList,
      myParent: myParent ?? this.myParent,
      role: role ?? this.role,
    );
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userId: json['id'].toString(),
      role: json['role'] == 'PARENT' ? UserRole.parent : UserRole.child,
    );
  }
}