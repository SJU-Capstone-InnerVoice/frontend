enum UserRole { parent, child, admin }

/// UserRole에 추가적인 기능을 넣어준다.
extension UserRoleExtension on UserRole {
  /// UserRole.parent.name // 'parent'
  String get name {
    switch (this) {
      case UserRole.parent:
        return 'parent';
      case UserRole.child:
        return 'child';
      case UserRole.admin:
        return 'admin';
    }
  }
  /// UserRoleExtension.fromString('admin') // UserRole.admin
  static UserRole fromString(String value) {
    /// UserRole.values = [UserRole.parent, UserRole.child, UserRole.admin]
    /// e 는 각각 원소로 들어가게 되고,
    /// value와 일치하는지 검사
    return UserRole.values.firstWhere(
          (e) => e.name == value,
      /// 없다면 return UserRole.child
      orElse: () => UserRole.child,
    );
  }
}
