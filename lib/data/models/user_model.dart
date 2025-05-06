import '../../core/constants/user/role.dart';

class User {
  final String userId;
  final int roomId;
  final List<String>? childList; // 부모 경우
  final String? myParent; // 아이 경우
  final DateTime createdAt;
  final UserRole role;

  User({
    required this.userId,
    required this.roomId,
    this.childList,
    this.myParent,
    required this.createdAt,
    required this.role,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userId: json['userId'],
      roomId: json['roomId'],
      childList: json['childList'] != null
          ? List<String>.from(json['childList'])
          : null,
      myParent: json['myParent'],
      createdAt: DateTime.parse(json['createdAt']),
      role: UserRole.values.firstWhere((e) => e.name == json['role']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'roomId': roomId,
      'childList': childList,
      'myParent': myParent,
      'createdAt': createdAt.toIso8601String(),
      'role': role.name,
    };
  }
}