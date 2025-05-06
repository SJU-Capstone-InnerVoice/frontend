import '../../../core/constants/user/role.dart';

class User {
  final String userId;
  final List<String>? childList; // 부모 경우
  final String? myParent; // 아이 경우
  final UserRole role;

  User({
    required this.userId,
    this.childList,
    this.myParent,
    required this.role,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userId: json['userId'],
      childList: json['childList'] != null
          ? List<String>.from(json['childList'])
          : null,
      myParent: json['myParent'],
      role: UserRole.values.firstWhere((e) => e.name == json['role']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'childList': childList,
      'myParent': myParent,
      'role': role.name,
    };
  }
}